#!/usr/bin/env bash
# build-run.sh - Package manager 감지 후 build 실행
# Usage: ./build-run.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PM_DIR="$SCRIPT_DIR/../pm"

# Package manager 감지
PM=$("$PM_DIR/pm-detect.sh")

echo "=== Building with $PM ==="

# Build 실행
case "$PM" in
  bun)
    bun run build
    ;;
  pnpm)
    pnpm run build
    ;;
  yarn)
    yarn build
    ;;
  npm)
    npm run build
    ;;
  *)
    echo "Error: Unknown package manager: $PM" >&2
    exit 1
    ;;
esac

echo ""
echo "✓ Build completed successfully"
