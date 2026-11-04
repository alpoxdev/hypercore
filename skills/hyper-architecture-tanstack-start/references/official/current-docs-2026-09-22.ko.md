# TanStack Start 공식 문서 현행 스냅샷

- last_verified_at: 2026-09-22
- source: TanStack 공식 Start 문서 페이지를 직접 가져온 결과(아래 `guide/<page>.md` URL)와 `TanStack/router` 소스 트리를 `fe7f1fd0e6ef73c3f341dd2338b406749538a85d`로 고정한 결과
- use_when: Start/Router API 동작, Start plugin 설정, import protection, 실행 경계, 미들웨어, 또는 서버 함수와 서버 라우트의 API 형태가 아키텍처 결정에 영향을 줄 때
- authority: API 사실은 TanStack 공식 문서를 기준으로 삼고, Hypercore 관례는 `rules/`에 남긴다.
- supersedes: 은퇴한 2026-06-02 스냅샷 (그 파일은 뒤집힌 주장을 두 곳 담고 있었다. 아래 "2026-06-02 스냅샷에서 바로잡은 것"을 본다.)

## 목차

- [2026-06-02 스냅샷에서 바로잡은 것](#2026-06-02-스냅샷에서-바로잡은-것)
- [서버 함수](#서버-함수)
- [실행 경계](#실행-경계)
- [전역 Start 설정](#전역-start-설정)
- [CSRF 보호](#csrf-보호)
- [미들웨어](#미들웨어)
- [import protection](#import-protection)
- [서버 라우트](#서버-라우트)
- [드리프트 처리](#드리프트-처리)
- [Sources](#sources)

## 2026-06-02 스냅샷에서 바로잡은 것

- **`.validator(...)`가 정본이다. `.inputValidator(...)`는 런타임에서 여전히 동작하는 폐기 별칭이다.** 이 파일에서 동작 판정이 뒤집히는 수정은 이것 하나다.
- 폐기 별칭은 위반이 아니며 차단 대상도 아니다. 기존 코드는 그대로 동작한다. 이미 손대는 코드일 때만 마이그레이션한다.
- 근거는 모두 2026-09-22에 다시 확인했다.
  - 문서: `guide/server-functions.md`는 전체에서 `.validator(...)`를 쓴다(7회, `inputValidator`는 0회). `guide/middleware.md:34`는 `Input Validation | No | Yes (`.validator()`)`이고, `guide/middleware.md:232`의 제목은 `### The `.validator` method`다.
  - 고정 소스: `packages/start-client-core/src/createServerFn.ts:511`이 `inputValidator` 위에 `/** @deprecated Use `validator` instead. */`를 달고 있고, `:921`은 `const validator = options.validator ?? options.inputValidator`다. 즉 별칭이 런타임에서 계속 해석되기 때문에 계속 동작한다. `packages/start-client-core/src/createMiddleware.ts:182-183`도 같은 `@deprecated` 표시를 달고 있다.
  - 이력: PR #7566 "rename inputValidator to validator"는 2026-06-06T21:05:57Z에 병합됐다(merge commit `9bebf8dc9f2bf74b680c065a5aa63d03b9622825`, 변경 파일 212개, 본문: "inputValidator is deprecated and will be removed soon"). 이 변경은 `@tanstack/react-start@1.168.25`로 2026-06-06T21:43:40Z에 배포됐다.
- **이 스킬의 이전 스냅샷은 단순히 낡은 것이 아니라 틀렸다.** 이전 2026-06-02 스냅샷은 `last_verified_at: 2026-06-09`로 적고, 31행에서 서버 함수가 "input validation에 `.inputValidator(...)`를 사용한다"고, 46행에서 미들웨어 검증도 "`.inputValidator(...)`를 사용한다"고 적었다. 둘 다 뒤집혀 있다. 리네임은 이미 사흘 전에 병합돼 있었으므로, 그 검증 pass는 당시의 문서와 소스가 말한 것의 반대를 기록했다. 이 이력은 일부러 남긴다. 날짜가 박힌 스냅샷은 그것을 만든 pass만큼만 믿을 수 있고, 이 스냅샷은 잘못 읽은 pass의 산물이었다.

## 서버 함수

- `createServerFn()`이 서버 함수를 정의한다. `method`의 기본값은 `GET`이며, 다른 형태는 `createServerFn({ method: 'POST' })`다. `Method`는 정확히 `'GET' | 'POST'`다. `packages/start-client-core/src/createServerFn.ts:449`가 `export type Method = 'GET' | 'POST'`다. 다른 메서드는 없다.
- `.handler(...)`가 체인을 끝내는 종단 호출이다. 여기서 구현을 정의한다. 입력 검증은 `.validator(...)`(정본) 또는 `.inputValidator(...)`(폐기 별칭)가 붙이고, 그 앞에 `.middleware([...])`가 미들웨어를 붙인다.
- `strict` 옵션이 있고 기본값은 `strict: true`다. TypeScript 수준의 직렬화 검사를 제어한다. `createServerFn({ strict: false })`와 세분화된 `strict: { input: false }` / `strict: { output: false }` 형태로 해제한다. 문서는 `strict: false`가 타입 검사만 완화한다고 경고한다. 값은 여전히 런타임 직렬화 계층이 제대로 처리해야 한다.
- 파일 구성: 문서는 `*.functions.ts`(서버 함수 래퍼) / `*.server.ts`(서버 전용 헬퍼) 분리를 "one approach"로 소개하며, 강제가 아니다. import protection은 그 명명을 강제하지 않는다. 강제되는 패턴은 `*.server.*`와 `*.client.*`뿐이다.
- 서버 함수의 정적 import는 안전하다. 문서는 동적 import를 피하라고 경고한다(`guide/server-functions.md:150`: "Avoid dynamic imports for server functions").
- 서버 함수는 같은 출처의 앱 RPC 엔드포인트다. loaders, components, hooks, 다른 서버 함수, event handlers에서 호출할 수 있다. hook 사용성이 필요하면 React 래퍼인 `useServerFn()`을 쓴다.

## 실행 경계

- `createServerFn`, `createServerOnlyFn`, `createClientOnlyFn`, `createIsomorphicFn`이 공식 실행 제어 프리미티브다.
- `createIsomorphicFn()`은 `.server(...)`와 `.client(...)`로 환경별 구현을 가진 함수 하나를 구성한다. 한쪽이 없으면 오류가 아니라 `undefined`를 돌려주는 no-op이다.
- `createServerOnlyFn(...)`과 `createClientOnlyFn(...)`은 환경에 묶인 실행을 강제하고, 잘못된 환경에서 호출하면 설명이 담긴 런타임 오류를 던진다.
- 환경 함수는 번들별로 트리 셰이킹된다. `.client()` 본문은 서버 번들에서 빠지고 그 반대도 마찬가지다.
- loader는 서버 전용이 아니라 isomorphic이다. 문서의 "Common Problems" 절이 그 반대로 가정하는 것을 대표적인 비밀 유출 실수로 지목한다.

## 전역 Start 설정

- `src/start.ts`는 기본 Start 템플릿에 **포함되지 않는다**. 전역 미들웨어나 Start 수준 옵션이 필요할 때 만든다.
- 정본 형태는 콜백 형태다. `export const startInstance = createStart(() => ({ requestMiddleware: [...], functionMiddleware: [...] }))`. 소스 시그니처는 `createStart(getOptions: () => StartInstanceOptions | Promise<StartInstanceOptions>)`다.
- 실제 옵션 표면은 `serializationAdapters`, `defaultSsr`, `requestMiddleware`, `functionMiddleware`, `serverFns: { fetch }`다(`packages/start-client-core/src/createStart.ts:15-50`). `requestMiddleware`는 Start가 처리하는 모든 요청에 실행되고, `functionMiddleware`는 모든 서버 함수에 실행된다.
- 이 옵션들은 **새로 생긴 것이 아니다.** 은퇴한 2026-06-02 스냅샷보다 먼저 존재했다. 그 파일이 이들을 나열하지 않았을 뿐이므로, 누락은 상류 드리프트가 아니라 이 스킬 자체의 누락이었다.

## CSRF 보호

- `createCsrfMiddleware()`가 서버 함수를 교차 사이트 요청에서 보호하는 이름 있는 API다. 옵션은 `filter`, `origin`, `allowRequestsWithoutOriginCheck`이고, 기본적으로 `Origin`과 `Referer`를 들어온 요청 URL의 origin과 비교한다. `createCsrfMiddleware({ origin: 'https://app.example.com' })`로 다른 공개 origin을 허용한다.
- **앱이 `src/start.ts`를 정의하지 않으면 Start가 서버 함수용으로 이 미들웨어를 자동 설치한다.** 함정은 여기 있다. `src/start.ts`를 만들면 그 자동 설치가 조용히 빠지므로, 그 파일이 `requestMiddleware: [createCsrfMiddleware()]`를 명시적으로 넣어야 한다. `src/start.ts`가 있는데 이 미들웨어가 없으면 Start가 서버 함수 요청에 대해 개발 경고를 남긴다.

## 미들웨어

- 미들웨어는 두 종류다. 요청 미들웨어는 `createMiddleware()`를 쓴다. `createMiddleware({ type: 'request' })`도 허용되지만 요청 타입이 기본값이다. 서버 함수 미들웨어는 `createMiddleware({ type: 'function' })`를 쓰고 `.client(...)`와 `.server(...)` 단계를 정의할 수 있다.
- 서버 함수 미들웨어 검증도 `.validator(...)`를 쓴다. 같은 리네임이 두 체인 객체에 모두 적용되며, `createMiddleware.ts:182-183`이 `inputValidator`에 같은 `@deprecated` 표시를 달고 있다. 미들웨어 `.validator(...)`와 서버 함수 `.validator(...)`를 혼동하지 않는다. 둘은 서로 다른 체인 객체와 서로 다른 데이터 문맥에 속한다.
- `sendContext`는 명시적이고 홉마다 단방향이다. 클라이언트 문맥은 기본적으로 서버로 전송되지 않는다. `next({ sendContext: {...} })`로 넘겨야 한다. 클라이언트가 보낼 수 있는 값은 클라이언트가 거짓으로 바꿀 수 있으므로, `sendContext`로 도착한 값은 클라이언트가 제공한 데이터다.
- **"Shape validation is not authorization."** (`guide/middleware.md:348`.) 파싱된 UUID나 숫자는 형태가 올바른 식별자일 뿐, 권한이 부여된 식별자가 아니다. 그 값이 어떤 행을 읽거나 쓸지 고르는 데 쓰이면(쿼리 키, 필터, 경로 파라미터) 세션 주체가 그 값에 접근 권한이 있는지 따로 검증해야 한다. 그렇지 않으면 로그인한 사용자가 자기 요청에서 값을 바꿔 다른 테넌트의 데이터에 닿을 수 있다.
- 문서가 요구하는 패턴(`guide/middleware.md:377`): "Always derive the session itself from a server-trusted source (a cookie + DB lookup in `authMiddleware`), never from `sendContext`. Anything the client can send, the client can lie about."

## import protection

- **상태: Experimental.** 페이지는 `> **Experimental:** Import protection is experimental and subject to change.`로 시작한다. 옵션 표면을 불안정한 것으로 본다.
- 기본 활성화다. 문서화된 기본값은 `enabled: true`, `behavior: { dev: 'mock', build: 'error' }`(`'mock'`은 경고 후 mock 모듈로 대체하고 `'error'`는 빌드를 실패시킨다), `log: 'once'`(반복 위반을 중복 제거한다), 범위 `include` = Start의 `srcDirectory`, `maxTraceDepth: 20`이다.
- 기본 거부 규칙은 `client.files` = `['**/*.server.*']`, `server.files` = `['**/*.client.*']`, `client.specifiers` = 프레임워크 서버 specifier, `server.specifiers` = `[]`, 그리고 양쪽 `excludeFiles` = `['**/node_modules/**']`다.
- **함정은 replace 대 additive 구분이다.** 옵션 표(`guide/import-protection.md:561-567`)에 따르면 다음과 같다.
  - `client.specifiers`는 기본값에 **더해진다**(additive). 제공하면 내장 목록이 확장된다.
  - `client.files`, `client.excludeFiles`, `server.files`, `server.specifiers`, `server.excludeFiles`는 기본값을 **대체한다**. (`server.specifiers`는 "replaces defaults"로 적혀 있지만 기본값이 `[]`이므로 실제로는 additive가 아니다.)
  - `excludeFiles`는 `['**/node_modules/**']`를 **통째로 대체한다**. `node_modules`를 계속 건너뛰면서 경로를 더 제외하려면 둘 다 넘긴다: `excludeFiles: ['**/node_modules/**', '**/vendor/**']`.
  - 따라서 `'**/*.server.*'`를 함께 넣지 않고 `client.files`를 설정하면 기본 거부 규칙이 조용히 사라진다.
- `excludeFiles: []`는 기본값이 건너뛰는 위치(`node_modules` 등)의 resolved-target 검사를 다시 켠다. 권장이 아니라 의도적인 opt-in이다.
- type-only import와 re-export는 런타임에서 제거되므로 무시된다. 런타임 값을 하나라도 담은 mixed import는 여전히 검사 대상이다.
- 명시적 경계용 side-effect marker import는 그대로 쓸 수 있다: `@tanstack/react-start/server-only`, `@tanstack/react-start/client-only`.
- `mockAccess`(`'error' | 'warn' | 'off'`, 선택)는 `packages/start-plugin-core/src/schema.ts:42`에 있지만 **import protection 가이드에는 없다**. 실제 스키마 옵션이면서 문서가 다루지 않는 항목이므로, 인용할 때는 반드시 그 사실을 함께 적고 문서화된 옵션처럼 제시하지 않는다.

## 서버 라우트

- 서버 라우트는 route 파일의 `createFileRoute(...)(...)` 호출에 `server`를 추가해 선언하고, Router의 파일 기반 라우팅 규칙을 따른다.
- `server` 속성은 `handlers`를 담는다. HTTP 메서드를 핸들러 함수에 매핑한 객체이거나, 미들웨어 구성이 필요한 핸들러를 위해 `createHandlers`를 받는 함수다. 그리고 선택적인 `middleware` 배열이 모든 핸들러에 라우트 수준 미들웨어를 적용한다.
- 서버 라우트 미들웨어를 묶는 데 pathless layout route와 break-out route를 쓸 수 있다. pathless layout은 라우트 묶음에 미들웨어를 더하고, break-out route는 상위 미들웨어에서 빠져나온다.
- 같은 라우트 경로에 같은 HTTP 메서드가 중복되면 무효다. wildcard/splat 라우트는 끝에 `$`를 붙이는 파일 라우트 규칙을 쓴다.

## 드리프트 처리

- 이 파일은 날짜가 박힌 공식 문서 스냅샷이며 영구 규칙집이 아니다. 파일명 날짜와 `last_verified_at`은 구조상 일치한다. 둘 중 하나가 바뀌면 둘 다 함께 바꾼다.
- 갱신 트리거: 아래 공식 문서 페이지가 바뀌었을 때, 또는 권고 확인 시점에 다시 검증한다. 고정한 패키지 버전 집합을 넘어서는지를 트리거로 삼지 **않는다**. router/start는 PATCH 릴리스에서도 파괴적 변경을 흡수하므로 버전 기반 트리거는 과하게도, 모자라게도 발동한다.
- 로컬에 설치된 패키지 타입이 이 파일과 다르면 이 스냅샷을 고치지 말고 typecheck를 돌려 프로젝트별 예외를 기록한다.
- `src/modules`, `src/lib`, `src/db`, `src/server`, `src/integrations`, `src/config` 묶음은 공식 TanStack 요구사항이 아니라 Hypercore 관례다. `.functions.ts` / `.server.ts` 분리는 공식 지침이지만, 이를 `src/modules/<domain>/<feature>/` 중첩 폴더 안에서 강제하는 것은 Hypercore 관례다.

## Sources

> Sources checked 2026-09-22. Every page and source below was fetched directly on 2026-09-22 for this snapshot. The `guide/` path segment is required; the same pages without it return 404. Line numbers cited are positions in the 2026-09-22 fetched copy, so they will drift as the pages change — the quoted text is the stable anchor.

- <https://tanstack.com/start/latest/docs/framework/react/guide/server-functions.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/middleware.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/import-protection.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/server-routes.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns.md>
- <https://tanstack.com/start/latest/docs/framework/react/guide/environment-functions.md>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createServerFn.ts>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createMiddleware.ts>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createStart.ts>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-client-core/src/createCsrfMiddleware.ts>
- <https://raw.githubusercontent.com/TanStack/router/fe7f1fd0e6ef73c3f341dd2338b406749538a85d/packages/start-plugin-core/src/schema.ts>
- <https://api.github.com/repos/TanStack/router/pulls/7566>
