# Context Engineering

> 영어판: [`CONTEXT_ENGINEERING.md`](CONTEXT_ENGINEERING.md)

Codex, Claude Code, Cursor, GitHub Copilot 등 여러 에이전트 런타임이 같은 의도로 작업하도록 instruction, context, tools, memory, validation을 설계하는 기준이다.

## 핵심 정의

Context engineering은 “좋은 문장으로 프롬프트를 꾸미는 일”이 아니라, 모델이 작업을 수행할 때 받는 **목표, 범위, 근거, 도구, 제약, 검증 기준**을 실행 가능한 시스템으로 설계하는 일이다. 역할 프롬프트도 마찬가지로 페르소나 선언이 아니라, 역할이 책임져야 할 성공 기준과 검증 가능한 행동 계약이어야 한다.

Anthropic은 이를 “추론 중에 최적의 토큰 집합을 선별하고 유지하는 전략의 모음”이라고 정의하고, “프롬프트 엔지니어링의 자연스러운 다음 단계”라고 부른다(2025-09-29 발행, 2026-10-18 갱신, 확인 2026-11-03). 분량 기준은 “기대하는 동작을 온전히 규정하는 최소한의 정보”이며, “최소가 반드시 짧다는 뜻은 아니다”라는 단서가 붙는다. Chroma는 그 경험적 근거를 제공한다. 네 계열 모델 18종에서 작업 난이도를 고정해도 입력 길이가 늘면 성능이 떨어졌다. 컨텍스트 크기는 비용 변수이면서 품질 변수다([`references/core-principles.ko.md`](references/core-principles.ko.md) 2절).

## Core Contract

| 섹션 | 반드시 적을 것 | 피할 것 |
|---|---|---|
| Intent | 사용자가 성공으로 보는 결과와 실패로 보는 결과 | 페르소나/과장된 역할놀이 |
| Scope | 읽기/수정/생성 가능한 범위 | “관련된 것 전부” 같은 무제한 범위 |
| Authority | 지시 우선순위와 충돌 해소 | 사용자·프로젝트·도구 지시 혼합 |
| Evidence | 어떤 근거를 신뢰할지 | 검색 snippet/LLM 답변을 1차 출처처럼 사용 |
| Tools | 언제 어떤 도구를 쓰고 멈출지, 병렬 위임 시 소유권/검증 책임 | 모델이 존재하지 않는 도구를 상상하게 하기 |
| Output | 산출물 형식, 파일 위치, 언어/톤, 완료 기준 | “좋게 정리” 같은 모호한 완료 조건 |
| Verification | 테스트/eval/리뷰/source-check 기준 | 검증 없는 완료 선언 |
| Iteration | prompt 버전, 실패 사례, 변경 이유 | 좋아 보이는 문장 다듬기만 반복 |

## Context Lifecycle

계약은 한 턴을 지배한다. 긴 작업에는 LangChain이 이름 붙인 네 가지 수단이 함께 필요하다. write, select, compress, isolate다(확인 2026-11-03). 실행이 나빠지는데 모델 탓이 아닐 때 이 목록으로 점검한다.

| 수단 | 하는 일 | 구체적 방법 | 빠뜨리면 |
|---|---|---|---|
| Write | 상태를 창 밖으로 옮겨 잘림을 견디게 한다 | 노트, 스펙 파일, 할 일 목록, 외부 메모리 디렉터리, 산출물 경로 | 창이 잘리는 순간 계획이 사라진다 |
| Select | 이번 단계에 필요한 것만 들인다 | 필요할 때 읽는 참조, 좁은 도구 집합, 표적 검색 | 신호가 약한 토큰이 중요했던 규칙을 밀어낸다 |
| Compress | 뜻은 남기고 토큰은 줄인다 | 서버 측 압축, 요약 인계, 도구 결과 비우기 | 비용과 지연이 오르고 정확도는 떨어진다 |
| Isolate | 작업자나 샌드박스별로 나눈다 | 자체 창을 가진 서브에이전트가 요약만 반환, 샌드박스가 결과만 반환 | 한 작업자의 장황한 출력이 이후 모든 판단을 오염시킨다 |

런타임과 무관하게 지키는 규칙:

