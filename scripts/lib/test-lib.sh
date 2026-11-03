#!/usr/bin/env bash
# test-lib.sh — shared assertions, workdirs, and case runner for the bash test suite.
#
# Usage:
#   source "$(dirname "$0")/../lib/test-lib.sh"
#   test_init
#   run_case "case name" case_function
#   test_summary
#
# A test file defines one shell function per case, calls run_case for each, and
# ends with test_summary. Inside a case, the assertion helpers below return
# non-zero on failure; run_case runs each case in a subshell with `set -e`, so
# the first failed assertion fails that case and the remaining cases still run.
# Exit code 77 from a case means skip; `skip "reason"` produces it.
#
# Output is plain ASCII without color: one PASS/FAIL/SKIP line per case
# followed by "<N> pass, <M> fail, <K> skip". test_summary exits 1 when any
# case failed. Requires bash 3.2+ and POSIX tools; JSON helpers use jq.
#
# Under scripts/run-tests.sh, HYPERCORE_TEST_LIB is this file's absolute path
# (use `source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"`),
# HYPERCORE_SCRIPTS_DIR is scripts/, and HYPERCORE_ROOT is the repository root.

# Counters and state. Usable before test_init for assertion-only scripts, but
# new_workdir, skip, and the summary need test_init.
TL_PASS=${TL_PASS:-0}
TL_FAIL=${TL_FAIL:-0}
TL_SKIP=${TL_SKIP:-0}
TL_SUMMARY_PRINTED=${TL_SUMMARY_PRINTED:-0}
TL_STATE_DIR=${TL_STATE_DIR:-}
TL_SKIP_REASON_FILE=${TL_SKIP_REASON_FILE:-}

# test_init [result-file] — reset counters, create the state/workdir tracker,
# and install cleanup traps. The optional result file (or the
# HYPERCORE_TEST_RESULT_FILE environment variable) receives pass/fail/skip= lines.
test_init() {
  TL_PASS=0
  TL_FAIL=0
  TL_SKIP=0
  TL_SUMMARY_PRINTED=0
  if [ "$#" -gt 0 ] && [ -n "$1" ]; then
    HYPERCORE_TEST_RESULT_FILE=$1
  fi
  TL_STATE_DIR=$(mktemp -d "${TMPDIR:-/tmp}/hypercore-test-state.XXXXXX")
  TL_SKIP_REASON_FILE=$TL_STATE_DIR/skip-reason
  : >"$TL_STATE_DIR/workdirs"
  trap __tl_on_exit EXIT
  trap '__tl_signal 130' INT
  trap '__tl_signal 143' TERM
}

# describe <text> — print a group header line between case groups.
describe() {
  if [ "$#" -eq 0 ]; then
    printf '#\n'
    return 0
  fi
  printf '# %s\n' "$*"
}

# fail <message> — record a case failure and return 1.
fail() {
  __tl_fail "$*"
}

# skip [reason] — mark the current case skipped (exit 77 handled by run_case).
skip() {
  if [ -z "${TL_STATE_DIR:-}" ] || [ -z "${TL_SKIP_REASON_FILE:-}" ]; then
    printf 'SKIP-REASON: %s\n' "${1:-}" >&2
  else
    printf '%s' "${1:-}" >"$TL_SKIP_REASON_FILE"
  fi
  exit 77
}

# skip_case <name> [reason] — record a skip without entering a case function.
skip_case() {
  local name=$1
  local reason=${2:-}
  TL_SKIP=$((TL_SKIP + 1))
  if [ -n "$reason" ]; then
    printf 'SKIP %s (%s)\n' "$name" "$reason"
  else
    printf 'SKIP %s\n' "$name"
  fi
}

# skip_all [reason] — skip the whole file (one skip) and exit 0.
skip_all() {
  local reason=${1:-}
  TL_SKIP=$((TL_SKIP + 1))
  if [ -n "$reason" ]; then
    printf 'SKIP all cases (%s)\n' "$reason"
  else
    printf 'SKIP all cases\n'
  fi
  test_summary
}

# require_cmd <command> — skip the current case when a command is unavailable.
require_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    return 0
  fi
  skip "missing required command: $1"
}

# new_workdir — create and print a temporary directory, removed by the EXIT trap.
new_workdir() {
  if [ -z "${TL_STATE_DIR:-}" ]; then
    printf 'new_workdir: call test_init first\n' >&2
    return 1
  fi
  local dir
  dir=$(mktemp -d "${TMPDIR:-/tmp}/hypercore-test.XXXXXX") || return 1
  printf '%s\n' "$dir" >>"$TL_STATE_DIR/workdirs"
  printf '%s\n' "$dir"
}

