# Skill Authoring

> 영어판: [`SKILL_AUTHORING.md`](SKILL_AUTHORING.md)

이 문서는 `skills/*`를 새로 만들거나 개선할 때 읽는 기본 문서다. 목적은 AI에게 반복 가능한 역할과 절차를 맡길 수 있도록, skill을 단순 프롬프트가 아니라 **트리거 가능한 실행 패키지**이자 **검증 가능한 작은 프로그램**으로 설계하게 하는 것이다.

## 핵심 정의

Skill은 특정 작업군을 안정적으로 수행하기 위한 폴더형 실행 계약이다. 최소 단위는 `SKILL.md`이며, 필요할 때 `rules/`, `references/`, `scripts/`, `assets/`, 런타임별 metadata를 함께 둔다.

Skill은 다음을 동시에 만족해야 한다.

| 축 | 질문 |
|---|---|
| Intent | 어떤 반복 작업을 더 잘 수행하게 하는가? |
| Trigger | 어떤 사용자 요청에서 켜져야 하며, 어떤 요청에서는 켜지면 안 되는가? |
| Scope | 이 skill이 소유하는 파일, 행동, 산출물은 어디까지인가? |
| Authority | 사용자/프로젝트 지시, 공식 문서, 기존 skill 중 무엇이 우선인가? |
| Workflow | 실행자가 어떤 순서로 읽고, 판단하고, 행동해야 하는가? |
| Loop | 반복이 필요한가? 필요하다면 metric/rubric, guard, stop condition은 무엇인가? |
| Resources | 어떤 세부 지식·템플릿·스크립트가 필요할 때만 로드되어야 하는가? |
| Verification | skill이 트리거·실행·출력·안전 기준을 만족했음을 어떻게 증명하는가? |
| Stop condition | 언제 완료/중단/사용자 확인으로 전환하는가? |

## 공식 근거 요약

> 아래 출처는 2026-07-29 확인 기준이며, 링크 사용 가능 여부는 2026-09-19에 재확인했다. OpenAI Codex skill 문서는 `developers.openai.com/codex/skills`에서 `learn.chatgpt.com/docs/build-skills`로 이전됐다.

- OpenAI Codex는 skill을 지시문, 리소스, 선택적 스크립트를 묶어 Codex가 workflow를 안정적으로 따르도록 하는 reusable authoring format으로 설명한다. 호출은 ChatGPT에서 `@skill-name`, Codex/IDE에서 `$skill-name` 또는 `/skills`다. 목록 단계에서는 name과 description만 로드되고 그 예산은 컨텍스트의 2% 또는 8,000자다. 설치형 배포에는 OpenAI가 plugins를 권한다. <https://learn.chatgpt.com/docs/build-skills>
- **Codex 런타임 탐색 (2026-09-20 보고, `VENDOR`).** Codex는 고정된 우선순위 목록을 읽는 대신 현재 작업 디렉터리에서 저장소 루트까지 **모든 디렉터리**의 `.agents/skills`를 훑는다고 보고한다(`$CWD`, `$CWD/../`, `$REPO_ROOT`). 같은 `name`을 가진 두 skill은 **병합되지 않고** 둘 다 선택기에 나타날 수 있다고 보고한다. skill이 많으면 설명을 먼저 줄이고, 일부 skill을 **초기 목록에서 통째로 생략하고 경고를 띄울 수 있다**고 보고한다 — 설명이 잘리는 것만이 아니다. `allow_implicit_invocation`(기본 true)을 false로 두면 암시적 발화가 꺼지고 `$skill` 명시 호출만 동작한다. 이것들은 Codex의 동작이지 보편 규칙이 아니다 — 다른 런타임은 다를 수 있다. <https://learn.chatgpt.com/docs/build-skills>
- OpenAI API Skills 문서는 skill을 open Agent Skills standard와 호환되는 versioned bundle로 설명하고, prompt injection과 exfiltration 리스크 때문에 skill을 privileged instruction/code처럼 다루라고 경고한다. <https://developers.openai.com/api/docs/guides/tools-skills>
- OpenAI agent eval 문서는 agent workflow 검증을 trace grading에서 시작하고, 반복 가능성이 필요할 때 dataset/eval run으로 확장하라고 설명한다. <https://developers.openai.com/api/docs/guides/agent-evals>
- Anthropic은 Agent Skills를 `SKILL.md`, scripts, resources가 담긴 폴더로 보고, metadata → full instructions → referenced files/scripts 순서의 progressive disclosure를 핵심 설계 원리로 설명한다. 신뢰할 수 있는 출처의 skill만 설치하고, 신뢰할 수 없는 skill은 번들 파일·의존성·외부 네트워크 연결까지 감사하라고 경고한다. (발행 2025-10-16) <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills>
- Anthropic의 prompt/eval 문서는 success criteria와 evaluation을 먼저 정의한 뒤 prompt를 개선하라고 권장한다. <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>
- Agent Skills specification은 `name`, `description`을 필수 frontmatter로 두고 `license`, `compatibility`, `metadata`, `allowed-tools`(Experimental)를 선택 필드로, `scripts/`, `references/`, `assets/`를 선택 디렉터리로 정의한다. 길이 제한과 progressive disclosure 예산은 [`references/skill-anatomy.ko.md`](references/skill-anatomy.ko.md)를 따른다. <https://agentskills.io/specification>
- ReAct, Self-Refine, Reflexion, Tree of Thoughts, OPRO, Promptbreeder, DSPy/MIPRO 계열 연구는 skill을 “한 번에 잘 쓰는 prompt”가 아니라 observe/critique/score/iterate 가능한 workflow로 설계해야 함을 뒷받침한다. 자세한 적용은 [`references/prompt-loop-eval.ko.md`](references/prompt-loop-eval.ko.md)를 따른다.
- OpenAI의 skill eval 가이드는 skill 개선을 prompt 품질 개선처럼 다루며 **outcome(과제 완수), process(올바른 호출과 절차), style(관례·출력 형식 준수), efficiency(불필요한 명령·토큰 없이 완료)** 네 축을 작고 반복 가능한 eval로 확인하라고 권장한다. 데이터셋은 10-20개 프롬프트로 시작하고 explicit / implicit / contextual / negative control 네 범주를 담는다. <https://developers.openai.com/blog/eval-skills>

