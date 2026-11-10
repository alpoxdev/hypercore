#!/usr/bin/env bash
# check-plugin-manifests.sh contracts: the checker accepts the repository's own
# manifests and rejects each way the Codex, Claude Code and Cursor manifests can
# drift.
# Each mutation runs on a minimal copied tree, never on the working tree.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
CHECK=$ROOT/scripts/check-plugin-manifests.sh

# fixture_tree <dir> — manifests plus one valid skill.
fixture_tree() {
  local dir=$1
  mkdir -p "$dir/.codex-plugin" "$dir/.claude-plugin" "$dir/.cursor-plugin" "$dir/skills/demo"
  cp "$ROOT/.codex-plugin/plugin.json" "$dir/.codex-plugin/plugin.json"
  cp "$ROOT/.claude-plugin/plugin.json" "$dir/.claude-plugin/plugin.json"
  cp "$ROOT/.claude-plugin/marketplace.json" "$dir/.claude-plugin/marketplace.json"
  cp "$ROOT/.cursor-plugin/plugin.json" "$dir/.cursor-plugin/plugin.json"
  printf -- '---\nname: demo\ndescription: "Demo skill."\n---\n\n# Demo\n' >"$dir/skills/demo/SKILL.md"
}

# edit_json <file> <jq-filter> — rewrite a JSON file in place.
edit_json() {
  local file=$1 filter=$2
  jq "$filter" "$file" >"$file.tmp" && mv "$file.tmp" "$file"
}

case_repository_passes() {
  require_cmd jq
  assert_success bash "$CHECK" "$ROOT"
}

case_version_drift_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  edit_json "$dir/.claude-plugin/plugin.json" '.version = "9.9.9"'
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" "version differs"
}

case_cursor_version_drift_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  edit_json "$dir/.cursor-plugin/plugin.json" '.version = "9.9.9"'
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" "version differs between .cursor-plugin and .claude-plugin"
}

case_cursor_missing_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  rm "$dir/.cursor-plugin/plugin.json"
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" ".cursor-plugin/plugin.json is missing"
}

case_non_semver_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  edit_json "$dir/.claude-plugin/plugin.json" '.version = "one"'
  edit_json "$dir/.codex-plugin/plugin.json" '.version = "one"'
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" "not SemVer"
}

case_entry_name_mismatch_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  edit_json "$dir/.claude-plugin/marketplace.json" '.plugins[0].name = "other"'
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" "marketplace entry name differs"
}

case_entry_version_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  edit_json "$dir/.claude-plugin/marketplace.json" '.plugins[0].version = "1.1.0"'
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" "must not set version"
}

case_parent_source_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  edit_json "$dir/.claude-plugin/marketplace.json" '.plugins[0].source = "./../x"'
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" "must not contain .."
}

case_invalid_yaml_escape_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  # shellcheck disable=SC2016 # literal backticks: the fixture needs an unexpanded YAML escape
  printf -- '---\nname: demo\ndescription: "Saves `\\.hyper/x`."\n---\n' >"$dir/skills/demo/SKILL.md"
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" "invalid YAML escape"
}

case_name_directory_mismatch_fails() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir"
  printf -- '---\nname: other\ndescription: "Demo."\n---\n' >"$dir/skills/demo/SKILL.md"
  local out
  out=$(bash "$CHECK" "$dir" 2>&1) && fail "expected failure"
  assert_contains "$out" "differs from its directory"
}

run_case "repository manifests pass" case_repository_passes
run_case "version drift between manifests fails" case_version_drift_fails
run_case "Cursor manifest version drift fails" case_cursor_version_drift_fails
run_case "missing Cursor manifest fails" case_cursor_missing_fails
run_case "non-SemVer version fails" case_non_semver_fails
run_case "marketplace entry name mismatch fails" case_entry_name_mismatch_fails
run_case "marketplace entry version fails" case_entry_version_fails
run_case "source containing .. fails" case_parent_source_fails
run_case "invalid YAML escape in frontmatter fails" case_invalid_yaml_escape_fails
run_case "skill name differing from directory fails" case_name_directory_mismatch_fails

test_summary
