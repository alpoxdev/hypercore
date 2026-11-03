# Skill Authoring

> 영어판: [`SKILL_AUTHORING.md`](SKILL_AUTHORING.md)
>
> 고정 스냅샷: `skills/skill-maker/references/local/instructions-skill-authoring.ko.md`는 `instructions/skill/**`의 고정 요약(사본이 아님)을 담아 그 skill이 자립할 수 있게 합니다. 둘이 다르면 이 기준 문서가 우선합니다. 이 기준 문서가 바뀌면 그 요약을 의도적으로 갱신합니다. 자동으로 동기화되지 않습니다.

이 문서는 `skills/*`를 새로 만들거나 개선할 때 읽는 기본 문서입니다. 목적은 AI에게 반복 가능한 역할과 절차를 맡길 수 있도록, skill을 단순 프롬프트가 아니라 **트리거 가능한 실행 패키지**이자 **검증 가능한 작은 프로그램**으로 설계하게 하는 것입니다.

## 핵심 정의

Skill은 특정 작업군을 안정적으로 수행하기 위한 폴더형 실행 계약입니다. 최소 단위는 `SKILL.md`이며, 필요할 때 `rules/`, `references/`, `scripts/`, `assets/`, 런타임별 metadata를 함께 둡니다.

Skill은 다음을 동시에 만족해야 합니다.

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

> 아래 출처는 2026-11-03에 모두 다시 읽었습니다. Agent Skills 문서 페이지에는 눈에 보이는 발행일이 없어, 페이지에 내장된 `dateModified` metadata가 있는 경우 함께 적었습니다. OpenAI Codex skill 문서는 `learn.chatgpt.com/docs/build-skills`에 있습니다. `developers.openai.com/codex/skills`는 이제 그 페이지로 308 redirect만 되므로, 인용하는 canonical URL은 전자입니다.

