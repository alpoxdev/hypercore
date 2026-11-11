#!/usr/bin/env bash
# Exercises scripts/check-hyper-stage-parity.sh.
#
# The checker is the only thing that makes the `hyper` orchestrator's three
# stage tables, its stage skills on disk, and its eval fixtures agree. Every
# case here builds a small fixture package that passes, breaks exactly one
# property, and asserts the checker reports that code and no other. A checker
# that quietly passes a broken tree is worse than none, so each check gets both
# a positive and a negative case.
# Requires bash 3.2+, POSIX tools.
set -uo pipefail

# literal backticks in the fixture Markdown and sed patterns are code spans, not
# command substitution
# shellcheck disable=SC2016
# shellcheck source=/dev/null
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
CHECKER=$ROOT/scripts/check-hyper-stage-parity.sh
SHIPPED=$ROOT/skills

WORK=
RC=0

# write_stage_tables <skills-root> — a fixture package with four stages whose
# six tables, eval fixture, and skill folders all agree.
write_stage_tables() {
  local root=$1 pkg=$1/hyper id
  mkdir -p "$pkg/rules" "$pkg/assets/evals"
  for id in hyper-plan hyper-debate hyper-execute hyper-review; do
    mkdir -p "$root/$id"
    printf '# %s\n' "$id" >"$root/$id/SKILL.md"
    printf '# %s\n' "$id" >"$root/$id/SKILL.ko.md"
  done

  cat >"$pkg/SKILL.md" <<'EOF'
# Hyper

| Stage skill | What the stage produces |
|---|---|
| `hyper-plan` | A plan |
| `hyper-debate` | An adversarial plan |
| `hyper-execute` | A run |
| `hyper-review` | A verdict |

`hyper-debate` replaces `hyper-plan` for a request that asks for the debate, and never runs alongside it.
EOF
  cat >"$pkg/SKILL.ko.md" <<'EOF'
# Hyper

| Stage skill | What the stage produces |
|---|---|
| `hyper-plan` | 계획 |
| `hyper-debate` | 대립형 계획 |
| `hyper-execute` | 실행 |
| `hyper-review` | 판정 |

`hyper-debate`는 `hyper-plan`을 대신하고 둘을 한 체인에 넣지 않습니다.
EOF
  cat >"$pkg/rules/workflow-routing.md" <<'EOF'
# Routing

## 2. Stage Signals

| Stage | Add it when | Evidence to quote |
|---|---|---|
| `hyper-plan` | The work needs a plan | The request |
| `hyper-debate` | The user opted in | The opt-in words |
| `hyper-execute` | A plan exists | The plan path |
| `hyper-review` | A diff exists | The diff |

- At most four distinct core stages run, counted this way.

`hyper-debate` replaces `hyper-plan`; never chain both.
EOF
  cat >"$pkg/rules/workflow-routing.ko.md" <<'EOF'
# 라우팅

## 2. 단계 신호

| Stage | Add it when | Evidence to quote |
|---|---|---|
| `hyper-plan` | 계획이 필요함 | 요청 |
| `hyper-debate` | 사용자가 선택함 | 선택 표현 |
| `hyper-execute` | 계획이 있음 | 계획 경로 |
| `hyper-review` | diff가 있음 | diff |

- 서로 다른 핵심 단계를 최대 네 개까지 실행하며 다음처럼 셉니다.

`hyper-debate`는 `hyper-plan`을 대신합니다. 둘을 한 체인에 넣지 않습니다.
EOF
  cat >"$pkg/rules/stage-handoff.md" <<'EOF'
# Stage Handoff

## 1. Stage Contracts

| Stage | Request passed to the stage | Artifact that must exist before the next stage | Passed forward |
|---|---|---|---|
| `hyper-plan` | The request | `.hyper/plans/<slug>.md` | The plan path |
| `hyper-debate` | The opt-in words | `.hyper/debate/<slug>/` | The plan path |
| `hyper-execute` | The plan slug | `.hyper/execute/<slug>/state.json` | The completion block |
| `hyper-review` | The diff | `.hyper/review/<slug>.md` | The `Result:` line |
EOF
  cat >"$pkg/rules/stage-handoff.ko.md" <<'EOF'
# 단계 인계

## 1. 단계 계약

| Stage | Request passed to the stage | Artifact that must exist before the next stage | Passed forward |
|---|---|---|---|
| `hyper-plan` | 요청 | `.hyper/plans/<slug>.md` | 계획 경로 |
| `hyper-debate` | 선택 표현 | `.hyper/debate/<slug>/` | 계획 경로 |
| `hyper-execute` | 계획 슬러그 | `.hyper/execute/<slug>/state.json` | 완료 블록 |
| `hyper-review` | diff | `.hyper/review/<slug>.md` | `Result:` 줄 |
EOF
  cat >"$pkg/assets/evals/hyper-cases.jsonl" <<'EOF'
{"id":"plan-en","expect":"trigger","expected_route":"hyper-plan -> hyper-execute"}
{"id":"debate-ko","expect":"trigger","expected_route":"hyper-debate -> hyper-execute"}
{"id":"browsing-en","expect":"trigger","expected_route":"hyper-review(+hyper-browsing)"}
{"id":"negative-ko","expect":"no_trigger","expected_route":null}
EOF
}

