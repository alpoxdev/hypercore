#!/usr/bin/env bash
# hyper-seo score, status, flow and optimization-history contracts — bash port
# of scripts/tests/hyper-seo-score.test.mjs.
#
# The score is recomputed from the documents instead of trusted: weights come
# from the `<scoring>` block in SKILL.md, the category example from
# artifact-spec.md, and the weighted score and grade are recalculated and
# compared with the grade the document prints.
#
# HYPER_SEO_DOC_ROOT points every contract read at a copied tree. The mutation
# controls copy one file into a temp root and never touch the working tree.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "$(dirname "$0")/lib/hyper-seo-doc-contracts.sh"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
DOC_ROOT=${HYPER_SEO_DOC_ROOT:-$ROOT}

RESULTS_SECTION="\`results.json\`"
FLOW_SECTION="\`flow.json\`"
CATEGORY_STATUSES="measured unknown not-applicable"
CONFIDENCES="high medium low"
FLOW_STATUSES="pending running complete skipped"
CANONICAL_WEIGHTS="20 20 15 15 10 10 10"

# doc <relative-path> — path under the configured document root.
doc() {
  printf '%s/%s\n' "$DOC_ROOT" "$1"
}

# copy_doc <workdir> <relative-path> — copy one repository file, print its path.
copy_doc() {
  local dir=$1 rel=$2
  mkdir -p "$dir/$(dirname "$rel")"
  cp "$ROOT/$rel" "$dir/$rel"
  printf '%s/%s\n' "$dir" "$rel"
}

# section_lines <file> <title> — start and end line of one section body.
section_lines() {
  awk -v want="$2" '
    /^#{1,6}[ \t]/ {
      if (started) { print start, NR - 1; exit }
      title = $0
      sub(/^#+[ \t]+/, "", title)
      sub(/[ \t\r]+$/, "", title)
      if (title == want) { started = 1; start = NR + 1 }
    }
    END { if (started) print start, NR }
  ' "$1"
}

