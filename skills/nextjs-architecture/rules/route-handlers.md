# Route Handlers

> When `route.ts` is the right surface and when it is not.

---

## Use Route Handlers For

- webhooks
- feeds
- CORS-sensitive endpoints
- machine-readable public endpoints
- non-UI content such as XML or JSON responses
- HTTP-native integrations that need method-level handling and headers

## Do Not Default To Route Handlers For

- normal internal form mutations that fit Server Actions
- internal UI data reads that can be done in Server Components
- forwarding behavior that belongs in Proxy

If a mutation originates from app UI, assume Server Action first and justify `route.ts` only when HTTP semantics are the actual requirement.

## Hard Rules

| Check | Rule |
|------|------|
| `route.ts` and `page.tsx` placed in the same segment | BLOCKED |
| Route Handler used as default internal RPC for a UI-only flow | BLOCKED unless HTTP semantics are required |
| `NextResponse.next()` used inside a Route Handler | BLOCKED |
| Route Handler caching assumed from old defaults without checking current behavior | BLOCKED |

## Important Notes

- Route Handlers are available only in the App Router
- Route Handlers use route segment config like other App Router files
- `GET` handler caching defaults changed in newer Next.js releases, so do not rely on stale assumptions; set intent explicitly when it matters
- Built-in file conventions already exist for `sitemap.xml`, `robots.txt`, icons, and metadata surfaces, so do not build custom handlers unless needed

## Decision Rule

Choose:

1. Server Component for server-rendered UI reads
2. Server Action for internal UI mutations and forms
3. Route Handler only when the surface is genuinely HTTP-native

## Review Checklist

- The endpoint really needs HTTP semantics
- No `page.tsx` conflict exists
- Current caching behavior is understood
- Proxy-specific behavior is not leaking into the Route Handler