- Agent Skills specification은 `name`(1~64자, 소문자 영숫자와 하이픈, 앞뒤 하이픈 없음, `--` 없음, 폴더 이름과 일치)과 `description`(1~1024자)만 필수로 둡니다. `license`, `compatibility`(1~500자), `metadata`, `allowed-tools`(Experimental)는 선택이고 `scripts/`, `references/`, `assets/`는 선택 디렉터리입니다. 페이지 metadata의 `dateModified`는 2026-08-04입니다. <https://agentskills.io/specification>
- **Codex (2026-11-03 확인).** Skill은 지시문, 리소스, 선택적 스크립트를 묶은 단위입니다. 명시 호출은 ChatGPT에서 `@`, Codex CLI와 IDE 확장에서 `/skills` 또는 `$`이고, 암시 호출은 `description`과의 일치로 이뤄집니다. 초기 목록 예산은 **모델 컨텍스트의 2%, 컨텍스트 크기를 모를 때는 8,000자**이며 `skills.max_context_tokens`로 최대 10,000토큰까지 올릴 수 있습니다. Codex는 `$CWD`에서 저장소 루트까지의 `.agents/skills`, `$HOME/.agents/skills`, `/etc/codex/skills`, 번들 system skill을 읽고, 같은 `name`의 skill 두 개를 병합하지 않으며, symlink 폴더를 따라가고, `~/.codex/config.toml`의 `[[skills.config]]`로 특정 skill을 끕니다. `agents/openai.yaml`은 UI metadata, `policy.allow_implicit_invocation`, 도구 의존성을 담습니다. 배포는 plugins를 권합니다. <https://learn.chatgpt.com/docs/build-skills>
- **Claude Code (2026-11-03 확인).** Skill은 `.claude/skills/`(enterprise, 개인 `~/.claude/skills/`, 프로젝트, 중첩, `--add-dir`, plugin, claude.ai 계정)에서 로드되고 `/skill-name`으로 호출합니다. 사용자 명령은 skill로 통합됐습니다. Frontmatter는 spec보다 많은 필드를 받고, 목록 예산은 **모델 컨텍스트의 1%**이며 항목마다 `description`과 `when_to_use`를 합친 길이가 **1,536자**로 제한됩니다. 목록이 예산을 넘으면 Claude Code는 호출 빈도가 낮은 skill부터 설명을 버립니다. <https://code.claude.com/docs/en/skills>
- **Anthropic 플랫폼 (2026-11-03 확인).** Metadata는 skill마다 약 100토큰이 항상 로드되고, `SKILL.md` 본문은 트리거 시 로드되며 **5k 토큰 미만**을 권장합니다. 묶인 파일은 읽기 전까지 비용이 없습니다. `name`에는 XML 태그와 예약어 `anthropic`/`claude`를 쓸 수 없습니다. Skill은 network가 없는 파일시스템 sandbox에서 실행됩니다. <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> API 요청 하나에는 **skill을 최대 20개**까지 붙일 수 있습니다. <https://platform.claude.com/docs/en/build-with-claude/skills-guide>
- **Anthropic enterprise 지침 (2026-11-03 확인).** Skill은 Git, Skills API, plugin, managed settings를 거쳐 운영에 들어갑니다. 운영 skill은 버전을 고정하고, 모든 업데이트를 보안 검토가 붙는 새 배포로 다루며, 이전 버전을 rollback용으로 남기고, 검토한 skill의 checksum을 배포 시점에 확인합니다. Custom skill은 표면(API, claude.ai, Claude Code) 사이에서 동기화되지 않습니다. <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise>
- **Vercel `skills` CLI (2026-11-03 확인).** `npx skills`는 하나의 source 형식으로 대략 80개 coding agent에 skill을 설치·검색·업데이트·삭제합니다. README는 OpenCode, Claude Code, Codex, Cursor와 "75 more"를 듭니다. 프로젝트 설치는 각 agent의 프로젝트 디렉터리에 들어가고, Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode 등 여러 agent가 `.agents/skills/`를 공통 프로젝트 경로로 씁니다. 공통 전역 경로는 `~/.agents/skills/`입니다. Node.js 22.20 이상이 필요하고 `npx skills init`으로 skill 뼈대를 만듭니다. <https://github.com/vercel-labs/skills>
- **Skill의 효용은 가정하지 않습니다 (논문, 2026-03-16).** SWE-Skills-Bench는 공개 skill 98개를 저장소 commit을 고정한 과제와 실행 verifier로 측정했습니다. 98개 중 92개가 통계적으로 유의미한 효과를 내지 못했고, 평균 통과율은 76.6%에서 76.9%로만 움직였습니다. 도움이 된 skill은 agent가 빠뜨릴 절차를 제공했고(최대 +17.7점), 해로운 skill은 agent를 자기 템플릿에 고정시켜 과제의 명시 지시를 덮어썼습니다. <https://arxiv.org/abs/2603.15401>
- OpenAI API Skills 문서는 skill을 open Agent Skills standard와 호환되는 versioned bundle로 설명하고, prompt injection과 exfiltration 리스크 때문에 skill을 privileged instruction이자 code로 다루라고 경고합니다. <https://developers.openai.com/api/docs/guides/tools-skills>
- Anthropic 엔지니어링 노트(발행 2025-10-16)는 metadata → 전체 지시 → 참조 파일과 스크립트로 이어지는 progressive disclosure를 핵심 설계 원리로 꼽고, 신뢰할 수 있는 출처의 skill만 설치하며 신뢰할 수 없는 skill은 번들 파일, 의존성, 외부 network 연결까지 감사하라고 경고합니다. <https://www.anthropic.com/research/equipping-agents-for-the-real-world-with-agent-skills>
- OpenAI의 skill eval 지침은 skill 개선을 prompt 품질 개선처럼 다루며, 작고 반복 가능한 eval로 네 축을 확인하라고 권합니다. 네 축은 **outcome(과제 완수), process(올바른 호출과 절차), style(관례와 출력 형식 준수), efficiency(불필요한 명령과 토큰 없이 완료)**입니다. 데이터셋은 explicit, implicit, contextual, negative control 범주에 걸쳐 10~20개 프롬프트로 시작합니다. <https://developers.openai.com/blog/eval-skills>
- ReAct, Self-Refine, Reflexion, Tree of Thoughts, OPRO, Promptbreeder, DSPy/MIPRO 계열 연구는 skill을 "한 번에 잘 쓰는 prompt"가 아니라 observe/critique/score/iterate 가능한 workflow로 설계해야 함을 뒷받침합니다. 적용 방법은 [`references/prompt-loop-eval.ko.md`](references/prompt-loop-eval.ko.md)를 따릅니다.

