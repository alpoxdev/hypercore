# Instructions Base

이 폴더는 이 프로젝트의 LLM 작업 베이스 문서층이다. 목적은 Codex, Claude Code, Cursor, GitHub Copilot 같은 에이전트가 같은 프로젝트 의도와 검증 기준을 이해하고 일관되게 작업하도록 만드는 것이다.

> 영어판: [`README.md`](README.md). 이 베이스의 모든 문서는 쌍으로 관리한다 — `X.md`가 영어, `X.ko.md`가 한국어이며 `skills/`에서 이미 쓰는 관례와 동일하다. 한쪽을 고치면 반대쪽도 함께 맞춘다.

## 역할

| 영역 | 파일 | 목적 |
|---|---|---|
| Context Engineering | [`context-engineering/CONTEXT_ENGINEERING.ko.md`](context-engineering/CONTEXT_ENGINEERING.ko.md) | 프롬프트/컨텍스트/도구 지시를 런타임 중립적으로 설계 |
| Prompt Authoring | [`context-engineering/references/prompt-authoring.ko.md`](context-engineering/references/prompt-authoring.ko.md) | 역할 수행 프롬프트를 실행 계약으로 작성하는 실전 템플릿 |
| Prompt & Skill Caching | [`cache/CACHE.ko.md`](cache/CACHE.ko.md) | 프롬프트·스킬의 재사용 접두부를 안정적으로 유지해 프로바이더 프롬프트 캐시가 재사용하게 한다 |
| AGENTS.md / CLAUDE.md | [`agents-md/AGENTS_MD.ko.md`](agents-md/AGENTS_MD.ko.md) | 저장소 에이전트 instruction 파일을 작고 근거 있고 이식 가능한 계약으로 작성 |
| Skill Authoring | [`skill/SKILL_AUTHORING.ko.md`](skill/SKILL_AUTHORING.ko.md) | 재사용 가능한 skill 폴더를 트리거·구조·검증 가능한 실행 패키지로 설계 |
| Skill Prompt/Loop/Eval | [`skill/references/prompt-loop-eval.ko.md`](skill/references/prompt-loop-eval.ko.md) | skill을 단일 프롬프트가 아니라 반복·검증 가능한 작은 프로그램으로 설계 |
| Autoresearch | [`autoresearch/AUTORESEARCH.ko.md`](autoresearch/AUTORESEARCH.ko.md) | 목표·범위·측정·검증·가드·로그·rollback 기반 자율 반복 하네스 설계 |
| Harness Engineering | [`harness-engineering/HARNESS_ENGINEERING.ko.md`](harness-engineering/HARNESS_ENGINEERING.ko.md) | 프롬프트, 에이전트, 도구 사용을 테스트 가능한 하네스로 관리 |
| Loop Engineering | [`loop-engineering/LOOP_ENGINEERING.ko.md`](loop-engineering/LOOP_ENGINEERING.ko.md) | 하네스 한 층 위에서 자율 에이전트 루프를 설계한다. 트리거, 작업 출처, 상태, 작성자·검증자 분리, 검증 가능한 멈춤 조건, 예산을 다룬다 |
| Graph Engineering | [`graph-engineering/GRAPH_ENGINEERING.ko.md`](graph-engineering/GRAPH_ENGINEERING.ko.md) | 다단계·다중 에이전트 작업을 노드, 간선, 상태로 이루어진 그래프로 설계하고, 그래프가 맞지 않는 경우를 가린다 |
| Harness Anatomy | [`harness-engineering/references/harness-anatomy.ko.md`](harness-engineering/references/harness-anatomy.ko.md) | 하네스를 이루는 부품과 하네스 구성 요소가 낡았는지 판단하는 기준 |
| Context Management | [`context-engineering/references/context-management.ko.md`](context-engineering/references/context-management.ko.md) | 긴 실행에서 문맥을 쓰고, 고르고, 압축하고, 격리하는 방법과 런타임별 압축·메모리 기능 |
| Context Core Principles | [`context-engineering/references/core-principles.ko.md`](context-engineering/references/core-principles.ko.md) | instruction을 쓰기 전에 정할 고도, 구체성, 우선순위 규칙 |
| Context Techniques | [`context-engineering/references/techniques.ko.md`](context-engineering/references/techniques.ko.md) | 복잡한 작업을 실행 가능한 단계로 쪼개는 분해법과 그 밖의 반복 기법 |
| Runtime Profiles | [`context-engineering/references/runtime-profiles.ko.md`](context-engineering/references/runtime-profiles.ko.md) | 공유 문서에서 빼 둔 런타임별 instruction 표면, 우선순위, 기능 차이 |
| Parallel Workflows | [`context-engineering/references/parallel-workflows.ko.md`](context-engineering/references/parallel-workflows.ko.md) | 병렬 작업과 서브에이전트의 독립성, 소유권, 격리, 통합, 검증 기준 |
| Harness Measurement | [`harness-engineering/references/measurement.ko.md`](harness-engineering/references/measurement.ko.md) | 반복·집계·컨텍스트 변수 규칙의 유도: `pass^k`, 표본 크기, 행동 평가 vs 종단 벤치마크 |
| Harness Evaluation Patterns | [`harness-engineering/references/evaluation-patterns.ko.md`](harness-engineering/references/evaluation-patterns.ko.md) | 에이전트 출력을 검사하는 결정적 단언과 그 밖의 eval 패턴 |
| Harness Evidence & Recovery | [`harness-engineering/references/evidence-and-recovery.ko.md`](harness-engineering/references/evidence-and-recovery.ko.md) | 증거·검증 비용 축소·장기 실행 복구 규칙의 작업 형태 |
| Harness Agent Security | [`harness-engineering/references/agent-security.ko.md`](harness-engineering/references/agent-security.ko.md) | 최소 보안 단언 뒤의 OWASP 에이전트 위협 목록 |
| Graph Framework Mapping | [`graph-engineering/references/framework-mapping.ko.md`](graph-engineering/references/framework-mapping.ko.md) | 다섯 런타임이 부르는 그래프 기본 요소를 문서에 적힌 범위에서 맞춘 번역표 |
| Graph as Context | [`graph-engineering/references/graph-as-context.ko.md`](graph-engineering/references/graph-as-context.ko.md) | 다음 실행을 정하는 그래프와 분리해, 콘텐츠 위에 만들어 문맥으로 읽는 그래프 |
| Graph Patterns | [`graph-engineering/references/graph-patterns.ko.md`](graph-engineering/references/graph-patterns.ko.md) | 반복되는 그래프 토폴로지와 각 패턴이 상태·엣지에 요구하는 것, 평가 방법 |
| When Not to Use Graphs | [`graph-engineering/references/when-not-to-use-graphs.ko.md`](graph-engineering/references/when-not-to-use-graphs.ko.md) | 그래프를 만들기 전에 통과할 판별 질문, 비용 모델, 더 값싼 대안 |
| Sourcing | [`sourcing/reliable-search.ko.md`](sourcing/reliable-search.ko.md) | 자료조사·검색·출처 검증 기준 |
| Validation | [`validation/index.ko.md`](validation/index.ko.md) | 작업 완료 전 검증 기준 |

