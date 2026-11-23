#!/usr/bin/env bash
# Behavior-anchored tests for skills/hyper/scripts/hyper-workflow-state.sh.
set -uo pipefail

# shellcheck source=/dev/null
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
SCRIPT="$ROOT/skills/hyper/scripts/hyper-workflow-state.sh"

case_happy_lifecycle_and_verify() {
  local work out rc
  work=$(new_workdir)
  out=$(bash "$SCRIPT" init --root "$work" --slug "auth-fix" --job build --delivery local \
    --request "로그인 오류 고쳐줘" --stages "hyper-debug,hyper-git" --reasons "실행 실패|커밋 요청" 2>&1) || rc=$?
  assert_eq 0 "${rc:-0}" "init succeeds"
  assert_contains "$out" "[라우팅: hyper-debug -> hyper-git" "routing banner printed"
  assert_file "$work/.hyper/workflows/auth-fix/state.json" "state.json written"
  assert_file "$work/.hyper/workflows/auth-fix.md" "workflow markdown written"

  out=$(bash "$SCRIPT" enter --root "$work" --slug "auth-fix" --stage "hyper-debug" 2>&1)
  assert_contains "$out" "[현재 단계: 1/2 hyper-debug — 진행 중]" "enter banner printed"

  mkdir -p "$work/.hyper/debug"
  printf 'Result: fixed\n' >"$work/.hyper/debug/auth-fix.md"
  out=$(bash "$SCRIPT" complete --root "$work" --slug "auth-fix" --stage "hyper-debug" \
    --artifact ".hyper/debug/auth-fix.md" 2>&1)
  assert_contains "$out" "[현재 단계: 1/2 hyper-debug — 완료 | 산출물: .hyper/debug/auth-fix.md | 다음: hyper-git]" "complete banner names next stage"

  bash "$SCRIPT" enter --root "$work" --slug "auth-fix" --stage "hyper-git" >/dev/null
  out=$(bash "$SCRIPT" complete --root "$work" --slug "auth-fix" --stage "hyper-git" \
    --artifact "stage-note" --note "pushed abc1234 to origin/dev" 2>&1)
  assert_contains "$out" "다음: 없음]" "final stage marks no remaining stage"

  rc=0
  out=$(bash "$SCRIPT" verify --root "$work" --slug "auth-fix" 2>&1) || rc=$?
  assert_eq 0 "$rc" "verify passes when all stages done and artifacts exist"
  assert_contains "$out" "2 stage(s) complete" "verify summary"
}

case_complete_rejects_missing_or_empty_artifact() {
  local work out rc
  work=$(new_workdir)
  bash "$SCRIPT" init --root "$work" --slug "missing-art" --job build --delivery local \
    --request "점검해줘" --stages "hyper-review" >/dev/null
  bash "$SCRIPT" enter --root "$work" --slug "missing-art" --stage "hyper-review" >/dev/null

  rc=0
  out=$(bash "$SCRIPT" complete --root "$work" --slug "missing-art" --stage "hyper-review" \
    --artifact ".hyper/review/missing-art.md" 2>&1) || rc=$?
  assert_eq 1 "$rc" "missing artifact fails closed"
  assert_contains "$out" "missing on disk" "names missing artifact"

  mkdir -p "$work/.hyper/review"
  : >"$work/.hyper/review/missing-art.md"
  rc=0
  out=$(bash "$SCRIPT" complete --root "$work" --slug "missing-art" --stage "hyper-review" \
    --artifact ".hyper/review/missing-art.md" 2>&1) || rc=$?
  assert_eq 1 "$rc" "empty artifact fails closed"
  assert_contains "$out" "empty on disk" "names empty artifact"
  assert_eq "running" "$(jq -r '.stages[0].status' "$work/.hyper/workflows/missing-art/state.json")" "stage stays running"
}

case_enter_enforces_stage_order() {
  local work out rc=0
  work=$(new_workdir)
  bash "$SCRIPT" init --root "$work" --slug "order-check" --job build --delivery local \
    --request "리팩토링해줘" --stages "hyper-architecture,hyper-plan,hyper-execute" >/dev/null

  out=$(bash "$SCRIPT" enter --root "$work" --slug "order-check" --stage "hyper-plan" 2>&1) || rc=$?
  assert_eq 1 "$rc" "cannot skip pending upstream stage"
  assert_contains "$out" "hyper-architecture" "names unfinished upstream stage"
}

