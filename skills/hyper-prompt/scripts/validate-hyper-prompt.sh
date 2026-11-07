#!/usr/bin/env bash
# Validate the repository-local hyper-prompt package.
#
# Requires bash 3.2+ and jq 1.6+. No bun/node dependency.
set -euo pipefail
shopt -s dotglob nullglob

DEFAULT_ROOT="skills/hyper-prompt"

REQUIRED_MARKERS=(
  output_language
  purpose
  routing_rule
  instruction_contract
  activation_examples
  trigger_conditions
  skill_architecture
  loop_policy
  language_and_translation_default
  reference_routing
  support_file_read_order
  workflow
  required
  forbidden
  validation
)
CONTRACT_LABELS=(
  Intent
  Trigger
  Scope
  Authority
  Evidence
  Tools
  Output
  Verification
  "Stop condition"
)
ACTIVATION_LABELS=(positive negative boundary)
ACTIVATION_FLOORS=(3 2 1)
CATEGORIES=(positive negative boundary workflow source safety regression adversarial coexistence)
CAT_FLOORS=(1 1 1 1 1 1 1 1 0)
RICH_CAT_FLOORS=(3 2 2 2 2 2 2 2 0)
LANGUAGES=(en ko mixed)
LANG_FLOORS=(1 1 1)
INVOCATIONS=(explicit implicit contextual)
INV_FLOORS=(1 1 1)
REQUIRED_TEMPLATES=(
  assets/prompt-pack.template.md
  assets/prompt-pack.template.ko.md
  assets/source-ledger.template.md
  assets/source-ledger.template.ko.md
  assets/eval-harness.template.json
)
CONCEPT_NAMES=(
  identity
  variables
  "context packet"
  examples
  constraints
  "output schema"
  "eval cases"
  "version note"
)
# Word boundaries are spelled out because POSIX ERE has no \b.
CONCEPT_PATTERNS=(
  '(^|[^A-Za-z0-9_])identity([^A-Za-z0-9_]|$)'
  '(^|[^A-Za-z0-9_])variables?([^A-Za-z0-9_]|$)'
  '(^|[^A-Za-z0-9_])context[- ]packet([^A-Za-z0-9_]|$)'
  '(^|[^A-Za-z0-9_])examples?([^A-Za-z0-9_]|$)'
  '(^|[^A-Za-z0-9_])constraints?([^A-Za-z0-9_]|$)'
  '(^|[^A-Za-z0-9_])output[- ]schema([^A-Za-z0-9_]|$)'
  '(^|[^A-Za-z0-9_])(eval[- ]cases?|evaluation[- ]cases?)([^A-Za-z0-9_]|$)'
  '(^|[^A-Za-z0-9_])version[- ]note([^A-Za-z0-9_]|$)'
)
TILDE="~"
FORBIDDEN_PHRASES=(
  "${TILDE}/.agents"
  "${TILDE}/.codex"
  "/Users/"
  "global skill dir"
)

CATEGORIES_JSON=$(printf '%s\n' "${CATEGORIES[@]}" | jq -R . | jq -s -c .)
MARKER_KEYS_JSON=$(printf '%s\n' "${REQUIRED_MARKERS[@]}" | jq -R . | jq -s -c .)
LABEL_KEYS_JSON=$(printf '%s\n' "${CONTRACT_LABELS[@]}" | jq -R . | jq -s -c .)
CONCEPT_KEYS_JSON=$(printf '%s\n' "${CONCEPT_NAMES[@]}" | jq -R . | jq -s -c .)

CWD=$(pwd -P)

ERRFILE=""
ERR_COUNT=0
TMPFILES=()

cleanup() {
  local f
  for f in "${TMPFILES[@]+"${TMPFILES[@]}"}"; do
    [ -n "$f" ] && rm -f "$f"
  done
  return 0
}
trap cleanup EXIT

new_tmpfile() {
  local f
  f=$(mktemp "${TMPDIR:-/tmp}/validate-hyper-prompt.XXXXXX")
  TMPFILES+=("$f")
  printf '%s' "$f"
}

# ---------------------------------------------------------------- path utils

# normalize_path <path> <absolute: 0|1>
normalize_path() {
  local rest=$1 absolute=$2 out="" part
  local -a parts=()
  local n=0 i=0
  rest=${rest#/}
  while [ -n "$rest" ]; do
    part=${rest%%/*}
    case $rest in
      */*) rest=${rest#*/} ;;
      *) rest="" ;;
    esac
    case $part in
      ''|.) ;;
      ..)
        if [ "$n" -gt 0 ] && [ "${parts[$((n - 1))]}" != ".." ]; then
          n=$((n - 1))
        elif [ "$absolute" = "0" ]; then
          parts[n]=".."
          n=$((n + 1))
        fi
        ;;
      *)
        parts[n]=$part
        n=$((n + 1))
        ;;
    esac
  done
  while [ "$i" -lt "$n" ]; do
    if [ -z "$out" ]; then
      out=${parts[$i]}
    else
      out="$out/${parts[$i]}"
    fi
    i=$((i + 1))
  done
  if [ "$absolute" = "1" ]; then
    if [ -z "$out" ]; then out="/"; else out="/$out"; fi
  elif [ -z "$out" ]; then
    out="."
  fi
  printf '%s' "$out"
}

abs_path() {
  case $1 in
    /*) normalize_path "$1" 1 ;;
    '') printf '%s' "$CWD" ;;
    *) normalize_path "$CWD/$1" 1 ;;
  esac
}

join_path() { # <left> <right>
  case $1 in
    /*) normalize_path "$1/$2" 1 ;;
    *) normalize_path "$1/$2" 0 ;;
  esac
}

dirname_of() {
  case $1 in
    /) printf '/' ;;
    */*)
      local head=${1%/*}
      if [ -z "$head" ]; then printf '/'; else printf '%s' "$head"; fi
      ;;
    *) printf '.' ;;
  esac
}

# split_components <path> -> fills SPLIT_PARTS / SPLIT_COUNT
SPLIT_PARTS=()
SPLIT_COUNT=0
split_components() {
  local rest=$1 part
  SPLIT_PARTS=()
  SPLIT_COUNT=0
  rest=${rest#/}
  while [ -n "$rest" ]; do
    part=${rest%%/*}
    case $rest in
      */*) rest=${rest#*/} ;;
      *) rest="" ;;
    esac
    SPLIT_PARTS[SPLIT_COUNT]=$part
    SPLIT_COUNT=$((SPLIT_COUNT + 1))
  done
}

# rel_path <from> <to> : path.relative equivalent for absolute POSIX paths
rel_path() {
  local from=$1 to=$2 i=0 j out=""
  local -a fa=() ta=()
  local fn tn x
  split_components "$from"
  fn=$SPLIT_COUNT
  for x in "${SPLIT_PARTS[@]+"${SPLIT_PARTS[@]}"}"; do fa+=("$x"); done
  split_components "$to"
  tn=$SPLIT_COUNT
  for x in "${SPLIT_PARTS[@]+"${SPLIT_PARTS[@]}"}"; do ta+=("$x"); done
  while [ "$i" -lt "$fn" ] && [ "$i" -lt "$tn" ] && [ "${fa[$i]}" = "${ta[$i]}" ]; do
    i=$((i + 1))
  done
  j=$i
  while [ "$j" -lt "$fn" ]; do
    out="$out/.."
    j=$((j + 1))
  done
  while [ "$j" -lt "$tn" ]; do
    out="$out/${ta[$j]}"
    j=$((j + 1))
  done
  # built with a leading separator; drop it for a plain relative result
  printf '%s' "${out#/}"
}

