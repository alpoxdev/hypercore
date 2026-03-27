#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "${script_dir}/.." && pwd)"

core="${skill_dir}/SKILL.md"
push_script="${script_dir}/git-push.sh"

score=0
max_score=12

trigger_quality_pass=0
script_safety_pass=0
push_behavior_pass=0
skill_structure_pass=0

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

make_repo_with_remote() {
  local dir=$1
  local branch=${2:-main}
  mkdir -p "${dir}"
  git init -q --bare "${dir}/origin.git"
  mkdir -p "${dir}/work"
  git init -q -b "${branch}" "${dir}/work"
  (
    cd "${dir}/work"
    git config user.name 'Eval User'
    git config user.email 'eval@example.com'
    git remote add origin ../origin.git
    printf 'seed\n' > seed.txt
    git add seed.txt
    git commit -qm 'chore: init fixture'
    git push -q -u origin "${branch}"
  )
}

make_repo_no_remote() {
  local dir=$1
  local branch=${2:-main}
  mkdir -p "${dir}"
  git init -q -b "${branch}" "${dir}"
  (
    cd "${dir}"
    git config user.name 'Eval User'
    git config user.email 'eval@example.com'
    printf 'seed\n' > seed.txt
    git add seed.txt
    git commit -qm 'chore: init fixture'
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
      "Trigger quality")
        trigger_quality_pass=$((trigger_quality_pass + 1))
        ;;
      "Script safety")
        script_safety_pass=$((script_safety_pass + 1))
        ;;
      "Push behavior")
        push_behavior_pass=$((push_behavior_pass + 1))
        ;;
      "Skill structure")
        skill_structure_pass=$((skill_structure_pass + 1))
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

# --- Trigger quality evals ---

check "T1" "Trigger quality" \
  "/git-push" \
  "Description clearly states what the skill does (push) and when to use it." \
  file_pairs_have \
  "${core}" 'description:.*[Pp]ush.*commit' \
  "${core}" 'description:.*[Uu]se when'

check "T2" "Trigger quality" \
  "/git-push" \
  "Trigger conditions include positive examples (push, git push) and negative examples (commit, rebase)." \
  file_pairs_have \
  "${core}" '"push".*yes|"git push".*yes' \
  "${core}" 'commit.*no|rebase.*no'

check "T3" "Trigger quality" \
  "/git-push" \
  "Forbidden section explicitly blocks raw --force and history rewrites." \
  file_pairs_have \
  "${core}" '--force.*main|main.*master' \
  "${core}" 'amend.*rebase.*reset|history.*rewrite|History rewrite'

# --- Script safety evals ---

check "S1" "Script safety" \
  "git push --force on main" \
  "Script blocks force push to main." \
  bash -c '
    tmpdir="$(mktemp -d)"
    trap "rm -rf ${tmpdir}" EXIT
    git init -q --bare "${tmpdir}/origin.git"
    mkdir -p "${tmpdir}/work"
    git init -q -b main "${tmpdir}/work"
    cd "${tmpdir}/work"
    git config user.name "T"
    git config user.email "t@t.com"
    git remote add origin ../origin.git
    echo seed > seed.txt
    git add seed.txt
    git commit -qm "init"
    git push -q -u origin main
    echo new > new.txt
    git add new.txt
    git commit -qm "add"
    output="$('"${push_script}"' --force 2>&1)" || true
    echo "${output}" | grep -q "cannot force push to protected branch main"
  '

check "S2" "Script safety" \
  "git push from detached HEAD" \
  "Script skips detached HEAD repos." \
  bash -c '
    tmpdir="$(mktemp -d)"
    trap "rm -rf ${tmpdir}" EXIT
    git init -q --bare "${tmpdir}/origin.git"
    mkdir -p "${tmpdir}/work"
    git init -q -b main "${tmpdir}/work"
    cd "${tmpdir}/work"
    git config user.name "T"
    git config user.email "t@t.com"
    git remote add origin ../origin.git
    echo seed > seed.txt
    git add seed.txt
    git commit -qm "init"
    git push -q -u origin main
    git checkout -q --detach
    output="$('"${push_script}"' 2>&1)" || true
    echo "${output}" | grep -q "detached HEAD"
  '

check "S3" "Script safety" \
  "git push --force on feature branch" \
  "Script uses --force-with-lease (not raw --force) for non-protected branches." \
  file_has "${push_script}" 'force-with-lease'

# --- Push behavior evals ---

