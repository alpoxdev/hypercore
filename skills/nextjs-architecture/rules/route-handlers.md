# Route Handlers

> When `route.ts` is the right surface and when it is not.

---

## Use Route Handlers For

- webhooks
- feeds
- CORS-sensitive endpoints
- machine-readable public endpoints
- non-UI content such as XML, JSON, or streams
- HTTP-native integrations that need method-level handling, headers, status codes, or raw body access

## Do Not Default To Route Handlers For

- normal internal form mutations that fit Server Actions
- internal UI data reads that can be done in Server Components
- forwarding behavior that belongs in Proxy

If a mutation originates from app UI, assume Server Action first and justify `route.ts` only when HTTP semantics are the actual requirement.

## Current Facts

- Route Handlers are available in the App Router.
- A `route.ts` file supports standard HTTP method exports: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, and `OPTIONS`.
- Route Handlers use Web `Request` / `Response` APIs, with `NextRequest` / `NextResponse` when Next.js helpers are needed.
- Dynamic segment `params` are promise-shaped in current App Router examples; await them before use.
- Route Handlers share route segment config, but config behavior must be checked when `cacheComponents` is enabled.

## Hard Rules

| Check | Rule |
|---|---|
| `route.ts` and `page.tsx` placed in the same segment | BLOCKED |
| Route Handler used as default internal RPC for a UI-only flow | BLOCKED unless HTTP semantics are required |
| `NextResponse.next()` used inside a Route Handler | BLOCKED. That behavior belongs in Proxy |
| Route Handler caching assumed from old defaults without checking current behavior | BLOCKED |
| Custom Route Handler duplicates built-in metadata files such as sitemap, robots, icons, or Open Graph images without need | WARNING/BLOCKED by risk |

## Cache and Freshness

- For cached Route Handler data, state whether you use `revalidate`, `cacheTag`, `revalidateTag`, `generateStaticParams`, or another explicit strategy.
- When Cache Components are enabled, verify whether Route Handler prerendering follows the same model as pages for the target version.
- Do not rely on undocumented `GET` caching defaults for correctness-critical endpoints.

## Decision Rule

Choose:

1. Server Component for server-rendered UI reads
2. Server Action for internal UI mutations and forms
3. Route Handler only when the surface is genuinely HTTP-native
4. Proxy only for pre-route request boundary behavior

## Review Checklist

- The endpoint really needs HTTP semantics
- No `page.tsx` conflict exists
- Method exports and request/response handling are explicit
- Current caching behavior is understood and documented
- Proxy-specific behavior is not leaking into the Route Handler