## 이 저장소의 기본 원칙

1. **로컬 우선**: 이 프로젝트에서 만드는 skill은 저장소 내부 `skills/`, `instructions/`, `scripts/`, `README.md`를 우선 근거로 삼는다.
2. **트리거 우선**: `description`은 기능 소개가 아니라 “언제 써야 하는지”를 앞부분에 명확히 적는다.
3. **계약 우선**: 페르소나보다 intent, scope, authority, evidence, output, verification, stop condition을 먼저 고정한다.
4. **프로그램처럼 설계**: 입력, 읽을 자료, 작업 단계, 도구, 중간 산출, 최종 산출, 검증을 분리한다. “좋은 prompt”보다 “재실행 가능한 procedure”가 우선이다.
5. **Loop는 조건부**: 반복 루프는 feedback, metric/rubric, guard, stop condition이 있을 때만 둔다. 무한 개선, 무제한 탐색, 자기 채점 단독 루프는 금지한다.
6. **Progressive disclosure**: `SKILL.md`는 얇게 유지하고, 반복 정책은 `rules/`, 상세 지식은 `references/`, deterministic helper는 `scripts/`, 산출 템플릿과 eval fixture는 `assets/`로 내린다.
7. **검증 내장**: trigger smoke test, workflow trace check, source grounding, safety case, local link/fence check, eval 또는 readback checklist를 skill 자체에 포함한다.
8. **안전 경계**: network, credential, destructive action, production side effect, broad tool permission은 skill 안에서 명시적으로 gated 상태로 둔다.
9. **한국어 산출 기본**: 이 저장소의 사용자-facing 산출물, 보고서, 검증 노트는 기본 한국어다. 단, machine-readable field와 공식 키는 원문을 보존한다.
10. **취약도에 맞춘 구체성**: 지시의 구체성 수준을 과제의 취약도에 맞춘다. 깨지기 쉬운 단계는 엄격하게 쓰고, 에이전트 판단에 맡겨도 되는 부분은 열어 둔다. 앞의 원칙들이 "무엇을 어디에 두는가"라면 이것은 "얼마나 엄격하게 쓰는가"다.
11. **자립이 기본**: 스킬은 자기 폴더만으로 온전하게 배포한다. 다른 스킬의 설치, 호출, 경로, 문서를 요구하지 않고, 바깥 내용이 꼭 필요하면 그 스킬의 `references/`에 로컬 스냅샷으로 가져온다. 경계는 이웃 스킬의 이름이 아니라 산출물의 형태로 서술한다. 예외는 사용자 지시뿐이고, 그 지시는 기록한다.

