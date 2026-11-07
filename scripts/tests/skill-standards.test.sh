#!/usr/bin/env bash
# Bash port of scripts/tests/skill-standards.test.mjs.
#
# Exercises scripts/check-skill-standards.sh: baseline ratchet, integrity
# checks, exception handling, scope, and default path resolution. Every case
# keeps the original bun test title, as the lib mapping table requires.
# Requires bash 3.2+, POSIX tools, and jq.
set -uo pipefail

# shellcheck source=/dev/null
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
SCRIPTS=${HYPERCORE_SCRIPTS_DIR:-$ROOT/scripts}
GATE=$SCRIPTS/check-skill-standards.sh

if ! command -v jq >/dev/null 2>&1; then
  skip_all "missing required command: jq"
fi

WORKSPACE=
SKILLS_DIR=
BASELINE_PATH=
EXCEPTIONS_PATH=
SKILL_DIR=
GATE_STATUS=0

# make_workspace — temp root with skills/, an empty exceptions file, and no baseline.
make_workspace() {
  WORKSPACE=$(new_workdir)
  SKILLS_DIR=$WORKSPACE/skills
  BASELINE_PATH=$WORKSPACE/baseline.json
  EXCEPTIONS_PATH=$WORKSPACE/exceptions.json
  mkdir -p "$SKILLS_DIR"
  printf '{}\n' >"$EXCEPTIONS_PATH"
}

# write_skill <skills-dir> <name> [body] — write a minimal skill and set SKILL_DIR.
write_skill() {
  local skills_dir=$1
  local name=$2
  local body=${3:-'# D'}
  local dir=$skills_dir/$name
  mkdir -p "$dir"
  {
    printf -- '---\n'
    printf 'name: %s\n' "$name"
    printf 'description: "Use this skill when x"\n'
    printf -- '---\n\n'
    printf '%s\n' "$body"
  } >"$dir/SKILL.md"
  SKILL_DIR=$dir
}

# __run_gate_at <cwd> [args...] — run the gate and keep its streams in the workspace.
__run_gate_at() {
  local dir=$1
  shift
  GATE_STATUS=0
  ( cd "$dir" && bash "$GATE" "$@" ) >"$WORKSPACE/stdout" 2>"$WORKSPACE/stderr" || GATE_STATUS=$?
  return 0
}

run_gate() {
  __run_gate_at "$ROOT" "$@"
}

run_gate_ws() {
  run_gate --root "$SKILLS_DIR" --baseline "$BASELINE_PATH" --exceptions "$EXCEPTIONS_PATH" "$@"
}

update_baseline() {
  run_gate_ws --update-baseline
}

gate_stdout() {
  cat "$WORKSPACE/stdout"
}

gate_stderr() {
  cat "$WORKSPACE/stderr"
}

case_creates_baseline() {
  make_workspace
  write_skill "$SKILLS_DIR" demo

  update_baseline
  assert_eq 0 "$GATE_STATUS" "update-baseline exit"
  assert_json_eq "$BASELINE_PATH" '.skills | keys | join(",")' demo "baseline skills"

  run_gate_ws --json
  assert_eq 0 "$GATE_STATUS" "check exit"
  assert_json_eq "$WORKSPACE/stdout" '.regressions' 0 "regressions"
  assert_json_eq "$WORKSPACE/stdout" '.counts | keys | join(",")' demo "counts"
}

case_detects_regression() {
  make_workspace
  write_skill "$SKILLS_DIR" demo
  local skill_dir=$SKILL_DIR

  update_baseline
  assert_eq 0 "$GATE_STATUS" "update-baseline exit"
  printf 'see skills/other/ for help\n' >>"$skill_dir/SKILL.md"

  run_gate_ws --json
  assert_eq 1 "$GATE_STATUS" "regressed exit"
  assert_jq "$WORKSPACE/stdout" '.regressions > 0' "regressions"
  assert_json_eq "$WORKSPACE/stdout" '.counts.demo.CROSS_SKILL_REFERENCE' 1 "cross-skill count"

  run_gate_ws
  assert_eq 1 "$GATE_STATUS" "human report exit"
  assert_contains "$(gate_stdout)" 'REGRESSION demo|CROSS_SKILL_REFERENCE count 1 > baseline 0' "human report"
}

case_reports_debt() {
  make_workspace
  write_skill "$SKILLS_DIR" demo

  update_baseline
  assert_eq 0 "$GATE_STATUS" "update-baseline exit"

  run_gate_ws --json
  assert_eq 0 "$GATE_STATUS" "debt-only exit"
  assert_json_eq "$WORKSPACE/stdout" '.regressions' 0 "regressions"
  assert_jq "$WORKSPACE/stdout" '.debt > 0' "debt"
  assert_json_eq "$WORKSPACE/stdout" '.counts.demo.CONTRACT_FIELDS_MISSING' 9 "contract fields"
  assert_json_eq "$WORKSPACE/stdout" '.counts.demo.EVAL_FIXTURE_MISSING' 1 "eval fixture"
}

