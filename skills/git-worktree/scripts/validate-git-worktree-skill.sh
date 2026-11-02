#!/usr/bin/env bash
# Deterministic validator for the git-worktree skill folder.
# Requires bash 3.2+ and jq 1.6+.
set -euo pipefail

script_path=${BASH_SOURCE[0]}
script_dir=${script_path%/*}
case $script_path in
  */*) ;;
  *) script_dir=. ;;
esac
script_dir=$(cd -- "$script_dir" && pwd -P)
root=${script_dir%/*}

core_path=$root/SKILL.md
ko_path=$root/SKILL.ko.md
rules_path=$root/rules/worktree-lifecycle.md
survey_path=$root/references/source-survey.md

read_text() { # $1 = path; sets REPLY to the file content (empty when missing)
  REPLY=''
  if [ -e "$1" ]; then
    IFS= read -r -d '' REPLY <"$1" || true
  fi
}

has_frontmatter() { # $1 = text
  case $1 in
    "---"$'\n'*) ;;
    *) return 1 ;;
  esac
  local rest frontmatter
  rest=${1:4}
  case $rest in
    *$'\n---'*) ;;
    *) return 1 ;;
  esac
  frontmatter=${rest%%$'\n---'*}
  case $frontmatter in *name:*) ;; *) return 1 ;; esac
  case $frontmatter in *description:*) ;; *) return 1 ;; esac
  return 0
}

contains_all() { # $1 = text, rest = needles
  local text=$1 needle
  shift
  for needle in "$@"; do
    case $text in
      *"$needle"*) ;;
      *) return 1 ;;
    esac
  done
  return 0
}

contains_korean_operation_menu() { # $1 = text
  contains_all "$1" "어떤 worktree 작업을 원하시나요?" "생성" "목록" "열기/이동" "삭제" "정리" "복구" "잠금"
}

line_count() { # $1 = path
  if [ ! -e "$1" ]; then
    printf '0'
    return 0
  fi
  jq -Rn --rawfile t "$1" '
    if $t == "" then 0
    else
      ($t | gsub("\r\n"; "\n")) as $s
      | ($s | [match("[\n\r\u000b\u000c\u001c-\u001e\u0085\u2028\u2029]"; "g")] | length) as $n
      | if ($s | test("[\n\r\u000b\u000c\u001c-\u001e\u0085\u2028\u2029]$")) then $n else $n + 1 end
    end'
}

core=''
read_text "$core_path"; core=$REPLY
ko=''
read_text "$ko_path"; ko=$REPLY
rules=''
read_text "$rules_path"; rules=$REPLY
survey=''
read_text "$survey_path"; survey=$REPLY

combined=$core$'\n'$ko$'\n'$rules
core_lines=$(line_count "$core_path")

support_refs=$(printf '%s' "$core" | awk '
  substr($0, 1, 7) == "@rules/" && length($0) > 7 { print "rules"; next }
  substr($0, 1, 12) == "@references/" && length($0) > 12 { print "references" }' | paste -sd, -)

source_count=$(printf '%s' "$survey" | awk '$0 ~ /^[0-9]+\. \*\*/ { c++ } END { print c + 0 }')

checks_tsv=''
add_check() { # $1 = id, $2 = 1 when passing, $3 = detail
  checks_tsv=$checks_tsv$2$'\t'$1$'\t'$3$'\n'
}

if has_frontmatter "$core" && has_frontmatter "$ko"; then p=1; else p=0; fi
add_check frontmatter_present "$p" "SKILL.md and SKILL.ko.md must retain parseable metadata blocks."

if [ "$core_lines" -lt 300 ]; then p=1; else p=0; fi
add_check core_under_300_lines "$p" "SKILL.md has ${core_lines} lines; keep core instructions lean."

if [ "$support_refs" = "rules" ] && contains_all "$core" "references/source-survey.md" "not loaded by default"; then p=1; else p=0; fi
add_check one_level_support_refs "$p" "Core skill should import only the lifecycle rule and link the source survey on demand."

if contains_all "$core" "이 worktree에서 어떤 작업을 할 예정인가요?" &&
  contains_all "$ko" "이 worktree에서 어떤 작업을 할 예정인가요?" &&
  contains_all "$rules" "이 worktree에서 어떤 작업을 할 예정인가요?"; then p=1; else p=0; fi
add_check korean_intent_question_present "$p" "Ambiguous create requests from Korean users need a Korean work-intent question."

if contains_korean_operation_menu "$ko" && contains_korean_operation_menu "$rules"; then p=1; else p=0; fi
add_check korean_operation_question_present "$p" "Only truly ambiguous operation selection should use a localized Korean menu."

if contains_all "$combined" "What worktree operation do you want"; then p=0; else p=1; fi
add_check exact_english_operation_menu_absent "$p" "The user-reported English operation menu must not appear in operative guidance."

if contains_all "$combined" "infer the operation" "문맥에서 추론"; then p=1; else p=0; fi
add_check infer_before_asking "$p" "Agents should infer create/open/remove/etc. before asking another question."

if contains_all "$core" "git-worktree <ARGUMENT>" "do not ask what worktree to create" "positional argument" &&
  contains_all "$ko" "git-worktree <ARGUMENT>" "되묻지" "위치 인자" &&
  contains_all "$rules" "git-worktree <ARGUMENT>" "Direct argument fast path" "do not ask what worktree to create"; then p=1; else p=0; fi
add_check direct_argument_create_fast_path "$p" "Direct git-worktree <ARGUMENT> invocations should create from the argument without a work-intent question."

if contains_all "$core" "creation is not complete until the active execution context has moved" &&
  contains_all "$ko" "생성은 새 worktree 컨텍스트로 전환된 뒤에 완료"; then p=1; else p=0; fi
add_check create_not_done_until_context_moved "$p" "Creation must include moving the active context into the new worktree."

if contains_all "$core" "create and enter/open/switch" "do not stop after \`git worktree add\`" &&
  contains_all "$ko" "생성하고 들어가/이동/전환/열어줘" "\`git worktree add\`나 \`cd <path>\` 안내만 하고 멈추지" &&
  contains_all "$rules" "enter" "open" "switch" "go into it" "들어가" "이동" "전환" "not complete until follow-up commands run from the new path"; then p=1; else p=0; fi
add_check create_enter_open_switch_single_operation "$p" "Create+enter/open/switch requests should be treated as one completed operation."

if contains_all "$core$rules" "workdir=<path>" "cd <path>" "parent shell" &&
  contains_all "$ko" "부모 셸" "\`cd <path>\`"; then p=1; else p=0; fi
add_check agent_workdir_and_parent_shell_cd "$p" "Agent environments need workdir guidance and parent-shell cd reporting."

if contains_all "$core" "actually execute \`cd <path>\`" "Do not merely display \`cd <path>\`" &&
  contains_all "$ko" "실제로 \`cd <path>\`를 실행" "\`cd <path>\`를 최종 답변으로 표시만 하고 멈추지" &&
  contains_all "$rules" "actually executing \`cd <path>\`" "Do not claim the active context moved if you only printed \`cd <path>\`"; then p=1; else p=0; fi
add_check no_cd_only_after_create "$p" "Creation should require a real persistent-session cd when available, or a tool workdir fallback."

if contains_all "$core$rules" "git -C <path> status --short --branch" "workdir=<path>" "cd <path> && pwd"; then p=1; else p=0; fi
add_check post_create_status_verification "$p" "Post-create examples should verify status and demonstrate entry."

# shellcheck disable=SC2016 # needles are matched literally, not expanded
if contains_all "$core$rules" "target_path" "main_path" "Refuse" 'git worktree remove "$target_path"' ||
  contains_all "$core$rules" "target_path" "main_path" "refuse" 'git worktree remove "$target_path"'; then p=1; else p=0; fi
add_check current_worktree_delete_safety "$p" "Deleting the current linked worktree must save target path, refuse main, move out, then remove saved target."

if contains_all "$rules" "Only use force when explicitly requested" "dirty current-worktree deletion"; then p=1; else p=0; fi
add_check dirty_remove_requires_explicit_force "$p" "Dirty worktree deletion must require explicit force/discard intent."

if contains_all "$core$rules" ".hyper/git-worktree/" "git rev-parse --git-path info/exclude" "local excludes"; then p=1; else p=0; fi
add_check nested_worktree_exclude_rule "$p" "Nested project-local worktrees need local exclude protection."

if contains_all "$core" "validate-git-worktree-skill" "clarification questions match the user's language" "after creation, subsequent commands use the new worktree" &&
  contains_all "$ko" "validate-git-worktree-skill" "영어 작업 메뉴" "workdir=<path>"; then p=1; else p=0; fi
add_check validation_checklist_covers_new_edges "$p" "Validation checklists should lock the language and post-create context edges."

if [ "$source_count" -ge 10 ]; then p=1; else p=0; fi
add_check source_survey_still_available "$p" "Source survey should retain external rationale breadth; found ${source_count} numbered sources."

report=$(jq -n \
  --arg tsv "$checks_tsv" \
  --argjson core_lines "$core_lines" \
  --argjson source_count "$source_count" '
  ($tsv | split("\n") | map(select(length > 0) | split("\t") | {id: .[1], pass: (.[0] == "1"), detail: .[2]})) as $checks
  | ($checks | length) as $total
  | ($checks | map(select(.pass)) | length) as $score
  | {
      score: $score,
      total: $total,
      percent: ((($score / $total) * 10000 | round) / 100),
      metrics: {core_lines: $core_lines, source_count: $source_count},
      checks: $checks
    }')

printf '%s\n' "$report"
if [ "$(printf '%s' "$report" | jq '[.checks[] | select(.pass | not)] | length')" -ne 0 ]; then
  printf 'FAILED: %s\n' "$(printf '%s' "$report" | jq -r '[.checks[] | select(.pass | not) | .id] | join(", ")')" >&2
  exit 1
fi
