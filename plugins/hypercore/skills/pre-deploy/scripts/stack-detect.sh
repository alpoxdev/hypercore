#!/usr/bin/env bash
# stack-detect.sh - Project stack auto detection
# Output: one stack per line (node|rust|python)

set -euo pipefail

found=0

if [ -f "package.json" ]; then
  echo "node"
  found=1
fi

if [ -f "Cargo.toml" ]; then
  echo "rust"
  found=1
fi

if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "Pipfile" ] || [ -f "poetry.lock" ]; then
  echo "python"
  found=1
fi

if [ "$found" -eq 0 ]; then
  echo "Error: No supported stack detected (node/rust/python)" >&2
  exit 1
fi