display_path() {
  local rel
  rel=$(rel_path "$CWD" "$1")
  if [ -z "$rel" ]; then printf '%s' "$1"; else printf '%s' "$rel"; fi
}

is_inside() { # root target
  local rel
  rel=$(rel_path "$1" "$2")
  if [ -z "$rel" ]; then return 0; fi
  case $rel in
    ..*) return 1 ;;
    *) return 0 ;;
  esac
}

exists() { [ -e "$1" ]; }

# ------------------------------------------------------------- json helpers

join_json() { # items already valid JSON
  local out="" v
  for v in "$@"; do out="$out${out:+,}$v"; done
  printf '[%s]' "$out"
}

strings_json() { # raw strings, JSON-encoded
  local out="" v
  for v in "$@"; do out="$out${out:+,}$(printf '%s' "$v" | jq -Rs .)"; done
  printf '[%s]' "$out"
}

array_contains() { # needle values...
  local needle=$1 v
  shift
  for v in "$@"; do
    if [ "$v" = "$needle" ]; then return 0; fi
  done
  return 1
}

zip_object() { # <keys json> <values json>
  jq -cn --argjson keys "$1" --argjson vals "$2" \
    '[range(0; ($keys | length)) as $i | {key: $keys[$i], value: $vals[$i]}] | from_entries'
}

bool_values_json() {
  local out="" b
  for b in "$@"; do out="$out${out:+,}$b"; done
  printf '[%s]' "$out"
}

int_values_json() {
  local out="" b
  for b in "$@"; do out="$out${out:+,}$b"; done
  printf '[%s]' "$out"
}

push_error_raw() { # compact JSON error object
  printf '%s\n' "$1" >> "$ERRFILE"
  ERR_COUNT=$((ERR_COUNT + 1))
}

push_error() { # code message extra-json
  local obj
  obj=$(jq -cn --arg code "$1" --arg message "$2" --argjson extra "$3" \
    '{code: $code, message: $message} + $extra')
  push_error_raw "$obj"
}

escape_ere() {
  printf '%s' "$1" | sed 's/[][\.^$*+?(){}|]/\\&/g'
}

contains_ci() { # haystack needle(lower-case ascii)
  case $1 in
    *"$2"*) return 0 ;;
    *) return 1 ;;
  esac
}

# --------------------------------------------------------------- file walk

FILES=()