# run_case <name> <function> — run one test function in an isolated subshell.
run_case() {
  if [ "$#" -lt 2 ]; then
    printf 'run_case: usage: run_case <name> <function>\n' >&2
    return 2
  fi
  if [ -z "${TL_STATE_DIR:-}" ]; then
    printf 'run_case: call test_init first\n' >&2
    return 2
  fi
  local name=$1
  local fn=$2
  local rc=0
  local had_errexit=0
  rm -f "$TL_SKIP_REASON_FILE"
  # A subshell on the left of || or inside an if condition runs with errexit
  # ignored, so `set -e` would not stop a case after its first failed
  # assertion. Disable the caller's errexit just for the call, run the case as
  # a bare command, then restore. The case's own `set -e` is then effective.
  case $- in
    *e*) had_errexit=1 ;;
  esac
  set +e
  (trap - EXIT INT TERM; set -e; "$fn")
  rc=$?
  if [ "$had_errexit" -eq 1 ]; then
    set -e
  fi
  case $rc in
    0)
      TL_PASS=$((TL_PASS + 1))
      printf 'PASS %s\n' "$name"
      ;;
    77)
      TL_SKIP=$((TL_SKIP + 1))
      local reason=''
      if [ -f "$TL_SKIP_REASON_FILE" ]; then
        reason=$(cat "$TL_SKIP_REASON_FILE")
      fi
      if [ -n "$reason" ]; then
        printf 'SKIP %s (%s)\n' "$name" "$reason"
      else
        printf 'SKIP %s\n' "$name"
      fi
      ;;
    *)
      TL_FAIL=$((TL_FAIL + 1))
      printf 'FAIL %s\n' "$name"
      ;;
  esac
  return 0
}

# test_summary — print the summary line, write the result file, and exit.
test_summary() {
  __tl_print_summary
  if [ "$TL_FAIL" -gt 0 ]; then
    exit 1
  fi
  exit 0
}

# ---- assertions -----------------------------------------------------------

# assert_eq <expected> <actual> [label]
assert_eq() {
  local expected=$1
  local actual=$2
  local label=${3:-}
  if [ "$expected" = "$actual" ]; then
    return 0
  fi
  __tl_fail "${label:+$label: }expected [$expected], got [$actual]"
}

# assert_ne <unexpected> <actual> [label]
assert_ne() {
  local unexpected=$1
  local actual=$2
  local label=${3:-}
  if [ "$unexpected" != "$actual" ]; then
    return 0
  fi
  __tl_fail "${label:+$label: }did not expect [$actual]"
}

# assert_contains <haystack> <needle> [label]
assert_contains() {
  local haystack=$1
  local needle=$2
  local label=${3:-}
  case $haystack in
    *"$needle"*) return 0 ;;
  esac
  __tl_fail "${label:+$label: }missing [$needle] in [$haystack]"
}

# assert_not_contains <haystack> <needle> [label]
assert_not_contains() {
  local haystack=$1
  local needle=$2
  local label=${3:-}
  case $haystack in
    *"$needle"*) __tl_fail "${label:+$label: }unexpected [$needle] in [$haystack]" ;;
  esac
  return 0
}

# assert_match <extended-regex> <text> [label]
assert_match() {
  local regex=$1
  local text=$2
  local label=${3:-}
  if [[ $text =~ $regex ]]; then
    return 0
  fi
  __tl_fail "${label:+$label: }[$text] does not match /$regex/"
}

# assert_file <path> [label]
assert_file() {
  local path=$1
  local label=${2:-}
  if [ -f "$path" ]; then
    return 0
  fi
  __tl_fail "${label:+$label: }missing file: $path"
}

# assert_not_file <path> [label]
assert_not_file() {
  local path=$1
  local label=${2:-}
  if [ ! -e "$path" ]; then
    return 0
  fi
  __tl_fail "${label:+$label: }unexpected file: $path"
}

# assert_dir <path> [label]
assert_dir() {
  local path=$1
  local label=${2:-}
  if [ -d "$path" ]; then
    return 0
  fi
  __tl_fail "${label:+$label: }missing directory: $path"
}

# assert_executable <path> [label]
assert_executable() {
  local path=$1
  local label=${2:-}
  if [ -x "$path" ]; then
    return 0
  fi
  __tl_fail "${label:+$label: }not executable: $path"
}

# assert_empty <text> [label]
assert_empty() {
  local text=$1
  local label=${2:-}
  if [ -z "$text" ]; then
    return 0
  fi
  __tl_fail "${label:+$label: }expected empty, got [$text]"
}

