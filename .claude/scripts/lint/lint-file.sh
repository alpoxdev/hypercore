#!/usr/bin/env bash
# lint-file.sh - 특정 파일/디렉토리만 검사
# Usage: ./lint-file.sh <file|directory> [file2...]
# Example: ./lint-file.sh src/utils/api.ts
#          ./lint-file.sh src/components/

set -uo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 <file|directory> [file2...]"
  echo "Example: $0 src/utils/api.ts"
  exit 1
fi

TSC_EXIT=0
ESLINT_EXIT=0

echo "=== Checking: $@ ==="

# TypeScript 검사 (전체 프로젝트 - tsc는 개별 파일 검사 미지원)
echo ""
echo "=== TypeScript ==="
echo "(Note: tsc checks entire project)"
npx tsc --noEmit || TSC_EXIT=$?

# ESLint 검사
echo ""
echo "=== ESLint ==="
npx eslint "$@" || ESLINT_EXIT=$?

# 결과
echo ""
echo "=== Summary ==="
if [ $TSC_EXIT -eq 0 ] && [ $ESLINT_EXIT -eq 0 ]; then
  echo "✓ All checks passed"
  exit 0
else
  [ $TSC_EXIT -ne 0 ] && echo "✗ TypeScript: FAILED"
  [ $ESLINT_EXIT -ne 0 ] && echo "✗ ESLint: FAILED"
  exit 1
fi
