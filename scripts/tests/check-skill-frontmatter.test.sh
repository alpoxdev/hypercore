#!/usr/bin/env bash
# check-skill-frontmatter.sh contracts: accepts the repository's skills corpus
# and rejects strict-YAML syntax errors, unsafe unquoted scalars, and schema
# mismatches on isolated fixtures.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
CHECK=$ROOT/scripts/check-skill-frontmatter.sh

write_skill() { # <root> <folder> <filename> <frontmatter-body>
  local root=$1 folder=$2 filename=$3 fm=$4
  mkdir -p "$root/$folder"
  {
    printf -- '---\n'
    printf '%s\n' "$fm"
    printf -- '---\n\n# %s\n' "$folder"
  } >"$root/$folder/$filename"
}

case_repository_passes() {
  assert_success bash "$CHECK" --root "$ROOT/skills"
}

case_rejects_unquoted_colon_space_and_accepts_quoted() {
  local dir out
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: "Use this skill when testing."\ncompatibility: Optional feature: fails when unquoted.'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for unquoted ': ' in SKILL.md"
  assert_contains "$out" "demo/SKILL.md"
  assert_contains "$out" "mapping values are not allowed"

  # Quoting the exact same value fixes SKILL.md; unquoted ': ' in SKILL.ko.md is also caught.
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: "Use this skill when testing."\ncompatibility: "Optional feature: works when quoted."'
  write_skill "$dir" demo SKILL.ko.md $'name: demo\ndescription: "테스트할 때 사용합니다."\ncompatibility: 선택 기능(예: 따옴표 없으면 실패).'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for unquoted ': ' in SKILL.ko.md"
  assert_contains "$out" "demo/SKILL.ko.md"

  write_skill "$dir" demo SKILL.ko.md $'name: demo\ndescription: "테스트할 때 사용합니다."\ncompatibility: "선택 기능(예: 따옴표로 감싸면 통과)."'
  assert_success bash "$CHECK" --root "$dir"
}

case_rejects_yaml_hazards() {
  local dir out

  # Duplicate key
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: "First."\ndescription: "Second."'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for duplicate key"
  assert_contains "$out" "duplicate key"

  # Tab indentation
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: demo\n\tdescription: "Tabbed."'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for tab indentation"
  assert_contains "$out" "tab indentation"

  # Unquoted inline ' #' comment truncation
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: Use for #1 issues.'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for unquoted ' #'"
  assert_contains "$out" "parses as a comment"

  # Invalid escape in double-quoted string
  dir=$(new_workdir)
  # shellcheck disable=SC2016
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: "Path `\\.hyper/x`."'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for invalid YAML escape"
  assert_contains "$out" "YAML parse error"

  # Unmatched quote
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: "Unclosed quote'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for unmatched quote"
  assert_contains "$out" "YAML parse error"
}

case_rejects_schema_and_type_violations() {
  local dir out

  # name mismatch
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: other\ndescription: "Mismatch."'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for name mismatch"
  assert_contains "$out" "does not match folder name"

  # non-string description (YAML sequence)
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: [not, a, string]'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for non-string description"
  assert_contains "$out" "'description' must be a non-empty string"

  # non-string compatibility (YAML mapping)
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: "Valid."\ncompatibility:\n  os: macos'
  out=$(bash "$CHECK" --root "$dir" 2>&1) && fail "expected failure for non-string compatibility"
  assert_contains "$out" "'compatibility' must be a non-empty string"
}

case_accepts_quoted_block_scalar_and_comments() {
  local dir
  dir=$(new_workdir)
  write_skill "$dir" demo SKILL.md $'name: demo\ndescription: "[Hyper] Use this skill: handles #1 cases."\ncompatibility: >-\n  Needs shell: bash 3.2+ and jq.\n  Supports #comments inside block scalars.\n# Runtime extension note.\ndisable-model-invocation: true'
  assert_success bash "$CHECK" --root "$dir"
}

run_case "repository skills frontmatter passes" case_repository_passes
run_case "rejects unquoted ': ' in SKILL.md and SKILL.ko.md and accepts quoted values" case_rejects_unquoted_colon_space_and_accepts_quoted
run_case "rejects duplicate keys, tabs, unquoted ' #', invalid escapes, and unmatched quotes" case_rejects_yaml_hazards
run_case "rejects folder name mismatch and non-string description or compatibility" case_rejects_schema_and_type_violations
run_case "accepts quoted scalars, block scalars, and full-line YAML comments" case_accepts_quoted_block_scalar_and_comments

test_summary
