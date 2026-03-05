#!/usr/bin/env bash
# git-commit.sh - 커밋 실행
# Usage: ./git-commit.sh "커밋 메시지" [files...]
# files 미지정 시 staged files만 커밋

set -euo pipefail

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 \"commit message\" [files...]"
  echo "  files: 커밋할 파일들 (미지정 시 staged files만)"
  exit 1
fi

COMMIT_MSG="$1"

# 빈 메시지 체크
if [ -z "$(echo "$COMMIT_MSG" | xargs)" ]; then
  echo "Error: Commit message cannot be empty" >&2
  exit 1
fi

shift
FILES_PROVIDED=$#

# 파일 지정된 경우 add
if [ $FILES_PROVIDED -gt 0 ]; then
  git add "$@"
fi

# staged 파일 확인
if git diff --cached --quiet; then
  if [ $FILES_PROVIDED -eq 0 ]; then
    echo "Error: No staged changes to commit"
    echo "Tip: Stage files with 'git add' or pass files as arguments"
  else
    echo "Error: No changes in specified files"
    echo "Tip: Check if files exist and have modifications"
  fi
  exit 1
fi

# 커밋
git commit -m "$COMMIT_MSG"

echo "Committed successfully"
