#!/usr/bin/env bash
# git-push.sh - safely push the current branch in one repository
# Usage: ./git-push.sh [--repo path] [--force]

set -euo pipefail

REPO="."
USE_FORCE=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
        echo "Usage: $0 [--repo path] [--force]" >&2
        exit 1
      fi
      REPO="${2:-}"
      shift 2
      ;;
    --force)
      USE_FORCE=true
      shift
      ;;
    *)
      echo "Usage: $0 [--repo path] [--force]" >&2
      exit 1
      ;;
  esac
done

if [ ! -d "$REPO" ]; then
  echo "Error: Directory not found: $REPO" >&2
  exit 1
fi

cd "$REPO"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: Not a git repository: $REPO" >&2
  exit 1
fi

BRANCH="$(git branch --show-current)"
if [ -z "$BRANCH" ]; then
  echo "Error: Not on any branch (detached HEAD)" >&2
  exit 1
fi

if [ "$USE_FORCE" = true ] && { [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; }; then
  echo "Error: Cannot force push to protected branch $BRANCH" >&2
  exit 1
fi

if ! git rev-parse --abbrev-ref "@{upstream}" >/dev/null 2>&1; then
  if [ "$USE_FORCE" = true ]; then
    git push -u origin "$BRANCH" --force-with-lease
  else
    git push -u origin "$BRANCH"
  fi
else
  if [ "$USE_FORCE" = true ]; then
    git push --force-with-lease
  else
    git push
  fi
fi

echo "Pushed successfully from $(git rev-parse --show-toplevel)"