check "B1" "Push behavior" \
  "git push when already up to date" \
  "Script reports already up to date and exits 0 when no unpushed commits." \
  bash -c '
    tmpdir="$(mktemp -d)"
    trap "rm -rf ${tmpdir}" EXIT
    git init -q --bare "${tmpdir}/origin.git"
    mkdir -p "${tmpdir}/work"
    git init -q -b main "${tmpdir}/work"
    cd "${tmpdir}/work"
    git config user.name "T"
    git config user.email "t@t.com"
    git remote add origin ../origin.git
    echo seed > seed.txt
    git add seed.txt
    git commit -qm "init"
    git push -q -u origin main
    output="$('"${push_script}"' 2>&1)"
    rc=$?
    [[ ${rc} -eq 0 ]] && echo "${output}" | grep -qi "up to date"
  '

check "B2" "Push behavior" \
  "git push with 1 unpushed commit" \
  "Script successfully pushes when there are commits ahead of upstream." \
  bash -c '
    tmpdir="$(mktemp -d)"
    trap "rm -rf ${tmpdir}" EXIT
    git init -q --bare "${tmpdir}/origin.git"
    mkdir -p "${tmpdir}/work"
    git init -q -b main "${tmpdir}/work"
    cd "${tmpdir}/work"
    git config user.name "T"
    git config user.email "t@t.com"
    git remote add origin ../origin.git
    echo seed > seed.txt
    git add seed.txt
    git commit -qm "init"
    git push -q -u origin main
    echo new > new.txt
    git add new.txt
    git commit -qm "add new"
    output="$('"${push_script}"' 2>&1)"
    rc=$?
    [[ ${rc} -eq 0 ]] && echo "${output}" | grep -q "1 commit"
  '

check "B3" "Push behavior" \
  "git push on branch with no upstream" \
  "Script sets upstream with -u origin when no upstream exists." \
  bash -c '
    tmpdir="$(mktemp -d)"
    trap "rm -rf ${tmpdir}" EXIT
    git init -q --bare "${tmpdir}/origin.git"
    mkdir -p "${tmpdir}/work"
    git init -q -b main "${tmpdir}/work"
    cd "${tmpdir}/work"
    git config user.name "T"
    git config user.email "t@t.com"
    git remote add origin ../origin.git
    echo seed > seed.txt
    git add seed.txt
    git commit -qm "init"
    git push -q -u origin main
    git checkout -q -b feature
    echo feat > feat.txt
    git add feat.txt
    git commit -qm "feat"
    output="$('"${push_script}"' 2>&1)"
    rc=$?
    [[ ${rc} -eq 0 ]] && echo "${output}" | grep -qi "no upstream\|Pushing feature to origin"
  '

check "B4" "Push behavior" \
  "git push with descendant repos" \
  "Script discovers and processes descendant repositories." \
  bash -c '
    tmpdir="$(mktemp -d)"
    trap "rm -rf ${tmpdir}" EXIT
    mkdir -p "${tmpdir}/root"
    for name in repo-a repo-b; do
      git init -q -b main "${tmpdir}/root/${name}"
      cd "${tmpdir}/root/${name}"
      git config user.name "T"
      git config user.email "t@t.com"
      echo seed > seed.txt
      git add seed.txt
      git commit -qm "init"
    done
    cd "${tmpdir}/root"
    output="$('"${push_script}"' 2>&1)" || true
    echo "${output}" | grep -q "repo-a" && echo "${output}" | grep -q "repo-b"
  '

# --- Skill structure evals ---

check "R1" "Skill structure" \
  "/git-push" \
  "SKILL.md is lean (under 200 lines)." \
  bash -c '
    lines="$(wc -l < '"${core}"')"
    [[ ${lines} -lt 200 ]]
  '

check "R2" "Skill structure" \
  "/git-push" \
  "Script file exists and is executable." \
  bash -c '
    [[ -x '"${push_script}"' ]]
  '

# --- Output ---

pass_rate="$(jq -nc --argjson score "${score}" --argjson max_score "${max_score}" '$score * 100 / $max_score')"

jq -nc \
  --arg skill_name "git-push" \
  --arg target_path "skills/git-push" \
  --argjson score "${score}" \
  --argjson max_score "${max_score}" \
  --argjson pass_rate "${pass_rate}" \
  --argjson eval_breakdown "$(printf '%s\n' \
    "$(jq -nc --arg name 'Trigger quality' --argjson pass_count "${trigger_quality_pass}" '{name:$name, pass_count:$pass_count, total:3}')" \
    "$(jq -nc --arg name 'Script safety' --argjson pass_count "${script_safety_pass}" '{name:$name, pass_count:$pass_count, total:3}')" \
    "$(jq -nc --arg name 'Push behavior' --argjson pass_count "${push_behavior_pass}" '{name:$name, pass_count:$pass_count, total:4}')" \
    "$(jq -nc --arg name 'Skill structure' --argjson pass_count "${skill_structure_pass}" '{name:$name, pass_count:$pass_count, total:2}')" \
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
