#!/usr/bin/env bash
# Validates the skill-tester core, local markdown resources, and the
# machine-readable regression fixture. Uses bash and jq only.
set -euo pipefail
shopt -s dotglob nullglob

REQUIRED_SECTIONS=(output_language purpose routing_rule instruction_contract activation_examples trigger_conditions skill_architecture loop_policy language_and_translation_default reference_routing support_file_read_order workflow required forbidden validation)
CATEGORY_FLOORS=(positive:3 negative:2 boundary:1 workflow:1 source:1 safety:1 adversarial:1 regression:1)
LANGUAGE_FLOORS=(en:1 ko:1 mixed:1)

cwd=$(pwd -P)
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/validate-skill-tester.XXXXXX")
trap 'rm -rf "$tmpdir"' EXIT
errors_file="$tmpdir/errors.jsonl"
: > "$errors_file"

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

rel_text() { # absolute path, relative to cwd without a fallback
  relpath "$cwd" "$1"
}

# --- issue helpers ----------------------------------------------------------

issue_code_msg() { # code message
  jq -cn --arg code "$1" --arg message "$2" '{code:$code,message:$message}' >> "$errors_file"
}

issue_path() { # code message path
  jq -cn --arg code "$1" --arg message "$2" --arg path "$3" \
    '{code:$code,message:$message,path:$path}' >> "$errors_file"
}

issue_href() { # code message path href
  jq -cn --arg code "$1" --arg message "$2" --arg path "$3" --arg href "$4" \
    '{code:$code,message:$message,path:$path,href:$href}' >> "$errors_file"
}

issue_read_failed() { # code message path detail
  jq -cn --arg code "$1" --arg message "$2" --arg path "$3" --arg detail "$4" \
    '{code:$code,message:$message,path:$path,detail:$detail}' >> "$errors_file"
}

