#!/usr/bin/env bash
# pm-run.sh - 감지된 package manager로 스크립트 실행
# Usage: ./pm-run.sh <script> [args...]
# Example: ./pm-run.sh build
#          ./pm-run.sh test --watch

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -eq 0 ] || [ -z "${1:-}" ]; then
  echo "Usage: $0 <script> [args...]"
  echo "Example: $0 build"
  exit 1
fi

SCRIPT="$1"
shift

# Package manager 감지
PM=$("$SCRIPT_DIR/pm-detect.sh")

# 실행
case "$PM" in
  bun)
    bun run "$SCRIPT" "$@"
    ;;
  pnpm)
    pnpm run "$SCRIPT" "$@"
    ;;
  yarn)
    yarn "$SCRIPT" "$@"
    ;;
  npm)
    npm run "$SCRIPT" "$@"
    ;;
  *)
    echo "Error: Unknown package manager: $PM" >&2
    exit 1
    ;;
esac
