#!/usr/bin/env bash
# EN/KO contract parity for the instruction and skill contract trees.
#
# What this checks, and why only this:
#   (a) the set of normative `SK-<letter>-<n>` ids is identical in both languages
#   (b) the `## ` section count is identical
#   (c) each file carries a Sources section with a checked-date line
#   (d) within each section, each letter's numbering runs 1..N with no gaps
#
# What it deliberately does NOT check: section heading TEXT (Korean headings vs English
# headings differ by design), and numerals inside prose (numerals are localized).
#
# Three pair sets, each with its OWN root: the instructions set (hardcoded pairs), the discovered
# hyper-skill set, and the explicit hyper-documentation single pair. `--root` addresses the
# instruction set; `--root-skills` keeps its historical meaning as the hyper-skill root and
# additionally overrides the selected skill set when exactly one skill set is selected.
#
# Usage:
#   check-skill-contract-parity.sh [--root <dir>] [--root-skills <dir>] [--set <name>] [--list]
#
#   --root <dir>        root of the instructions/skill pair set (default: ../instructions/skill)
#   --root-skills <dir> skill-set root override: the hyper-skill root when no set is selected, and
#                       the selected set's own root when exactly one skill set is selected
#   --set <name>        restrict to one set: instructions-skill | hyper-skill | hyper-documentation
#                       (default: all)
#   --list              print one line per pair as set<TAB>root<TAB>en<TAB>ko, then exit 0
#
# Exit 0 when PARITY-FAILURES=0, non-zero otherwise. Argument errors exit 2.

LC_ALL=C
export LC_ALL

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

VALUE_FLAGS="--root --root-skills --set"
SKILL_SET_NAMES="hyper-skill hyper-documentation"
ALLOWED_SETS_LABEL="instructions-skill|hyper-skill|hyper-documentation"
ALLOWED_SETS_PADDED=" instructions-skill hyper-skill hyper-documentation "

argc=$#
args=("$@")

WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/parity.XXXXXX") || exit 1
trap 'rm -rf "$WORKDIR"' EXIT

problems=()

flag_value() {
  local flag=$1 i=0
  while [ "$i" -lt "$argc" ]; do
    if [ "${args[$i]}" = "$flag" ] && [ $((i + 1)) -lt "$argc" ]; then
      printf '%s' "${args[$((i + 1))]}"
      return 0
    fi
    i=$((i + 1))
  done
  return 1
}

# A repeated value flag is ambiguous, so it is rejected outright.
for flag in $VALUE_FLAGS; do
  count=0
  i=0
  while [ "$i" -lt "$argc" ]; do
    if [ "${args[$i]}" = "$flag" ]; then
      count=$((count + 1))
    fi
    i=$((i + 1))
  done
  if [ "$count" -gt 1 ]; then
    problems[${#problems[@]}]="$flag was given $count times; it may appear at most once"
  fi
done

# Positions that hold the value of a value flag are not stray positionals.
value_positions=" "
i=0
while [ "$i" -lt "$argc" ]; do
  arg="${args[$i]}"
  for flag in $VALUE_FLAGS; do
    if [ "$arg" = "$flag" ] && [ $((i + 1)) -lt "$argc" ]; then
      case "${args[$((i + 1))]}" in
        -*) ;;
        *) value_positions="$value_positions$((i + 1)) " ;;
      esac
    fi
  done
  i=$((i + 1))
done