위 원칙 중 규범 ID를 갖는 것들을 기계가 읽는 형식으로 적는다:

- SK-P-1: 취약도에 맞춘 구체성 — 지시의 구체성 수준은 과제가 얼마나 쉽게 깨지는지에 맞춰야 한다(원칙 10).
- SK-P-2: 자립이 기본 — 스킬은 자기 폴더만으로 동작하고, 다른 스킬 참조는 사용자가 명시적으로 요청한 경우에만 존재하며 그 지시를 기록한다(원칙 11).

## 기본 폴더 구조

```text
skill-name/
├── SKILL.md                 # 필수: metadata + 핵심 실행 계약
├── SKILL.ko.md              # 권장: 한국어 mirror
├── rules/                   # 반복 정책, workflow, 검증 기준
├── references/              # 필요 시 로드하는 상세 지식/공식 문서 요약
├── scripts/                 # 반복·결정성이 필요한 실행 helper
├── assets/                  # 템플릿, 예시 산출물, static resources
└── agents/                  # 런타임/UI metadata가 필요할 때만
```

자세한 구조 규칙은 [`references/skill-anatomy.ko.md`](references/skill-anatomy.ko.md)를 읽는다.

## 최소 `SKILL.md` 계약

새 skill의 core 파일은 다음 항목을 빠짐없이 포함해야 한다.

```markdown
---
name: kebab-case-name
description: Use this skill when ...
compatibility: Optional runtime or dependency notes.
---

# Skill Name

<output_language>
...
</output_language>

<purpose>
...
</purpose>

<routing_rule>
...
</routing_rule>

<instruction_contract>
| Field | Contract |
|---|---|
| Intent | ... |
| Scope | ... |
| Authority | ... |
| Evidence | ... |
| Tools | ... |
| Loop | ... |
| Output | ... |
| Verification | ... |
| Stop condition | ... |
</instruction_contract>

<activation_examples>
Positive / Negative / Boundary examples
</activation_examples>

<workflow>
...
</workflow>

<validation>
...
</validation>
```

## 작성 workflow

| 단계 | 작업 | 완료 증거 |
|---|---|---|
| 0 | 이 산출물이 일반 문서인지 skill인지 판정 | “skill folder/refactor” scope 결정 |
| 1 | 대상 작업군과 반복 실패를 수집 | 실제 사용자 문장, local docs, 기존 skill 관찰, known failure |
| 2 | trigger 설계 | positive/negative/boundary 예시와 `description` 초안 |
| 3 | prompt contract 작성 | intent/scope/authority/context/workflow/output/verification이 분리됨 |
| 4 | loop 필요성 판정 | loop type, feedback source, guard, stop condition 또는 no-loop 사유 |
| 5 | resource 분리 | rules/references/scripts/assets가 필요성과 로딩 조건을 가짐 |
| 6 | 검증 설계 | trigger smoke set, workflow trace, source/safety cases, local links, script checks |
| 7 | bilingual/mirror 정리 | 필요한 경우 `*.ko.md`와 구조 정렬 |
| 8 | handoff | 변경 파일, 검증 결과, 남은 risk 기록 |

## Prompt / Loop / Eval 설계

Skill 작성자는 먼저 “이 skill이 어떤 작은 프로그램인가”를 정한다.

| 질문 | 문서화 위치 | 기준 |
|---|---|---|
| 입력은 무엇인가? | `SKILL.md` contract | 사용자 요청, 파일, source, tool output을 분리 |
| 어떤 단계로 실행하는가? | `workflow` 또는 `rules/` | explore/plan/act/verify/report처럼 관찰 가능한 단계 |
| 반복이 필요한가? | `Loop` contract 또는 `rules/loop.md` | feedback과 stop condition이 없으면 loop를 두지 않음 |
| 외부 근거가 필요한가? | `Evidence`, `references/official/`, source ledger | 최신·벤더·보안 claim은 source와 접근일 기록 |
| 어떻게 실패를 잡는가? | `validation`, `assets/evals/`, `scripts/` | trigger/workflow/output/safety regression case |

