# MCP

현재 프로토콜 `2026-07-28` 판을 기준으로 Model Context Protocol 서버와 클라이언트를 만들고 연결하고 통제하는 기준이다. 언제 서버를 만드는지, 무시하면 구현이 깨지는 프로토콜 규칙, 모델이 쓰고 호스트가 감당할 수 있는 도구 표면을 설계하는 방법, 보안 최저선을 다룬다.

> 영어판: [`MCP.md`](MCP.md)

## Why

MCP는 "AI 애플리케이션을 외부 시스템에 연결하는 오픈소스 표준"이다. 외부 시스템에는 데이터 원본, 도구, 워크플로가 있다(MCP 소개 문서, 2026-11-07 확인). 이 문서는 세 가지 사실 위에 서 있다.

- **현재 판은 단절이다.** `2026-07-28`이 현재 프로토콜 버전이고 이 릴리스는 MCP를 "양방향 상태 기반 프로토콜에서 요청/응답 무상태 프로토콜로" 바꿨다. `initialize` 핸드셰이크도, 프로토콜 세션도, 서버가 시작하는 요청도 없다(버전 관리 문서와 릴리스 글, 2026-11-07 확인). `2025-11-25` 이전을 기준으로 쓰인 튜토리얼, SDK 예제, 모델의 기억은 더 이상 존재하지 않는 메커니즘을 설명하는데도 여전히 컴파일된다.
- **프로토콜이 서버를 안전하게 만들지는 않는다.** 공식 로컬 서버 가이드는 "**어떤 검사도 서버가 무엇을 할지 증명하지 못한다**"고 적는다. 실제로 돌아가는 서버 45개를 대상으로 한 도구 오염(tool poisoning) 벤치마크는 공격 성공률을 최대 72.8%로 측정했고 거부율은 3% 아래였다(arXiv 2508.14925, 2026-09-29 개정, 둘 다 2026-11-07 확인). 안전은 서버 주위에서 호스트와 운영자가 강제하는 것에서 나온다.
- **도구는 매 턴 컨텍스트를 소비한다.** 유지보수자 로드맵은 "도구가 백 개 달린 서버에 연결하면 사용자가 질문을 하나도 하기 전에 모델이 그 표면 전체에 값을 치르게 되고 목록이 길어질수록 도구 선택은 대체로 나빠진다"고 적는다(2026-08-22, 2026-11-07 확인).

운영 체계는 안정적이다. Anthropic은 2025-12-09에 Linux Foundation 산하 Agentic AI Foundation에 MCP를 기증했고 유지보수자는 Specification Enhancement Proposal(SEP)과 최소 12개월 유예 기간을 둔 폐기 정책으로 기술 방향을 정한다(2026-11-07 확인).

## Definition

- MCP-1: **호스트**는 AI 애플리케이션이다. 연결된 **서버**마다 **클라이언트** 하나를 실행한다. 서버는 프리미티브를 노출하고 클라이언트는 서버에 기능을 되돌려 줄 수 있다.
- MCP-2: 프리미티브마다 제어자가 있다. 도구는 모델이 제어하고 리소스는 애플리케이션이 제어하며 프롬프트는 사용자가 제어한다. 서버가 의존할 수 있는 클라이언트 기능은 elicitation이고 Roots와 Sampling은 폐기 예정(Deprecated)이다.
- MCP-3: 판은 날짜 문자열이다. `2026-07-28` 이후는 **modern**(모든 요청의 `_meta`에 버전과 능력을 담는다)이고 `2025-11-25` 이전은 **legacy**(핸드셰이크와 세션)이며 둘 다 지원하는 구현은 **dual-era**다. 이 세 이름은 명세의 용어라 원어로 쓴다.
- MCP-4: 트랜스포트는 의미가 같은 바인딩이다. stdio 또는 Streamable HTTP다. HTTP+SSE는 폐기 예정이다.
- MCP-5: 확장(Apps, Tasks, Skills, 인가 확장)은 코어 밖에 있고 `{vendor-prefix}/{name}` 형식으로 이름을 붙이며 양쪽이 모두 선택하지 않으면 꺼져 있다.

## When to build a server

