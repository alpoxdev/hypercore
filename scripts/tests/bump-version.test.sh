#!/usr/bin/env bash
# bump-version.sh contracts: keyword and explicit bumps rewrite every manifest
# to one version that passes check-plugin-manifests.sh, and every rejected
# argument leaves the files byte-identical. Each case runs on a copied tree.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
BUMP=$ROOT/scripts/bump-version.sh
CHECK=$ROOT/scripts/check-plugin-manifests.sh

# fixture_tree <dir> <version> — the three manifests at <version> plus one skill.
fixture_tree() {
  local dir=$1 version=$2 file
  mkdir -p "$dir/.codex-plugin" "$dir/.claude-plugin" "$dir/.cursor-plugin" "$dir/skills/demo"
  cp "$ROOT/.claude-plugin/marketplace.json" "$dir/.claude-plugin/marketplace.json"
  for file in .codex-plugin/plugin.json .claude-plugin/plugin.json .cursor-plugin/plugin.json; do
    jq --arg v "$version" '.version = $v' "$ROOT/$file" >"$dir/$file"
  done
  printf -- '---\nname: demo\ndescription: "Demo skill."\n---\n\n# Demo\n' >"$dir/skills/demo/SKILL.md"
}

# versions <dir> — the three manifest versions on one line.
versions() {
  local dir=$1
  printf '%s %s %s' \
    "$(jq -r .version "$dir/.codex-plugin/plugin.json")" \
    "$(jq -r .version "$dir/.claude-plugin/plugin.json")" \
    "$(jq -r .version "$dir/.cursor-plugin/plugin.json")"
}

# digest <dir> — one hash over the three manifests.
digest() {
  local dir=$1
  cat "$dir/.codex-plugin/plugin.json" "$dir/.claude-plugin/plugin.json" "$dir/.cursor-plugin/plugin.json" | shasum -a 256
}

# expect_bump <from> <argument> <to>
expect_bump() {
  require_cmd jq
  local dir
  dir=$(new_workdir)
  fixture_tree "$dir" "$1"
  assert_success bash "$BUMP" "$2" "$dir"
  assert_eq "$3 $3 $3" "$(versions "$dir")"
  assert_success bash "$CHECK" "$dir"
}

# expect_rejected <from> <argument...> — exit 1 and no file changes.
expect_rejected() {
  require_cmd jq
  require_cmd shasum
  local dir from=$1 before
  shift
  dir=$(new_workdir)
  fixture_tree "$dir" "$from"
  before=$(digest "$dir")
  assert_exit 1 bash "$BUMP" "$@" "$dir"
  assert_eq "$before" "$(digest "$dir")"
}

case_patch() { expect_bump 1.1.0 patch 1.1.1; }
case_minor() { expect_bump 1.1.3 minor 1.2.0; }
case_major() { expect_bump 1.4.2 major 2.0.0; }
case_explicit() { expect_bump 1.1.0 1.10.0 1.10.0; }
case_release_from_prerelease() { expect_bump 2.0.0-rc.1 2.0.0 2.0.0; }
case_lower_rejected() { expect_rejected 1.1.0 1.0.0; }
case_same_rejected() { expect_rejected 1.1.0 1.1.0; }
case_bad_argument_rejected() { expect_rejected 1.1.0 next; }
case_partial_version_rejected() { expect_rejected 1.1.0 1.2; }

case_drifted_manifests_rejected() {
  require_cmd jq
  require_cmd shasum
  local dir before
  dir=$(new_workdir)
  fixture_tree "$dir" 1.1.0
  jq '.version = "1.0.9"' "$dir/.cursor-plugin/plugin.json" >"$dir/tmp.json" && mv "$dir/tmp.json" "$dir/.cursor-plugin/plugin.json"
  before=$(digest "$dir")
  assert_exit 1 bash "$BUMP" patch "$dir"
  assert_eq "$before" "$(digest "$dir")"
}

run_case "patch bumps every manifest" case_patch
run_case "minor resets patch" case_minor
run_case "major resets minor and patch" case_major
run_case "explicit X.Y.Z compares numerically" case_explicit
run_case "X.Y.Z is higher than its pre-release" case_release_from_prerelease
run_case "lower version is rejected without changes" case_lower_rejected
run_case "same version is rejected without changes" case_same_rejected
run_case "unknown argument is rejected without changes" case_bad_argument_rejected
run_case "partial version is rejected without changes" case_partial_version_rejected
run_case "drifted manifests are rejected without changes" case_drifted_manifests_rejected

test_summary
