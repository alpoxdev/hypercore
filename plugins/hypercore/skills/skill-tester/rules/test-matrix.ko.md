# Skill Test Matrix

**Purpose**: 스킬을 신뢰하기 전에 무엇을 테스트해야 하는지 결정한다.

## Required dimensions

| Dimension | What to test | Typical evidence |
|---|---|---|
| Trigger precision | 스킬을 활성화해야 하는 요청과 활성화하지 않아야 하는 요청 | Positive/negative prompt table |
| Boundary routing | 이웃 스킬과 겹치는 요청 | Routing rationale |
| Workflow completeness | 각 단계가 에이전트에게 다음 행동을 제공하는지 | Phase-by-phase simulation |
| Resource integrity | 연결된 rules/references/scripts/assets가 존재하고 올바르게 배치되어 있는지 | Static file check |
| Validation strength | 완료에 근거가 필요한지 | Checklist/readback |
| Edge resilience | 입력 누락, 잘못된 경로, localization, 충돌, 지원되지 않는 대상 | Edge scenario table |
| Regression risk | 유사 스킬에서 온 알려졌거나 가능성 큰 실패 | Regression scenario |

## Minimum matrix

사용자가 더 작은 smoke test를 명시적으로 요청하지 않는 한 최소한 다음 케이스를 만든다:

- positive trigger 시나리오 3개.
- negative trigger 시나리오 2개.
- boundary 시나리오 2개.
- edge-case 시나리오 2개.
- regression 시나리오 1개.

## Severity guide

- `critical`: destructive 또는 high-risk 작업에 잘못된 스킬이 활성화되거나 필수 리소스가 없음.
- `high`: 일반적인 대상 요청에 대해 핵심 trigger/workflow가 실패함.
- `medium`: boundary behavior가 모호하지만 복구 가능함.
- `low`: 즉각적인 오라우팅 없는 wording, maintainability, 또는 report quality 이슈.

## Exit rule

일반 positive 시나리오가 올바르게 라우팅되고, negative 시나리오가 범위 밖에 머물며, support files가 해석되고, 워크플로가 validation evidence 없이 완료를 주장할 수 없을 때만 스킬은 통과한다.
