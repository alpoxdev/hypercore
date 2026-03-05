#!/usr/bin/env bash
# version-find.sh - Discover version-bearing files for node/rust/python
# Usage:
#   ./version-find.sh         # human-readable output
#   ./version-find.sh --plain # files only (one per line)

set -euo pipefail

PLAIN=false
if [ "${1:-}" = "--plain" ]; then
  PLAIN=true
fi

ROOT="$(pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

NODE_OUT="$TMP_DIR/node.txt"
RUST_OUT="$TMP_DIR/rust.txt"
PY_OUT="$TMP_DIR/python.txt"
CODE_OUT="$TMP_DIR/code.txt"
ALL_OUT="$TMP_DIR/all.txt"

# Initialize files to avoid cat failures when no matches exist
: > "$NODE_OUT"
: > "$RUST_OUT"
: > "$PY_OUT"
: > "$CODE_OUT"
: > "$ALL_OUT"

# Node
find "$ROOT" -type f -name package.json -not -path '*/node_modules/*' | sed "s#^$ROOT/##" > "$NODE_OUT" || true

# Rust
find "$ROOT" -type f -name Cargo.toml -not -path '*/target/*' | sed "s#^$ROOT/##" > "$RUST_OUT" || true

# Python
find "$ROOT" -type f \( -name pyproject.toml -o -name setup.py -o -name "*__init__.py" -o -name "*_version.py" \) \
  -not -path '*/.venv/*' -not -path '*/venv/*' -not -path '*/.tox/*' \
  | sed "s#^$ROOT/##" > "$PY_OUT" || true

# Common code version patterns
if command -v rg >/dev/null 2>&1; then
  rg -l --hidden --glob '!node_modules/**' --glob '!.git/**' --glob '!.venv/**' --glob '!venv/**' \
    "\\.version\\(['\"][0-9]+\\.[0-9]+\\.[0-9]+['\"]\\)|__version__\\s*=\\s*['\"][0-9]+\\.[0-9]+\\.[0-9]+['\"]" . \
    | sed 's#^\./##' > "$CODE_OUT" || true
else
  find "$ROOT" -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rs" \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/.venv/*' -not -path '*/venv/*' \
    -exec grep -El "\\.version\\(['\"][0-9]+\\.[0-9]+\\.[0-9]+['\"]\\)|__version__\\s*=\\s*['\"][0-9]+\\.[0-9]+\\.[0-9]+['\"]" {} + \
    | sed "s#^$ROOT/##" > "$CODE_OUT" || true
fi

cat "$NODE_OUT" "$RUST_OUT" "$PY_OUT" "$CODE_OUT" 2>/dev/null | sed '/^$/d' | sort -u > "$ALL_OUT"

if [ "$PLAIN" = true ]; then
  cat "$ALL_OUT"
  exit 0
fi

echo "=== Searching version files ==="
echo ""
echo "=== Node version files ==="
if [ -s "$NODE_OUT" ]; then cat "$NODE_OUT"; else echo "(none found)"; fi

echo ""
echo "=== Rust version files ==="
if [ -s "$RUST_OUT" ]; then cat "$RUST_OUT"; else echo "(none found)"; fi

echo ""
echo "=== Python version files ==="
if [ -s "$PY_OUT" ]; then cat "$PY_OUT"; else echo "(none found)"; fi

echo ""
echo "=== Code files with inline version patterns ==="
if [ -s "$CODE_OUT" ]; then cat "$CODE_OUT"; else echo "(none found)"; fi

echo ""
echo "=== All version files ==="
if [ -s "$ALL_OUT" ]; then cat "$ALL_OUT"; else echo "(none found)"; fi
