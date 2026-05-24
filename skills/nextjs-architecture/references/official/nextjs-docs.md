# Official Next.js Docs Map

> Canonical official doc surfaces this skill depends on. Re-check these when behavior drifts or a rule becomes ambiguous.

Last verified: 2026-05-24 against latest stable Next.js 16.2.6 (`npm dist-tag latest`).

Reader access rule: when re-checking official docs, prefer Jina Reader markdown URLs in the form `https://r.jina.ai/https://nextjs.org/docs/...` so agents can inspect the current page text without relying on browser rendering. Keep the canonical URL listed below as the original source URL.

## Core Sources

- App Router index
  URL: `https://nextjs.org/docs/app`
  Use for: current App Router learning path and official navigation.

- Project Structure
  URL: `https://nextjs.org/docs/app/getting-started/project-structure`
  Use for: top-level folders, `app` / `pages` / `public` / `src`, route groups, private folders, metadata conventions, and organization strategies.

- File-system Conventions
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions`
  Use for: special files including `page`, `layout`, `loading`, `error`, `not-found`, `forbidden`, `unauthorized`, `route`, `proxy`, metadata files, and route segment config.

- Server and Client Components
  URL: `https://nextjs.org/docs/app/getting-started/server-and-client-components`
  Use for: Server Component default, `'use client'` boundaries, serializable props, provider depth, RSC payload, and `server-only` / `client-only` guidance.

- Fetching Data
  URL: `https://nextjs.org/docs/app/getting-started/fetching-data`
  Use for: server-first fetching, streaming, `<Suspense>`, request memoization basics, and client fetching boundaries.

- Caching
  URL: `https://nextjs.org/docs/app/getting-started/caching`
  Use for: Cache Components, runtime data handling, `connection()`, `use cache`, `use cache: remote`, rendering model, Route Handler Cache Components note, and Suspense requirements.

- Caching and Revalidating
  URL: `https://nextjs.org/docs/app/getting-started/caching-and-revalidating`
  Use for: `fetch` cache options, `cacheTag`, `revalidateTag`, `updateTag`, `revalidatePath`, and `unstable_cache` legacy status.

- `use cache`
  URL: `https://nextjs.org/docs/app/api-reference/directives/use-cache`
  Use for: `cacheComponents` requirement, cached scopes, cache keys, serialization constraints, request-time API restrictions, `cacheLife`, `cacheTag`, and platform support.

- `use cache: private`
  URL: `https://nextjs.org/docs/app/api-reference/directives/use-cache-private`
  Use for: experimental private cache behavior, request API exceptions, browser-memory-only constraints, and production-risk review.

- `use cache: remote`
  URL: `https://nextjs.org/docs/app/api-reference/directives/use-cache-remote`
  Use for: durable shared cache tradeoffs, `cacheHandlers`, runtime-data cache keys, nesting rules, and cost/latency review.

- `cacheComponents`
  URL: `https://nextjs.org/docs/app/api-reference/config/next-config-js/cacheComponents`
  Use for: enabling Cache Components and understanding its relationship to `use cache`, `cacheLife`, and `cacheTag`.

- Updating Data
  URL: `https://nextjs.org/docs/app/getting-started/updating-data`
  Use for: Server Action mutation flow, `refresh`, revalidation, cookie updates, and redirect ordering.

- Forms
  URL: `https://nextjs.org/docs/app/guides/forms`
  Use for: Server Actions in forms, `FormData`, validation, pending states, optimistic updates, and `useActionState`.

- `use server`
  URL: `https://nextjs.org/docs/app/api-reference/directives/use-server`
  Use for: dedicated action files, inline Server Functions, and auth/authz expectations.

- Route Handlers guide
  URL: `https://nextjs.org/docs/app/getting-started/route-handlers`
  Use for: default caching behavior, Cache Components `GET` prerendering model, `use cache` helper placement, special metadata handlers, and route resolution.

- Route Handlers API
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/route`
  Use for: `route.ts`, HTTP method exports, Web Request/Response APIs, cookies/headers, promise-shaped dynamic params, `RouteContext`, CORS, webhooks, streaming, and non-UI responses.

- Route Segment Config
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/route-segment-config`
  Use for: current `dynamicParams`, `runtime`, `preferredRegion`, `maxDuration`, and the v16 removal of `dynamic`, `revalidate`, and `fetchCache` when `cacheComponents` is enabled.

- Proxy
  URL: `https://nextjs.org/docs/app/api-reference/file-conventions/proxy`
  Use for: `proxy.ts`, static matcher placement, negative matching for `_next/static` / `_next/image` / public assets, pre-render request handling, Node.js runtime default, Proxy as last resort, and Middleware-to-Proxy migration.

- Environment Variables
  URL: `https://nextjs.org/docs/app/guides/environment-variables`
  Use for: `.env*` loading, `NEXT_PUBLIC_`, runtime vs build-time env behavior, and `@next/env`.

- Redirecting
  URL: `https://nextjs.org/docs/app/guides/redirecting`
  Use for: redirect surfaces, Server Action redirects, `next.config.*` redirects, and pre-render redirect strategy.

- Data Security
  URL: `https://nextjs.org/docs/app/guides/data-security`
  Use for: DAL guidance, `server-only`, Server Action security, auth/authz inside actions, and return-value minimization.

- Authentication
  URL: `https://nextjs.org/docs/app/guides/authentication`
  Use for: multi-entry-point auth cautions, Server Action access, Proxy optimistic checks, and route protection patterns.

- `connection`
  URL: `https://nextjs.org/docs/app/api-reference/functions/connection`
  Use for: request-time rendering opt-in and replacement guidance for deprecated `unstable_noStore`.

- `unstable_noStore`
  URL: `https://nextjs.org/docs/app/api-reference/functions/unstable_noStore`
  Use for: legacy maintenance only; v15+ docs recommend `connection` instead.

- `authInterrupts`
  URL: `https://nextjs.org/docs/app/api-reference/config/next-config-js/authInterrupts`
  Use for: experimental `forbidden` / `unauthorized` enablement and production-risk review.

## Drift Watchlist

Re-check official docs before relying on these behaviors:

- Cache Components defaults, `cacheComponents`, `use cache`, `use cache: remote`, experimental `use cache: private`, `cacheLife`, `cacheTag`, `updateTag`, and `revalidateTag` profile semantics.
- Route Segment Config availability, especially v16 removals under `cacheComponents`.
- Route Handler `GET` caching/prerender behavior and `use cache` helper placement.
- Proxy runtime/platform support, static matcher behavior, and Middleware migration guidance.
- Experimental `authInterrupts`, `forbidden`, and `unauthorized` stability.
- Server Action origin, encryption, and allowed origin settings.

## Interpretation Rules

- Prefer latest official docs over stale community habits.
- If a newer Next.js release changes caching, Proxy, Route Handler, or Server Action behavior, update the relevant rule file rather than bloating `SKILL.md`.
- When local repo conventions exceed the docs, label them as local conventions in reviews and change reports.
- Treat this file as a doc map, not a replacement for rereading official docs on version-sensitive work.