collect_files() {
  local dir=$1 entry dp
  if [ ! -r "$dir" ]; then
    dp=$(display_path "$dir")
    push_error DIR_READ_FAILED "Cannot read directory: $dp" \
      "$(jq -cn --arg p "$dp" --arg d "EACCES: permission denied, scandir '$dir'" '{path: $p, detail: $d}')"
    return 0
  fi
  for entry in "$dir"/*; do
    if [ -L "$entry" ]; then
      continue
    fi
    if [ -d "$entry" ]; then
      collect_files "$entry"
    elif [ -f "$entry" ]; then
      FILES+=("$entry")
    fi
  done
}

sort_files() {
  local f line sorted
  if [ "${#FILES[@]}" -eq 0 ]; then
    return 0
  fi
  sorted=$(new_tmpfile)
  for f in "${FILES[@]}"; do printf '%s\n' "$f"; done | LC_ALL=C sort > "$sorted"
  FILES=()
  while IFS= read -r line; do
    FILES+=("$line")
  done < "$sorted"
}

markdown_files() {
  local f
  MARKDOWN=()
  for f in "${FILES[@]+"${FILES[@]}"}"; do
    case $f in
      *.md) MARKDOWN+=("$f") ;;
    esac
  done
}

# ------------------------------------------------------------- skill checks

MARKER_FOUND=()
LABEL_FOUND=()
LOOP_FOUND=false
ACT_COUNTS=()
SKILL_JSON=""

count_word() { # text word
  printf '%s' "$1" | LC_ALL=C awk -v w="$2" '
    { n = split($0, a, /[^A-Za-z0-9_]+/); for (i = 1; i <= n; i++) if (tolower(a[i]) == w) c++ }
    END { print c + 0 }'
}

parse_frontmatter() { # text -> echoes frontmatter, exit 1 if absent
  local text=$1 rest
  case $text in
    "---"$'\n'*) ;;
    *) return 1 ;;
  esac
  rest=${text#---$'\n'}
  case $rest in
    *$'\n---'*) ;;
    *) return 1 ;;
  esac
  printf '%s' "${rest%%$'\n---'*}"
}

validate_skill_file() {
  local root=$1 skill_path text i found fm pattern label
  skill_path="$root/SKILL.md"
  local exists_flag=false fm_flag=false acts_have_values=false
  MARKER_FOUND=()
  LABEL_FOUND=()
  LOOP_FOUND=false
  ACT_COUNTS=()
  for i in "${!REQUIRED_MARKERS[@]}"; do MARKER_FOUND[i]=false; done
  for i in "${!CONTRACT_LABELS[@]}"; do LABEL_FOUND[i]=false; done
  for i in "${!ACTIVATION_LABELS[@]}"; do ACT_COUNTS[i]=0; done

  if [ ! -e "$skill_path" ]; then
    push_error SKILL_MISSING "SKILL.md is missing" '{"path":"SKILL.md"}'
  else
    exists_flag=true
    acts_have_values=true
    text=$(cat "$skill_path")
    if ! fm=$(parse_frontmatter "$text"); then
      push_error FRONTMATTER_MISSING "SKILL.md must start with closed YAML frontmatter" '{"path":"SKILL.md"}'
    elif grep -Eq '^name:[[:space:]]*hyper-prompt[[:space:]]*$' <<< "$fm"; then
      fm_flag=true
    else
      push_error NAME_MISMATCH "SKILL.md frontmatter must contain name: hyper-prompt" '{"path":"SKILL.md"}'
    fi

    for i in "${!REQUIRED_MARKERS[@]}"; do
      marker=$(escape_ere "${REQUIRED_MARKERS[$i]}")
      pattern="^##[[:space:]]+${marker}[[:space:]]*\$"
      tag_pattern="^<${marker}>[[:space:]]*\$"
      if grep -Eiq "$pattern" "$skill_path" || grep -Eiq "$tag_pattern" "$skill_path"; then
        MARKER_FOUND[i]=true
      else
        push_error MARKER_MISSING "Required SKILL.md marker is missing: ## ${REQUIRED_MARKERS[$i]} or <${REQUIRED_MARKERS[$i]}>" \
          "$(jq -cn --arg m "${REQUIRED_MARKERS[$i]}" '{path: "SKILL.md", marker: $m}')"
      fi
    done

    for i in "${!CONTRACT_LABELS[@]}"; do
      label=${CONTRACT_LABELS[$i]}
      pattern="(^|[^A-Za-z0-9_])$(escape_ere "$label")([^A-Za-z0-9_]|\$)"
      if grep -Eiq "$pattern" "$skill_path"; then
        LABEL_FOUND[i]=true
      else
        push_error CONTRACT_LABEL_MISSING "Required contract label is missing: $label" \
          "$(jq -cn --arg l "$label" '{path: "SKILL.md", label: $l}')"
      fi
    done
    if grep -Fq '## artifact_levels' "$skill_path" || grep -Fq '<artifact_levels>' "$skill_path"; then
      if grep -Eiq '(^|[^A-Za-z0-9_])Loop([^A-Za-z0-9_]|$)' "$skill_path"; then
        LOOP_FOUND=true
      else
        push_error CONTRACT_LABEL_MISSING "Required contract label is missing: Loop" \
          '{"path":"SKILL.md","label":"Loop"}'
      fi
    fi

    for i in "${!ACTIVATION_LABELS[@]}"; do
      found=$(count_word "$text" "${ACTIVATION_LABELS[$i]}")
      ACT_COUNTS[i]=$found
      if [ "$found" -lt "${ACTIVATION_FLOORS[$i]}" ]; then
        push_error ACTIVATION_EXAMPLE_COUNT \
          "Expected at least ${ACTIVATION_FLOORS[$i]} ${ACTIVATION_LABELS[$i]} activation example label(s)" \
          "$(jq -cn --arg l "${ACTIVATION_LABELS[$i]}" --argjson e "${ACTIVATION_FLOORS[$i]}" --argjson a "$found" \
            '{path: "SKILL.md", label: $l, expected: $e, actual: $a}')"
      fi
    done
  fi

  local labels_json acts_json
  if [ "$acts_have_values" = "true" ]; then
    acts_json=$(zip_object "$(printf '%s\n' "${ACTIVATION_LABELS[@]}" | jq -R . | jq -s -c .)" "$(int_values_json "${ACT_COUNTS[@]}")")
  else
    acts_json='{}'
  fi
  labels_json=$(zip_object "$LABEL_KEYS_JSON" "$(bool_values_json "${LABEL_FOUND[@]}")")
  if [ "$LOOP_FOUND" = "true" ]; then
    labels_json=$(jq -cn --argjson base "$labels_json" '$base + {Loop: true}')
  fi
  SKILL_JSON=$(jq -cn \
    --argjson exists "$exists_flag" \
    --argjson fm "$fm_flag" \
    --argjson markers "$(zip_object "$MARKER_KEYS_JSON" "$(bool_values_json "${MARKER_FOUND[@]}")")" \
    --argjson labels "$labels_json" \
    --argjson acts "$acts_json" \
    '{exists: $exists, frontmatterName: $fm, markers: $markers, contractLabels: $labels, activationExamples: $acts}')
}

# ------------------------------------------------------------------- links

# shellcheck disable=SC2016 # awk program body
AT_AWK='
{
  line = $0; L = length(line); i = 1
  while (i <= L) {
    c = substr(line, i, 1)
    if (c == "@") {
      ok = (i == 1)
      if (!ok) {
        prev = substr(line, i - 1, 1)
        if (index("`(> \t\r\f\v", prev) > 0) ok = 1
      }
      if (ok) {
        rest = substr(line, i + 1)
        if (rest ~ /^(rules|references)\//) {
          j = i + 1
          while (j <= L) {
            ch = substr(line, j, 1)
            if (ch == "`" || ch == ")" || ch == "]" || ch == "#" || ch == " " || ch == "\t" || ch == "\r" || ch == "\f" || ch == "\v") break
            j++
          }
          print substr(line, i + 1, j - i - 1)
          i = j
          continue
        }
      }
    }
    i++
  }
}
'

# shellcheck disable=SC2016 # awk program body
MD_AWK='
{
  line = $0; L = length(line); i = 1
  while (i <= L - 1) {
    k = index(substr(line, i), "](")
    if (k == 0) break
    j = i + k - 1
    ok = 0; p = j - 1
    while (p >= 1) {
      ch = substr(line, p, 1)
      if (ch == "[") { ok = 1; break }
      if (ch == "]") { ok = 0; break }
      p--
    }
    if (!ok) { i = j + 2; continue }
    q = j + 2
    if (q > L) { i = j + 2; continue }
    start = q
    while (q <= L) {
      ch = substr(line, q, 1)
      if (ch == ")" || ch == " " || ch == "\t" || ch == "\r" || ch == "\f" || ch == "\v") break
      q++
    }
    if (q == start) { i = j + 2; continue }
    href = substr(line, start, q - start)
    if (q <= L && substr(line, q, 1) == ")") { print href; i = q + 1; continue }
    t = q
    while (t <= L) {
      ch = substr(line, t, 1)
      if (ch == " " || ch == "\t" || ch == "\r" || ch == "\f" || ch == "\v") t++; else break
    }
    if (t > q && t <= L && substr(line, t, 1) == "\"") {
      t++
      while (t <= L && substr(line, t, 1) != "\"") t++
      if (t <= L) {
        t++
        if (t <= L && substr(line, t, 1) == ")") { print href; i = t + 1; continue }
      }
    }
    i = j + 2
  }
}
'

decode_uri() {
  local s=$1 out="" c hex
  case $s in
    *%*) ;;
    *) printf '%s' "$s"; return 0 ;;
  esac
  while [ -n "$s" ]; do
    c=${s:0:1}
    if [ "$c" = "%" ] && [ "${#s}" -ge 3 ]; then
      hex=${s:1:2}
      case $hex in
        *[!0-9A-Fa-f]*)
          out="$out%"
          s=${s:1}
          ;;
        *)
          printf -v c '%b' "\\x$hex"
          out="$out$c"
          s=${s:3}
          ;;
      esac
    else
      out="$out$c"
      s=${s:1}
    fi
  done
  printf '%s' "$out"
}

resolve_reference() { # root file href
  local root=$1 file=$2 href=$3
  case $href in
    /*) normalize_path "$root$href" 1 ;;
    rules/*|references/*|assets/*) normalize_path "$root/$href" 1 ;;
    *) normalize_path "$(dirname_of "$file")/$href" 1 ;;
  esac
}

LINK_CHECKED=0
LINK_MISSING_ITEMS=()

extract_at_refs() { LC_ALL=C awk "$AT_AWK" "$1"; }
extract_md_refs() { LC_ALL=C awk "$MD_AWK" "$1"; }

validate_links() {
  local root=$1 file rel href clean target localized
  LINK_CHECKED=0
  LINK_MISSING_ITEMS=()
  for file in "${MARKDOWN[@]+"${MARKDOWN[@]}"}"; do
    rel=$(rel_path "$root" "$file")
    while IFS= read -r href; do
      case $(LC_ALL=C printf '%s' "$href" | tr '[:upper:]' '[:lower:]') in
        http:*|https:*|mailto:*|tel:*|'#'*) continue ;;
      esac
      clean=${href%%#*}
      [ -n "$clean" ] || continue
      target=$(resolve_reference "$root" "$file" "$(decode_uri "$clean")")
      LINK_CHECKED=$((LINK_CHECKED + 1))
      if ! is_inside "$root" "$target" || ! exists "$target"; then
        LINK_MISSING_ITEMS+=("$(jq -cn --arg from "$rel" --arg href "$href" --arg resolved "$(display_path "$target")" \
          '{from: $from, href: $href, resolved: $resolved}')")
        push_error LINK_MISSING "Local package reference does not resolve: $rel -> $href" \
          "$(jq -cn --arg from "$rel" --arg href "$href" --arg resolved "$(display_path "$target")" \
            '{from: $from, href: $href, resolved: $resolved}')"
        continue
      fi
      case $rel in
        *.ko.md)
          case $clean in
            *.md)
              case $clean in
                *.ko.md) ;;
                *)
                  localized="${target%.md}.ko.md"
                  if exists "$localized"; then
                    push_error LOCALIZED_LINK_EXPECTED \
                      "Korean markdown must link the localized support file when one exists: $rel -> $href" \
                      "$(jq -cn --arg from "$rel" --arg href "$href" --arg expected "$(rel_path "$root" "$localized")" \
                        '{from: $from, href: $href, expected: $expected}')"
                  fi
                  ;;
              esac
              ;;
          esac
          ;;
      esac
    done < <(extract_at_refs "$file"; extract_md_refs "$file")
  done
}

# ------------------------------------------------------------- code fences

# shellcheck disable=SC2016 # awk program body
FENCE_AWK='
{
  line = $0
  if (match(line, /^[ \t\r\f\v]*[`~]+/)) {
    seg = substr(line, RSTART, RLENGTH)
    p = 1
    while (p <= length(seg) && substr(seg, p, 1) ~ /[ \t\r\f\v]/) p++
    ch = substr(seg, p, 1)
    count = 0
    while (substr(seg, p + count, 1) == ch) count++
    if (count >= 3) {
      if (depth > 0 && stackmark[depth] == ch && stacklen[depth] >= count) {
        depth--
      } else {
        depth++
        stackmark[depth] = ch
        stacklen[depth] = count
        stackline[depth] = NR
      }
    }
  }
}
END {
  for (i = 1; i <= depth; i++) printf "%s\t%d\t%d\n", stackmark[i], stacklen[i], stackline[i]
}
'

FENCE_CHECKED=0
FENCE_INVALID_ITEMS=()

validate_code_fences() {
  local root=$1 file rel rows item unclosed
  FENCE_CHECKED=0
  FENCE_INVALID_ITEMS=()
  for file in "${MARKDOWN[@]+"${MARKDOWN[@]}"}"; do
    rel=$(rel_path "$root" "$file")
    FENCE_CHECKED=$((FENCE_CHECKED + 1))
    rows=$(LC_ALL=C awk "$FENCE_AWK" "$file")
    if [ -n "$rows" ]; then
      unclosed=""
      while IFS=$'\t' read -r marker length line; do
        [ -n "$marker" ] || continue
        unclosed="$unclosed${unclosed:+,}$(jq -cn --arg m "$marker" --argjson l "$length" --argjson n "$line" \
          '{marker: $m, length: $l, line: $n}')"
      done <<< "$rows"
      item=$(jq -cn --arg p "$rel" --argjson u "[$unclosed]" '{path: $p, unclosed: $u}')
      FENCE_INVALID_ITEMS+=("$item")
      push_error CODE_FENCE_UNBALANCED "Unbalanced fenced code block in $rel" "$item"
    fi
  done
}

# ---------------------------------------------------------- bilingual pairs

BILINGUAL_MISSING=()
BILINGUAL_ORPHAN=()
BILINGUAL_CHECKED=0

validate_bilingual_pairs() {
  local root=$1 file rel english korean
  local -a eligible=()
  BILINGUAL_MISSING=()
  BILINGUAL_ORPHAN=()
  for file in "${MARKDOWN[@]+"${MARKDOWN[@]}"}"; do
    rel=$(rel_path "$root" "$file")
    case $rel in
      assets/evals/*) ;;
      *) eligible+=("$rel") ;;
    esac
  done
  BILINGUAL_CHECKED=${#eligible[@]}
  for rel in "${eligible[@]+"${eligible[@]}"}"; do
    case $rel in
      *.ko.md)
        english="${rel%.ko.md}.md"
        if ! array_contains "$english" "${eligible[@]+"${eligible[@]}"}"; then
          BILINGUAL_ORPHAN+=("$rel")
          push_error BILINGUAL_PAIR_ORPHAN "Korean markdown file has no English pair: $rel" \
            "$(jq -cn --arg p "$rel" --arg e "$english" '{path: $p, expected: $e}')"
        fi
        ;;
      *)
        korean="${rel%.md}.ko.md"
        if ! array_contains "$korean" "${eligible[@]+"${eligible[@]}"}"; then
          BILINGUAL_MISSING+=("$korean")
          push_error BILINGUAL_PAIR_MISSING "English markdown file has no Korean pair: $rel" \
            "$(jq -cn --arg p "$rel" --arg e "$korean" '{path: $p, expected: $e}')"
        fi
        ;;
    esac
  done
}

# --------------------------------------------------------------- stray docs

STRAY_FOUND=()

validate_stray_docs() {
  local root=$1 file rel name hit
  STRAY_FOUND=()
  for file in "${FILES[@]+"${FILES[@]}"}"; do
    name=${file##*/}
    hit=false
    case $name in
      README.md|CHANGELOG.md|QUICK_REFERENCE.md) hit=true ;;
    esac
    [ "$hit" = "true" ] || continue
    rel=$(rel_path "$root" "$file")
    STRAY_FOUND+=("$rel")
    push_error STRAY_DOC "Stray broad documentation file is not allowed: $rel" \
      "$(jq -cn --arg p "$rel" '{path: $p}')"
  done
}

