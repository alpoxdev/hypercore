#!/usr/bin/env bash
# version-current.sh - Extract current project version
# Usage:
#   ./version-current.sh              # auto-pick primary file
#   ./version-current.sh <file_path>  # parse specific file
# Output: <file>|<version>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIND_SCRIPT="$SCRIPT_DIR/version-find.sh"

extract_from_package_json() {
  sed -nE 's/.*"version"[[:space:]]*:[[:space:]]*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/p' "$1" | head -n1
}

extract_from_cargo_toml() {
  awk '
    BEGIN { in_package=0 }
    /^\[package\][[:space:]]*$/ { in_package=1; next }
    /^\[[^]]+\][[:space:]]*$/ { if ($0 != "[package]") in_package=0 }
    in_package && $0 ~ /^[[:space:]]*version[[:space:]]*=/ {
      if (match($0, /"[0-9]+\.[0-9]+\.[0-9]+"/)) {
        v=substr($0, RSTART+1, RLENGTH-2)
        print v
        exit
      }
    }
  ' "$1"
}

extract_from_pyproject() {
  awk '
    BEGIN { section="" }
    /^\[[^]]+\][[:space:]]*$/ {
      section=$0
      next
    }
    (section=="[project]" || section=="[tool.poetry]") && $0 ~ /^[[:space:]]*version[[:space:]]*=/ {
      line=$0
      sub(/^[^=]*=/, "", line)
      gsub(/[[:space:]"'"'"']/, "", line)
      if (line ~ /^[0-9]+\.[0-9]+\.[0-9]+$/) {
        print line
        exit
      }
    }
  ' "$1"
}

extract_from_setup_py() {
  sed -nE "s/.*version[[:space:]]*=[[:space:]]*['\"]([0-9]+\.[0-9]+\.[0-9]+)['\"].*/\1/p" "$1" | head -n1
}

extract_from_py_file() {
  sed -nE "s/^[[:space:]]*__version__[[:space:]]*=[[:space:]]*['\"]([0-9]+\.[0-9]+\.[0-9]+)['\"].*/\1/p" "$1" | head -n1
}

extract_from_code() {
  sed -nE "s/.*\\.version\\(['\"]([0-9]+\.[0-9]+\.[0-9]+)['\"]\\).*/\1/p" "$1" | head -n1
}

pick_primary_file() {
  if [ -f package.json ]; then
    echo "package.json"
    return
  fi
  if [ -f Cargo.toml ]; then
    echo "Cargo.toml"
    return
  fi
  if [ -f pyproject.toml ]; then
    echo "pyproject.toml"
    return
  fi
  if [ -f setup.py ]; then
    echo "setup.py"
    return
  fi
  "$FIND_SCRIPT" --plain | head -n1
}

FILE="${1:-}"
if [ -z "$FILE" ]; then
  FILE="$(pick_primary_file)"
fi

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Error: Could not determine a version file" >&2
  exit 1
fi

VERSION=""
base="$(basename "$FILE")"

case "$base" in
  package.json)
    VERSION="$(extract_from_package_json "$FILE")"
    ;;
  Cargo.toml)
    VERSION="$(extract_from_cargo_toml "$FILE")"
    ;;
  pyproject.toml)
    VERSION="$(extract_from_pyproject "$FILE")"
    ;;
  setup.py)
    VERSION="$(extract_from_setup_py "$FILE")"
    ;;
  *)
    if [[ "$FILE" == *.py ]]; then
      VERSION="$(extract_from_py_file "$FILE")"
      if [ -z "$VERSION" ]; then
        VERSION="$(extract_from_code "$FILE")"
      fi
    else
      VERSION="$(extract_from_code "$FILE")"
    fi
    ;;
esac

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Could not parse semantic version (x.y.z) from $FILE" >&2
  exit 1
fi

echo "$FILE|$VERSION"
