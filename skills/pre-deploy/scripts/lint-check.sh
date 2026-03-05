#!/usr/bin/env bash
# lint-check.sh - Run quality checks for detected stacks (node/rust/python)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DETECT="$SCRIPT_DIR/stack-detect.sh"
PM_DETECT="$SCRIPT_DIR/pm-detect.sh"

if [ ! -x "$STACK_DETECT" ]; then
  echo "Error: stack-detect.sh not found or not executable" >&2
  exit 1
fi

resolve_py_tool() {
  local tool="$1"
  if [ -x ".venv/bin/$tool" ]; then
    echo ".venv/bin/$tool"
    return 0
  fi
  if command -v "$tool" >/dev/null 2>&1; then
    echo "$tool"
    return 0
  fi
  return 1
}

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

run_node_checks() {
  local pm
  local tsc_out eslint_out
  local tsc_pid=0 eslint_pid=0
  local tsc_exit=0 eslint_exit=0
  local has_any=0

  if [ ! -x "$PM_DETECT" ]; then
    echo "Error: pm-detect.sh not found or not executable" >&2
    return 1
  fi

  pm="$($PM_DETECT)"
  tsc_out="$(mktemp)"
  eslint_out="$(mktemp)"

  echo ""
  echo "=== [node] Running checks ==="

  if [ -f "tsconfig.json" ]; then
    has_any=1
    if has_package_script typecheck; then
      (
        case "$pm" in
          bun) bun run typecheck ;;
          pnpm) pnpm run typecheck ;;
          yarn) yarn typecheck ;;
          npm) npm run typecheck ;;
          *) npx tsc --noEmit ;;
        esac
      ) >"$tsc_out" 2>&1 &
    else
      (npx tsc --noEmit) >"$tsc_out" 2>&1 &
    fi
    tsc_pid=$!
  fi

  if has_package_script lint; then
    has_any=1
    (
      case "$pm" in
        bun) bun run lint ;;
        pnpm) pnpm run lint ;;
        yarn) yarn lint ;;
        npm) npm run lint ;;
        *) npx eslint . ;;
      esac
    ) >"$eslint_out" 2>&1 &
    eslint_pid=$!
  elif [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ] || [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.cjs" ] || [ -f ".eslintrc.json" ]; then
    has_any=1
    (npx eslint .) >"$eslint_out" 2>&1 &
    eslint_pid=$!
  fi

  if [ "$has_any" -eq 0 ]; then
    echo "[node] No typecheck/lint configuration found. Skipping."
    rm -f "$tsc_out" "$eslint_out"
    return 0
  fi

  if [ "$tsc_pid" -ne 0 ]; then
    wait "$tsc_pid" || tsc_exit=$?
    echo ""
    echo "--- [node] Typecheck ---"
    if [ "$tsc_exit" -eq 0 ]; then
      echo "✓ Typecheck passed"
    else
      cat "$tsc_out"
    fi
  else
    echo ""
    echo "--- [node] Typecheck ---"
    echo "(skipped: no tsconfig.json)"
  fi

  if [ "$eslint_pid" -ne 0 ]; then
    wait "$eslint_pid" || eslint_exit=$?
    echo ""
    echo "--- [node] Lint ---"
    if [ "$eslint_exit" -eq 0 ]; then
      echo "✓ Lint passed"
    else
      cat "$eslint_out"
    fi
  else
    echo ""
    echo "--- [node] Lint ---"
    echo "(skipped: no lint configuration)"
  fi

  rm -f "$tsc_out" "$eslint_out"

  if [ "$tsc_exit" -ne 0 ] || [ "$eslint_exit" -ne 0 ]; then
    return 1
  fi
  return 0
}

run_rust_checks() {
  local exit_code=0

  echo ""
  echo "=== [rust] Running checks ==="

  if ! command -v cargo >/dev/null 2>&1; then
    echo "Error: cargo not found for Rust project" >&2
    return 1
  fi

  echo "--- [rust] cargo fmt --check ---"
  if cargo fmt --all -- --check; then
    echo "✓ Format check passed"
  else
    exit_code=1
  fi

  echo ""
  echo "--- [rust] cargo clippy ---"
  if cargo clippy --all-targets --all-features -- -D warnings; then
    echo "✓ Clippy passed"
  else
    exit_code=1
  fi

  echo ""
  echo "--- [rust] cargo check ---"
  if cargo check --all-targets --all-features; then
    echo "✓ Cargo check passed"
  else
    exit_code=1
  fi

  return "$exit_code"
}

run_python_checks() {
  local exit_code=0
  local py_bin=""
  local lint_tool=""
  local mypy_tool=""

  echo ""
  echo "=== [python] Running checks ==="

  if command -v python3 >/dev/null 2>&1; then
    py_bin="python3"
  elif command -v python >/dev/null 2>&1; then
    py_bin="python"
  else
    echo "Error: python/python3 not found for Python project" >&2
    return 1
  fi

  if lint_tool="$(resolve_py_tool ruff)"; then
    echo "--- [python] Ruff ---"
    if "$lint_tool" check .; then
      echo "✓ Ruff passed"
    else
      exit_code=1
    fi
  elif lint_tool="$(resolve_py_tool flake8)"; then
    echo "--- [python] Flake8 ---"
    if "$lint_tool" .; then
      echo "✓ Flake8 passed"
    else
      exit_code=1
    fi
  else
    echo "--- [python] Lint ---"
    echo "(skipped: ruff/flake8 not found)"
  fi

  echo ""
  if mypy_tool="$(resolve_py_tool mypy)"; then
    echo "--- [python] Mypy ---"
    if "$mypy_tool" .; then
      echo "✓ Mypy passed"
    else
      exit_code=1
    fi
  else
    echo "--- [python] Type/Syntax ---"
    if "$py_bin" -m compileall -q .; then
      echo "✓ Syntax compile check passed (fallback)"
    else
      exit_code=1
    fi
  fi

  return "$exit_code"
}

echo "=========================================="
echo "  Pre-Deploy Quality Checks"
echo "=========================================="

STACKS="$($STACK_DETECT)"
TOTAL_EXIT=0

while IFS= read -r stack; do
  case "$stack" in
    node)
      run_node_checks || TOTAL_EXIT=1
      ;;
    rust)
      run_rust_checks || TOTAL_EXIT=1
      ;;
    python)
      run_python_checks || TOTAL_EXIT=1
      ;;
    *)
      echo "Warning: Unknown stack '$stack'" >&2
      ;;
  esac
done <<< "$STACKS"

echo ""
echo "=========================================="
if [ "$TOTAL_EXIT" -eq 0 ]; then
  echo "  ✓ All quality checks passed"
else
  echo "  ✗ Quality checks failed"
fi
echo "=========================================="

exit "$TOTAL_EXIT"