1. **요약보다 이동이 먼저다.** 다시 만들 수 있는 것(도구 출력, 파일 덤프)은 비우거나 옮기고, 다시 만들 수 없는 것만 요약한다.
2. **권위 있는 계획은 창 밖에 둔다.** 그리고 압축이 끝날 때마다 다시 읽는다. 계획의 요약은 계획이 아니다.
3. **인계는 요약과 경로다.** 트랜스크립트가 아니다. 받는 쪽이 근거를 다시 열 수 있어야 한다.
4. **발동 지점을 기록한다.** 무엇이 임계값을 넘었고, 무엇이 버려졌고, 무엇을 다시 읽어야 했는지 남긴다. 그래야 잃은 사실과 틀린 사실을 구분할 수 있다.
5. **이력 재작성보다 도구 결과 비우기를 먼저 한다.** 가장 가벼운 압축이고, 어떤 도구가 실행됐는지 기록은 남는다.

벤더별 파라미터와 임계값, 모델 제외 조건은 [`references/context-management.ko.md`](references/context-management.ko.md)에 있다. 지시문 쪽 대응물(안정적인 캐시 접두부와 변동 꼬리)은 [`../cache/CACHE.ko.md`](../cache/CACHE.ko.md)에 있다.

## Runtime-Neutral Pattern

```xml
<task_contract>
  <intent>무엇을 달성해야 하는가</intent>
  <scope>대상 파일/시스템/사용자 영향 범위</scope>
  <authority>충돌 시 우선할 지시와 금지할 추정</authority>
  <evidence>신뢰할 자료 채널과 출처 등급</evidence>
  <workflow>탐색 → 계획 → 실행 → 검증 → 보고</workflow>
  <tools>사용 가능한 도구와 side effect 제한</tools>
  <verification>완료를 증명할 테스트/eval/리뷰</verification>
  <output>최종 산출물 형식</output>
</task_contract>
```

XML 태그는 Claude 계열의 문서화된 기본값으로 남아 있다. 현행 지침은 XML 태그가 “복잡한 프롬프트를 모호함 없이 해석하도록” 돕는다고 적고(확인 2026-11-03), 에이전트 지침은 프롬프트를 XML 태그나 Markdown 헤더로 구획하도록 권하면서 다만 “모델이 더 유능해지면서 형식의 정확한 모양은 점점 덜 중요해질 것”이라고 덧붙인다. 핵심은 XML 자체가 아니라 **구획 분리**다. Codex/AGENTS.md, Cursor Rules, Copilot instructions에서는 Markdown heading과 표로 같은 구조를 표현해도 된다.


## Prompt Authoring Contract

역할 수행 프롬프트는 아래 순서로 작성한다. 세부 템플릿은 [`references/prompt-authoring.ko.md`](references/prompt-authoring.ko.md)를 따른다.

1. **Intent**: 사용자가 성공으로 보는 결과와 실패로 보는 결과.
2. **Role as responsibility**: 역할명보다 책임, 판단 기준, 금지 행동.
3. **Scope / Non-goals**: 읽기·수정·생성·외부 행동 범위와 제외 대상.
4. **Authority**: instruction 우선순위와 tool/web/retrieved content의 증거 경계.
5. **Context packet**: source, date, trust grade, 누락 정보.
6. **Workflow**: 탐색, 계획, 실행, 검증, 보고 또는 task-specific 분해.
7. **Output contract**: 형식, 필수 필드, 언어, 저장 위치.
8. **Verification**: smoke eval, source-check, deterministic assertion, human review 중 무엇으로 통과를 증명하는지.

## Instruction Layers

| Layer | 예시 | 내용 | 원칙 |
|---|---|---|---|
| Project root | `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` | 프로젝트 공통 규칙 | 짧고 강하게 |
| Instructions base | `instructions/**` | 공통 방법론, 검증, 소싱 | reference로 JIT 로딩 |
| Runtime rules | `.cursor/rules`, Codex config, Claude memory | 도구별 동작 차이 | 중복 최소화 |
| Skill/command | `skills/**/SKILL.md`, slash command | 특정 작업 워크플로 | 좁고 실행 가능하게 |
| Task prompt | 현재 사용자 요청 | 최신 우선순위와 구체 요구 | 이전 규칙과 충돌하면 명시적으로 해소 |

