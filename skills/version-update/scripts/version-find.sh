#!/usr/bin/env bash
# Discovers files that carry semantic versions below the current directory.
# Usage:
#   version-find.sh           # human-readable sections
#   version-find.sh --plain   # files only, one per line

set -euo pipefail

plain=0
if [ "${1-}" = "--plain" ]; then
  plain=1
fi

work="$(mktemp -d "${TMPDIR:-/tmp}/version-find.XXXXXX")"
trap 'rm -rf "$work"' EXIT

files="$work/files"
candidates="$work/candidates"
code_matches="$work/code-matches"
node_list="$work/node"
rust_list="$work/rust"
python_list="$work/python"
code_list="$work/code"
all_list="$work/all"
: >"$files"
: >"$candidates"
: >"$code_matches"
: >"$node_list"
: >"$rust_list"
: >"$python_list"
: >"$code_list"

# Walk once, pruning the same directory names the Node implementation skips.
if ! find . -mindepth 1 \
  \( -type d \( -name .git -o -name node_modules -o -name target -o -name .venv -o -name venv -o -name .tox -o -name dist -o -name build \) -prune \) \
  -o -type f -print0 >"$files" 2>"$work/find.err"; then
  sed -e 's/^find: /Error: Failed to read directory: /' "$work/find.err" >&2
  exit 1
fi

is_text_or_code_extension() {
  case "$1" in
    .c | .cc | .cpp | .cs | .css | .go | .h | .hpp | .java | .js | .json | .jsx | .kt | .kts | \
      .mjs | .mts | .php | .py | .rb | .rs | .scala | .sh | .toml | .ts | .tsx | .txt | .yaml | .yml)
      return 0
      ;;
    *) return 1 ;;
  esac
}

# The inline patterns only accept canonical semver segments.
version_pattern="\\.version\\(['\"](0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)['\"]\\)|__version__[[:space:]]*=[[:space:]]*['\"](0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)['\"]"

while IFS= read -r -d '' raw; do
  rel="${raw#./}"
  base="${rel##*/}"

  case "$base" in
    package.json) printf '%s\n' "$rel" >>"$node_list" ;;
    Cargo.toml) printf '%s\n' "$rel" >>"$rust_list" ;;
    pyproject.toml | setup.py | *__init__.py | *_version.py)
      printf '%s\n' "$rel" >>"$python_list"
      ;;
  esac

  # Mirrors extname() from node:path without forking per file.
  case "$base" in
    . | ..) ext="" ;;
    .*)
      rest="${base#.}"
      case "$rest" in
        *.*) ext=".${rest##*.}" ;;
        *) ext="" ;;
      esac
      ;;
    *.*) ext=".${base##*.}" ;;
    *) ext="" ;;
  esac
  if is_text_or_code_extension "$ext"; then
    printf '%s\0' "$raw" >>"$candidates"
  fi
done <"$files"

# Scan the candidates in argument-order batches: grep -l emits matches in the
# order the paths are given, so the traversal order of the Node version holds.
batch=()
scan_batch() {
  if [ "${#batch[@]}" -eq 0 ]; then
    return 0
  fi
  local status=0 detail
  LC_ALL=C grep -lE -e "$version_pattern" ${batch[@]+"${batch[@]}"} >>"$code_matches" 2>"$work/grep.err" || status=$?
  batch=()
  if [ "$status" -gt 1 ]; then
    detail="$(sed -n '1p' "$work/grep.err")"
    detail="${detail#grep: }"
    printf 'Error: Failed to read file: %s\n' "${detail:-read error}" >&2
    exit 1
  fi
}

while IFS= read -r -d '' candidate; do
  batch+=("$candidate")
  if [ "${#batch[@]}" -ge 256 ]; then
    scan_batch
  fi
done <"$candidates"
scan_batch

while IFS= read -r match; do
  if [ -n "$match" ]; then
    printf '%s\n' "${match#./}" >>"$code_list"
  fi
done <"$code_matches"

LC_ALL=C sort -u "$node_list" "$rust_list" "$python_list" "$code_list" >"$all_list"

if [ "$plain" -eq 1 ]; then
  cat "$all_list"
  exit 0
fi

section() {
  printf '%s\n' "$1"
  if [ -s "$2" ]; then
    cat "$2"
  else
    printf '(none found)\n'
  fi
}

echo "=== Searching version files ==="
echo ""
section "=== Node version files ===" "$node_list"
echo ""
section "=== Rust version files ===" "$rust_list"
echo ""
section "=== Python version files ===" "$python_list"
echo ""
section "=== Code files with inline version patterns ===" "$code_list"
echo ""
section "=== All version files ===" "$all_list"
