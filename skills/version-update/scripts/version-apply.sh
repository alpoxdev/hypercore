#!/usr/bin/env bash
# version-apply.sh - Apply target version to discovered files
# Usage:
#   ./version-apply.sh <new_version> [files...]
# If files are omitted, uses version-find.sh --plain

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <new_version> [files...]" >&2
  exit 1
fi

NEW_VERSION="$1"
shift

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format: $NEW_VERSION (expected x.y.z)" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIND_SCRIPT="$SCRIPT_DIR/version-find.sh"

update_package_json() {
  local file="$1"
  awk -v v="$NEW_VERSION" '
    BEGIN { done=0 }
    {
      if (!done && $0 ~ /"version"[[:space:]]*:/) {
        gsub(/"[0-9]+\.[0-9]+\.[0-9]+"/, "\"" v "\"")
        done=1
      }
      print
    }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

update_cargo_toml() {
  local file="$1"
  awk -v v="$NEW_VERSION" '
    BEGIN { in_package=0 }
    /^\[package\][[:space:]]*$/ { in_package=1; print; next }
    /^\[[^]]+\][[:space:]]*$/ {
      if ($0 != "[package]") in_package=0
      print
      next
    }
    {
      if (in_package && $0 ~ /^[[:space:]]*version[[:space:]]*=/) {
        sub(/"[0-9]+\.[0-9]+\.[0-9]+"/, "\"" v "\"")
      }
      print
    }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

update_pyproject_toml() {
  local file="$1"
  awk -v v="$NEW_VERSION" '
    BEGIN { section="" }
    /^\[[^]]+\][[:space:]]*$/ {
      section=$0
      print
      next
    }
    {
      if ((section=="[project]" || section=="[tool.poetry]") && $0 ~ /^[[:space:]]*version[[:space:]]*=/) {
        sub(/"[0-9]+\.[0-9]+\.[0-9]+"/, "\"" v "\"")
        sub(/\x27[0-9]+\.[0-9]+\.[0-9]+\x27/, "\x27" v "\x27")
      }
      print
    }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

update_setup_py() {
  local file="$1"
  sed -E "s/(version[[:space:]]*=[[:space:]]*['\"])[0-9]+\.[0-9]+\.[0-9]+(['\"])/\\1$NEW_VERSION\\2/g" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

update_python_version_var() {
  local file="$1"
  sed -E "s/^([[:space:]]*__version__[[:space:]]*=[[:space:]]*['\"])[0-9]+\.[0-9]+\.[0-9]+(['\"].*)$/\\1$NEW_VERSION\\2/" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

update_code_pattern() {
  local file="$1"
  sed -E "s/(\\.version\\(['\"])[0-9]+\.[0-9]+\.[0-9]+(['\"]\\))/\\1$NEW_VERSION\\2/g" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

FILES=()
if [ $# -gt 0 ]; then
  FILES=("$@")
else
  while IFS= read -r f; do
    [ -n "$f" ] && FILES+=("$f")
  done < <("$FIND_SCRIPT" --plain)
fi

if [ ${#FILES[@]} -eq 0 ]; then
  echo "Error: No version files found" >&2
  exit 1
fi

UPDATED=0
for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "[skip] not found: $file" >&2
    continue
  fi

  base="$(basename "$file")"
  case "$base" in
    package.json)
      update_package_json "$file"
      ;;
    Cargo.toml)
      update_cargo_toml "$file"
      ;;
    pyproject.toml)
      update_pyproject_toml "$file"
      ;;
    setup.py)
      update_setup_py "$file"
      ;;
    *)
      if [[ "$file" == *.py ]]; then
        update_python_version_var "$file"
      fi
      update_code_pattern "$file"
      ;;
  esac

  echo "[updated] $file"
  UPDATED=$((UPDATED + 1))
done

echo "Applied version $NEW_VERSION to $UPDATED file(s)."
