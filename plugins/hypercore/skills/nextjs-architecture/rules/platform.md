# Platform and Environment

> `next.config.*`, env handling, route segment config, Proxy, and deployment-sensitive setup.

---

## Environment Variables

- `.env*` files belong at the project root, not inside `src/`.
- Non-`NEXT_PUBLIC_` env vars are server-only.
- `NEXT_PUBLIC_` values are inlined at build time into browser bundles.
- If the client needs runtime values, expose them through a server path instead of pretending they are runtime-public env vars.
- If code outside the Next runtime needs env loading, use `@next/env`.

## Runtime Env Rule

Server code can read runtime env values during dynamic rendering. Do not confuse runtime server env with build-time inlined client env.

## Cache Components and Route Segment Config

- `cacheComponents: true` is the Next.js 16+ unified switch for Cache Components, PPR, `useCache`, and `dynamicIO` behavior.
- When `cacheComponents` is enabled, v16 removes `dynamic`, `revalidate`, and `fetchCache` route segment options; use the Cache Components model instead.
- Current route segment options include `dynamicParams`, `runtime`, `preferredRegion`, and `maxDuration`; they affect Server Component pages, layouts, and Route Handlers.
- `runtime` defaults to `'nodejs'`; `runtime: 'edge'` is a deployment/platform decision that must be verified for the libraries and APIs used.
- Deployment platforms may use `maxDuration`; document changes that alter execution limits.

## Proxy

- `proxy.ts` belongs at the project root or `src/` root, next to `app` or `pages`.
- Proxy runs before routes are rendered and represents a network boundary in front of app render code.
- Prefer `redirects`, `rewrites`, headers, cookies, or render-time logic before reaching for Proxy.
- Proxy should have an explicit matcher and narrow scope; without a matcher it runs on every request, including `_next/static`, `_next/image`, and public assets.
- Matcher values must be static constants so Next.js can analyze them at build time.
- Do not rely on shared modules or globals inside Proxy.
- Exclude API routes, metadata, static surfaces, image optimization, and public assets from broad matchers when they should bypass Proxy.
- Server Functions are POST requests to the route where they are used; matcher changes can silently remove Proxy coverage, so auth/authz must still live inside the Server Function or DAL.

## Important Proxy Note

The old `middleware` file convention is deprecated and has been renamed to `proxy`. Do not add fresh `middleware.ts` files for new work. Use the official `npx @next/codemod@canary middleware-to-proxy .` codemod for migrations when needed. Proxy defaults to the Node.js runtime and does not accept a `runtime` config option.

## `next.config.*`

Keep config changes explicit and intentional. Review carefully when changing:

- `typedRoutes`
- `serverActions.allowedOrigins`
- `cacheComponents`, `cacheLife`, `cacheHandlers`, or experimental `authInterrupts`
- route segment config strategy, especially removed v16 options under `cacheComponents`
- redirect and rewrite rules
- output and deployment settings

## Recommended Platform Checks

- Consider `typedRoutes: true` in TypeScript App Router projects where route-safety matters.
- In multi-proxy or reverse-proxy deployments, verify whether Server Action origin configuration is needed.
- Keep deployment-sensitive settings documented in the PR or final report when changed.

## Review Checklist

- `.env*` handling matches Next.js behavior
- Client code sees only `NEXT_PUBLIC_` env vars
- Cache Components and removed v16 route segment config options are not mixed accidentally
- Proxy is truly justified, statically matched, and narrowly scoped
- `next.config.*` changes are intentional and explained
