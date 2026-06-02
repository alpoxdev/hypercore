#!/usr/bin/env bash
# git-push.sh - discover repositories and push unpushed commits safely
# Usage: ./git-push.sh [--force]
#
# Discovers the current git repository or descendant repositories,
# checks each for unpushed commits, and pushes them.
# Exits 0 if at least one repo was pushed successfully.

set -euo pipefail

FORCE=false
START_DIR="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=true
      shift
      ;;
    *)
      echo "Usage: $0 [--force]" >&2
      exit 1
      ;;
  esac
done

# --- Repository discovery ---

REPOS=()

if ROOT="$(git -C "$START_DIR" rev-parse --show-toplevel 2>/dev/null)"; then
  REPOS+=("$ROOT")
else
  while IFS= read -r git_path; do
    [[ -z "$git_path" ]] && continue
    if [[ "$(basename "$git_path")" == ".git" ]]; then
      REPOS+=("$(cd "$(dirname "$git_path")" && pwd)")
    fi
  done < <(find "$START_DIR" -mindepth 2 \( -name .git -type d -o -name .git -type f \) 2>/dev/null | sort)
fi

if [[ ${#REPOS[@]} -eq 0 ]]; then
  echo "Error: No git repository found" >&2
  exit 1
fi

# --- Push each repository ---

PUSHED=0
SKIPPED=0
ERRORS=0

for repo in "${REPOS[@]}"; do
  label="$repo"

  # Branch check
  BRANCH="$(git -C "$repo" branch --show-current 2>/dev/null || true)"
  if [[ -z "$BRANCH" ]]; then
    echo "[$label] Skipped: detached HEAD" >&2
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Force push safety
  if [[ "$FORCE" == true ]] && { [[ "$BRANCH" == "main" ]] || [[ "$BRANCH" == "master" ]]; }; then
    echo "[$label] Skipped: cannot force push to protected branch $BRANCH" >&2
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Check upstream and ahead count
  HAS_UPSTREAM=false
  AHEAD=0
  if git -C "$repo" rev-parse --abbrev-ref "@{upstream}" >/dev/null 2>&1; then
    HAS_UPSTREAM=true
    AHEAD="$(git -C "$repo" rev-list --count "@{upstream}..HEAD" 2>/dev/null || echo 0)"
  fi

  if [[ "$HAS_UPSTREAM" == true ]] && [[ "$AHEAD" -eq 0 ]]; then
    echo "[$label] Already up to date on $BRANCH"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Push
  if [[ "$HAS_UPSTREAM" == true ]]; then
    echo "[$label] Pushing $AHEAD commit(s) on $BRANCH..."
    if [[ "$FORCE" == true ]]; then
      if git -C "$repo" push --force-with-lease; then
        PUSHED=$((PUSHED + 1))
      else
        echo "[$label] Push failed" >&2
        ERRORS=$((ERRORS + 1))
      fi
    else
      if git -C "$repo" push; then
        PUSHED=$((PUSHED + 1))
      else
        echo "[$label] Push failed" >&2
        ERRORS=$((ERRORS + 1))
      fi
    fi
  else
    echo "[$label] No upstream. Pushing $BRANCH to origin..."
    if [[ "$FORCE" == true ]]; then
      if git -C "$repo" push -u origin "$BRANCH" --force-with-lease; then
        PUSHED=$((PUSHED + 1))
      else
        echo "[$label] Push failed" >&2
        ERRORS=$((ERRORS + 1))
      fi
    else
      if git -C "$repo" push -u origin "$BRANCH"; then
        PUSHED=$((PUSHED + 1))
      else
        echo "[$label] Push failed" >&2
        ERRORS=$((ERRORS + 1))
      fi
    fi
  fi
done

# --- Summary ---

echo ""
echo "Done: $PUSHED pushed, $SKIPPED skipped, $ERRORS failed"

if [[ "$ERRORS" -gt 0 ]]; then
  exit 1
fi

if [[ "$PUSHED" -eq 0 ]]; then
  echo "Nothing to push."
  exit 0
fi

exit 0
