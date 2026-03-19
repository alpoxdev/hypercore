#!/usr/bin/env bash
# repo-discover.sh - detect current or descendant git repositories
# Usage: ./repo-discover.sh [start_dir]

set -euo pipefail

START_DIR="${1:-.}"

if [ ! -d "$START_DIR" ]; then
  echo "Error: Directory not found: $START_DIR" >&2
  exit 1
fi

cd "$START_DIR"

if ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "current|$ROOT"
  exit 0
fi

FOUND=0
while IFS= read -r git_path; do
  FOUND=1
  if [ "$(basename "$git_path")" = ".git" ]; then
    echo "descendant|$(cd "$(dirname "$git_path")" && pwd)"
  fi
done < <(find . -mindepth 2 \( -name .git -type d -o -name .git -type f \) | sort)

if [ "$FOUND" -eq 0 ]; then
  echo "Error: No git repository found from $START_DIR" >&2
  exit 1
fi