# -------------------------------------------------------- authority refs

AUTH_HITS=()

is_text_like() {
  local ext
  ext=${1##*.}
  case $(LC_ALL=C printf '%s' "$ext" | tr '[:upper:]' '[:lower:]') in
    md|markdown|txt|json|jsonl|mjs|js|yaml|yml) return 0 ;;
    *) return 1 ;;
  esac
}

validate_authority_references() {
  local root=$1 file rel text lower phrase phrase_lower
  AUTH_HITS=()
  for file in "${FILES[@]+"${FILES[@]}"}"; do
    is_text_like "$file" || continue
    rel=$(rel_path "$root" "$file")
    text=$(cat "$file")
    lower=$(LC_ALL=C printf '%s' "$text" | tr '[:upper:]' '[:lower:]')
    for phrase in "${FORBIDDEN_PHRASES[@]}"; do
      phrase_lower=$(LC_ALL=C printf '%s' "$phrase" | tr '[:upper:]' '[:lower:]')
      if contains_ci "$lower" "$phrase_lower"; then
        AUTH_HITS+=("$(jq -cn --arg p "$rel" --arg ph "$phrase" '{path: $p, phrase: $ph}')")
        push_error GLOBAL_AUTHORITY_REFERENCE "Forbidden global or home authority reference in $rel" \
          "$(jq -cn --arg p "$rel" --arg ph "$phrase" '{path: $p, phrase: $ph}')"
      fi
    done
  done
}

