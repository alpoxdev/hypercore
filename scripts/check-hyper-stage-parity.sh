#!/usr/bin/env bash
# check-hyper-stage-parity.sh — keep the `hyper` orchestrator's three stage
# tables, its stage skills on disk, and its eval fixtures telling one story.
#
# The `hyper` package names its stage skills in three places that must agree:
#   SKILL.md                              (§ stage map)
#   rules/workflow-routing.md             (§2 "Add it when")
#   rules/stage-handoff.md                (§1 stage contracts)
# plus the Korean mirror of each. A stage added to one table and forgotten in
# another is invisible to the corpus validator, which checks each file on its
# own. The eval fixture then routes to a stage the tables never define, and the
# orchestrator's own order line stays silently wrong.
#
# What this checks:
#   (a) the stage-id set is identical across all six tables
#   (b) every stage id resolves to skills/<id>/SKILL.md
#   (c) every stage-handoff §1 row has four non-empty cells
#   (d) every hyper-* token in an eval `expected_route` is a known stage
#   (e) `expected_route: null` holds exactly when `expect` is `no_trigger`
#   (f) no eval route names both `hyper-plan` and `hyper-debate`
#   (g) the routing rules carry the stage-counting rule, and both the stage map
#       and the routing rules carry the plan/debate exclusivity sentence, in the
#       language of each file
#   (h) no file spells out a stage total ("twenty-seven", "스물일곱")
#
# The package name is fixed: the three tables, the six-result vocabulary, and
# the eval fixture layout belong to `hyper` alone, so a flag would only pretend
# this check generalizes.
#
# Usage:
#   check-hyper-stage-parity.sh [--skills <dir>] [--json] [--list]
#
#   --skills <dir>   root that holds the skill folders (default: ../skills)
#   --json           one JSON object of findings on stdout
#   --list           print the seven checked paths, then exit 0
#
# Exit 0 when PARITY-FAILURES=0, 1 when any check failed, 2 on argument errors.
#
# Requires bash 3.2+, POSIX tools. No jq: the eval fixture is one JSON object
# per line, so its two scalar fields are read per line with sed.

# literal backticks in the sed patterns match Markdown code spans, not commands
# shellcheck disable=SC2016
LC_ALL=C
export LC_ALL

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)
DEFAULT_SKILLS_ROOT=$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)/skills

SKILLS_ROOT=$DEFAULT_SKILLS_ROOT
SKILL_NAME=hyper
JSON=0
LIST=0
ERRORS=()
FINDINGS=()

usage() {
  printf 'usage: %s [--skills <dir>] [--json] [--list]\n' "${0##*/}"
}

arg_error() {
  printf 'check-hyper-stage-parity: %s\n' "$1" >&2
  usage >&2
  exit 2
}

while [ "$#" -gt 0 ]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    --skills)
      [ "$#" -ge 2 ] || arg_error "--skills needs a directory"
      SKILLS_ROOT=$2
      shift 2
      ;;
    --json)
      JSON=1
      shift
      ;;
    --list)
      LIST=1
      shift
      ;;
    *)
      arg_error "unknown argument: $1"
      ;;
  esac
done

PKG=$SKILLS_ROOT/$SKILL_NAME
EN_SKILL=$PKG/SKILL.md
KO_SKILL=$PKG/SKILL.ko.md
EN_ROUTING=$PKG/rules/workflow-routing.md
KO_ROUTING=$PKG/rules/workflow-routing.ko.md
EN_HANDOFF=$PKG/rules/stage-handoff.md
KO_HANDOFF=$PKG/rules/stage-handoff.ko.md
EVALS=$PKG/assets/evals/$SKILL_NAME-cases.jsonl

if [ "$LIST" -eq 1 ]; then
  printf '%s\n' "$EN_SKILL" "$KO_SKILL" "$EN_ROUTING" "$KO_ROUTING" "$EN_HANDOFF" "$KO_HANDOFF" "$EVALS"
  exit 0
fi

