#!/usr/bin/env bash
# Detects the supported project stacks in the current directory.
# Output: one stack per line (node, rust, python).

set -euo pipefail

found=0

if [ -e package.json ]; then
  echo "node"
  found=1
fi

if [ -e Cargo.toml ]; then
  echo "rust"
  found=1
fi

for candidate in pyproject.toml requirements.txt setup.py Pipfile poetry.lock; do
  if [ -e "$candidate" ]; then
    echo "python"
    found=1
    break
  fi
done

if [ "$found" -eq 0 ]; then
  echo "Error: No supported stack detected (node/rust/python)" >&2
  exit 1
fi
