#!/usr/bin/env bash
# version-bump.sh - 버전 계산
# Usage: ./version-bump.sh <current_version> <bump_type>
# bump_type: +1 (patch), +minor, +major, or direct version (x.x.x)
# Example: ./version-bump.sh 1.2.3 +1      → 1.2.4
#          ./version-bump.sh 1.2.3 +minor  → 1.3.0
#          ./version-bump.sh 1.2.3 +major  → 2.0.0
#          ./version-bump.sh 1.2.3 2.0.0   → 2.0.0

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <current_version> <bump_type>"
  echo "bump_type: +1, +minor, +major, or x.x.x"
  exit 1
fi

CURRENT="$1"
BUMP="$2"

# 버전 형식 먼저 검증
if ! [[ "$CURRENT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format: $CURRENT" >&2
  echo "Expected: x.x.x (e.g., 1.2.3)" >&2
  exit 1
fi

# 버전 파싱
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

# 새 버전 계산
case "$BUMP" in
  +1|+patch)
    NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
    ;;
  +minor)
    NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
    ;;
  +major)
    NEW_VERSION="$((MAJOR + 1)).0.0"
    ;;
  *)
    # 직접 버전 지정 검증
    if [[ "$BUMP" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      NEW_VERSION="$BUMP"
    else
      echo "Error: Invalid bump type: $BUMP"
      echo "Use: +1, +minor, +major, or x.x.x"
      exit 1
    fi
    ;;
esac

echo "$NEW_VERSION"
