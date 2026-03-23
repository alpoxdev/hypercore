#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "${script_dir}/.." && pwd)"

core_en="${skill_dir}/SKILL.md"
core_ko="${skill_dir}/SKILL.ko.md"
routing_en="${skill_dir}/rules/routing.md"
routing_ko="${skill_dir}/rules/routing.ko.md"
recipes_en="${skill_dir}/references/recipes.md"
recipes_ko="${skill_dir}/references/recipes.ko.md"

score=0
max_score=25

applicability_pass=0
execution_readiness_pass=0
command_fidelity_pass=0
safety_discipline_pass=0
completion_handoff_pass=0

declare -a check_rows=()

file_has() {
  local file=$1
  local pattern=$2
  [[ -f "${file}" ]] && grep -Eq -- "${pattern}" "${file}"
}

file_has_all() {
  local file=$1
  shift
  local pattern
  for pattern in "$@"; do
    if ! file_has "${file}" "${pattern}"; then
      return 1
    fi
  done
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
      "Applicability")
        applicability_pass=$((applicability_pass + 1))
        ;;
      "Execution readiness")
        execution_readiness_pass=$((execution_readiness_pass + 1))
        ;;
      "Command fidelity")
        command_fidelity_pass=$((command_fidelity_pass + 1))
        ;;
      "Safety discipline")
        safety_discipline_pass=$((safety_discipline_pass + 1))
        ;;
      "Completion handoff")
        completion_handoff_pass=$((completion_handoff_pass + 1))
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

check "P1E1" "Applicability" \
  "Use Codex CLI to review the latest diff in this repo." \
  "The core clearly states that Codex CLI requests for code analysis/review are in scope." \
  all_files_have "run Codex CLI|Codex CLI|code analysis|review|refactoring|automated editing|코드 분석|검토|리팩토링|자동 편집" "${core_en}" "${core_ko}"

check "P1E2" "Execution readiness" \
  "Use Codex CLI to review the latest diff in this repo." \
  "The skill defaults review-style work to read-only sandboxing." \
  all_files_have 'read-only' "${core_en}" "${core_ko}"

check "P1E3" "Command fidelity" \
  "Use Codex CLI to review the latest diff in this repo." \
  "The read-only recipe includes skip-git-repo-check, model, reasoning effort, and read-only sandbox flags." \
  file_has_all "${core_en}" 'codex exec --skip-git-repo-check' '-m gpt-5\.3-codex' '--config model_reasoning_effort="high"' '--sandbox read-only'

check "P1E4" "Safety discipline" \
  "Use Codex CLI to review the latest diff in this repo." \
  "The skill suppresses thinking tokens by default for normal runs." \
  all_files_have '2>/dev/null' "${core_en}" "${core_ko}"

check "P1E5" "Completion handoff" \
  "Use Codex CLI to review the latest diff in this repo." \
  "The skill tells the user how to resume and prompts for next steps after completion." \
  file_pairs_have "${core_en}" "You can resume this Codex session by saying 'codex resume'\\." "${core_en}" 'AskUserQuestion|ask how to adjust|ask how to proceed' "${core_ko}" 'codex resume'

check "P2E1" "Applicability" \
  "Use Codex to edit src/app.ts and fix the failing build." \
  "The core makes local file-edit requests an in-scope Codex use case." \
  all_files_have 'file edits|파일 편집' "${core_en}" "${core_ko}"

check "P2E2" "Execution readiness" \
  "Use Codex to edit src/app.ts and fix the failing build." \
  "The skill maps file edits to workspace-write." \
  all_files_have 'workspace-write' "${core_en}" "${core_ko}"

check "P2E3" "Command fidelity" \
  "Use Codex to edit src/app.ts and fix the failing build." \
  "A concrete workspace-write command recipe exists in the linked recipes." \
  file_pairs_have "${recipes_en}" '--sandbox workspace-write' "${recipes_ko}" '--sandbox workspace-write'

check "P2E4" "Safety discipline" \
  "Use Codex to edit src/app.ts and fix the failing build." \
  "The skill requires confirmation before full-auto edits unless already approved." \
  file_pairs_have "${core_en}" '--full-auto' "${core_en}" 'Confirm with user before using `--full-auto`|ask before using `--full-auto`|confirm before using `--full-auto`' "${core_ko}" '--full-auto'

check "P2E5" "Completion handoff" \
  "Use Codex to edit src/app.ts and fix the failing build." \
  "The skill says to summarize warnings or partial results and ask how to adjust." \
  all_files_have 'warnings or partial results|경고나 부분 결과|부분 결과' "${core_en}" "${core_ko}"

check "P3E1" "Applicability" \
  "Use Codex to check the latest Next.js docs online and patch the code if needed." \
  "The skill makes network-backed Codex work an explicit danger-full-access case." \
  all_files_have 'danger-full-access' "${core_en}" "${core_ko}"

check "P3E2" "Execution readiness" \
  "Use Codex to check the latest Next.js docs online and patch the code if needed." \
  "A concrete danger-full-access recipe exists in the linked recipes." \
  file_pairs_have "${recipes_en}" '--sandbox danger-full-access' "${recipes_ko}" '--sandbox danger-full-access'

check "P3E3" "Command fidelity" \
  "Use Codex to check the latest Next.js docs online and patch the code if needed." \
  "The skill preserves skip-git-repo-check and stderr suppression for network recipes too." \
  file_pairs_have "${recipes_en}" '--skip-git-repo-check' "${recipes_en}" '2>/dev/null' "${recipes_ko}" '--skip-git-repo-check' "${recipes_ko}" '2>/dev/null'

