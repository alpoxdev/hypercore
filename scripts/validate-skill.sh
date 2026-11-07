#!/usr/bin/env bash
# Validates one skill folder: metadata, direct links, bilingual structure, core
# parity, and code fences. Uses bash and jq only.
set -euo pipefail
shopt -s dotglob nullglob

cwd=$(pwd -P)
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/validate-skill.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT
fails="$tmpdir/failures.jsonl"
warns="$tmpdir/warnings.jsonl"
: > "$fails"
: > "$warns"

# --- path helpers (lexical, matching Node path.resolve/normalize) -----------

normalize_path() {
  local input=$1 out='' seg n=0 i
  local -a parts=()
  local -a stack=()
  IFS='/' read -r -a parts <<< "$input" || true
  for seg in ${parts[@]+"${parts[@]}"}; do
    case $seg in
      ''|.) ;;
      ..) [ "$n" -gt 0 ] && n=$((n - 1)) ;;
      *) stack[n]=$seg; n=$((n + 1)) ;;
    esac
  done
  i=0
  while [ "$i" -lt "$n" ]; do
    out="$out/${stack[i]}"
    i=$((i + 1))
  done
  printf '%s' "${out:-/}"
}

relpath() {
  local from=$1 to=$2 out='' i=0 j=0
  local -a af=()
  local -a at=()
  IFS='/' read -r -a af <<< "${from#/}" || true
  IFS='/' read -r -a at <<< "${to#/}" || true
  while [ "$i" -lt "${#af[@]}" ] && [ "$j" -lt "${#at[@]}" ] && [ "${af[i]}" = "${at[j]}" ]; do
    i=$((i + 1))
    j=$((j + 1))
  done
  while [ "$i" -lt "${#af[@]}" ]; do
    out="$out../"
    i=$((i + 1))
  done
  while [ "$j" -lt "${#at[@]}" ]; do
    out="$out${at[j]}/"
    j=$((j + 1))
  done
  printf '%s' "${out%/}"
}

