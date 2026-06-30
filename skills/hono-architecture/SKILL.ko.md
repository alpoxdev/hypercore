@architecture-rules.ko.md
@rules/conventions.ko.md
@rules/routes.ko.md
@rules/handlers.ko.md
@rules/middleware.ko.md
@rules/validation.ko.md
@rules/database.ko.md
@rules/openapi.ko.md
@rules/errors.ko.md
@rules/testing-rpc.ko.md
@rules/platform.ko.md
@references/official/hono-docs.ko.md
@references/official/drizzle-docs.ko.md

# Hono 아키텍처 강제 적용

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<purpose>

- 코드 변경 전에 Hypercore Hono 아키텍처 규칙을 강제합니다.
- Hono 전용 gate를 적용하기 전에 대상이 실제 Hono 프로젝트인지 확인합니다.
- route composition, handler, middleware, validation, database/ORM, Drizzle, OpenAPI/Swagger, platform entrypoint, error handling, testing, typed RPC 경계를 일관되게 유지합니다.
- Hono 공식 기본보다 엄격한 요구사항은 finding/report에서 Hypercore convention으로 표시합니다.

</purpose>

<routing_rule>

Hono app 구현, 리뷰, remediation, architecture enforcement에 이 스킬을 사용합니다.

Hono가 아닌 프로젝트, generic Express/Fastify 작업, architecture boundary를 건드리지 않는 copy-only 변경, 사용자가 Hypercore convention 없이 공식 Hono 기본만 원한다고 명시한 요청에는 강제로 적용하지 않습니다.

이 스킬은 자체적으로 동작합니다. Hono 규칙 적용만을 위해 global skill이나 외부 orchestration surface를 기다리지 않습니다.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Hono project를 official Hono behavior와 labelled Hypercore conventions에 맞춰 architecture, typing, docs, runtime boundary가 안전한 상태로 유지합니다. |
| Trigger | routes, handlers, middleware, validation, DB/ORM, Drizzle, OpenAPI, platform entrypoint, error handling, testing, RPC가 포함된 Hono 작업. |
| Scope | touched Hono source, topic rule files, official references, validation notes, small reversible architecture fixes를 review/guide합니다. |
| Authority | user/project instructions가 이 스킬보다 우선합니다. API facts에서는 official Hono/Drizzle docs가 Hypercore convention보다 우선합니다. Safety, typing, validation, data-boundary rules는 위험한 변경을 차단합니다. |
| Evidence | project indicators, local package/source files, touched paths, topic rules, drift가 중요할 때 official references, validation command output을 사용합니다. |
| Tools | local search/read/edit/validation command를 사용하고 migration, credential access, production side effect, runtime adapter swap, broad rewrite는 gate합니다. |
| Output | rule classification, changed files, validation evidence, remaining risks, official-vs-Hypercore label을 포함한 한국어 architecture finding 또는 implementation summary. |
| Verification | 완료 전 touched surface에 맞는 project check와 final checklist를 실행합니다. |
| Stop condition | project mode가 확인되고 applicable gate가 통과했거나 blocker로 보고되었으며 validation evidence가 기록되면 멈춥니다. |

</instruction_contract>

<activation_examples>

### Positive examples:

- `이 Hono 앱 구조부터 점검하고 라우트 추가하자.`
- `Hono API를 리팩터링하는데 routing, middleware, validator 구조를 하나로 맞춰줘.`
- `Hono route를 추가하는데 testClient랑 AppType 추론도 안 깨지게 해줘.`
- `Hono API에 Drizzle을 붙이되 route가 DB를 직접 만지지 않게 해줘.`
- `새 persisted endpoint를 추가하기 전에 database, migration, OpenAPI 경계를 점검해줘.`
- `hono-architecture 전체 수정`
- `Hono architecture 스킬을 full-remediation mode로 실행해줘.`

### Negative examples:

- `Express 미들웨어 가이드 만들어줘.`
- `Hono를 쓰지 않는 React SPA를 리뷰해줘.`

### Boundary examples:

- `Hono handler의 응답 문구만 아주 작게 바꿔줘.`
아키텍처 경계가 안 걸리면 direct edit만으로 충분할 수 있습니다.

- `hypercore 규칙 말고 Hono 공식 기본만 따를래.`
이 경우에도 스킬은 적용되지만, 공식 기본을 넘는 hypercore 전용 규칙은 완화합니다.

</activation_examples>

<trigger_conditions>

## 호출 인자

인자는 핵심 규칙이 아니라 수정 범위를 바꿉니다.

| 인자 | 의미 |
|------|------|
| 없음 | 요청된/touched Hono 범위를 검토하고 수정합니다. Untouched legacy drift는 hypercore 전용이거나 이관 위험이 크면 backlog로 보고할 수 있습니다. |
| `전체 수정` | Full-remediation mode. 감지된 Hono app 전체를 스캔하고, 안전하고 국소적이며 되돌릴 수 있고 검증 가능한 모든 위반을 수정합니다. Touched file에서 멈추지 않습니다. |
| `full fix` / `fix all` | `전체 수정`과 동일합니다. |
| `공식 기본만` / `official defaults only` | 공식 Hono 동작을 기본 decision surface로 두고, 사용자가 `전체 수정`도 함께 요청하지 않았다면 hypercore 전용 컨벤션은 optional finding으로 낮춥니다. |

`전체 수정` 모드에서는:

- Hono app file, route module, handler, middleware, validation schema, OpenAPI file, database/repository boundary, tests/RPC surface, runtime entrypoint 전체를 범위에 포함합니다.
- 감지된 Hono source tree 전체의 folder/file name을 스캔합니다. `package.json`, `tsconfig.json`, `drizzle.config.ts`, lockfile, generated declaration, 명시적으로 설정된 migration artifact처럼 framework/tool이 요구하는 이름을 제외하고 folder/file은 kebab-case여야 합니다.
- camelCase 또는 PascalCase folder/file은 같은 변경 안에서 import, test path, route reference, configuration reference를 안전하게 갱신할 수 있으면 kebab-case로 rename합니다.
- 3.5단계의 저위험 auto-remediation을 touched file에 한정하지 않고 앱 전체에 적용합니다.
- 같은 실행에서 안전하게 끝낼 수 없는 위험한 변경은 file path와 실패한 규칙을 포함해 정확한 blocker/backlog item으로 남깁니다. 조용히 무시하지 않습니다.

</trigger_conditions>

<workflow>

## 1단계: 프로젝트 검증

작업 전, 대상이 Hono 프로젝트인지 확인:

```bash
rg -n '"hono"|@hono/' package.json
rg -n "from 'hono'|from \"hono\"" src app .
rg -n "new Hono\\(|createFactory\\(|testClient\\(|hc<|OpenAPIHono|swaggerUI" src app .
```

이 지표가 하나도 없으면 중단하고, Hono 규칙을 강제로 적용하지 말고 일반 구현/리뷰 경로로 되돌립니다.

Database 작업이 범위에 포함되면 아래 지표도 확인합니다:

```bash
rg -n '"drizzle-orm"|drizzle-kit|DATABASE_URL|D1Database|@neondatabase|@libsql|pg|postgres' package.json drizzle.config.ts src app .
rg -n "from 'drizzle-orm|from \"drizzle-orm|db\\.|transaction\\(|migrate\\(|schema|repositories?" src app .
```

`전체 수정` 모드에서는 편집 전에 넓게 탐색합니다:

```bash
rg --files src app routes 2>/dev/null
rg -n "new Hono\\(|app\\.route\\(|basePath\\(|validator\\(|zValidator\\(|standardValidator\\(|OpenAPIHono|swaggerUI|testClient\\(|hc<|drizzle-orm|DATABASE_URL|D1Database|@neondatabase|@libsql" src app .
```

## 2단계: 아키텍처 규칙 읽기

<support_file_read_order>

편집 전에 아래 파일들을 읽으세요:

