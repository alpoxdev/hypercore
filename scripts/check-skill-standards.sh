#!/usr/bin/env bash
# Repo-level skill standard gate with a baseline ratchet.
#
# Every directory directly under the skill root is validated by the hyper-skill validator, the
# watched finding codes are counted per skill, and the counts are compared with a frozen baseline.
# A count above its baseline entry is a regression (exit 1); an accepted or pre-existing count is
# debt, reported only, and never changes the exit code.
set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
VALIDATOR_PATH=$REPO_ROOT/skills/hyper-skill/scripts/validate-hyper-skill.sh
DEFAULT_ROOT=skills
DEFAULT_BASELINE=scripts/fixtures/skill-standards/baseline.json
DEFAULT_EXCEPTIONS=scripts/fixtures/skill-standards/exceptions.json

WATCHED_CODES='[
  "CROSS_SKILL_REFERENCE",
  "LINK_MISSING",
  "CODE_FENCE_UNBALANCED",
  "BILINGUAL_MISSING",
  "BILINGUAL_LINK_DRIFT",
  "BILINGUAL_TAG_DRIFT",
  "BILINGUAL_ORPHAN",
  "SCRIPT_RUNTIME_EXTENSION",
  "SCRIPT_RUNTIME_SHEBANG",
  "SCRIPT_RUNTIME_UNREADABLE",
  "STRAY_DOC",
  "FRONTMATTER_NAME",
  "FRONTMATTER_DESCRIPTION",
  "FRONTMATTER_TRIGGER",
  "FRONTMATTER_XML_TAG",
  "CORE_LINE_BUDGET",
  "REFERENCE_TOC_MISSING",
  "OFFICIAL_LAST_VERIFIED_AT",
  "SOURCES_MISSING",
  "SOURCES_CHECKED_DATE_MISSING",
  "SOURCES_CHECKED_DATE_INVALID"
]'

WORK_DIR=

cleanup() {
  if [ -n "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR"
  fi
}
trap cleanup EXIT

config_error() {
  printf 'check-skill-standards: %s\n' "$1" >&2
  exit 2
}

unexpected_error() {
  printf 'check-skill-standards: unexpected failure: %s\n' "$1" >&2
  exit 2
}

ensure_workdir() {
  if [ -z "$WORK_DIR" ]; then
    WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/hypercore-skill-standards.XXXXXX") || unexpected_error "cannot create a temporary directory"
  fi
}

# path.resolve(repoRoot, path): absolute paths stay absolute, relative ones join the repository root.
resolve_path() {
  local path=$1 rest segment out=
  if [ -z "$path" ]; then
    printf '%s\n' "$REPO_ROOT"
    return 0
  fi
  case $path in
    /*) ;;
    *) path=$REPO_ROOT/$path ;;
  esac
  rest=$path
  while [ -n "$rest" ]; do
    segment=${rest%%/*}
    if [ "$segment" = "$rest" ]; then
      rest=
    else
      rest=${rest#*/}
    fi
    case $segment in
      '' | .) ;;
      ..) out=${out%/*} ;;
      *) out=$out/$segment ;;
    esac
  done
  if [ -z "$out" ]; then
    out=/
  fi
  printf '%s\n' "$out"
}

# Skill roots are directories only: files, symlinks, and dotfiles such as .DS_Store are skipped.
list_skills() {
  local root=$1 entry
  for entry in "$root"/*; do
    if [ -L "$entry" ]; then continue; fi
    if [ ! -d "$entry" ]; then continue; fi
    printf '%s\n' "${entry##*/}"
  done | sort
}