# ---------------------------------------------------------------- templates

TEMPLATE_PRESENT=()
TEMPLATE_MISSING=()
TEMPLATE_CONCEPTS=()

validate_templates() {
  local root=$1 rel file i ok
  local -a present_paths=()
  TEMPLATE_PRESENT=()
  TEMPLATE_MISSING=()
  for rel in "${REQUIRED_TEMPLATES[@]}"; do
    file="$root/$rel"
    if ! exists "$file"; then
      TEMPLATE_MISSING+=("$rel")
      push_error TEMPLATE_MISSING "Required template is missing: $rel" \
        "$(jq -cn --arg p "$rel" '{path: $p}')"
      continue
    fi
    TEMPLATE_PRESENT+=("$rel")
    present_paths+=("$file")
  done

  local -a found=()
  for i in "${!CONCEPT_NAMES[@]}"; do
    ok=false
    if [ "${#present_paths[@]}" -gt 0 ] &&
      grep -Eiq "${CONCEPT_PATTERNS[$i]}" "${present_paths[@]+"${present_paths[@]}"}"; then
      ok=true
    else
      push_error TEMPLATE_CONCEPT_MISSING "Required template concept is missing: ${CONCEPT_NAMES[$i]}" \
        "$(jq -cn --arg c "${CONCEPT_NAMES[$i]}" '{concept: $c}')"
    fi
    found[i]=$ok
  done
  TEMPLATE_CONCEPTS=("${found[@]}")
}

# ------------------------------------------------------------------- evals

# shellcheck disable=SC2016 # awk program body
JSON_VALIDATOR_AWK='
{
  s = $0; n = length(s); bad = 0; d = 0
  p = parse_value(1)
  if (p < 0) bad = 1
  else { p = skipws(p); if (p <= n) bad = 1 }
  exit (bad ? 1 : 0)
}
function skipws(i) {
  while (i <= n && (substr(s, i, 1) == " " || substr(s, i, 1) == "\t" || substr(s, i, 1) == "\r")) i++
  return i
}
function parse_value(i,  c) {
  i = skipws(i)
  if (i > n) return -1
  c = substr(s, i, 1)
  if (c == "{") return parse_object(i + 1)
  if (c == "[") return parse_array(i + 1)
  if (c == "\"") return parse_string(i + 1)
  if (c == "t") return parse_lit(i, "true")
  if (c == "f") return parse_lit(i, "false")
  if (c == "n") return parse_lit(i, "null")
  if (c == "-" || c ~ /[0-9]/) return parse_number(i)
  return -1
}
function parse_lit(i, lit,  k) {
  k = length(lit)
  if (substr(s, i, k) == lit) return i + k
  return -1
}
function parse_number(i,  c) {
  if (substr(s, i, 1) == "-") i++
  c = substr(s, i, 1)
  if (c == "0") i++
  else if (c ~ /[1-9]/) { while (substr(s, i, 1) ~ /[0-9]/) i++ }
  else return -1
  if (substr(s, i, 1) == ".") {
    i++
    if (substr(s, i, 1) !~ /[0-9]/) return -1
    while (substr(s, i, 1) ~ /[0-9]/) i++
  }
  c = substr(s, i, 1)
  if (c == "e" || c == "E") {
    i++
    c = substr(s, i, 1)
    if (c == "+" || c == "-") i++
    if (substr(s, i, 1) !~ /[0-9]/) return -1
    while (substr(s, i, 1) ~ /[0-9]/) i++
  }
  return i
}
function parse_string(i,  c, e) {
  while (i <= n) {
    c = substr(s, i, 1)
    if (c == "\"") return i + 1
    if (c == "\\") {
      e = substr(s, i + 1, 1)
      if (e == "\"" || e == "\\" || e == "/" || e == "b" || e == "f" || e == "n" || e == "r" || e == "t") i += 2
      else if (e == "u") {
        if (substr(s, i + 2, 4) !~ /^[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]$/) return -1
        i += 6
      } else return -1
    } else if (c ~ /[\001-\037]/) return -1
    else i++
  }
  return -1
}
function parse_object(i,  c) {
  d++
  if (d > 1000) return -1
  i = skipws(i)
  if (substr(s, i, 1) == "}") return i + 1
  while (1) {
    i = skipws(i)
    if (substr(s, i, 1) != "\"") return -1
    i = parse_string(i + 1)
    if (i < 0) return -1
    i = skipws(i)
    if (substr(s, i, 1) != ":") return -1
    i = parse_value(i + 1)
    if (i < 0) return -1
    i = skipws(i)
    c = substr(s, i, 1)
    if (c == ",") { i++; continue }
    if (c == "}") return i + 1
    return -1
  }
}
function parse_array(i,  c) {
  d++
  if (d > 1000) return -1
  i = skipws(i)
  if (substr(s, i, 1) == "]") return i + 1
  while (1) {
    i = parse_value(i)
    if (i < 0) return -1
    i = skipws(i)
    c = substr(s, i, 1)
    if (c == ",") { i++; continue }
    if (c == "]") return i + 1
    return -1
  }
}
'

# shellcheck disable=SC2016 # jq program body
ROW_JQ='
def ne: (type == "string") and (test("\\S"));
def tr: if type == "string" then (sub("^\\s+"; "") | sub("\\s+$"; "")) else "" end;
def opt($r; $k): if ($r | has($k)) then {($k): $r[$k]} else {} end;
def rich($r): (($r|has("language")) or ($r|has("invocation")) or ($r|has("risk")) or ($r|has("runner")) or ($r|has("judge")) or ($r|has("trace")) or ($r|has("gate")));
def adderr($st; $m; $x): {errs: ($st.errs + [{code: "EVAL_CASE_INVALID", message: $m} + $x]), seen: $st.seen, isobj: $st.isobj, rich: $st.rich, category: $st.category, language: $st.language, invocation: $st.invocation};
if (($row|type) != "object") then
  {errs: [{code: "EVAL_CASE_INVALID", message: "Eval case must be a JSON object", line: $line}], seen: $seen, isobj: false, rich: false, category: null, language: null, invocation: null}