- `architecture-rules.md`
- `rules/conventions.md`
- `rules/routes.md`
- `rules/handlers.md`
- `rules/middleware.md`
- `rules/validation.md`
- `rules/database.md`
- `rules/openapi.md`
- `rules/errors.md`
- `rules/testing-rpc.md`
- `rules/platform.md`

현재 프레임워크 동작을 공식 문서 기준으로 다시 확인해야 하거나, 규칙의 근거를 명확히 적어야 하면 아래 참조도 읽습니다:

- `references/official/hono-docs.ko.md`
- `references/official/drizzle-docs.ko.md`

### 작업별 규칙 라우팅

- route composition, mount order, fallback 위치, sub-app structure는 `rules/routes.ko.md`를 읽습니다.
- handler extraction, `createFactory()`, `createHandlers()`, typed context flow는 `rules/handlers.ko.md`를 읽습니다.
- shared request boundaries, auth/logging/request-id flow, `c.set()` / `c.get()` 사용은 `rules/middleware.ko.md`를 읽습니다.
- params/query/json/form validation 선택은 `rules/validation.ko.md`를 읽습니다.
- database client, repository, ORM boundary, Drizzle schema, migration, transaction, D1, Neon, Turso/libSQL, `DATABASE_URL`은 `rules/database.ko.md`를 읽습니다.
- OpenAPI generation, Swagger UI, operation metadata, schema drift, docs endpoint, API contract publishing은 `rules/openapi.ko.md`를 읽습니다.
- `HTTPException`, `app.onError()`, response-shaping 문제는 `rules/errors.ko.md`를 읽습니다.
- `testClient()`, `hc<AppType>`, `AppType`, larger-app inference는 `rules/testing-rpc.ko.md`를 읽습니다.
- adapters, entrypoints, bindings, env/config typing, `basePath()` boundaries는 `rules/platform.ko.md`를 읽습니다.

### 공식 기본값 Override 모드

사용자가 hypercore 전용 컨벤션이 아니라 공식 Hono 기본값만 원한다고 명시하면:

- 먼저 `references/official/hono-docs.ko.md`를 읽습니다.
- 공식 Hono 동작을 기본 decision surface로 둡니다.
- 더 엄격한 hypercore 규칙은 optional overlay로 취급하고, 사용자가 opt out하지 않았을 때만 강제합니다.
- Finding과 final report에서는 어떤 규칙이 공식 Hono 동작이고 어떤 규칙이 hypercore 전용 컨벤션인지 구분합니다.

</support_file_read_order>

## 3단계: 변경 전 검증 체크리스트

편집 전 계획된 변경을 `architecture-rules.ko.md`와 topic rule 파일로 검증합니다.

브라운필드 규칙:

- Untouched legacy style drift는 backlog로 남길 수 있습니다.
- Safety, typing, validation, persistence, OpenAPI, runtime boundary 문제는 touched work에서 계속 차단합니다.
- `전체 수정` 모드에서는 감지된 Hono app 전체가 touched scope입니다.

핵심 gate:

- Hono app composition path가 하나로 분명해야 하며, route registration이 흩어지거나 fallback route가 앞서 등록되면 안 됩니다.
- Touched route module은 service를 우회해 DB/ORM/schema/SDK/runtime adapter 세부사항을 직접 import하지 않습니다.
- 의미 있는 params/query/json/form 데이터는 domain logic 전에 validator middleware를 거칩니다.
- 분리된 handler는 inline chaining 또는 `createFactory()` / `createHandlers()`로 typing을 유지합니다.
- Shared context를 쓰면 middleware order와 typed `Bindings`/`Variables`를 명시합니다.
- Drizzle schema, migration, client, transaction은 database/service boundary 뒤에 둡니다.
- Public documented route는 runtime validation, DTO, OpenAPI/Swagger, RPC response shape를 맞춥니다.
- Runtime adapter/bootstrap code는 platform edge에 둡니다.
- Tool 또는 외부 contract가 요구하지 않는 한 source folder/file은 kebab-case를 사용합니다.

