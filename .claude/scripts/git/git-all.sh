#!/usr/bin/env bash
# git-all.sh - 모든 변경사항 add + commit + push (단순 케이스)
# Usage: ./git-all.sh "커밋 메시지"
# WARNING: git add -A 사용 - 민감 파일(.env 등) 포함 주의

set -euo pipefail

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 \"commit message\""
  exit 1
fi

COMMIT_MSG="$1"

# 빈 메시지 체크
if [ -z "$(echo "$COMMIT_MSG" | xargs)" ]; then
  echo "Error: Commit message cannot be empty" >&2
  exit 1
fi

# 변경사항 확인
if [ -n "$(git status --porcelain)" ]; then
  # 민감 파일 검증
  SENSITIVE=$(git status --porcelain | grep -E '^\?\?.*\.(env|pem|key|secret|credentials)' || true)
  if [ -n "$SENSITIVE" ]; then
    echo "ERROR: Sensitive files detected:" >&2
    echo "$SENSITIVE" >&2
    echo "" >&2
    echo "Please use git-commit.sh with specific files instead" >&2
    exit 1
  fi

  echo "=== Adding all changes ==="
  git add -A

  echo "=== Committing ==="
  git commit -m "$COMMIT_MSG"

  echo "=== Pushing ==="
  BRANCH=$(git branch --show-current)
  if ! git rev-parse --abbrev-ref "@{upstream}" >/dev/null 2>&1; then
    git push -u origin "$BRANCH"
  else
    git push
  fi

  echo "Done: All changes committed and pushed"
else
  echo "No changes to commit"
  exit 0
fi
