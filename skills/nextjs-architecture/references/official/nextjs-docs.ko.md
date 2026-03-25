# Next.js 공식 문서 지도

> 이 스킬이 기반으로 삼은 공식 문서 표면입니다. 동작이 바뀌었거나 규칙이 애매하면 여기부터 다시 확인하세요.

## 핵심 소스

- Project Structure
  URL: `https://nextjs.org/docs/app/getting-started/project-structure`
  용도: App Router 파일 규칙, route group, private folder, colocated file

- Server and Client Components
  URL: `https://nextjs.org/docs/app/getting-started/server-and-client-components`
  용도: `'use client'`, provider 위치, 서버/클라이언트 조합, 번들 경계 판단

- Fetching Data
  URL: `https://nextjs.org/docs/app/getting-started/fetching-data`
  용도: 서버 우선 데이터 페칭, 스트리밍, Suspense, request memoization 기초

- Caching
  URL: `https://nextjs.org/docs/app/getting-started/caching`
  용도: 캐시 의도, dynamic vs cached 동작, freshness 판단

- Updating Data
  URL: `https://nextjs.org/docs/app/getting-started/updating-data`
  용도: Server Action mutation 흐름, revalidation, redirect 순서, 서버 왕복 기반 업데이트

- Forms
  URL: `https://nextjs.org/docs/app/guides/forms`
  용도: Server Actions 기반 form 처리, 검증 패턴, action 내부 auth/authz 재확인

- Error Handling
  URL: `https://nextjs.org/docs/app/getting-started/error-handling`
  용도: expected error, `error.tsx`, `notFound()`, 중첩 경계

- `use server`
  URL: `https://nextjs.org/docs/app/api-reference/directives/use-server`
  용도: Server Action 배치, auth/authz 기대치, 최소 반환값

- Route Handlers
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/route`
  용도: `route.ts`, 메서드 기반 HTTP 처리, segment config, non-UI 응답

- Proxy
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/proxy`
  용도: `proxy.ts`, matcher 배치, 렌더 전 요청 처리, middleware 명칭 변경

- Environment Variables
  URL: `https://nextjs.org/docs/app/guides/environment-variables`
  용도: `.env*` 로딩, `NEXT_PUBLIC_`, runtime vs build-time env 동작, `@next/env`

- Redirecting
  URL: `https://nextjs.org/docs/app/guides/redirecting`
  용도: mutation redirect, `revalidatePath` / `revalidateTag` 순서, prerender 전 redirect 전략

- Data Security
  URL: `https://nextjs.org/docs/app/guides/data-security`
  용도: DAL 가이드, `server-only`, Server Action 보안, action 내부 auth/authz, 반환값 최소화

## 해석 규칙

- 오래된 커뮤니티 습관보다 최신 공식 문서를 우선합니다.
- 새 Next.js 릴리스가 caching, Proxy, Server Action 동작을 바꾸면 `SKILL.md`를 비대하게 만들지 말고 해당 rule 파일을 갱신하세요.
- 로컬 저장소 규칙이 공식 문서보다 더 엄격하면, 리뷰와 변경 보고에서 로컬 컨벤션이라고 명시하세요.
