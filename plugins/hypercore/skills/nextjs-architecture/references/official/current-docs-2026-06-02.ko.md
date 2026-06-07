# Current Official Next.js Docs Snapshot — 2026-06-02

> drift-sensitive Next.js architecture decision을 위한 Context7 확인 official docs facts입니다. cache, Proxy, Route Handler, Server Action behavior가 중요하면 older doc map보다 먼저 사용합니다.

checked_at: 2026-06-02
library_id: `/vercel/next.js`, `/vercel/next.js/v16.2.2`
source_priority: Context7를 통한 official Next.js docs. `https://github.com/vercel/next.js/blob/v16.2.2/docs/...` 및 canonical `https://nextjs.org/docs/...` page 기반.

## Current Official Facts

- App Router는 React Server Components 기반이며 layouts, nested routes, loading states, error handling, `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, `route.ts` 같은 special files를 쓰는 file-system routing입니다.
- App Router에서 pages와 layouts는 기본적으로 Server Components입니다. Interactivity, browser APIs, client hooks가 필요한 client entry point에만 `'use client'`를 추가합니다.
- optional `src/` directory는 project organization 선택이고, `app/`, `pages/`, `public/`은 framework-level meaning이 있습니다. `src/lib`, `src/services` 같은 shared folders는 repo-local convention이며 official Next.js requirement가 아닙니다.
- Route groups는 URL path를 바꾸지 않고 routes를 organize합니다. `_components`, `_lib` 같은 private folders는 segment-local non-routable internals에 사용합니다.
- Next.js 16은 `cacheComponents: true`를 Cache Components switch로 사용합니다. 이는 `use cache` model을 활성화하며 older experimental PPR / dynamic IO flags를 대체합니다.
- `cacheComponents` 사용 시 `dynamic`, `revalidate`, `fetchCache` 같은 route segment config options를 새 모델로 삼지 말고 current Cache Components primitives와 current segment options를 사용합니다.
- `use cache`, `use cache: remote`, `use cache: private`는 서로 다른 caching directives입니다. `cacheTag`, `cacheLife`는 invalidation/lifetime intent를 문서화합니다.
- `connection()`은 request-time dynamic rendering을 표시하며 deprecated `unstable_noStore` 대신 new work에서 선호되는 path입니다.
- Server Actions / Server Functions는 reachable mutation surface입니다. Input validation, authentication, authorization, minimal client-safe return shaping을 action 또는 delegated server-only layer에서 수행합니다.
- UI mutation 후 read-your-own-writes에는 Server Action-only `updateTag`를 사용합니다. `revalidateTag`는 broader stale-while-revalidate invalidation에 사용하며 deprecated single-argument usage 대신 `'max'` 같은 profile을 사용합니다.
- Route Handlers는 `GET`, `POST`, `PUT`, `PATCH`, `DELETE` 같은 HTTP method exports를 사용합니다. Webhooks, feeds, CORS endpoints, streams, public machine-readable responses 같은 HTTP-native contracts에 사용합니다.
- Cache Components 사용 시 `GET` Route Handlers는 UI routes와 같은 prerendering model을 따릅니다. `use cache`가 필요하면 handler body가 아니라 helper function 안에 둡니다.
- `NextResponse.next()`는 Route Handlers 내부에서 valid하지 않고 Proxy-style request continuation에 속합니다.
- Next.js 16은 old `middleware` file convention을 `proxy.ts` / `proxy.js`로 대체하며 deprecate합니다. official codemod는 `npx @next/codemod@latest middleware-to-proxy .`입니다.
- Proxy는 project root 또는 `src/` root에 둘 수 있고 Node.js runtime이 default입니다. `next.config.*` redirects, rewrites, headers, render-time logic을 먼저 확인한 뒤 last-resort network-boundary tool로 사용합니다.
- Environment variables는 project-root `.env*` files에서 load되며 `src/`에서 load된다고 가정하지 않습니다. Browser code에는 `NEXT_PUBLIC_` variables만 bundle되고 public values는 build-time inline됩니다.

## Architecture Implications

- `src/lib/<domain>/`, `src/services/<domain-or-provider>/`는 Hypercore/repo-local convention으로 취급합니다. Ownership/runtime boundary에는 유용하지만 official Next.js law는 아닙니다.
- Project exception이 기록되지 않는 한 touched shared roots에 `src/lib/foo.ts`, `src/services/foo.ts` 같은 new direct leaf files를 추가하지 않습니다.
- Initial reads는 Server Components, internal UI writes는 Server Actions, HTTP-native endpoints는 Route Handlers, pre-render interception은 last-resort Proxy를 우선 순서로 검토합니다.
- stale default assumptions에 의존하기 전에 current Cache Components semantics로 cache behavior를 review합니다.

## Source URLs Checked

- `https://nextjs.org/docs/app/getting-started/project-structure`
- `https://nextjs.org/docs/app/getting-started/server-and-client-components`
- `https://nextjs.org/docs/app/getting-started/caching`
- `https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents`
- `https://nextjs.org/docs/app/api-reference/directives/use-cache`
- `https://nextjs.org/docs/app/api-reference/directives/use-cache-remote`
- `https://nextjs.org/docs/app/api-reference/directives/use-cache-private`
- `https://nextjs.org/docs/app/api-reference/functions/connection`
- `https://nextjs.org/docs/app/api-reference/file-conventions/route`
- `https://nextjs.org/docs/app/api-reference/file-conventions/proxy`
- `https://nextjs.org/docs/app/guides/environment-variables`
- `https://nextjs.org/docs/app/guides/data-security`
- `https://nextjs.org/docs/app/guides/upgrading/version-16`
