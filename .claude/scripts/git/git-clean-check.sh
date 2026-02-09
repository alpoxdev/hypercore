#!/usr/bin/env bash
# git-clean-check.sh - Working directory clean 여부 확인
# Usage: ./git-clean-check.sh [--quiet]
# Exit 0: clean, Exit 1: dirty

set -uo pipefail

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi

QUIET=false
if [ "${1:-}" = "--quiet" ]; then
  QUIET=true
fi

if [ -n "$(git status --porcelain)" ]; then
  if [ "$QUIET" = false ]; then
    echo "Working directory is DIRTY"
    echo ""
    git status --short
  fi
  exit 1
else
  if [ "$QUIET" = false ]; then
    echo "Working directory is CLEAN"
  fi
  exit 0
fi
