#!/usr/bin/env bash
# run-tests.sh — run every bash test file under scripts/tests.
#
# Usage:
#   scripts/run-tests.sh                 # run all tests/tests/*.test.sh
#   scripts/run-tests.sh standards       # run files whose name contains "standards"
#   scripts/run-tests.sh skill-standards.test.sh hyper-seo-score
#   scripts/run-tests.sh --list          # list the selected files without running
#
# Each test file is executed with bash, prints its own PASS/FAIL/SKIP lines and
# a "<N> pass, <M> fail, <K> skip" summary, and writes its counters to a result
# file the runner passes in HYPERCORE_TEST_RESULT_FILE. A file that exits
# without a summary is counted as one failure. The runner prints totals and
# exits 1 when any case failed. Set HYPERCORE_TESTS_DIR to test the runner
# itself against a different directory.

set -euo pipefail

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
TESTS_DIR=${HYPERCORE_TESTS_DIR:-$SCRIPT_DIR/tests}

# Contracts for test files: source the shared library by absolute path and
# locate the repository root without depending on the caller's directory.
export HYPERCORE_SCRIPTS_DIR=$SCRIPT_DIR
HYPERCORE_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)
export HYPERCORE_ROOT
export HYPERCORE_TEST_LIB=$SCRIPT_DIR/lib/test-lib.sh

usage() {
  printf 'usage: %s [-h|--help] [--list] [name|substring ...]\n' "${0##*/}"
  printf '\n'
  printf 'Runs %s/*.test.sh. Arguments match a file name, a name without\n' "$TESTS_DIR"
  printf 'the .test.sh suffix, or any substring of the file name.\n'
}

LIST_ONLY=0
PATTERNS=()
for arg in "$@"; do
  case $arg in
    -h|--help)
      usage
      exit 0
      ;;
    --list)
      LIST_ONLY=1
      ;;
    -*)
      printf 'run-tests: unknown option: %s\n' "$arg" >&2
      usage >&2
      exit 2
      ;;
    *)
      PATTERNS+=("$arg")
      ;;
  esac
done

if [ ! -d "$TESTS_DIR" ]; then
  printf 'run-tests: test directory not found: %s\n' "$TESTS_DIR" >&2
  exit 2
fi

shopt -s nullglob
ALL_FILES=("$TESTS_DIR"/*.test.sh)
shopt -u nullglob

if [ "${#ALL_FILES[@]}" -eq 0 ]; then
  printf 'run-tests: no *.test.sh files in %s\n' "$TESTS_DIR" >&2
  exit 1
fi

SELECTED=()
if [ "${#PATTERNS[@]}" -eq 0 ]; then
  SELECTED=("${ALL_FILES[@]}")
else
  for file in "${ALL_FILES[@]}"; do
    base=${file##*/}
    for pattern in "${PATTERNS[@]}"; do
      case $base in
        "$pattern" | "$pattern.test.sh")
          SELECTED+=("$file")
          break
          ;;
      esac
      case $base in
        *"$pattern"*)
          SELECTED+=("$file")
          break
          ;;
      esac
    done
  done
fi

if [ "${#SELECTED[@]}" -eq 0 ]; then
  printf 'run-tests: no test file matched:' >&2
  printf ' %s' "${PATTERNS[@]}" >&2
  printf '\n' >&2
  exit 1
fi

if [ "$LIST_ONLY" -eq 1 ]; then
  for file in "${SELECTED[@]}"; do
    printf '%s\n' "$file"
  done
  exit 0
fi

RESULT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/hypercore-run-tests.XXXXXX")
trap 'rm -rf -- "$RESULT_DIR"' EXIT

# Test files run from the repository root so relative paths are stable; use
# HYPERCORE_ROOT or HYPERCORE_SCRIPTS_DIR for explicit absolute paths.
cd "$HYPERCORE_ROOT"

TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_SKIP=0
BROKEN=0
index=0

for file in "${SELECTED[@]}"; do
  index=$((index + 1))
  rel=${file#"$SCRIPT_DIR"/}
  printf '\n== %s\n' "$rel"
  result_file=$RESULT_DIR/result-$index
  : >"$result_file"
  rc=0
  HYPERCORE_TEST_RESULT_FILE=$result_file bash "$file" || rc=$?

  file_pass=0
  file_fail=0
  file_skip=0
  have_summary=0
  if [ -s "$result_file" ]; then
    have_summary=1
    while IFS='=' read -r key value; do
      case $key in
        pass) file_pass=$value ;;
        fail) file_fail=$value ;;
        skip) file_skip=$value ;;
      esac
    done <"$result_file"
  fi

  if [ "$have_summary" -eq 0 ]; then
    printf 'FAIL %s (no summary, exit %d)\n' "$rel" "$rc"
    file_fail=1
    BROKEN=$((BROKEN + 1))
  elif [ "$rc" -ne 0 ] && [ "$file_fail" -eq 0 ]; then
    printf 'FAIL %s (exit %d with no failed case)\n' "$rel" "$rc"
    file_fail=1
    BROKEN=$((BROKEN + 1))
  fi

  TOTAL_PASS=$((TOTAL_PASS + file_pass))
  TOTAL_FAIL=$((TOTAL_FAIL + file_fail))
  TOTAL_SKIP=$((TOTAL_SKIP + file_skip))
done

printf '\nTOTAL: %d pass, %d fail, %d skip\n' "$TOTAL_PASS" "$TOTAL_FAIL" "$TOTAL_SKIP"
printf 'files: %d run, %d broken\n' "${#SELECTED[@]}" "$BROKEN"

if [ "$TOTAL_FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
