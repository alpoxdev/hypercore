#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "${script_dir}/.." && pwd)"

core_en="${skill_dir}/SKILL.md"
core_ko="${skill_dir}/SKILL.ko.md"
repo_discover="${script_dir}/repo-discover.sh"
repo_status="${script_dir}/repo-status.sh"
git_commit_script="${script_dir}/git-commit.sh"
git_push_script="${script_dir}/git-push.sh"

score=0
max_score=31

trigger_boundary_pass=0
repo_discovery_pass=0
staging_discipline_pass=0
message_integrity_pass=0
push_handoff_pass=0
all_mode_pass=0

declare -a check_rows=()
declare -a temp_dirs=()

cleanup_temp_dirs() {
  if [[ ${#temp_dirs[@]} -gt 0 ]]; then
    rm -rf "${temp_dirs[@]}"
  fi
}

trap cleanup_temp_dirs EXIT

file_has() {
  local file=$1
  local pattern=$2
  [[ -f "${file}" ]] && grep -Eq -- "${pattern}" "${file}"
}

all_files_have() {
  local pattern=$1
  shift
  local file
  for file in "$@"; do
    if ! file_has "${file}" "${pattern}"; then
      return 1
    fi
  done
}

file_pairs_have() {
  while [[ $# -gt 0 ]]; do
    local file=$1
    local pattern=$2
    shift 2
    if ! file_has "${file}" "${pattern}"; then
      return 1
    fi
  done
}

repo_discovery_scripts_are_documented() {
  file_has "${core_en}" 'scripts/repo-discover\.sh' &&
    file_has "${core_en}" 'scripts/repo-status\.sh' &&
    file_has "${core_ko}" 'scripts/repo-discover\.sh' &&
    file_has "${core_ko}" 'scripts/repo-status\.sh'
}

scope_boundary_is_documented() {
  file_has "${core_en}" 'Commit only\.' &&
    file_has "${core_en}" 'user explicitly asks' &&
    file_has "${core_ko}" '커밋까지만 수행한다\.' &&
    file_has "${core_ko}" '명시적으로 요청하지 않으면'
}

start_dir_and_descendant_routing_are_documented() {
  file_has "${core_en}" 'Start from the current working directory' &&
    file_has "${core_en}" 'inspect descendant directories' &&
    file_has "${core_ko}" '현재 작업 디렉터리에서 시작한다' &&
    file_has "${core_ko}" '하위 디렉터리들에 git 저장소가 있는지'
}

forbid_blanket_staging_is_documented() {
  file_has "${core_en}" 'git add \.' &&
    file_has "${core_en}" 'blanket staging' &&
    file_has "${core_ko}" 'git add \.' &&
    file_has "${core_ko}" '전체 스테이징|관련 없는 변경이 섞여 있는데'
}

message_format_is_documented() {
  file_has "${core_en}" '<type>\[optional scope\]: <subject>' &&
    file_has "${core_en}" 'keep the subject under 72 characters' &&
    file_has "${core_ko}" '<type>\[optional scope\]: <subject>' &&
    file_has "${core_ko}" '72자 이내'
}

multiline_helper_is_documented() {
  file_has "${core_en}" 'Body or footer included' &&
    file_has "${core_en}" 'scripts/git-commit\.sh' &&
    file_has "${core_en}" "cat <<'EOF'" &&
    file_has "${core_ko}" 'body 또는 footer가 있으면' &&
    file_has "${core_ko}" 'scripts/git-commit\.sh' &&
    file_has "${core_ko}" "cat <<'EOF'"
}

korean_language_rule_is_documented() {
  file_has "${core_en}" 'Write commit subject and body in Korean' &&
    file_has "${core_en}" 'type.*and.*scope.*stay in English' &&
    file_has "${core_ko}" '커밋 subject와 body를 한국어로 작성' &&
    file_has "${core_ko}" 'type.*과.*scope.*는 영어로 유지'
}

push_confirmation_is_documented() {
  file_has "${core_en}" 'Commit created\. Run git push\?' &&
    file_has "${core_en}" 'plain-text question' &&
    file_has "${core_ko}" 'Commit created\. Run git push\?' &&
    file_has "${core_ko}" '평문 질문'
}

make_repo() {
  local dir=$1
  local branch=${2:-main}
  mkdir -p "${dir}"
  git init -q -b "${branch}" "${dir}"
  (
    cd "${dir}"
    printf 'seed\n' > seed.txt
    git add seed.txt
    git -c user.name='Eval User' -c user.email='eval@example.com' commit -qm 'chore: init fixture'
  )
}

current_repo_discover_works() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo"
  local output
  output="$("${repo_discover}" "${tmpdir}/repo")"
  [[ "${output}" == "current|$(cd "${tmpdir}/repo" && pwd -P)" ]]
}

descendant_repo_discover_works() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  mkdir -p "${tmpdir}/root"
  make_repo "${tmpdir}/root/repo-a"
  make_repo "${tmpdir}/root/repo-b"

  local output
  output="$("${repo_discover}" "${tmpdir}/root")"
  local expected_a="descendant|${tmpdir}/root/repo-a"
  local expected_b="descendant|${tmpdir}/root/repo-b"

  grep -Fxq "${expected_a}" <<< "${output}" &&
    grep -Fxq "${expected_b}" <<< "${output}"
}

repo_status_reports_sections() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo"
  (
    cd "${tmpdir}/repo"
    printf 'seed-2\n' > seed.txt
    printf 'new\n' > staged.txt
    git add staged.txt
    printf 'worktree\n' > unstaged.txt
    printf 'loose\n' > loose.txt
  )

  local output
  output="$("${repo_status}" "${tmpdir}/repo")"
  local repo_root
  repo_root="$(cd "${tmpdir}/repo" && pwd -P)"

  grep -Fq "repo|${repo_root}" <<< "${output}" &&
    grep -Fq "status|begin" <<< "${output}" &&
    grep -Fq "status|end" <<< "${output}" &&
    grep -Fq "staged|begin" <<< "${output}" &&
    grep -Fq "staged|end" <<< "${output}" &&
    grep -Fq "unstaged|begin" <<< "${output}" &&
    grep -Fq "unstaged|end" <<< "${output}" &&
    grep -Fq "untracked: loose.txt" <<< "${output}"
}

selected_file_commit_is_isolated() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo"
  (
    cd "${tmpdir}/repo"
    printf 'a-2\n' > a.txt
    printf 'b-2\n' > b.txt
  )

  "${git_commit_script}" --repo "${tmpdir}/repo" "fix(scope): update a only" a.txt >/dev/null

  local subject
  subject="$(git -C "${tmpdir}/repo" log -1 --pretty=%s)"
  local changed
  changed="$(git -C "${tmpdir}/repo" show --pretty='' --name-only HEAD)"
  local status
  status="$(git -C "${tmpdir}/repo" status --short)"

  [[ "${subject}" == "fix(scope): update a only" ]] &&
    [[ "${changed}" == "a.txt" ]] &&
    grep -Fq "?? b.txt" <<< "${status}"
}

rejects_unrelated_pre_staged_files() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo"
  (
    cd "${tmpdir}/repo"
    printf 'a-2\n' > a.txt
    printf 'b-2\n' > b.txt
    git add b.txt
    set +e
    "${git_commit_script}" --repo "${tmpdir}/repo" "fix(scope): update a only" a.txt >stdout.txt 2>stderr.txt
    local rc=$?
    set -e
    [[ ${rc} -eq 1 ]] &&
      grep -Fq "Additional staged changes exist outside the requested files" stderr.txt
  )
}

