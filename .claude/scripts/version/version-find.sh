#!/usr/bin/env bash
# version-find.sh - 버전 파일 탐색
# Usage: ./version-find.sh
# package.json과 .version() 코드 파일을 병렬로 탐색

set -uo pipefail

echo "=== Searching version files ==="

# 임시 파일
PKG_OUT=$(mktemp)
CODE_OUT=$(mktemp)

trap "rm -f $PKG_OUT $CODE_OUT" EXIT ERR INT TERM

# 병렬 탐색 (fd 우선, 없으면 find)
if command -v fd &>/dev/null; then
  fd -t f 'package.json' -E node_modules > "$PKG_OUT" 2>&1 &
else
  find . -name 'package.json' -not -path '*/node_modules/*' > "$PKG_OUT" 2>&1 &
fi
PID1=$!

(rg "\.version\(['\"]" --type ts --type js -l 2>/dev/null || true) > "$CODE_OUT" &
PID2=$!

wait $PID1
wait $PID2

# 결과 출력
echo ""
echo "=== package.json files ==="
if [ -s "$PKG_OUT" ]; then
  cat "$PKG_OUT"
else
  echo "(none found)"
fi

echo ""
echo "=== Code files with .version() ==="
if [ -s "$CODE_OUT" ]; then
  cat "$CODE_OUT"
else
  echo "(none found)"
fi

echo ""
echo "=== All version files ==="
cat "$PKG_OUT" "$CODE_OUT" | sort -u
