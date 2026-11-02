#!/usr/bin/env bash
# Validates a repository-local skills corpus: frontmatter, bilingual siblings,
# code fences, and direct support links. Uses bash and jq only.
set -euo pipefail
shopt -s dotglob nullglob

DEFAULT_ROOT='skills'

cwd=$(pwd -P)
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/validate-skills-corpus.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT
skill_fails="$tmpdir/skill-failures.jsonl"
skill_warns="$tmpdir/skill-warnings.jsonl"
all_failures="$tmpdir/all-failures.jsonl"
: > "$skill_fails"
: > "$skill_warns"
: > "$all_failures"

# --- path helpers -----------------------------------------------------------

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

normalize_arg() { # normalizes a possibly relative argument the way path.normalize does
  local n
  case $1 in
    /*) normalize_path "$1" ;;
    *)
      n=$(normalize_path "/$1")
      n=${n#/}
      printf '%s' "${n:-.}"
      ;;
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

display_path() { # absolute path
  local rel
  rel=$(relpath "$cwd" "$1")
  printf '%s' "${rel:-$1}"
}

# --- issue helpers ----------------------------------------------------------

issue_read_failed() { # file code message path detail
  jq -cn --arg code "$2" --arg message "$3" --arg path "$4" --arg detail "$5" \
    '{code:$code,message:$message,path:$path,detail:$detail}' >> "$1"
}

issue_path_only() { # file code message path
  jq -cn --arg code "$2" --arg message "$3" --arg path "$4" \
    '{code:$code,message:$message,path:$path}' >> "$1"
}

issue_skill_path() { # file code message skill path
  jq -cn --arg code "$2" --arg message "$3" --arg skill "$4" --arg path "$5" \
    '{code:$code,message:$message,skill:$skill,path:$path}' >> "$1"
}

issue_name_mismatch() { # file code message skill expected actual path
  jq -cn --arg code "$2" --arg message "$3" --arg skill "$4" \
    --arg expected "$5" --arg actual "$6" --arg path "$7" \
    '{code:$code,message:$message,skill:$skill,expected:$expected,actual:$actual,path:$path}' >> "$1"
}

issue_href() { # file code message skill path href
  jq -cn --arg code "$2" --arg message "$3" --arg skill "$4" --arg path "$5" --arg href "$6" \
    '{code:$code,message:$message,skill:$skill,path:$path,href:$href}' >> "$1"
}

issue_long() { # file code message skill path lines
  jq -cn --arg code "$2" --arg message "$3" --arg skill "$4" --arg path "$5" --argjson lines "$6" \
    '{code:$code,message:$message,skill:$skill,path:$path,lines:$lines}' >> "$1"
}

issue_fence() { # file code message path unclosed-json
  jq -cn --arg code "$2" --arg message "$3" --arg path "$4" --argjson unclosed "$5" \
    '{code:$code,message:$message,path:$path,unclosed:$unclosed}' >> "$1"
}

issue_not_found() { # file skill
  jq -cn --arg skill "$2" \
    '{code:"SKILL_NOT_FOUND",message:("Requested skill is not present under root: " + $skill),skill:$skill}' >> "$1"
}

# --- text helpers -----------------------------------------------------------

file_newlines() { # file
  LC_ALL=C tr -cd '\n' < "$1" | wc -c | tr -d ' '
}

file_lines() { # file
  printf '%s' "$(( $(file_newlines "$1") + 1 ))"
}

frontmatter_closed() { # file
  LC_ALL=C awk 'NR >= 3 && /^---/ { found = 1; exit } END { exit found ? 0 : 1 }' "$1"
}

starts_with_frontmatter() { # file: first four bytes are "---\n"
  local bytes
  bytes=$(head -c 4 "$1" | od -An -tx1 | tr -d ' \n')
  [ "$bytes" = '2d2d2d0a' ]
}

frontmatter_name() { # file
  LC_ALL=C awk '
    /^name:/ {
      rest = substr($0, 6)
      sub(/^[ \t\r\f\v]+/, "", rest)
      sub(/[ \t\r\f\v]+$/, "", rest)
      n = split(rest, parts, /[ \t\r\f\v]+/)
      if (n > 0 && parts[n] != "") { print parts[n] }
      exit
    }
  ' "$1"
}

has_description() { # file
  LC_ALL=C awk '
    /^description:/ {
      rest = substr($0, 13)
      sub(/^[ \t\r\f\v]+/, "", rest)
      sub(/[ \t\r\f\v]+$/, "", rest)
      if (rest ~ /^"[^"]+"$/) found = 1
      else if (rest ~ /^\047[^\047]+\047$/) found = 1
      else if (length(rest) >= 2) found = 1
      exit
    }
    END { exit found ? 0 : 1 }
  ' "$1"
}

extract_links() { # text file
  LC_ALL=C awk 'length($0) > 1 && /^@/ { s = substr($0, 2); sub(/^[ \t\r]+/, "", s); sub(/[ \t\r]+$/, "", s); print s }' "$1"
}

# Prints one JSON object per unclosed fence entry; exits non-zero when unbalanced.
fence_report() { # text file
  LC_ALL=C awk '
    {
      line = $0
      sub(/^[ \t\f\v]+/, "", line)
      c = substr(line, 1, 1)
      if (c != "`" && c != "~") next
      n = 0
      while (substr(line, n + 1, 1) == c) n++
      if (n < 3) next
      if (depth > 0 && stack[depth] == c) { depth--; next }
      depth++
      stack[depth] = c
      lines[depth] = NR
    }
    END {
      for (i = 1; i <= depth; i++) printf "{\"marker\":\"%s\",\"line\":%d}\n", stack[i], lines[i]
      exit depth > 0 ? 1 : 0
    }
  ' "$1"
}

# --- directory walking ------------------------------------------------------

TOP_LEVEL=()

list_top_level_directories() { # rootAbs
  local root=$1 entry
  local -a found=()
  local -a sorted=()
  if [ ! -r "$root" ] || [ ! -x "$root" ]; then
    issue_read_failed "$all_failures" ROOT_READ_FAILED \
      "Cannot read skills root: $(display_path "$root")" "$(display_path "$root")" \
      'EACCES: permission denied, scandir'
    TOP_LEVEL=()
    return 0
  fi
  for entry in "$root"/*; do
    if [ -L "$entry" ]; then
      continue
    fi
    if [ -d "$entry" ]; then
      found[${#found[@]}]=${entry##*/}
    fi
  done
  if [ "${#found[@]}" -gt 0 ]; then
    while IFS= read -r entry; do
      sorted[${#sorted[@]}]=$entry
    done < <(printf '%s\n' ${found[@]+"${found[@]}"} | LC_ALL=C sort)
  fi
  TOP_LEVEL=(${sorted[@]+"${sorted[@]}"})
}

WALK_FILES=()

walk_markdown_files() { # dirAbs
  local dir=$1 entry current count=1
  local -a stack=()
  local -a found=()
  local -a sorted=()
  stack[0]=$dir
  while [ "$count" -gt 0 ]; do
    count=$((count - 1))
    current=${stack[count]}
    if [ ! -r "$current" ] || [ ! -x "$current" ]; then
      issue_read_failed "$skill_fails" DIR_READ_FAILED \
        "Cannot read directory: $(display_path "$current")" "$(display_path "$current")" \
        'EACCES: permission denied, scandir'
      continue
    fi
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
  if [ "${#found[@]}" -gt 0 ]; then
    while IFS= read -r entry; do
      sorted[${#sorted[@]}]=$entry
    done < <(printf '%s\n' ${found[@]+"${found[@]}"} | LC_ALL=C sort)
  fi
  WALK_FILES=(${sorted[@]+"${sorted[@]}"})
}

walk_contains() { # skillDir relPath
  local root=$1 want=$2 file
  for file in ${WALK_FILES[@]+"${WALK_FILES[@]}"}; do
    if [ "${file#"$root"/}" = "$want" ]; then
      return 0
    fi
  done
  return 1
}

# --- per-skill validation ---------------------------------------------------

SKILL_CHECKS=''
SKILL_JSON=''
SKILL_FAIL_COUNT=0
SKILL_WARN_COUNT=0

validate_skill_file() { # skillDir skillPath skillName
  local skill_dir=$1 skill_path=$2 skill_name=$3
  local skill_file=true frontmatter=false name_ok=false description_ok=false support_links=true
  local name lines link resolved

  if starts_with_frontmatter "$skill_path"; then
    if frontmatter_closed "$skill_path"; then
      frontmatter=true
    else
      issue_skill_path "$skill_fails" FRONTMATTER_UNCLOSED \
        "SKILL.md frontmatter is not closed: $skill_name" "$skill_name" 'SKILL.md'
    fi
  else
    issue_skill_path "$skill_fails" FRONTMATTER_MISSING \
      "SKILL.md must start with YAML frontmatter: $skill_name" "$skill_name" 'SKILL.md'
  fi

  name=$(frontmatter_name "$skill_path")
  if [ -z "$name" ]; then
    issue_skill_path "$skill_fails" NAME_MISSING \
      "Frontmatter is missing name: $skill_name" "$skill_name" 'SKILL.md'
  elif [ "$name" != "$skill_name" ]; then
    issue_name_mismatch "$skill_fails" NAME_MISMATCH \
      "Frontmatter name must match folder name: $skill_name" "$skill_name" \
      "$skill_name" "$name" 'SKILL.md'
  else
    name_ok=true
  fi

  if has_description "$skill_path"; then
    description_ok=true
  else
    issue_skill_path "$skill_fails" DESCRIPTION_MISSING \
      "Frontmatter is missing a non-empty description: $skill_name" "$skill_name" 'SKILL.md'
  fi

  while IFS= read -r link; do
    [ -n "$link" ] || continue
    resolved=$(normalize_path "$skill_dir/$link")
    if ! is_inside "$skill_dir" "$resolved" || [ ! -e "$resolved" ]; then
      support_links=false
      issue_href "$skill_fails" SUPPORT_LINK_MISSING \
        "Direct support link does not resolve: $skill_name -> $link" "$skill_name" 'SKILL.md' "$link"
    fi
  done < <(extract_links "$skill_path")

  lines=$(file_lines "$skill_path")
  if [ "$lines" -gt 300 ]; then
    issue_long "$skill_warns" SKILL_LONG \
      "SKILL.md is long ($lines lines); consider moving detail to rules or references." \
      "$skill_name" 'SKILL.md' "$lines"
  fi

  SKILL_CHECKS=$(jq -cn --argjson skillFile "$skill_file" --argjson frontmatter "$frontmatter" \
    --argjson name "$name_ok" --argjson description "$description_ok" \
    --argjson supportLinks "$support_links" \
    '{skillFile:$skillFile,frontmatter:$frontmatter,name:$name,description:$description,supportLinks:$supportLinks,bilingualPairs:false,codeFences:false}')
}

validate_bilingual_pairs() { # skillDir
  local skill_dir=$1 rel_path source korean file
  local -a missing=()
  local -a orphan=()
  for file in ${WALK_FILES[@]+"${WALK_FILES[@]}"}; do
    rel_path=${file#"$skill_dir"/}
    case $rel_path in
      *.ko.md)
        source="${rel_path%.ko.md}.md"
        if ! walk_contains "$skill_dir" "$source"; then
          orphan[${#orphan[@]}]=$rel_path
        fi
        ;;
      *)
        korean="${rel_path%.md}.ko.md"
        if ! walk_contains "$skill_dir" "$korean"; then
          missing[${#missing[@]}]=$korean
        fi
        ;;
    esac
  done
  for rel_path in ${missing[@]+"${missing[@]}"}; do
    issue_path_only "$skill_fails" BILINGUAL_PAIR_MISSING "Missing Korean markdown sibling: $rel_path" "$rel_path"
  done
  for rel_path in ${orphan[@]+"${orphan[@]}"}; do
    issue_path_only "$skill_fails" BILINGUAL_PAIR_ORPHAN \
      "Korean markdown sibling has no English source: $rel_path" "$rel_path"
  done
  if [ "${#missing[@]}" -eq 0 ] && [ "${#orphan[@]}" -eq 0 ]; then
    return 0
  fi
  return 1
}

validate_code_fences() { # skillDir
  local skill_dir=$1 file rel unclosed
  local ok=true
  for file in ${WALK_FILES[@]+"${WALK_FILES[@]}"}; do
    rel=${file#"$skill_dir"/}
    if unclosed=$(fence_report "$file"); then
      continue
    fi
    ok=false
    issue_fence "$skill_fails" CODE_FENCE_UNBALANCED "Unbalanced code fence in $rel" "$rel" \
      "$(printf '%s\n' "$unclosed" | jq -s '.')"
  done
  [ "$ok" = true ]
}

validate_skill() { # rootAbs skillName
  local root=$1 skill_name=$2
  local skill_dir="$root/$2"
  local skill_path="$skill_dir/SKILL.md"
  local pairs_ok=true fences_ok=true ok=true fail_count warn_count

  : > "$skill_fails"
  : > "$skill_warns"

  if [ ! -e "$skill_path" ]; then
    issue_skill_path "$skill_fails" SKILL_MISSING "Missing SKILL.md for skill: $skill_name" \
      "$skill_name" "$skill_name/SKILL.md"
    SKILL_CHECKS='{"skillFile":false,"frontmatter":false,"name":false,"description":false,"supportLinks":false,"bilingualPairs":false,"codeFences":false}'
  else
    validate_skill_file "$skill_dir" "$skill_path" "$skill_name"
  fi

  WALK_FILES=()
  if [ -e "$skill_dir" ]; then
    walk_markdown_files "$skill_dir"
  fi
  if ! validate_bilingual_pairs "$skill_dir"; then
    pairs_ok=false
  fi
  if ! validate_code_fences "$skill_dir"; then
    fences_ok=false
  fi
  SKILL_CHECKS=$(printf '%s\n' "$SKILL_CHECKS" | jq -c --argjson pairs "$pairs_ok" --argjson fences "$fences_ok" \
    '.bilingualPairs = $pairs | .codeFences = $fences')

  fail_count=$(wc -l < "$skill_fails" | tr -d ' ')
  warn_count=$(wc -l < "$skill_warns" | tr -d ' ')
  if [ "$fail_count" -gt 0 ]; then ok=false; fi

  SKILL_JSON=$(jq -cn --arg name "$skill_name" --arg path "$(display_path "$skill_dir")" \
    --argjson ok "$ok" --slurpfile failures "$skill_fails" --slurpfile warnings "$skill_warns" \
    --argjson checks "$SKILL_CHECKS" \
    '{name:$name,path:$path,ok:$ok,failures:$failures,warnings:$warnings,checks:$checks}')

  SKILL_FAIL_COUNT=$fail_count
  SKILL_WARN_COUNT=$warn_count
}

array_contains() { # needle rest...
  local needle=$1 item
  shift
  if [ "$#" -eq 0 ]; then
    return 1
  fi
  for item in "$@"; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

flatten_failures() { # skillName
  local skill_name=$1 failure
  while IFS= read -r failure; do
    [ -n "$failure" ] || continue
    jq -c --arg skill "$skill_name" 'if has("skill") then . else . + {skill:$skill} end' <<< "$failure" >> "$all_failures"
  done < "$skill_fails"
}

# --- corpus -----------------------------------------------------------------

build_result() {
  local root_abs errors_file="$tmpdir/corpus-errors.jsonl"
  local -a top=()
  local -a selected=()
  local -a skill_json=()
  local name failed=0 warnings=0 checked=0 ok=true
  : > "$errors_file"
  : > "$all_failures"

  root_abs=$(abspath "$root")
  if [ ! -e "$root_abs" ] || [ ! -d "$root_abs" ]; then
    local sel_json='[]'
    if [ "$only_set" -eq 1 ] && [ "${#only_names[@]}" -gt 0 ]; then
      sel_json=$(printf '%s\n' "${only_names[@]}" | jq -R . | jq -s .)
    fi
    jq -n --arg root "$(normalize_arg "$root")" --arg raw "$root" --argjson selected "$sel_json" \
      '{ok:false,root:$root,totalTopLevelSkills:0,selectedSkills:$selected,selectedCount:0,checkedCount:0,summary:{passed:0,failed:0,warnings:0},skills:[],errors:[{code:"ROOT_MISSING",message:("Skills root is not a directory: " + $raw),path:$raw}]}'
    return 0
  fi

  list_top_level_directories "$root_abs"
  top=(${TOP_LEVEL[@]+"${TOP_LEVEL[@]}"})

  if [ "$only_set" -eq 1 ]; then
    selected=(${only_names[@]+"${only_names[@]}"})
  else
    selected=(${top[@]+"${top[@]}"})
  fi

  for name in ${selected[@]+"${selected[@]}"}; do
    if ! array_contains "$name" ${top[@]+"${top[@]}"}; then
      issue_not_found "$errors_file" "$name"
    fi
  done

  for name in ${selected[@]+"${selected[@]}"}; do
    if ! array_contains "$name" ${top[@]+"${top[@]}"}; then
      continue
    fi
    validate_skill "$root_abs" "$name"
    skill_json[${#skill_json[@]}]=$SKILL_JSON
    checked=$((checked + 1))
    if [ "$SKILL_FAIL_COUNT" -gt 0 ]; then
      failed=$((failed + 1))
    fi
    warnings=$((warnings + SKILL_WARN_COUNT))
    flatten_failures "$name"
  done

  local skills_ndjson="$tmpdir/skills.ndjson" errors_ndjson="$tmpdir/errors.ndjson"
  : > "$skills_ndjson"
  : > "$errors_ndjson"
  if [ "${#skill_json[@]}" -gt 0 ]; then
    printf '%s\n' ${skill_json[@]+"${skill_json[@]}"} > "$skills_ndjson"
  fi
  cat "$errors_file" "$all_failures" > "$errors_ndjson"
  if [ -s "$errors_ndjson" ]; then ok=false; fi

  local sel_json='[]'
  if [ "${#selected[@]}" -gt 0 ]; then
    sel_json=$(printf '%s\n' ${selected[@]+"${selected[@]}"} | jq -R . | jq -s .)
  fi

  local root_display
  root_display=$(display_path "$root_abs")
  if [ "$root_display" = "$root_abs" ]; then
    root_display=$root
  fi

  jq -n --argjson ok "$ok" --arg root "$root_display" --argjson total "${#top[@]}" \
    --argjson selected "$sel_json" --argjson selectedCount "${#selected[@]}" \
    --argjson checked "$checked" --argjson passed "$((checked - failed))" --argjson failed "$failed" \
    --argjson warnings "$warnings" --slurpfile skills "$skills_ndjson" --slurpfile errors "$errors_ndjson" \
    '{ok:$ok,root:$root,totalTopLevelSkills:$total,selectedSkills:$selected,selectedCount:$selectedCount,checkedCount:$checked,summary:{passed:$passed,failed:$failed,warnings:$warnings},skills:$skills,errors:$errors}'
}

print_help() {
  printf '%s\n' 'Usage: bash skills/skill-tester/scripts/validate-skills-corpus.sh --root <skills-dir> [--only a,b,c] [--json]'
  printf '\n'
  printf '%s\n' 'Validates a repository-local skills corpus with bash and jq only.'
  printf '\n'
  printf '%s\n' 'Options:'
  printf '%s\n' '  --root <dir>     Directory containing top-level skill folders. Defaults to skills.'
  printf '%s\n' '  --only <names>   Comma-separated folder names to validate as a subset.'
  printf '%s\n' '  --json           Emit structured JSON.'
  printf '%s\n' '  --help           Show this help.'
}

write_result() { # result-json json-flag
  local result=$1
  if [ "$2" -eq 1 ]; then
    printf '%s\n' "$result"
    return 0
  fi
  if [ "$(jq -r '.ok' <<< "$result")" = true ]; then
    jq -r '"skills corpus validation passed: \(.checkedCount)/\(.selectedCount) selected skill(s) checked"' <<< "$result"
    return 0
  fi
  printf 'skills corpus validation failed\n' >&2
  jq -r '.errors[] | "\(.code): \(.message)"' <<< "$result" >&2
  return 0
}

parse_args() {
  local arg name
  root=$DEFAULT_ROOT
  only_set=0
  only_names=()
  json=0
  help=0
  while [ "$#" -gt 0 ]; do
    arg=$1
    case $arg in
      --root|--only)
        if [ "$#" -lt 2 ] || [ -z "$2" ] || [[ $2 == --* ]]; then
          ERR_CODE=ARG_VALUE_MISSING
          ERR_MSG="$arg requires a value"
          return 1
        fi
        if [ "$arg" = '--root' ]; then
          root=$2
        else
          only_set=1
          only_names=()
          while IFS= read -r name; do
            name=${name#"${name%%[![:space:]]*}"}
            name=${name%"${name##*[![:space:]]}"}
            if [ -n "$name" ]; then
              only_names[${#only_names[@]}]=$name
            fi
          done < <(printf '%s\n' "$2" | tr ',' '\n')
        fi
        shift
        ;;
      --json) json=1 ;;
      --help|-h) help=1 ;;
      *)
        ERR_CODE=ARG_UNKNOWN
        ERR_MSG="Unknown argument: $arg"
        return 1
        ;;
    esac
    shift
  done
  return 0
}

# --- main -------------------------------------------------------------------

root=$DEFAULT_ROOT
only_set=0
only_names=()
json=0
help=0
ERR_CODE=''
ERR_MSG=''

if ! parse_args "$@"; then
  jq -n --arg code "$ERR_CODE" --arg message "$ERR_MSG" \
    '{ok:false,root:"skills",totalTopLevelSkills:0,selectedSkills:[],selectedCount:0,checkedCount:0,summary:{passed:0,failed:0,warnings:0},skills:[],errors:[{code:$code,message:$message}]}'
  exit 2
fi

if [ "$help" -eq 1 ]; then
  print_help
  exit 0
fi

result=$(build_result)
write_result "$result" "$json"

if [ "$(jq -r '.ok' <<< "$result")" = true ]; then
  exit 0
fi
exit 1
