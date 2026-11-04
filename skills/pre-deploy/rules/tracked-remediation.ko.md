# Tracked Remediation

**목적**: pre-deploy blocker가 복잡해 즉시 수정 패스로 처리하기 어려울 때 근거, 담당, 재개 상태를 보존합니다.

**읽는 조건**: baseline 배포 검사가 실패했고 분류 결과가 중간, 복잡, 병렬이거나, `.hyper/pre-deploy/flow.json`이 이미 있을 때 읽습니다. 그 밖의 경우에는 이 파일이 필요하지 않습니다.

다음 조건을 모두 만족한 뒤에만 사용합니다.

1. 대상 루트가 존재하고 그 루트에서 `bash skills/pre-deploy/scripts/stack-detect.sh`를 실행했습니다.
2. `bash skills/pre-deploy/scripts/deploy-check.sh`를 전체 실행해 baseline 실패를 확보했습니다.
3. 분류에서 형태를 중간, 복잡, 병렬로 판정했습니다.

## 흐름 파일

저장소 루트에 `.hyper/pre-deploy/flow.json`을 만들거나 이어서 씁니다. 파일은 작고 기계가 읽을 수 있게 유지하고, phase가 바뀔 때마다 갱신합니다.

```json
{
  "version": 1,
  "target_root": ".",
  "current_phase": "detect",
  "stacks": ["node"],
  "max_fix_attempts": 3,
  "phase_history": [
    { "phase": "detect", "status": "complete", "evidence": "stack-detect.sh output", "updated_at": "ISO-8601 timestamp" }
  ],
  "baseline": {
    "command": "bash skills/pre-deploy/scripts/deploy-check.sh",
    "exit_code": 1,
    "summary": "PRE_DEPLOY_SUMMARY executed=2 skipped=1"
  },
  "failure_groups": [
    {
      "id": "node-typecheck",
      "stack": "node",
      "command": "npm run typecheck",
      "priority": 1,
      "owner": "leader",
      "status": "open",
      "attempts": 0,
      "evidence": "exact failure excerpt"
    }
  ],
  "fixes": [
    {
      "failure_group": "node-typecheck",
      "files": ["src/example.ts"],
      "summary": "재현된 blocker에 묶인 좁은 수정",
      "validation_command": "npm run typecheck",
      "validation_status": "passed"
    }
  ],
  "validation_history": [
    { "command": "bash skills/pre-deploy/scripts/deploy-check.sh", "status": "failed", "evidence": "exit code and summary line" }
  ],
  "verdict": null,
  "report_path": ".hyper/pre-deploy/report.md",
  "remaining_risks": []
}
```

## Phase 전환

`detect` -> `baseline` -> `triage` -> `fix` -> `verify` -> `report` 순서로 이동합니다.

- `detect`: 대상 루트와 감지한 스택, 또는 지원하지 않는 스택으로 중단한 근거를 기록합니다.
- `baseline`: 명령, 종료 코드, `PRE_DEPLOY_SUMMARY` 줄을 기록합니다.
- `triage`: 실패를 스택, 명령, 우선순위, 담당, 독립성 기준으로 묶습니다.
- `fix`: 좁은 수정마다 대상 그룹, 증가한 `attempts`, 대상 재실행 결과를 기록합니다.
- `verify`: leader 맥락에서 새로 실행한 전체 deploy-check 결과를 기록합니다.
- `report`: `.hyper/pre-deploy/report.md`를 쓰고 `verdict`를 `ready`, `unproven`, `exhausted`, `handoff` 중 하나로 두며, 건너뛴 검사와 위험을 정리합니다.

## 시도 한도

`max_fix_attempts`는 스킬의 루프 계약이 선언한 한도를 담습니다. 권장값이 아니고 세션마다 새로 주어지는 값도 아닙니다.

- 대상 검사를 실행하기 전에 `attempts`를 먼저 올립니다. 중단된 실행이 시도를 숨기지 못하게 하려는 것입니다.
- 재개해도 기존 시도 횟수는 유지됩니다. 재개가 카운터를 초기화하지 않습니다.
- 같은 root 원인으로 한도에 닿으면 그룹을 `exhausted`로 두고 작업을 멈추며 `exhausted`로 보고합니다. `done`으로 이름을 바꾸지 않습니다.
- 새로운 root 원인은 새 그룹이고 카운터도 따로 씁니다.
- 검사자는 대상 명령이나 `bash skills/pre-deploy/scripts/deploy-check.sh`입니다. agent가 자기 diff를 다시 읽은 결과는 검사자가 아닙니다.

## 재개 규칙

흐름 파일이 이미 있을 때:

1. 새 검사를 실행하기 전에 `current_phase`, `failure_groups`, `fixes`, `attempts`, `validation_history`를 읽습니다.
2. 처음부터 다시 시작하지 않고 가장 이른 미완료 또는 실패 phase에서 이어서 진행합니다.
3. phase가 바뀌거나 초기화할 때마다 `phase_history` 이벤트를 덧붙입니다.
4. 대상 루트, 감지한 스택 집합, 패키지 매니저, 검증 명령이 바뀔 때만 `baseline`으로 되돌립니다.
5. 마지막 수정 뒤에 전체 deploy check를 다시 실행합니다. 이전 실행 결과로 `report`를 완료 처리하지 않습니다.

## 검증 확인 항목

- [ ] `target_root`, `current_phase`, `stacks`, `phase_history`, `baseline`, `failure_groups`, `validation_history`가 있습니다.
- [ ] 모든 실패 그룹에 스택, 명령, 우선순위, 담당, 상태, `attempts`, 근거가 있습니다.
- [ ] 모든 수정이 재현된 실패 그룹과 연결됩니다.
- [ ] 한 root 원인에서 `attempts`가 `max_fix_attempts`를 넘지 않습니다.
- [ ] 판정이 leader가 실행한 전체 deploy check에 근거하며 대상 검사만으로 끝나지 않습니다.
- [ ] 건너뛰었거나 사용할 수 없었던 검사를 통과한 검사와 분리해 적습니다.

## Sources

> 확인 2026-11-03. 이 규칙은 이 패키지 자체의 절차이며, 같은 날짜에 패키지 스크립트와 함께 다시 읽었습니다.

| 주장 | 출처 |
|---|---|
| 실패 그룹은 선언한 시도 한도에서 멈추고 `exhausted`로 보고한다 | `instructions/loop-engineering/LOOP_ENGINEERING.md` |
| 검사자는 작업을 수행한 주체와 분리한다 | `instructions/harness-engineering/HARNESS_ENGINEERING.md` |
| 건너뛴 검사는 `SKIP`으로 기록하고 통과로 세지 않는다 | `instructions/harness-engineering/references/evidence-and-recovery.md` |
| 보고서에는 검사 대상, 관찰 내용, 충분한 이유, 생략 내용을 담는다 | `instructions/harness-engineering/references/evidence-and-recovery.md` |
