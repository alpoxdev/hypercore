# Instructions Base

이 폴더는 이 프로젝트의 LLM 작업 베이스 문서층이다. 목적은 Codex, Claude Code, Cursor, GitHub Copilot 같은 에이전트가 같은 프로젝트 의도와 검증 기준을 이해하고 일관되게 작업하도록 만드는 것이다.

## 역할

| 영역 | 파일 | 목적 |
|---|---|---|
| Context Engineering | [`context-engineering/CONTEXT_ENGINEERING.md`](context-engineering/CONTEXT_ENGINEERING.md) | 프롬프트/컨텍스트/도구 지시를 런타임 중립적으로 설계 |
| Prompt Authoring | [`context-engineering/references/prompt-authoring.md`](context-engineering/references/prompt-authoring.md) | 역할 수행 프롬프트를 실행 계약으로 작성하는 실전 템플릿 |
| Skill Authoring | [`skill/SKILL_AUTHORING.md`](skill/SKILL_AUTHORING.md) | 재사용 가능한 skill 폴더를 트리거·구조·검증 가능한 실행 패키지로 설계 |
| Skill Prompt/Loop/Eval | [`skill/references/prompt-loop-eval.md`](skill/references/prompt-loop-eval.md) | skill을 단일 프롬프트가 아니라 반복·검증 가능한 작은 프로그램으로 설계 |
| Autoresearch | [`autoresearch/AUTORESEARCH.md`](autoresearch/AUTORESEARCH.md) | 목표·범위·측정·검증·가드·로그·rollback 기반 자율 반복 하네스 설계 |
| Harness Engineering | [`harness-engineering/HARNESS_ENGINEERING.md`](harness-engineering/HARNESS_ENGINEERING.md) | 프롬프트, 에이전트, 도구 사용을 테스트 가능한 하네스로 관리 |
| Sourcing | [`sourcing/reliable-search.md`](sourcing/reliable-search.md) | 자료조사·검색·출처 검증 기준 |
| Validation | [`validation/index.md`](validation/index.md) | 작업 완료 전 검증 기준 |

## 작성 원칙

1. **런타임 중립**: 특정 모델/벤더 전용 규칙은 provider profile로 분리한다.
2. **명확한 우선순위**: 항상 scope, authority, required/forbidden, verification을 분리한다.
3. **하네스 우선**: 중요한 instruction 변경은 예시 3개보다 eval case 10개가 낫다.
4. **역할보다 계약**: 역할 프롬프트는 페르소나보다 intent, scope, authority, context, output, verification을 먼저 고정한다.
5. **소스 기반**: 최신성·도구 동작·보안 주장은 공식 문서/표준/논문을 우선한다.
6. **짧은 루트, 깊은 reference**: 상위 문서는 200-300줄 이내로 유지하고 세부는 `references/`로 분리한다.

## 권장 로딩 순서

```markdown
@instructions/README.md
@instructions/context-engineering/CONTEXT_ENGINEERING.md
@instructions/context-engineering/references/prompt-authoring.md
@instructions/skill/SKILL_AUTHORING.md
@instructions/skill/references/prompt-loop-eval.md
@instructions/autoresearch/AUTORESEARCH.md
@instructions/harness-engineering/HARNESS_ENGINEERING.md
@instructions/sourcing/reliable-search.md
@instructions/validation/index.md
```

작업이 특정 런타임에 묶이면 [`context-engineering/references/runtime-profiles.md`](context-engineering/references/runtime-profiles.md)를 추가로 읽는다. 병렬 작업, subagent, background agent, agent team을 사용할 때는 [`context-engineering/references/parallel-workflows.md`](context-engineering/references/parallel-workflows.md)를 함께 읽는다.


Skill을 새로 만들거나 `skills/*`를 refactor할 때는 [`skill/SKILL_AUTHORING.md`](skill/SKILL_AUTHORING.md)를 읽고, prompt/loop/eval 설계가 필요하면 [`skill/references/prompt-loop-eval.md`](skill/references/prompt-loop-eval.md)를 함께 읽는다. 필요에 따라 `skill/references/`의 anatomy, trigger, progressive disclosure, resource placement, validation 문서를 추가로 읽는다.

Autoresearch-style 반복 개선, metric optimization, autonomous debug/fix/learn/reason loop를 설계할 때는 [`autoresearch/AUTORESEARCH.md`](autoresearch/AUTORESEARCH.md)를 읽고, metric/verify/guard/log/rollback 기준에 따라 `autoresearch/references/`를 추가로 읽는다.

리서치·최신성·출처 추적이 중요한 작업은 [`sourcing/reliable-search.md`](sourcing/reliable-search.md)를 먼저 읽고, source ledger/citation/freshness가 필요하면 `sourcing/references/`를 추가로 읽는다. 완료 주장, eval, agent/tool 검증이 중요한 작업은 [`validation/index.md`](validation/index.md)와 `validation/references/`를 함께 읽는다.
