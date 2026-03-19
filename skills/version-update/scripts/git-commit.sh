#!/usr/bin/env bash
# git-commit.sh - fallback commit helper for version-update
# Usage: ./git-commit.sh "commit message" [files...]
# files omitted: commit the current staged set
# files provided: stage only those files and fail if unrelated staged files remain

set -euo pipefail

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository" >&2
  exit 1
fi

if [ -z "${1:-}" ]; then
  echo "Usage: $0 \"commit message\" [files...]" >&2
  exit 1
fi

COMMIT_MSG="$1"

if [ -z "$(echo "$COMMIT_MSG" | xargs)" ]; then
  echo "Error: Commit message cannot be empty" >&2
  exit 1
fi

shift
FILES_PROVIDED=$#

if [ $FILES_PROVIDED -gt 0 ]; then
  git add "$@"

  EXTRA_STAGED=()
  while IFS= read -r staged_file; do
    [ -z "$staged_file" ] && continue
    MATCHED=false
    for target in "$@"; do
      if [ "$staged_file" = "$target" ] || [[ "$staged_file" == "$target/"* ]]; then
        MATCHED=true
        break
      fi
    done

    if [ "$MATCHED" = false ]; then
      EXTRA_STAGED+=("$staged_file")
    fi
  done < <(git diff --cached --name-only)

  if [ "${#EXTRA_STAGED[@]}" -gt 0 ]; then
    echo "Error: Additional staged changes exist outside the requested files:" >&2
    printf '  %s\n' "${EXTRA_STAGED[@]}" >&2
    echo "Tip: Unstage unrelated files or commit them separately before retrying." >&2
    exit 1
  fi
fi

if git diff --cached --quiet; then
  if [ $FILES_PROVIDED -eq 0 ]; then
    echo "Error: No staged changes to commit" >&2
    echo "Tip: Stage files with 'git add' or pass files as arguments" >&2
  else
    echo "Error: No changes in specified files" >&2
    echo "Tip: Check if files exist and have modifications" >&2
  fi
  exit 1
fi

git commit -m "$COMMIT_MSG"

echo "Committed successfully"
