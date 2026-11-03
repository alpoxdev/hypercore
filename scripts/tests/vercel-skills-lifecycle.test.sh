#!/usr/bin/env bash
# vercel-skills-lifecycle.test.sh — exercise the deterministic Vercel skills
# source checks and the opt-in public upstream lifecycle.
#
# The live lifecycle case runs only when HYPERCORE_ENABLE_VERCEL_SKILLS_LIVE_GATE=1
# and needs network access plus npx; it is skipped by default.

set -uo pipefail
# shellcheck disable=SC1090,SC1091
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

SCRIPTS_DIR=${HYPERCORE_SCRIPTS_DIR:-$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)}
VALIDATOR=$SCRIPTS_DIR/check-vercel-skills.sh
README_FIXTURE=$SCRIPTS_DIR/fixtures/vercel-skills-lifecycle/README.fixture.txt

# must <command...> — abort the current case on a non-zero status. run_case
# executes cases with errexit suppressed, so setup and assertions chain here.
must() {
  "$@" || exit 1
}

materialize_source() {
  local root=$1
  local frontmatter
  frontmatter=$'---\nname: example\ndescription: Deterministic lifecycle fixture.\n---\n\n# Example\n'
  mkdir -p "$root/skills/example"
  printf '%s' "$frontmatter" >"$root/skills/example/SKILL.md"
  printf '%s' "$frontmatter" >"$root/skills/example/SKILL.ko.md"
  cp "$README_FIXTURE" "$root/README.md"
}

prepare_isolated_env() {
  local root=$1
  mkdir -p "$root/home" "$root/xdg" "$root/claude" "$root/codex"
}

# run_validator <root> <output-file> — run the bash validator with isolated
# agent homes and merge stdout and stderr into the output file.
run_validator() {
  local root=$1
  local out=$2
  local rc=0
  prepare_isolated_env "$root"
  env \
    HOME="$root/home" \
    XDG_CONFIG_HOME="$root/xdg" \
    XDG_STATE_HOME="$root/xdg" \
    CLAUDE_CONFIG_DIR="$root/claude" \
    CODEX_HOME="$root/codex" \
    CI=1 \
    NO_COLOR=1 \
    bash "$VALIDATOR" --root "$root" >"$out" 2>&1 || rc=$?
  return "$rc"
}

apply_defect() {
  local name=$1
  local root=$2
  case $name in
    frontmatter)
      printf '# Missing frontmatter\n' >"$root/skills/example/SKILL.md"
      ;;
    bilingual)
      rm -f "$root/skills/example/SKILL.ko.md"
      ;;
    adapter)
      mkdir -p "$root/.claude-plugin"
      ;;
    readme)
      printf 'npx skills\n' >"$root/README.md"
      ;;
    *)
      printf 'unknown defect: %s\n' "$name" >&2
      return 1
      ;;
  esac
}

defect_message() {
  case $1 in
    frontmatter) printf '%s' 'skills/example/SKILL.md must start with YAML frontmatter' ;;
    bilingual) printf '%s' 'skills/example/SKILL.ko.md must be a file' ;;
    adapter) printf '%s' '.claude-plugin must not remain' ;;
    readme) printf '%s' 'README.md must document npx skills add' ;;
  esac
}

# run_skills <dir> <stdout-file> <stderr-file> [npx skills arguments...]
run_skills() {
  local dir=$1
  local out=$2
  local err=$3
  shift 3
  local rc=0
  prepare_isolated_env "$dir"
  (
    cd "$dir" || exit 1
    env \
      HOME="$dir/home" \
      XDG_CONFIG_HOME="$dir/xdg" \
      XDG_STATE_HOME="$dir/xdg" \
      CLAUDE_CONFIG_DIR="$dir/claude" \
      CODEX_HOME="$dir/codex" \
      CI=1 \
      NO_COLOR=1 \
      npx --yes skills "$@"
  ) >"$out" 2>"$err" || rc=$?
  return "$rc"
}

case_accepts_deterministic_source() {
  local root out rc=0
  root=$(new_workdir)
  materialize_source "$root"
  out=$root/validator.out
  run_validator "$root" "$out" || rc=$?
  must assert_eq 0 "$rc" "validator exit code"
  must assert_contains "$(cat "$out")" "vercel skills lifecycle validation passed"
}

