# Instructions Base

이 폴더는 이 프로젝트의 LLM 작업 베이스 문서층이다. 목적은 Codex, Claude Code, Cursor, GitHub Copilot 같은 에이전트가 같은 프로젝트 의도와 검증 기준을 이해하고 일관되게 작업하도록 만드는 것이다.

> 영어판: [`README.md`](README.md). 이 베이스의 모든 문서는 쌍으로 관리한다 — `X.md`가 영어, `X.ko.md`가 한국어이며 `skills/`에서 이미 쓰는 관례와 동일하다. 한쪽을 고치면 반대쪽도 함께 맞춘다.

## 역할

| 영역 | 파일 | 목적 |
|---|---|---|
| Context Engineering | [`context-engineering/CONTEXT_ENGINEERING.ko.md`](context-engineering/CONTEXT_ENGINEERING.ko.md) | 프롬프트/컨텍스트/도구 지시를 런타임 중립적으로 설계 |
| CLI Runtime Profiles | [`cli/README.ko.md`](cli/README.ko.md) | skill이 Claude Code, Codex, GJC, Hermes Agent, JCode, OMO, OpenClaw, OpenCode의 질문·승인·도구 기능을 안전하게 선택 |
| Prompt Authoring | [`context-engineering/references/prompt-authoring.ko.md`](context-engineering/references/prompt-authoring.ko.md) | 역할 수행 프롬프트를 실행 계약으로 작성하는 실전 템플릿 |
| Prompt & Skill Caching | [`cache/CACHE.ko.md`](cache/CACHE.ko.md) | 프롬프트·스킬의 재사용 접두부를 안정적으로 유지해 프로바이더 프롬프트 캐시가 재사용하게 한다 |
| AGENTS.md / CLAUDE.md | [`agents-md/AGENTS_MD.ko.md`](agents-md/AGENTS_MD.ko.md) | 저장소 에이전트 instruction 파일을 작고 근거 있고 이식 가능한 계약으로 작성 |
| Skill Authoring | [`skill/SKILL_AUTHORING.ko.md`](skill/SKILL_AUTHORING.ko.md) | 재사용 가능한 skill 폴더를 트리거·구조·검증 가능한 실행 패키지로 설계 |
| Skill Prompt/Loop/Eval | [`skill/references/prompt-loop-eval.ko.md`](skill/references/prompt-loop-eval.ko.md) | skill을 단일 프롬프트가 아니라 반복·검증 가능한 작은 프로그램으로 설계 |
| Autoresearch | [`autoresearch/AUTORESEARCH.ko.md`](autoresearch/AUTORESEARCH.ko.md) | 목표·범위·측정·검증·가드·로그·rollback 기반 자율 반복 하네스 설계 |
| Harness Engineering | [`harness-engineering/HARNESS_ENGINEERING.ko.md`](harness-engineering/HARNESS_ENGINEERING.ko.md) | 프롬프트, 에이전트, 도구 사용을 테스트 가능한 하네스로 관리 |
| Sourcing | [`sourcing/reliable-search.ko.md`](sourcing/reliable-search.ko.md) | 자료조사·검색·출처 검증 기준 |
| Validation | [`validation/index.ko.md`](validation/index.ko.md) | 작업 완료 전 검증 기준 |

## 출처 관리

외부 출처는 **URL과 확인일을 인라인으로** 적는다. `Sources` 섹션이 있는 문서는 그곳에, 없으면 claim 옆에 적는다. 예외는 저장소 유지보수 원장 하나뿐이며(예: [`cli/sources.md`](cli/sources.md)), [`sourcing/reliable-search.ko.md`](sourcing/reliable-search.ko.md) §7에서 정의한다. 나머지 claim을 근거 옆에 두는 편이 중앙화보다 비용이 작다.

```bash
bash scripts/check-sources.sh             # 확인일 형식·문서 길이 strict, 링크 advisory
bash scripts/check-sources.sh --strict    # 링크 이전까지 게이트 (릴리스 전)
bash scripts/check-sources.sh --offline   # 네트워크 없이 구조 검사만
bash scripts/check-sources.sh --self-test # 검사 자체가 실패를 잡는지 증명
bun run --cwd scripts lint:sh        # 검사기 자체의 정적 분석 (shellcheck 필요)
```

