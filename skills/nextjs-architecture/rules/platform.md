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

- `cacheComponents: true` is the Next.js 16+ unified switch for Cache Components.
- When `cacheComponents` is enabled, route segment config options are disabled and marked for future deprecation.
- Route segment options only affect Server Component pages, layouts, and Route Handlers.
- `runtime: 'edge'` is not supported for Cache Components; use the Node.js runtime unless a documented exception applies.
- Deployment platforms may use `maxDuration`; document changes that alter execution limits.

## Proxy

- `proxy.ts` belongs at the project root or `src/` root, next to `app` or `pages`.
- Proxy runs before routes are rendered and represents a network boundary in front of app render code.
- Prefer `redirects`, `rewrites`, headers, cookies, or render-time logic before reaching for Proxy.
- Proxy should have an explicit matcher and narrow scope.
- Do not rely on shared modules or globals inside Proxy.
- Exclude metadata and static surfaces from broad matchers when they should bypass Proxy.

## Important Proxy Note

The old `middleware` file convention is deprecated and has been renamed to `proxy`. Do not add fresh `middleware.ts` files for new work. Use the official codemod for migrations when needed.

## `next.config.*`

Keep config changes explicit and intentional. Review carefully when changing:

- `typedRoutes`
- `serverActions.allowedOrigins`
- `cacheComponents`, `cacheLife`, or `cacheHandlers`
- route segment config strategy
- redirect and rewrite rules
- output and deployment settings

## Recommended Platform Checks

- Consider `typedRoutes: true` in TypeScript App Router projects where route-safety matters.
- In multi-proxy or reverse-proxy deployments, verify whether Server Action origin configuration is needed.
- Keep deployment-sensitive settings documented in the PR or final report when changed.

## Review Checklist

- `.env*` handling matches Next.js behavior
- Client code sees only `NEXT_PUBLIC_` env vars
- Cache Components and route segment config are not mixed accidentally
- Proxy is truly justified and narrowly matched
- `next.config.*` changes are intentional and explained