else
( {errs: [], seen: $seen, isobj: true,
   rich: rich($row),
   category: (if ($row.category|ne) then ($row.category|tr) else null end),
   language: (if ($row.language|ne) then ($row.language|tr) else null end),
   invocation: (if ($row.invocation|ne) then ($row.invocation|tr) else null end)}
| (if ($row.id|ne) then
     ( . as $st | (($row.id)|tr) as $id
       | if ($st.seen | has($id)) then
           adderr($st; "Eval case id must be unique"; {line: $line, id: $id, firstLine: $st.seen[$id]})
         else
           {errs: $st.errs, seen: ($st.seen + {($id): $line}), isobj: $st.isobj, rich: $st.rich, category: $st.category, language: $st.language, invocation: $st.invocation}
         end )
   else adderr(.; "Eval case requires non-empty string id"; {line: $line} + opt($row; "id")) end)
| (if ($row.category|ne) then
     (($row.category|tr) as $cat
      | if (($allowed | index($cat)) != null) then . else
          adderr(.; "Eval case category is not allowed"; {line: $line} + opt($row; "id") + {category: $row.category, allowed: $allowed})
        end)
   else adderr(.; "Eval case requires non-empty string category"; {line: $line} + opt($row; "id")) end)
| (if ((($row.category|type) == "string") and ((["positive", "negative", "boundary"] | index(($row.category|tr))) != null)) then
     ((if (($row.expect == "trigger") or ($row.expect == "no_trigger")) then . else
        adderr(.; "Eval case trigger category requires expect of trigger|no_trigger"; {line: $line} + opt($row; "id") + opt($row; "expect")) end)
      | (if ((($row.runs|type) == "number") and ($row.runs == ($row.runs|floor)) and ($row.runs >= 1)) then . else
        adderr(.; "Eval case trigger category requires an integer runs >= 1"; {line: $line} + opt($row; "id") + opt($row; "runs")) end)
      | (if ((($row.threshold|type) == "number") and ($row.threshold > 0) and ($row.threshold < 1)) then . else
        adderr(.; "Eval case trigger category requires a threshold strictly between 0 and 1"; {line: $line} + opt($row; "id") + opt($row; "threshold")) end))
   else . end)
| (if ((($row.context|type) == "object") and (($row.context.files|type) == "array") and (($row.context.sources|type) == "array")) then
     ((($row.context.files) as $vals | reduce range(0; ($vals|length)) as $i (.;
        if ($vals[$i]|ne) then . else
          adderr(.; "Eval case context.files item must be a non-empty string"; {line: $line} + opt($row; "id") + {index: $i, value: $vals[$i]}) end))
      | (($row.context.sources) as $vals | reduce range(0; ($vals|length)) as $i (.;
        if ($vals[$i]|ne) then . else
          adderr(.; "Eval case context.sources item must be a non-empty string"; {line: $line} + opt($row; "id") + {index: $i, value: $vals[$i]}) end)))
   else adderr(.; "Eval case requires a context object with files and sources arrays"; {line: $line} + opt($row; "id")) end)
| (if ((($row.metrics|type) == "array") and (($row.metrics|length) > 0)) then
     (($row.metrics) as $vals | reduce range(0; ($vals|length)) as $i (.;
        if ($vals[$i]|ne) then . else
          adderr(.; "Eval case metrics item must be a non-empty string"; {line: $line} + opt($row; "id") + {index: $i, value: $vals[$i]}) end))
   else adderr(.; "Eval case metrics must contain at least one non-empty string"; {line: $line} + opt($row; "id")) end)
| (if ($row.prompt|ne) then . else adderr(.; "Eval case requires non-empty string prompt"; {line: $line} + opt($row; "id")) end)
| (if rich($row) then
     ((reduce ["language", "invocation", "risk", "runner", "judge", "gate"][] as $f (.;
        if ($row[$f]|ne) then . else
          adderr(.; ("Eval case requires non-empty string " + $f); {line: $line} + opt($row; "id") + {field: $f}) end))
      | (if ((($row.trace|type) == "array") and (($row.trace|length) > 0)) then
           (($row.trace) as $vals | reduce range(0; ($vals|length)) as $i (.;
              if ($vals[$i]|ne) then . else
                adderr(.; "Eval case trace item must be a non-empty string"; {line: $line} + opt($row; "id") + {index: $i, value: $vals[$i]}) end))
         else adderr(.; "Eval case trace must contain at least one non-empty string"; {line: $line} + opt($row; "id")) end))
   else . end)
| (if (($row.expected|type) == "object") then
     ((if (($row.expected.must|type) == "array") then
          (if (($row.expected.must|length) > 0) then
             (($row.expected.must) as $vals | reduce range(0; ($vals|length)) as $i (.;
                if ($vals[$i]|ne) then . else
                  adderr(.; "Eval case expected.must item must be a non-empty string"; {line: $line} + opt($row; "id") + {index: $i, value: $vals[$i]}) end))
           else adderr(.; "Eval case expected.must must contain at least one non-empty string"; {line: $line} + opt($row; "id")) end)
        else adderr(.; "Eval case expected.must must be an array"; {line: $line} + opt($row; "id")) end)
      | (if (($row.expected.mustNot|type) == "array") then
           (($row.expected.mustNot) as $vals | reduce range(0; ($vals|length)) as $i (.;
              if ($vals[$i]|ne) then . else
                adderr(.; "Eval case expected.mustNot item must be a non-empty string"; {line: $line} + opt($row; "id") + {index: $i, value: $vals[$i]}) end))
         else adderr(.; "Eval case expected.mustNot must be an array"; {line: $line} + opt($row; "id")) end))
   else adderr(.; "Eval case requires expected object"; {line: $line} + opt($row; "id")) end)
)
end
'

EVAL_TOTAL=0
EVAL_RICH=0
EVAL_CATS_JSON='{}'
CAT_ORDER=()
CAT_COUNTS=()
LANG_COUNTS=()
INV_COUNTS=()

lookup_index() { # needle candidates...
  local needle=$1 i=0 x
  shift
  for x in "$@"; do
    if [ "$x" = "$needle" ]; then printf '%s' "$i"; return 0; fi
    i=$((i + 1))
  done
  printf '%s' -1
}

build_categories_json() {
  local out="" idx n=0
  for idx in "${CAT_ORDER[@]+"${CAT_ORDER[@]}"}"; do
    out="$out${out:+,}$(jq -cn --arg k "${CATEGORIES[$idx]}" --argjson v "${CAT_COUNTS[$idx]}" '{($k): $v}')"
    n=$((n + 1))
  done
  if [ "$n" -eq 0 ]; then
    printf '{}'
  else
    # merge the per-key objects while keeping their order
    printf '[%s]' "$out" | jq -c 'reduce .[] as $o ({}; . + $o)'
  fi
}

