# Workflow Routing

> 요청한 결과물을 분류하고, 작업이 쓰는 산출물을 만드는 단계만 더해 하나의 고정 순서로 실행합니다.

## 1. 작업 분류

요청한 결과물로 작업을 정한 뒤 저장소 파일로 확인합니다. 요청을 먼저 읽고, 신호가 가리키는 파일만 읽습니다.

| Job class | Requested output | Example words |
|---|---|---|
| Build | 바뀐 코드: 기능, 수정, 리팩토링, 마이그레이션, 도입. MCP 서버, 클라이언트, 호스트 설정. 또는 새로 만들거나 리팩터링한 스킬 폴더, 문서, 프롬프트 산출물 | 만들어, 추가해, 고쳐, 리팩토링해, 옮겨, 적용해, 연결해, 스킬로 만들어, 문서로 정리해, 프롬프트 만들어, implement, refactor, migrate, connect |
| Report | 코드 변경 없는 저장 보고서, 감사, 리뷰, 계획 | 조사만, 점검만, 리뷰만, 리포트만, 계획만, audit only, just the plan |
| Resume | 앞선 실행 이어가기 | 이어서, 계속, 재개, resume, continue |

계획 없는 한 곳 수정(오타, 문자열 하나, 설정 값 하나), 커밋만 하는 요청, PRD나 와이어프레임 패키지, 질문은 범위 밖입니다. 라우팅하지 않습니다.

## 2. 단계 신호

신호가 하나 있을 때만 그 단계를 더합니다. 라우팅 줄에 그 신호를 인용합니다.

| Stage | Add it when | Evidence to quote |
|---|---|---|
| `hyper-research` | 작업이 저장소 밖 사실에 달려 있습니다. 라이브러리나 서비스 선택, 새 메이저 버전, 낯선 외부 API, "최신" / "latest" 동작 | 요청 문구 |
| `hyper-seo` | 작업이 이름이 정해진 사이트나 페이지 묶음의 검색 또는 AI 답변 노출에 관한 것입니다 | 요청 문구와 대상 URL 또는 앱 경로 |
| `hyper-architecture` | 작업이 폴더, 라우트, 모듈, 데이터나 서버 경계, 플랫폼 설정을 재구성하거나, 새 라우트·모듈·서버 경계를 만드는 기능을 추가합니다 | 요청 문구와 읽은 스택 매니페스트(`package.json`, `pubspec.yaml`, `Cargo.toml` 등) |
| `hyper-mcp` | 작업이 MCP(Model Context Protocol) 서버, 클라이언트, 호스트 MCP 설정을 만들거나 고치거나 이전하거나 점검하거나 연결합니다. 또는 MCP 레지스트리 메타데이터를 준비합니다 | 요청 문구와, 있으면 읽은 MCP 의존성이나 설정 파일(`package.json`의 `@modelcontextprotocol/*`, `pyproject.toml`의 `mcp`, `.mcp.json`, `server.json` 등) |
| `hyper-plan` | Build 작업이 여러 파일이나 단계를 건드리거나, Report 작업이 계획을 요청합니다 | 요청 문구 |
| `hyper-execute` | 첫 단계일 때만: `.hyper/plans/` 아래 계획 파일이 이미 있고 사용자가 실행이나 재개를 원합니다 | 읽은 계획 경로 |
| `hyper-mass` | 사용자가 의존성 그래프, DAG, "의존성 그래프", "단계별 병렬"을 요청하거나, 일부가 먼저 끝나야 다른 일이 시작되는 여러 작업이 있고 계획 파일을 원하지 않습니다 | 요청 문구 |
| `hyper-skill` | 요청한 결과물이 재사용 스킬 폴더입니다. 새 스킬, 또는 기존 스킬의 트리거, 계약, 리소스, 검증 리팩터링 | 요청 문구, 그리고 이미 있으면 대상 `skills/<name>/SKILL.md` |
| `hyper-documentation` | 요청한 결과물이 새로 만들거나 리팩터링하는 문서 산출물입니다. README, `AGENTS.md`, AI가 읽기 좋은 문서(지침 베이스, 에이전트 가이드, 런북, 스펙, 규칙 묶음), 재사용 프롬프트 산출물(역할·시스템·에이전트 프롬프트, 프롬프트 템플릿이나 팩, 프롬프트 평가 픽스처) | 요청 문구, 그리고 이미 있으면 대상 경로 |

## 3. 단계 순서

고른 단계는 항상 이 순서로 실행합니다. 고르지 않은 단계는 건너뜁니다.

