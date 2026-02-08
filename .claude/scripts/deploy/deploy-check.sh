#!/usr/bin/env bash
# deploy-check.sh - 배포 전 전체 검증 (tsc + eslint + build)
# Usage: ./deploy-check.sh
# 검사 실패 시 조기 종료

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINT_DIR="$SCRIPT_DIR/../lint"

echo "=========================================="
echo "  Pre-Deploy Verification"
echo "=========================================="

# 스크립트 존재 검증
if [ ! -x "$LINT_DIR/lint-check.sh" ]; then
  echo "Error: lint-check.sh not found or not executable" >&2
  exit 1
fi
if [ ! -x "$SCRIPT_DIR/build-run.sh" ]; then
  echo "Error: build-run.sh not found or not executable" >&2
  exit 1
fi

# Step 1: Lint 검사 (tsc + eslint 병렬)
echo ""
echo "[1/2] Running lint checks..."
"$LINT_DIR/lint-check.sh"

# Step 2: Build
echo ""
echo "[2/2] Running build..."
"$SCRIPT_DIR/build-run.sh"

echo ""
echo "=========================================="
echo "  ✓ All checks passed - Ready to deploy"
echo "=========================================="