validate_eval_cases() {
  local evals_abs=$1
  local i raw line lineno parsed out isobj rich cat lang inv idx n
  EVAL_TOTAL=0
  EVAL_RICH=0
  CAT_ORDER=()
  CAT_COUNTS=()
  LANG_COUNTS=()
  INV_COUNTS=()
  for i in "${!CATEGORIES[@]}"; do CAT_COUNTS[i]=0; done
  for i in "${!LANGUAGES[@]}"; do LANG_COUNTS[i]=0; done
  for i in "${!INVOCATIONS[@]}"; do INV_COUNTS[i]=0; done
  local seen='{}'
  lineno=0

  if [ ! -e "$evals_abs" ]; then
    local dp
    dp=$(display_path "$evals_abs")
    push_error EVAL_FILE_MISSING "Eval JSONL file is missing: $dp" \
      "$(jq -cn --arg p "$dp" '{path: $p}')"
    EVAL_CATS_JSON='{}'
    return 0
  fi

  while IFS= read -r raw || [ -n "$raw" ]; do
    lineno=$((lineno + 1))
    line=${raw%$'\r'}
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ -n "$line" ] || continue

    if ! printf '%s' "$line" | LC_ALL=C awk "$JSON_VALIDATOR_AWK"; then
      push_error EVAL_CASE_INVALID "Eval case line $lineno is not valid JSON: invalid JSON syntax" \
        "$(jq -cn --argjson l "$lineno" '{line: $l}')"
      continue
    fi

    parsed=$(printf '%s' "$line" | jq -c 'walk(if type == "number" then . + 0 else . end)')
    out=$(jq -cn --argjson row "$parsed" --argjson line "$lineno" --argjson seen "$seen" \
      --argjson allowed "$CATEGORIES_JSON" "$ROW_JQ")
    seen=$(printf '%s' "$out" | jq -c '.seen')
    n=$(printf '%s' "$out" | jq '.errs | length')
    if [ "$n" -gt 0 ]; then
      printf '%s' "$out" | jq -c '.errs[]' >> "$ERRFILE"
      ERR_COUNT=$((ERR_COUNT + n))
    fi

    isobj=$(printf '%s' "$out" | jq -r '.isobj')
    rich=$(printf '%s' "$out" | jq -r '.rich')
    if [ "$isobj" = "true" ]; then
      EVAL_TOTAL=$((EVAL_TOTAL + 1))
      if [ "$rich" = "true" ]; then EVAL_RICH=$((EVAL_RICH + 1)); fi
      cat=$(printf '%s' "$out" | jq -r 'if .category == null then "" else .category end')
      if [ -n "$cat" ]; then
        idx=$(lookup_index "$cat" "${CATEGORIES[@]}")
        if [ "$idx" -ge 0 ]; then
          if [ "${CAT_COUNTS[$idx]}" -eq 0 ]; then CAT_ORDER+=("$idx"); fi
          CAT_COUNTS[idx]=$((CAT_COUNTS[idx] + 1))
        fi
      fi
      lang=$(printf '%s' "$out" | jq -r 'if .language == null then "" else .language end')
      if [ -n "$lang" ]; then
        idx=$(lookup_index "$lang" "${LANGUAGES[@]}")
        if [ "$idx" -ge 0 ]; then LANG_COUNTS[idx]=$((LANG_COUNTS[idx] + 1)); fi
      fi
      inv=$(printf '%s' "$out" | jq -r 'if .invocation == null then "" else .invocation end')
      if [ -n "$inv" ]; then
        idx=$(lookup_index "$inv" "${INVOCATIONS[@]}")
        if [ "$idx" -ge 0 ]; then INV_COUNTS[idx]=$((INV_COUNTS[idx] + 1)); fi
      fi
    fi
  done < "$evals_abs"

  local floor actual
  if [ "$EVAL_RICH" -gt 0 ]; then
    for i in "${!CATEGORIES[@]}"; do
      floor=${RICH_CAT_FLOORS[$i]}
      actual=${CAT_COUNTS[$i]}
      if [ "$actual" -lt "$floor" ]; then
        push_error EVAL_CATEGORY_FLOOR "Expected at least $floor eval case(s) for category: ${CATEGORIES[$i]}" \
          "$(jq -cn --arg c "${CATEGORIES[$i]}" --argjson e "$floor" --argjson a "$actual" \
            '{category: $c, expected: $e, actual: $a}')"
      fi
    done
    for i in "${!LANGUAGES[@]}"; do
      floor=${LANG_FLOORS[$i]}
      actual=${LANG_COUNTS[$i]}
      if [ "$actual" -lt "$floor" ]; then
        push_error EVAL_LANGUAGE_FLOOR "Expected at least $floor eval case(s) for language: ${LANGUAGES[$i]}" \
          "$(jq -cn --arg l "${LANGUAGES[$i]}" --argjson e "$floor" --argjson a "$actual" \
            '{language: $l, expected: $e, actual: $a}')"
      fi
    done
    for i in "${!INVOCATIONS[@]}"; do
      floor=${INV_FLOORS[$i]}
      actual=${INV_COUNTS[$i]}
      if [ "$actual" -lt "$floor" ]; then
        push_error EVAL_INVOCATION_FLOOR "Expected at least $floor eval case(s) for invocation: ${INVOCATIONS[$i]}" \
          "$(jq -cn --arg n "${INVOCATIONS[$i]}" --argjson e "$floor" --argjson a "$actual" \
            '{invocation: $n, expected: $e, actual: $a}')"
      fi
    done
  else
    for i in "${!CATEGORIES[@]}"; do
      floor=${CAT_FLOORS[$i]}
      actual=${CAT_COUNTS[$i]}
      if [ "$actual" -lt "$floor" ]; then
        push_error EVAL_CATEGORY_FLOOR "Expected at least $floor eval case(s) for category: ${CATEGORIES[$i]}" \
          "$(jq -cn --arg c "${CATEGORIES[$i]}" --argjson e "$floor" --argjson a "$actual" \
            '{category: $c, expected: $e, actual: $a}')"
      fi
    done
  fi

  EVAL_CATS_JSON=$(build_categories_json)
}

# ------------------------------------------------------------------ output

print_help() {
  printf '%s\n' "Usage: bash skills/hyper-prompt/scripts/validate-hyper-prompt.sh [--root <dir>] [--evals <jsonl>] [--json]"
  printf '\n'
  printf '%s\n' "Validates the repository-local hyper-prompt package with bash and jq only."
  printf '\n'
  printf '%s\n' "Options:"
  printf '%s\n' "  --root <dir>     Skill root directory. Defaults to skills/hyper-prompt."
  printf '%s\n' "  --evals <file>   JSONL eval cases. Defaults to <root>/assets/evals/hyper-prompt-cases.jsonl."
  printf '%s\n' "  --json           Emit one structured JSON object."
  printf '%s\n' "  --help           Show this help."
  printf '\n'
}

emit_result() { # root evals ok json
  local root=$1 evals=$2 ok=$3 json=$4 errors_json code_line
  errors_json=$(jq -s -c . "$ERRFILE")
  local payload
  payload=$(jq -cn --argjson ok "$ok" --arg root "$root" --arg evals "$evals" \
    --argjson errors "$errors_json" --argjson summary "$SUMMARY_JSON" \
    '{ok: $ok, root: $root, evals: $evals, errors: $errors, warnings: [], summary: $summary}')
  if [ "$json" = "true" ]; then
    printf '%s\n' "$payload" | jq .
    return 0
  fi
  if [ "$ok" = "true" ]; then
    printf 'PASS hyper-prompt validation (%s markdown files, %s eval cases)\n' "$MD_COUNT" "$EVAL_TOTAL"
    return 0
  fi
  printf 'FAIL hyper-prompt validation (%s error%s)\n' "$ERR_COUNT" "$([ "$ERR_COUNT" -eq 1 ] && printf '' || printf 's')" >&2
  while IFS= read -r code_line; do
    printf '%s\n' "$code_line" >&2
  done < <(jq -r '.code + ": " + .message' "$ERRFILE")
}