## 이 저장소의 기본 원칙

1. **로컬 우선**: 이 프로젝트에서 만드는 skill은 저장소 내부 `skills/`, `instructions/`, `scripts/`, `README.md`를 우선 근거로 삼습니다.
2. **트리거 우선**: `description`은 기능 소개가 아니라 "언제 써야 하는지"를 앞부분에 명확히 적습니다.
3. **계약 우선**: 페르소나보다 intent, scope, authority, evidence, output, verification, stop condition을 먼저 고정합니다.
4. **프로그램처럼 설계**: 입력, 읽을 자료, 작업 단계, 도구, 중간 산출, 최종 산출, 검증을 분리합니다. "좋은 prompt"보다 "재실행 가능한 procedure"가 우선입니다.
5. **Loop는 조건부**: 반복 루프는 feedback, metric/rubric, guard, stop condition이 있을 때만 둡니다. 무한 개선, 무제한 탐색, 자기 채점 단독 루프는 금지합니다.
6. **Progressive disclosure**: `SKILL.md`는 얇게 유지하고, 반복 정책은 `rules/`, 상세 지식은 `references/`, deterministic helper는 `scripts/`, 산출 템플릿과 eval fixture는 `assets/`로 내립니다.
7. **검증 내장**: trigger smoke test, workflow trace check, source grounding, safety case, local link/fence check, eval 또는 readback checklist를 skill 자체에 포함합니다.
8. **안전 경계**: network, credential, destructive action, production side effect, 넓은 tool 권한은 skill 안에서 명시적으로 gated 상태로 둡니다.
9. **한국어 산출 기본**: 이 저장소의 사용자-facing 산출물, 보고서, 검증 노트는 기본 한국어입니다. 단, machine-readable field와 공식 키는 원문을 보존합니다.
10. **취약도에 맞춘 구체성**: 지시의 구체성 수준을 과제가 얼마나 쉽게 깨지는지에 맞춥니다. 깨지기 쉬운 단계는 엄격하게 쓰고, agent 판단에 맡겨도 되는 부분은 열어 둡니다. 앞의 원칙들이 "무엇을 어디에 두는가"라면 이것은 "얼마나 엄격하게 쓰는가"입니다.
11. **자립이 기본**: skill은 자기 폴더만으로 온전하게 배포합니다. 다른 skill의 설치, 호출, 경로, 문서를 요구하지 않고, 바깥 내용이 꼭 필요하면 그 skill의 `references/`에 로컬 스냅샷으로 가져옵니다. 예외는 사용자 지시뿐이고, 그 지시는 기록합니다.
12. **이식 가능한 핵심, 기록하는 확장**: specification의 여섯 필드는 모든 런타임이 이해하는 부분입니다. 런타임 전용 필드를 더할 수는 있지만, 그 필드를 걷어내도 skill이 동작해야 하고, 필드를 쓰는 자리에서 어느 런타임의 필드인지 밝힙니다.

위 원칙 중 규범 ID를 갖는 것들을 기계가 읽는 형식으로 적습니다:

- SK-P-1: 취약도에 맞춘 구체성 — 지시의 구체성 수준은 과제가 얼마나 쉽게 깨지는지에 맞춰야 합니다(원칙 10).
- SK-P-2: 자립이 기본 — skill은 자기 폴더만으로 동작하고, 다른 skill 참조는 사용자가 명시적으로 요청한 경우에만 존재하며 그 지시를 기록합니다(원칙 11).
- SK-P-3: 이식 가능한 핵심, 기록하는 확장 — 계약은 spec의 여섯 필드가 지고, 런타임 전용 frontmatter는 어느 런타임의 것인지 밝히며 없어도 동작해야 합니다(원칙 12).

