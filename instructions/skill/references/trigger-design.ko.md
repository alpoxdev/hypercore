# Trigger Design

> 영어판: [`trigger-design.md`](trigger-design.md)

Trigger 설계의 목표는 skill이 필요한 작업에서 켜지고, 그 밖의 작업에서는 조용히 물러나게 하는 것입니다.

## 1. Description 작성 규칙

좋은 `description`은 세 가지를 담습니다.

1. 수행하는 작업군
2. 쓰여야 하는 상황
3. 제외할 경계 또는 중요한 키워드

3인칭으로 씁니다. 설명은 시스템 프롬프트에 주입되므로 "제가 도와드릴 수 있습니다", "이것으로 처리할 수 있습니다"처럼 시점이 흔들리면 선택에 문제가 생깁니다. 출처의 예시도 "Extract text and tables from PDF files" 같은 서술형입니다(<https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>, 확인 2026-11-03).

약한 예:

```yaml
description: Helps with documentation.
```

강한 예:

```yaml
description: Use this skill when the user asks to create or refactor a reusable Codex skill folder, including SKILL.md trigger wording, rules, references, scripts, assets, and validation checks. Do not use for generic documentation that is not a skill.
```

## 2. 작성 패턴

- "Use this skill when..."으로 시작합니다.
- 사용자가 원하는 결과를 앞에 씁니다. 내부 구현이 아니라 사용자가 얻으려는 산출을 적습니다.
- 핵심 키워드를 첫 문장에 둡니다. 모든 런타임이 긴 설명의 뒷부분을 줄이거나 버릴 수 있으므로(§7 참고), 트리거가 마지막 절에 의존하면 안 됩니다.
- 하나의 설명에 너무 많은 일을 담지 않습니다.
- 짧은 부정 경계를 넣습니다. 언제 켜지는지만 적은 설명은 선택기에게 물러설 근거를 주지 않습니다.

## 3. 트리거 예시 세트

트리거 예시는 **서로 직교하는 두 축**으로 만듭니다. 하나는 "켜져야 하는가", 다른 하나는 "어떻게 호출되는가"입니다. 두 축은 서로를 대체하지 않고, 둘을 교차해야 실제 실패가 드러납니다.

| 축 | 값 | 검증하는 것 |
|---|---|---|
| Activation | positive / negative / boundary | 설명이 옳은 요청에만 반응하는가 |
| Invocation mode | explicit / implicit / contextual / negative control | 이름 없이도 매칭되고, 비슷한 요청에는 오발화하지 않는가 |