# make_fixture — a fresh passing fixture; sets WORK and PKG.
make_fixture() {
  WORK=$(new_workdir)
  write_stage_tables "$WORK/skills"
  PKG=$WORK/skills/hyper
}

# run_check — run the checker against the fixture, print its exit code.
run_check() {
  local out=$WORK/out.txt rc=0
  bash "$CHECKER" --skills "$WORK/skills" --json >"$out" 2>&1 || rc=$?
  printf '%s\n' "$rc"
}

# expect_codes <code[,code...]> — the report's distinct codes, as one string.
# A single defect may produce several findings (one per file or row), but a
# checker that also reports unrelated codes is guessing, so each case pins the
# whole distinct code set.
expect_codes() {
  local code=$1 out=$WORK/out.txt
  assert_json_eq "$out" '.ok' "false" "ok"
  assert_json_eq "$out" '.problems | map(.code) | unique | join(",")' "$code" "codes"
}

case_shipped_package_passes() {
  local rc
  rc=$(run_shipped)
  assert_eq "0" "$rc" "checker exit on the shipped package"
}

run_shipped() {
  WORK=$(new_workdir)
  local out=$WORK/shipped.json rc=0
  bash "$CHECKER" --skills "$SHIPPED" --json >"$out" 2>&1 || rc=$?
  if [ -s "$out" ]; then
    assert_json_eq "$out" '.ok' "true" "shipped ok"
    assert_json_eq "$out" '.findings' "0" "shipped findings"
  fi
  printf '%s\n' "$rc"
}

case_fixture_passes() {
  make_fixture
  RC=$(run_check)
  assert_eq "0" "$RC" "fixture exit"
  assert_json_eq "$WORK/out.txt" '.ok' "true" "ok"
  assert_json_eq "$WORK/out.txt" '.findings' "0" "findings"
}

case_stage_missing_from_one_table() {
  make_fixture
  # shellcheck disable=SC2016  # literal backticks: fixture Markdown
  sed -i.bak '/`hyper-review`/d' "$PKG/rules/stage-handoff.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "STAGE_SET_MISMATCH"
}

case_stage_extra_in_map() {
  local extra
  make_fixture
  extra=$WORK/skills/hyper-extra
  mkdir -p "$extra"
  printf '# hyper-extra\n' >"$extra/SKILL.md"
  printf '# hyper-extra\n' >"$extra/SKILL.ko.md"
  # shellcheck disable=SC2016  # literal backticks: fixture Markdown
  sed -i.bak 's/^| `hyper-execute` | A run |$/| `hyper-execute` | A run |\n| `hyper-extra` | Nothing |/' "$PKG/SKILL.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "STAGE_SET_MISMATCH"
}

case_korean_mirror_drops_a_stage() {
  make_fixture
  # shellcheck disable=SC2016  # literal backticks: fixture Markdown
  sed -i.bak '/`hyper-execute`/d' "$PKG/rules/stage-handoff.ko.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "STAGE_SET_MISMATCH"
}

case_stage_skill_folder_absent() {
  make_fixture
  rm -rf "$WORK/skills/hyper-review"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "STAGE_SKILL_MISSING"
}

case_handoff_row_has_three_cells() {
  make_fixture
  # shellcheck disable=SC2016  # literal backticks: fixture Markdown
  printf '| `hyper-review` | The diff | `.hyper/review/<slug>.md` |\n' >"$WORK/row"
  # shellcheck disable=SC2016  # literal backticks: fixture Markdown
  sed -i.bak '/`hyper-review`/d' "$PKG/rules/stage-handoff.md"
  cat "$WORK/row" >>"$PKG/rules/stage-handoff.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "ROW_CELLS"
}

case_handoff_row_has_an_empty_cell() {
  make_fixture
  # shellcheck disable=SC2016  # literal backticks: fixture Markdown
  printf '| `hyper-review` | The diff | `.hyper/review/<slug>.md` |  |\n' >"$WORK/row"
  # shellcheck disable=SC2016  # literal backticks: fixture Markdown
  sed -i.bak '/`hyper-review`/d' "$PKG/rules/stage-handoff.md"
  cat "$WORK/row" >>"$PKG/rules/stage-handoff.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "ROW_EMPTY_CELL"
}

case_table_header_absent() {
  make_fixture
  sed -i.bak 's/^| Stage skill | What the stage produces |$/| Skill | Output |/' "$PKG/SKILL.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  assert_json_eq "$WORK/out.txt" '.ok' "false" "ok"
  assert_contains "$(cat "$WORK/out.txt")" "TABLE_MISSING" "missing header code"
}