# Validate EVERY occurrence by walking the arguments in order.
i=0
while [ "$i" -lt "$argc" ]; do
  arg="${args[$i]}"
  is_value_flag=0
  for flag in $VALUE_FLAGS; do
    if [ "$arg" = "$flag" ]; then
      is_value_flag=1
      if [ $((i + 1)) -ge "$argc" ]; then
        problems[${#problems[@]}]="$arg requires a value"
      else
        next_value="${args[$((i + 1))]}"
        case "$next_value" in
          -*) problems[${#problems[@]}]="$arg requires a value" ;;
          "") problems[${#problems[@]}]="$arg requires a non-empty value" ;;
        esac
      fi
    fi
  done
  if [ "$is_value_flag" -eq 1 ]; then
    i=$((i + 1))
    continue
  fi
  case "$value_positions" in
    *" $i "*) i=$((i + 1)); continue ;;
  esac
  if [ "$arg" = "--list" ]; then
    i=$((i + 1))
    continue
  fi
  case "$arg" in
    -*) problems[${#problems[@]}]="unknown option: $arg" ;;
    *) problems[${#problems[@]}]="unexpected argument: $arg" ;;
  esac
  i=$((i + 1))
done

has_set=0
requested_set=""
if requested_set=$(flag_value --set); then
  has_set=1
fi
if [ "$has_set" -eq 1 ]; then
  case "$ALLOWED_SETS_PADDED" in
    *" $requested_set "*) ;;
    *) problems[${#problems[@]}]="--set must be one of instructions-skill | hyper-skill | hyper-documentation, got \"$requested_set\"" ;;
  esac
fi

if [ "${#problems[@]}" -gt 0 ]; then
  for problem in "${problems[@]}"; do
    printf 'ARGUMENT-ERROR: %s\n' "$problem" >&2
  done
  printf 'Usage: %s [--root <dir>] [--root-skills <dir>] [--set %s] [--list]\n' \
    "$(basename "$0")" "$ALLOWED_SETS_LABEL" >&2
  exit 2
fi

explicit_root=0
if instruction_root=$(flag_value --root); then
  explicit_root=1
else
  instruction_root="$REPO_ROOT/instructions/skill"
fi

explicit_skills_root=0
skills_root_override=""
if skills_root_override=$(flag_value --root-skills); then
  explicit_skills_root=1
fi

# Skill sets the current --set selects: the one named, or all of them when none is named.
selected_skill_set_count=0
if [ "$has_set" -eq 0 ]; then
  selected_skill_set_count=3
else
  case " $SKILL_SET_NAMES " in
    *" $requested_set "*) selected_skill_set_count=1 ;;
  esac
fi

sroot_hyper_skill="$REPO_ROOT/skills/hyper-skill"
sroot_hyper_documentation="$REPO_ROOT/skills/hyper-documentation"

for name in $SKILL_SET_NAMES; do
  override_applies=0
  if [ "$explicit_skills_root" -eq 1 ]; then
    if [ "$selected_skill_set_count" -eq 1 ]; then
      if [ "$requested_set" = "$name" ]; then
        override_applies=1
      fi
    elif [ "$name" = "hyper-skill" ]; then
      override_applies=1
    fi
  fi
  if [ "$override_applies" -eq 1 ]; then
    resolved_root="$skills_root_override"
  else
    resolved_root="$REPO_ROOT/skills/$name"
  fi
  case "$name" in
    hyper-skill) sroot_hyper_skill="$resolved_root" ;;
    hyper-documentation) sroot_hyper_documentation="$resolved_root" ;;
  esac
done

root_for_set() {
  case "$1" in
    instructions-skill) printf '%s' "$instruction_root" ;;
    hyper-skill) printf '%s' "$sroot_hyper_skill" ;;
    hyper-documentation) printf '%s' "$sroot_hyper_documentation" ;;
  esac
}

# Validate each root that will be USED or was EXPLICITLY given, before anything is checked or listed.
validate_root() {
  local name=$1 root=$2
  if [ ! -d "$root" ]; then
    printf 'ARGUMENT-ERROR: the %s root is not an existing directory: %s\n' "$name" "$root" >&2
    exit 2
  fi
  if ! ls -A "$root" >/dev/null 2>"$WORKDIR/readdir.err"; then
    printf 'ARGUMENT-ERROR: the %s root is not readable: %s (%s)\n' \
      "$name" "$root" "$(tr -d '\n' <"$WORKDIR/readdir.err")" >&2
    exit 2
  fi
}

for name in instructions-skill $SKILL_SET_NAMES; do
  root=$(root_for_set "$name")
  explicit=0
  if [ "$name" = "instructions-skill" ]; then
    explicit=$explicit_root
  else
    explicit=$explicit_skills_root
  fi
  if [ "$explicit" -eq 0 ] && [ "$has_set" -eq 1 ] && [ "$requested_set" != "$name" ]; then
    continue
  fi
  validate_root "$name" "$root"
done