rejection_keeps_staged_set_unchanged() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo"
  (
    cd "${tmpdir}/repo"
    printf 'a-2\n' > a.txt
    printf 'b-2\n' > b.txt
    git add b.txt
    local before after
    before="$(git diff --cached --name-only | sort)"
    set +e
    "${git_commit_script}" --repo "${tmpdir}/repo" "fix(scope): update a only" a.txt >/dev/null 2>&1
    set -e
    after="$(git diff --cached --name-only | sort)"
    [[ "${before}" == "${after}" ]]
  )
}

apostrophe_subject_commit_works() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo"
  (
    cd "${tmpdir}/repo"
    printf 'seed-2\n' > seed.txt
  )

  "${git_commit_script}" --repo "${tmpdir}/repo" "fix: don't drop apostrophes" seed.txt >/dev/null
  [[ "$(git -C "${tmpdir}/repo" log -1 --pretty=%s)" == "fix: don't drop apostrophes" ]]
}

multiline_commit_preserves_body_and_footer() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo"
  (
    cd "${tmpdir}/repo"
    printf 'seed-2\n' > seed.txt
  )

  local message
  printf -v message '%s\n\n%s\n\n%s' \
    "feat(cli): don't lose commit context" \
    "Preserve the user's intent when the reviewer's note contains apostrophes." \
    "Refs: #482"

  "${git_commit_script}" --repo "${tmpdir}/repo" "${message}" seed.txt >/dev/null

  local body
  body="$(git -C "${tmpdir}/repo" log -1 --pretty=%B)"
  [[ "${body%$'\n'}" == "${message}" ]]
}