## 좋은 Instruction의 기준

- **측정 가능**: “잘” 대신 pass/fail 기준을 둔다.
- **실행 가능**: 에이전트가 바로 할 수 있는 동사로 쓴다.
- **범위 명확**: 대상 디렉터리, 파일, 산출물 위치가 있다.
- **충돌 안전**: destructive/external/credential-gated 행동은 중단 조건을 둔다.
- **검증 가능**: lint/typecheck/test/eval/source-check 중 무엇이 증명인지 적는다.
- **모델 중립**: vendor-specific 기능은 runtime profile에만 둔다.

## Anti-Patterns

| Anti-pattern | 문제 | 대체 |
|---|---|---|
| Persona stacking | 실제 품질 기준 없이 토큰만 증가 | 역할을 책임·범위·검증 기준으로 번역 |
| CRITICAL 남발 | 중요도 신호가 무뎌짐 | truly blocking rule만 강조 |
| 모든 edge case 나열 | 컨텍스트 낭비와 충돌 증가 | 원칙 + 대표 예시 + 검증 루프 |
| 숨은 가정 | 에이전트가 보수적/과잉 작업 | scope와 stop condition 명시 |
| 도구명 하드코딩 | 다른 런타임에서 실패 | “best available doc/fetch tool”처럼 capability로 표현 |
| 검증 없는 prompt 개선 | 좋아 보이나 회귀 가능 | harness/eval case로 비교 |

## When To Load References

| 필요 | 추가 문서 |
|---|---|
| 런타임별 instruction 파일 배치/우선순위 | [`references/runtime-profiles.ko.md`](references/runtime-profiles.ko.md) |
| 역할 수행 프롬프트 템플릿 | [`references/prompt-authoring.ko.md`](references/prompt-authoring.ko.md) |
| 추론, few-shot, structured output, tool-use 기법 | [`references/techniques.ko.md`](references/techniques.ko.md) |
| 추상화 수준과 컨텍스트 예산 | [`references/core-principles.ko.md`](references/core-principles.ko.md) |
| 압축, 도구 결과 비우기, 메모리, 런타임별 컨텍스트 파라미터 | [`references/context-management.ko.md`](references/context-management.ko.md) |
| 병렬 작업/서브에이전트 위임 | [`references/parallel-workflows.ko.md`](references/parallel-workflows.ko.md) |
| prompt/eval 하네스 | [`../harness-engineering/HARNESS_ENGINEERING.ko.md`](../harness-engineering/HARNESS_ENGINEERING.ko.md) |
| 반복 실행, 중단 조건, 예산, 에스컬레이션 | [`../loop-engineering/LOOP_ENGINEERING.ko.md`](../loop-engineering/LOOP_ENGINEERING.ko.md) |
| 분산·수렴 구조, 결합 방식, 영속 그래프 상태 | [`../graph-engineering/GRAPH_ENGINEERING.ko.md`](../graph-engineering/GRAPH_ENGINEERING.ko.md) |

## Sources

> 2026-11-03 표기가 붙은 주장은 그날 다시 읽었다. 더 이른 확인 날짜가 남은 행은 이번 개정에서 다시 읽지 않았으므로, 새 날짜를 물려주지 않고 원래 날짜를 유지한다.