PAIRS_FILE="$WORKDIR/discovered.pairs"
ORPHANS_FILE="$WORKDIR/discovered.orphans"
SEEN_DIRS="$WORKDIR/seen-dirs"

add_orphan() {
  printf '%s\t%s\n' "$1" "$2" >>"$ORPHANS_FILE"
}

# Follows symlinks, records a broken symlink as an orphan, and bounds symlink loops by realpath.
walk_dir() {
  local dir=$1 rel=$2 real name full entry_rel
  [ -e "$dir" ] || return 0
  real=$(cd "$dir" 2>/dev/null && pwd -P) || real=$dir
  if grep -Fxq -- "$real" "$SEEN_DIRS" 2>/dev/null; then
    return 0
  fi
  printf '%s\n' "$real" >>"$SEEN_DIRS"
  if ! ls -A "$dir" >/dev/null 2>"$WORKDIR/walk.err"; then
    if [ -z "$rel" ]; then
      add_orphan "." "unreadable directory ($(tr -d '\n' <"$WORKDIR/walk.err"))"
    else
      add_orphan "$rel" "unreadable directory ($(tr -d '\n' <"$WORKDIR/walk.err"))"
    fi
    return 0
  fi
  while IFS= read -r -d '' full; do
    name="${full##*/}"
    if [ -z "$rel" ]; then
      entry_rel="$name"
    else
      entry_rel="$rel/$name"
    fi
    is_dir=0
    is_file=0
    if [ -L "$full" ]; then
      if [ -d "$full" ]; then
        is_dir=1
      elif [ -f "$full" ]; then
        is_file=1
      else
        add_orphan "$entry_rel" "broken symlink"
        continue
      fi
    elif [ -d "$full" ]; then
      is_dir=1
    elif [ -f "$full" ]; then
      is_file=1
    else
      continue
    fi
    if [ "$is_dir" -eq 1 ]; then
      walk_dir "$full" "$entry_rel"
      continue
    fi
    if [ "$is_file" -eq 0 ]; then
      continue
    fi
    case "$name" in
      *.md) ;;
      *) continue ;;
    esac
    case "$name" in
      *.ko.md)
        en_rel="${entry_rel%.ko.md}.md"
        if [ ! -f "$DISCOVERY_ROOT/$en_rel" ]; then
          add_orphan "$entry_rel" "no EN sibling"
        fi
        ;;
      *)
        ko_rel="${entry_rel%.md}.ko.md"
        if [ -f "$DISCOVERY_ROOT/$ko_rel" ]; then
          printf '%s\t%s\n' "$entry_rel" "$ko_rel" >>"$PAIRS_FILE"
        else
          add_orphan "$entry_rel" "no KO mirror"
        fi
        ;;
    esac
  done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 2>/dev/null)
}

DISCOVERY_ROOT="$sroot_hyper_skill"
: >"$PAIRS_FILE"
: >"$ORPHANS_FILE"
: >"$SEEN_DIRS"
walk_dir "$DISCOVERY_ROOT" ""
if [ -s "$PAIRS_FILE" ]; then
  sort -t "$(printf '\t')" -k1,1 "$PAIRS_FILE" -o "$PAIRS_FILE"
fi
if [ -s "$ORPHANS_FILE" ]; then
  sort -t "$(printf '\t')" -k1,1 "$ORPHANS_FILE" -o "$ORPHANS_FILE"
fi

ALL_PAIRS="$WORKDIR/all.pairs"
: >"$ALL_PAIRS"

add_pair() {
  printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" >>"$ALL_PAIRS"
}

while IFS='|' read -r en ko; do
  add_pair "instructions-skill" "$instruction_root" "$en" "$ko"
done <<'INSTRUCTION_PAIRS'
SKILL_AUTHORING.md|SKILL_AUTHORING.ko.md
references/trigger-design.md|references/trigger-design.ko.md
references/skill-anatomy.md|references/skill-anatomy.ko.md
references/progressive-disclosure.md|references/progressive-disclosure.ko.md
references/resource-placement.md|references/resource-placement.ko.md
references/prompt-loop-eval.md|references/prompt-loop-eval.ko.md
references/validation.md|references/validation.ko.md
INSTRUCTION_PAIRS

