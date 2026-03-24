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
