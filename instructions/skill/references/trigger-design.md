# Trigger Design

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

모든 신규/대규모 refactor skill은 예시를 둔다.

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

최소 세트:

```json
[
  { "id": "p1", "prompt": "Create a Codex skill for SQL migration review", "should_trigger": true },
  { "id": "p2", "prompt": "Refactor this SKILL.md so it loads references correctly", "should_trigger": true },
  { "id": "p3", "prompt": "스킬 폴더를 새로 만들고 검증 규칙까지 넣어줘", "should_trigger": true },
  { "id": "n1", "prompt": "Rewrite this runbook for readability", "should_trigger": false },
  { "id": "n2", "prompt": "Summarize these OpenAI docs", "should_trigger": false },
  { "id": "b1", "prompt": "Create a guide for writing skills", "should_trigger": "depends_on_output_shape" },
  { "id": "b2", "prompt": "최신 논문을 보고 새 skill을 만들어줘", "should_trigger": "after_research_or_with_research_skill" },
  { "id": "b3", "prompt": "이 skill이 배포 명령까지 자동 실행하게 해줘", "should_trigger": true, "requires_gate": "production_side_effect" }
]
```

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
- [ ] positive/negative/boundary 예시가 있다.
- [ ] 비슷한 skill과의 차이가 명시되어 있다.
- [ ] should-trigger와 should-not-trigger smoke set이 있다.
- [ ] research, safety, deploy, commit 같은 companion workflow가 필요한 boundary가 있다.