while IFS="$(printf '\t')" read -r en ko; do
  add_pair "hyper-skill" "$sroot_hyper_skill" "$en" "$ko"
done <"$PAIRS_FILE"

add_pair "hyper-documentation" "$sroot_hyper_documentation" "SKILL.md" "SKILL.ko.md"

# Every configured set must yield at least one pair; a wrong root makes a whole set vanish silently.
if [ "$has_set" -eq 1 ]; then
  set_names="$requested_set"
else
  set_names="instructions-skill $SKILL_SET_NAMES"
fi
for name in $set_names; do
  if ! awk -F'\t' -v s="$name" '$1 == s { found = 1; exit } END { exit found ? 0 : 1 }' "$ALL_PAIRS"; then
    printf 'ARGUMENT-ERROR: the %s set has no pairs; its root looks wrong (%s)\n' \
      "$name" "$(root_for_set "$name")" >&2
    exit 2
  fi
done

SELECTED="$WORKDIR/selected.pairs"
if [ "$has_set" -eq 1 ]; then
  awk -F'\t' -v s="$requested_set" '$1 == s' "$ALL_PAIRS" >"$SELECTED"
else
  cat "$ALL_PAIRS" >"$SELECTED"
fi

if [ "$(wc -l <"$SELECTED" | tr -d ' ')" -eq 0 ]; then
  printf 'ARGUMENT-ERROR: the selection matched no pairs (set=%s)\n' "${requested_set:-all}" >&2
  exit 2
fi

failures=0
fail() {
  failures=$((failures + 1))
  printf 'FAIL %s\n' "$1"
}

# A file whose sibling is missing is a parity failure, not something to skip.
while IFS="$(printf '\t')" read -r orphan_path orphan_reason; do
  fail "hyper-skill:$orphan_path: $orphan_reason"
done <"$ORPHANS_FILE"

# Every selected pair must resolve to real files before anything is listed or checked.
BROKEN="$WORKDIR/broken.pairs"
: >"$BROKEN"
while IFS="$(printf '\t')" read -r pair_set pair_root pair_en pair_ko; do
  for rel in "$pair_en" "$pair_ko"; do
    if [ ! -f "$pair_root/$rel" ]; then
      fail "$pair_set:$pair_en: $rel is missing or not a regular file"
      printf '%s:%s\n' "$pair_set" "$pair_en" >>"$BROKEN"
    fi
  done
done <"$SELECTED"

has_list=0
i=0
while [ "$i" -lt "$argc" ]; do
  if [ "${args[$i]}" = "--list" ]; then
    has_list=1
  fi
  i=$((i + 1))
done

if [ "$has_list" -eq 1 ]; then
  while IFS="$(printf '\t')" read -r pair_set pair_root pair_en pair_ko; do
    printf '%s\t%s\t%s\t%s\n' "$pair_set" "$pair_root" "$pair_en" "$pair_ko"
  done <"$SELECTED"
  if [ "$failures" -eq 0 ]; then
    exit 0
  fi
  exit 1
fi

extract_ids() {
  sed -nE 's/^- (SK-[A-Z])-([0-9]+):.*/\1-\2/p' "$1" | awk '!seen[$0]++'
}

