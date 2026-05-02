# Prompt Pack Template

**Purpose**: 스킬 트리거와 워크플로 테스트를 위한 재사용 가능한 회귀 테스트 산출물 형태를 제공한다.

사용자가 대상 스킬에 대한 재사용 가능한 프롬프트 팩, 회귀 테스트 팩, 또는 체크리스트 생성을 요청할 때 이 참고 자료를 사용한다.

## File placement

다음 위치 중 하나를 선호한다:

- 팩이 스킬과 함께 이동해야 할 때는 `skills/<target-skill>/references/skill-test-pack.md`.
- 팩이 실행별 근거일 때는 `.hypercore/skill-tester/<target-skill>/prompt-pack.md`.

저장소에 더 강한 관례가 이미 있지 않다면, 프롬프트 팩을 대상 스킬의 `SKILL.md`에서 한 디렉터리보다 더 깊이 묻지 않는다.

## Required sections

```markdown
# [Target Skill] Skill Test Pack

## Target behavior
- Skill path: `skills/example/`
- Intended job: ...
- Neighbor skills to avoid: ...

## Scenario matrix
| ID | Type | Prompt / condition | Expected routing | Expected workflow checkpoint |
|----|------|--------------------|------------------|------------------------------|
| P1 | positive | ... | target skill activates | ... |
| N1 | negative | ... | route away to ... | ... |
| B1 | boundary | ... | conditional / handoff | ... |
| E1 | edge | ... | safe fallback | ... |
| R1 | regression | ... | previous failure stays fixed | ... |

## Expected-observed results
| ID | Expected | Observed | Result | Evidence |
|----|----------|----------|--------|----------|

## Binary evals
```text
EVAL 1: Trigger boundary
Question: ...?
Pass: ...
Fail: ...
```

## Untested risks
- ...
```

## Minimum coverage

- `positive`: 현실적인 대상 요청을 최소 3개.
- `negative`: 이웃 스킬이 소유하는 요청을 최소 2개.
- `boundary`: 모호하거나 혼합 의도인 요청을 최소 2개.
- `edge`: 특이하지만 현실적인 조건을 최소 2개.
- `regression`: 알려졌거나 가능성이 큰 실패를 최소 1개.

## Scenario writing rules

- 대상 스킬이 `SKILL.ko.md`를 제공하거나 사용자가 한국어를 쓸 때는 한국어를 포함하여 실제 사용자 언어로 프롬프트를 작성한다.
- 기대 동작은 관찰 가능하게 유지한다: 라우팅, 다음으로 읽을 파일, 워크플로 단계, 명령, 또는 보고서 필드.
- "good" 또는 "clear" 같은 모호한 기준으로 점수화하지 말고 binary eval로 변환한다.
- 모든 실패를 가장 작은 가능성 있는 수정 또는 handoff 대상에 연결한다.