Invocation mode 축은 OpenAI skill eval 지침에서 왔습니다(<https://developers.openai.com/blog/eval-skills>, 확인 2026-11-03). 그 지침의 표적 프롬프트 세트는 **explicit invocation**, **implicit invocation**, **contextual invocation**, **negative control** 네 가지 호출 case를 구분합니다.

| 호출 모드 | 의미 | 예 |
|---|---|---|
| explicit | skill 이름을 직접 부름 | `Use $skill-maker to build a skill` |
| implicit | 이름 없이 자연어로 설명과 일치 | `Create a reusable skill folder for me` |
| contextual | 실제 업무 문장에 도메인 맥락이 섞임 | `Make this migration review procedure run identically every time` |
| negative control | 비슷하지만 켜지면 안 되는 요청 | `Clean up this runbook so it reads better` |

데이터셋은 10~20개 프롬프트로 시작하고, 만나는 실패를 회귀 case로 계속 추가해 살아 있게 유지합니다.

아래 positive/negative/boundary 세트는 **activation 축**입니다. 새로 만들거나 크게 고친 skill은 예시를 남깁니다.

### Positive

- 실제 사용자가 skill을 호출해야 하는 문장
- 공식 skill 이름이 전혀 나오지 않는 문장
- 오타, 약어, 한국어와 영어가 섞인 문장

### Negative

- 비슷해 보이지만 다른 skill에 속하는 문장
- 일반 문서 작성, 기획, 요약 요청
- 단순한 한 단계 작업

### Boundary

- 두 skill이 겹치는 요청
- 조사 후 skill 작성처럼 순서가 필요한 요청
- commit이나 deploy처럼 후속 skill이 필요한 요청
- 외부 조사와 skill 작성처럼 source ledger가 먼저 와야 하는 요청
- network, credential, destructive action이 걸린 안전 gate가 필요한 요청
- "prompt를 더 좋게 만들어줘"처럼 일반 prompt 개선과 재사용 skill 작성이 구별되지 않는 모호한 요청

## 4. 트리거 smoke test

최소 세트입니다. 이전의 boolean `should_trigger`는 없앴습니다. 트리거는 확률적이므로 case마다 반복 횟수와 threshold를 스스로 갖고, 실행은 측정된 비율을 기록합니다. 이 key들이 따르는 판정 규칙은 `SKILL_AUTHORING.ko.md` → `## Judgement Rules`에 있습니다.

```json
[
  { "id": "p1", "prompt": "Create a Codex skill for SQL migration review", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "p2", "prompt": "Refactor this SKILL.md so it loads references correctly", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "p3", "prompt": "Create a new skill folder and include the validation rules", "expect": "trigger", "runs": 3, "threshold": 0.5 },
  { "id": "n1", "prompt": "Rewrite this runbook for readability", "expect": "no_trigger", "runs": 3, "threshold": 0.5 },
  { "id": "n2", "prompt": "Summarize these OpenAI docs", "expect": "no_trigger", "runs": 3, "threshold": 0.5 },
  { "id": "b1", "prompt": "Create a guide for writing skills", "expect": "no_trigger", "runs": 3, "threshold": 0.5, "note": "depends on output shape" },
  { "id": "b2", "prompt": "Read the latest papers and build a new skill", "expect": "trigger", "runs": 3, "threshold": 0.5, "note": "after or with a research skill" },
  { "id": "b3", "prompt": "Make this skill run the deploy command automatically", "expect": "trigger", "runs": 3, "threshold": 0.5, "requires_gate": "production_side_effect" }
]
```

실행은 case마다 측정된 `trigger_rate`를 덧붙이므로, 결과 파일은 같은 네 key와 결과를 함께 갖습니다.

```json
{ "id": "p1", "expect": "trigger", "runs": 3, "threshold": 0.5, "trigger_rate": 1.0 }
```

**모든 case는 자기 `runs`와 `threshold`를 적습니다.** 기본값을 상속하게 두지 않습니다. `runs`가 비율의 의미를 바꾸므로 값은 쓰이는 자리에서 보여야 합니다. 아래 case들은 **예시 하나의 세트이며 요구 개수가 아닙니다.** 각 case는 다른 case가 검사하지 않는 것을 검사하기 때문에 존재하고, 새로운 것을 검사하지 않는 case는 호출만 늘립니다.

| Case | 다른 case가 검사하지 않는 것 |
|---|---|
| `p1` | 설명만으로 켜져야 하는 평범한 제작 요청 |
| `p2` | skill이 아니라 기존 산출물을 지목하는 요청 |
| `p3` | 트리거 단어가 문장에 흩어진 요청 |
| `n1` | 무관한 산출물에 걸린 비슷한 동사(negative control) |
| `n2` | 같은 영역의 문서 작업(negative control) |
| `b1` | 요청한 산출물 형태에 따라 skill 작업이 되기도 하는 요청 |
| `b2` | 이 skill이 적용되기 전에 동반 workflow가 필요한 요청 |
| `b3` | 활성화된 뒤 안전 gate까지 걸어야 하는 요청 |

세트를 목표 개수에 맞춰 채우지 않습니다. 새로운 것을 검사하지 않는 case는 증거가 아니라 호출만 늘립니다.

트리거 eval에서는 프롬프트 문구만 보지 않고, 활성화된 뒤 필요한 동반 workflow도 함께 기록합니다.

| 경계 | 기대 라우팅 |
|---|---|
| 조사 + skill 작성 | sourcing과 조사를 먼저 하고 그 근거로 skill을 씁니다 |
| prompt 개선만 | context-engineering prompt 문서. skill을 만들지 않습니다 |
| 재사용 skill 폴더 | skill 작성 skill을 활성화합니다 |
| 도구 권한 추가 | skill 작성 + 안전/검증 참조 |
| deploy, commit, publish 포함 | 해당 후속 skill 또는 사용자 권한 gate |

## 5. 실패 양상

| 실패 | 증상 | 고치기 |
|---|---|---|
| 너무 넓음 | 매번 켜져 컨텍스트를 낭비합니다 | 부정 경계를 넣습니다 |
| 너무 좁음 | 사용자가 skill 이름을 말할 때만 켜집니다 | 사용자 의도와 동의어를 넣습니다 |
| 구현 중심 | 사용자가 목적을 말했는데 트리거가 걸리지 않습니다 | 도구·파일 이름 대신 결과를 앞에 씁니다 |
| 범위 모호 | 다른 skill과 충돌합니다 | 라우팅 규칙에서 소유와 비소유를 나눕니다 |
| 긴 설명 | 목록에는 앞부분만 남고 핵심이 사라집니다 | 핵심 트리거를 첫 문장에 압축합니다 |
| 안전 gate 누락 | 활성화되면 외부 부작용을 당연하게 여깁니다 | 설명이나 라우팅 규칙에 gated 행동을 적습니다 |
| 선행 조사 누락 | 최신성 주장이 그대로 skill에 박힙니다 | 출처 민감 트리거에는 sourcing 단계를 요구합니다 |
| 수동 전용 workflow | 자동 트리거가 사용자가 의도하지 않은 피해를 냅니다 | 수동으로 표시합니다(Claude Code는 `disable-model-invocation`, Codex는 `allow_implicit_invocation: false`) |

## 6. 완료 기준

- [ ] Description의 첫 문장이 트리거로 읽힙니다.
- [ ] Description이 3인칭이고 무엇을 하는지와 언제 쓰는지를 함께 적습니다.
- [ ] Positive, negative, boundary 예시가 있습니다(activation 축).
- [ ] Explicit, implicit, contextual, negative control 예시가 있습니다(invocation mode 축).
- [ ] 비슷한 skill과의 차이를 적었습니다.
- [ ] should-trigger와 should-not-trigger smoke set이 있습니다.
- [ ] 조사, 안전, deploy, commit 같은 동반 workflow 경계가 있습니다.
- [ ] Description이 skill을 설치할 가장 빡빡한 런타임 한도에 맞습니다.

## 7. 모델에 실제로 도달하는 것

설명은 적은 그대로 전달되지 않습니다. 런타임마다 목록 예산을 두고 잘라냅니다.

| 런타임 | 실제로 걸리는 한도 | 자르는 방식 |
|---|---|---|
| Agent Skills spec | `description` 1~1024자 | 정의되지 않음. 필드를 검증할 뿐 줄이지 않음 |
| Claude Code | 항목당 `description`과 `when_to_use`를 합쳐 1,536자, 목록은 컨텍스트의 1% | 호출 빈도가 낮은 skill부터 설명을 버림. 이름은 모두 남음 |
| Codex | 목록은 컨텍스트의 2% 또는 8,000자, `skills.max_context_tokens`로 최대 10,000토큰 | 설명을 먼저 줄이고, 일부 skill을 경고와 함께 목록에서 뺄 수 있음 |

설계에 주는 결론은 모든 런타임에서 같습니다. 첫 문장이 트리거를 혼자 감당해야 하고, 형식상 설치된 skill도 여전히 보이지 않을 수 있습니다.

## 8. Description 최적화

Description을 한 번 쓰고 끝내는 것으로는 부족합니다. 반복 수정은 조정한 예시에 과적합됩니다. 아래 규칙은 규범입니다.

- SK-O-1: 질의 세트를 **train과 validation**으로 나눕니다. Train으로 개선하고, **validation 통과율로 선택**합니다. 출처의 분할은 대략 train 60%, validation 40%이며, 섞은 뒤 반복 사이에 고정하고 두 세트 모두 positive/negative 비율을 유지합니다.
- SK-O-2: **가장 좋은 설명이 마지막 설명은 아닐 수 있습니다.** 나중 반복이 validation에서 더 낮으면 이전 반복을 남깁니다.
- SK-O-3: 최적화 과정에서 설명이 자랍니다. 수정할 때마다 **1024자 한도**를 다시 확인합니다.
- SK-O-4: 미세 조정이 더 도움이 되지 않으면 **구조를 바꿉니다.** 형용사를 하나 더 붙이는 것이 아니라 다른 틀이나 다른 문장 형태를 씁니다.

마지막 validation 점수만 보고하는 실행은 개선의 증거가 아닙니다. 선택이 드러나도록 반복마다 train과 validation 수치를 함께 보고합니다. 출처는 실무 한도도 두 가지 더 둡니다. 질의는 대략 20개(should-trigger 8~10개, should-not 8~10개)로 시작하고, "다섯 번 반복이면 대개 충분"하며, 마지막에 새 질의 5~10개로 다시 시험합니다.

## Sources

> 링크는 다시 읽고 확인 2026-11-03.

| 주장 | 출처 |
|---|---|
| 3인칭 description, 무엇을·언제를 함께 적는 요구, 이름 작성 지침 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> |
| 네 가지 호출 모드와 10~20개 프롬프트 시작 세트 | <https://developers.openai.com/blog/eval-skills> |
| trigger rate를 지표로 두는 것, 3회, 0.5 기본 threshold, train 60/validation 40 분할, "가장 좋은 것이 마지막은 아님", 1024자 재확인, 다섯 번 반복 지침, 새 질의 확인 — `SK-O-1`~`SK-O-4`의 근거 | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| `description` 1~1024자 범위 | <https://agentskills.io/specification> |
| 항목당 1,536자 제한과 호출 빈도 낮은 순서로 버리는 동작 | <https://code.claude.com/docs/en/skills> |
| 컨텍스트 2%/8,000자 목록 예산과 줄인 뒤 생략하는 동작 | <https://learn.chatgpt.com/docs/build-skills> |

### 근거 등급

최적화 규칙은 specification 사이트가 직접 밝히므로 `PRIMARY`입니다. 10~20개 프롬프트와 60/40 분할은 출처의 권장값으로 인용한 것이지 검증된 최적값이 아닙니다. §7의 목록 동작은 `VENDOR`입니다. 런타임마다 자기 잘라내기를 설명하고, 그 차이는 중요합니다(Claude Code는 설명을 버리고, Codex는 skill 자체를 뺄 수도 있습니다). §4의 case 수는 의도적으로 고정하지 않았습니다. 출처가 검증된 개수를 밝히지 않으므로 이 파일은 개수 대신 **구성**을 요구합니다. 각 case는 다른 case가 검사하지 않는 것을 검사해야 합니다.