case_classifies_failures() {
  local name root out rc
  for name in frontmatter bilingual adapter readme; do
    root=$(new_workdir)
    must materialize_source "$root"
    must apply_defect "$name" "$root"
    out=$root/validator.out
    rc=0
    run_validator "$root" "$out" || rc=$?
    must assert_eq 1 "$rc" "$name exit code"
    must assert_contains "$(cat "$out")" "vercel skills lifecycle validation failed: $(defect_message "$name")" "$name message"
  done
}

case_live_lifecycle() {
  if [ "${HYPERCORE_ENABLE_VERCEL_SKILLS_LIVE_GATE:-}" != "1" ]; then
    skip "HYPERCORE_ENABLE_VERCEL_SKILLS_LIVE_GATE is not 1"
  fi
  require_cmd npx

  local root use_root use_out use_err rc
  local project_lock project_list project_add_out project_add_err
  local source_before hash_before
  local global_lock global_list

  root=$(new_workdir)
  prepare_isolated_env "$root"
  use_root=$root/use-only
  must mkdir -p "$use_root"

  use_out=$root/use.out
  use_err=$root/use.err
  rc=0
  run_skills "$use_root" "$use_out" "$use_err" use alpoxdev/hypercore --skill git-maker || rc=$?
  must assert_eq 0 "$rc" "use exit code"
  must assert_contains "$(cat "$use_out")$(cat "$use_err")" "git-maker"
  must assert_not_file "$use_root/skills-lock.json"
  must assert_not_file "$use_root/.agents"
  must assert_not_file "$use_root/.claude"

  project_add_out=$root/project-add.out
  project_add_err=$root/project-add.err
  rc=0
  run_skills "$root" "$project_add_out" "$project_add_err" add alpoxdev/hypercore --skill git-maker -a codex -y || rc=$?
  must assert_eq 0 "$rc" "project add exit code"

  project_lock=$root/skills-lock.json
  must assert_json_eq "$project_lock" '.version' '1'
  must assert_json_eq "$project_lock" '.skills["git-maker"].source' 'alpoxdev/hypercore'
  must assert_jq "$project_lock" '.skills["git-maker"].computedHash'
  source_before=$(json_get "$project_lock" '.skills["git-maker"].source')
  hash_before=$(json_get "$project_lock" '.skills["git-maker"].computedHash')

  rc=0
  run_skills "$root" "$root/project-update.out" "$root/project-update.err" update git-maker -y || rc=$?
  must assert_eq 0 "$rc" "project update exit code"
  must assert_json_eq "$project_lock" '.skills["git-maker"].source' "$source_before"
  must assert_json_eq "$project_lock" '.skills["git-maker"].computedHash' "$hash_before"

  project_list=$root/project-list.json
  rc=0
  run_skills "$root" "$project_list" "$root/project-list.err" list --json || rc=$?
  must assert_eq 0 "$rc" "project list exit code"
  must assert_json_eq "$project_list" 'length' '1'
  must assert_json_eq "$project_list" '.[0].source' 'alpoxdev/hypercore'
  must assert_contains "$(json_get "$project_list" '.[0].path')" "/.agents/skills/git-maker"

  rc=0
  run_skills "$root" "$root/project-remove.out" "$root/project-remove.err" remove git-maker -y || rc=$?
  must assert_eq 0 "$rc" "project remove exit code"
  rc=0
  run_skills "$root" "$root/project-list-after.json" "$root/project-list-after.err" list --json || rc=$?
  must assert_eq 0 "$rc" "project list after remove exit code"
  must assert_json_eq "$root/project-list-after.json" 'length' '0'
  must assert_not_file "$root/.agents/skills/git-maker"
  must assert_json_eq "$project_lock" '(.skills["git-maker"] == null)' 'true'

  rc=0
  run_skills "$root" "$root/copy-add.out" "$root/copy-add.err" add alpoxdev/hypercore --skill git-maker -a claude-code --copy -y || rc=$?
  must assert_eq 0 "$rc" "copy add exit code"
  must assert_dir "$root/.claude/skills/git-maker"
  must assert_exit 1 test -L "$root/.claude/skills/git-maker"
  rc=0
  run_skills "$root" "$root/copy-remove.out" "$root/copy-remove.err" remove git-maker -y || rc=$?
  must assert_eq 0 "$rc" "copy remove exit code"

  rc=0
  run_skills "$root" "$root/multi-add.out" "$root/multi-add.err" add alpoxdev/hypercore --skill git-maker -a claude-code -a codex -y || rc=$?
  must assert_eq 0 "$rc" "multi add exit code"
  must assert_dir "$root/.agents/skills/git-maker"
  must assert_dir "$root/.claude/skills/git-maker"

  rc=0
  run_skills "$root" "$root/partial-remove.out" "$root/partial-remove.err" remove git-maker -a claude-code -y || rc=$?
  must assert_eq 0 "$rc" "partial remove exit code"
  must assert_dir "$root/.agents/skills/git-maker"
  must assert_json_eq "$project_lock" '(.skills["git-maker"] == null)' 'true'

  rc=0
  run_skills "$root" "$root/managed-add.out" "$root/managed-add.err" add alpoxdev/hypercore --skill git-maker -a codex -y || rc=$?
  must assert_eq 0 "$rc" "managed re-add exit code"
  must assert_json_eq "$project_lock" '.skills["git-maker"].source' 'alpoxdev/hypercore'
  must assert_jq "$project_lock" '.skills["git-maker"].computedHash'
  rc=0
  run_skills "$root" "$root/managed-remove.out" "$root/managed-remove.err" remove git-maker -y || rc=$?
  must assert_eq 0 "$rc" "managed remove exit code"

  rc=0
  run_skills "$root" "$root/global-add.out" "$root/global-add.err" add alpoxdev/hypercore --skill git-maker -a codex -g -y || rc=$?
  must assert_eq 0 "$rc" "global add exit code"
  global_lock=$root/xdg/skills/.skill-lock.json
  must assert_json_eq "$global_lock" '.version' '3'
  must assert_json_eq "$global_lock" '.skills["git-maker"].source' 'alpoxdev/hypercore'
  must assert_jq "$global_lock" '.skills["git-maker"].skillFolderHash'
  source_before=$(json_get "$global_lock" '.skills["git-maker"].source')
  hash_before=$(json_get "$global_lock" '.skills["git-maker"].skillFolderHash')

  rc=0
  run_skills "$root" "$root/global-update.out" "$root/global-update.err" update git-maker -g -y || rc=$?
  must assert_eq 0 "$rc" "global update exit code"
  must assert_json_eq "$global_lock" '.skills["git-maker"].source' "$source_before"
  must assert_json_eq "$global_lock" '.skills["git-maker"].skillFolderHash' "$hash_before"

  global_list=$root/global-list.json
  rc=0
  run_skills "$root" "$global_list" "$root/global-list.err" list -g --json || rc=$?
  must assert_eq 0 "$rc" "global list exit code"
  must assert_contains "$(json_get "$global_list" '.[0].path')" "/home/.agents/skills/git-maker"
  must assert_not_contains "$(json_get "$global_list" '.[0].path')" "/codex/"

  rc=0
  run_skills "$root" "$root/global-remove.out" "$root/global-remove.err" remove git-maker -g -y || rc=$?
  must assert_eq 0 "$rc" "global remove exit code"
  must assert_not_file "$root/home/.agents/skills/git-maker"
  must assert_json_eq "$global_lock" '(.skills["git-maker"] == null)' 'true'

  rc=0
  run_skills "$root" "$root/init.out" "$root/init.err" init fixture-skill || rc=$?
  must assert_eq 0 "$rc" "init exit code"
  must assert_file "$root/fixture-skill/SKILL.md"
  local generated_before
  generated_before=$(cat "$root/fixture-skill/SKILL.md") || exit 1
  rc=0
  run_skills "$root" "$root/init-again.out" "$root/init-again.err" init fixture-skill || rc=$?
  must assert_eq 0 "$rc" "second init exit code"
  must assert_eq "$generated_before" "$(cat "$root/fixture-skill/SKILL.md")" "generated skill content"

  rc=0
  run_skills "$root" "$root/find.out" "$root/find.err" find hypercore --owner alpoxdev || rc=$?
  must assert_eq 0 "$rc" "find exit code"
  must assert_contains "$(cat "$root/find.out")$(cat "$root/find.err")" "hypercore"
}

describe "vercel skills lifecycle"
run_case "accepts a deterministic source without reading isolated agent homes" case_accepts_deterministic_source
run_case "classifies frontmatter, bilingual, adapter, and README contract failures" case_classifies_failures
run_case "runs the public remote lifecycle in isolated project and global scopes" case_live_lifecycle
test_summary
