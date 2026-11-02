#!/usr/bin/env bash
# Extracts a semantic version from a version-bearing project file.
# Usage:
#   version-current.sh              # auto-pick the primary file
#   version-current.sh <file_path>  # parse the given file
# Output: <file>|<version>

set -euo pipefail

work=""
child_pid=""
discovered=""

cleanup() {
  if [ -n "$work" ]; then
    rm -rf "$work"
  fi
}

forward_signal() {
  local signal="$1"
  if [ -n "$child_pid" ]; then
    kill -s "$signal" "$child_pid" 2>/dev/null || true
    wait "$child_pid" 2>/dev/null || true
    child_pid=""
  fi
  case "$signal" in
    INT) exit 130 ;;
    TERM) exit 143 ;;
    *) exit 1 ;;
  esac
}

trap cleanup EXIT
trap 'forward_signal INT' INT
trap 'forward_signal TERM' TERM

discover() {
  local script_dir output error status=0 first
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  work="$(mktemp -d "${TMPDIR:-/tmp}/version-current.XXXXXX")"
  output="$work/stdout"
  error="$work/stderr"
  set -m
  bash "$script_dir/version-find.sh" --plain >"$output" 2>"$error" &
  child_pid=$!
  set +m
  wait "$child_pid" || status=$?
  child_pid=""
  if [ "$status" -ne 0 ]; then
    cat "$error" >&2
    echo "Error: Version discovery failed with exit code $status" >&2
    return 1
  fi
  first="$(sed -n '1p' "$output")"
  first="${first%$'\r'}"
  discovered="$first"
}

# sed passes: drop a trailing CR the way the JS line split does, then keep the
# first substituted line.
first_match() {
  sed -e 's/\r$//' "$1" | sed -nE "$2" | sed -n '1p'
}

extract_cargo() {
  local candidate
  candidate="$(awk '
    { bare = $0; sub(/\r$/, "", bare) }
    bare ~ /^\[package\][[:blank:]]*$/ { in_package = 1; next }
    bare ~ /^\[[^]]+\][[:blank:]]*$/ { if (bare != "[package]") in_package = 0; next }
    in_package && bare ~ /^[[:blank:]]*version[[:blank:]]*=.*"(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"/ {
      print bare
      exit
    }
  ' "$1")"
  if [ -z "$candidate" ]; then
    return 0
  fi
  printf '%s\n' "$candidate" |
    sed -E 's/.*"((0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*))".*/\1/'
}

extract_pyproject() {
  awk '
    { line = $0; sub(/\r$/, "", line) }
    line ~ /^\[[^]]+\][[:blank:]]*$/ { section = line; next }
    (section == "[project]" || section == "[tool.poetry]") && line ~ /^[[:blank:]]*version[[:blank:]]*=/ {
      value = line
      sub(/^[^=]*=/, "", value)
      gsub(/[[:blank:]"\047]/, "", value)
      if (value ~ /^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$/) {
        print value
        exit
      }
    }
  ' "$1"
}

file="${1-}"
if [ -z "$file" ]; then
  for candidate in package.json Cargo.toml pyproject.toml setup.py; do
    if [ -e "$candidate" ]; then
      file="$candidate"
      break
    fi
  done
  if [ -z "$file" ]; then
    discover
    file="$discovered"
  fi
fi

if [ -z "$file" ] || [ ! -e "$file" ]; then
  echo "Error: Could not determine a version file" >&2
  exit 1
fi

version=""
case "${file##*/}" in
  package.json)
    version="$(first_match "$file" 's/.*"version"[[:blank:]]*:[[:blank:]]*"((0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*))".*/\1/p')"
    ;;
  Cargo.toml)
    version="$(extract_cargo "$file")"
    ;;
  pyproject.toml)
    version="$(extract_pyproject "$file")"
    ;;
  setup.py)
    version="$(first_match "$file" "s/.*version[[:blank:]]*=[[:blank:]]*['\"]((0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*))['\"].*/\\1/p")"
    ;;
  *)
    case "$file" in
      *.py)
        version="$(first_match "$file" "s/^[[:blank:]]*__version__[[:blank:]]*=[[:blank:]]*['\"]((0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*))['\"].*/\\1/p")"
        ;;
    esac
    if [ -z "$version" ]; then
      version="$(first_match "$file" "s/.*\\.version\\(['\"]((0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*))['\"]\\).*/\\1/p")"
    fi
    ;;
esac

if ! [[ "$version" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
  echo "Error: Could not parse semantic version (x.y.z) from $file" >&2
  exit 1
fi

echo "$file|$version"
