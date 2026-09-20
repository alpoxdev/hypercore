# Trigger Design

> 영어판: [`trigger-design.md`](trigger-design.md)

Trigger design의 목표는 skill이 필요한 작업에서는 켜지고, 불필요한 작업에서는 조용히 물러나게 하는 것이다.

## 1. Description 작성 규칙

좋은 `description`은 세 가지를 포함한다.

1. 수행할 작업군
2. 사용해야 하는 상황
3. 제외해야 할 경계 또는 중요한 keyword

약한 예:

```yaml
description: Helps with documentation.
```

강한 예:

```yaml
description: Use this skill when the user asks to create or refactor a reusable Codex skill folder, including SKILL.md trigger wording, rules, references, scripts, assets, and validation checks. Do not use for generic documentation that is not a skill.
```

## 2. 작성 패턴

- “Use this skill when...”으로 시작한다.
- user intent를 앞세운다. 내부 구현보다 사용자가 원하는 결과를 적는다.
- 핵심 keyword를 앞부분에 둔다. 긴 skill 목록에서는 설명이 줄어들 수 있다고 가정한다.
- 너무 많은 일을 한 description에 넣지 않는다.
- negative boundary를 짧게 포함한다.

## 3. Trigger 예시 세트

Trigger 예시는 **두 개의 직교하는 축**으로 만든다. 하나는 “켜져야 하는가”이고 다른 하나는 “어떻게 불리는가”다. 둘은 서로를 대체하지 않으며, 두 축을 교차시켜야 실제 실패를 잡는다.

| 축 | 값 | 무엇을 검증하는가 |
|---|---|---|
| 발동 여부 | positive / negative / boundary | description이 옳은 요청에만 반응하는가 |
| 호출 방식 | explicit / implicit / contextual / negative control | 이름 없이도 매칭되는가, 그리고 오발동하지 않는가 |