detached_head_push_is_blocked() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo"
  (
    cd "${tmpdir}/repo"
    git checkout -q --detach
    set +e
    "${git_push_script}" --repo "${tmpdir}/repo" >stdout.txt 2>stderr.txt
    local rc=$?
    set -e
    [[ ${rc} -eq 1 ]] &&
      grep -Fq "Not on any branch (detached HEAD)" stderr.txt
  )
}

force_push_main_is_blocked() {
  local tmpdir
  tmpdir="$(mktemp -d)"
  temp_dirs+=("${tmpdir}")

  make_repo "${tmpdir}/repo" main
  (
    cd "${tmpdir}/repo"
    set +e
    "${git_push_script}" --repo "${tmpdir}/repo" --force >stdout.txt 2>stderr.txt
    local rc=$?
    set -e
    [[ ${rc} -eq 1 ]] &&
      grep -Fq "Cannot force push to protected branch main" stderr.txt
  )
}

check() {
  local id=$1
  local eval_name=$2
  local prompt=$3
  local description=$4
  shift 4

  local passed=false
  if "$@"; then
    passed=true
    score=$((score + 1))
    case "${eval_name}" in
      "Trigger and mode boundary")
        trigger_boundary_pass=$((trigger_boundary_pass + 1))
        ;;
      "Repository discovery")
        repo_discovery_pass=$((repo_discovery_pass + 1))
        ;;
      "Staging discipline")
        staging_discipline_pass=$((staging_discipline_pass + 1))
        ;;
      "Message integrity")
        message_integrity_pass=$((message_integrity_pass + 1))
        ;;
      "Push safety and handoff")
        push_handoff_pass=$((push_handoff_pass + 1))
        ;;
      "ALL mode and multi-group")
        all_mode_pass=$((all_mode_pass + 1))
        ;;
    esac
  fi

  check_rows+=("$(jq -nc \
    --arg id "${id}" \
    --arg eval_name "${eval_name}" \
    --arg prompt "${prompt}" \
    --arg description "${description}" \
    --argjson passed "${passed}" \
    '{id:$id, eval:$eval_name, prompt:$prompt, description:$description, passed:$passed}')")
}

check "P1E1" "Trigger and mode boundary" \
  "/git-commit" \
  "Both language variants explicitly trigger on commit requests and route away push-only requests." \
  file_pairs_have \
  "${core_en}" 'commit these changes|make a git commit|/git-commit' \
  "${core_en}" 'push/rebase/reset.*no' \
  "${core_ko}" 'commit these changes|make a git commit|/git-commit' \
  "${core_ko}" 'push/rebase/reset.*no|push/rebase/reset만 요청'

check "P1E2" "Trigger and mode boundary" \
  "/git-commit" \
  "No-argument mode iterates through all logical groups and the remaining-uncommitted fallback are explicit in both language variants." \
  file_pairs_have \
  "${core_en}" 'current session|current-session' \
  "${core_en}" 'remaining uncommitted' \
  "${core_ko}" '현재 세션' \
  "${core_ko}" '남은.*미커밋|아직 커밋되지 않은 나머지'

check "P1E3" "Trigger and mode boundary" \
  "/git-commit packages/api session validation fix" \
  "Explicit ARGUMENT mode is treated as the primary filter in both language variants." \
  file_pairs_have \
  "${core_en}" 'ARGUMENT.*primary commit target|Use ARGUMENT as the primary filter' \
  "${core_ko}" 'ARGUMENT.*기본 커밋 대상|ARGUMENT를 .*기본 대상으로 사용'

check "P1E4" "Trigger and mode boundary" \
  "/git-commit packages/api session validation fix" \
  "The skill iterates through multiple groups instead of stopping, and stops only on argument mismatches." \
  file_pairs_have \
  "${core_en}" 'Stop if ARGUMENT does not match|commit each group separately' \
  "${core_ko}" 'ARGUMENT가 .*맞지 않으면 멈춘다|각 그룹을 따로 커밋'

