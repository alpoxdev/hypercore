#!/usr/bin/env bash
# hyper-seo behavioural eval corpus — bash port of
# scripts/tests/hyper-seo-evals.test.mjs.
#
# Every case carries a machine-readable probe naming a real seam, and the runner
# computes the actual value by calling that seam:
#   1. render-gate  — render-dashboard.sh run against a temp dir holding the
#      case payload; the verdict is the exit code plus what it wrote, read back
#      out of the results.js it produced, or the rejected field from stderr.
#   2. render-page  — the shipped dashboard template executed with node over the
#      case payload; escaping and chart-absent observations.
#   3. doc-query    — the shared document parser over the real rule documents.
# Cases with no seam are marked probe.kind "none", and the runner asserts that
# exact set instead of letting an unevaluated case look evaluated.
#
# HYPER_SEO_EVAL_DIR points the corpus read at another directory holding both
# JSONL files; documents and scripts always come from the repository.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "$(dirname "$0")/lib/hyper-seo-doc-contracts.sh"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
EVAL_DIR="$ROOT/skills/hyper-seo/assets/evals"
EN_NAME="hyper-seo-cases.jsonl"
KO_NAME="hyper-seo-cases.ko.jsonl"
CORPUS_DIR=${HYPER_SEO_EVAL_DIR:-$EVAL_DIR}
RENDERER="$ROOT/skills/hyper-seo/scripts/render-dashboard.sh"
TEMPLATE="$ROOT/skills/hyper-seo/assets/dashboard-template.html"
RESULTS_JS_PREFIX='window.__SEO_RESULTS__ = '

NO_SEAM_IDS=(seo-guarantee-language-negative seo-non-seo-negative seo-policy-bulk-generation seo-policy-expired-domain seo-site-setup-positive)
REQUIRED_METRICS="evidence-discipline unknown-handling no-guarantee-language policy-accuracy scope-fidelity target-conditionality output-escaping dashboard-resilience tool-fallback triggerability"
# axis|case-id-prefix
REQUIRED_AXES=(
  "normal audit|seo-audit-positive"
  "missing evidence grade|seo-missing-evidence-grade"
  "all channels unknown|seo-all-unknown"
  "not-applicable mix|seo-not-applicable-mix"
  "tool-absent fallback|seo-tool-absent-fallback"
  "chart not loaded|seo-chart-not-loaded"
  "external markup in a finding|seo-finding-with-markup"
  "bulk generation policy|seo-policy-bulk-generation"
  "expired domain policy|seo-policy-expired-domain"
  "unverified policy not stated as fact|seo-unverified-policy-negative"
  "no rich-result, index or citation guarantee|seo-guarantee-language-negative"
  "commerce-only stays conditional|seo-commerce-only-negative"
  "Naver and Bing stay conditional|seo-platform-conditional-negative"
  "non-SEO request does not trigger|seo-non-seo-negative"
  "new site setup plan|seo-site-setup-positive"
)

# ---- corpus and seam helpers ---------------------------------------------

# load_corpus <dir> <name> <out> — the JSONL file as one JSON array.
load_corpus() {
  jq -s -c '.' "$1/$2" >"$3"
}

# lines_json — stdin lines as a canonical JSON array of strings.
lines_json() {
  local text
  text=$(cat)
  if [ -z "$text" ]; then
    printf '[]\n'
  else
    printf '%s\n' "$text" | jq -R . | jq -sc .
  fi
}

# numbers_json — stdin numeric lines as a canonical JSON array of numbers.
numbers_json() {
  local text
  text=$(cat)
  if [ -z "$text" ]; then
    printf '[]\n'
  else
    printf '%s\n' "$text" | jq -sc 'map(tonumber)'
  fi
}

# json_string <value> — one value as a canonical JSON string.
json_string() {
  printf '%s' "$1" | jq -Rs .
}