sources_error() {
  awk '
    {
      n++
      line[n] = $0
      if (at == 0 && $0 ~ /^## ([0-9]+\. )?Sources[ \t\r]*$/) at = n
    }
    END {
      if (at == 0) {
        print "no Sources section"
        exit
      }
      ok = 0
      for (i = at; i <= at + 5 && i <= n; i++) {
        if (line[i] ~ /^> .*([Cc][Hh][Ee][Cc][Kk][Ee][Dd]|확인)[ \t\r]+[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) {
          ok = 1
          break
        }
      }
      if (!ok) print "Sources section has no checked-date line"
    }
  ' "$1"
}

numbering_gaps() {
  awk '
    function trim(s) {
      sub(/^[ \t\r\n]+/, "", s)
      sub(/[ \t\r\n]+$/, "", s)
      return s
    }
    BEGIN { cur = "(preamble)" }
    {
      line = $0
      if (line ~ /^## /) {
        cur = trim(line)
        if (!(cur in sec_seen)) {
          sec_seen[cur] = 1
          sec_order[++nsec] = cur
        }
        next
      }
      if (line !~ /^- SK-[A-Z]-[0-9]+:/) next
      rest = substr(line, 3)
      letter = "SK-" substr(rest, 4, 1)
      digits = substr(rest, 6)
      sub(/:.*/, "", digits)
      if (!(cur in sec_seen)) {
        sec_seen[cur] = 1
        sec_order[++nsec] = cur
      }
      key = cur SUBSEP letter
      if (!(key in letter_seen)) {
        letter_seen[key] = 1
        lcount[cur]++
        lorder[cur, lcount[cur]] = letter
      }
      if (key in numbers) numbers[key] = numbers[key] "," digits
      else numbers[key] = digits
    }
    END {
      for (s = 1; s <= nsec; s++) {
        sec = sec_order[s]
        for (l = 1; l <= lcount[sec]; l++) {
          letter = lorder[sec, l]
          key = sec SUBSEP letter
          n = split(numbers[key], a, ",")
          for (i = 2; i <= n; i++) {
            v = a[i] + 0
            j = i - 1
            while (j >= 1 && (a[j] + 0) > v) {
              a[j + 1] = a[j]
              j--
            }
            a[j + 1] = v
          }
          sorted = ""
          expected = ""
          for (i = 1; i <= n; i++) {
            sorted = sorted (i > 1 ? "," : "") sprintf("%d", a[i] + 0)
            expected = expected (i > 1 ? "," : "") i
          }
          if (sorted != expected) {
            printf "%s :: %s has [%s], expected [%s]\n", sec, letter, sorted, expected
          }
        }
      }
    }
  ' "$1"
}

count_sections() {
  grep -c '^## ' "$1" 2>/dev/null || true
}

while IFS="$(printf '\t')" read -r pair_set pair_root pair_en pair_ko; do
  if grep -Fxq -- "$pair_set:$pair_en" "$BROKEN" 2>/dev/null; then
    continue
  fi
  label="$pair_set:$pair_en"
  en_path="$pair_root/$pair_en"
  ko_path="$pair_root/$pair_ko"
  if [ ! -e "$en_path" ]; then
    fail "$label: missing"
    continue
  fi
  if [ ! -e "$ko_path" ]; then
    fail "$label: $pair_ko missing"
    continue
  fi

  en_ids="$WORKDIR/en.ids"
  ko_ids="$WORKDIR/ko.ids"
  extract_ids "$en_path" >"$en_ids"
  extract_ids "$ko_path" >"$ko_ids"

  if [ -s "$ko_ids" ]; then
    missing_in_ko=$(grep -vxF -f "$ko_ids" "$en_ids")
  else
    missing_in_ko=$(cat "$en_ids")
  fi
  while IFS= read -r id; do
    if [ -n "$id" ]; then
      fail "$label: $pair_ko missing id $id"
    fi
  done <<EOF
$missing_in_ko
EOF

  if [ -s "$en_ids" ]; then
    missing_in_en=$(grep -vxF -f "$en_ids" "$ko_ids")
  else
    missing_in_en=$(cat "$ko_ids")
  fi
  while IFS= read -r id; do
    if [ -n "$id" ]; then
      fail "$label: $pair_en missing id $id"
    fi
  done <<EOF
$missing_in_en
EOF

  en_sections=$(count_sections "$en_path")
  ko_sections=$(count_sections "$ko_path")
  if [ "$en_sections" != "$ko_sections" ]; then
    fail "$label: $pair_en has $en_sections sections, $pair_ko has $ko_sections"
  fi

  for side in "$pair_en:$en_path" "$pair_ko:$ko_path"; do
    side_name="${side%%:*}"
    side_path="${side#*:}"
    src_err=$(sources_error "$side_path")
    if [ -n "$src_err" ]; then
      fail "$label: $side_name: $src_err"
    fi
    while IFS= read -r gap; do
      if [ -n "$gap" ]; then
        fail "$label: $side_name: $gap"
      fi
    done <<EOF
$(numbering_gaps "$side_path")
EOF
  done
done <"$SELECTED"

printf 'PARITY-FAILURES=%s\n' "$failures"
if [ "$failures" -eq 0 ]; then
  exit 0
fi
exit 1