issue_unclosed() { # code message path unclosed-json
  jq -cn --arg code "$1" --arg message "$2" --arg path "$3" --argjson unclosed "$4" \
    '{code:$code,message:$message,path:$path,unclosed:$unclosed}' >> "$errors_file"
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

# Whole lines that are a single structural tag, lowercased.
extract_tags() {
  LC_ALL=C awk '{ line = tolower($0); if (line ~ /^<\/?[a-z][a-z0-9_]*>[ \t\f\v\r]*$/) print line }' "$1"
}

# Lines of the form `@path.md`.
extract_at_links() {
  LC_ALL=C awk 'length($0) > 2 && /^@/ { s = substr($0, 2); if (s ~ /^[^ \t\r]+\.md[ \t\r]*$/) { sub(/[ \t\r]+$/, "", s); print s } }' "$1"
}

# Inline markdown links, first group of the link target.
extract_md_links() {
  LC_ALL=C awk '
    {
      s = $0
      while (match(s, /!?\[[^]]*\]\(/)) {
        rest = substr(s, RSTART + RLENGTH)
        link = ""
        i = 1
        while (i <= length(rest)) {
          c = substr(rest, i, 1)
          if (c == " " || c == "\t" || c == ")") break
          link = link c
          i++
        }
        if (link != "" && link !~ /^(https?:|mailto:|#)/) print link
        s = substr(rest, i)
      }
    }
  ' "$1"
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

decode_uri() { # percent-decoded argument
  local s=$1
  s=${s//%/\\x}
  printf '%b' "$s"
}

starts_with_trigger() {
  case $1 in
    'Use this skill when') return 0 ;;
    'Use this skill when'[!A-Za-z0-9_]*) return 0 ;;
  esac
  return 1
}

string_length() { # codepoint length like JS .length for BMP text
  jq -rn --arg s "$1" '$s | length'
}

walk_contains() { # root relPath (checked against FILES)
  local root=$1 want=$2 file
  for file in ${FILES[@]+"${FILES[@]}"}; do
    if [ "${file#"$root"/}" = "$want" ]; then
      return 0
    fi
  done
  return 1
}

# --- directory walking ------------------------------------------------------

FILES=()

walk_files() { # root
  local root=$1 entry current count=1
  local -a stack=()
  local -a found=()
  local -a sorted=()
  stack[0]=$root
  while [ "$count" -gt 0 ]; do
    count=$((count - 1))
    current=${stack[count]}
    if [ ! -r "$current" ] || [ ! -x "$current" ]; then
      issue_read_failed DIR_READ_FAILED "Cannot read directory: $(rel_text "$current")" \
        "$(rel_text "$current")" 'EACCES: permission denied, scandir' 
      continue
    fi
    for entry in "$current"/*; do
      if [ -L "$entry" ]; then
        continue
      elif [ -d "$entry" ]; then
        stack[count]=$entry
        count=$((count + 1))
      elif [ -f "$entry" ]; then
        found[${#found[@]}]=$entry
      fi
    done
  done
  if [ "${#found[@]}" -gt 0 ]; then
    while IFS= read -r entry; do
      sorted[${#sorted[@]}]=$entry
    done < <(printf '%s\n' ${found[@]+"${found[@]}"} | LC_ALL=C sort)
  fi
  FILES=(${sorted[@]+"${sorted[@]}"})
}

# --- core checks ------------------------------------------------------------

check_core() { # root ; prints the core object on stdout
  local root=$1 english_path korean_path expected_name
  local metadata=true sections ok=true pairs direct_links=true
  local name description file body missing_sections=() section
  english_path="$root/SKILL.md"
  korean_path="$root/SKILL.ko.md"
  expected_name=${root##*/}

  if [ ! -e "$english_path" ] || [ ! -e "$korean_path" ]; then
    if [ ! -e "$english_path" ]; then
      issue_path SKILL_MISSING 'Missing SKILL.md' 'SKILL.md'
    fi
    if [ ! -e "$korean_path" ]; then
      issue_path KOREAN_CORE_MISSING 'Missing SKILL.ko.md' 'SKILL.ko.md'
    fi
    printf '%s' '{"metadata":false,"sections":false,"parity":false,"directLinks":false}'
    return 0
  fi

  for file in 'SKILL.md' 'SKILL.ko.md'; do
    body="$root/$file"
    name=$(frontmatter_value "$body" name)
    description=$(frontmatter_value "$body" description)
    if [ "$name" != "$expected_name" ] || ! is_kebab "$name"; then
      metadata=false
      jq -cn --arg code FRONTMATTER_NAME \
        --arg message "Skill name must be kebab-case and match $expected_name" \
        --arg path "$file" --arg actual "$name" \
        '{code:$code,message:$message,path:$path,actual:$actual}' >> "$errors_file"
    fi
    if [ -z "$description" ] || [ "$(string_length "$description")" -gt 1024 ]; then
      metadata=false
      issue_path FRONTMATTER_DESCRIPTION 'Description must contain 1–1024 characters.' "$file"
    fi
  done

  if ! starts_with_trigger "$(frontmatter_value "$english_path" description)"; then
    metadata=false
    issue_path FRONTMATTER_TRIGGER "Canonical description must start with 'Use this skill when'." 'SKILL.md'
  fi

  for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! LC_ALL=C grep -qiE "<${section}([^A-Za-z0-9_]|$)" "$english_path"; then
      missing_sections[${#missing_sections[@]}]=$section
    fi
  done
  for section in ${missing_sections[@]+"${missing_sections[@]}"}; do
    issue_path SECTION_MISSING "Required section missing: $section" 'SKILL.md'
  done
  if [ "${#missing_sections[@]}" -eq 0 ]; then sections=true; else sections=false; fi

  local tags_match=0 links_match=0
  if cmp -s <(extract_tags "$english_path") <(extract_tags "$korean_path"); then
    tags_match=1
  fi
  if cmp -s <(extract_at_links "$english_path" | sed 's/\.ko\.md$/.md/') \
             <(extract_at_links "$korean_path" | sed 's/\.ko\.md$/.md/'); then
    links_match=1
  fi
  if [ "$tags_match" -eq 0 ]; then
    issue_code_msg BILINGUAL_TAG_DRIFT 'Core structural tags differ.'
  fi
  if [ "$links_match" -eq 0 ]; then
    issue_code_msg BILINGUAL_LINK_DRIFT 'Core direct links differ.'
  fi
  if [ "$tags_match" -eq 1 ] && [ "$links_match" -eq 1 ]; then pairs=true; else pairs=false; fi

  local link resolved
  while IFS= read -r link; do
    [ -n "$link" ] || continue
    resolved=$(normalize_path "$root/$link")
    if ! is_inside "$root" "$resolved" || [ ! -e "$resolved" ]; then
      direct_links=false
      issue_href DIRECT_LINK_MISSING "Direct support link does not resolve: $link" 'SKILL.md' "$link"
    fi
  done < <(extract_at_links "$english_path")

  jq -cn --argjson metadata "$metadata" --argjson sections "$sections" \
    --argjson parity "$pairs" --argjson directLinks "$direct_links" \
    '{metadata:$metadata,sections:$sections,parity:$parity,directLinks:$directLinks}'
}

is_kebab() {
  case $1 in
    ''|*[!a-z0-9-]*) return 1 ;;
    -*|*-) return 1 ;;
    *--*) return 1 ;;
  esac
  return 0
}

# --- markdown checks --------------------------------------------------------

check_markdown() { # root ; prints the markdown object on stdout
  local root=$1
  local pairs=true fences_ok=true links_ok=true file rel sibling unclosed link target

  for file in ${MARKDOWN[@]+"${MARKDOWN[@]}"}; do
    rel=${file#"$root"/}
    case $rel in
      *.ko.md) sibling="${rel%.ko.md}.md" ;;
      *) sibling="${rel%.md}.ko.md" ;;
    esac
    if ! walk_contains "$root" "$sibling"; then
      pairs=false
      issue_path BILINGUAL_PAIR_MISSING "Missing markdown sibling: $sibling" "$rel"
    fi
    if ! unclosed=$(fence_report "$file"); then
      fences_ok=false
      issue_unclosed CODE_FENCE_UNBALANCED 'Unbalanced code fence.' "$rel" "$(printf '%s\n' "$unclosed" | jq -s '.')"
    fi
    while IFS= read -r link; do
      [ -n "$link" ] || continue
      case $link in
        *.md) ;;
        *) continue ;;
      esac
      target=$(normalize_path "$(dirname_of "$file")/$(decode_uri "${link%%#*}")")
      if ! is_inside "$root" "$target" || [ ! -e "$target" ]; then
        links_ok=false
        issue_href LINK_MISSING "Local markdown link does not resolve: $rel -> $link" "$rel" "$link"
      fi
    done < <(extract_at_links "$file")
    while IFS= read -r link; do
      [ -n "$link" ] || continue
      target=$(normalize_path "$(dirname_of "$file")/$(decode_uri "${link%%#*}")")
      if ! is_inside "$root" "$target" || [ ! -e "$target" ]; then
        links_ok=false
        issue_href LINK_MISSING "Local markdown link does not resolve: $rel -> $link" "$rel" "$link"
      fi
    done < <(extract_md_links "$file")
  done

  jq -cn --argjson pairs "$pairs" --argjson fences "$fences_ok" --argjson links "$links_ok" \
    '{pairs:$pairs,fences:$fences,links:$links}'
}

dirname_of() {
  case $1 in
    */*) printf '%s' "${1%/*}" ;;
    *) printf '.' ;;
  esac
}

# --- eval checks ------------------------------------------------------------

is_text() {
  [ -n "$1" ] && [[ $1 == *[![:space:]]* ]]
}

issue_row_invalid() { # message line row-json
  jq -cn --arg message "$1" --argjson line "$2" --arg path "$eval_path" --argjson row "$3" \
    'if ($row | has("id")) then
       {code:"EVAL_ROW_INVALID",message:$message,path:$path,line:$line,id:$row.id}
     else
       {code:"EVAL_ROW_INVALID",message:$message,path:$path,line:$line}
     end' >> "$errors_file"
}

issue_line_json() { # code message path line
  jq -cn --arg code "$1" --arg message "$2" --arg path "$3" --argjson line "$4" \
    '{code:$code,message:$message,path:$path,line:$line}' >> "$errors_file"
}

issue_floor() { # code message path actual
  jq -cn --arg code "$1" --arg message "$2" --arg path "$3" --argjson actual "$4" \
    '{code:$code,message:$message,path:$path,actual:$actual}' >> "$errors_file"
}

# shellcheck disable=SC2016  # jq variables, not shell expansions.
ROW_MESSAGES_FILTER='
  def text: type == "string" and test("\\S");
  def record: type == "object";
  def category_problem:
    if (.category | text) then
      (if $cats[.category] == true then empty else "Eval row has unsupported category." end)
    else "Eval row has unsupported category." end;
  def language_problem:
    if (.language | text) then
      (if $langs[.language] == true then empty else "Eval row has unsupported language." end)
    else "Eval row has unsupported language." end;
  def risk_problem:
    if (.risk | text) then
      (if $risks[.risk] == true then empty else "Eval row has unsupported risk." end)
    else "Eval row has unsupported risk." end;
  def intent_problem:
    if ((.intent | text) and (.prompt | text)) then empty
    else "Eval row requires non-empty intent and prompt." end;
  def context_problem:
    if ((.context | record) and (.context.files | type) == "array" and (.context.sources | type) == "array") then empty
    else "Eval row context requires files and sources arrays." end;
  def metrics_problem:
    if ((.metrics | type) != "array") then "Eval row requires non-empty metrics."
    elif ((.metrics | length) == 0) then "Eval row requires non-empty metrics."
    elif ([.metrics[] | text] | all | not) then "Eval row requires non-empty metrics."
    else empty end;
  def expected_problem:
    if ((.expected | record) | not) then "Eval row expected requires non-empty must and mustNot arrays."
    elif ((.expected.must | type) != "array") then "Eval row expected requires non-empty must and mustNot arrays."
    elif ((.expected.must | length) == 0) then "Eval row expected requires non-empty must and mustNot arrays."
    elif ((.expected.mustNot | type) != "array") then "Eval row expected requires non-empty must and mustNot arrays."
    elif ((.expected.mustNot | length) == 0) then "Eval row expected requires non-empty must and mustNot arrays."
    else empty end;
  def trigger_problem:
    . as $row
    | if (($row.category | text) and (["positive", "negative", "boundary", "coexistence"] | index($row.category) != null)) then
        (if ($row.expect == "trigger" or $row.expect == "no_trigger") then empty
         else "Trigger eval requires expect to be trigger or no_trigger." end),
        (if (($row.runs | type) == "number" and ($row.runs | floor) == $row.runs and $row.runs >= 1) then empty
         else "Trigger eval requires a positive integer runs value on the case." end),
        (if (($row.threshold | type) == "number" and $row.threshold > 0 and $row.threshold < 1) then empty
         else "Trigger eval requires a threshold between 0 and 1 on the case." end)
      else empty end;
  [category_problem, language_problem, risk_problem, intent_problem, context_problem, metrics_problem, expected_problem, trigger_problem]
  | .[]'

check_evals() { # evalPath; prints the evals object on stdout
  local eval_path=$1
  local line row total=0 number=0 ok=true
  local count='{}' languages='{}' cat lang messages message seen idv
  seen="$tmpdir/seen-ids"
  : > "$seen"

  if [ ! -e "$eval_path" ]; then
    issue_path EVAL_FILE_MISSING "Eval fixture is missing: $eval_path" "$eval_path"
    printf '%s' '{"total":0,"count":{},"languages":{},"ok":false}'
    return 0
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    number=$((number + 1))
    line=${line%$'\r'}
    if ! is_text "$line"; then
      continue
    fi
    if ! jq -e -s 'length == 1' >/dev/null 2>&1 <<< "$line"; then
      issue_line_json EVAL_JSON_INVALID 'Eval row is not valid JSON: invalid JSON' "$eval_path" "$number"
      continue
    fi
    row=$(jq -c . <<< "$line")
    total=$((total + 1))
    if [ "$(jq -r 'type == "object"' <<< "$row")" != true ]; then
      issue_line_json EVAL_ROW_INVALID 'Eval row must be an object.' "$eval_path" "$number"
      continue
    fi

    if [ "$(jq -r '(.id | type) == "string" and (.id | test("^[a-z0-9]+(-[a-z0-9]+)*$"))' <<< "$row")" = true ]; then
      idv=$(jq -r '.id' <<< "$row")
      if grep -Fxq -- "$idv" "$seen"; then
        issue_row_invalid "Duplicate eval id: $idv" "$number" "$row"
      else
        printf '%s\n' "$idv" >> "$seen"
      fi
    else
      issue_row_invalid 'Eval row requires a unique kebab-case id.' "$number" "$row"
    fi

    cat=$(jq -r 'if (.category | type) == "string" then .category else "" end' <<< "$row")
    case $cat in
      positive|negative|boundary|workflow|source|safety|adversarial|regression|coexistence)
        count=$(jq -cn --argjson c "$count" --arg k "$cat" '$c + {($k): (($c[$k] // 0) + 1)}')
        ;;
    esac
    lang=$(jq -r 'if (.language | type) == "string" then .language else "" end' <<< "$row")
    case $lang in
      en|ko|mixed)
        languages=$(jq -cn --argjson c "$languages" --arg k "$lang" '$c + {($k): (($c[$k] // 0) + 1)}')
        ;;
    esac

    messages=$(jq -r \
      --argjson cats '{"positive":true,"negative":true,"boundary":true,"workflow":true,"source":true,"safety":true,"adversarial":true,"regression":true,"coexistence":true}' \
      --argjson langs '{"en":true,"ko":true,"mixed":true}' \
      --argjson risks '{"smoke":true,"targeted":true,"standard":true,"thorough":true,"high-stakes":true}' \
      "$ROW_MESSAGES_FILTER" <<< "$row")
    if [ -n "$messages" ]; then
      while IFS= read -r message; do
        [ -n "$message" ] || continue
        issue_row_invalid "$message" "$number" "$row"
      done <<< "$messages"
    fi
  done < <(cat "$eval_path"; printf '\n')

  local spec floor actual
  for spec in "${CATEGORY_FLOORS[@]}"; do
    cat=${spec%%:*}
    floor=${spec##*:}
    actual=$(jq -r --arg k "$cat" '.[$k] // 0' <<< "$count")
    if [ "$actual" -lt "$floor" ]; then
      issue_floor EVAL_CATEGORY_FLOOR "Expected at least $floor $cat case(s)." "$eval_path" "$actual"
    fi
  done
  for spec in "${LANGUAGE_FLOORS[@]}"; do
    lang=${spec%%:*}
    floor=${spec##*:}
    actual=$(jq -r --arg k "$lang" '.[$k] // 0' <<< "$languages")
    if [ "$actual" -lt "$floor" ]; then
      issue_floor EVAL_LANGUAGE_FLOOR "Expected at least $floor $lang case(s)." "$eval_path" "$actual"
    fi
  done

  if jq -s 'any(.[]; (.code | type == "string") and (.code | startswith("EVAL_")))' "$errors_file" | grep -q true; then
    ok=false
  fi

  jq -cn --argjson total "$total" --argjson count "$count" --argjson languages "$languages" \
    --argjson ok "$ok" '{total:$total,count:$count,languages:$languages,ok:$ok}'
}

# --- arguments --------------------------------------------------------------


parse_args() {
  root='skills/skill-tester'
  evals='skills/skill-tester/assets/evals/skill-tester-cases.jsonl'
  json=0
  help=0
  while [ "$#" -gt 0 ]; do
    case $1 in
      --root|--evals)
        if [ "$#" -lt 2 ] || [ -z "$2" ] || [[ $2 == --* ]]; then
          ERR_CODE=ARG_VALUE_MISSING
          ERR_MSG="$1 requires a value."
          return 1
        fi
        if [ "$1" = '--root' ]; then
          root=$2
        else
          evals=$2
        fi
        shift
        ;;
      --json) json=1 ;;
      --help|-h) help=1 ;;
      *)
        ERR_CODE=ARG_UNKNOWN
        ERR_MSG="Unknown argument: $1"
        return 1
        ;;
    esac
    shift
  done
  return 0
}

print_help() {
  printf '%s\n' 'Usage: bash skills/skill-tester/scripts/validate-skill-tester.sh [--root <skill-dir>] [--evals <jsonl>] [--json]'
  printf '\n'
  printf '%s\n' 'Validates the skill-tester core, local markdown resources, and machine-readable regression fixture with bash and jq.'
}

# --- main -------------------------------------------------------------------

root='skills/skill-tester'
evals='skills/skill-tester/assets/evals/skill-tester-cases.jsonl'
json=0
help=0
ERR_CODE=''
ERR_MSG=''

if ! parse_args "$@"; then
  jq -n --arg code "$ERR_CODE" --arg message "$ERR_MSG" \
    '{ok:false,errors:[{code:$code,message:$message}]}'
  exit 2
fi

if [ "$help" -eq 1 ]; then
  print_help
  exit 0
fi

root_abs=$(abspath "$root")
evals_abs=$(abspath "$evals")
if [ ! -e "$root_abs" ] || [ ! -d "$root_abs" ]; then
  issue_path ROOT_MISSING "Skill root is not a directory: $root" "$root"
fi

FILES=()
if [ ! -s "$errors_file" ]; then
  walk_files "$root_abs"
fi

MARKDOWN=()
for file in ${FILES[@]+"${FILES[@]}"}; do
  case $file in
    *.md) MARKDOWN[${#MARKDOWN[@]}]=$file ;;
  esac
done

core='null'
markdown_report='null'
if [ ! -s "$errors_file" ]; then
  core=$(check_core "$root_abs")
fi
if [ ! -s "$errors_file" ]; then
  markdown_report=$(check_markdown "$root_abs")
fi

evals_report=$(check_evals "$evals_abs")

ok=true
if [ -s "$errors_file" ]; then ok=false; fi

root_display=$(display_path "$root_abs")
if [ "$root_display" = "$root_abs" ]; then
  root_display=$root
fi

result=$(jq -n --argjson ok "$ok" --arg root "$root_display" --argjson core "$core" \
  --argjson markdown "$markdown_report" --argjson evals "$evals_report" \
  --slurpfile errors "$errors_file" \
  '{ok:$ok,root:$root,core:$core,markdown:$markdown,evals:$evals,errors:$errors}')

if [ "$json" -eq 1 ]; then
  printf '%s\n' "$result"
elif [ "$ok" = true ]; then
  printf 'skill-tester validation passed\n'
else
  printf 'skill-tester validation failed\n'
fi

if [ "$ok" = true ]; then
  exit 0
fi
exit 1