# temp_root — TMPDIR without a trailing separator.
temp_root() {
  local root=${TMPDIR:-/tmp}
  printf '%s\n' "${root%/}"
}

# rejected_field <stderr-file> — the results.json field the renderer named.
rejected_field() {
  local line rest
  line=$(awk '
    {
      candidate = $0
      sub(/^[ \t]+/, "", candidate)
      sub(/[ \t\r]+$/, "", candidate)
      if (index(candidate, "results.json ") == 1) { print candidate; exit }
    }
  ' "$1")
  if [ -z "$line" ]; then
    printf 'unknown'
    return 0
  fi
  if [ "${line#results.json 필수 키가 없습니다: }" != "$line" ]; then
    printf 'required(%s)' "${line#results.json 필수 키가 없습니다: }"
    return 0
  fi
  rest=${line#results.json }
  printf '%s' "${rest%% *}"
}

# render_gate_verdict <payload> <workdir> — canonical JSON verdict string.
render_gate_verdict() {
  local payload=$1 work=$2 dir rc stderr_file statuses findings value
  dir=$(mktemp -d "$(temp_root)/hyper-seo-eval-render.XXXXXX")
  printf '%s\n' "$dir" >>"$TL_STATE_DIR/workdirs"
  cp "$payload" "$dir/results.json"
  stderr_file="$work/stderr.txt"
  rc=0
  NO_COLOR=1 bash "$RENDERER" "$dir" >"$work/stdout.txt" 2>"$stderr_file" || rc=$?
  if [ "$rc" -ne 0 ]; then
    json_string "rejected:$(rejected_field "$stderr_file")"
    return 0
  fi
  if [ ! -f "$dir/dashboard.html" ] || [ ! -f "$dir/results.js" ]; then
    value="partial:exit0:dashboard=$([ -f "$dir/dashboard.html" ] && echo true || echo false):resultsJs=$([ -f "$dir/results.js" ] && echo true || echo false)"
    json_string "$value"
    return 0
  fi
  statuses=$(sed -e "s/^${RESULTS_JS_PREFIX}//" "$dir/results.js" | sed 's/;$//' | jq -r '[.categories[]?.status] | join(",")')
  findings=$(sed -e "s/^${RESULTS_JS_PREFIX}//" "$dir/results.js" | sed 's/;$//' | jq -r '(.findings // []) | length')
  json_string "rendered:$statuses:$findings"
}

# compute_actual <case-json> <workdir> — canonical JSON actual value.
compute_actual() {
  local case_file=$1 work=$2 kind query doc observe targets t ids result payload
  kind=$(jq -r '.probe.kind' "$case_file")
  case $kind in
    none)
      printf 'null\n'
      ;;
    doc-query)
      query=$(jq -r '.probe.query' "$case_file")
      doc=$(jq -r '.probe.doc' "$case_file")
      case $query in
        heuristicItemIndices)
          hs_heuristic_indices "$ROOT/$doc" | numbers_json
          ;;
        rankingAlgorithmIds)
          hs_ranking_ids "$ROOT/$doc" | lines_json
          ;;
        conditionalItemsForTarget)
          targets=$(jq -r '.probe.targets[]' "$case_file")
          result='{}'
          for t in $targets; do
            ids=$(hs_conditional_items_for_target "$ROOT/$doc" "$t")
            result=$(printf '%s' "$result" | jq --arg t "$t" --argjson ids "$(printf '%s\n' "$ids" | lines_json)" '. + {($t): $ids}')
          done
          printf '%s' "$result" | jq -Sc .
          ;;
        *)
          printf 'unknown doc-query: %s\n' "$query" >&2
          return 2
          ;;
      esac
      ;;
    render-gate)
      payload="$work/payload.json"
      jq '.probe.payload' "$case_file" >"$payload"
      render_gate_verdict "$payload" "$work"
      ;;
    render-page)
      payload="$work/payload.json"
      observe=$(jq -r '.probe.observe' "$case_file")
      jq '.probe.payload' "$case_file" >"$payload"
      hs_render_page_verdict "$TEMPLATE" "$payload" "$observe"
      ;;
    *)
      printf 'unknown probe kind: %s\n' "$kind" >&2
      return 2
      ;;
  esac
}

