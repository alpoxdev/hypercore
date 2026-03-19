#!/usr/bin/env bash
# git-commit.sh - commit staged or selected files in one repository
# Usage: ./git-commit.sh [--repo path] "commit message" [files...]

set -euo pipefail

REPO="."

if [ "${1:-}" = "--repo" ]; then
  if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then
    echo "Usage: $0 [--repo path] \"commit message\" [files...]" >&2
    exit 1
  fi
  REPO="${2:-}"
  shift 2
fi

if [ -z "${1:-}" ]; then
  echo "Usage: $0 [--repo path] \"commit message\" [files...]" >&2
  exit 1
fi

COMMIT_MSG="$1"
shift

if [ -z "$(echo "$COMMIT_MSG" | xargs)" ]; then
  echo "Error: Commit message cannot be empty" >&2
  exit 1
fi

if [ ! -d "$REPO" ]; then
  echo "Error: Directory not found: $REPO" >&2
  exit 1
fi

cd "$REPO"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: Not a git repository: $REPO" >&2
  exit 1
fi

if [ "$#" -gt 0 ]; then
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
  echo "Error: No staged changes to commit" >&2
  exit 1
fi

git commit -m "$COMMIT_MSG"
echo "Committed successfully in $(git rev-parse --show-toplevel)"
