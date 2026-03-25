# Platform and Environment

> `next.config.*`, env handling, Proxy, and deployment-sensitive setup.

---

## Environment Variables

- `.env*` files belong at the project root, not inside `src/`
- Non-`NEXT_PUBLIC_` env vars are server-only
- `NEXT_PUBLIC_` values are inlined at build time into browser bundles
- If the client needs runtime values, expose them through a server path instead of pretending they are runtime-public env vars
- If code outside the Next runtime needs env loading, use `@next/env`

## Runtime Env Rule

Server code can read runtime env values during dynamic rendering. Do not confuse runtime server env with build-time inlined client env.

## Proxy

- `proxy.ts` belongs at the project root or `src/` root, next to `app` or `pages`
- Proxy runs before routes are rendered
- Prefer `redirects`, `rewrites`, headers, cookies, or render-time logic before reaching for Proxy
- Proxy should have an explicit matcher and a narrow scope
- Do not rely on shared modules or globals inside Proxy

## Important Proxy Note

The old `middleware` file convention is deprecated and has been renamed to `proxy`. Do not add fresh `middleware.ts` files for new work.

## `next.config.*`

Keep config changes explicit and intentional. Review carefully when changing:

- `typedRoutes`
- `experimental.serverActions.allowedOrigins`
- caching-related settings
- redirect and rewrite rules
- output and deployment settings

## Recommended Platform Checks

- Consider `typedRoutes: true` in TypeScript App Router projects where route-safety matters
- In multi-proxy or reverse-proxy deployments, verify whether Server Action origin configuration is needed
- Keep deployment-sensitive settings documented in the PR or final report when changed

## Review Checklist

- `.env*` handling matches Next.js behavior
- Client code sees only `NEXT_PUBLIC_` env vars
- Proxy is truly justified and narrowly matched
- `next.config.*` changes are intentional and explained