# evaluate_corpus <dir> <workdir> — one TSV line per case:
# id <TAB> kind <TAB> ok(1|0) <TAB> expected <TAB> actual
evaluate_corpus() {
  local dir=$1 work=$2 name line id kind expected actual ok
  : >"$work/run.tsv"
  for name in "$EN_NAME" "$KO_NAME"; do
    jq -c '.' "$dir/$name" >"$work/entries.jsonl"
    while IFS= read -r line; do
      printf '%s\n' "$line" >"$work/case.json"
      id=$(jq -r '.id' "$work/case.json")
      kind=$(jq -r '.probe.kind' "$work/case.json")
      expected=$(jq -Sc '.probe.expected' "$work/case.json")
      actual=$(compute_actual "$work/case.json" "$work")
      if [ "$actual" = "$expected" ]; then ok=1; else ok=0; fi
      printf '%s\t%s\t%s\t%s\t%s\n' "$id" "$kind" "$ok" "$expected" "$actual" >>"$work/run.tsv"
    done <"$work/entries.jsonl"
  done
}

# ---- corpus structure ----------------------------------------------------

case_language_files_parse() {
  local work en_count ko_count
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  en_count=$(jq 'length' "$work/en.json")
  ko_count=$(jq 'length' "$work/ko.json")
  [ "$en_count" -ge 14 ] || fail "too few English cases: $en_count"
  assert_eq "$en_count" "$ko_count" "case count"
}

case_required_fields() {
  local work
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  jq -e '
    all(.[];
      ((.id | type) == "string") and ((.id | length) > 0) and
      ((.intent | type) == "string") and ((.prompt | type) == "string") and
      ((.shouldTrigger | type) == "boolean") and
      ((.context | type) == "object") and
      ((.expected.must | type) == "array") and ((.expected.must | length) > 0) and
      ((.expected.mustNot | type) == "array") and ((.expected.mustNot | length) > 0) and
      ((.metrics | type) == "array") and ((.metrics | length) > 0) and
      (.category as $c | ["positive", "negative", "boundary", "adversarial"] | index($c) != null)
    )
  ' "$work/en.json" "$work/ko.json" >/dev/null ||
    fail "an entry is missing a required field"
}

case_probe_executable() {
  local work doc
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  jq -e '
    all(.[];
      ((.probe | type) == "object") and
      (.probe.kind as $k | ["render-gate", "render-page", "doc-query", "none"] | index($k) != null) and
      (if .probe.kind == "none" then (.probe | has("expected") | not)
       else
         (.probe | has("expected")) and
         (if (.probe.kind == "render-gate" or .probe.kind == "render-page")
          then ((.probe.payload | type) == "object") and (.probe.payload | has("findings"))
          else true end) and
         (if .probe.kind == "render-page"
          then (.probe.observe as $o | ["escaping", "chart-absent"] | index($o) != null)
          else true end) and
         (if .probe.kind == "doc-query"
          then ((.probe.doc | type) == "string") and
               (.probe.query as $q | ["heuristicItemIndices", "rankingAlgorithmIds", "conditionalItemsForTarget"] | index($q) != null)
          else true end)
       end)
    )
  ' "$work/en.json" "$work/ko.json" >/dev/null ||
    fail "a probe is not executable as described"

  for doc in $(jq -r '.[] | select(.probe.kind == "doc-query") | .probe.doc' "$work/en.json" "$work/ko.json" | sort -u); do
    assert_file "$ROOT/$doc"
  done
}

case_unique_identifiers() {
  local work
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  for corpus in en ko; do
    jq -e '([.[].id] | length) == ([.[].id] | unique | length)' "$work/$corpus.json" >/dev/null ||
      fail "$corpus identifiers are not unique"
  done
}

