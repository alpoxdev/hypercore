#!/usr/bin/env bash
# git-commit-detect.sh - detect whether a usable git-commit skill is installed
# Search order:
#   1) ~/.agents/skills/git-commit
#   2) ~/.claude/skills/git-commit
# Output:
#   installed|<absolute_skill_dir>
#   missing|<searched_paths>|<reason>

set -euo pipefail

SEARCHED=()

add_candidate() {
  local path="$1"
  [ -z "$path" ] && return
  for existing in "${CANDIDATES[@]:-}"; do
    [ "$existing" = "$path" ] && return
  done
  CANDIDATES+=("$path")
}

validate_skill_dir() {
  local skill_dir="$1"

  if [ ! -d "$skill_dir" ]; then
    VALIDATE_REASON="directory-not-found"
    return 1
  fi

  if [ ! -f "$skill_dir/SKILL.md" ]; then
    VALIDATE_REASON="skill-markdown-missing"
    return 1
  fi

  if ! grep -Eq '^name:[[:space:]]*git-commit[[:space:]]*$' "$skill_dir/SKILL.md"; then
    VALIDATE_REASON="skill-name-mismatch"
    return 1
  fi

  local required_scripts=(
    "$skill_dir/scripts/git-commit.sh"
    "$skill_dir/scripts/git-push.sh"
    "$skill_dir/scripts/repo-discover.sh"
    "$skill_dir/scripts/repo-status.sh"
  )

  local path
  for path in "${required_scripts[@]}"; do
    if [ ! -f "$path" ]; then
      VALIDATE_REASON="missing-file:$(basename "$path")"
      return 1
    fi

    if [ ! -r "$path" ]; then
      VALIDATE_REASON="unreadable-file:$(basename "$path")"
      return 1
    fi

    if [ ! -x "$path" ]; then
      VALIDATE_REASON="non-executable-file:$(basename "$path")"
      return 1
    fi
  done

  VALIDATE_REASON=""
  return 0
}

declare -a CANDIDATES=()
add_candidate "$HOME/.agents/skills/git-commit"
add_candidate "$HOME/.claude/skills/git-commit"

LAST_REASON="no-candidates"
for skill_dir in "${CANDIDATES[@]}"; do
  SEARCHED+=("$skill_dir")
  if validate_skill_dir "$skill_dir"; then
    echo "installed|$skill_dir"
    exit 0
  fi
  LAST_REASON="$VALIDATE_REASON"
done

SEARCHED_JOINED="$(printf '%s\n' "${SEARCHED[@]}" | paste -sd ',' -)"
echo "missing|$SEARCHED_JOINED|$LAST_REASON"