| 상황 | 선택 |
|---|---|
| 여러 호스트나 에이전트에서 동작해야 하거나, 사용자 인가를 받아 그 사용자를 대신해 원격 시스템에 작용해야 한다 | MCP 서버. 클라우드 API를 감싸는 것은 원격 Streamable HTTP로 만든다 |
| 사용자 기계(파일, 로컬 앱, 하드웨어)가 필요하다 | [`references/security-and-authorization.ko.md`](references/security-and-authorization.ko.md)의 방식으로 격리한 로컬 stdio 서버 |
| 필요한 것이 저장소 하나나 런타임 하나의 절차나 프로젝트 지식이다 | 서버가 아니라 지시 파일이나 스킬([`../agents-md/AGENTS_MD.ko.md`](../agents-md/AGENTS_MD.ko.md), [`../skill/SKILL_AUTHORING.ko.md`](../skill/SKILL_AUTHORING.ko.md)) |
| 기존 서버가 이미 덮는다 | 그 서버를 쓴다. 출처를 확인하고 고정하고 도구 범위를 좁힌다. 두 번째 서버를 쓰지 않는다 |

서버는 연결된 모든 호스트가 정의 값을 치르는 인터페이스다. 호스트 간 재사용이나 위임된 인가가 목적일 때 만든다. 아무 도우미나 담는 기본 포장으로 만들지 않는다.

## Protocol rules

- MCP-P-1: `2026-07-28`을 대상으로 한다. 통제하지 못하는 legacy 클라이언트를 지원해야 할 때만 dual-era로 만들고 두 era 모두 시험한다.
- MCP-P-2: `server/discover`를 구현하고 버전과 클라이언트 능력은 요청마다 `_meta`에서 읽는다. 연결이나 프로세스에서 추론하지 않는다.
- MCP-P-3: 호출 간 상태는 서버가 발급한 명시적 핸들을 도구 인수로 넘겨 나른다. 핸들은 상태를 가리킬 뿐 호출자를 인증하지 않는다.
- MCP-P-4: 클라이언트에 입력을 요청할 때는 `tools/call`, `prompts/get`, `resources/read`의 Multi Round-Trip Request(`InputRequiredResult`)만 쓰고 인가나 비즈니스 로직에 영향을 주는 `requestState`는 무결성을 보호한다.
- MCP-P-5: stdio에서는 MCP 메시지 말고 `stdout`에 아무것도 쓰지 않고 `stderr`에 기록한다. Streamable HTTP에서는 `Origin`을 검증하고 `MCP-Protocol-Version`, `Mcp-Method`, `Mcp-Name`을 본문과 대조하며 `Mcp-Session-Id`는 무시한다.
- MCP-P-6: 목록 결과는 `ttlMs`와 `cacheScope`를 붙여 결정적 순서로 돌려준다. `private` 캐시 항목을 인가 문맥 사이에서 공유하지 않는다.
- MCP-P-7: 폐기 예정 기능을 채택하지 않는다. Roots, Sampling, Logging, Dynamic Client Registration, HTTP+SSE다. 각각 이름 붙은 마이그레이션 경로가 있다.

세부 내용, 호환성을 깨는 변경 표, 호환성 행렬, 마이그레이션 체크리스트는 [`references/protocol-2026-07-28.ko.md`](references/protocol-2026-07-28.ko.md)에 있다.

## Server design rules

- MCP-D-1: API 엔드포인트마다 도구 하나를 두지 말고 작업 모양의 도구 몇 개를 노출하며 관련 도구는 네임스페이스로 묶는다. 이름 선택은 평가로 측정한다.
- MCP-D-2: 도구 이름은 `A-Z a-z 0-9 _ - .`에서 1~128자로 짓고 서버 안에서 유일하다. `tools/list`는 요청의 인가에 따라서만 달라진다.
- MCP-D-3: 모든 `inputSchema`는 유효한 JSON Schema 객체다. `outputSchema`가 있으면 그에 맞는 `structuredContent`와 텍스트 사본을 함께 돌려준다.
- MCP-D-4: 모델이 고칠 수 있는 실패(잘못된 입력, API 오류, 비즈니스 규칙)는 실행 가능한 메시지와 함께 `isError: true`로 보고한다. JSON-RPC 오류는 알 수 없는 도구와 형식이 깨진 요청에만 쓴다.
- MCP-D-5: 모든 응답을 페이지 나누기, 필터링, 잘라내기 가운데 하나로 제한하고 더 가져오는 방법을 밝힌다. 호스트는 출력에 상한을 둔다(Claude Code는 기본 25,000토큰).
- MCP-D-6: annotation을 사실대로 설정하고 안전을 위해 그중 무엇에도 의존하지 않는다.
- MCP-D-7: 서버 `instructions`는 도구 사이의 관계와 도구가 말할 수 없는 제약에만 쓴다. 보증에는 쓰지 않는다.

