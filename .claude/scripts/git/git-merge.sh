#!/usr/bin/env bash
# git-merge.sh - 타겟 브랜치에 소스 브랜치를 merge 후 push
# Usage: ./git-merge.sh <target-branch> <source-branch>
# Example: ./git-merge.sh deploy/prod dev

set -euo pipefail

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi

if [ $# -lt 2 ]; then
  echo "Usage: $0 <target-branch> <source-branch>"
  echo "Example: $0 deploy/prod dev"
  exit 1
fi

TARGET="$1"
SOURCE="$2"
ORIGINAL_BRANCH=$(git branch --show-current)

# Working directory clean 확인
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: Working directory is not clean. Commit or stash changes first."
  exit 1
fi

# 소스 브랜치 존재 확인
if ! git rev-parse --verify "$SOURCE" >/dev/null 2>&1; then
  echo "Error: Source branch '$SOURCE' does not exist"
  exit 1
fi

# 타겟 브랜치 존재 확인
if ! git rev-parse --verify "$TARGET" >/dev/null 2>&1; then
  echo "Error: Target branch '$TARGET' does not exist"
  exit 1
fi

echo "=== Merging '$SOURCE' into '$TARGET' ==="

# remote 최신화
echo "--- Fetching origin ---"
git fetch origin

# 타겟 브랜치로 전환
echo "--- Checkout '$TARGET' ---"
git checkout "$TARGET"

# 타겟 브랜치 최신화
echo "--- Pulling latest '$TARGET' ---"
git pull origin "$TARGET" --ff-only || git pull origin "$TARGET"

# 머지 실행
echo "--- Merging '$SOURCE' into '$TARGET' ---"
if ! git merge "$SOURCE" --no-edit; then
  echo "Error: Merge conflict detected. Resolve manually."
  echo "You are now on '$TARGET' branch."
  exit 1
fi

# 푸시
echo "--- Pushing '$TARGET' ---"
git push origin "$TARGET"

# 원래 브랜치로 복귀
echo "--- Returning to '$ORIGINAL_BRANCH' ---"
git checkout "$ORIGINAL_BRANCH"

echo ""
echo "Done: Merged '$SOURCE' into '$TARGET' and pushed."