Loop 선택은 [`references/prompt-loop-eval.ko.md`](references/prompt-loop-eval.ko.md)를 따른다. 요약하면:

- 외부 상태를 읽고 행동해야 하면 ReAct형 `observe → act → observe → update` 루프를 쓴다.
- 산출물을 rubric으로 고칠 수 있으면 Self-Refine형 `draft → critique → revise` 루프를 쓴다.
- 반복 작업군의 실패 학습이 중요하면 Reflexion형 postmortem memory를 쓰되, 나쁜 feedback이 누적되지 않게 검증한다.
- 대안 탐색이 필요하면 Tree-of-Thoughts형 branch/score/prune을 쓰되, branch 수와 evaluator를 고정한다.
- prompt를 최적화하려면 OPRO/Promptbreeder/DSPy/MIPRO식 후보 비교를 사용하되, holdout과 regression set 없이 채택하지 않는다.

## 언제 support file을 추가하는가

| 위치 | 추가 기준 | 금지 기준 |
|---|---|---|
| `rules/` | 여러 skill run에서 반복되는 정책·절차·검증 기준 | 한 번만 쓰는 설명, 공식문서 복붙 |
| `references/` | 상세 API, 공식 문서 요약, edge case, long examples, source/safety notes | core trigger logic, 필수 stop condition |
| `scripts/` | 매번 같은 파싱/검증/생성 로직을 안정적으로 실행해야 함 | agent가 한두 줄 명령으로 충분히 처리 가능 |
| `assets/` | 템플릿, 스키마, 예시 산출물, eval fixture처럼 복사/채움 대상 | reasoning-only 설명 |
| `agents/` | UI 카드, OpenAI/Vendor metadata, dependency hints가 필요 | core instruction 대체물 |

자세한 배치 규칙은 [`references/resource-placement.ko.md`](references/resource-placement.ko.md)를 읽는다 — 그 파일이 배치 기준의 **정본**이고 이 절은 요약이다.

## Trigger 설계 규칙

- `description` 첫 문장에 가장 중요한 사용 시점과 keyword를 넣는다.
- “helps with X” 같은 일반 설명을 피하고, “Use when the user asks to...” 형태로 쓴다.
- 실제 사용자 문장을 positive/negative/boundary로 나눈다.
- should-trigger와 should-not-trigger를 모두 테스트한다.
- 너무 넓은 skill은 false positive를 만들고, 너무 좁은 skill은 여러 skill이 동시에 로드되어 충돌할 수 있다.

자세한 규칙은 [`references/trigger-design.ko.md`](references/trigger-design.ko.md)를 읽는다 — 그 파일이 trigger 완료 기준의 **정본**이고 위 체크리스트는 그것을 다시 적지 않는다.

## Progressive disclosure 규칙

1. Discovery: skill 목록에는 `name`, `description`, path 정도만 들어간다고 가정한다.
2. Activation: task가 맞을 때만 `SKILL.md` 전체가 들어간다고 가정한다.
3. Execution: referenced files/scripts/assets는 명시된 조건에서만 읽거나 실행한다고 설계한다.

즉, `SKILL.md`에는 항상 필요한 것만 둔다. 세부는 “언제 읽을지”와 함께 분리한다. 자세한 규칙은 [`references/progressive-disclosure.ko.md`](references/progressive-disclosure.ko.md)를 읽는다.

## Judgement Rules

확률적 검사가 어떻게 게이트가 되는지. 이 규칙들은 규범이고, `references/` 파일들이 이를 적용한다.

- SK-J-1: trigger 판정을 **단일 실행으로 선언하지 않는다.** 쿼리마다 여러 번 돌려 **트리거율**을 계산한다.
- SK-J-2: 시작 반복 횟수는 **쿼리당 3회**다.
- SK-J-3: should-trigger 쿼리는 트리거율이 임계값 **위**면 통과하고, should-not-trigger 쿼리는 **아래**면 통과한다. 기본 임계값은 **0.5**다.
- SK-J-4: 케이스 수와 반복 횟수를 **함께** 기록한다 — 예: 20 쿼리 x 3회 = 60 호출. 반복 횟수 없는 트리거율은 해석할 수 없다.
- SK-J-5: 트리거율은 반복 횟수에 따라 달라지므로, 다른 반복 횟수로 낸 결과는 이전 결과와 직접 비교하지 않는다.
- SK-J-6: 케이스별 통과/실패만 세지 않고 **트리거율 분포**를 남긴다. 임계값 근처에 몰린 쿼리가 불안정한 지점이다.