## 기본 폴더 구조

```text
skill-name/
├── SKILL.md                 # Required: metadata + core execution contract
├── SKILL.ko.md              # Recommended: Korean mirror
├── rules/                   # Recurring policy, workflow, verification criteria
├── references/              # Detailed knowledge and official doc summaries, loaded on demand
├── scripts/                 # Execution helpers needing repeatability and determinism
├── assets/                  # Templates, example artifacts, static resources
└── agents/                  # Runtime metadata only: e.g. Codex agents/openai.yaml
```

자세한 구조 규칙은 [`references/skill-anatomy.ko.md`](references/skill-anatomy.ko.md)를 읽습니다.

## 최소 `SKILL.md` 계약

새 skill의 core 파일은 다음 항목을 빠짐없이 포함해야 합니다. `instruction_contract`의 아홉 필드가 canonical 세트이고, prompt 계약을 개략적으로 적은 다른 문서는 더 짧은 목록을 다시 적지 않고 이 필드로 대응시킵니다.

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
| 0 | 산출물이 일반 문서인지 skill인지 결정 | "skill 폴더/리팩터" 범위 결정 |
| 1 | 대상 작업군과 반복 실패를 수집 | 실제 사용자 문장, 로컬 문서, 기존 skill 관찰, 알려진 실패 |
| 2 | 트리거 설계 | positive/negative/boundary 예시와 `description` 초안 |
| 3 | Prompt 계약 작성 | 계약의 아홉 필드, 즉 intent, scope, authority, evidence, tools, loop, output, verification, stop condition을 분리 |
| 4 | Loop 필요 여부 결정 | loop 유형, feedback 출처, guard, stop condition 또는 loop를 두지 않는 이유 |
| 5 | 리소스 분할 | rules/references/scripts/assets마다 존재 이유와 로드 조건 |
| 6 | 검증 설계 | trigger smoke set, workflow trace, source/safety case, 로컬 링크, 스크립트 검사 |
| 7 | 이중 언어 정합 | 필요하면 `*.ko.md`와 구조 정렬 |
| 8 | 인계 | 변경 파일, 검증 결과, 남은 위험 기록 |

## Prompt / loop / eval 설계

Skill 작성자는 먼저 "이 skill은 어떤 작은 프로그램인가"를 정합니다.

| 질문 | 기록 위치 | 기준 |
|---|---|---|
| 입력은 무엇인가? | `SKILL.md` 계약 | 사용자 요청, 파일, 출처, 도구 출력을 구분 |
| 어떤 단계로 실행되는가? | `workflow` 또는 `rules/` | explore/plan/act/verify/report처럼 관찰 가능한 단계 |
| 반복이 필요한가? | `Loop` 계약 또는 `rules/loop.md` | feedback과 stop condition이 없으면 loop도 없다 |
| 외부 근거가 필요한가? | `Evidence`, source ledger, `references/official/`(권장) 또는 저장소 스냅샷용 `references/local/` | 최신성·벤더·보안 주장에는 출처와 확인 날짜를 기록 |
| 실패는 어떻게 잡히는가? | `validation`, `assets/evals/`, `scripts/` | 트리거·workflow·출력·안전 회귀 case |

Loop 선택은 [`references/prompt-loop-eval.ko.md`](references/prompt-loop-eval.ko.md)를 따릅니다. 요약하면 다음과 같습니다.

- 외부 상태를 읽고 행동해야 하면 ReAct식 `observe -> act -> observe -> update` loop를 씁니다.
- 산출물을 rubric에 맞춰 고칠 수 있으면 Self-Refine식 `draft -> critique -> revise` loop를 씁니다.
- 작업군 전체에서 실패로 배우는 것이 중요하면 Reflexion식 사후 분석 기억을 쓰되, 나쁜 feedback이 쌓이지 않는지 확인합니다.
- 대안 탐색이 필요하면 Tree-of-Thoughts식 branch/score/prune을 쓰되, branch 수와 evaluator를 고정합니다.
- Prompt 최적화에는 OPRO/Promptbreeder/DSPy/MIPRO식 후보 비교를 쓰되, holdout과 회귀 세트 없이 채택하지 않습니다.