abspath() {
  case $1 in
    /*) normalize_path "$1" ;;
    *) normalize_path "$cwd/$1" ;;
  esac
}

is_inside() {
  local rel
  rel=$(relpath "$1" "$2")
  [ -z "$rel" ] && return 0
  case $rel in
    ../*|..|/*) return 1 ;;
    [A-Za-z]:*) return 1 ;;
  esac
  return 0
}

# --- issue helpers ----------------------------------------------------------

issue_code_msg() { # file code message
  jq -cn --arg code "$2" --arg message "$3" '{code:$code,message:$message}' >> "$1"
}

issue_path() { # file code message path
  jq -cn --arg code "$2" --arg message "$3" --arg path "$4" \
    '{code:$code,message:$message,path:$path}' >> "$1"
}

issue_name_mismatch() { # file code message path expected actual
  jq -cn --arg code "$2" --arg message "$3" --arg path "$4" --arg expected "$5" --arg actual "$6" \
    '{code:$code,message:$message,path:$path,expected:$expected,actual:$actual}' >> "$1"
}

issue_href() { # file code message path href
  jq -cn --arg code "$2" --arg message "$3" --arg path "$4" --arg href "$5" \
    '{code:$code,message:$message,path:$path,href:$href}' >> "$1"
}

# --- text helpers -----------------------------------------------------------

frontmatter_value() { # file key
  LC_ALL=C awk -v key="$2" -v sq="'" -v dq='"' '
    BEGIN { inside = 0; grab = 0; done = 0; val = "" }
    NR == 1 {
      if ($0 ~ /^---\r?$/) { inside = 1; next }
      exit
    }
    inside && !done {
      if ($0 ~ /^---/) { done = 1; exit }
      if (!grab) {
        if (index($0, key ":") == 1) {
          rest = substr($0, length(key) + 2)
          sub(/^[ \t\r\f\v]+/, "", rest)
          if (rest != "") { val = rest; done = 1 }
          else grab = 1
        }
      } else {
        rest = $0
        sub(/^[ \t\r\f\v]+/, "", rest)
        if (rest != "") { val = rest; done = 1 }
      }
    }
    END {
      if (done) {
        sub(/^[ \t\r\n\f\v]+/, "", val)
        sub(/[ \t\r\n\f\v]+$/, "", val)
        c1 = substr(val, 1, 1)
        if (c1 == sq || c1 == dq) val = substr(val, 2)
        c2 = substr(val, length(val), 1)
        if (val != "" && (c2 == sq || c2 == dq)) val = substr(val, 1, length(val) - 1)
        print val
      }
    }
  ' "$1"
}

extract_tags() { # text file
  LC_ALL=C awk '{ line = tolower($0); if (line ~ /^<\/?[a-z][a-z0-9_]*>[ \t\f\v\r]*$/) print line }' "$1"
}

extract_links() { # text file
  LC_ALL=C awk 'length($0) > 1 && /^@/ { s = substr($0, 2); sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); print s }' "$1"
}

fences_balanced() { # text file
  LC_ALL=C awk '
    {
      line = $0
      sub(/^[ \t\f\v]+/, "", line)
      c = substr(line, 1, 1)
      if (c != "`" && c != "~") next
      n = 0
      while (substr(line, n + 1, 1) == c) n++
      if (n < 3) next
      if (depth > 0 && stack[depth] == c) depth--
      else { depth++; stack[depth] = c }
    }
    END { exit depth > 0 ? 1 : 0 }
  ' "$1"
}

file_lines() { # file
  local newlines
  newlines=$(LC_ALL=C tr -cd '\n' < "$1" | wc -c)
  newlines=${newlines//[[:space:]]/}
  printf '%s' "$((newlines + 1))"
}

starts_with_trigger() { # description
  case $1 in
    'Use this skill when') return 0 ;;
    'Use this skill when'[!A-Za-z0-9_]*) return 0 ;;
  esac
  return 1
}

# --- markdown collection ----------------------------------------------------

MD_FILES=()

collect_markdown() { # root
  local root=$1 entry current count found_file
  local -a stack=()
  local -a found=()
  local -a list=()
  stack[0]=$root
  count=1
  while [ "$count" -gt 0 ]; do
    count=$((count - 1))
    current=${stack[count]}
    for entry in "$current"/*; do
      if [ -L "$entry" ]; then
        continue
      elif [ -d "$entry" ]; then
        stack[count]=$entry
        count=$((count + 1))
      elif [ -f "$entry" ]; then
        case $entry in
          *.md) found[${#found[@]}]=$entry ;;
        esac
      fi
    done
  done
  MD_FILES=()
  if [ "${#found[@]}" -gt 0 ]; then
    while IFS= read -r found_file; do
      list[${#list[@]}]=$found_file
    done < <(printf '%s\n' ${found[@]+"${found[@]}"} | LC_ALL=C sort)
  fi
  MD_FILES=(${list[@]+"${list[@]}"})
}

md_contains() { # root relpath
  local root=$1 want=$2 file
  for file in ${MD_FILES[@]+"${MD_FILES[@]}"}; do
    if [ "${file#"$root"/}" = "$want" ]; then
      return 0
    fi
  done
  return 1
}

# --- argument parsing -------------------------------------------------------

target_arg=''
json=0
help=0
ERR_CODE=''
ERR_MSG=''

parse_args() {
  local arg
  for arg in "$@"; do
    case $arg in
      --json) json=1 ;;
      --help|-h) help=1 ;;
      --*) ERR_CODE=ARG_UNKNOWN; ERR_MSG="Unknown argument: $arg"; return 1 ;;
      *)
        if [ -n "$target_arg" ]; then
          ERR_CODE=ARG_TARGET_COUNT
          ERR_MSG='Provide exactly one target skill folder.'
          return 1
        fi
        target_arg=$arg
        ;;
    esac
  done
  if [ "$help" -eq 0 ] && [ -z "$target_arg" ]; then
    ERR_CODE=ARG_TARGET_MISSING
    ERR_MSG='Usage: bash scripts/validate-skill.sh <skill-folder> [--json]'
    return 1
  fi
  return 0
}

print_help() {
  printf '%s\n' 'Usage: bash scripts/validate-skill.sh <skill-folder> [--json]'
  printf '\n'
  printf '%s\n' 'Checks local metadata, direct links, bilingual structure, core parity, and code fences with bash and jq.'
}

# --- validation -------------------------------------------------------------

result_target() { # absolute path
  local rel
  rel=$(relpath "$cwd" "$1")
  printf '%s' "${rel:-$1}"
}

REPORT=''

emit_result() { # ok target checks-json
  REPORT=$(jq -n --argjson ok "$1" --arg target "$2" --argjson checks "$3" \
    --slurpfile failures "$fails" --slurpfile warnings "$warns" \
    '{ok:$ok,target:$target,checks:$checks,failures:$failures,warnings:$warnings}')
}

validate() {
  local target target_name skill_path korean_path core
  local directory=false metadata=false support_links=false bilingual=false parity=false fences=false
  local tags_match=0 links_match=0 links_ok=true fail_frontmatter=0 fail_name=0 fail_description=0
  local name description lines link resolved rel sibling file unbalanced=0
  local -a missing_pairs=()

  target=$(abspath "$target_arg")
  target_name=${target##*/}
  skill_path="$target/SKILL.md"
  korean_path="$target/SKILL.ko.md"

  if [ ! -e "$target" ] || [ ! -d "$target" ]; then
    issue_path "$fails" TARGET_NOT_DIRECTORY "Target is not a directory: $target_arg" "$target_arg"
    emit_result false "$(result_target "$target")" \
      '{"directory":false,"metadata":false,"supportLinks":false,"bilingualPairs":false,"coreParity":false,"codeFences":false}'
    return 1
  fi
  directory=true

  if [ ! -e "$skill_path" ]; then
    issue_path "$fails" SKILL_MISSING 'Missing SKILL.md' 'SKILL.md'
  fi
  if [ ! -e "$korean_path" ]; then
    issue_path "$fails" KOREAN_CORE_MISSING 'Missing SKILL.ko.md' 'SKILL.ko.md'
  fi

  if [ -e "$skill_path" ]; then
    core=$(cat "$skill_path"; printf x)
    core=${core%x}
    name=$(frontmatter_value "$skill_path" name)
    description=$(frontmatter_value "$skill_path" description)
    case $core in
      ---$'\n'*|---$'\r\n'*) ;;
      *)
        fail_frontmatter=1
        issue_path "$fails" FRONTMATTER_MISSING 'SKILL.md must start with YAML frontmatter.' 'SKILL.md'
        ;;
    esac
    if [ "$name" != "$target_name" ]; then
      fail_name=1
      issue_name_mismatch "$fails" NAME_MISMATCH "Frontmatter name must match folder name: $target_name" 'SKILL.md' "$target_name" "$name"
    fi
    if [ -z "$description" ]; then
      fail_description=1
      issue_path "$fails" DESCRIPTION_MISSING 'Frontmatter needs a non-empty description.' 'SKILL.md'
    elif ! starts_with_trigger "$description"; then
      issue_path "$warns" DESCRIPTION_TRIGGER_STYLE "Canonical description should start with 'Use this skill when'." 'SKILL.md'
    fi
    lines=$(file_lines "$skill_path")
    if [ "$lines" -gt 300 ]; then
      issue_path "$warns" SKILL_LONG 'SKILL.md exceeds 300 lines; consider progressive disclosure.' 'SKILL.md'
    fi
    if [ "$fail_frontmatter" -eq 0 ] && [ "$fail_name" -eq 0 ] && [ "$fail_description" -eq 0 ]; then
      metadata=true
    fi

    while IFS= read -r link; do
      [ -n "$link" ] || continue
      resolved=$(normalize_path "$target/$link")
      if ! is_inside "$target" "$resolved" || [ ! -e "$resolved" ]; then
        links_ok=false
        issue_href "$fails" SUPPORT_LINK_MISSING "Direct support link does not resolve: $link" 'SKILL.md' "$link"
      fi
    done < <(extract_links "$skill_path")
    support_links=$links_ok
  fi

  if [ -e "$skill_path" ] && [ -e "$korean_path" ]; then
    if cmp -s <(extract_tags "$skill_path") <(extract_tags "$korean_path"); then
      tags_match=1
    fi
    if cmp -s <(extract_links "$skill_path" | sed 's/\.ko\.md$/.md/') \
               <(extract_links "$korean_path" | sed 's/\.ko\.md$/.md/'); then
      links_match=1
    fi
    if [ "$tags_match" -eq 0 ]; then
      issue_code_msg "$fails" BILINGUAL_TAG_DRIFT 'SKILL.md and SKILL.ko.md structural tags differ.'
    fi
    if [ "$links_match" -eq 0 ]; then
      issue_code_msg "$fails" BILINGUAL_LINK_DRIFT 'SKILL.md and SKILL.ko.md direct support links differ.'
    fi
    if [ "$tags_match" -eq 1 ] && [ "$links_match" -eq 1 ]; then
      parity=true
    fi
  fi

  if [ "$directory" = true ]; then
    collect_markdown "$target"
    for file in ${MD_FILES[@]+"${MD_FILES[@]}"}; do
      rel=${file#"$target"/}
      case $rel in
        *.ko.md) sibling="${rel%.ko.md}.md" ;;
        *) sibling="${rel%.md}.ko.md" ;;
      esac
      if ! md_contains "$target" "$sibling"; then
        missing_pairs[${#missing_pairs[@]}]=$rel
        issue_path "$fails" BILINGUAL_PAIR_MISSING "Markdown sibling is missing: $sibling" "$rel"
      fi
    done
    if [ "${#missing_pairs[@]}" -eq 0 ]; then
      bilingual=true
    fi
    for file in ${MD_FILES[@]+"${MD_FILES[@]}"}; do
      if ! fences_balanced "$file"; then
        unbalanced=1
        issue_path "$fails" CODE_FENCE_UNBALANCED 'Unbalanced code fence.' "${file#"$target"/}"
      fi
    done
    if [ "$unbalanced" -eq 0 ]; then
      fences=true
    fi
  fi

  local checks ok=true count
  checks=$(jq -cn --argjson directory "$directory" --argjson metadata "$metadata" \
    --argjson supportLinks "$support_links" --argjson bilingualPairs "$bilingual" \
    --argjson coreParity "$parity" --argjson codeFences "$fences" \
    '{directory:$directory,metadata:$metadata,supportLinks:$supportLinks,bilingualPairs:$bilingualPairs,coreParity:$coreParity,codeFences:$codeFences}')
  count=$(wc -l < "$fails" | tr -d ' ')
  if [ "$count" -gt 0 ]; then ok=false; fi
  emit_result "$ok" "$(result_target "$target")" "$checks"
  [ "$ok" = true ]
}

# --- main -------------------------------------------------------------------

if [ "$#" -eq 0 ]; then
  printf 'Usage: bash scripts/validate-skill.sh <skill-folder>\n' >&2
  exit 2
fi

legacy_target=$1
case $legacy_target in
  --*)
    jq -n --arg target "$legacy_target" \
      '{result:"fail",target:$target,failures:["Target is not a directory: \($target)"],warnings:[]}'
    exit 1
    ;;
esac

if ! parse_args "$@"; then
  jq -n --arg code "$ERR_CODE" --arg message "$ERR_MSG" \
    '{ok:false,target:null,checks:null,failures:[{code:$code,message:$message}],warnings:[]}'
  exit 2
fi

if [ "$help" -eq 1 ]; then
  print_help
  exit 0
fi

set +e
validate
status=$?
set -e

if [ "$json" -eq 1 ]; then
  printf '%s\n' "$REPORT"
else
  if [ "$status" -eq 0 ]; then
    printf 'skill validation passed: %s\n' "$(result_target "$(abspath "$target_arg")")"
  else
    printf 'skill validation failed: %s\n' "$(result_target "$(abspath "$target_arg")")"
  fi
fi
exit "$status"
