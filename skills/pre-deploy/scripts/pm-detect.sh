#!/usr/bin/env bash
# pm-detect.sh - Package manager 자동 감지
# Usage: ./pm-detect.sh
# Output: npm | yarn | pnpm | bun
# Exit 1 if no lock file found

set -euo pipefail

# Lock 파일 기반 감지
if [ -f "bun.lockb" ]; then
  echo "bun"
elif [ -f "pnpm-lock.yaml" ]; then
  echo "pnpm"
elif [ -f "yarn.lock" ]; then
  echo "yarn"
elif [ -f "package-lock.json" ]; then
  echo "npm"
elif [ -f "package.json" ]; then
  # Lock 파일 없으면 기본 npm
  echo "Warning: No lock file found, defaulting to npm" >&2
  echo "npm"
else
  echo "Error: No package.json found" >&2
  exit 1
fi
