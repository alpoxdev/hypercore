# Instructions Base

이 폴더는 이 프로젝트의 LLM 작업 베이스 문서층이다. 목적은 Codex, Claude Code, Cursor, GitHub Copilot 같은 에이전트가 같은 프로젝트 의도와 검증 기준을 이해하고 일관되게 작업하도록 만드는 것이다.

## 역할

| 영역 | 파일 | 목적 |
|---|---|---|
| Context Engineering | [`context-engineering/CONTEXT_ENGINEERING.md`](context-engineering/CONTEXT_ENGINEERING.md) | 프롬프트/컨텍스트/도구 지시를 런타임 중립적으로 설계 |
| Harness Engineering | [`harness-engineering/HARNESS_ENGINEERING.md`](harness-engineering/HARNESS_ENGINEERING.md) | 프롬프트, 에이전트, 도구 사용을 테스트 가능한 하네스로 관리 |
| Sourcing | [`sourcing/reliable-search.md`](sourcing/reliable-search.md) | 자료조사·검색·출처 검증 기준 |
| Validation | [`validation/index.md`](validation/index.md) | 작업 완료 전 검증 기준 |

## 작성 원칙

1. **런타임 중립**: 특정 모델/벤더 전용 규칙은 provider profile로 분리한다.
2. **명확한 우선순위**: 항상 scope, authority, required/forbidden, verification을 분리한다.
3. **하네스 우선**: 중요한 instruction 변경은 예시 3개보다 eval case 10개가 낫다.
4. **소스 기반**: 최신성·도구 동작·보안 주장은 공식 문서/표준/논문을 우선한다.
5. **짧은 루트, 깊은 reference**: 상위 문서는 200-300줄 이내로 유지하고 세부는 `references/`로 분리한다.

## 권장 로딩 순서

```markdown
@instructions/README.md
@instructions/context-engineering/CONTEXT_ENGINEERING.md
@instructions/harness-engineering/HARNESS_ENGINEERING.md
@instructions/sourcing/reliable-search.md
@instructions/validation/index.md
```

작업이 특정 런타임에 묶이면 [`context-engineering/references/runtime-profiles.md`](context-engineering/references/runtime-profiles.md)를 추가로 읽는다. 병렬 작업, subagent, background agent, agent team을 사용할 때는 [`context-engineering/references/parallel-workflows.md`](context-engineering/references/parallel-workflows.md)를 함께 읽는다.
