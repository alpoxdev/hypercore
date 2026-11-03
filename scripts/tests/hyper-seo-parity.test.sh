#!/usr/bin/env bash
# hyper-seo bilingual structural-tag parity — bash port of
# scripts/tests/hyper-seo-parity.test.mjs.
#
# validate-skill.sh compares the structural tag sequence of SKILL.md and
# SKILL.ko.md and reports BILINGUAL_TAG_DRIFT when they differ. Two empty tag
# lists compare equal, so this pins the contract from both sides: the shipped
# skill validates with two identical, non-empty tag sequences, and a copy with
# one tag removed fails with that code.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
VALIDATOR="$ROOT/skills/skill-tester/scripts/validate-skill.sh"
SKILL="$ROOT/skills/hyper-seo"

# structural_tags <file> — whole-line structural tags, lowercased.
structural_tags() {
  awk '
    tolower($0) ~ /^<\/?[a-z][a-z0-9_]*>[ \t]*$/ {
      line = tolower($0)
      sub(/[ \t\r]+$/, "", line)
      print line
    }
  ' "$1"
}

# validate_skill <target> <out-json> — run the validator, print its exit code.
validate_skill() {
  local target=$1 out=$2 rc=0
  bash "$VALIDATOR" "$target" --json >"$out" 2>/dev/null || rc=$?
  printf '%s\n' "$rc"
}

case_structural_tags_parity() {
  local work rc english
  work=$(new_workdir)
  rc=$(validate_skill "$SKILL" "$work/report.json")
  assert_json_eq "$work/report.json" '.ok' "true" "validator ok"
  assert_json_eq "$work/report.json" '.failures | length' "0" "validator failures"
  assert_json_eq "$work/report.json" '.checks.coreParity' "true" "core parity"
  assert_eq "0" "$rc" "validator exit"

  structural_tags "$SKILL/SKILL.md" >"$work/en.tags"
  structural_tags "$SKILL/SKILL.ko.md" >"$work/ko.tags"
  english=$(wc -l <"$work/en.tags" | tr -d ' ')
  [ "$english" -gt 0 ] || fail "en tag list is empty"
  assert_eq "$(cat "$work/en.tags")" "$(cat "$work/ko.tags")" "tag sequences"
}

case_tag_drift_detected() {
  local work copy target rc
  work=$(new_workdir)
  cp -R "$SKILL" "$work/hyper-seo"
  copy="$work/hyper-seo"
  rc=$(validate_skill "$copy" "$work/before.json")
  assert_json_eq "$work/before.json" '.ok' "true" "copy validates before mutation"
  assert_eq "0" "$rc" "copy exit before mutation"

  target="$copy/SKILL.ko.md"
  awk 'tolower($0) !~ /^<\/?scoring>[ \t]*$/' "$target" >"$work/skill.ko.md"
  mv "$work/skill.ko.md" "$target"
  assert_ne "$(structural_tags "$SKILL/SKILL.ko.md")" "$(structural_tags "$target")" "tag removed"

  rc=$(validate_skill "$copy" "$work/after.json")
  assert_eq "1" "$rc" "validator exit after drift"
  assert_json_eq "$work/after.json" '.ok' "false" "validator reports failure"
  assert_contains "$(jq -r '[.failures[].code] | join(",")' "$work/after.json")" "BILINGUAL_TAG_DRIFT" "drift code"
}

run_case "hyper-seo SKILL.md and SKILL.ko.md carry the same non-empty structural tags" case_structural_tags_parity
run_case "removing one structural tag from a temp copy fails with BILINGUAL_TAG_DRIFT" case_tag_drift_detected
test_summary