# section_text <file> <title> — body of one section, up to the next heading.
section_text() {
  local range start end
  range=$(section_lines "$1" "$2")
  [ -n "$range" ] || return 1
  start=${range%% *}
  end=${range##* }
  awk -v s="$start" -v e="$end" 'NR >= s && NR <= e' "$1"
}

# json_example <file> <title> — first ```json fence of one section.
json_example() {
  section_text "$1" "$2" | awk '
    /^```json[ \t\r]*$/ { inside = 1; next }
    inside && /^```[ \t\r]*$/ { exit }
    inside { print }
  '
}

# json_fence_lines <file> <title> — open and close line numbers of the fence.
json_fence_lines() {
  local file=$1 range start end
  range=$(section_lines "$file" "$2")
  [ -n "$range" ] || return 1
  start=${range%% *}
  end=${range##* }
  awk -v s="$start" -v e="$end" '
    NR >= s && NR <= e && /^```json[ \t\r]*$/ && !fence { fence = NR; next }
    fence && NR > fence && /^```[ \t\r]*$/ { print fence, NR; exit }
  ' "$file"
}

# edit_json_example <file> <title> <jq-filter> — rewrite the section JSON example.
edit_json_example() {
  local file=$1 title=$2 filter=$3 fence open close work
  fence=$(json_fence_lines "$file" "$title")
  [ -n "$fence" ] || return 1
  open=${fence%% *}
  close=${fence##* }
  work=$(new_workdir)
  awk -v o="$open" -v c="$close" 'NR > o && NR < c' "$file" >"$work/example.json"
  jq "$filter" "$work/example.json" >"$work/mutated.json" || return 1
  {
    awk -v o="$open" 'NR <= o' "$file"
    cat "$work/mutated.json"
    awk -v c="$close" 'NR >= c' "$file"
  } >"$work/rewritten.md"
  mv "$work/rewritten.md" "$file"
}

# scoring_weights <file> — weights in canonical order from the scoring block.
scoring_weights() {
  awk '
    /<scoring>/ { inside = 1; next }
    /<\/scoring>/ { inside = 0 }
    inside {
      if (match($0, /^[ \t]*-[ \t]+[^:]+:[ \t]*[0-9]+[ \t\r]*$/)) {
        value = $0
        sub(/^[ \t]*-[ \t]+[^:]+:[ \t]*/, "", value)
        sub(/[ \t\r]+$/, "", value)
        printf "%s%s", (count++ ? " " : ""), value
      }
    }
  ' "$1"
}

# threshold_table <file> — Average|Grade table text (header plus rows).
threshold_table() {
  hs_table "$1" "Average"
}

# grade_for <score> <threshold-table> — first matching grade.
grade_for() {
  local score=$1 table=$2
  hs_table_rows "$table" | awk -F '\t' -v score="$score" '
    {
      cell = $1
      if (cell ~ /^>=[ \t]*[0-9]+$/) {
        min = cell
        sub(/^>=[ \t]*/, "", min)
        if (score + 0 >= min + 0) { print $2; exit }
      } else if (cell ~ /^<[ \t]*[0-9]+$/) {
        max = cell
        sub(/^<[ \t]*/, "", max)
        if (score + 0 < max + 0) { print $2; exit }
      }
    }
  '
}

# weighted_score <space-separated scores> <space-separated weights>.
weighted_score() {
  awk -v scores="$1" -v weights="$2" '
    BEGIN {
      n = split(scores, s, " ")
      m = split(weights, w, " ")
      if (n != m) exit 1
      for (i = 1; i <= n; i++) { total += s[i] * w[i]; weight += w[i] }
      rounded = int((total / weight) * 100 + 0.5) / 100
      printf "%.2f\n", rounded
    }
  ' | sed 's/0*$//; s/\.$//'
}

# skill_flow_phases <file> — phase names from the flow.json sentence.
skill_flow_phases() {
  awk '
    END { if (!done) exit 1 }
    /`flow\.json` tracks phases in order:/ {
      done = 1
      if (!match($0, /in order:[ \t]*[^.]*\./)) exit 1
      text = substr($0, RSTART + 9, RLENGTH - 10)
      while (match(text, /`[^`]+`/)) {
        printf "%s\n", substr(text, RSTART + 1, RLENGTH - 2)
        text = substr(text, RSTART + RLENGTH)
      }
      exit 0
    }
  ' "$1"
}

# section_table <file> <section-suffix> <header-cell...> — table text.
section_table() {
  local file=$1 suffix=$2
  shift 2
  hs_records "$file" | awk -F "$HS_US" -v suffix="$suffix" -v want="$*" '
    function join_cells(from, to,   s, i) {
      s = ""
      for (i = from; i <= to; i++) s = s (i > from ? "\t" : "") $i
      return s
    }
    $1 == "T" {
      t = $2
      n = length(suffix)
      if ($3 == "-1") {
        if (substr($4, length($4) - n + 1) != suffix) { active[t] = 0; next }
        cells = join_cells(5, NF)
        gsub(/\t/, " ", cells)
        if (cells != want) { active[t] = 0; next }
        active[t] = 1
        print join_cells(5, NF)
        next
      }
      if (active[t]) print join_cells(5, NF)
    }
  '
}

# history_failures <results-json> <threshold-table> — failures, one per line.
history_failures() {
  local json=$1 table=$2 count i label evaluator weights grade decision score
  local prev_evaluator='' prev_weights='' have_prev=0
  count=$(jq '.score_history | if type == "array" then length else 0 end' "$json")
  if [ "$count" -eq 0 ]; then
    printf 'score_history is missing\n'
    return 0
  fi
  i=0
  while [ "$i" -lt "$count" ]; do
    label="score_history[$i] (iteration $(jq -r ".score_history[$i].iteration" "$json"))"
    evaluator=$(jq -r ".score_history[$i].evaluator_version // \"\"" "$json")
    weights=$(jq -c ".score_history[$i].weights // null" "$json")
    grade=$(jq -r ".score_history[$i].grade" "$json")
    decision=$(jq -r ".score_history[$i].decision // \"\"" "$json")
    score=$(jq -r ".score_history[$i].score" "$json")

    if [ -z "$(printf '%s' "$evaluator" | tr -d '[:space:]')" ]; then
      printf '%s: evaluator_version is required\n' "$label"
    fi
    if [ "$(printf '%s' "$weights" | jq 'if type == "array" and length > 0 and (map(type == "number") | all) then 1 else 0 end')" != "1" ]; then
      printf '%s: weights are required\n' "$label"
    fi
    if [ "$grade" != "$(grade_for "$score" "$table")" ]; then
      printf '%s: grade %s does not match score %s\n' "$label" "$grade" "$score"
    fi
    if [ "$have_prev" -eq 1 ] && [ "$decision" != "reset" ]; then
      if [ "$evaluator" != "$prev_evaluator" ] || [ "$weights" != "$prev_weights" ]; then
        printf '%s: evaluator_version or weights changed without a reset event\n' "$label"
      fi
    fi
    prev_evaluator=$evaluator
    prev_weights=$weights
    have_prev=1
    i=$((i + 1))
  done

  local best_iteration best_score best_grade target_count target_decision target_score kept_max
  best_iteration=$(jq -r '.best_run.iteration // ""' "$json")
  if [ -z "$best_iteration" ]; then
    printf 'best_run is missing\n'
    return 0
  fi
  target_count=$(jq --argjson iteration "$best_iteration" '[.score_history[] | select(.iteration == $iteration)] | length' "$json")
  if [ "$target_count" -eq 0 ]; then
    printf 'best_run.iteration %s: no matching iteration\n' "$best_iteration"
    return 0
  fi
  target_decision=$(jq -r --argjson iteration "$best_iteration" '.score_history[] | select(.iteration == $iteration) | .decision' "$json")
  target_score=$(jq -r --argjson iteration "$best_iteration" '.score_history[] | select(.iteration == $iteration) | .score' "$json")
  best_score=$(jq -r '.best_run.score' "$json")
  best_grade=$(jq -r '.best_run.grade' "$json")
  if [ "$target_decision" = "discarded" ]; then
    printf 'best_run points at a discarded iteration (%s)\n' "$best_iteration"
  fi
  if [ "$target_decision" != "kept" ]; then
    printf 'best_run iteration %s is not a kept iteration\n' "$best_iteration"
  fi
  if [ "$best_score" != "$target_score" ]; then
    printf 'best_run.score %s does not match iteration score %s\n' "$best_score" "$target_score"
  fi
  if [ "$best_grade" != "$(grade_for "$best_score" "$table")" ]; then
    printf 'best_run.grade %s does not match score %s\n' "$best_grade" "$best_score"
  fi
  kept_max=$(jq '[.score_history[] | select(.decision == "kept") | .score] | max // empty' "$json")
  if [ -n "$kept_max" ] && awk -v best="$best_score" -v top="$kept_max" 'BEGIN { exit (best + 0 < top + 0) ? 0 : 1 }'; then
    printf 'best_run.score %s is below the highest kept score %s\n' "$best_score" "$kept_max"
  fi
}

# contract_of_mutated_spec <jq-filter> — copy, mutate, recompute the contract.
# Prints: overall_grade <TAB> grade_matches <TAB> history length <TAB> history lines.
contract_of_mutated_spec() {
  local work target markdown results weights thresholds categories computed history length
  work=$(new_workdir)
  target=$(copy_doc "$work" "$HS_ARTIFACT_SPEC_EN")
  edit_json_example "$target" "$RESULTS_SECTION" "$1" || return 1
  markdown="$target"
  json_example "$markdown" "$RESULTS_SECTION" >"$work/results.json" || return 1
  results="$work/results.json"
  weights=$(scoring_weights "$(doc "$HS_SKILL_EN")")
  thresholds=$(threshold_table "$markdown")
  categories=$(jq -r '[.categories[] | (.score // 0)] | map(tostring) | join(" ")' "$results")
  computed=$(grade_for "$(weighted_score "$categories" "$weights")" "$thresholds")
  history=$(history_failures "$results" "$thresholds")
  length=$(jq '.score_history | length' "$results")
  printf '%s\t%s\t%s\t%s\n' \
    "$(jq -r '.overall_grade' "$results")" \
    "$([ "$computed" = "$(jq -r '.overall_grade' "$results")" ] && echo 1 || echo 0)" \
    "$length" \
    "$(printf '%s' "$history" | tr '\n' "$HS_US")"
}

# history_text <outcome> — the US-joined failure field as newline text.
history_text() {
  printf '%s\n' "$1" | tr "$HS_US" '\t' | cut -f4 | tr "$HS_US" '\n'
}

# ---- cases ---------------------------------------------------------------

case_documented_example_grades() {
  local work weights scores thresholds computed grade
  work=$(new_workdir)
  cp "$(doc "$HS_ARTIFACT_SPEC_EN")" "$work/spec.md"
  weights=$(scoring_weights "$(doc "$HS_SKILL_EN")")
  assert_eq "$CANONICAL_WEIGHTS" "$weights" "SKILL.md weights"

  json_example "$work/spec.md" "$RESULTS_SECTION" >"$work/results.json"
  scores=$(jq -r '[.categories[].score] | map(tostring) | join(" ")' "$work/results.json")
  assert_eq "7" "$(printf '%s\n' "$scores" | wc -w | tr -d ' ')" "category score count"

  thresholds=$(threshold_table "$work/spec.md")
  assert_nonempty "$thresholds" "threshold table"
  computed=$(weighted_score "$scores" "$weights")
  assert_eq "72.2" "$computed" "weighted score"
  grade=$(grade_for "$computed" "$thresholds")
  assert_eq "C" "$grade" "computed grade"
  assert_eq "C" "$(jq -r '.overall_grade' "$work/results.json")" "documented grade"
}

case_grade_thresholds_unchanged() {
  local work table rows
  work=$(new_workdir)
  cp "$(doc "$HS_ARTIFACT_SPEC_EN")" "$work/spec.md"
  table=$(threshold_table "$work/spec.md")
  assert_nonempty "$table" "threshold table"
  rows=$(hs_table_rows "$table" | awk -F '\t' '
    {
      cell = $1
      if (cell ~ /^>=[ \t]*[0-9]+$/) { min = cell; sub(/^>=[ \t]*/, "", min); printf "min=%s grade=%s;", min, $2 }
      else if (cell ~ /^<[ \t]*[0-9]+$/) { max = cell; sub(/^<[ \t]*/, "", max); printf "min=-Inf max=%s grade=%s;", max, $2 }
    }
  ' | sed 's/;$//')
  assert_eq "min=90 grade=A;min=75 grade=B;min=60 grade=C;min=40 grade=D;min=-Inf max=40 grade=F" "$rows" "threshold rows"
}

case_category_examples() {
  local work count i keys status confidence evidence score
  work=$(new_workdir)
  cp "$(doc "$HS_ARTIFACT_SPEC_EN")" "$work/spec.md"
  json_example "$work/spec.md" "$RESULTS_SECTION" >"$work/results.json"
  count=$(jq '.categories | length' "$work/results.json")
  assert_eq "7" "$count" "category count"
  i=0
  while [ "$i" -lt "$count" ]; do
    keys=",$(jq -r ".categories[$i] | keys | join(\",\")" "$work/results.json"),"
    for key in name status score evidence confidence; do
      assert_contains "$keys" ",$key," "categories[$i].$key present"
    done
    status=$(jq -r ".categories[$i].status" "$work/results.json")
    assert_contains " $CATEGORY_STATUSES " " $status " "categories[$i].status enum"
    confidence=$(jq -r ".categories[$i].confidence" "$work/results.json")
    assert_contains " $CONFIDENCES " " $confidence " "categories[$i].confidence enum"
    evidence=$(jq -r ".categories[$i].evidence" "$work/results.json")
    assert_nonempty "$evidence" "categories[$i].evidence"
    score=$(jq -r ".categories[$i].score // \"null\"" "$work/results.json")
    if [ "$score" != "null" ]; then
      awk -v value="$score" 'BEGIN { exit (value + 0 >= 0 && value + 0 <= 100) ? 0 : 1 }' ||
        fail "categories[$i].score out of range: $score"
    fi
    i=$((i + 1))
  done
}

case_korean_spec_mirrors() {
  local work en_tuples ko_tuples keys
  work=$(new_workdir)
  cp "$(doc "$HS_ARTIFACT_SPEC_EN")" "$work/en.md"
  cp "$(doc "$HS_ARTIFACT_SPEC_KO")" "$work/ko.md"
  json_example "$work/en.md" "$RESULTS_SECTION" >"$work/en.json"
  json_example "$work/ko.md" "$RESULTS_SECTION" >"$work/ko.json"
  assert_eq "$(jq -r '.overall_grade' "$work/en.json")" "$(jq -r '.overall_grade' "$work/ko.json")" "overall grade"
  en_tuples=$(jq -c '[.categories[] | [.name, .status, .score]]' "$work/en.json")
  ko_tuples=$(jq -c '[.categories[] | [.name, .status, .score]]' "$work/ko.json")
  assert_eq "$en_tuples" "$ko_tuples" "category tuples"
  keys=",$(jq -r '[.categories[] | keys] | add | join(",")' "$work/ko.json"),"
  for key in status evidence confidence; do
    assert_contains "$keys" ",$key," "ko category field $key"
  done
  json_example "$work/en.md" "$FLOW_SECTION" | jq -r '[.phases[].name] | join(",")' >"$work/en.phases"
  json_example "$work/ko.md" "$FLOW_SECTION" | jq -r '[.phases[].name] | join(",")' >"$work/ko.phases"
  assert_eq "$(cat "$work/en.phases")" "$(cat "$work/ko.phases")" "phase names"
}

case_flow_contract() {
  local work phases statuses first_incomplete rows status_cell
  work=$(new_workdir)
  cp "$(doc "$HS_ARTIFACT_SPEC_EN")" "$work/spec.md"
  json_example "$work/spec.md" "$FLOW_SECTION" >"$work/flow.json"
  phases=$(jq -r '[.phases[].name] | join(",")' "$work/flow.json")
  assert_eq "$(skill_flow_phases "$(doc "$HS_SKILL_EN")" | paste -sd, -)" "$phases" "flow.json phases match SKILL.md"

  statuses=$(jq -r '[.phases[].status] | unique | map(tostring) | join(" ")' "$work/flow.json")
  for status in $statuses; do
    assert_contains " $FLOW_STATUSES " " $status " "phase status enum"
  done
  first_incomplete=$(jq -r '[.phases[] | select(.status != "complete")] | first | .name' "$work/flow.json")
  assert_eq "$first_incomplete" "$(jq -r '.resume_at' "$work/flow.json")" "resume_at points at the first incomplete phase"

  rows=$(section_table "$work/spec.md" "$FLOW_SECTION" "Field" "Contract")
  assert_nonempty "$rows" "flow contract table"
  hs_table_rows "$rows" >"$work/rows.tsv"
  local status_key="\`phases[].status\`"
  for key in "\`phases[].name\`" "$status_key" "\`resume_at\`"; do
    assert_contains "$(cut -f1 "$work/rows.tsv")" "$key" "contract row $key"
  done
  status_cell=$(awk -F '\t' -v key="$status_key" '$1 == key { print $2 }' "$work/rows.tsv")
  assert_eq "$(printf '%s' "$status_cell" | grep -oE "\`[^\`]+\`" | tr -d '\140' | paste -sd, -)" \
    "$(printf '%s' "$FLOW_STATUSES" | tr ' ' ',')" "status cell enum"
}

case_documented_history() {
  local work weights failures count i entry_weights
  work=$(new_workdir)
  cp "$(doc "$HS_ARTIFACT_SPEC_EN")" "$work/spec.md"
  json_example "$work/spec.md" "$RESULTS_SECTION" >"$work/results.json"
  weights=$(scoring_weights "$(doc "$HS_SKILL_EN")" | sed 's/ /,/g')
  count=$(jq '.score_history | length' "$work/results.json")
  i=0
  while [ "$i" -lt "$count" ]; do
    entry_weights=$(jq -r ".score_history[$i].weights | map(tostring) | join(\",\")" "$work/results.json")
    assert_eq "$weights" "$entry_weights" "score_history[$i].weights"
    i=$((i + 1))
  done
  failures=$(history_failures "$work/results.json" "$(threshold_table "$work/spec.md")")
  assert_empty "$failures" "documented history"
}

case_rejects_wrong_grade() {
  local outcome
  outcome=$(contract_of_mutated_spec '.overall_grade = "B"')
  assert_eq "B" "$(printf '%s' "$outcome" | cut -f1)" "mutated grade"
  assert_eq "0" "$(printf '%s' "$outcome" | cut -f2)" "recomputed grade disagrees"
}

case_rejects_missing_evaluator_version() {
  local outcome history
  outcome=$(contract_of_mutated_spec 'del(.score_history[1].evaluator_version)')
  history=$(history_text "$outcome")
  assert_contains "$history" "evaluator_version" "evaluator_version failure"
}

case_rejects_weight_change_without_reset() {
  local outcome history
  outcome=$(contract_of_mutated_spec '.score_history[1].weights = [25,20,15,10,10,10,10]')
  history=$(history_text "$outcome")
  assert_contains "$history" "reset" "reset failure"
}

case_rejects_discarded_best_run() {
  local outcome history
  outcome=$(contract_of_mutated_spec '.score_history[1].decision = "discarded"')
  history=$(history_text "$outcome")
  assert_contains "$history" "discarded" "discarded failure"
}

case_rejects_lower_best_run() {
  local outcome history
  outcome=$(contract_of_mutated_spec '.score_history += [{iteration: 2, score: 85, grade: "B", critical_count: 0, decision: "kept", changed: "Cleaned up remaining on-page issues", evidence: "Later re-audit", evaluator_version: .score_history[1].evaluator_version, weights: .score_history[1].weights}]')
  assert_eq "3" "$(printf '%s' "$outcome" | cut -f3)" "history length"
  history=$(history_text "$outcome")
  assert_contains "$history" "highest kept score" "highest kept score failure"
}

run_case "the documented example grades with the SKILL.md weights" case_documented_example_grades
run_case "grade thresholds stay unchanged" case_grade_thresholds_unchanged
run_case "category examples record status, evidence, and confidence" case_category_examples
run_case "the Korean spec mirrors the English score and flow example" case_korean_spec_mirrors
run_case "the flow.json contract matches the SKILL.md phase list" case_flow_contract
run_case "the documented optimization history satisfies the history contract" case_documented_history
run_case "rejects a documented grade that the weights do not produce" case_rejects_wrong_grade
run_case "rejects a history entry without evaluator_version" case_rejects_missing_evaluator_version
run_case "rejects a weight change without a reset event" case_rejects_weight_change_without_reset
run_case "rejects best_run pointing at a discarded iteration" case_rejects_discarded_best_run
run_case "rejects best_run that is not the highest kept score" case_rejects_lower_best_run
test_summary
