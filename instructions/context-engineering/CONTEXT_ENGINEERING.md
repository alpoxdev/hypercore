# Context Engineering

Codex, Claude Code, Cursor, GitHub Copilot 등 여러 에이전트 런타임이 같은 의도로 작업하도록 instruction, context, tools, memory, validation을 설계하는 기준이다.

## 핵심 정의

Context engineering은 “좋은 문장으로 프롬프트를 꾸미는 일”이 아니라, 모델이 작업을 수행할 때 받는 **목표, 범위, 근거, 도구, 제약, 검증 기준**을 실행 가능한 시스템으로 설계하는 일이다. 역할 프롬프트도 마찬가지로 페르소나 선언이 아니라, 역할이 책임져야 할 성공 기준과 검증 가능한 행동 계약이어야 한다.

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

XML 태그는 Claude 계열에서 특히 유용하지만, 핵심은 XML 자체가 아니라 **구획 분리**다. Codex/AGENTS.md, Cursor Rules, Copilot instructions에서는 Markdown heading과 표로 같은 구조를 표현해도 된다.


## Prompt Authoring Contract

역할 수행 프롬프트는 아래 순서로 작성한다. 세부 템플릿은 [`references/prompt-authoring.md`](references/prompt-authoring.md)를 따른다.

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
| 런타임별 instruction 파일 배치/우선순위 | [`references/runtime-profiles.md`](references/runtime-profiles.md) |
| 역할 수행 프롬프트 템플릿 | [`references/prompt-authoring.md`](references/prompt-authoring.md) |
| 추론, few-shot, structured output, tool-use 기법 | [`references/techniques.md`](references/techniques.md) |
| 추상화 수준과 컨텍스트 예산 | [`references/core-principles.md`](references/core-principles.md) |
| 병렬 작업/서브에이전트 위임 | [`references/parallel-workflows.md`](references/parallel-workflows.md) |
| prompt/eval 하네스 | [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md) |

## Sources

- OpenAI Codex instruction aggregation and AGENTS.md behavior
- Anthropic prompt engineering, XML tags, Claude Code subagents/agent teams guidance
- Google Gemini prompt design strategies
- Cursor Rules and Memories
- GitHub Copilot repository/path/agent instructions
- MCP specification security and prompt/tool boundaries
- OpenAI, Anthropic, Google, LangSmith, Promptfoo evaluation guidance
- `.hypercore/research/2026-06-02-official-llm-prompt-instructions-update.md`