# Prints the normalized first cells of the contract table, as tableLabels/contractLabels do in the
# original tool. Exits 1 when the skill carries no contract block at all.
contract_labels() {
 LC_ALL=C awk '
    { line = $0; sub(/\r$/, "", line); rows[++count] = line }
    function trim(s) {
      sub(/^[ \t\r]+/, "", s)
      sub(/[ \t\r]+$/, "", s)
      return s
    }
    function normalize(s) {
      s = trim(s)
      s = tolower(s)
      gsub(/[ \t\r]+/, " ", s)
      sub(/[.:;,]+$/, "", s)
      return s
    }
    function emit(text,   lines, line_count, i, cells, cell_count, first) {
      line_count = split(text, lines, "\n")
      for (i = 1; i <= line_count; i++) {
        cell_count = split(lines[i], cells, "[|]")
        if (cell_count < 4) continue
        first = trim(cells[2])
        if (first == "") continue
        if (first ~ /^-+$/) continue
        print normalize(first)
      }
    }
    END {
      opened = 0
      for (i = 1; i <= count; i++) {
        position = index(rows[i], "<instruction_contract>")
        if (position > 0) {
          opened = i
          remainder = substr(rows[i], position + length("<instruction_contract>"))
          break
        }
      }
      if (opened > 0) {
        closing = index(remainder, "</instruction_contract>")
        if (closing > 0) {
          emit(substr(remainder, 1, closing - 1))
          exit 0
        }
        text = remainder "\n"
        found_close = 0
        for (j = opened + 1; j <= count; j++) {
          closing = index(rows[j], "</instruction_contract>")
          if (closing > 0) {
            text = text substr(rows[j], 1, closing - 1)
            found_close = 1
            break
          }
          text = text rows[j] "\n"
        }
        if (found_close) {
          emit(text)
          exit 0
        }
      }
      heading = 0
      for (i = 1; i <= count; i++) {
        if (rows[i] ~ /^##[ \t]+Contract[ \t]*$/) { heading = i; break }
      }
      if (heading == 0) exit 1
      text = ""
      for (j = heading + 1; j <= count; j++) {
        line = rows[j]
        if (line ~ /^[ \t\r]*$/) continue
        trimmed = line
        sub(/^[ \t\r]+/, "", trimmed)
        if (substr(trimmed, 1, 1) != "|") break
        text = text line "\n"
      }
      emit(text)
    }
  ' "$1"
}

# Number of the nine canonical contract labels missing from the skill's own contract block.
count_missing_contract_labels() {
  local skill_dir=$1 skill_md labels_file missing=0 label
  skill_md=$skill_dir/SKILL.md
  if [ ! -e "$skill_md" ]; then
    printf '9\n'
    return 0
  fi
  labels_file=$WORK_DIR/contract-labels
  if ! contract_labels "$skill_md" > "$labels_file"; then
    printf '9\n'
    return 0
  fi
  for label in intent scope authority evidence tools loop output verification "stop condition"; do
    if ! grep -Fxq -- "$label" "$labels_file"; then
      missing=$((missing + 1))
    fi
  done
  printf '%s\n' "$missing"
}

# Sets SKILL_COUNTS to the watched finding counts, plus the two gate-owned checks, for one skill.
collect_skill_counts() {
  local skill_dir=$1 stdout status detail parsed evals_dir entry eval_missing missing_labels counts error_file
  error_file=$WORK_DIR/validator-stderr
  stdout=$(cd "$REPO_ROOT" && bash "$VALIDATOR_PATH" --root "$skill_dir" --require-self-containment --json 2>"$error_file")
  status=$?
  if [ "$status" -ne 0 ] && [ "$status" -ne 1 ]; then
    detail=$(head -n 1 "$error_file" 2>/dev/null)
    if [ -z "$detail" ]; then
      detail="spawn failure"
    fi
    config_error "Validator failed for $skill_dir (exit $status): $detail"
  fi
  parsed=$(printf '%s' "$stdout" | jq -c . 2>/dev/null)
  if [ -z "$parsed" ]; then
    config_error "Validator output for $skill_dir is not JSON"
  fi
  if ! printf '%s' "$parsed" | jq -e 'type == "object" and (.errors | type) == "array" and (.warnings | type) == "array"' >/dev/null 2>&1; then
    config_error "Validator output for $skill_dir has no errors/warnings arrays"
  fi

  evals_dir=$skill_dir/assets/evals
  eval_missing=1
  if [ -d "$evals_dir" ]; then
    for entry in "$evals_dir"/*.jsonl "$evals_dir"/.*.jsonl; do
      if [ -L "$entry" ]; then continue; fi
      if [ -f "$entry" ]; then
        eval_missing=0
        break
      fi
    done
  fi
  missing_labels=$(count_missing_contract_labels "$skill_dir")

  counts=$(printf '%s' "$stdout" | jq -c --argjson watched "$WATCHED_CODES" --argjson eval_missing "$eval_missing" --argjson contract_missing "$missing_labels" '
    reduce (
      ([.errors[] | .code | strings] + [.warnings[] | .code | strings])[]
      | . as $code
      | select($watched | index($code))
    ) as $code ({}; .[$code] = ((.[$code] // 0) + 1))
    | if $eval_missing > 0 then .EVAL_FIXTURE_MISSING = ((.EVAL_FIXTURE_MISSING // 0) + $eval_missing) else . end
    | if $contract_missing > 0 then .CONTRACT_FIELDS_MISSING = ((.CONTRACT_FIELDS_MISSING // 0) + $contract_missing) else . end
  ')
  SKILL_COUNTS=$counts
}

# Sets EXCEPTIONS_JSON after validating the exceptions file.
load_exceptions() {
  local path=$1 problem kind first second
  if [ ! -e "$path" ]; then
    config_error "Exceptions file is missing: $path"
  fi
  if ! jq . "$path" >/dev/null 2>&1; then
    config_error "Exceptions file is not valid JSON: $path"
  fi
  problem=$(jq -r '
    if ((type == "object") | not) then
      "SHAPE"
    else
      (to_entries[] |
         .key as $key |
         .value as $value |
         if (($key | index("|")) == null) then
           "KEY\t" + $key
         elif ((($value | type) != "string") or (((($value | gsub("^[ \t\r\n]+|[ \t\r\n]+$"; "")) | length) == 0))) then
           "REASON\t" + $key
         else
           empty
         end)
    end
  ' "$path" | head -n 1)
  if [ -n "$problem" ]; then
    IFS=$'\t' read -r kind first second <<<"$problem"
    case $kind in
      SHAPE) config_error "Exceptions file must be {\"<name>|<CODE>\": \"<reason>\"}: $path" ;;
      KEY) config_error "Exception key must be \"<name>|<CODE>\": $first" ;;
      REASON) config_error "Exception entry needs a reason: $first" ;;
    esac
  fi
  EXCEPTIONS_JSON=$(jq -c . "$path")
}

# Sets BASELINE_SKILLS after validating the baseline file.
load_baseline() {
  local path=$1 problem kind first second
  if [ ! -e "$path" ]; then
    config_error "Baseline is missing: $path (run --update-baseline to create it)"
  fi
  if ! jq . "$path" >/dev/null 2>&1; then
    config_error "Baseline is not valid JSON: $path"
  fi
  problem=$(jq -r '
    if (((type == "object") and ((.skills | type) == "object")) | not) then
      "SHAPE"
    else
      (.skills | to_entries[] |
         .key as $name |
         .value as $entry |
         if (($entry | type) != "object") then
           "ENTRY\t" + $name
         else
           ($entry | to_entries[] |
              select(((.value | type) != "number") or (.value < 0) or (.value != (.value | floor)))
              | "COUNT\t" + $name + "\t" + .key)
         end)
    end
  ' "$path" | head -n 1)
  if [ -n "$problem" ]; then
    IFS=$'\t' read -r kind first second <<<"$problem"
    case $kind in
      SHAPE) config_error "Baseline must be {\"skills\": {\"<name>\": {\"<CODE>\": <count>}}}: $path" ;;
      ENTRY) config_error "Baseline entry for $first must be an object of code counts: $path" ;;
      COUNT) config_error "Baseline count for $first|$second must be a non-negative integer: $path" ;;
    esac
  fi
  BASELINE_SKILLS=$(jq -c '.skills' "$path")
}

write_baseline() {
  local path=$1 payload=$2 directory temporary
  directory=$(dirname "$path")
  if ! mkdir -p "$directory"; then
    unexpected_error "cannot create $directory"
  fi
  temporary=$path.tmp-$$
  if ! printf '%s' "$payload" | jq . > "$temporary"; then
    rm -f "$temporary"
    unexpected_error "cannot write $path"
  fi
  if ! mv -f "$temporary" "$path"; then
    rm -f "$temporary"
    unexpected_error "cannot replace $path"
  fi
}

print_help() {
  printf '%s\n' "Usage: scripts/check-skill-standards.sh [options]

Runs the hyper-skill validator over every skill directory under the root, counts the watched
finding codes per skill, and compares them with the frozen baseline.

  --root <dir>        skill root (default $DEFAULT_ROOT, resolved from the repository root)
  --baseline <path>   baseline file (default $DEFAULT_BASELINE)
  --exceptions <path> permanent exception file (default $DEFAULT_EXCEPTIONS)
  --skill <name>      restrict the report to one skill directory
  --json              print the machine-readable report
  --update-baseline   rewrite the baseline from the current counts (never writes exceptions)
  -h, --help          print this help

Exit codes: 0 no regressions, 1 one or more regressions, 2 configuration or integrity error.
Counts above 0 that are not exceptions are reported as debt and never change the exit code."
}

parse_args() {
  ARG_ROOT=$DEFAULT_ROOT
  ARG_BASELINE=$DEFAULT_BASELINE
  ARG_EXCEPTIONS=$DEFAULT_EXCEPTIONS
  ARG_SKILL=
  HAS_SKILL=0
  ARG_JSON=0
  ARG_UPDATE=0
  ARG_HELP=0
  while [ $# -gt 0 ]; do
    case $1 in
      --root)
        if [ $# -lt 2 ] || [ "${2#--}" != "$2" ]; then
          config_error "Missing value for --root"
        fi
        ARG_ROOT=$2
        shift 2
        ;;
      --baseline)
        if [ $# -lt 2 ] || [ "${2#--}" != "$2" ]; then
          config_error "Missing value for --baseline"
        fi
        ARG_BASELINE=$2
        shift 2
        ;;
      --exceptions)
        if [ $# -lt 2 ] || [ "${2#--}" != "$2" ]; then
          config_error "Missing value for --exceptions"
        fi
        ARG_EXCEPTIONS=$2
        shift 2
        ;;
      --skill)
        if [ $# -lt 2 ] || [ "${2#--}" != "$2" ]; then
          config_error "Missing value for --skill"
        fi
        ARG_SKILL=$2
        HAS_SKILL=1
        shift 2
        ;;
      --json)
        ARG_JSON=1
        shift
        ;;
      --update-baseline)
        ARG_UPDATE=1
        shift
        ;;
      --help | -h)
        ARG_HELP=1
        shift
        ;;
      *)
        config_error "Unknown argument: $1"
        ;;
    esac
  done
}

main() {
  local root all_skills scope scanned name current reference skills_json entries_file
  local regressions_json debt_json exceptions_json report_baseline report_json
  local scanned_count regression_count debt_count exception_count

  parse_args "$@"
  if [ "$ARG_HELP" -eq 1 ]; then
    print_help
    return 0
  fi

  root=$(resolve_path "$ARG_ROOT")
  if [ ! -d "$root" ]; then
    config_error "Skill root is missing: $ARG_ROOT"
  fi
  all_skills=$(list_skills "$root")

  scope=$all_skills
  if [ "$HAS_SKILL" -eq 1 ]; then
    scope=
    for name in $all_skills; do
      if [ "$name" = "$ARG_SKILL" ]; then
        scope=$name
      fi
    done
    if [ -z "$scope" ]; then
      config_error "Unknown skill: $ARG_SKILL"
    fi
  fi

  BASELINE_PATH=$(resolve_path "$ARG_BASELINE")
  EXCEPTIONS_PATH=$(resolve_path "$ARG_EXCEPTIONS")
  ensure_workdir
  load_exceptions "$EXCEPTIONS_PATH"

  if [ "$ARG_UPDATE" -eq 1 ]; then
    scanned=$all_skills
  else
    scanned=$scope
  fi

  skills_json='{}'
  scanned_count=0
  for name in $scanned; do
    collect_skill_counts "$root/$name"
    skills_json=$(printf '%s' "$skills_json" | jq -c --arg name "$name" --argjson counts "$SKILL_COUNTS" '. + {($name): $counts}')
    scanned_count=$((scanned_count + 1))
  done

  if [ "$ARG_UPDATE" -eq 1 ]; then
    BASELINE_SKILLS=$skills_json
    write_baseline "$BASELINE_PATH" "{\"skills\":$skills_json}"
  else
    load_baseline "$BASELINE_PATH"
    for name in $scanned; do
      if ! printf '%s' "$BASELINE_SKILLS" | jq -e --arg name "$name" 'has($name)' >/dev/null 2>&1; then
        config_error "Baseline has no entry for skill: $name (run --update-baseline)"
      fi
    done
  fi

  entries_file=$WORK_DIR/entries.ndjson
  : > "$entries_file"
  for name in $scanned; do
    current=$(printf '%s' "$skills_json" | jq -c --arg name "$name" '.[$name]')
    reference=$(printf '%s' "$BASELINE_SKILLS" | jq -c --arg name "$name" '.[$name] // {}')
    printf '%s\n%s\n' "$current" "$reference" | jq -s -c --arg name "$name" --argjson exceptions "$EXCEPTIONS_JSON" '
      .[0] as $current | .[1] as $reference |
      $current | to_entries[] |
      . as $entry |
      {
        skill: $name,
        code: $entry.key,
        count: $entry.value,
        baseline: ($reference[$entry.key] // 0),
        exception: (if ($exceptions | has($name + "|" + $entry.key)) then $exceptions[$name + "|" + $entry.key] else null end)
      }
    ' >> "$entries_file"
  done

  regressions_json=$(jq -s '[.[] | select(.count > .baseline) | {skill: .skill, code: .code, baseline: .baseline, count: .count}]' "$entries_file")
  debt_json=$(jq -s '[.[] | select(.exception == null) | {skill: .skill, code: .code, count: .count}]' "$entries_file")
  exceptions_json=$(jq -s 'reduce (.[] | select(.exception != null)) as $entry ({}; .[$entry.skill + "|" + $entry.code] = $entry.exception)' "$entries_file")
  report_baseline=$(printf '%s' "$skills_json" | jq -c --argjson reference "$BASELINE_SKILLS" 'reduce (to_entries[] | .key) as $name ({}; .[$name] = ($reference[$name] // {}))')

  regression_count=$(printf '%s' "$regressions_json" | jq 'length')
  debt_count=$(printf '%s' "$debt_json" | jq 'length')
  exception_count=$(printf '%s' "$exceptions_json" | jq 'length')

  report_json=$(jq -n \
    --argjson counts "$skills_json" \
    --argjson baseline "$report_baseline" \
    --argjson regressions "$regressions_json" \
    --argjson debt "$debt_json" \
    --argjson exceptions "$exceptions_json" \
    '{counts: $counts, baseline: $baseline, regressions: ($regressions | length), debt: ($debt | length), exceptions: $exceptions}')

  if [ "$ARG_JSON" -eq 1 ]; then
    printf '%s\n' "$report_json" | jq .
  else
    printf 'skill standard gate: %s skill(s), %s regression(s), %s debt item(s), %s exception(s)\n' \
      "$scanned_count" "$regression_count" "$debt_count" "$exception_count"
    if [ "$ARG_UPDATE" -eq 1 ]; then
      printf 'baseline written: %s\n' "$BASELINE_PATH"
    fi
    printf '%s' "$regressions_json" | jq -r '.[] | "REGRESSION \(.skill)|\(.code) count \(.count) > baseline \(.baseline)"'
    printf '%s' "$debt_json" | jq -r '.[] | "DEBT \(.skill)|\(.code) count \(.count)"'
  fi

  if [ "$regression_count" -gt 0 ]; then
    return 1
  fi
  return 0
}

main "$@"
