#!/usr/bin/env bash
# git-push.sh - 안전한 푸시 (상태 확인 후)
# Usage: ./git-push.sh [--force]

set -euo pipefail

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi

# 현재 브랜치
BRANCH=$(git branch --show-current)

if [ -z "$BRANCH" ]; then
  echo "Error: Not on any branch (detached HEAD)"
  exit 1
fi

# Force push 처리
USE_FORCE=false
if [ "${1:-}" = "--force" ]; then
  # main/master 보호
  if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "ERROR: Cannot force push to $BRANCH"
    echo "This operation is too dangerous on protected branches"
    exit 1
  fi
  USE_FORCE=true
  echo "Warning: Force push enabled (with lease) to $BRANCH"
fi

# upstream 확인 및 push
if ! git rev-parse --abbrev-ref "@{upstream}" >/dev/null 2>&1; then
  echo "Setting upstream for branch: $BRANCH"
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

echo "Pushed to origin/$BRANCH"