# assert_nonempty <text> [label]
assert_nonempty() {
  local text=$1
  local label=${2:-}
  if [ -n "$text" ]; then
    return 0
  fi
  __tl_fail "${label:+$label: }expected non-empty value"
}

# assert_exit <expected-code> <command> [args...]
assert_exit() {
  if [ "$#" -lt 2 ]; then
    __tl_fail "assert_exit: usage: assert_exit <code> <command> [args...]"
    return 1
  fi
  local expected=$1
  shift
  local rc=0
  if "$@"; then
    rc=0
  else
    rc=$?
  fi
  if [ "$rc" -eq "$expected" ]; then
    return 0
  fi
  __tl_fail "expected exit $expected, got $rc: $*"
}

# assert_success <command> [args...]
assert_success() {
  assert_exit 0 "$@"
}

# assert_failure <command> [args...]
assert_failure() {
  if [ "$#" -lt 1 ]; then
    __tl_fail "assert_failure: missing command"
    return 1
  fi
  local rc=0
  if "$@"; then
    rc=0
  else
    rc=$?
  fi
  if [ "$rc" -ne 0 ]; then
    return 0
  fi
  __tl_fail "expected failure, command succeeded: $*"
}

# assert_file_contains <path> <needle> [label]
assert_file_contains() {
  local path=$1
  local needle=$2
  local label=${3:-}
  if [ ! -f "$path" ]; then
    __tl_fail "${label:+$label: }missing file: $path"
    return 1
  fi
  assert_contains "$(cat "$path")" "$needle" "${label:-$path}"
}

# ---- JSON (jq) ------------------------------------------------------------

# json_get <file> <filter> — print the filter result (raw strings).
json_get() {
  jq -er "$2" "$1"
}

# assert_json_valid <file> [label]
assert_json_valid() {
  local file=$1
  local label=${2:-}
  require_cmd jq
  if jq -e . "$file" >/dev/null 2>&1; then
    return 0
  fi
  __tl_fail "${label:+$label: }invalid JSON: $file"
}

# assert_json_eq <file> <filter> <expected> [label]
assert_json_eq() {
  local file=$1
  local filter=$2
  local expected=$3
  local label=${4:-}
  require_cmd jq
  local actual
  # `jq -e` exits 1 when the result is false or null, which would make a
  # legitimate `false`/`null` comparison look like a parse error. Use plain
  # `-r` and treat only jq's own error exit (2+) as a failure.
  if ! actual=$(jq -r "$filter" "$file" 2>/dev/null); then
    __tl_fail "${label:+$label: }filter failed: $filter in $file"
    return 1
  fi
  assert_eq "$expected" "$actual" "${label:-json $filter}"
}

# assert_jq <file> <filter> [label] — pass when the filter output is truthy.
assert_jq() {
  local file=$1
  local filter=$2
  local label=${3:-}
  require_cmd jq
  if jq -e "$filter" "$file" >/dev/null 2>&1; then
    return 0
  fi
  __tl_fail "${label:+$label: }filter not truthy: $filter in $file"
}

# ---- internals ------------------------------------------------------------

__tl_fail() {
  printf '  %s\n' "$*"
  return 1
}

__tl_print_summary() {
  printf '%d pass, %d fail, %d skip\n' "$TL_PASS" "$TL_FAIL" "$TL_SKIP"
  if [ -n "${HYPERCORE_TEST_RESULT_FILE:-}" ]; then
    {
      printf 'pass=%d\n' "$TL_PASS"
      printf 'fail=%d\n' "$TL_FAIL"
      printf 'skip=%d\n' "$TL_SKIP"
    } >"$HYPERCORE_TEST_RESULT_FILE"
  fi
  TL_SUMMARY_PRINTED=1
}

__tl_cleanup() {
  if [ -z "${TL_STATE_DIR:-}" ] || [ ! -d "$TL_STATE_DIR" ]; then
    return 0
  fi
  if [ -f "$TL_STATE_DIR/workdirs" ]; then
    while IFS= read -r dir; do
      if [ -n "$dir" ]; then
        rm -rf -- "$dir"
      fi
    done <"$TL_STATE_DIR/workdirs"
  fi
  rm -rf -- "$TL_STATE_DIR"
  TL_STATE_DIR=''
}

__tl_on_exit() {
  local rc=$?
  trap - EXIT INT TERM
  __tl_cleanup
  if [ "${TL_SUMMARY_PRINTED:-0}" -eq 0 ]; then
    __tl_print_summary
    if [ "$TL_FAIL" -gt 0 ] && [ "$rc" -eq 0 ]; then
      rc=1
    fi
  fi
  exit "$rc"
}

__tl_signal() {
  exit "$1"
}