호출 방식 축은 OpenAI skill eval 가이드(<https://developers.openai.com/blog/eval-skills>, 확인 2026-09-19)에서 온다. 그 가이드의 표적 프롬프트 세트는 네 가지 호출 사례를 구분한다. **explicit invocation**, **implicit invocation**, **contextual invocation**, **negative control**이다. 이 저장소는 이를 아래 축으로 일반화해 쓴다.

| 호출 방식 | 의미 | 예시 |
|---|---|---|
| explicit | skill 이름을 직접 지목 | `$skill-maker로 스킬 만들어줘` |
| implicit | 이름 없이 description과 자연어로 매칭 | `재사용 가능한 스킬 폴더를 만들어줘` |
| contextual | 도메인 맥락이 섞인 실제 업무 문장 | `이 마이그레이션 리뷰 절차를 매번 똑같이 돌리게 해줘` |
| negative control | 켜지면 안 되는 유사 요청 | `이 런북을 읽기 좋게 다듬어줘` |

데이터셋은 10-20개 프롬프트로 시작하고, 실패를 만날 때마다 회귀 케이스로 추가해 살아있는 세트로 유지한다.

아래 positive/negative/boundary는 **발동 여부 축**이다. 모든 신규/대규모 refactor skill은 예시를 둔다.

### Positive

- 실제 사용자가 skill을 불러야 하는 문장
- 공식 skill 이름을 직접 언급하지 않는 문장
- 오타, 축약, 한국어/영어 혼합 문장

### Negative

- 비슷해 보이지만 다른 skill이 맡아야 하는 문장
- 일반 문서/계획/요약 요청
- 단순 one-step 작업

### Boundary

- 두 skill이 겹치는 요청
- research + skill creation처럼 순서가 필요한 요청
- commit/deploy처럼 후속 skill이 필요한 요청
- 외부 자료조사 + skill 생성처럼 source ledger가 선행되어야 하는 요청
- 네트워크, credential, destructive action을 포함해 safety gate가 필요한 요청
- “프롬프트를 좋게 해줘”처럼 일반 prompt 개선인지 reusable skill 제작인지 애매한 요청

## 4. Trigger smoke test

최소 세트. 이전의 불리언 `should_trigger`는 사라졌다: trigger는 확률적이므로 케이스마다 자기 반복 횟수와 임계값을 싣고, 실행이 결과 비율을 기록한다. 이 키들이 따르는 판정 규칙은 `SKILL_AUTHORING.ko.md`의 `## Judgement Rules`를 본다.

```json
[
  { "id": "p1", "prompt": "Create a Codex skill for SQL migration review", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "p2", "prompt": "Refactor this SKILL.md so it loads references correctly", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "p3", "prompt": "스킬 폴더를 새로 만들고 검증 규칙까지 넣어줘", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "n1", "prompt": "Rewrite this runbook for readability", "expect": "no_trigger", "runs": 3, "threshold": 0.5 },
  { "id": "n2", "prompt": "Summarize these OpenAI docs", "expect": "no_trigger", "runs": 3, "threshold": 0.5 },
  { "id": "b1", "prompt": "Create a guide for writing skills", "expect": "no_trigger", "runs": 3, "threshold": 0.5, "note": "출력 형태에 달림" },
  { "id": "b2", "prompt": "최신 논문을 보고 새 skill을 만들어줘", "expect": "trigger", "runs": 3, "threshold": 0.5, "note": "research skill과 함께 또는 이후" },
  { "id": "b3", "prompt": "이 skill이 배포 명령까지 자동 실행하게 해줘", "expect": "trigger", "runs": 3, "threshold": 0.5, "requires_gate": "production_side_effect" }
]
```

실행은 케이스마다 측정된 `trigger_rate`를 덧붙인다. 결과 파일은 같은 네 키에 결과가 더해진 형태다:

```json
{ "id": "p1", "expect": "trigger", "runs": 3, "threshold": 0.5, "trigger_rate": 1.0 }
```

**케이스마다 자기 `runs`와 `threshold`를 명시한다.** 기본값을 상속하게 두지 않는다 — `runs`가 비율의 의미를 바꾸므로 그 값이 쓰이는 자리에서 보여야 한다. 아래 케이스들은 **예시 세트 하나이지 요구 개수가 아니다** — 각 케이스는 다른 케이스가 검사하지 않는 것을 검사하기 때문에 존재하고, 새로 검사하는 것이 없는 케이스는 호출만 늘린다:

| 케이스 | 다른 케이스가 검사하지 않는 것 |
|---|---|
| `p1` | description만으로 발화해야 하는 평범한 작성 요청 |
| `p2` | skill 이름이 아니라 기존 산출물을 지목하는 요청 |
| `p3` | trigger 단어가 문장 전체에 흩어진 요청 |
| `n1` | 같은 동사를 무관한 산출물에 쓴 경우(negative control) |
| `n2` | 같은 영역의 문서 작업(negative control) |
| `b1` | 요청한 출력 형태에 따라 skill 작업이 되기도 하는 요청 |
| `b2` | 이 skill이 적용되기 전에 companion workflow가 필요한 요청 |
| `b3` | 발화한 뒤 안전 gate까지 걸려야 하는 요청 |

목표 개수를 채우려고 케이스를 늘리지 않는다. 새로 검사하는 것이 없는 케이스는 증거가 아니라 호출만 늘린다.

Trigger eval에는 prompt wording만 보지 말고, 켜진 뒤 필요한 companion workflow도 기록한다.

| Boundary | 기대 routing |
|---|---|
| research + skill creation | sourcing/research 먼저, 그 근거로 skill 작성 |
| prompt improvement only | context-engineering prompt guide, skill 생성은 하지 않음 |
| reusable skill folder | skill authoring 활성화 |
| tool permission 추가 | skill authoring + safety/validation reference |
| deploy/commit/publish 포함 | 해당 후속 skill 또는 사용자 권한 gate |

## 5. 실패 패턴

| 실패 | 증상 | 수정 |
|---|---|---|
| 너무 넓음 | 매번 skill이 켜져 context를 낭비 | negative boundary 추가 |
| 너무 좁음 | 사용자가 skill 이름을 말해야만 켜짐 | user intent와 유사어 추가 |
| 구현 중심 | 사용자는 목적을 말했는데 trigger가 안 됨 | tool/file명보다 outcome을 앞세움 |
| 모호한 scope | 다른 skill과 충돌 | routing rule에 소유/비소유를 분리 |
| 긴 설명 | skill list에서 앞부분만 남아 핵심 누락 | 첫 문장에 핵심 trigger 압축 |
| 안전 gate 누락 | skill이 켜진 뒤 외부 side effect를 당연시함 | description 또는 routing rule에 gated action 명시 |
| research 선행 누락 | 최신 claim을 skill에 바로 박음 | source-sensitive trigger는 sourcing 단계 요구 |

## 6. 완료 기준

- [ ] description 첫 문장이 trigger로 읽힌다.
- [ ] positive/negative/boundary 예시가 있다(발동 여부 축).
- [ ] explicit/implicit/contextual/negative control 예시가 있다(호출 방식 축).
- [ ] 비슷한 skill과의 차이가 명시되어 있다.
- [ ] should-trigger와 should-not-trigger smoke set이 있다.
- [ ] research, safety, deploy, commit 같은 companion workflow가 필요한 boundary가 있다.

## 7. Description 최적화

description을 한 번 쓰고 끝내는 것이 전부가 아니다. 반복 편집은 그것을 조정한 예시에 과적합된다. 이 규칙들은 규범이다.

- SK-O-1: 쿼리 집합을 **train과 validation으로 나눈다.** 개선은 train으로, **선택**은 validation 통과율로 한다.
- SK-O-2: **가장 좋은 description이 마지막 것이 아닐 수 있다.** 나중 반복이 validation에서 더 낮으면 이전 반복을 선택한다.
- SK-O-3: 최적화하는 동안 description은 자란다. 편집할 때마다 **1024자 한계**를 다시 확인한다.
- SK-O-4: 미세 조정이 도움이 되지 않으면 **구조를 바꾼다** — 형용사를 하나 더 붙이는 것이 아니라 다른 프레이밍, 다른 문장 구조로.

마지막 validation 점수만 보고하는 실행은 개선의 증거가 아니다. 선택 과정이 보이도록 반복마다 train과 validation 수치를 함께 보고한다.

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-20. Next re-verification 2026-10-29.

| 주장 | 출처 |
|---|---|
| 네 가지 호출 방식(explicit/implicit/contextual/negative control)과 10-20 프롬프트 시작 세트 | <https://developers.openai.com/blog/eval-skills> |
| 트리거율 지표, 3회, 기본 임계값 0.5, train/validation 분할, "가장 좋은 것이 마지막이 아닐 수 있다", 1024자 재확인, 구조 변경 fallback — `SK-O-1`~`SK-O-4`의 근거 | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| `description`의 1024자 한계 | <https://agentskills.io/specification> |

### 근거 등급

위 최적화 규칙들은 `PRIMARY`다 — specification 사이트가 직접 진술한다. 10-20 프롬프트 수치는 출처가 권하는 **시작점**으로 인용한 것이지 검증된 최적값이 아니다. §4의 케이스 개수는 의도적으로 고정하지 않는다: 출처가 개수를 진술하지 않으므로 이 파일은 **구성** 요건으로 대신한다 — 각 케이스는 다른 케이스가 검사하지 않는 것을 검사해야 한다.