case_eval_names_an_unknown_stage() {
  make_fixture
  printf '{"id":"bogus-en","expect":"trigger","expected_route":"hyper-nope -> hyper-execute"}\n' >>"$PKG/assets/evals/hyper-cases.jsonl"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "EVAL_UNKNOWN_STAGE"
}

case_eval_null_route_on_a_trigger() {
  make_fixture
  printf '{"id":"null-en","expect":"trigger","expected_route":null}\n' >>"$PKG/assets/evals/hyper-cases.jsonl"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "EVAL_NULL_ROUTE"
}

case_eval_route_on_a_no_trigger() {
  make_fixture
  printf '{"id":"routes-anyway-ko","expect":"no_trigger","expected_route":"hyper-plan"}\n' >>"$PKG/assets/evals/hyper-cases.jsonl"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "EVAL_ROUTE_ON_NO_TRIGGER"
}

case_eval_empty_route_on_a_trigger() {
  make_fixture
  printf '{"id":"empty-en","expect":"trigger","expected_route":""}\n' >>"$PKG/assets/evals/hyper-cases.jsonl"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "EVAL_EMPTY_ROUTE"
}

case_eval_chains_plan_and_debate() {
  make_fixture
  printf '{"id":"both-en","expect":"trigger","expected_route":"hyper-plan -> hyper-debate -> hyper-execute"}\n' >>"$PKG/assets/evals/hyper-cases.jsonl"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "EVAL_PLAN_DEBATE_BOTH"
}

case_eval_missing_route_field() {
  make_fixture
  printf '{"id":"absent-ko","expect":"trigger"}\n' >>"$PKG/assets/evals/hyper-cases.jsonl"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "EVAL_ROUTE_MISSING"
}

case_stage_count_rule_absent() {
  make_fixture
  sed -i.bak '/At most four distinct core stages run/d' "$PKG/rules/workflow-routing.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "STAGE_COUNT_RULE"
}

case_plan_debate_rule_absent() {
  make_fixture
  sed -i.bak '/never runs alongside it/d' "$PKG/SKILL.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "PLAN_DEBATE_RULE"
}

case_hardcoded_stage_total() {
  make_fixture
  printf -- '- it names its twenty-seven stage skills here\n' >>"$PKG/SKILL.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  expect_codes "HARDCODED_STAGE_COUNT"
}

case_missing_package_file() {
  make_fixture
  rm -f "$PKG/rules/workflow-routing.ko.md"
  RC=$(run_check)
  assert_eq "1" "$RC" "exit"
  assert_contains "$(cat "$WORK/out.txt")" "MISSING_FILE" "missing file"
}

case_list_prints_checked_paths() {
  make_fixture
  local out=$WORK/list.txt count
  bash "$CHECKER" --skills "$WORK/skills" --list >"$out" 2>&1 ||
    fail "list exit"
  count=$(wc -l <"$out" | tr -d ' ')
  assert_eq "7" "$count" "listed paths"
  assert_file_contains "$out" "$PKG/rules/stage-handoff.ko.md" "ko handoff path"
  assert_file_contains "$out" "$PKG/assets/evals/hyper-cases.jsonl" "eval path"
}

case_bad_argument_exits_two() {
  local rc=0
  bash "$CHECKER" --skills >/dev/null 2>&1 || rc=$?
  assert_eq "2" "$rc" "missing value exit"
  rc=0
  bash "$CHECKER" --nonsense >/dev/null 2>&1 || rc=$?
  assert_eq "2" "$rc" "unknown flag exit"
}

run_case "shipped package passes" case_shipped_package_passes
run_case "fixture passes" case_fixture_passes
run_case "stage missing from one table" case_stage_missing_from_one_table
run_case "stage extra in the map" case_stage_extra_in_map
run_case "korean mirror drops a stage" case_korean_mirror_drops_a_stage
run_case "stage skill folder absent" case_stage_skill_folder_absent
run_case "handoff row has three cells" case_handoff_row_has_three_cells
run_case "handoff row has an empty cell" case_handoff_row_has_an_empty_cell
run_case "table header absent" case_table_header_absent
run_case "eval names an unknown stage" case_eval_names_an_unknown_stage
run_case "eval null route on a trigger" case_eval_null_route_on_a_trigger
run_case "eval route on a no_trigger" case_eval_route_on_a_no_trigger
run_case "eval empty route on a trigger" case_eval_empty_route_on_a_trigger
run_case "eval chains plan and debate" case_eval_chains_plan_and_debate
run_case "eval missing route field" case_eval_missing_route_field
run_case "stage count rule absent" case_stage_count_rule_absent
run_case "plan/debate rule absent" case_plan_debate_rule_absent
run_case "hardcoded stage total" case_hardcoded_stage_total
run_case "missing package file" case_missing_package_file
run_case "list prints checked paths" case_list_prints_checked_paths
run_case "bad argument exits two" case_bad_argument_exits_two

test_summary
