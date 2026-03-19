#!/usr/bin/env bash
# repo-status.sh - summarize git state for one repository
# Usage: ./repo-status.sh [repo]

set -euo pipefail

REPO="${1:-.}"

if [ ! -d "$REPO" ]; then
  echo "Error: Directory not found: $REPO" >&2
  exit 1
fi

cd "$REPO"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: Not a git repository: $REPO" >&2
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"

echo "repo|$ROOT"
echo "status|begin"
git status --short --branch
echo "status|end"

echo "staged|begin"
if git diff --staged --quiet; then
  echo "(no staged changes)"
else
  git diff --staged --stat
fi
echo "staged|end"

echo "unstaged|begin"
UNTRACKED_FILES="$(git ls-files --others --exclude-standard)"

if git diff --quiet && [ -z "$UNTRACKED_FILES" ]; then
  echo "(no unstaged changes)"
else
  if ! git diff --quiet; then
    git diff --stat
  fi

  if [ -n "$UNTRACKED_FILES" ]; then
    while IFS= read -r untracked_file; do
      [ -n "$untracked_file" ] && echo "untracked: $untracked_file"
    done <<< "$UNTRACKED_FILES"
  fi
fi
echo "unstaged|end"