세부 내용과 각 규칙의 근거는 [`references/server-design.ko.md`](references/server-design.ko.md)에 있다.

## Security rules

- MCP-S-1: 모든 서버를 부여한 권한만 가진 신뢰할 수 없는 코드로 다룬다. 서드파티 로컬 서버는 컨테이너나 VM에 격리하고 서버마다 좁은 자격 증명을 따로 주며 가능하면 다이제스트로 고정한다.
- MCP-S-2: 원격 서버는 `2026-07-28` 인가 프로파일을 구현한다. OAuth 2.1, Protected Resource Metadata, PKCE, 리소스 지시자, 요청마다 대상(audience) 검증, 발급자 검증, Dynamic Client Registration보다 앞선 Client ID Metadata Document에 의한 클라이언트 등록이다.
- MCP-S-3: 다른 리소스에 발급된 토큰을 받거나 넘기지 않는다. 업스트림 API를 호출하는 서버는 그 자체로 OAuth 클라이언트다.
- MCP-S-4: 로컬 HTTP 리스너는 `Origin`을 검증하고 루프백에 바인딩하며 그래도 인증한다. 루프백은 인증 경계가 아니다.
- MCP-S-5: 비밀을 form 모드 elicitation으로 요청하거나 URL에 넣거나 `x-mcp-header`로 표시하지 않는다.
- MCP-S-6: 서버가 아니라 세션을 평가한다. 사적 데이터와 신뢰할 수 없는 내용, 외부 채널이 한 세션에 겹치면 게이트를 두거나 세션을 나눠야 한다.

위협 근거, 인가 표, 체크리스트는 [`references/security-and-authorization.ko.md`](references/security-and-authorization.ko.md)에 있다. 공급망 고정과 최소 행위자 권한은 [`../harness-engineering/HARNESS_ENGINEERING.ko.md`](../harness-engineering/HARNESS_ENGINEERING.ko.md)의 `HE-S-1`과 `HE-S-3`이 소유한다.

## Host and agent rules

- MCP-U-1: 서버가 보내는 모든 것(결과, 리소스, 프롬프트, 설명, annotation, instructions, `serverInfo`)은 증거이고 권한이 아니다.
- MCP-U-2: 저장소가 자기 서버를 스스로 승인할 수 없다. 프로젝트 범위 설정은 검토를 거쳐 신뢰하는 작업 공간에서만 효력을 낸다.
- MCP-U-3: 사람이 어떤 호출이든 거부할 수 있게 둔다. 읽기 전용 힌트로 승인을 건너뛰는 것은 신뢰하는 서버에만 하고 호출 전에 인수를 보여준다.
- MCP-U-4: 도구 정의에 예산을 둔다. 정의가 정한 임계값을 넘으면 불러오기를 미루거나 검색하거나 필요할 때 연결한다(MCP 클라이언트 가이드는 컨텍스트 창의 1~5%를 제안한다). 어느 임계값을 적용했는지 기록한다.
- MCP-U-5: 대화 안에서 도구 배열을 안정적으로 유지한다. 새 정의는 캐시 중단점 뒤에 덧붙인다.
- MCP-U-6: 설정됐다고 쓸 수 있는 것은 아니다. 에이전트가 의존하기 전에 실제 호출로 서버마다 입증한다.

패턴, 런타임별 사실, 측정된 비용 수치는 [`references/host-integration.ko.md`](references/host-integration.ko.md)에 있다.