for f in "$EN_SKILL" "$KO_SKILL" "$EN_ROUTING" "$KO_ROUTING" "$EN_HANDOFF" "$KO_HANDOFF" "$EVALS"; do
  [ -f "$f" ] || ERRORS+=("MISSING_FILE $f")
done

WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/hyper-stage-parity.XXXXXX") || exit 1
trap 'rm -rf "$WORKDIR"' EXIT

finding() { # <code> <detail>
  FINDINGS+=("$1 $2")
}

# table_header <file> <header-line> — exact first cell text of a markdown table
# header. The tables are found by their header text, not a line number, so the
# files can grow around them.
header_of() { # <file> <english-header>
  grep -n -F -- "$2" "$1" 2>/dev/null | head -1 | sed 's/^\([0-9]*\):.*/\1/'
}

# table_rows <file> <header-line> — the body rows of the first table whose
# header equals the given line, header and delimiter row excluded.
table_rows() {
  awk -v hdr="$2" '
    index($0, hdr) == 1 && !seen { seen = 1; next }
    seen && /^\|[[:space:]:|-]+\|[[:space:]]*$/ { next }
    seen && /^\|/ { print; next }
    seen { exit }
  ' "$1"
}

# stage_ids <file> <header-line> — the backticked skill id in each row's first
# cell, in file order.
stage_ids() {
  table_rows "$1" "$2" | sed -n 's/^|[[:space:]]*`\([a-z0-9-]*\)`[[:space:]]*|.*/\1/p'
}

EN_MAP_HEADER='| Stage skill | What the stage produces |'
EN_ROUTE_HEADER='| Stage | Add it when | Evidence to quote |'
EN_HANDOFF_HEADER='| Stage | Request passed to the stage | Artifact that must exist before the next stage | Passed forward |'

extract_set() { # <out-file> <file> <header-line> <label>
  local out=$1 file=$2 header=$3 label=$4
  if [ ! -f "$file" ]; then
    : >"$out"
    return 0
  fi
  if [ -z "$(header_of "$file" "$header")" ]; then
    finding "TABLE_MISSING" "$label has no table header: $header"
    : >"$out"
    return 0
  fi
  stage_ids "$file" "$header" | sort -u >"$out"
  if [ ! -s "$out" ]; then
    finding "TABLE_EMPTY" "$label has no stage rows"
  fi
  local dupes
  dupes=$(stage_ids "$file" "$header" | sort | uniq -d | tr '\n' ' ')
  [ -z "$dupes" ] || finding "DUPLICATE_STAGE $label" "$dupes"
}

extract_set "$WORKDIR/map.en" "$EN_SKILL" "$EN_MAP_HEADER" 'SKILL.md'
extract_set "$WORKDIR/map.ko" "$KO_SKILL" "$EN_MAP_HEADER" 'SKILL.ko.md'
extract_set "$WORKDIR/route.en" "$EN_ROUTING" "$EN_ROUTE_HEADER" 'rules/workflow-routing.md'
extract_set "$WORKDIR/route.ko" "$KO_ROUTING" "$EN_ROUTE_HEADER" 'rules/workflow-routing.ko.md'
extract_set "$WORKDIR/handoff.en" "$EN_HANDOFF" "$EN_HANDOFF_HEADER" 'rules/stage-handoff.md'
extract_set "$WORKDIR/handoff.ko" "$KO_HANDOFF" "$EN_HANDOFF_HEADER" 'rules/stage-handoff.ko.md'

# The reference set is the union of the six tables: a stage named in any table
# is a stage the package claims, so a table that omits it is the broken one. Each
# file reports only what it lacks, and the whole drift lands in one finding so a
# single forgotten row does not read as five unrelated defects.
CANON=$WORKDIR/union
sort -u "$WORKDIR"/map.en "$WORKDIR"/map.ko "$WORKDIR"/route.en "$WORKDIR"/route.ko \
  "$WORKDIR"/handoff.en "$WORKDIR"/handoff.ko >"$CANON"
