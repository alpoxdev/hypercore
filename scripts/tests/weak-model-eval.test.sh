#!/usr/bin/env bash
# Behavior-anchored tests for scripts/weak-model-eval.sh: a scored run reports
# exactly the workflow devices the agent left out.
set -uo pipefail

# shellcheck source=/dev/null
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
EVAL="$ROOT/scripts/weak-model-eval.sh"
STATE="$ROOT/skills/hyper/scripts/hyper-workflow-state.sh"
SCENARIO=paginate-off-by-one

# A run that follows every device: state through the helper, all banners, the
# journal terminal, the closing checklist, and a real fix. $2 is the checklist line.
compliant_run() { # <workdir> <checklist-line>
  local work=$1 t=$1/.eval/transcript.txt s
  {
    bash "$STATE" init --root "$work" --slug page-fix --job build --delivery local \
      --request "paginate 고쳐줘" --stages hyper-debug --reasons "테스트 실패"
    bash "$STATE" enter --root "$work" --slug page-fix --stage hyper-debug
    for s in 1 2 3 4 5 6 7 8 9; do printf '[현재 단계: %s/9 진행]\n' "$s"; done
  } >"$t" 2>&1
  sed 's/start + size - 1/start + size/' "$work/src/paginate.js" >"$work/src/paginate.tmp" &&
    mv "$work/src/paginate.tmp" "$work/src/paginate.js"
  mkdir -p "$work/.hyper/debug"
  printf '# paginate\n\nResult: fixed\n' >"$work/.hyper/debug/page-fix.md"
  bash "$STATE" complete --root "$work" --slug page-fix --stage hyper-debug \
    --artifact .hyper/debug/page-fix.md >>"$t" 2>&1
  printf '%s\n' "$2" >>"$t"
}

case_compliant_run_scores_zero_omissions() {
  require_cmd node || return 0
  local work out
  work=$(new_workdir)/run
  bash "$EVAL" prepare --scenario "$SCENARIO" --out "$work" >/dev/null
  compliant_run "$work" '[체크리스트: 1=예 2=예 3=예 4=예 5=예 6=예]'
  out=$work/.eval/score.json
  bash "$EVAL" score --scenario "$SCENARIO" --workdir "$work" --transcript "$work/.eval/transcript.txt" >"$out"
  assert_json_eq "$out" '.omissions.total' '0' "no omission in a compliant run"
  assert_json_eq "$out" '.outcome.tests_pass' 'true' "the fix makes the scenario tests pass"
  assert_json_eq "$out" '.outcome.out_of_scope | length' '0' "only allowed paths changed"
}

case_chat_only_run_counts_every_missing_device() {
  require_cmd node || return 0
  local work out
  work=$(new_workdir)/run
  bash "$EVAL" prepare --scenario "$SCENARIO" --out "$work" >/dev/null
  printf '[라우팅: hyper-debug]\n원인을 찾았고 고쳤습니다.\n' >"$work/.eval/transcript.txt"
  out=$work/.eval/score.json
  bash "$EVAL" score --scenario "$SCENARIO" --workdir "$work" --transcript "$work/.eval/transcript.txt" >"$out"
  assert_json_eq "$out" '.omissions.steps' '11' "two stage banners and nine debug banners missing"
  assert_json_eq "$out" '.omissions.state' '4' "state file, verify, journal, and terminal missing"
  assert_json_eq "$out" '.omissions.checklist' '6' "all six checklist answers missing"
  assert_json_eq "$out" '.outcome.tests_pass' 'false' "an unfixed bug keeps the tests failing"
}

case_no_answers_and_stray_edits_are_reported_apart() {
  require_cmd node || return 0
  local work out
  work=$(new_workdir)/run
  bash "$EVAL" prepare --scenario "$SCENARIO" --out "$work" >/dev/null
  compliant_run "$work" '[체크리스트: 1=예 2=예 3=아니오 4=예 5=예 6=예]'
  printf '{}\n' >"$work/package.json"
  out=$work/.eval/score.json
  bash "$EVAL" score --scenario "$SCENARIO" --workdir "$work" --transcript "$work/.eval/transcript.txt" >"$out"
  assert_json_eq "$out" '.omissions.checklist' '0' "an honest no is not an omission"
  assert_json_eq "$out" '.checklist.answered_no | join(",")' '3' "the no answer is listed"
  assert_json_eq "$out" '.outcome.out_of_scope | join(",")' 'package.json' "edit outside allowed paths flagged"
}

# In an omp event log, a checklist template echoed by a file read is not an
# answer; the same line in the agent's own reply is.
case_event_log_counts_only_agent_output() {
  require_cmd node || return 0
  local work out line='[체크리스트: 1=예 2=예 3=예 4=예 5=예 6=예]'
  work=$(new_workdir)/run
  bash "$EVAL" prepare --scenario "$SCENARIO" --out "$work" >/dev/null
  jq -cn --arg t "$line" '{type: "message_end", message: {role: "toolResult", toolName: "read", content: [{type: "text", text: $t}]}}' \
    >"$work/.eval/read-only.jsonl"
  out=$work/.eval/read-only.json
  bash "$EVAL" score --scenario "$SCENARIO" --workdir "$work" --transcript "$work/.eval/read-only.jsonl" >"$out"
  assert_json_eq "$out" '.omissions.checklist' '6' "a template seen in a file read is not an answer"
  {
    cat "$work/.eval/read-only.jsonl"
    jq -cn --arg t "$line" '{type: "message_end", message: {role: "assistant", content: [{type: "text", text: $t}]}}'
  } >"$work/.eval/replied.jsonl"
  out=$work/.eval/replied.json
  bash "$EVAL" score --scenario "$SCENARIO" --workdir "$work" --transcript "$work/.eval/replied.jsonl" >"$out"
  assert_json_eq "$out" '.omissions.checklist' '0' "the agent's own checklist line counts"
}

run_case "a compliant run scores zero omissions" case_compliant_run_scores_zero_omissions
run_case "a chat-only run counts every missing device" case_chat_only_run_counts_every_missing_device
run_case "no answers and stray edits are reported apart from omissions" case_no_answers_and_stray_edits_are_reported_apart
run_case "an event log counts only the agent's own output" case_event_log_counts_only_agent_output
test_summary