`lint:sh`는 `scripts/check-sources.sh`에 [ShellCheck](https://www.shellcheck.net/)를 실행한다. ShellCheck는 이 저장소의 의존성이 아니라 시스템 도구이므로 별도 opt-in 작업으로 둔다. 편집기 진단용 `bash-language-server`는 `scripts/package.json`에 선언되어 있다.

- 마지막 전수 확인: **2026-07-29**. AGENTS.md 탐색/우선순위 영역, CLI 런타임 프로필, skill·context-engineering 레퍼런스, harness-engineering 출처표, Hermes Agent 안내서, 신설 caching 영역의 부분 재검증: **2026-09-19**. 다음 전수 재검증: **2026-10-29**
- 링크 검사는 인라인 인용만 읽는다. 코드 블록과 RFC 2606이 문서용으로 예약한 도메인(`example.com`, `example.net`, `example.org`, `*.example`), 루프백(`localhost`, `127/8`, `[::1]`)의 예시 URL은 제외하고, 제외한 개수를 보고한다. 검사하지 않은 코드 블록 안 URL도 함께 보고하므로 조용히 사라지는 항목이 없다. 나머지는 리다이렉트 없이 해석되어야 한다.
- 분기 재검증 주기는 이 프로젝트의 정책으로 지킨다. 벤더 문서는 각자의 일정으로 바뀌며, 이 주기는 벤더 보장이 아니라 우리가 고른 검토 간격이다. arXiv·표준 문서는 부패 속도가 달라 URL 확인만으로 충분하다.
- `.hyper/`는 `.gitignore` 대상이다. 그 아래 리서치 리포트는 **로컬 재검증 캐시**이며 다른 clone에는 없다. 공유 가능한 근거는 항상 문서 안의 URL이다.

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
@instructions/sourcing/reliable-search.ko.md
@instructions/validation/index.ko.md
```

작업 언어가 영어면 `.ko.md` 대신 `.md`를 로드한다. 둘을 함께 로드하지 않는다 — 같은 계약이므로 컨텍스트만 두 배로 쓴다.

저장소의 `AGENTS.md`나 `CLAUDE.md`를 만들거나 리팩터링하거나 리뷰할 때는 [`agents-md/AGENTS_MD.ko.md`](agents-md/AGENTS_MD.ko.md)를 읽고, 필요에 따라 `agents-md/references/` 아래 문서를 읽는다 — 런타임 로딩 동작은 `discovery-and-precedence.ko.md`, 어떤 줄이 자격을 얻는지는 `content-contract.ko.md`, 두 파일의 조율은 `claude-md-adapter.ko.md`, 실제로 측정된 것은 `evidence-and-evaluation.ko.md`다.

프롬프트, 시스템 메시지, 도구 설명, 스킬의 로드되는 텍스트를 쓰거나 고칠 때는 [`cache/CACHE.ko.md`](cache/CACHE.ko.md)를 읽어 재사용 접두부를 안정적으로 유지한다. 프로바이더별 임계값은 [`cache/references/provider-cache-facts.ko.md`](cache/references/provider-cache-facts.ko.md)에 있다.

작업이 특정 런타임에 묶이면 [`context-engineering/references/runtime-profiles.ko.md`](context-engineering/references/runtime-profiles.ko.md)를 추가로 읽는다. 병렬 작업, subagent, background agent, agent team을 사용할 때는 [`context-engineering/references/parallel-workflows.ko.md`](context-engineering/references/parallel-workflows.ko.md)를 함께 읽는다. CLI별 질문·승인·도구 기능을 skill에서 사용하려면 [`cli/README.ko.md`](cli/README.ko.md)와 해당 하위 런타임 프로필을 함께 읽는다.

Skill을 새로 만들거나 `skills/*`를 refactor할 때는 [`skill/SKILL_AUTHORING.ko.md`](skill/SKILL_AUTHORING.ko.md)를 읽고, prompt/loop/eval 설계가 필요하면 [`skill/references/prompt-loop-eval.ko.md`](skill/references/prompt-loop-eval.ko.md)를 함께 읽는다. 필요에 따라 `skill/references/`의 anatomy, trigger, progressive disclosure, resource placement, validation 문서를 추가로 읽는다.

Autoresearch-style 반복 개선, metric optimization, autonomous debug/fix/learn/reason loop를 설계할 때는 [`autoresearch/AUTORESEARCH.ko.md`](autoresearch/AUTORESEARCH.ko.md)를 읽고, metric/verify/guard/log/rollback 기준에 따라 `autoresearch/references/`를 추가로 읽는다.

리서치·최신성·출처 추적이 중요한 작업은 [`sourcing/reliable-search.ko.md`](sourcing/reliable-search.ko.md)를 먼저 읽고, source ledger/citation/freshness가 필요하면 `sourcing/references/`를 추가로 읽는다. 완료 주장, eval, agent/tool 검증이 중요한 작업은 [`validation/index.ko.md`](validation/index.ko.md)와 `validation/references/`를 함께 읽는다.
