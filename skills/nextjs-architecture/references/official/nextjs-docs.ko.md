# Official Next.js Docs Map

> 이 skill이 의존하는 공식 문서 surface입니다. behavior가 drift되거나 rule이 모호하면 다시 확인합니다.

Last verified: 2026-05-05.

## Core Sources

- App Router index
  URL: `https://nextjs.org/docs/app`
  Use for: 현재 App Router learning path와 official navigation.

- Project Structure
  URL: `https://nextjs.org/docs/app/getting-started/project-structure`
  Use for: top-level folders, `app` / `pages` / `public` / `src`, route groups, private folders, metadata conventions, organization strategies.

- File-system Conventions
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions`
  Use for: `page`, `layout`, `loading`, `error`, `not-found`, `forbidden`, `unauthorized`, `route`, `proxy`, metadata files, route segment config 같은 special files.

- Server and Client Components
  URL: `https://nextjs.org/docs/app/getting-started/server-and-client-components`
  Use for: Server Component default, `'use client'` boundaries, serializable props, provider depth, RSC payload, `server-only` / `client-only` guidance.

- Fetching Data
  URL: `https://nextjs.org/docs/app/getting-started/fetching-data`
  Use for: server-first fetching, streaming, `<Suspense>`, request memoization basics, client fetching boundaries.

- Caching
  URL: `https://nextjs.org/docs/app/getting-started/caching`
  Use for: Cache Components, runtime data handling, `connection()`, `use cache`, rendering model, Suspense requirements.

- Caching and Revalidating
  URL: `https://nextjs.org/docs/app/getting-started/caching-and-revalidating`
  Use for: `fetch` cache options, `cacheTag`, `revalidateTag`, `updateTag`, `revalidatePath`, `unstable_cache` legacy status.

- `use cache`
  URL: `https://nextjs.org/docs/app/api-reference/directives/use-cache`
  Use for: `cacheComponents` requirement, cached scopes, cache keys, serialization constraints, `cacheLife`, `cacheTag`, platform support.

- `cacheComponents`
  URL: `https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents`
  Use for: Cache Components 활성화와 `use cache`, `cacheLife`, `cacheTag` 관계 이해.

- Updating Data
  URL: `https://nextjs.org/docs/app/getting-started/updating-data`
  Use for: Server Action mutation flow, `refresh`, revalidation, cookie updates, redirect ordering.

- Forms
  URL: `https://nextjs.org/docs/app/guides/forms`
  Use for: forms에서 Server Actions, `FormData`, validation, pending states, optimistic updates, `useActionState`.

- `use server`
  URL: `https://nextjs.org/docs/app/api-reference/directives/use-server`
  Use for: dedicated action files, inline Server Functions, auth/authz expectations.

- Route Handlers
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/route`
  Use for: `route.ts`, HTTP method exports, Web Request/Response APIs, cookies/headers, dynamic params, CORS, webhooks, streaming, non-UI responses.

- Route Segment Config
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config`
  Use for: `dynamic`, `dynamicParams`, `revalidate`, `fetchCache`, `runtime`, `preferredRegion`, `maxDuration`, `cacheComponents` compatibility warning.

- Proxy
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/proxy`
  Use for: `proxy.ts`, matcher placement, pre-render request handling, last-resort Proxy, Middleware-to-Proxy migration.

- Environment Variables
  URL: `https://nextjs.org/docs/app/guides/environment-variables`
  Use for: `.env*` loading, `NEXT_PUBLIC_`, runtime vs build-time env behavior, `@next/env`.

- Redirecting
  URL: `https://nextjs.org/docs/app/guides/redirecting`
  Use for: redirect surfaces, Server Action redirects, `next.config.*` redirects, pre-render redirect strategy.

- Data Security
  URL: `https://nextjs.org/docs/app/guides/data-security`
  Use for: DAL guidance, `server-only`, Server Action security, action 내부 auth/authz, return-value minimization.

- Authentication
  URL: `https://nextjs.org/docs/app/guides/authentication`
  Use for: multi-entry-point auth cautions, Server Action access, route protection patterns.

## Drift Watchlist

다음 behavior에 의존하기 전 공식 문서를 다시 확인합니다:

- Cache Components defaults, `cacheComponents`, `use cache`, `cacheLife`, `cacheTag`, `updateTag`, `revalidateTag` profile semantics.
- `cacheComponents`와 Route Segment Config availability/compatibility.
- Route Handler `GET` caching/prerender behavior.
- Proxy runtime/platform support 및 Middleware migration guidance.
- Server Action origin, encryption, allowed origin settings.

## Interpretation Rules

- stale community habits보다 최신 official docs를 우선합니다.
- 새 Next.js release가 caching, Proxy, Route Handler, Server Action behavior를 바꾸면 `SKILL.md`를 부풀리지 말고 관련 rule file을 업데이트합니다.
- local repo conventions가 docs보다 엄격하면 reviews와 change reports에서 local convention으로 표시합니다.
- 이 파일은 doc map이며 version-sensitive work에서는 official docs를 다시 읽어야 합니다.
