#!/usr/bin/env bash
# Directly commits the specified version-update files.
# Usage: git-commit.sh "commit message" [files...]
# Without files the current staged set is committed; with files only those
# paths are staged, and unrelated staged changes abort the commit.
#
# errexit is intentionally off: the git probes below use exit statuses 1 and
# 97 on purpose, so every call is checked explicitly.

set -uo pipefail

on_signal() {
  case "$1" in
    INT) exit 130 ;;
    TERM) exit 143 ;;
    *) exit 1 ;;
  esac
}

trap 'on_signal INT' INT
trap 'on_signal TERM' TERM

# Repository check: stderr is captured to classify the failure, so the raw
# "not a git repository" line is replaced by the stable message below.
git_error="$(git rev-parse --git-dir 2>&1)"
git_status=$?
if [ "$git_status" -ne 0 ]; then
  not_repository=0
  if [ -n "$git_error" ]; then
    while IFS= read -r line; do
      if [ "$line" = "fatal: not a git repository (or any of the parent directories): .git" ]; then
        not_repository=1
      fi
    done <<<"$git_error"
  fi
  if [ "$not_repository" -eq 1 ]; then
    echo "Error: Not a git repository" >&2
    exit 1
  fi
  if [ -n "$git_error" ]; then
    printf '%s\n' "$git_error" >&2
  fi
  exit "$git_status"
fi

message="${1-}"
if [ "$#" -lt 1 ] || [ -z "$message" ]; then
  echo "Usage: $0 \"commit message\" [files...]" >&2
  exit 1
fi
case "$message" in
  *[![:space:]]*) : ;;
  *)
    echo "Error: Commit message cannot be empty" >&2
    exit 1
    ;;
esac

shift
targets=("$@")
target_count=$#

if [ "$target_count" -gt 0 ]; then
  staged="$(git diff --cached --name-only)"
  staged_status=$?
  if [ "$staged_status" -ne 0 ]; then
    exit "$staged_status"
  fi

  extras=""
  while IFS= read -r staged_file; do
    [ -n "$staged_file" ] || continue
    matched=0
    for target in ${targets[@]+"${targets[@]}"}; do
      if [ "$staged_file" = "$target" ]; then
        matched=1
        break
      fi
      case "$staged_file" in
        "$target"/*)
          matched=1
          break
          ;;
      esac
    done
    if [ "$matched" -eq 0 ]; then
      extras="$extras$staged_file"$'\n'
    fi
  done <<<"$staged"

  if [ -n "$extras" ]; then
    echo "Error: Additional staged changes exist outside the requested files:" >&2
    while IFS= read -r extra; do
      if [ -n "$extra" ]; then
        printf '  %s\n' "$extra" >&2
      fi
    done <<<"$extras"
    echo "Tip: Unstage unrelated files or commit them separately before retrying." >&2
    exit 1
  fi

  if ! git add -- "${targets[@]}"; then
    exit 1
  fi
fi

git diff --cached --quiet
staged_changes_status=$?
if [ "$staged_changes_status" -eq 0 ]; then
  if [ "$target_count" -eq 0 ]; then
    echo "Error: No staged changes to commit" >&2
    echo "Tip: Stage files with 'git add' or pass files as arguments" >&2
  else
    echo "Error: No changes in specified files" >&2
    echo "Tip: Check if files exist and have modifications" >&2
  fi
  exit 1
fi
if [ "$staged_changes_status" -ne 1 ]; then
  exit "$staged_changes_status"
fi

if ! git commit -m "$message"; then
  exit 1
fi

echo "Committed successfully"