```text
hyper-research -> hyper-seo -> hyper-architecture -> hyper-mcp -> (hyper-plan [-> hyper-execute] | hyper-mass | hyper-execute | hyper-skill | hyper-documentation)
```

- 앞 단계(`hyper-research`, `hyper-seo`, `hyper-architecture`)는 꼬리 단계에 쓸 근거를 만듭니다. Build 작업에서는 보고서 모드로 실행하고, 코드 변경은 꼬리 단계가 합니다.
- `hyper-mcp`가 마지막으로 고른 단계면 꼬리 단계입니다. 직접 만들거나 고치거나 이전하거나 연결하고 결과를 검증합니다. 뒤에 `hyper-plan`이나 `hyper-mass`가 오면 점검 모드로 실행하고 그 보고서가 계획의 입력이 됩니다.
- 그 밖의 경우 꼬리 단계는 정확히 하나입니다. `hyper-plan`(스스로 `hyper-execute`로 이어짐), `hyper-mass`, 기존 계획에 대한 `hyper-execute` 단독, 스킬 폴더에 대한 `hyper-skill`, 문서나 프롬프트 산출물에 대한 `hyper-documentation` 중 하나입니다.
- Report 작업에서는 요청한 마지막 단계에서 체인이 끝납니다. 계획을 요청한 Report 작업은 `--plan-only`로 `hyper-plan`에서 끝납니다.
- 최대 네 단계까지 실행합니다. 더 필요해 보이는 체인은 작업 두 개입니다. 첫 작업을 실행하고 두 번째는 다음 단계로 보고합니다.

## 4. 체인 레시피

| Job | Chain |
|---|---|
| 아키텍처 점검만 | `hyper-architecture` |
| 리팩토링이나 구조 변경 | `hyper-architecture` -> `hyper-plan` |
| 여러 파일에 걸친 기능이나 수정 | `hyper-plan` |
| 라우트, 모듈, 서버 경계를 추가하는 기능 | `hyper-architecture` -> `hyper-plan` |
| 라이브러리나 기술 선택 후 도입 | `hyper-research` -> `hyper-plan` |
| 프레임워크나 메이저 버전 마이그레이션 | `hyper-research` -> `hyper-architecture` -> `hyper-plan` |
| MCP 서버나 클라이언트 구축, 수정, 이전, 연결 | `hyper-mcp` |
| MCP 점검이나 보고서만 | `hyper-mcp` 점검 모드 단독 |
| 낯선 외부 API를 감싸는 MCP 서버("Notion API를 MCP로") | `hyper-research` -> `hyper-mcp` |
| PR이나 배포로 전달하는 MCP 변경, 또는 MCP 밖 모듈도 바꾸는 변경 | `hyper-mcp`(점검) -> `hyper-plan` |
| 리서치 보고서만 | `hyper-research` |
| SEO 감사나 보고서만 | `hyper-seo` |
| SEO 점수 루프("최대 점수까지", "keep improving the score") | 최적화 모드의 `hyper-seo` 단독 |
| SEO 수정을 계획된 변경으로 구현 | `hyper-seo` -> `hyper-plan` |
| 의존 순서가 있는 다중 에이전트 작업 | `hyper-mass`. 앞 단계 신호가 있으면 그 단계를 앞에 둡니다 |
| 기존 계획 실행이나 재개 | `hyper-execute` |
| 스킬 폴더를 새로 만들거나 리팩터링 | `hyper-skill` |
| 최신 공식 문서에 기대는 스킬 폴더("최신 규격", "latest spec") | `hyper-research` -> `hyper-skill` |
| README, `AGENTS.md`, 문서, 규칙 묶음, 재사용 프롬프트, 템플릿, 팩, 프롬프트 평가 픽스처를 새로 만들거나 리팩터링 | `hyper-documentation` |
| 최신 외부 출처나 공급자 지침에 기대는 문서나 프롬프트 | `hyper-research` -> `hyper-documentation` |

`hyper-plan`이 들어간 행은 Report 작업이 아니면 `hyper-execute`로 이어집니다.

## 5. 동률 처리

