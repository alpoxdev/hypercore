# 플랫폼과 환경 변수

> `next.config.*`, env 처리, Proxy, 배포 민감 설정 규칙.

---

## 환경 변수

- `.env*` 파일은 `src/`가 아니라 프로젝트 루트에 있어야 합니다
- `NEXT_PUBLIC_`이 아닌 env는 서버 전용입니다
- `NEXT_PUBLIC_` 값은 브라우저 번들에 build time에 inline 됩니다
- 클라이언트가 runtime 값을 필요로 하면, public env처럼 가장하지 말고 서버 경로/API로 노출하세요
- Next 런타임 밖에서 env를 로드해야 하면 `@next/env`를 사용합니다

## runtime env 규칙

서버 코드는 dynamic rendering 중 runtime env를 읽을 수 있습니다. 서버의 runtime env와 클라이언트 번들에 build time inline 되는 env를 혼동하면 안 됩니다.

## Proxy

- `proxy.ts`는 프로젝트 루트나 `src/` 루트에 있어야 하며 `app` 또는 `pages`와 같은 레벨이어야 합니다
- Proxy는 라우트 렌더링 전에 실행됩니다
- 가능하면 Proxy보다 `redirects`, `rewrites`, headers, cookies, render-time 로직을 먼저 검토합니다
- Proxy는 명시적인 matcher와 좁은 범위를 가져야 합니다
- Proxy 내부에서 shared module/global에 의존하지 마세요

## 중요한 Proxy 메모

기존 `middleware` 파일 규칙은 deprecated 되었고 이름이 `proxy`로 바뀌었습니다. 새 작업에 `middleware.ts`를 새로 추가하지 마세요.

## `next.config.*`

다음 항목을 바꿀 때는 항상 명시적 의도와 함께 검토하세요:

- `typedRoutes`
- `experimental.serverActions.allowedOrigins`
- 캐싱 관련 설정
- redirect / rewrite 규칙
- output / 배포 설정

## 권장 플랫폼 체크

- TypeScript App Router 프로젝트에서 라우트 안정성이 중요하면 `typedRoutes: true`를 검토합니다
- reverse proxy / multi-proxy 배포에서는 Server Action origin 설정이 필요한지 확인합니다
- 배포 민감 설정을 바꿨다면 PR이나 최종 보고에 남깁니다

## 리뷰 체크리스트

- `.env*` 처리가 Next.js 동작과 일치하는지
- client 코드가 `NEXT_PUBLIC_` env만 보는지
- Proxy가 정말 필요한지, matcher 범위가 좁은지
- `next.config.*` 변경 의도와 영향이 설명되는지