`SK-J-2`·`SK-J-3`의 값은 출처가 진술한 것이고, 출처는 이를 합리적인 시작점·합리적인 기본값이라고 부른다 — 검증된 최적값이 아니다. 케이스 파일은 자기 `runs`와 `threshold`를 상속하지 않고 명시한다. 그 숫자가 쓰이는 자리에서 보이게 하기 위해서다.

## 검증 기준

완료 전 최소 확인:

- [ ] `name`은 kebab-case이며 폴더명과 일치한다.
- [ ] `description`은 무엇을 하는지와 언제 쓰는지를 모두 포함한다.
- [ ] trigger 예시가 positive, negative, boundary를 포괄한다. 케이스 개수는 여기서 고정하지 않는다 — 세트 구성은 [`references/validation.ko.md`](references/validation.ko.md)가, 케이스 판정 방식은 [`references/trigger-design.ko.md`](references/trigger-design.ko.md)가 맡는다.
- [ ] `instruction_contract`에 intent/scope/authority/evidence/tools/loop/output/verification/stop condition이 있다.
- [ ] loop가 있으면 feedback source, metric/rubric, guard, stop condition이 있다.
- [ ] 최신·벤더·논문·보안 claim에는 source URL과 접근일 또는 snapshot date가 있다.
- [ ] prompt injection, credential, destructive/network/production side effect boundary가 있다.
- [ ] support files는 `SKILL.md`에서 상대경로로 직접 참조된다.
- [ ] scripts가 있으면 dependency, usage, expected output, failure handling이 적혀 있다.
- [ ] local markdown links와 code fence가 깨지지 않는다.
- [ ] 검증 결과와 남은 risk가 handoff에 남는다.

자세한 검증 루프는 [`references/validation.ko.md`](references/validation.ko.md)를 읽는다. 위 기준은 **무엇이 성립해야 하는지**의 정본이고, 각 항목을 **어떻게 검사하는지**는 그 파일이 갖는다.

## 함께 읽을 문서

- [`../context-engineering/CONTEXT_ENGINEERING.ko.md`](../context-engineering/CONTEXT_ENGINEERING.ko.md)
- [`../context-engineering/references/prompt-authoring.ko.md`](../context-engineering/references/prompt-authoring.ko.md)
- [`references/prompt-loop-eval.ko.md`](references/prompt-loop-eval.ko.md)
- [`../harness-engineering/HARNESS_ENGINEERING.ko.md`](../harness-engineering/HARNESS_ENGINEERING.ko.md)
- [`../sourcing/reliable-search.ko.md`](../sourcing/reliable-search.ko.md)
- [`../sourcing/references/retrieval-safety.ko.md`](../sourcing/references/retrieval-safety.ko.md)
- [`../validation/index.ko.md`](../validation/index.ko.md)

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-20. Next re-verification 2026-10-29.

| 주장 | 출처 |
|---|---|
| `name` 문자 규칙, frontmatter 필드 표, 3단계 점진공개 모델 | <https://agentskills.io/specification> |
| "취약도에 구체성을 맞춘다" — 원칙 10의 근거 | <https://agentskills.io/skill-creation/best-practices> |
| **트리거율** 지표, 시작 반복 횟수 **3회**, 기본 임계값 **0.5**, `SK-J-2`·`SK-J-3` 뒤의 "합리적인 시작점·기본값" hedge | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| 컨텍스트 2% / 8,000자 목록 예산, Codex의 저장소 순회 탐색, 같은 `name` 비병합, 경고를 동반한 목록 생략, `allow_implicit_invocation`, `/skills` 호출 형식, plugins 권고 | <https://learn.chatgpt.com/docs/build-skills> |

### 근거 등급

위 trigger 판정 값들은 출처가 **시작점**으로 진술한 것이지 검증된 최적값이 아니다. Codex 탐색 동작은 한 런타임이 보고한 `VENDOR` 주장이다 — 이 문서는 여러 런타임을 다루므로 "Codex는 …라고 보고한다"로 쓴다.