## 지원 파일을 추가하는 기준

| 위치 | 추가할 때 | 추가하지 말 때 |
|---|---|---|
| `rules/` | skill 실행마다 반복되는 정책, 절차, 검증 기준 | 일회성 설명, 공식 문서 붙여넣기 |
| `references/` | 상세 API, 공식 문서 요약, edge case, 긴 예시, 출처·안전 노트 | 핵심 트리거 로직, 필수 stop condition |
| `scripts/` | 같은 파싱·검증·생성 로직을 매번 안정적으로 실행해야 할 때 | agent가 명령 한두 개로 처리할 수 있을 때 |
| `assets/` | 템플릿, schema, 예시 산출물, eval fixture처럼 복사하거나 채우는 대상 | 추론만으로 충분한 설명 |
| `agents/` | Codex `agents/openai.yaml` 같은 런타임 metadata, UI 카드, 의존성 힌트 | 핵심 지시를 대신하려고 |

[`references/resource-placement.ko.md`](references/resource-placement.ko.md)를 읽습니다. 배치 기준의 **canonical** 서술은 그 파일에 있고, 이 절은 요약입니다.

## Trigger 설계 규칙

- `description` 첫 문장에 가장 중요한 사용 순간과 키워드를 둡니다.
- "X를 도와준다" 같은 일반적인 설명을 피하고 "사용자가 ...를 요청할 때" 형태로 씁니다.
- 3인칭으로 씁니다. 설명은 시스템 프롬프트에 주입되므로 "제가 도와드릴 수 있습니다"처럼 시점이 흔들리면 선택 정확도가 떨어집니다.
- 실제 사용자 문장을 positive, negative, boundary case로 나눕니다.
- should-trigger와 should-not-trigger를 모두 시험합니다.
- 지나치게 넓은 skill은 오탐을 만들고, 지나치게 좁은 skill은 여러 skill이 한꺼번에 로드되어 충돌할 수 있습니다.

[`references/trigger-design.ko.md`](references/trigger-design.ko.md)를 읽습니다. 트리거 완료 기준의 **canonical** 서술은 그 파일에 있고, 위 checklist는 그것을 다시 적지 않습니다.

## Progressive disclosure 규칙

1. Discovery: skill 목록에는 `name`, `description`, 경로만 실린다고 가정합니다.
2. Activation: 과제가 맞을 때만 `SKILL.md` 전체가 로드된다고 가정합니다.
3. Execution: 참조 파일, 스크립트, asset은 명시한 조건에서만 읽거나 실행되도록 설계합니다.

요약하면 항상 필요한 자료만 `SKILL.md`에 둡니다. 세부 내용은 "언제 읽는지"와 함께 분리합니다. 자세한 규칙은 [`references/progressive-disclosure.ko.md`](references/progressive-disclosure.ko.md)를 읽습니다.

## 패키지를 바꾸는 런타임 차이

폴더 형식은 공유되지만 주변 장치는 공유되지 않습니다. Skill이 이식 가능하다고 말하기 전에 다음을 확인합니다.

| 런타임 | 탐색 | 패키지를 바꾸는 것 |
|---|---|---|
| Agent Skills spec | client가 결정 | Frontmatter 여섯 필드만 정의되고, 나머지는 동작이 정의되지 않음 |
| Claude Code | enterprise, 개인, 프로젝트, 중첩, 추가 디렉터리, plugin 단계의 `.claude/skills/` | 추가 frontmatter가 여럿 있고 목록 예산이 컨텍스트 1%임. claude.ai 업로드와 Skills API는 비-spec 필드를 hard error로 거부 |
| Codex | CWD에서 저장소 루트까지의 `.agents/skills`, `$HOME/.agents/skills`, `/etc/codex/skills`, 번들 | UI·호출 정책·도구 의존성을 담는 `agents/openai.yaml`, 활성화를 다루는 `[[skills.config]]`와 `[skills.bundled]` |
| Vercel `npx skills` | 각 agent의 디렉터리에 쓰고, 다수가 `.agents/skills/`를 공유 | 파일 자체는 그대로이고 설치 경로만 agent마다 다름 |