SET_DRIFT=''
for entry in map.en:SKILL.md map.ko:SKILL.ko.md \
  route.en:rules/workflow-routing.md route.ko:rules/workflow-routing.ko.md \
  handoff.en:rules/stage-handoff.md handoff.ko:rules/stage-handoff.ko.md; do
  key=${entry%%:*}
  label=${entry#*:}
  case $label in
    SKILL.md) file=$EN_SKILL ;;
    SKILL.ko.md) file=$KO_SKILL ;;
    rules/workflow-routing.md) file=$EN_ROUTING ;;
    rules/workflow-routing.ko.md) file=$KO_ROUTING ;;
    rules/stage-handoff.md) file=$EN_HANDOFF ;;
    *) file=$KO_HANDOFF ;;
  esac
  [ -f "$file" ] || continue
  missing=$(comm -23 "$CANON" "$WORKDIR/$key" | tr '\n' ' ')
  missing=${missing% }
  [ -z "$missing" ] || SET_DRIFT="$SET_DRIFT; $label lacks[$missing]"
done
[ -z "$SET_DRIFT" ] || finding "STAGE_SET_MISMATCH" "${SET_DRIFT#; }"

# (b) every stage id resolves to a skill folder with both language files.
while IFS= read -r id; do
  [ -n "$id" ] || continue
  [ -f "$SKILLS_ROOT/$id/SKILL.md" ] || finding "STAGE_SKILL_MISSING" "skills/$id/SKILL.md"
  [ -f "$SKILLS_ROOT/$id/SKILL.ko.md" ] || finding "STAGE_SKILL_MISSING" "skills/$id/SKILL.ko.md"
done <"$CANON"

