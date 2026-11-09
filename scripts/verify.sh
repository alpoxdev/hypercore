#!/usr/bin/env bash
# verify.sh — repository verification gate for the skill tooling.
#
# Runs, in order:
#   1. shellcheck over scripts/*.sh, scripts/lib/*.sh, scripts/tests/*.sh
#      (skipped when shellcheck is not installed)
#   2. the bash test suite (scripts/run-tests.sh)
#   3. scripts/check-skill-corpus.sh
#   4. scripts/check-skill-contract-parity.sh
#   5. scripts/check-skill-standards.sh
#   6. scripts/check-vercel-skills.sh
#   7. scripts/check-plugin-manifests.sh
#
# Every step runs even when an earlier step fails; the script exits 1 when any
# step failed.
set -uo pipefail

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)
cd "$ROOT" || exit 1

FAILED=0
STEP=0

run_step() { # <label> <command...>
  local label=$1
  shift
  STEP=$((STEP + 1))
  printf '\n== %d. %s\n' "$STEP" "$label"
  "$@"
  local rc=$?
  if [ "$rc" -eq 0 ]; then
    printf 'OK %s\n' "$label"
  else
    printf 'FAIL %s (exit %d)\n' "$label" "$rc"
    FAILED=1
  fi
}

printf 'hypercore verification\n'
printf 'repository: %s\n' "$ROOT"

STEP=$((STEP + 1))
printf '\n== %d. shellcheck\n' "$STEP"
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck scripts/*.sh scripts/lib/*.sh scripts/tests/*.sh scripts/tests/lib/*.sh
  rc=$?
  if [ "$rc" -eq 0 ]; then
    printf 'OK shellcheck\n'
  else
    printf 'FAIL shellcheck (exit %d)\n' "$rc"
    FAILED=1
  fi
else
  printf 'SKIP shellcheck (not installed)\n'
fi

run_step "bash test suite" bash scripts/run-tests.sh
run_step "skill-script corpus" bash scripts/check-skill-corpus.sh
run_step "skill contract parity" bash scripts/check-skill-contract-parity.sh
run_step "skill standards" bash scripts/check-skill-standards.sh
run_step "vercel skills lifecycle" bash scripts/check-vercel-skills.sh
run_step "plugin manifests" bash scripts/check-plugin-manifests.sh

printf '\n'
if [ "$FAILED" -eq 0 ]; then
  printf 'verify: all checks passed\n'
  exit 0
fi
printf 'verify: one or more checks failed\n'
exit 1
