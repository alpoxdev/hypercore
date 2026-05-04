# Hono 아키텍처 강제 적용

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

## 개요

Hono 프로젝트에서 코드 변경 전에 아키텍처 규칙을 강제합니다. 실제로 Hono 프로젝트인지 먼저 검증한 뒤, 라우트 조합, 핸들러, 미들웨어, 검증, 에러 처리, 플랫폼 엔트리, typed testing/RPC 경계를 엄격히 확인합니다.

**이 스킬은 엄격합니다.** 사용자가 공식 Hono 기본만 따르라고 명시하지 않는 한, 여기 적힌 규칙을 그대로 적용합니다.

**운영 모드:** 이 스킬은 자체적으로 동작해야 합니다. 외부 오케스트레이션에 의존하지 말고, 이 스킬의 검증 흐름으로 바로 진행하세요. 사용자가 exhaustive verification을 요구한 경우에만 더 깊게 확인합니다.

**중요:** 일부 규칙은 Hono 공식 기본보다 더 엄격합니다. 이런 항목은 hypercore 전용 컨벤션으로 분리해서 설명하세요.

## 트리거 예시

### Positive

- `이 Hono 앱 구조부터 점검하고 라우트 추가하자.`
- `Hono API를 리팩터링하는데 routing, middleware, validator 구조를 하나로 맞춰줘.`
- `Hono route를 추가하는데 testClient랑 AppType 추론도 안 깨지게 해줘.`

### Negative

- `Express 미들웨어 가이드 만들어줘.`
- `Hono를 쓰지 않는 React SPA를 리뷰해줘.`

### Boundary

- `Hono handler의 응답 문구만 아주 작게 바꿔줘.`
아키텍처 경계가 안 걸리면 direct edit만으로 충분할 수 있습니다.

- `hypercore 규칙 말고 Hono 공식 기본만 따를래.`
이 경우에도 스킬은 적용되지만, 공식 기본을 넘는 hypercore 전용 규칙은 완화합니다.

## 1단계: 프로젝트 검증

작업 전, 대상이 Hono 프로젝트인지 확인:

```bash
rg -n '"hono"|@hono/' package.json
rg -n "from 'hono'|from \"hono\"" src app .
rg -n "new Hono\\(|createFactory\\(|testClient\\(|hc<" src app .
```

이 지표가 하나도 없으면 중단하고, Hono 규칙을 강제로 적용하지 말고 일반 구현/리뷰 경로로 되돌립니다.

## 2단계: 아키텍처 규칙 읽기

편집 전에 아래 파일들을 읽으세요:

- `architecture-rules.md`
- `rules/conventions.md`
- `rules/routes.md`
- `rules/handlers.md`
- `rules/middleware.md`
- `rules/validation.md`
- `rules/errors.md`
- `rules/testing-rpc.md`
- `rules/platform.md`

현재 프레임워크 동작을 공식 문서 기준으로 다시 확인해야 하거나, 규칙의 근거를 명확히 적어야 하면 아래 참조도 읽습니다:

- `references/official/hono-docs.ko.md`

## 3단계: 변경 전 검증 체크리스트

계획된 변경을 아래 게이트로 검증합니다.

### 브라운필드 적용 규칙

- 레거시 차이를 곧바로 전체 실패로 취급하지 않습니다.
- 안전, 타입, 검증 문제는 특히 touched file에서 즉시 차단합니다.
- hypercore 전용 구조 차이는 untouched legacy code에서는 migration backlog로 남길 수 있습니다.
- 직접 수정하는 파일은, 과도하게 위험한 마이그레이션이 아니라면 규칙에 맞게 끌어올립니다.

### 게이트 1: 조합과 레이어

| 확인 항목 | 규칙 |
|------|------|
| 루트 앱이 transport, business logic, persistence를 한곳에서 직접 섞음? | 차단. 조합은 app/route 모듈에 두고, 도메인 로직은 아래 레이어로 내립니다. |
| 라우트 모듈이 서비스 레이어 없이 DB/SDK를 직접 호출함? | hypercore 규칙상 차단. `routes -> services -> repositories/clients` 선호. |
| 단순 핸들러에 controller class나 거대한 controller 파일 도입? | 차단. Hono best practices는 작은 app과 route composition을 더 선호합니다. |
| 큰 기능 영역인데 sub-app 조합 없이 수동 등록만 함? | 경고. `app.route()` / `basePath()` 조합을 우선합니다. |

### 게이트 2: 라우트 모듈

| 확인 항목 | 규칙 |
|------|------|
| 라우트 등록이 여러 파일에 흩어져서 진입점이 불명확함? | 차단. 조합 경로를 하나로 유지합니다. |
| 규모가 있는 라우트 모듈에 local schema/handler 분리가 없음? | hypercore 규칙상 차단. |
| catch-all 또는 fallback route가 구체적 라우트보다 먼저 등록됨? | 차단. Hono는 등록 순서가 중요합니다. |
| 라우트 모듈이 `app.route()` 또는 typed sub-app으로 깔끔하게 mount되지 않음? | 차단. |

