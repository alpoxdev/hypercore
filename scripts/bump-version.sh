#!/usr/bin/env bash
# bump-version.sh — set one SemVer version in every plugin manifest.
#
# Usage: bump-version.sh <major|minor|patch|X.Y.Z> [repository-root]
#
# The version source is .claude-plugin/plugin.json. The script computes the
# next version from it (major, minor and patch use the numeric X.Y.Z core and
# drop any pre-release or build suffix), or takes an explicit X.Y.Z that must be
# higher than the current version. It then writes that version into each
# manifest that exists (.codex-plugin, .claude-plugin, .cursor-plugin) with jq
# and runs scripts/check-plugin-manifests.sh.
#
# A bad argument, a version that is not higher, or manifests that already
# disagree exit 1 without changing any file. The script never commits, tags or
# pushes.
set -uo pipefail
export LC_ALL=C

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
ROOT=${2:-$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)}
CHECK=$SCRIPT_DIR/check-plugin-manifests.sh
SOURCE=$ROOT/.claude-plugin/plugin.json

die() {
  printf 'bump-version: %s\n' "$1" >&2
  exit 1
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || die "usage: bump-version.sh <major|minor|patch|X.Y.Z> [repository-root]"
command -v jq >/dev/null 2>&1 || die "jq is required"
[ -f "$SOURCE" ] || die ".claude-plugin/plugin.json is missing"

# Refuse to start from manifests that already disagree.
bash "$CHECK" "$ROOT" >/dev/null || die "plugin manifests do not pass check-plugin-manifests.sh; fix them first"

current=$(jq -r '.version // empty' "$SOURCE")
core=${current%%[-+]*}
case $core in
  *.*.*) ;;
  *) die "current version '$current' is not SemVer" ;;
esac
cur_major=${core%%.*}
rest=${core#*.}
cur_minor=${rest%%.*}
cur_patch=${rest#*.}

case $1 in
  major) next="$((cur_major + 1)).0.0" ;;
  minor) next="$cur_major.$((cur_minor + 1)).0" ;;
  patch) next="$cur_major.$cur_minor.$((cur_patch + 1))" ;;
  *)
    printf '%s' "$1" | grep -Eq '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' \
      || die "argument '$1' is not major, minor, patch or X.Y.Z"
    next=$1
    new_major=${next%%.*}
    rest=${next#*.}
    new_minor=${rest%%.*}
    new_patch=${rest#*.}
    higher=0
    if [ "$new_major" -ne "$cur_major" ]; then
      [ "$new_major" -gt "$cur_major" ] && higher=1
    elif [ "$new_minor" -ne "$cur_minor" ]; then
      [ "$new_minor" -gt "$cur_minor" ] && higher=1
    elif [ "$new_patch" -ne "$cur_patch" ]; then
      [ "$new_patch" -gt "$cur_patch" ] && higher=1
    elif [ "$current" != "$core" ]; then
      # X.Y.Z is higher than its own pre-release X.Y.Z-rc.
      case $current in *-*) higher=1 ;; esac
    fi
    [ "$higher" -eq 1 ] || die "version '$next' is not higher than the current version '$current'"
    ;;
esac

for manifest in .codex-plugin/plugin.json .claude-plugin/plugin.json .cursor-plugin/plugin.json; do
  file=$ROOT/$manifest
  [ -f "$file" ] || continue
  tmp=$file.tmp.$$
  if ! { jq --arg v "$next" '.version = $v' "$file" >"$tmp" && mv "$tmp" "$file"; }; then
    rm -f "$tmp"
    die "could not write $manifest"
  fi
done

bash "$CHECK" "$ROOT" || die "plugin manifests failed validation after the bump"
printf 'bump-version: %s -> %s\n' "$current" "$next"