check "P1E5" "Trigger and mode boundary" \
  "make a git commit" \
  "The scope boundary stays commit-only unless the user explicitly asks for push or history edits." \
  scope_boundary_is_documented

check "P2E1" "Repository discovery" \
  "/git-commit from a nested working directory" \
  "Both language variants say to start from the current working directory and inspect descendants when the cwd is not itself a repository." \
  start_dir_and_descendant_routing_are_documented

check "P2E2" "Repository discovery" \
  "/git-commit" \
  "The workflow in both languages calls out repo discovery and per-repo status inspection scripts explicitly." \
  repo_discovery_scripts_are_documented

check "P2E3" "Repository discovery" \
  "/git-commit inside a repository" \
  "repo-discover.sh identifies the current repository without descending further." \
  current_repo_discover_works

check "P2E4" "Repository discovery" \
  "/git-commit from a non-repository root with child repos" \
  "repo-discover.sh enumerates descendant repositories one by one." \
  descendant_repo_discover_works

check "P2E5" "Repository discovery" \
  "/git-commit after staging one file and creating untracked work" \
  "repo-status.sh reports branch, staged, unstaged, and untracked sections in a parseable shape." \
  repo_status_reports_sections

check "P3E1" "Staging discipline" \
  "/git-commit" \
  "Both language variants forbid blanket staging such as git add ." \
  forbid_blanket_staging_is_documented

check "P3E2" "Staging discipline" \
  "/git-commit" \
  "Both language variants insist each commit covers one logical change, with multi-group iteration, and staging only the required files." \
  file_pairs_have \
  "${core_en}" 'Each commit covers exactly one logical change' \
  "${core_en}" 'Stage only the files required' \
  "${core_ko}" '각 커밋은 정확히 하나의 논리적 변경만 포함' \
  "${core_ko}" '관련 파일만 스테이징|필요한 파일만 스테이징'

check "P3E3" "Staging discipline" \
  "/git-commit src/a.txt" \
  "git-commit.sh can commit one requested file while leaving unrelated unstaged work out of the commit." \
  selected_file_commit_is_isolated

check "P3E4" "Staging discipline" \
  "/git-commit src/a.txt" \
  "git-commit.sh rejects a requested-file commit when unrelated files are already staged." \
  rejects_unrelated_pre_staged_files

check "P3E5" "Staging discipline" \
  "/git-commit src/a.txt" \
  "A rejected requested-file commit leaves the staged set unchanged instead of widening it." \
  rejection_keeps_staged_set_unchanged

check "P4E1" "Message integrity" \
  "make a git commit" \
  "Both language variants define message structure and subject-line constraints explicitly." \
  message_format_is_documented

check "P4E2" "Message integrity" \
  "make a git commit with body and footer" \
  "Both language variants show the helper-script pattern for multiline commit messages." \
  multiline_helper_is_documented

check "P4E3" "Message integrity" \
  "make a git commit with apostrophes in the subject" \
  "git-commit.sh accepts apostrophes in a subject-only Conventional Commit message." \
  apostrophe_subject_commit_works

check "P4E4" "Message integrity" \
  "make a git commit with body and footer" \
  "git-commit.sh preserves multiline messages with body and footer exactly, including apostrophes." \
  multiline_commit_preserves_body_and_footer

check "P4E5" "Message integrity" \
  "make a git commit" \
  "Both language variants include good and bad subject examples with Korean descriptions for operator calibration." \
  file_pairs_have \
  "${core_en}" 'Good subjects' \
  "${core_en}" 'Bad subjects' \
  "${core_ko}" '좋은 subject 예시' \
  "${core_ko}" '나쁜 subject 예시'

check "P4E6" "Message integrity" \
  "make a git commit" \
  "Both language variants require Korean language for commit subject and body while keeping type/scope in English." \
  korean_language_rule_is_documented

check "P5E1" "Push safety and handoff" \
  "make a git commit" \
  "Both language variants require explicit push confirmation and show the confirmation text." \
  push_confirmation_is_documented

check "P5E2" "Push safety and handoff" \
  "make a git commit" \
  "Both language variants forbid auto push, --no-verify, and history rewrites without explicit request." \
  file_pairs_have \
  "${core_en}" 'auto-running `git push`|`--no-verify`|amend, rebase, reset, force push' \
  "${core_ko}" '자동 실행|`--no-verify`|amend, rebase, reset, force push'