필드 전체 목록, 목록 예산, 탐색 순서는 [`references/skill-anatomy.ko.md`](references/skill-anatomy.ko.md) §2와 [`references/progressive-disclosure.ko.md`](references/progressive-disclosure.ko.md) §7에 있습니다. 이 표는 배포 전에 그 차이를 알아차리게 하려고 둡니다.

결론은 두 가지입니다. 트리거와 workflow는 spec의 여섯 필드만으로 읽히게 유지하고(SK-P-3), 런타임별 지시에는 어느 런타임의 것인지 밝혀 다른 client의 독자가 해당되지 않음을 알 수 있게 합니다.

## Judgement Rules

확률적 검사를 어떻게 gate로 바꾸는지 정합니다. 아래 규칙은 규범이며 `references/` 파일이 이를 적용합니다.

- SK-J-1: 한 번의 실행으로 트리거 판정을 선언하지 않습니다. 질의마다 여러 번 실행해 **trigger rate**를 계산합니다.
- SK-J-2: 시작 반복 횟수는 질의당 **3회**입니다.
- SK-J-3: should-trigger 질의는 trigger rate가 threshold보다 **높을 때** 통과하고, should-not-trigger 질의는 **낮을 때** 통과합니다. 기본 threshold는 **0.5**입니다.
- SK-J-4: case 수와 반복 횟수를 **함께** 기록합니다. 예를 들어 질의 20개 x 3회 = 60회 호출입니다. 반복 횟수가 빠진 비율은 해석할 수 없습니다.
- SK-J-5: trigger rate는 반복 횟수에 의존하므로, 다른 반복 횟수에서 나온 결과를 이전 결과와 직접 비교하지 않습니다.
- SK-J-6: case별 통과/실패만 기록하지 않습니다. trigger rate의 **분포**를 남깁니다. threshold 근처에 몰린 질의가 불안정 지점입니다.

`SK-J-2`와 `SK-J-3`의 값은 출처가 직접 밝힌 값이며, 출처도 이를 합리적인 시작점과 합리적인 기본값이라고 부를 뿐 검증된 최적값이라고 하지 않습니다. case 파일은 기본값을 상속하지 않고 자기 `runs`와 `threshold`를 적어, 쓰이는 자리에서 숫자가 보이게 합니다.

## 검증 기준

완료 전 최소 확인 항목입니다.

- [ ] `name`이 kebab-case이고 폴더 이름과 일치합니다.
- [ ] `description`이 무엇을 하는지와 언제 쓰는지를 모두 담습니다.
- [ ] 트리거 예시가 positive, negative, boundary를 모두 덮습니다. case 수는 여기서 고정하지 않습니다. 세트 구성은 [`references/validation.ko.md`](references/validation.ko.md)가, case 판정 방식은 [`references/trigger-design.ko.md`](references/trigger-design.ko.md)가 소유합니다.
- [ ] `instruction_contract`에 intent, scope, authority, evidence, tools, loop, output, verification, stop condition이 있습니다.
- [ ] Loop가 있으면 feedback 출처, metric/rubric, guard, stop condition이 있습니다.
- [ ] 최신성·벤더·논문·보안 주장에 출처 URL과 확인일 또는 스냅샷 날짜가 있습니다.
- [ ] prompt injection, credential, destructive/network/production side effect 경계가 있습니다.
- [ ] 지원 파일을 `SKILL.md`에서 상대 경로로 직접 참조합니다.
- [ ] 스크립트가 있으면 의존성, 사용법, 기대 출력, 실패 처리를 문서화했습니다.
- [ ] 런타임 전용 frontmatter에 런타임을 밝혔고 그것이 없어도 동작합니다(SK-P-3).
- [ ] 로컬 markdown 링크와 code fence가 깨지지 않았습니다.
- [ ] 검증 결과와 남은 위험을 인계 기록에 남겼습니다.