## 출처 관리

외부 출처는 **URL과 확인일을 인라인으로** 적는다. `Sources` 섹션이 있는 문서는 그곳에, 없으면 claim 옆에 적는다. 저장소 유지보수 원장도 예외도 두지 않는다. claim을 인용에서 떼어 두면 둘이 어긋나고, 독자는 그 claim이 아직 유효한지 가릴 수 없다. 인용·등급·최신성 규칙은 [`sourcing/reliable-search.ko.md`](sourcing/reliable-search.ko.md)에 있다.

```bash
bash scripts/check-sources.sh             # 확인일 형식·문서 길이 strict, 링크 advisory
bash scripts/check-sources.sh --strict    # 링크 이전까지 게이트 (릴리스 전)
bash scripts/check-sources.sh --offline   # 네트워크 없이 구조 검사만
bash scripts/check-sources.sh --self-test # 검사 자체가 실패를 잡는지 증명
shellcheck scripts/*.sh scripts/lib/*.sh scripts/tests/*.sh        # 검사기 자체의 정적 분석 (shellcheck 필요)
```

shellcheck 줄은 `scripts/` 아래 bash 도구 전체에 [ShellCheck](https://www.shellcheck.net/)를 실행한다. ShellCheck는 이 저장소의 의존성이 아니라 시스템 도구이므로 opt-in으로 두고, `scripts/verify.sh`는 설치되어 있을 때만 이 검사를 실행하며 없으면 `SKIP`을 출력한다.

- 마지막 전수 확인: **2026-11-03**. 모든 영역을 Aside 브라우저로 현재 1차 출처와 다시 대조했고, 낡은 주장은 지우거나 고쳤으며, 새 영역 `loop-engineering/`과 `graph-engineering/`을 추가했다. 주장별 확인일은 각 문서에 있고, 다시 읽지 못한 행은 이전 날짜를 그대로 둔다. 다음 전수 재검증: **2027-02-03**.
- 이전 확인: 전수 확인 2026-07-29, 부분 재검증 2026-09-19와 2026-09-20.
- 링크 검사는 인라인 인용만 읽는다. 코드 블록과 RFC 2606이 문서용으로 예약한 도메인(`example.com`, `example.net`, `example.org`, `*.example`), 루프백(`localhost`, `127/8`, `[::1]`)의 예시 URL은 제외하고, 제외한 개수를 보고한다. 검사하지 않은 코드 블록 안 URL도 함께 보고하므로 조용히 사라지는 항목이 없다. 나머지는 리다이렉트 없이 해석되어야 한다.
- 분기 재검증 주기는 이 프로젝트의 정책으로 지킨다. 벤더 문서는 각자의 일정으로 바뀌며, 이 주기는 벤더 보장이 아니라 우리가 고른 검토 간격이다. arXiv·표준 문서는 부패 속도가 달라 URL 확인만으로 충분하다.
- `.hyper/`는 `.gitignore` 대상이므로 그 아래 미추적 리서치 리포트는 **로컬 재검증 캐시**이며 다른 clone에는 없다. 반면 `.hyper/`에는 추적 중인 파일도 있어 디렉터리 자체는 어느 clone에나 존재한다. 공유 가능한 근거는 항상 문서 안의 URL이다.

## 작성 원칙

1. **런타임 중립**: 특정 모델/벤더 전용 규칙은 provider profile로 분리한다.
2. **명확한 우선순위**: 항상 scope, authority, required/forbidden, verification을 분리한다.
3. **하네스 우선**: 중요한 instruction 변경은 예시 3개보다 eval case 10개가 낫다.
4. **역할보다 계약**: 역할 프롬프트는 페르소나보다 intent, scope, authority, context, output, verification을 먼저 고정한다.
5. **소스 기반**: 최신성·도구 동작·보안 주장은 공식 문서/표준/논문을 우선한다.
6. **짧은 루트, 깊은 reference**: 상위 문서는 200-300줄 이내로 유지하고 세부는 `references/`로 분리한다.
7. **이중 언어 동등성**: `X.md`와 `X.ko.md`는 같은 계약을 담아야 한다. 둘이 어긋나면 번역 뉘앙스가 아니라 결함이다.

## 권장 로딩 순서

```markdown
@instructions/README.ko.md
@instructions/context-engineering/CONTEXT_ENGINEERING.ko.md
@instructions/context-engineering/references/prompt-authoring.ko.md
@instructions/cache/CACHE.ko.md
@instructions/skill/SKILL_AUTHORING.ko.md
@instructions/skill/references/prompt-loop-eval.ko.md
@instructions/autoresearch/AUTORESEARCH.ko.md
@instructions/harness-engineering/HARNESS_ENGINEERING.ko.md
@instructions/loop-engineering/LOOP_ENGINEERING.ko.md
@instructions/graph-engineering/GRAPH_ENGINEERING.ko.md
@instructions/sourcing/reliable-search.ko.md
@instructions/validation/index.ko.md
```

작업 언어가 영어면 `.ko.md` 대신 `.md`를 로드한다. 둘을 함께 로드하지 않는다 — 같은 계약이므로 컨텍스트만 두 배로 쓴다.

저장소의 `AGENTS.md`나 `CLAUDE.md`를 만들거나 리팩터링하거나 리뷰할 때는 [`agents-md/AGENTS_MD.ko.md`](agents-md/AGENTS_MD.ko.md)를 읽고, 필요에 따라 `agents-md/references/` 아래 문서를 읽는다 — 런타임 로딩 동작은 `discovery-and-precedence.ko.md`, 어떤 줄이 자격을 얻는지는 `content-contract.ko.md`, 두 파일의 조율은 `claude-md-adapter.ko.md`, 실제로 측정된 것은 `evidence-and-evaluation.ko.md`다.

프롬프트, 시스템 메시지, 도구 설명, 스킬의 로드되는 텍스트를 쓰거나 고칠 때는 [`cache/CACHE.ko.md`](cache/CACHE.ko.md)를 읽어 재사용 접두부를 안정적으로 유지한다. 프로바이더별 임계값은 [`cache/references/provider-cache-facts.ko.md`](cache/references/provider-cache-facts.ko.md)에 있다.

작업이 특정 런타임에 묶이면 [`context-engineering/references/runtime-profiles.ko.md`](context-engineering/references/runtime-profiles.ko.md)를 추가로 읽는다. 병렬 작업, subagent, background agent, agent team을 사용할 때는 [`context-engineering/references/parallel-workflows.ko.md`](context-engineering/references/parallel-workflows.ko.md)를 함께 읽는다.

Skill을 새로 만들거나 `skills/*`를 refactor할 때는 [`skill/SKILL_AUTHORING.ko.md`](skill/SKILL_AUTHORING.ko.md)를 읽고, prompt/loop/eval 설계가 필요하면 [`skill/references/prompt-loop-eval.ko.md`](skill/references/prompt-loop-eval.ko.md)를 함께 읽는다. 필요에 따라 `skill/references/`의 anatomy, trigger, progressive disclosure, resource placement, validation 문서를 추가로 읽는다.

Autoresearch-style 반복 개선, metric optimization, autonomous debug/fix/learn/reason loop를 설계할 때는 [`autoresearch/AUTORESEARCH.ko.md`](autoresearch/AUTORESEARCH.ko.md)를 읽고, metric/verify/guard/log/rollback 기준에 따라 `autoresearch/references/`를 추가로 읽는다.

목표 기반, 예약 실행, 이벤트 기반처럼 멈춤 조건을 만족할 때까지 반복하는 자율 에이전트 루프를 설계할 때는 [`loop-engineering/LOOP_ENGINEERING.ko.md`](loop-engineering/LOOP_ENGINEERING.ko.md)를 읽는다. autoresearch는 이 영역 안의 지표 기반 특수 루프 하나다. 작업을 노드와 간선으로 나누고 공유 상태, 체크포인트, 에이전트 간 fan-out/fan-in을 다룰 때는 [`graph-engineering/GRAPH_ENGINEERING.ko.md`](graph-engineering/GRAPH_ENGINEERING.ko.md)를 읽는다.

리서치·최신성·출처 추적이 중요한 작업은 [`sourcing/reliable-search.ko.md`](sourcing/reliable-search.ko.md)를 먼저 읽고, source ledger/citation/freshness가 필요하면 `sourcing/references/`를 추가로 읽는다. 완료 주장, eval, agent/tool 검증이 중요한 작업은 [`validation/index.ko.md`](validation/index.ko.md)와 `validation/references/`를 함께 읽는다.
