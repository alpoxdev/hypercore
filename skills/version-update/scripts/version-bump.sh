#!/usr/bin/env bash
# Calculates the next semantic version for a requested bump.
# Usage: version-bump.sh <current_version> <bump_type>
# bump_type: +1, +minor, +major, or an explicit x.y.z

set -euo pipefail

if [ "$#" -lt 2 ] || [ -z "${1-}" ] || [ -z "${2-}" ]; then
  echo "Usage: $0 <current_version> <bump_type>"
  echo "bump_type: +1, +minor, +major, or x.x.x"
  exit 1
fi

current="$1"
bump="$2"

if ! [[ "$current" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format: $current" >&2
  echo "Expected: x.x.x (e.g., 1.2.3)" >&2
  exit 1
fi

# Leading zeros are decimal here, never octal.
IFS='.' read -r major minor patch <<<"$current"
major=$((10#$major))
minor=$((10#$minor))
patch=$((10#$patch))

case "$bump" in
  +1 | +patch) next="$major.$minor.$((patch + 1))" ;;
  +minor) next="$major.$((minor + 1)).0" ;;
  +major) next="$((major + 1)).0.0" ;;
  *)
    if ! [[ "$bump" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Error: Invalid bump type: $bump"
      echo "Use: +1, +minor, +major, or x.x.x"
      exit 1
    fi
    next="$bump"
    ;;
esac

echo "$next"
