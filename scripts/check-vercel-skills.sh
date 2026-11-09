#!/usr/bin/env bash
# check-vercel-skills.sh — validate Hypercore's vercel-labs/skills lifecycle integration.
#
# Usage:
#   scripts/check-vercel-skills.sh [--root <dir>] [--live]
#
# Checks every skill directory for YAML frontmatter (name, description) and a
# non-empty Korean translation, rejects the removed plugin adapter paths, and
# requires the README to document the public `npx skills` lifecycle, the
# Codex canonical destination, and the upstream-unverified update/remove
# guarantees. --live additionally runs `npx skills add ... --list` and
# `npx skills find` and requires HYPERCORE_ENABLE_VERCEL_SKILLS_LIVE_GATE=1.
#
# Exit 0 on success with a one-line confirmation on stdout. Exit 1 with
# "vercel skills lifecycle validation failed: <reason>" on stderr.

set -uo pipefail

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)

TMP_WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/check-vercel-skills.XXXXXX") || {
  printf 'check-vercel-skills: cannot create a temporary directory\n' >&2
  exit 1
}
trap 'rm -rf "$TMP_WORKDIR"' EXIT

ROOT_ARG_INDEX=-1
ROOT_ARG_VALUE=
LIVE=0
ARGS=("$@")
INDEX=0
while [ "$INDEX" -lt "$#" ]; do
  ARG=${ARGS[$INDEX]}
  if [ "$ROOT_ARG_INDEX" -eq -1 ] && [ "$ARG" = "--root" ]; then
    ROOT_ARG_INDEX=$INDEX
    if [ "$((INDEX + 1))" -lt "$#" ]; then
      ROOT_ARG_VALUE=${ARGS[$((INDEX + 1))]}
    else
      ROOT_ARG_VALUE=
    fi
  fi
  if [ "$ARG" = "--live" ]; then
    LIVE=1
  fi
  INDEX=$((INDEX + 1))
done

if [ "$ROOT_ARG_INDEX" -ne -1 ]; then
  if [ -z "$ROOT_ARG_VALUE" ]; then
    ROOT=$PWD
  elif [ -d "$ROOT_ARG_VALUE" ]; then
    ROOT=$(CDPATH='' cd -- "$ROOT_ARG_VALUE" && pwd)
  elif [ "${ROOT_ARG_VALUE#/}" != "$ROOT_ARG_VALUE" ]; then
    ROOT=$ROOT_ARG_VALUE
  else
    ROOT=$PWD/$ROOT_ARG_VALUE
  fi
fi

die() {
  printf 'vercel skills lifecycle validation failed: %s\n' "$1" >&2
  exit 1
}