## Verification

- MCP-V-1: MCP Inspector CLI를 `--protocol-era modern`으로 실행한다. 기본 era가 `legacy`라서 기본 실행으로는 `2026-07-28` 판의 동작을 알 수 없다. dual-era 서버는 두 era 모두에서 통과해야 한다.
- MCP-V-2: CI에서는 `--stored-auth-only`와 `--strict`를 쓰고 문서화된 종료 코드로 분기한다.
- MCP-V-3: 도구 사용은 적합성과 따로 평가한다. 현실적인 여러 호출 작업, 검증 가능한 결과, 남겨 둔 사례를 쓰고 호출 수와 토큰, 오류를 정확도와 함께 추적한다([`../validation/index.ko.md`](../validation/index.ko.md), [`../harness-engineering/HARNESS_ENGINEERING.ko.md`](../harness-engineering/HARNESS_ENGINEERING.ko.md)).
- MCP-V-4: 서버의 도구, 범위, 의존성이 바뀌면 보안 체크리스트를 다시 돌린다.

명령, 디버깅 순서, 레지스트리 게시는 [`references/build-test-ship.ko.md`](references/build-test-ship.ko.md)에 있다.

## Anti-patterns

| 패턴 | 나타나는 모습 | 실패하는 이유 | 규칙 |
|---|---|---|---|
| 기억에 의존한 legacy 코드 | 새 코드에 `initialize`, 세션 ID, 서버가 시작하는 `sampling` | 현재 판이 그것들을 없앴고 modern 클라이언트는 연결할 수 없다 | MCP-P-1, MCP-P-2 |
| 세션을 상태로 사용 | 연결마다 캐시하거나 `Mcp-Session-Id`로 조회 | 요청이 어느 인스턴스에든 닿을 수 있어 상태가 새거나 사라진다 | MCP-P-3 |
| `stdout` 기록 | stdio 서버의 `print`나 `console.log` | JSON-RPC 스트림을 깨뜨린다 | MCP-P-5 |
| 엔드포인트 거울 | REST 엔드포인트마다 도구 하나, 서버당 수십 개 | 목록이 길어질수록 컨텍스트 비용과 선택 오류가 커진다 | MCP-D-1, MCP-U-4 |
| 무제한 결과 | 한 호출에 표나 파일 전체를 돌려준다 | 호스트가 잘라내거나 호출을 실패시킨다 | MCP-D-5 |
| 힌트를 방어로 사용 | `readOnlyHint`가 참이라 자동 승인 | 신뢰할 수 없는 서버는 거짓말할 수 있다 | MCP-D-6, MCP-U-3 |
| 토큰 전달 | 클라이언트 토큰을 업스트림 API로 넘긴다 | 수신 대상(audience) 묶음과 감사 추적을 깬다 | MCP-S-3 |
| 설치하고 잊기 | 고정하지 않은 로컬 서버가 홈 디렉터리와 전역 비밀에 접근 | 오염된 릴리스나 의존성 하나가 모든 자격 증명에 닿는다 | MCP-S-1 |
| 기본 era 시험 | `--protocol-era modern` 없이 성공한 inspector 실행 | legacy 동작만 증명한다 | MCP-V-1 |

## Where it sits

| 영역 | 경계 |
|---|---|
| [`../harness-engineering/HARNESS_ENGINEERING.ko.md`](../harness-engineering/HARNESS_ENGINEERING.ko.md) | 트레이스 필드, 평가, 에이전트 보안 최저선을 소유한다. MCP 도구 호출도 그 트레이스 안의 도구 호출이다. |
| [`../context-engineering/CONTEXT_ENGINEERING.ko.md`](../context-engineering/CONTEXT_ENGINEERING.ko.md)와 [`references/runtime-profiles.ko.md`](../context-engineering/references/runtime-profiles.ko.md) | 권한, 컨텍스트 예산, 런타임별 표면을 소유한다. 이 영역은 MCP에 특유한 비용과 신뢰 사실을 더한다. |
| [`../cache/CACHE.ko.md`](../cache/CACHE.ko.md) | 프리픽스 안정성을 소유한다. 도구 목록이 바뀌면 캐시가 깨진다. |
| [`../sourcing/references/retrieval-safety.ko.md`](../sourcing/references/retrieval-safety.ko.md) | 검색된 내용과 도구 내용이 증거라는 규칙을 소유한다. |
| [`../skill/SKILL_AUTHORING.ko.md`](../skill/SKILL_AUTHORING.ko.md) | 재사용 가능한 절차 패키지를 소유한다. 외부 시스템이나 위임된 인가가 없으면 스킬을 고른다. |

