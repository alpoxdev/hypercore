# Tracked Remediation

**목적**: pre-deploy blocker가 direct Fix-now로 처리하기에 너무 복잡할 때 evidence, ownership, resume state를 보존합니다.

Tracked remediation은 다음 이후에만 사용합니다.

1. Target root가 존재하고 stack detection을 실행했습니다.
2. 지원 stack이 없는 경우를 제외하고, 초기 full `skills/pre-deploy/scripts/deploy-check.sh`가 baseline failure를 캡처했습니다.
3. Leader가 failure shape를 complex로 분류했습니다.

## Flow file

Repository root에 `.hypercore/pre-deploy/flow.json`을 만들거나 재개합니다. 작고 machine-readable하게 유지하며 phase transition마다 갱신합니다.

최소 schema:

```json
{
  "version": 1,
  "target_root": ".",
  "current_phase": "detect",
  "stacks": ["node"],
  "phase_history": [
    {
      "phase": "detect",
      "status": "complete",
      "evidence": "stack-detect.sh output",
      "updated_at": "ISO-8601 timestamp"
    }
  ],
  "baseline_command": "skills/pre-deploy/scripts/deploy-check.sh",
  "failure_groups": [
    {
      "id": "node-typecheck",
      "stack": "node",
      "command": "npm run typecheck",
      "priority": 1,
      "owner": "leader",
      "status": "open",
      "evidence": "exact failure excerpt"
    }
  ],
  "fixes": [
    {
      "failure_group": "node-typecheck",
      "files": ["src/example.ts"],
      "summary": "reproduced blocker에 연결된 narrow fix",
      "validation_command": "npm run typecheck",
      "validation_status": "passed"
    }
  ],
  "validation_history": [
    {
      "command": "skills/pre-deploy/scripts/deploy-check.sh",
      "status": "failed",
      "evidence": "summary 또는 captured output path"
    }
  ],
  "remaining_risks": []
}
```

## Phase transitions

Phase는 `detect` -> `baseline` -> `triage` -> `fix` -> `verify` -> `report` 순서로 이동합니다.

- `detect`: target root, detected stacks, unsupported-stack stop evidence를 기록합니다.
- `baseline`: full deploy-check command와 정확한 failing output을 기록합니다.
- `triage`: failure를 stack, command, priority, likely owner, independence 기준으로 그룹화합니다.
- `fix`: 각 narrow edit과 targeted validation command를 기록합니다.
- `verify`: leader context에서 실행한 final full deploy-check 결과를 기록합니다.
- `report`: blockers, fixes, skipped checks, remaining risks, readiness status를 요약합니다.

## Resume rules

`.hypercore/pre-deploy/flow.json`이 이미 있으면:

1. 새 check를 실행하기 전에 `current_phase`, `failure_groups`, `fixes`, `validation_history`를 읽습니다.
2. 처음부터 다시 시작하지 말고 가장 이른 incomplete 또는 failed phase에서 재개합니다.
3. phase가 바뀌거나 reset이 필요할 때마다 `phase_history` event를 추가합니다.
4. target root, detected stack set, package manager, validation command가 바뀐 경우에만 `baseline`으로 reset합니다.
5. Leader가 fresh final full deploy-check 결과를 읽기 전에는 `report`를 complete로 표시하지 않습니다.

## Validation assertions

- [ ] `target_root`, `current_phase`, `stacks`, `phase_history`, `failure_groups`, `validation_history`가 존재합니다.
- [ ] 모든 failure group에 stack, command, priority, owner, status, evidence가 있습니다.
- [ ] 모든 fix는 재현된 failure group으로 역추적됩니다.
- [ ] Final readiness는 targeted check만이 아니라 leader가 실행한 full deploy check에 근거합니다.
- [ ] Skipped 또는 unavailable check는 passed check와 분리해 나열합니다.
