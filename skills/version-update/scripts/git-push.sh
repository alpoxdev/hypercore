#!/usr/bin/env bash
# Directly pushes the current branch after an explicit user request.
# Usage: git-push.sh [--force]
#
# errexit is intentionally off: git probes use their exit status as data, so
# every call is checked explicitly.

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

trim_end() {
  local value="$1"
  while [ -n "$value" ] && [ "$value" != "${value%[[:space:]]}" ]; do
    value="${value%[[:space:]]}"
  done
  printf '%s' "$value"
}

if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && [ "${1-}" != "--force" ]; }; then
  echo "Usage: $0 [--force]" >&2
  exit 2
fi

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

branch_result="$(git branch --show-current)"
branch_status=$?
if [ "$branch_status" -ne 0 ]; then
  exit "$branch_status"
fi
branch="$(trim_end "$branch_result")"
if [ -z "$branch" ]; then
  echo "Error: Not on any branch (detached HEAD)" >&2
  exit 1
fi

force=0
if [ "${1-}" = "--force" ]; then
  force=1
fi
if [ "$force" -eq 1 ] && { [ "$branch" = "main" ] || [ "$branch" = "master" ]; }; then
  echo "ERROR: Cannot force push to $branch" >&2
  echo "This operation is too dangerous on protected branches" >&2
  exit 1
fi
if [ "$force" -eq 1 ]; then
  echo "Warning: Force push enabled (with lease) to $branch"
fi

upstream_result="$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch")"
upstream_status=$?
if [ "$upstream_status" -ne 0 ]; then
  exit "$upstream_status"
fi
upstream="$(trim_end "$upstream_result")"

if [ -z "$upstream" ]; then
  echo "Setting upstream for branch: $branch"
  if [ "$force" -eq 1 ]; then
    if ! git push -u origin "$branch" --force-with-lease; then
      exit 1
    fi
  else
    if ! git push -u origin "$branch"; then
      exit 1
    fi
  fi
else
  if [ "$force" -eq 1 ]; then
    if ! git push --force-with-lease; then
      exit 1
    fi
  else
    if ! git push; then
      exit 1
    fi
  fi
fi

echo "Pushed to origin/$branch"
