# 공식 보안 메모

변경이 현재 프레임워크나 auth stack 동작에 직접 의존할 때 이 참조 파일을 읽습니다.

## TanStack Start

- 실행 모델상 route `loader`는 secret-safe 경계가 아닙니다. privileged work는 `createServerFn` 또는 `createServerOnlyFn` 뒤에 둡니다.
- code execution pattern에서는 explicit server-only / client-only function을 환경 누수 방지 기본 수단으로 봅니다.
- environment variable 가이드는 secret은 서버에 두고, public env 노출은 의도적으로만 하라고 요구합니다.

주요 문서:

- https://tanstack.com/start/latest/docs/framework/react/guide/execution-model
- https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns
- https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables
- https://tanstack.com/start/latest/docs/framework/react/guide/server-functions
- https://tanstack.com/start/latest/docs/framework/react/guide/middleware
- https://tanstack.com/router/latest/docs/guide/authenticated-routes
- https://tanstack.com/router/latest/docs/how-to/validate-search-params
- https://tanstack.com/router/latest/docs/guide/ssr

## Better Auth

- TanStack Start 통합에서는 서버 세션 helper와 route `beforeLoad` 조합이 보호된 UI 패턴으로 자주 쓰입니다.
- `tanstackStartCookies()`를 쓰면 Better Auth plugin 배열의 마지막에 두어야 합니다.
- cross-origin 또는 multi-subdomain auth flow가 있으면 `trustedOrigins`, cross-subdomain cookie 설정을 명시적으로 다뤄야 합니다.

주요 문서:

- https://www.better-auth.com/docs/integrations/tanstack
- https://www.better-auth.com/docs/installation
- https://www.better-auth.com/docs/concepts/cookies
- https://www.better-auth.com/docs/reference/security
- https://www.better-auth.com/docs/concepts/rate-limit

## 사용 메모

저장소가 다른 auth provider를 쓰면, TanStack 실행 경계 규칙은 유지하고 Better Auth 전용 가이드는 해당 provider의 공식 요구사항으로 대체합니다.

## Sources

> 링크 확인 2026-09-22: 위에 적힌 문서 URL 전부가 그 날짜에 HTTP 200을 반환했습니다. 그 밖의 외부 출처는 사용하지 않았습니다.

- TanStack Start·TanStack Router 가이드(실행 모델, code execution pattern, environment variable, server function, middleware, authenticated route, search param 검증, SSR): 위 `TanStack Start` 절의 `주요 문서` 목록이며 출처는 https://tanstack.com/ 입니다.
- Better Auth 문서(TanStack Start 통합, 설치, cookie, security, rate limit): 위 `Better Auth` 절의 `주요 문서` 목록이며 출처는 https://www.better-auth.com/ 입니다.
- `사용 메모` 절은 Better Auth가 아닌 stack을 위한 이 패키지 자체 지침이며 외부 출처를 인용하지 않습니다.
