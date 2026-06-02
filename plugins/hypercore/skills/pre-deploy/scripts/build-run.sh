#!/usr/bin/env bash
# build-run.sh - Run build phase for detected stacks (node/rust/python)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DETECT="$SCRIPT_DIR/stack-detect.sh"
PM_DETECT="$SCRIPT_DIR/pm-detect.sh"

if [ ! -x "$STACK_DETECT" ]; then
  echo "Error: stack-detect.sh not found or not executable" >&2
  exit 1
fi

has_package_script() {
  local name="$1"
  if ! command -v node >/dev/null 2>&1; then
    return 1
  fi
  node -e "
    try {
      const p = require('./package.json');
      process.exit(p && p.scripts && p.scripts['$name'] ? 0 : 1);
    } catch {
      process.exit(1);
    }
  " >/dev/null 2>&1
}

resolve_py_bin() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
    return 0
  fi
  if command -v python >/dev/null 2>&1; then
    echo "python"
    return 0
  fi
  return 1
}

echo "=========================================="
echo "  Pre-Deploy Build Phase"
echo "=========================================="

STACKS="$($STACK_DETECT)"

while IFS= read -r stack; do
  case "$stack" in
    node)
      echo ""
      echo "=== [node] Build ==="
      PM="$($PM_DETECT)"
      if has_package_script build; then
        case "$PM" in
          bun) bun run build ;;
          pnpm) pnpm run build ;;
          yarn) yarn build ;;
          npm) npm run build ;;
          *) echo "Error: Unknown package manager: $PM" >&2; exit 1 ;;
        esac
        echo "✓ Node build completed"
      else
        echo "[node] No build script found in package.json. Skipping."
      fi
      ;;
    rust)
      echo ""
      echo "=== [rust] Build ==="
      if ! command -v cargo >/dev/null 2>&1; then
        echo "Error: cargo not found for Rust project" >&2
        exit 1
      fi
      cargo build --release
      echo "✓ Rust build completed"
      ;;
    python)
      echo ""
      echo "=== [python] Build ==="
      PY_BIN="$(resolve_py_bin || true)"
      if [ -z "$PY_BIN" ]; then
        echo "Error: python/python3 not found for Python project" >&2
        exit 1
      fi

      if command -v poetry >/dev/null 2>&1 && [ -f "poetry.lock" ]; then
        poetry build
        echo "✓ Python build completed (poetry)"
      elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        if "$PY_BIN" -m build --version >/dev/null 2>&1; then
          "$PY_BIN" -m build
          echo "✓ Python build completed (python -m build)"
        else
          echo "[python] build module not found. Running compile fallback."
          "$PY_BIN" -m compileall -q .
          echo "✓ Python compile fallback completed"
        fi
      else
        echo "[python] Packaging files not found. Running compile fallback."
        "$PY_BIN" -m compileall -q .
        echo "✓ Python compile fallback completed"
      fi
      ;;
    *)
      echo "Warning: Unknown stack '$stack'" >&2
      ;;
  esac
done <<< "$STACKS"

echo ""
echo "=========================================="
echo "  ✓ Build phase completed"
echo "=========================================="