check "P3E4" "Safety discipline" \
  "Use Codex to check the latest Next.js docs online and patch the code if needed." \
  "The skill requires confirmation before danger-full-access and full-auto runs." \
  file_pairs_have "${core_en}" 'Confirm with user before using `--full-auto` or `--sandbox danger-full-access`' "${core_ko}" '고영향 플래그'

check "P3E5" "Completion handoff" \
  "Use Codex to check the latest Next.js docs online and patch the code if needed." \
  "The skill tells the agent to cross-check Codex against docs or web evidence when it may be wrong." \
  all_files_have 'WebSearch|docs|Research disagreements|web search|웹 검색|문서' "${core_en}" "${core_ko}"

check "P4E1" "Applicability" \
  "Resume the last Codex session and tell it to continue with the previous task." \
  "The skill treats resume as a first-class path." \
  all_files_have 'resume' "${core_en}" "${core_ko}"

check "P4E2" "Execution readiness" \
  "Resume the last Codex session and tell it to continue with the previous task." \
  "The skill includes the stdin-based resume command pattern." \
  file_pairs_have "${core_en}" 'echo "your prompt here" \| codex exec --skip-git-repo-check resume --last 2>/dev/null' "${core_ko}" 'echo "프롬프트" \| codex exec --skip-git-repo-check resume --last 2>/dev/null'

check "P4E3" "Command fidelity" \
  "Resume the last Codex session and tell it to continue with the previous task." \
  "The skill states that flags go between exec and resume and config flags are omitted unless requested." \
  all_files_have 'between `exec` and `resume`|`exec`와 `resume` 사이' "${core_en}" "${core_ko}"

check "P4E4" "Safety discipline" \
  "Resume the last Codex session and tell it to continue with the previous task." \
  "The skill warns that resume inherits the original model/reasoning/sandbox unless changed deliberately." \
  file_pairs_have "${core_en}" 'inherits the original|same model|same sandbox|same reasoning' "${core_ko}" '동일한 모델|동일한 .*샌드박스|자동으로 사용'

check "P4E5" "Completion handoff" \
  "Resume the last Codex session and tell it to continue with the previous task." \
  "The skill reminds the agent to tell the user that resume remains available after the run." \
  file_pairs_have "${core_en}" "You can resume this Codex session by saying 'codex resume'\\." "${core_ko}" '재개할 수 있습니다'

check "P5E1" "Applicability" \
  "Create a new reusable browser-QA skill." \
  "The skill explicitly routes new-skill creation requests away from Codex CLI usage." \
  file_pairs_have "${routing_en}" 'Create or refactor a skill|route away|skill-maker|direct editing' "${routing_ko}" '스킬 생성|스킬 메이커|직접 편집'

check "P5E2" "Execution readiness" \
  "Create a new reusable browser-QA skill." \
  "The routing guide makes the alternative next step obvious for out-of-scope work." \
  file_pairs_have "${routing_en}" 'Use another skill or direct editing when the request does not actually need Codex CLI' "${routing_ko}" 'Codex CLI 자체가 필요하지 않으면 다른 스킬이나 직접 편집'

check "P5E3" "Command fidelity" \
  "Create a new reusable browser-QA skill." \
  "The skill avoids prescribing a Codex command for generic skill-authoring tasks." \
  file_pairs_have "${routing_en}" 'Do not build a Codex CLI command for generic writing, runbook rewrites, or skill creation' "${routing_ko}" '일반 문서 작성|런북|스킬 생성'

check "P5E4" "Safety discipline" \
  "Create a new reusable browser-QA skill." \
  "The boundary guidance tells the agent not to escalate sandboxing when Codex is the wrong tool." \
  file_pairs_have "${routing_en}" 'Do not escalate sandbox scope just to force Codex into a task it does not own' "${routing_ko}" '샌드박스를 올려서까지'

check "P5E5" "Completion handoff" \
  "Create a new reusable browser-QA skill." \
  "The route-away guidance says to hand off cleanly instead of running Codex anyway." \
  file_pairs_have "${routing_en}" 'route away cleanly' "${routing_ko}" '깔끔하게 넘긴다|깔끔하게 전환'

pass_rate="$(jq -nc --argjson score "${score}" --argjson max_score "${max_score}" '$score * 100 / $max_score')"

jq -nc \
  --arg skill_name "codex" \
  --argjson score "${score}" \
  --argjson max_score "${max_score}" \
  --argjson pass_rate "${pass_rate}" \
  --argjson eval_breakdown "$(printf '%s\n' \
    "$(jq -nc --arg name 'Applicability' --argjson pass_count "${applicability_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    "$(jq -nc --arg name 'Execution readiness' --argjson pass_count "${execution_readiness_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    "$(jq -nc --arg name 'Command fidelity' --argjson pass_count "${command_fidelity_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    "$(jq -nc --arg name 'Safety discipline' --argjson pass_count "${safety_discipline_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    "$(jq -nc --arg name 'Completion handoff' --argjson pass_count "${completion_handoff_pass}" '{name:$name, pass_count:$pass_count, total:5}')" \
    | jq -sc '.')" \
  --argjson checks "$(printf '%s\n' "${check_rows[@]}" | jq -sc '.')" \
  '
  {
    skill_name: $skill_name,
    score: $score,
    max_score: $max_score,
    pass_rate: $pass_rate,
    eval_breakdown: $eval_breakdown,
    checks: $checks
  }'
