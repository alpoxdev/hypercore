#!/usr/bin/env bash
# deploy-check.sh - Full pre-deploy checks for node/rust/python

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Pre-Deploy Verification"
echo "=========================================="

if [ ! -x "$SCRIPT_DIR/lint-check.sh" ]; then
  echo "Error: lint-check.sh not found or not executable" >&2
  exit 1
fi
if [ ! -x "$SCRIPT_DIR/build-run.sh" ]; then
  echo "Error: build-run.sh not found or not executable" >&2
  exit 1
fi
if [ ! -x "$SCRIPT_DIR/stack-detect.sh" ]; then
  echo "Error: stack-detect.sh not found or not executable" >&2
  exit 1
fi

# Step 1: Quality checks

echo ""
echo "[1/2] Running quality checks..."
"$SCRIPT_DIR/lint-check.sh"

# Step 2: Build

echo ""
echo "[2/2] Running build phase..."
"$SCRIPT_DIR/build-run.sh"

echo ""
echo "=========================================="
echo "  ✓ All checks passed - Ready to deploy"
echo "=========================================="