| 주장 | 출처 | 확인 |
|---|---|---|
| “최적의 토큰 집합을 선별하고 유지하는” 컨텍스트 엔지니어링 정의, 최소 집합 기준, right altitude, 압축, 노트 필기, 서브에이전트 압축 | <https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> | 2026-11-03(2025-09-29 발행, 2026-10-18 갱신) |
| XML 태그, 긴 문서 먼저, 질의는 마지막, Claude 4.6 이후 프리필 미지원 | <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices> | 2026-11-03 |
| 컨텍스트 편집과 도구 결과 비우기 파라미터 | <https://platform.claude.com/docs/en/build-with-claude/context-editing> | 2026-11-03 |
| 압축 방식과 모델 제외 조건 | <https://platform.claude.com/docs/en/build-with-claude/compaction> | 2026-11-03 |
| `context_management`·`compact_threshold` 기반 압축 | <https://developers.openai.com/api/docs/guides/compaction> | 2026-11-03 |
| 6단계 지시 위계, 신뢰할 수 없는 데이터는 “기본 권한이 없다” | <https://model-spec.openai.com/2026-10-29.html> | 2026-11-03 |
| 입력 길이가 늘면 모델 18종의 성능이 떨어지고, 방해 문서는 하락을 키운다 | <https://www.trychroma.com/research/context-rot> | 2026-11-03(2025-07-14 발행) |
| 네 가지 수단: write, select, compress, isolate | <https://www.langchain.com/blog/context-engineering-for-agents> | 2026-11-03(2025-07-02 발행) |
| 멀티 에이전트 토큰 배수와 공유 컨텍스트의 한계 | <https://www.anthropic.com/research/multi-agent-research-system> | 2026-11-03(2025-06-13 발행) |
| Codex instruction 집계와 AGENTS.md 동작 | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> | 2026-07-29 |
| AGENTS.md 포맷과 중첩 우선순위(“가장 가까운 파일이 이김, 사용자 채팅 지시가 최상위”). Linux Foundation 산하 Agentic AI Foundation이 관리 | <https://agents.md/> | 2026-07-29 |
| Claude Code subagents / agent teams | <https://code.claude.com/docs/en/sub-agents>, <https://code.claude.com/docs/en/agent-teams> | 2026-07-29 |
| Google 프롬프트 설계 전략(맥락 먼저, 지시 마지막, few-shot) | <https://aistudio.google.com/docs/prompting-strategies> | 2026-11-04 |
| Cursor Rules(Always Apply / Apply Intelligently / Apply to Specific Files / Apply Manually), 중첩 `AGENTS.md`, Memories 기능은 문서에 없음 | <https://cursor.com/docs/rules> | 2026-11-03 |
| GitHub Copilot repository / path-specific(`applyTo`) / agent instructions와 우선순위(personal > repository > organization) | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 2026-07-29 |
| MCP 보안 원칙과 prompt/tool 경계. tool annotation은 신뢰할 수 있는 서버가 아니면 untrusted로 간주해야 한다(MUST) | <https://modelcontextprotocol.io/specification/2026-07-28> | 2026-09-19 |
| MCP `2026-07-28` breaking change(stateless 전환, `server/discover`, MRTR, Roots·Sampling·Logging deprecation) | <https://modelcontextprotocol.io/specification/2026-07-28/changelog> | 2026-09-19 |
| OpenAI evaluation 지침. Evals 플랫폼은 **폐기 예정**(2026-10-31 read-only, 2026-11-30 종료, 후속은 Datasets)이고 agent-evals 지침은 현재 유효하다 | <https://developers.openai.com/api/docs/guides/evals>, <https://developers.openai.com/api/docs/guides/agent-evals> | 2026-07-29 |
| Anthropic 성공 기준 정의와 eval 구축 | <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests> | 2026-07-29 |
| Google Vertex Gen AI evaluation adaptive rubrics | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/evaluation-overview?hl=en> | 2026-07-29 |
| LangSmith evaluation datasets/evaluators | <https://docs.langchain.com/langsmith/evaluation> | 2026-07-29 |
| Promptfoo LLM-as-a-judge / red teaming | <https://www.promptfoo.dev/docs/guides/llm-as-a-judge/>, <https://www.promptfoo.dev/docs/red-team/> | 2026-07-29 |

**정정**: 이전 판은 Cursor의 “Memories”를 instruction 표면으로 적었다. Cursor Rules 문서에는 그런 기능이 없으므로 런타임 프로필에서도 그 주장을 뺐다. Gemini API 프롬프트 안내는 이제 `aistudio.google.com/docs/prompting-strategies`에서 응답하며(`ai.google.dev` 경로가 그쪽으로 301 리다이렉트된다), 표에는 그 최종 URL을 적는다.

로컬 재검증 노트는 `.hyper/research/` 아래 미추적 파일로 둔다. `.gitignore`가 저장소에서 빼므로 다른 clone에는 없다. 반면 `.hyper/`에는 추적 중인 파일도 있어 디렉터리 자체는 clone에 존재한다. 위 URL이 근거이며 로컬 노트가 이를 대체하지 않는다.