case_chain_invariants_enforced() {
  local work out rc=0
  work=$(new_workdir)
  out=$(bash "$SCRIPT" init --root "$work" --slug "bad-debate" --job build --delivery local \
    --request "계획" --stages "hyper-plan,hyper-debate" 2>&1) || rc=$?
  assert_eq 1 "$rc" "rejects plan + debate in same chain"
  assert_contains "$out" "cannot chain hyper-plan and hyper-debate" "explains mutual exclusion"

  rc=0
  out=$(bash "$SCRIPT" init --root "$work" --slug "too-many" --job build --delivery local \
    --request "전부" --stages "hyper-research,hyper-architecture,hyper-plan,hyper-execute,hyper-deploy" 2>&1) || rc=$?
  assert_eq 1 "$rc" "rejects >4 counted core stages"
  assert_contains "$out" "exceeds maximum of 4 counted core stages" "explains stage cap"

  rc=0
  bash "$SCRIPT" init --root "$work" --slug "uncounted-git" --job build --delivery local \
    --request "리서치와 스킬 제작 후 푸시" --stages "hyper-research,hyper-architecture,hyper-database,hyper-git,hyper-deploy" >/dev/null 2>&1 || rc=$?
  assert_eq 0 "$rc" "hyper-git is uncounted so 4 core + hyper-git passes"
}

case_resume_and_artifact_drift_detection() {
  local work out rc=0
  work=$(new_workdir)
  bash "$SCRIPT" init --root "$work" --slug "compacted-run" --job build --delivery local \
    --request "조사 후 계획" --stages "hyper-research,hyper-plan" >/dev/null
  mkdir -p "$work/.hyper/research"
  printf '# Research\n' >"$work/.hyper/research/01.topic.md"
  bash "$SCRIPT" enter --root "$work" --slug "compacted-run" --stage "hyper-research" >/dev/null
  bash "$SCRIPT" complete --root "$work" --slug "compacted-run" --stage "hyper-research" \
    --artifact ".hyper/research/01.topic.md" >/dev/null

  out=$(bash "$SCRIPT" resume --root "$work" 2>&1) || rc=$?
  assert_eq 0 "$rc" "resume finds open workflow"
  assert_contains "$out" "[현재 단계: 2/2 hyper-plan — 재개 대상" "resume identifies next unfinished stage"

  rm -f "$work/.hyper/research/01.topic.md"
  rc=0
  out=$(bash "$SCRIPT" resume --root "$work" --slug "compacted-run" 2>&1) || rc=$?
  assert_eq 1 "$rc" "resume fails closed when prior stage artifact vanished"
  assert_contains "$out" "artifact drift detected" "reports artifact drift"
}

case_append_stage_handoff_drops_pending_git() {
  local work
  work=$(new_workdir)
  bash "$SCRIPT" init --root "$work" --slug "dbg-handoff" --job build --delivery "git:commit dev" \
    --request "원인 찾아 고치고 dev 푸시" --stages "hyper-debug,hyper-git" >/dev/null
  mkdir -p "$work/.hyper/debug"
  printf 'Result: handoff\n' >"$work/.hyper/debug/dbg-handoff.md"
  bash "$SCRIPT" complete --root "$work" --slug "dbg-handoff" --stage "hyper-debug" \
    --artifact ".hyper/debug/dbg-handoff.md" >/dev/null

  bash "$SCRIPT" append-stage --root "$work" --slug "dbg-handoff" --stage "hyper-plan" \
    --reason "debug ended in multi-file handoff" >/dev/null
  assert_eq "hyper-debug,hyper-plan" \
    "$(jq -r '.stages | map(.name) | join(",")' "$work/.hyper/workflows/dbg-handoff/state.json")" \
    "pending hyper-git removed when hyper-plan takes over delivery"
}

run_case "init, enter, complete, and verify drive a workflow to verified completion" case_happy_lifecycle_and_verify
run_case "complete rejects missing or empty disk artifacts without advancing state" case_complete_rejects_missing_or_empty_artifact
run_case "enter rejects out-of-order execution when upstream stages are unfinished" case_enter_enforces_stage_order
run_case "init enforces plan/debate exclusion and the four-stage core cap" case_chain_invariants_enforced
run_case "resume locates the next unfinished stage and detects vanished prior artifacts" case_resume_and_artifact_drift_detection
run_case "append-stage adds hyper-plan on handoff and drops redundant pending hyper-git" case_append_stage_handoff_drops_pending_git
test_summary