case_language_declared() {
  local work
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  jq -e 'all(.[]; .language == "en")' "$work/en.json" >/dev/null || fail "en file does not declare en"
  jq -e 'all(.[]; .language == "ko")' "$work/ko.json" >/dev/null || fail "ko file does not declare ko"
}

case_same_axes_in_order() {
  local work
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  assert_eq "$(jq -c '[.[].id | sub("-en$"; "")]' "$work/en.json")" \
    "$(jq -c '[.[].id | sub("-ko$"; "")]' "$work/ko.json")" "case order"
}

case_plan_axes_covered() {
  local work axis prefix ids
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  for entry in "${REQUIRED_AXES[@]}"; do
    axis=${entry%%|*}
    prefix=${entry#*|}
    for corpus in en ko; do
      ids=$(jq -r '.[].id' "$work/$corpus.json")
      if ! printf '%s\n' "$ids" | grep -q "^${prefix}"; then
        fail "$axis: $corpus has no case starting with $prefix"
      fi
    done
  done
}

case_required_metrics_present() {
  local work metrics metric
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  metrics=$(jq -r '[.[] | .metrics[]] | unique | .[]' "$work/en.json" "$work/ko.json" | tr '\n' ' ')
  for metric in $REQUIRED_METRICS; do
    assert_contains " $metrics " " $metric " "metric $metric"
  done
}

case_trigger_and_non_trigger() {
  local work
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  for corpus in en ko; do
    jq -e 'any(.[]; .shouldTrigger == true)' "$work/$corpus.json" >/dev/null || fail "$corpus has no triggering case"
    jq -e 'any(.[]; .shouldTrigger == false)' "$work/$corpus.json" >/dev/null || fail "$corpus has no non-triggering case"
  done
}

case_overclaim_guards() {
  local work guarantees conditional
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  guarantees=$(jq '[.[] | select(.id | startswith("seo-guarantee-language"))]' "$work/en.json" "$work/ko.json" | jq -s -c 'add')
  assert_eq "2" "$(printf '%s' "$guarantees" | jq 'length')" "guarantee case count"
  printf '%s' "$guarantees" | jq -e 'all(.[]; .shouldTrigger == true and (.expected.mustNot | length) >= 2)' >/dev/null ||
    fail "a guarantee case does not forbid the overclaim"
  conditional=$(jq '[.[] | select(.id | startswith("seo-platform-conditional"))]' "$work/en.json" "$work/ko.json" | jq -s -c 'add')
  assert_eq "2" "$(printf '%s' "$conditional" | jq 'length')" "conditional case count"
  printf '%s' "$conditional" | jq -e 'all(.[]; (.metrics | index("target-conditionality")) != null)' >/dev/null ||
    fail "a conditional case lost its target-conditionality metric"
}

case_verdict_distribution() {
  local work en_verdicts ko_verdicts
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  en_verdicts=$(jq -Sc '[.[] | .probe.expected]' "$work/en.json")
  ko_verdicts=$(jq -Sc '[.[] | .probe.expected]' "$work/ko.json")
  assert_eq "$en_verdicts" "$ko_verdicts" "positional verdicts"
  assert_eq "$(printf '%s' "$en_verdicts" | jq -Sc 'sort')" "$(printf '%s' "$ko_verdicts" | jq -Sc 'sort')" "verdict multiset"
}

case_no_seam_set() {
  local work none_ids
  work=$(new_workdir)
  load_corpus "$CORPUS_DIR" "$EN_NAME" "$work/en.json"
  load_corpus "$CORPUS_DIR" "$KO_NAME" "$work/ko.json"
  for corpus in en ko; do
    none_ids=$(jq -r '[.[] | select(.probe.kind == "none") | .id | sub("-[a-z][a-z]$"; "")] | sort | join(" ")' "$work/$corpus.json")
    assert_eq "$(printf '%s\n' "${NO_SEAM_IDS[@]}" | sort | tr '\n' ' ' | sed 's/ $//')" "$none_ids" "$corpus seam-free cases"
  done
}

case_machine_checked_cases() {
  local work total evaluated none mismatches
  work=$(new_workdir)
  evaluate_corpus "$CORPUS_DIR" "$work"
  total=$(wc -l <"$work/run.tsv" | tr -d ' ')
  evaluated=$(awk -F '\t' '$2 != "none"' "$work/run.tsv" | wc -l | tr -d ' ')
  none=$(awk -F '\t' '$2 == "none"' "$work/run.tsv" | wc -l | tr -d ' ')
  assert_eq "30" "$total" "case count"
  assert_eq "20" "$evaluated" "machine-checked cases"
  assert_eq "10" "$none" "seam-free cases"
  mismatches=$(awk -F '\t' '$3 == "0" { printf "%s (%s): expected %s actual %s\n", $1, $2, $4, $5 }' "$work/run.tsv")
  assert_empty "$mismatches" "probe mismatches"
}

case_flipped_verdict_detected() {
  local work flipped_id flipped repository
  work=$(new_workdir)
  mkdir -p "$work/corpus"
  cp "$CORPUS_DIR/$EN_NAME" "$work/corpus/$EN_NAME"
  cp "$CORPUS_DIR/$KO_NAME" "$work/corpus/$KO_NAME"
  flipped_id="seo-missing-evidence-grade-en"
  jq -c --arg id "$flipped_id" 'if .id == $id then .probe.expected = "rendered:measured:1" else . end' \
    "$work/corpus/$EN_NAME" >"$work/en.jsonl"
  mv "$work/en.jsonl" "$work/corpus/$EN_NAME"

  evaluate_corpus "$work/corpus" "$work"
  assert_eq "seo-missing-evidence-grade-en" "$(awk -F '\t' '$1 == "'"$flipped_id"'" { print $1 }' "$work/run.tsv")" "case evaluated"
  flipped=$(awk -F '\t' '$1 == "'"$flipped_id"'" && $3 == "0" { print }' "$work/run.tsv")
  assert_nonempty "$flipped" "flipped verdict reported"
  assert_eq "\"rejected:findings[0].evidence_grade\"" "$(printf '%s' "$flipped" | cut -f5)" "actual verdict"
  assert_eq "\"rendered:measured:1\"" "$(printf '%s' "$flipped" | cut -f4)" "flipped expectation"

  repository=$(jq -c --arg id "$flipped_id" 'select(.id == $id) | .probe.expected' "$CORPUS_DIR/$EN_NAME")
  assert_eq '"rejected:findings[0].evidence_grade"' "$repository" "repository corpus untouched"
}

run_case "both language files parse and carry the same number of cases" case_language_files_parse
run_case "every case has the required machine-readable fields" case_required_fields
run_case "every case names a probe the runner can execute" case_probe_executable
run_case "identifiers are unique inside each file" case_unique_identifiers
run_case "each file declares its own language" case_language_declared
run_case "the English and Korean files cover the same axes in the same order" case_same_axes_in_order
run_case "every axis the plan names has a case in both languages" case_plan_axes_covered
run_case "every required metric appears somewhere in the corpus" case_required_metrics_present
run_case "each language has a case that triggers and a case that must not" case_trigger_and_non_trigger
run_case "the no-guarantee and target-conditional cases forbid the overclaim they guard" case_overclaim_guards
run_case "the two languages carry the same expected-verdict distribution" case_verdict_distribution
run_case "the corpus marks exactly the cases with no machine seam" case_no_seam_set
run_case "every machine-checked case matches an actual value computed from a real system call" case_machine_checked_cases
run_case "flipping one expected verdict in a temp corpus copy is reported as a mismatch" case_flipped_verdict_detected
test_summary