- 긴 요청 안에서 사용자가 이름을 댄 단계("hyper-research로 조사하고 바로 적용해")는 고르고, 나머지 단계는 여전히 신호를 따릅니다.
- `hyper-mass`와 `hyper-plan`은 한 체인에서 함께 실행하지 않습니다. 명시 신호가 있을 때만 `hyper-mass`를 고르고, 아니면 `hyper-plan`을 고릅니다.
- `hyper-skill`과 `hyper-plan`은 한 체인에서 함께 실행하지 않습니다. 요청한 결과물이 스킬 폴더면 `hyper-skill`을 고릅니다. 계획 파일은 그 단계의 입력이 아닙니다.
- `hyper-documentation`은 `hyper-plan`과 한 체인에서 함께 실행하지 않습니다. 주된 결과물로 고릅니다. README, `AGENTS.md`, 문서, 재사용 프롬프트 산출물은 모드를 스스로 고르는 `hyper-documentation`, 스킬 폴더는 `hyper-skill`입니다.
- `hyper-mcp`와 `hyper-skill`은 한 체인에서 함께 실행하지 않습니다. 요청한 결과물이 스킬 폴더면 MCP에 관한 스킬이라도 `hyper-skill`을 고릅니다.
- `hyper-mcp`와 `hyper-architecture`는 작업이 MCP 밖의 폴더, 라우트, 모듈도 재구성할 때만 함께 실행합니다. MCP만 다루는 작업은 아키텍처 단계 없이 `hyper-mcp`로 보냅니다.
- MCP 작업에 전달 단어("PR까지", "ship")가 있으면 `hyper-mcp`를 점검 모드로 `hyper-plan` 앞에 둡니다. 전달은 계획과 실행 단계만 맡기 때문입니다.
- 기존 계획 파일이 새 계획보다 우선하는 경우는 사용자가 그 파일을 가리키거나 재개를 말했을 때뿐입니다. 관계없는 옛 계획이 있는 새 Build 요청은 새 계획을 씁니다.
- 스택이 아키텍처 단계의 지원 범위 밖이어도 그 단계는 유지합니다. 그 단계가 파일로 지원 여부를 정하고 사유와 함께 멈추며, `rules/stage-handoff.md` §4가 그 정지를 건너뜀으로 기록합니다.

## 6. 전달 단어와 보고서 전용 단어

그것을 소유한 단계에 그대로 넘깁니다. 사용자가 말하지 않은 것을 고르지 않습니다.

| User words | Passed to the plan or execute stage |
|---|---|
| 없음 | local 전달(단계 기본값) |
| "PR까지", "PR만", "make a PR", `--make-pr` | `--make-pr` |
| "머지까지", "배포까지", "ship", `--ship` | `--ship` |
| "계획만", "실행하지 말고", "plan only", `--plan-only` | `--plan-only`. 체인은 계획 뒤에 끝납니다 |
| "승인은 내가 할게", "I'll approve" | 말한 그대로 승인 보류를 넘깁니다. 체인은 계획 뒤에 끝납니다 |

## 7. 애매함

- 파일과 요청으로 체인이 정해지면 묻지 않고 라우팅합니다.
- 두 체인의 근거가 같고 잘못 고르면 작업 대부분을 다시 해야 할 때만 질문 하나를 합니다. 예를 들어 지원 앱이 두 개인 저장소에서 경로 없이 "구조 바꿔줘"라고 한 경우입니다. 후보 체인을 나열하고 하나를 권장하며, 답이 없으면 권장안으로 진행한다고 밝힙니다.
- 요청이 저장소와 어긋나면(사용자가 말한 스택이 매니페스트에 없음) 두 근거를 함께 보여 주고 한 번 묻습니다.

## 8. 라우팅 줄

첫 단계 전에 한국어 한 줄을 출력합니다.

```text
워크플로: <stage> -> <stage> -> ... (전달: local|make-pr|ship|plan-only) / 근거: <stage>=<signal>; <stage>=<signal>
```

첫 단계 전에 멈추는 실행은 같은 줄에 체인 대신 정지 사유를 씁니다.

## Sources

> Checked 2026-11-07.

| Claim | Source |
|---|---|
| 아홉 단계 스킬과 오케스트레이터 역할 | user instruction, 2026-11-06; `hyper-skill`, `hyper-mcp`, 문서 단계 추가 사용자 지시, 2026-11-07; 문서 단계를 `hyper-documentation` 하나로 합친 사용자 지시, 2026-11-07 |
| 각 단계의 트리거, 결과물, 제외 범위. `hyper-mass`가 계획 파일 실행을 제외하고 `hyper-execute`가 기존 계획을 요구한다는 점 포함 | 이 저장소의 각 단계 스킬 `SKILL.md`, 2026-11-06 |
| 전달 단어, 계획만·승인 보류 단어, 계획에서 실행으로 자동 연결 | 이 저장소의 계획 스킬 handoff 규칙, 2026-11-06 |
| 단계 순서, 네 단계 상한, 레시피, 동률 처리 | 이 패키지가 고른 설계이며 검증된 최적값이 아님 |