### 게이트 3: 핸들러와 Context 타입

| 확인 항목 | 규칙 |
|------|------|
| 분리된 핸들러 때문에 route typing/context typing이 유실됨? | 차단. inline chaining 또는 `createFactory()` / `factory.createHandlers()` 사용. |
| `c.set()` / `c.get()` 값을 타입 없이 공유함? | 차단. app/factory에 `Variables`를 명시하세요. |
| 요청 파싱, 도메인 로직, 응답 포맷이 한 핸들러에 길게 섞여 있음? | 경고. validator, service, response shaping으로 분리합니다. |

### 게이트 4: Validation

| 확인 항목 | 규칙 |
|------|------|
| 의미 있는 요청 데이터를 validator 없이 소비함? | 차단. |
| `await c.req.json()` 같은 raw parsing이 핸들러마다 반복됨? | 아주 단순한 경우가 아니면 차단. |
| params/query/json/form 검증 전략이 같은 기능 안에서 제각각임? | 경고. 통일하세요. |
| 새 검증 라이브러리를 이유 없이 추가함? | 명시적 요청이 없으면 차단. `validator()`, `@hono/zod-validator`, `@hono/standard-validator` 우선. |

### 게이트 5: Middleware

| 확인 항목 | 규칙 |
|------|------|
| 미들웨어 실행 순서를 잘못 가정함? | 차단. 등록 순서가 곧 실행 순서입니다. |
| 공통 auth/logging/request-id 로직을 핸들러마다 복붙함? | 경고. middleware로 올립니다. |
| context 값이 요청 간에 유지된다고 가정함? | 차단. Context는 요청 단위입니다. |
| 런타임 전용 관심사가 middleware를 넘어 도메인 레이어까지 새어 나감? | 차단. |

### 게이트 6: 에러와 응답

| 확인 항목 | 규칙 |
|------|------|
| 예상 가능한 HTTP 실패를 전부 raw generic error로 던짐? | 경고. `HTTPException` 또는 중앙 번역 정책 사용. |
| 중간 이상 규모 API인데 `app.onError()`가 없음? | 경고. 중앙 에러 경계 추가. |
| `HTTPException.getResponse()`를 쓰면서 기존 `Context` 헤더를 잊음? | 차단. Context에서 세팅한 헤더를 보존해야 합니다. |
| typed RPC client를 내보내는데도 `c.notFound()` 동작에 의존함? | 차단. Hono RPC 문서에서 주의하는 패턴입니다. |

### 게이트 7: Testing과 RPC

| 확인 항목 | 규칙 |
|------|------|
| non-chained route 정의 때문에 `testClient()` 또는 `hc<typeof app>` 추론이 깨짐? | 차단. 타입이 exported app까지 흐르도록 유지합니다. |
| typed client/test가 필요한데 `AppType` export가 없음? | 차단. `AppType` export. |
| 큰 앱 분리 과정에서 sub-app 간 타입 추론이 유실됨? | 차단. Hono RPC larger application 패턴을 따릅니다. |

### 게이트 8: 플랫폼 엔트리

| 확인 항목 | 규칙 |
|------|------|
| 런타임 adapter 코드가 route module 안에 섞여 있음? | 차단. adapter/bootstrap은 edge에 둡니다. |
| 환경 bindings/vars를 타입 경계 없이 사용함? | 차단. |
| `showRoutes()` 같은 debug helper가 dev-only 가드 없이 켜져 있음? | 경고. |

## 3.5단계: Auto-Remediation Policy

국소적이고, 되돌리기 쉽고, 저위험이면 직접 수정합니다.

- 누락된 validator middleware 추가
- typed `AppType` export 추가
- route mounting을 하나의 composition 파일로 정리
- 분리된 untyped handler를 `createFactory()` / `factory.createHandlers()` 패턴으로 변경
- `app.onError()` 추가 또는 HTTP exception 번역 개선
- runtime adapter import를 handler/route 밖으로 이동

다만 범위가 넓거나 깨질 수 있는 마이그레이션은 명시적 근거 없이 자동 적용하지 않습니다.

- 대량 route/module rename
- 전역 레이어 재설계
- 저장소 전반의 validation library 교체
- 기존 client를 깨뜨리는 RPC 구조 변경
- runtime adapter 교체

## 4단계: 구현

Hono 코드를 변경할 때는 아래 순서를 우선합니다.

1. 현재 구조와 위반 지점을 검증
2. route composition과 typing 경계부터 정리
3. validation과 middleware 순서 정리
4. error handling과 response shaping 정리
5. testing/RPC 추론 회귀 수정
6. 검증 실행

## 검증 체크리스트

- Hono 프로젝트 감지 확인
- 관련 rule 파일 읽음
- touched file이 kebab-case 유지
- route composition이 명확하고 mount 가능
- middleware 순서 검증
- 의미 있는 입력에 validation 적용
- error handling 정책 명시
- 해당 시 `testClient` / `hc` / `AppType` 추론 유지
- runtime adapter 코드는 edge에 유지