## References

- [`references/protocol-2026-07-28.ko.md`](references/protocol-2026-07-28.ko.md): 메시지 모양, 호환성을 깨는 변경, MRTR, 구독, 캐싱, 트랜스포트, 시대 구분, 폐기, 마이그레이션 체크리스트.
- [`references/server-design.ko.md`](references/server-design.ko.md): 프리미티브, 도구 표면, 오류, 상태 핸들, elicitation, instructions, annotation, 확장.
- [`references/security-and-authorization.ko.md`](references/security-and-authorization.ko.md): 위협 근거, 인가 프로파일, 공격 완화, 로컬 서버 관행, 체크리스트.
- [`references/host-integration.ko.md`](references/host-integration.ko.md): 비용 모델, 설정 신뢰, 승인, 지연 로딩과 코드 모드, 런타임별 사실.
- [`references/build-test-ship.ko.md`](references/build-test-ship.ko.md): 배포 형태, SDK 등급, 최소 서버 계약, inspector, 디버깅, 레지스트리.

## Sources

> 모든 링크는 2026-11-07에 확인했고 명세 페이지는 `2026-07-28` 판이며 블로그·논문 날짜는 각 페이지에 표시된 값이다.

| 주장 | 출처 | 게재 |
|---|---|---|
| MCP 정의 | <https://modelcontextprotocol.io/docs/2026-07-28/getting-started/intro> | 2026-07-28 판 |
| 현재 판, 시대 구분, 폐기 유예 기간 | <https://modelcontextprotocol.io/docs/2026-07-28/learn/versioning> | 2026-07-28 판 |
| 호환성을 깨는 변경과 폐기 | <https://modelcontextprotocol.io/specification/2026-07-28/changelog> | 2026-07-28 판 |
| 무상태 코어 릴리스 | <https://blog.modelcontextprotocol.io/posts/2026-07-28/> | 2026-07-28 |
| 프리미티브 제어 모델 | <https://modelcontextprotocol.io/specification/2026-07-28/server> | 2026-07-28 판 |
| "어떤 검사도 서버가 무엇을 할지 증명하지 못한다" | <https://modelcontextprotocol.io/docs/2026-07-28/tutorials/security/local-server-security> | 2026-07-28 판 |
| 도구 오염 벤치마크 | <https://arxiv.org/abs/2508.14925> | 2025-08-19, 2026-09-29 개정 |
| 도구 백 개의 비용 | <https://blog.modelcontextprotocol.io/posts/mcp-roadmap/> | 2026-08-22 |
| Agentic AI Foundation에 기증 | <https://blog.modelcontextprotocol.io/posts/2025-12-09-mcp-joins-agentic-ai-foundation/> | 2025-12-09 |
| 재단 설립, 독립 확인 | <https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation> | 2025-12-09 |
| 1~5% 지연 임계값 | <https://modelcontextprotocol.io/docs/2026-07-28/develop/clients/client-best-practices> | 2026-07-28 판 |
| 호스트 출력 상한 | <https://code.claude.com/docs/en/mcp> | 2026-11-07 확인 |
| 클라우드 API의 원격 기본값 | <https://modelcontextprotocol.io/docs/2026-07-28/develop/build-with-agent-skills> | 2026-07-28 판 |

[`references/protocol-2026-07-28.ko.md`](references/protocol-2026-07-28.ko.md) · [`references/server-design.ko.md`](references/server-design.ko.md) · [`references/security-and-authorization.ko.md`](references/security-and-authorization.ko.md) · [`references/host-integration.ko.md`](references/host-integration.ko.md) · [`references/build-test-ship.ko.md`](references/build-test-ship.ko.md)