# (c) every stage-handoff §1 row has four cells, each non-empty.
check_four_cells() { # <file> <header-line> <label>
  local file=$1 header=$2 label=$3 row cells count first
  while IFS= read -r row; do
    count=$(printf '%s' "$row" | awk -F'|' '{ print NF - 2 }')
    first=$(printf '%s' "$row" | sed -n 's/^|[[:space:]]*`\([a-z0-9-]*\)`.*/\1/p')
    if [ "$count" -ne 4 ]; then
      finding "ROW_CELLS $label ${first:-?}" "expected 4 cells, found $count"
      continue
    fi
    cells=$(printf '%s' "$row" | awk -F'|' '
      { for (i = 2; i <= NF - 1; i++) if ($i ~ /^[[:space:]]*$/) bad = i }
      END { if (bad) print bad }
    ')
    if [ -n "$cells" ]; then
      finding "ROW_EMPTY_CELL $label ${first:-?}" "cell $((cells - 1)) is empty"
    fi
  done < <(table_rows "$file" "$header")
}
if [ -f "$EN_HANDOFF" ]; then
  check_four_cells "$EN_HANDOFF" "$EN_HANDOFF_HEADER" 'rules/stage-handoff.md'
fi
if [ -f "$KO_HANDOFF" ]; then
  check_four_cells "$KO_HANDOFF" "$EN_HANDOFF_HEADER" 'rules/stage-handoff.ko.md'
fi

# (d)-(f) eval fixture: per line, one object with scalar expect/expected_route.
if [ -f "$EVALS" ]; then
  linerec=$WORKDIR/evals.tsv
  : >"$linerec"
  while IFS= read -r line; do
    case $line in
      *'"id"'*) ;;
      *) continue ;;
    esac
    id=$(printf '%s' "$line" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    expect=$(printf '%s' "$line" | sed -n 's/.*"expect"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    route=__absent__
    if printf '%s' "$line" | grep -q '"expected_route"[[:space:]]*:'; then
      if printf '%s' "$line" | grep -q '"expected_route"[[:space:]]*:[[:space:]]*null'; then
        route=null
      else
        route=$(printf '%s' "$line" | sed -n 's/.*"expected_route"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
      fi
    fi
    printf '%s\t%s\t%s\n' "$id" "$expect" "$route" >>"$linerec"
  done <"$EVALS"

  while IFS=$'\t' read -r id expect route; do
    [ -n "$id" ] || continue
    if [ "$route" = "__absent__" ]; then
      finding "EVAL_ROUTE_MISSING" "$id has no expected_route field"
      continue
    fi
    if [ "$route" = "null" ]; then
      [ "$expect" = "no_trigger" ] || finding "EVAL_NULL_ROUTE" "$id has expect=$expect"
    else
      [ "$expect" = "no_trigger" ] && finding "EVAL_ROUTE_ON_NO_TRIGGER" "$id routes to $route"
      [ -n "$route" ] || finding "EVAL_EMPTY_ROUTE" "$id has an empty expected_route"
      case $route in
        hyper-plan*hyper-debate*|*hyper-debate*hyper-plan*)
          finding "EVAL_PLAN_DEBATE_BOTH" "$id routes to $route"
          ;;
      esac
      printf '%s\n' "$route" | grep -o 'hyper-[a-z0-9-]*' | sort -u >"$WORKDIR/tokens"
      while IFS= read -r token; do
        [ -n "$token" ] || continue
        [ "$token" = "$SKILL_NAME-browsing" ] && continue
        grep -qx -- "$token" "$CANON" || finding "EVAL_UNKNOWN_STAGE $id" "$token"
      done <"$WORKDIR/tokens"
    fi
  done <"$linerec"
fi

# (g) exclusivity and counting sentences, per language.
check_sentence() { # <file> <needle> <label> <code>
  local file=$1 needle=$2 label=$3 code=$4
  [ -f "$file" ] || return 0
  grep -qF -- "$needle" "$file" || finding "$code" "$label"
}

for pair in \
  "$EN_ROUTING|At most four distinct core stages run|rules/workflow-routing.md|STAGE_COUNT_RULE" \
  "$KO_ROUTING|서로 다른 핵심 단계를 최대 네 개까지 실행|rules/workflow-routing.ko.md|STAGE_COUNT_RULE" \
  "$EN_ROUTING|chain both|rules/workflow-routing.md|PLAN_DEBATE_RULE" \
  "$KO_ROUTING|둘을 한 체인에 넣지 않습니다|rules/workflow-routing.ko.md|PLAN_DEBATE_RULE" \
  "$EN_SKILL|never runs alongside it|SKILL.md|PLAN_DEBATE_RULE" \
  "$KO_SKILL|한 체인에 넣지 않습니다|SKILL.ko.md|PLAN_DEBATE_RULE"; do
  file=${pair%%|*}
  rest=${pair#*|}
  needle=${rest%%|*}
  rest=${rest#*|}
  label=${rest%%|*}
  code=${rest##*|}
  check_sentence "$file" "$needle" "$label" "$code"
done

# (h) no hardcoded stage total: the count must not be spelled out, because the
# stage set changes and the sentence cannot keep up.
for f in "$EN_SKILL" "$KO_SKILL" "$EN_ROUTING" "$KO_ROUTING"; do
  [ -f "$f" ] || continue
  grep -n 'twenty-seven\|스물일곱' "$f" >"$WORKDIR/hits" || true
  if [ -s "$WORKDIR/hits" ]; then
    finding "HARDCODED_STAGE_COUNT ${f#"$SKILLS_ROOT"/}" "$(sed -n '1p' "$WORKDIR/hits" | cut -d: -f1)"
  fi
done

for e in "${ERRORS[@]}"; do
  FINDINGS+=("$e")
done
total=${#FINDINGS[@]}
if [ "$JSON" -eq 1 ]; then
  printf '{"skill":"%s","ok":%s,"findings":%d' \
    "$SKILL_NAME" "$([ "$total" -eq 0 ] && printf true || printf false)" "$total"
  if [ "$total" -gt 0 ]; then
    printf ',"problems":['
    first=1
    for f in "${FINDINGS[@]}"; do
      [ "$first" -eq 1 ] || printf ','
      first=0
      printf '{"code":"%s","detail":"%s"}' "${f%% *}" "$(printf '%s' "${f#* }" | sed 's/\\/\\\\/g; s/"/\\"/g')"
    done
    printf ']'
  fi
  printf '}\n'
else
  for f in "${FINDINGS[@]}"; do
    printf 'FAIL %s\n' "$f"
  done
  printf 'PARITY-FAILURES=%s\n' "$total"
fi

[ "$total" -eq 0 ] || exit 1
exit 0