자세한 검증 loop는 [`references/validation.ko.md`](references/validation.ko.md)를 읽습니다. 이 기준은 *무엇이* 성립해야 하는지의 canonical 서술이고, 각 항목을 어떻게 확인하는지는 그 파일에 있습니다.

## 관련 문서

- [`../context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md)
- [`../context-engineering/references/prompt-authoring.md`](../context-engineering/references/prompt-authoring.md)
- [`references/prompt-loop-eval.ko.md`](references/prompt-loop-eval.ko.md)
- [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md)
- [`../sourcing/reliable-search.md`](../sourcing/reliable-search.md)
- [`../sourcing/references/retrieval-safety.md`](../sourcing/references/retrieval-safety.md)
- [`../validation/index.md`](../validation/index.md)

## Sources

> 아래 링크는 모두 다시 읽고 확인 2026-11-03. 출처가 발행일을 밝히는 경우 함께 적었습니다.

| 주장 | 출처 |
|---|---|
| `name`과 `description` 제약, 선택 필드, 3단계 progressive disclosure 예산 | <https://agentskills.io/specification> |
| "취약도에 맞춘 구체성"과 원칙 10의 삭제 판단 질문 | <https://agentskills.io/skill-creation/best-practices> |
| **trigger rate**, **3회**, **0.5** threshold, 그리고 `SK-J-2`·`SK-J-3`의 "합리적인 시작점/기본값" 단서 | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| with/without 기준선을 핵심 eval 패턴으로 두는 것, 실행별 비용 기록 | <https://agentskills.io/skill-creation/evaluating-skills> |
| 컨텍스트 2%/8,000자 목록 예산, `skills.max_context_tokens`, `.agents/skills` 탐색, user/admin/system 범위, 같은 `name` 비병합, symlink 추적, `[[skills.config]]`, `agents/openai.yaml`, `/skills`·`$` 호출, plugin 권장 | <https://learn.chatgpt.com/docs/build-skills> |
| skill 위치, `/skill-name` 호출, 통합된 command 형식, 컨텍스트 1% 목록 예산, 항목당 1,536자 제한, Claude Code frontmatter 확장 목록 | <https://code.claude.com/docs/en/skills> |
| 약 100토큰 metadata, 5k 토큰 본문 권장, 예약어 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| API 요청당 20개 제한 | <https://platform.claude.com/docs/en/build-with-claude/skills-guide> |
| 버전 고정, 업데이트 시 재검토, rollback, checksum, 표면 간 비동기화 경고 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> |
| `npx skills` 명령 집합, 지원 agent 수, 공통 `.agents/skills/` 프로젝트 경로, Node 22.20 요구 | <https://github.com/vercel-labs/skills> |
| 98개 중 92개 무효과, 76.6%에서 76.9%, 도움이 되는 skill과 해로운 skill의 실패 양상 | <https://arxiv.org/abs/2603.15401> |
| skill을 versioned bundle로 보는 관점, prompt injection·exfiltration 경고 | <https://developers.openai.com/api/docs/guides/tools-skills> |
| progressive disclosure를 핵심 설계 원리로 두는 것, 신뢰할 수 없는 skill 감사 규칙(발행 2025-10-16) | <https://www.anthropic.com/research/equipping-agents-for-the-real-world-with-agent-skills> |
| outcome/process/style/efficiency eval 축과 10~20개 프롬프트 시작 세트 | <https://developers.openai.com/blog/eval-skills> |

### 근거 등급

트리거 판정 값은 출처가 시작점으로 밝힌 것이지 검증된 최적값이 아닙니다. 런타임별 사실은 각 벤더가 자기 제품에 대해 밝힌 `VENDOR` 주장이며, 보편 규칙이 아니라 해당 런타임 이름과 함께 적었습니다. SWE-Skills-Bench는 2026년 벤치마크 하나의 결과이고, 그 결론은 자체 통계 검정과 함께 제시된 것이지 모든 skill에 적용되는 법칙이 아닙니다.