check "P5E3" "Push safety and handoff" \
  "git push after a detached-head commit" \
  "git-push.sh refuses to push from detached HEAD." \
  detached_head_push_is_blocked

check "P5E4" "Push safety and handoff" \
  "force push the current main branch" \
  "git-push.sh refuses force-pushes to main/master." \
  force_push_main_is_blocked

check "P5E5" "Push safety and handoff" \
  "make a git commit and then decide about push" \
  "Both language variants describe the approve/decline push branches explicitly." \
  file_pairs_have \
  "${core_en}" 'User declines push' \
  "${core_en}" 'User approves push' \
  "${core_ko}" '사용자가 push를 거절함' \
  "${core_ko}" '사용자가 push를 승인함'

check "P6E1" "ALL mode and multi-group" \
  "/git-commit ALL" \
  "Both language variants document ALL mode as taking all uncommitted changes regardless of session." \
  file_pairs_have \
  "${core_en}" 'ARGUMENT is "ALL" or "all"' \
  "${core_en}" 'regardless of whether they were touched in the current session' \
  "${core_ko}" 'ARGUMENT가 "ALL" 또는 "all"' \
  "${core_ko}" '현재 세션에서 작업했는지 여부와 관계없이'

check "P6E2" "ALL mode and multi-group" \
  "/git-commit ALL" \
  "Both language variants require every file to be committed in ALL mode with no files left behind." \
  file_pairs_have \
  "${core_en}" 'Every uncommitted file must be included in exactly one commit group' \
  "${core_en}" 'No file may be left behind' \
  "${core_ko}" '모든 미커밋 파일이 정확히 하나의 커밋 그룹에 포함' \
  "${core_ko}" '어떤 파일도 남겨두지 않는다'

check "P6E3" "ALL mode and multi-group" \
  "/git-commit" \
  "Both language variants describe multi-group iteration instead of stopping on multiple unrelated changes." \
  file_pairs_have \
  "${core_en}" 'commit them separately in sequence' \
  "${core_en}" 'Do not stop or ask for clarification' \
  "${core_ko}" '순서대로 따로 커밋' \
  "${core_ko}" '멈추거나 확인을 요청하지 않는다'

check "P6E4" "ALL mode and multi-group" \
  "/git-commit" \
  "Both language variants include grouping heuristics for partitioning changes into logical groups." \
  file_pairs_have \
  "${core_en}" 'Grouping heuristics' \
  "${core_en}" 'Test files belong with their corresponding implementation' \
  "${core_ko}" '그룹핑 휴리스틱' \
  "${core_ko}" '테스트 파일은 해당 구현 파일과 함께'

check "P6E5" "ALL mode and multi-group" \
  "/git-commit ALL" \
  "Both language variants show ALL mode examples with multiple sequential commits." \
  file_pairs_have \
  "${core_en}" '/git-commit ALL' \
  "${core_en}" 'no files left behind' \
  "${core_ko}" '/git-commit ALL' \
  "${core_ko}" '남겨지는 파일 없음'

pass_rate="$(jq -nc --argjson score "${score}" --argjson max_score "${max_score}" '$score * 100 / $max_score')"

jq -nc \
  --arg skill_name "git-commit" \
  --arg target_path "skills/git-commit" \
  --argjson score "${score}" \
  --argjson max_score "${max_score}" \
  --argjson pass_rate "${pass_rate}" \
  --argjson eval_breakdown "$(printf '%s\n' \
    "$(jq -nc --arg name 'Trigger and mode boundary' --argjson pass_count "${trigger_boundary_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    "$(jq -nc --arg name 'Repository discovery' --argjson pass_count "${repo_discovery_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    "$(jq -nc --arg name 'Staging discipline' --argjson pass_count "${staging_discipline_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    "$(jq -nc --arg name 'Message integrity' --argjson pass_count "${message_integrity_pass}" '{name:$name, pass_count:$pass_count, total:6}')" \
    "$(jq -nc --arg name 'Push safety and handoff' --argjson pass_count "${push_handoff_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    "$(jq -nc --arg name 'ALL mode and multi-group' --argjson pass_count "${all_mode_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    | jq -sc '.')" \
  --argjson checks "$(printf '%s\n' "${check_rows[@]}" | jq -sc '.')" \
  '
  {
    skill_name: $skill_name,
    target_path: $target_path,
    score: $score,
    max_score: $max_score,
    pass_rate: $pass_rate,
    eval_breakdown: $eval_breakdown,
    checks: $checks
  }'