print_cli_error() { # code message json
  local code=$1 message=$2 json=$3
  ERRFILE=$(new_tmpfile)
  push_error "$code" "$message" '{}'
  SUMMARY_JSON=$(jq -cn '{markdownFiles: 0, evalCases: 0, evalCategories: {}, linksChecked: 0}')
  MD_COUNT=0
  EVAL_TOTAL=0
  emit_result "$DEFAULT_ROOT" "$(join_path "$DEFAULT_ROOT" "assets/evals/hyper-prompt-cases.jsonl")" false "$json"
}

main() {
  local root="$DEFAULT_ROOT" evals="" have_evals=false json=false help=false
  local i=1 arg value json_flag=false
  local args=("$@")
  local argc=$#
  local root_abs evals_abs

  for arg in "$@"; do
    if [ "$arg" = "--json" ]; then json_flag=true; fi
  done

  while [ "$i" -le "$argc" ]; do
    arg=${args[$((i - 1))]}
    case $arg in
      --root)
        i=$((i + 1))
        value=${args[$((i - 1))]:-}
        if [ -z "$value" ] || case $value in --*) true ;; *) false ;; esac; then
          print_cli_error ARG_VALUE_MISSING "--root requires a value" "$json_flag"
          return 1
        fi
        root=$value
        ;;
      --evals)
        i=$((i + 1))
        value=${args[$((i - 1))]:-}
        if [ -z "$value" ] || case $value in --*) true ;; *) false ;; esac; then
          print_cli_error ARG_VALUE_MISSING "--evals requires a value" "$json_flag"
          return 1
        fi
        evals=$value
        have_evals=true
        ;;
      --json)
        json=true
        ;;
      --help|-h)
        help=true
        ;;
      *)
        print_cli_error ARG_UNKNOWN "Unknown argument: $arg" "$json_flag"
        return 1
        ;;
    esac
    i=$((i + 1))
  done

  if [ "$help" = "true" ]; then
    print_help
    return 0
  fi

  if [ "$have_evals" = "false" ]; then
    evals=$(join_path "$root" "assets/evals/hyper-prompt-cases.jsonl")
  fi

  root_abs=$(abs_path "$root")
  evals_abs=$(abs_path "$evals")

  ERRFILE=$(new_tmpfile)

  if [ ! -d "$root_abs" ]; then
    push_error ROOT_MISSING "Root directory is missing: $(display_path "$root_abs")" \
      "$(jq -cn --arg p "$(display_path "$root_abs")" '{path: $p}')"
    FILES=()
  else
    FILES=()
    collect_files "$root_abs"
    sort_files
  fi

  markdown_files
  MD_COUNT=${#MARKDOWN[@]}

  validate_skill_file "$root_abs"
  validate_links "$root_abs"
  validate_code_fences "$root_abs"
  validate_bilingual_pairs "$root_abs"
  validate_stray_docs "$root_abs"
  validate_authority_references "$root_abs"
  validate_templates "$root_abs"
  validate_eval_cases "$evals_abs"

  local fences_json bilingual_json stray_json authority_json templates_json
  fences_json=$(jq -cn --argjson ok "$([ "${#FENCE_INVALID_ITEMS[@]}" -eq 0 ] && printf true || printf false)" \
    --argjson checked "$FENCE_CHECKED" --argjson invalid "$(join_json "${FENCE_INVALID_ITEMS[@]+"${FENCE_INVALID_ITEMS[@]}"}")" \
    '{ok: $ok, checked: $checked, invalid: $invalid}')
  bilingual_json=$(jq -cn \
    --argjson ok "$([ "${#BILINGUAL_MISSING[@]}" -eq 0 ] && [ "${#BILINGUAL_ORPHAN[@]}" -eq 0 ] && printf true || printf false)" \
    --argjson checked "$BILINGUAL_CHECKED" \
    --argjson missing "$(strings_json "${BILINGUAL_MISSING[@]+"${BILINGUAL_MISSING[@]}"}")" \
    --argjson orphan "$(strings_json "${BILINGUAL_ORPHAN[@]+"${BILINGUAL_ORPHAN[@]}"}")" \
    '{ok: $ok, checked: $checked, missing: $missing, orphan: $orphan}')
  stray_json=$(jq -cn --argjson ok "$([ "${#STRAY_FOUND[@]}" -eq 0 ] && printf true || printf false)" \
    --argjson found "$(strings_json "${STRAY_FOUND[@]+"${STRAY_FOUND[@]}"}")" '{ok: $ok, found: $found}')
  authority_json=$(jq -cn --argjson ok "$([ "${#AUTH_HITS[@]}" -eq 0 ] && printf true || printf false)" \
    --argjson hits "$(join_json "${AUTH_HITS[@]+"${AUTH_HITS[@]}"}")" '{ok: $ok, hits: $hits}')
  templates_json=$(jq -cn \
    --argjson ok "$([ "${#TEMPLATE_MISSING[@]}" -eq 0 ] && printf true || printf false)" \
    --argjson required "$(printf '%s\n' "${REQUIRED_TEMPLATES[@]}" | jq -R . | jq -s -c .)" \
    --argjson present "$(strings_json "${TEMPLATE_PRESENT[@]+"${TEMPLATE_PRESENT[@]}"}")" \
    --argjson missing "$(strings_json "${TEMPLATE_MISSING[@]+"${TEMPLATE_MISSING[@]}"}")" \
    --argjson concepts "$(zip_object "$CONCEPT_KEYS_JSON" "$(bool_values_json "${TEMPLATE_CONCEPTS[@]+"${TEMPLATE_CONCEPTS[@]}"}")")" \
    '{ok: (($ok) and ([$concepts[]] | all)), required: $required, present: $present, missing: $missing, concepts: $concepts}')

  SUMMARY_JSON=$(jq -cn \
    --argjson markdownFiles "$MD_COUNT" \
    --argjson evalCases "$EVAL_TOTAL" \
    --argjson evalCategories "$EVAL_CATS_JSON" \
    --argjson linksChecked "$LINK_CHECKED" \
    --argjson skill "$SKILL_JSON" \
    --argjson codeFences "$fences_json" \
    --argjson bilingualPairs "$bilingual_json" \
    --argjson strayDocs "$stray_json" \
    --argjson authorityRefs "$authority_json" \
    --argjson templates "$templates_json" \
    '{markdownFiles: $markdownFiles, evalCases: $evalCases, evalCategories: $evalCategories, linksChecked: $linksChecked,
      skill: $skill, codeFences: $codeFences, bilingualPairs: $bilingualPairs, strayDocs: $strayDocs,
      authorityRefs: $authorityRefs, templates: $templates}')

  local ok=true
  if [ "$ERR_COUNT" -ne 0 ]; then ok=false; fi
  emit_result "$root" "$evals" "$ok" "$json"
  if [ "$ok" = "true" ]; then return 0; else return 1; fi
}

main "$@"