Finding과 remediation 세부사항은 연결된 support file의 상세 checklist를 사용하고, core 파일에 중복하지 않습니다.

## 3.5단계: Auto-Remediation Policy

국소적이고, 되돌리기 쉽고, 저위험이면 직접 수정합니다.

- touched camelCase/PascalCase source folder 또는 file을 kebab-case로 rename하고 import/reference 갱신
- 누락된 validator middleware 추가
- shared RPC/client contract가 의존할 때 typed `AppType` export 추가
- route mounting을 하나의 composition 파일로 정리
- 분리된 untyped handler를 `createFactory()` / `factory.createHandlers()` 패턴으로 변경
- `app.onError()` 추가 또는 HTTP exception 번역 개선
- runtime adapter import를 handler/route 밖으로 이동
- touched direct database call을 기존 service/repository로 이동
- touched query에 누락된 repository wrapper 추가
- 반복된 database client import를 기존 database client boundary로 중앙화
- 저장소가 이미 spec을 발행한다면 touched public route의 누락된 OpenAPI metadata 추가
- Swagger UI 노출을 기존 docs/admin/dev boundary 뒤로 이동

다만 범위가 넓거나 깨질 수 있는 마이그레이션은 명시적 근거 없이 자동 적용하지 않습니다.

- 대량 route/module rename. 단, `전체 수정` 모드에서 모든 import/reference/config path를 갱신하고 검증할 수 있는 kebab-case-only rename은 예외
- 전역 레이어 재설계
- 저장소 전반의 validation library 교체
- 기존 client를 깨뜨리는 RPC 구조 변경
- runtime adapter 교체
- Database provider, ORM, dialect, Drizzle driver 교체
- Production migration 생성, 편집, 적용, 삭제
- Schema table/column/index rename
- 영향 workflow 테스트 없이 transaction boundary 재작성
- 앱 전체의 OpenAPI generator 교체 (`@hono/zod-openapi` vs `hono-openapi`)

## 4단계: 구현

Hono 코드를 변경할 때는 아래 순서를 우선합니다.

1. 현재 구조와 위반 지점을 검증. `전체 수정` 모드에서는 편집 전에 감지된 Hono app 전체를 inventory합니다.
2. folder/file naming을 안전하면 kebab-case로 먼저 정리합니다. 이후 import와 test가 안정적인 path에 의존하기 때문입니다.
3. route composition과 typing 경계부터 정리
4. touched persistence behavior의 database/repository/connection boundary 정리. `전체 수정` 모드에서는 앱 전체가 대상입니다.
5. validation과 middleware 순서 정리
6. touched public route의 OpenAPI/Swagger contract drift 정리. `전체 수정` 모드에서는 모든 documented/public route가 대상입니다.
7. error handling과 response shaping 정리
8. testing/RPC 추론 회귀 수정
9. 검증 실행

</workflow>

<validation_checklist>

## 검증 체크리스트

- Hono 프로젝트 감지 확인
- 관련 rule 파일 읽음
- touched file과 folder가 kebab-case 유지
- `전체 수정` 모드에서는 감지된 Hono source tree 전체의 kebab-case 위반을 스캔함
- route composition이 명확하고 mount 가능
- middleware 순서 검증
- 의미 있는 입력에 validation 적용
- touched route가 DB/ORM client, Drizzle schema table, migration helper를 직접 import하지 않음
- database client lifecycle이 중앙화되어 있고 runtime에 적합함
- schema/migration path가 configured ORM/drizzle setup과 일치함
- 영향받는 multi-step write의 transaction이 명시적임
- 문서화 대상 route를 수정했다면 OpenAPI/Swagger docs 갱신
- Swagger UI 노출이 의도적이고 환경에 맞음
- error handling 정책 명시
- 해당 시 `testClient` / `hc` / `AppType` 추론 유지
- API DTO, OpenAPI schema, RPC response shape가 raw ORM row를 실수로 노출하지 않음
- runtime adapter 코드는 edge에 유지
- final finding은 공식 Hono 규칙과 hypercore 전용 컨벤션을 구분함

</validation_checklist>