case_exception_reason() {
  make_workspace
  write_skill "$SKILLS_DIR" demo

  update_baseline
  assert_eq 0 "$GATE_STATUS" "update-baseline exit"
  run_gate_ws --json
  local baselined_debt
  baselined_debt=$(jq -r '.debt' "$WORKSPACE/stdout")

  printf '{"demo|CONTRACT_FIELDS_MISSING":"Accepted while the contract block is rewritten."}\n' >"$EXCEPTIONS_PATH"
  run_gate_ws --json
  assert_eq 0 "$GATE_STATUS" "exception exit"
  assert_json_eq "$WORKSPACE/stdout" '.debt' "$((baselined_debt - 1))" "debt after exception"
  assert_json_eq "$WORKSPACE/stdout" '.exceptions | keys | join(",")' 'demo|CONTRACT_FIELDS_MISSING' "exceptions"

  printf '{"demo|CONTRACT_FIELDS_MISSING":""}\n' >"$EXCEPTIONS_PATH"
  run_gate_ws --json
  assert_eq 2 "$GATE_STATUS" "reasonless exception exit"
  assert_contains "$(gate_stderr)" "needs a reason" "reasonless exception message"
}

case_baseline_integrity() {
  make_workspace
  write_skill "$SKILLS_DIR" demo

  run_gate_ws --json
  assert_eq 2 "$GATE_STATUS" "missing baseline exit"
  assert_contains "$(gate_stderr)" "Baseline is missing" "missing baseline message"

  printf 'not json\n' >"$BASELINE_PATH"
  run_gate_ws --json
  assert_eq 2 "$GATE_STATUS" "corrupt baseline exit"
  assert_contains "$(gate_stderr)" "not valid JSON" "corrupt baseline message"

  update_baseline
  assert_eq 0 "$GATE_STATUS" "update-baseline exit"
  assert_json_eq "$BASELINE_PATH" '.skills | keys | join(",")' demo "baseline skills"

  printf '{\n  "skills": {}\n}\n' >"$BASELINE_PATH"
  run_gate_ws --json
  assert_eq 2 "$GATE_STATUS" "incomplete baseline exit"
  assert_contains "$(gate_stderr)" "Baseline has no entry for skill: demo" "incomplete baseline message"
}

case_exceptions_readonly() {
  make_workspace
  write_skill "$SKILLS_DIR" demo

  local declared='{
  "demo|CONTRACT_FIELDS_MISSING": "Kept by user decision."
}
'
  printf '%s' "$declared" >"$EXCEPTIONS_PATH"
  cp "$EXCEPTIONS_PATH" "$WORKSPACE/expected-exceptions"

  update_baseline
  assert_eq 0 "$GATE_STATUS" "update-baseline exit"
  assert_exit 0 cmp -s "$WORKSPACE/expected-exceptions" "$EXCEPTIONS_PATH"
}

case_scans_directories_only() {
  make_workspace
  write_skill "$SKILLS_DIR" demo
  write_skill "$SKILLS_DIR" other
  printf '# not a skill\n' >"$SKILLS_DIR/loose.md"
  : >"$SKILLS_DIR/.DS_Store"
  ln -s "$SKILLS_DIR/demo" "$SKILLS_DIR/linked"

  update_baseline
  assert_eq 0 "$GATE_STATUS" "update-baseline exit"
  assert_json_eq "$BASELINE_PATH" '.skills | keys | join(",")' 'demo,other' "baseline skills"

  run_gate_ws --skill demo --json
  assert_eq 0 "$GATE_STATUS" "scoped exit"
  assert_json_eq "$WORKSPACE/stdout" '.counts | keys | join(",")' demo "scoped counts"

  run_gate_ws --skill absent --json
  assert_eq 2 "$GATE_STATUS" "unknown skill exit"
  assert_contains "$(gate_stderr)" "Unknown skill: absent" "unknown skill message"

  run_gate_ws --nope
  assert_eq 2 "$GATE_STATUS" "unknown argument exit"
  assert_contains "$(gate_stderr)" "Unknown argument: --nope" "unknown argument message"
}

case_default_paths_from_repo_root() {
  make_workspace
  write_skill "$SKILLS_DIR" demo
  local elsewhere=$WORKSPACE/elsewhere
  mkdir -p "$elsewhere"

  __run_gate_at "$elsewhere" --json
  if [ "$GATE_STATUS" -ne 0 ] && [ "$GATE_STATUS" -ne 1 ]; then
    fail "default-path run exited $GATE_STATUS: $(gate_stderr)"
  fi
  assert_jq "$WORKSPACE/stdout" '.counts | keys | index("hyper-skill") != null' "repository counts"
  assert_not_file "$WORKSPACE/scripts" "workspace scripts"
  assert_not_file "$BASELINE_PATH" "workspace baseline"
  assert_eq '{}' "$(cat "$EXCEPTIONS_PATH")" "workspace exceptions"
  assert_eq 3 "$(wc -c <"$EXCEPTIONS_PATH" | tr -d ' ')" "workspace exceptions bytes"
}

run_case "creates a baseline and reports zero regressions for a clean tree" case_creates_baseline
run_case "detects a regression above the baseline and exits 1" case_detects_regression
run_case "reports debt without changing the exit code" case_reports_debt
run_case "accepts an exception with a reason and rejects one without" case_exception_reason
run_case "treats a missing, corrupt, or incomplete baseline as a configuration error" case_baseline_integrity
run_case "never writes the exceptions file when updating the baseline" case_exceptions_readonly
run_case "scans directories only and restricts the report with --skill" case_scans_directories_only
run_case "resolves the default paths from the repository root, not the working directory" case_default_paths_from_repo_root

test_summary