relative_path() {
  case $1 in
    "$ROOT"/*) printf '%s\n' "${1#"$ROOT"/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

require_file() {
  if [ ! -f "$1" ]; then
    die "$(relative_path "$1") must be a file"
  fi
}

validate_frontmatter() {
  local file=$1
  local label=$2
  local line first=1 in_body=0 closed=0
  local has_name=0 has_description=0
  local name_value='' description_value=''
  local key value

  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}
    if [ "$first" -eq 1 ]; then
      [ "$line" = "---" ] || die "$label must start with YAML frontmatter"
      first=0
      in_body=1
      continue
    fi
    if [ "$in_body" -eq 1 ]; then
      if [ "$line" = "---" ]; then
        closed=1
        break
      fi
      if [[ $line =~ ^([A-Za-z][A-Za-z0-9_-]*):[[:space:]]*(.+)$ ]]; then
        key=${BASH_REMATCH[1]}
        value=${BASH_REMATCH[2]}
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        case $key in
          name)
            has_name=1
            name_value=$value
            ;;
          description)
            has_description=1
            description_value=$value
            ;;
        esac
      fi
    fi
  done <"$file"

  if [ "$closed" -ne 1 ]; then
    die "$label must start with YAML frontmatter"
  fi
  if [ "$has_name" -ne 1 ] || [ -z "$name_value" ]; then
    die "$label frontmatter requires name"
  fi
  if [ "$has_description" -ne 1 ] || [ -z "$description_value" ]; then
    die "$label frontmatter requires description"
  fi
}

validate_skills() {
  local skills=$ROOT/skills
  local count=0
  local directory name english korean

  if [ ! -d "$skills" ]; then
    die "skills must be a directory"
  fi

  while IFS= read -r directory; do
    [ -n "$directory" ] || continue
    count=$((count + 1))
    name=$(basename -- "$directory")
    english=$directory/SKILL.md
    korean=$directory/SKILL.ko.md
    require_file "$english"
    validate_frontmatter "$english" "skills/$name/SKILL.md"
    require_file "$korean"
    if [ -z "$(tr -d '[:space:]' <"$korean")" ]; then
      die "skills/$name/SKILL.ko.md must not be empty"
    fi
  done < <(find "$skills" -mindepth 1 -maxdepth 1 -type d | sort)

  if [ "$count" -eq 0 ]; then
    die "skills must contain at least one skill directory"
  fi
}

validate_no_plugin_adapters() {
  local adapter
  for adapter in ".agents/plugins" "plugins/hypercore" "scripts/validate-codex-plugin.mjs"; do
    if [ -e "$ROOT/$adapter" ]; then
      die "$adapter must not remain after removing plugin adapters"
    fi
  done
}

readme_has_line() {
  local pattern=$1
  local insensitive=${2:-0}
  if [ "$insensitive" -eq 1 ]; then
    grep -Eiq -- "$pattern" "$README_FILE"
  else
    grep -Eq -- "$pattern" "$README_FILE"
  fi
}

readme_has_span() {
  local pattern=$1
  local flattened=$TMP_WORKDIR/readme-flat.txt
  tr '\n' ' ' <"$README_FILE" >"$flattened"
  grep -Eiq -- "$pattern" "$flattened"
}

validate_readme() {
  local phrase
  README_FILE=$ROOT/README.md

  require_file "$README_FILE"

  for phrase in \
    "npx skills" \
    "npx skills add" \
    "npx skills list" \
    "npx skills update" \
    "npx skills remove" \
    "npx skills use" \
    "npx skills init" \
    "npx skills find" \
    ".agents/skills" \
    "CODEX_HOME"; do
    if ! grep -Fq -- "$phrase" "$README_FILE"; then
      die "README.md must document $phrase"
    fi
  done

  if ! readme_has_line 'CODEX_HOME.*(not|아님|아닙|아니|primary destination)' 1; then
    die "README.md must state that CODEX_HOME is not the primary destination"
  fi
  if ! readme_has_line '(.agents/skills.*(Codex|Codex CLI))|((Codex|Codex CLI).*\.agents/skills)' 0; then
    die "README.md must identify .agents/skills as Codex's canonical destination"
  fi
  if ! readme_has_span '(update|업데이트).{0,240}(agent|mode|에이전트|모드).{0,240}(not guaranteed|보장하지|비보장)'; then
    die "README.md must document update agent/mode preservation as upstream-unverified"
  fi
  if ! readme_has_span '(partial|부분).{0,240}(remove|제거).{0,240}(provenance|출처).{0,240}(not guaranteed|보장하지|비보장)'; then
    die "README.md must document partial-remove provenance as upstream-unverified"
  fi
}

run_live_gate() {
  local workdir=$1
  local out=$workdir/live
  local status
  local first combined_second

  if [ "${HYPERCORE_ENABLE_VERCEL_SKILLS_LIVE_GATE:-}" != "1" ]; then
    die "--live requires HYPERCORE_ENABLE_VERCEL_SKILLS_LIVE_GATE=1"
  fi

  if (cd -- "$ROOT" && npx --yes skills add alpoxdev/hypercore --list) >"$out.add.out" 2>"$out.add.err"; then
    status=0
  else
    status=$?
  fi
  if [ "$status" -ne 0 ]; then
    if [ -s "$out.add.err" ]; then
      die "live skills add gate failed: $(cat "$out.add.err")"
    fi
    die "live skills add gate failed: $(cat "$out.add.out")"
  fi
  first=$(cat "$out.add.out")$'\n'$(cat "$out.add.err")

  if (cd -- "$ROOT" && npx --yes skills find hypercore --owner alpoxdev) >"$out.find.out" 2>"$out.find.err"; then
    status=0
  else
    status=$?
  fi
  if [ "$status" -ne 0 ]; then
    if [ -s "$out.find.err" ]; then
      die "live skills find gate failed: $(cat "$out.find.err")"
    fi
    die "live skills find gate failed: $(cat "$out.find.out")"
  fi
  combined_second=$(cat "$out.find.out")$'\n'$(cat "$out.find.err")

  case $first in
    *hyper-git*) ;;
    *) die "live add --list did not discover Hypercore skills" ;;
  esac
  case $combined_second in
    *alpoxdev/hypercore*) ;;
    *) die "live find returned a stale or missing Hypercore source identity" ;;
  esac
}

validate_skills
validate_no_plugin_adapters
validate_readme
if [ "$LIVE" -eq 1 ]; then
  run_live_gate "$TMP_WORKDIR"
fi

if [ "$LIVE" -eq 1 ]; then
  printf 'vercel skills lifecycle validation passed (live gate)\n'
else
  printf 'vercel skills lifecycle validation passed\n'
fi
