#!/usr/bin/env bash
# git-info.sh - Git 상태 및 diff 요약 출력
# 에이전트가 분석할 정보를 빠르게 수집

set -euo pipefail

# Git 저장소 확인
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository"
  exit 1
fi

echo "=== Git Status ==="
if [ -n "$(git status --porcelain)" ]; then
  git status --short
else
  echo "(clean)"
fi

echo ""
echo "=== Changed Files ==="
git diff --stat

echo ""
echo "=== Staged Files ==="
git diff --cached --stat

echo ""
echo "=== Recent Commits (5) ==="
git log --oneline -5

echo ""
echo "=== Current Branch ==="
git branch --show-current
