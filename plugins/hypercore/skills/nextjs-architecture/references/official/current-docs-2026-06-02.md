# Current Official Next.js Docs Snapshot — 2026-06-02

> Context7-checked official documentation facts for drift-sensitive Next.js architecture decisions. Use this file before older doc maps when cache, Proxy, route handler, or Server Action behavior matters.

checked_at: 2026-06-02
library_id: `/vercel/next.js` and `/vercel/next.js/v16.2.2`
source_priority: official Next.js docs via Context7, backed by `https://github.com/vercel/next.js/blob/v16.2.2/docs/...` and canonical `https://nextjs.org/docs/...` pages.

## Current Official Facts

- App Router is built on React Server Components and uses file-system routing with layouts, nested routes, loading states, error handling, and special files such as `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, and `route.ts`.
- In App Router, pages and layouts are Server Components by default. Add `'use client'` only at client entry points that need interactivity, browser APIs, or client hooks.
- The optional `src/` directory is a project organization choice, while `app/`, `pages/`, and `public/` have framework-level meanings. Shared folders such as `src/lib` or `src/services` are repo-local conventions, not official Next.js requirement.
- Route groups organize routes without changing URL paths. Private folders such as `_components` or `_lib` opt implementation code out of routing and should be used for segment-local non-routable internals.
- Next.js 16 uses `cacheComponents: true` as the Cache Components switch. It enables the `use cache` model and replaces older experimental PPR / dynamic IO flags.
- With `cacheComponents`, route segment config options such as `dynamic`, `revalidate`, and `fetchCache` are not the model to use; prefer current Cache Components primitives and current segment options.
- `use cache`, `use cache: remote`, and `use cache: private` are distinct caching directives. `cacheTag` and `cacheLife` document invalidation and lifetime intent.
- `connection()` marks request-time dynamic rendering and is the preferred replacement path for new work that previously might have used deprecated `unstable_noStore`.
- Server Actions / Server Functions are reachable mutation surfaces. Validate input, authenticate, authorize, and return minimal client-safe data inside the action or a delegated server-only layer.
- For read-your-own-writes after UI mutations, `updateTag` is Server Action-only. `revalidateTag` works for broader stale-while-revalidate invalidation and should use a profile such as `'max'` rather than deprecated single-argument usage.
- Route Handlers use HTTP method exports such as `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`. Use them for HTTP-native contracts such as webhooks, feeds, CORS endpoints, streams, and public machine-readable responses.
- With Cache Components, `GET` Route Handlers follow the same prerendering model as UI routes. If `use cache` is needed, put it in a helper function rather than directly in the handler body.
- `NextResponse.next()` is not valid inside Route Handlers; it belongs to Proxy-style request continuation.
- Next.js 16 deprecates the old `middleware` file convention in favor of `proxy.ts` / `proxy.js`. The official codemod is `npx @next/codemod@latest middleware-to-proxy .`.
- Proxy can live at the project root or `src/` root, defaults to the Node.js runtime, and should be a last-resort network-boundary tool after checking `next.config.*` redirects, rewrites, headers, and render-time logic.
- Environment variables are loaded from project-root `.env*` files, not from `src/`. Only `NEXT_PUBLIC_` variables are bundled for browser code, and public values are build-time inlined.

## Architecture Implications

- Treat `src/lib/<domain>/` and `src/services/<domain-or-provider>/` as Hypercore/repo-local conventions. They are useful for ownership and runtime boundaries but not official Next.js law.
- Do not add new direct leaf files such as `src/lib/foo.ts` or `src/services/foo.ts` in touched shared roots unless the project records an explicit exception.
- Prefer Server Components for initial reads, Server Actions for internal UI writes, Route Handlers for HTTP-native endpoints, and Proxy only for last-resort pre-render interception.
- Review cache behavior with current Cache Components semantics before relying on stale default assumptions.

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
