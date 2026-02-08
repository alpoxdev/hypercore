#!/usr/bin/env bash
# lint-check.sh - tsc + eslint 병렬 실행
# Usage: ./lint-check.sh
# 두 검사를 병렬로 실행하고 결과를 수집

set -uo pipefail

# 임시 파일
TSC_OUT=$(mktemp)
ESLINT_OUT=$(mktemp)
TSC_EXIT=0
ESLINT_EXIT=0

# Cleanup (ERR, INT, TERM도 처리)
trap "rm -f $TSC_OUT $ESLINT_OUT" EXIT ERR INT TERM

echo "=== Running TypeScript + ESLint in parallel ==="

# 병렬 실행
(npx tsc --noEmit > "$TSC_OUT" 2>&1) &
TSC_PID=$!

(npx eslint . > "$ESLINT_OUT" 2>&1) &
ESLINT_PID=$!

# 대기
wait $TSC_PID || TSC_EXIT=$?
wait $ESLINT_PID || ESLINT_EXIT=$?

# 결과 출력
echo ""
echo "=== TypeScript Results ==="
if [ $TSC_EXIT -eq 0 ]; then
  echo "✓ No type errors"
else
  cat "$TSC_OUT"
fi

echo ""
echo "=== ESLint Results ==="
if [ $ESLINT_EXIT -eq 0 ]; then
  echo "✓ No lint errors"
else
  cat "$ESLINT_OUT"
fi

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
