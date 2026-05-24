# Architecture Rules Reference

> Consolidated official-first rule set for Next.js projects, with App Router as the default mode.

Brownfield adoption rule: untouched legacy `pages/` code is not an automatic failure. Safety, boundary, auth, and data-leak issues still block immediately, especially in touched code.

---

## Project Modes

| Mode | Indicators | Enforcement |
|---|---|---|
| App Router | `app/` or `src/app/` | Full skill applies |
| Shared Next.js | `pages/` only | Apply shared platform, env, boundary, and safety rules only |
| Mixed | both `app/` and `pages/` | Apply App Router rules to touched `app/` code; avoid broad migration unless requested |

---

## Current Official Baselines

- Server Components are the default in App Router; add `'use client'` only at client entry points that need interactivity, browser APIs, or client hooks.
- In modern App Router docs, `fetch` requests are not cached by default, while routes may still be prerendered and HTML cached. Cache intent must be explicit.
- In latest stable Next.js 16.2.6 docs, Cache Components are enabled with `cacheComponents: true`; `use cache`, `cacheTag`, and `cacheLife` are the preferred cache primitives for that mode.
- `cacheComponents` is the unified v16 switch for PPR, `useCache`, and `dynamicIO`; experimental PPR flags and the `experimental_ppr` segment option are removed.
- With `cacheComponents`, `dynamic`, `revalidate`, and `fetchCache` route segment config options are removed; only current segment options such as `dynamicParams`, `runtime`, `preferredRegion`, and `maxDuration` remain.
- `use cache` cannot directly read request-time APIs; pass serializable values in, use `use cache: remote` for justified durable shared cache, and treat experimental `use cache: private` as exceptional.
- Use `connection()` for new request-time dynamic work; `unstable_noStore` is deprecated in favor of `connection()`.
- Server Actions are Server Functions invoked from UI/forms/events; treat each one as a reachable POST surface and re-check auth/authz inside it.
- `updateTag` is Server Action-only for read-your-own-writes; `revalidateTag` works in Server Actions and Route Handlers and should use a second argument such as `'max'` for stale-while-revalidate. The single-argument form is deprecated.
- Route Handlers are for HTTP-native endpoints and support standard Web `Request`/`Response` APIs plus method exports. With Cache Components, `GET` handlers follow the same prerendering model as UI routes and `use cache` must live in a helper, not directly in the handler body.
- The old `middleware` convention is deprecated in favor of `proxy.ts`; Proxy is a last-resort network-boundary tool, defaults to Node.js runtime, and must use static, narrow matchers.

---

## Core Principles

- Follow the official Next.js docs before local taste.
- Default to Server Components and add `'use client'` only at interactive leaves.
- Prefer Server Actions for internal UI mutations and forms.
- Keep privileged data access in server-only modules or a DAL.
- Make cache behavior intentional, not accidental.
- Treat every Server Action as externally reachable and re-authorize inside it.
- Use Route Handlers for HTTP-native concerns, not default internal mutations.
- Use Proxy only when redirects, rewrites, headers, or render-time logic are insufficient.

---

## Forbidden

| Category | Forbidden |
|---|---|
| Routing | `page.tsx` and `route.ts` at the same route segment |
| Client Boundary | Broad top-level `'use client'` without real interaction need |
| Secrets | Private env, DB clients, or server-only modules imported into Client Components |
| Data Safety | Passing broad raw records from Server Components into Client Components |
| Cache Intent | Relying on implicit caching or dynamic rendering without understanding why |
| Cache Components | Reading runtime request APIs inside a `use cache` scope instead of passing serializable inputs or a justified experimental `use cache: private` exception |
| Cache Components | Adding `unstable_noStore` for new dynamic work instead of `connection()` |
| Server Actions | Trusting client input, skipping auth/authz, or returning raw internal objects |
| Freshness | Redirecting before necessary revalidation/tag update or omitting freshness entirely |
| Route Handlers | Using `route.ts` as default internal RPC when a Server Action or Server Component is right |
| Route Handlers | Using `NextResponse.next()` inside a Route Handler |
| Proxy | Adding `proxy.ts` when `next.config.*` or render-time logic is enough |
| Env Setup | Expecting `.env*` files to load from `src/` |

---

## Required

| Category | Required |
|---|---|
| Validation | Confirm Next.js mode before editing |
| Routing | Place special files in valid route segments |
| Boundaries | Keep Client Components narrow and props serializable |
| Safety | Use `server-only` or an equally clear server boundary for privileged modules |
| Cache | State whether data/UI is uncached, cached with `use cache`, remotely/private cached by exception, tag-revalidated, path-revalidated, or refreshed |
| Auth | Re-check authentication and authorization inside each Server Action or delegated server-only layer |
| Platform | Keep env handling, route segment config, Proxy, and Next config explicit |
| Reporting | Label repo-local conventions as conventions, not framework law |

---

## Decision Order

1. Is this an App Router surface, legacy Pages Router surface, or mixed repo?
2. Is this code server-only, client-interactive, shared, cached, or request-time dynamic?
3. Does this need HTML/UI rendering, an internal UI mutation, or an HTTP-native endpoint?
4. Should the read be uncached, cached with `use cache`, revalidated by tag/path, or refreshed after mutation?
5. Does the change affect deployment-sensitive config such as env, Proxy, runtime, route segment config, or Server Action origins?

Default surface order:

1. Server Components for initial reads and server-rendered UI
2. Server Actions for internal UI writes and forms
3. Route Handlers for HTTP-native endpoints
4. Proxy only when pre-render network-boundary interception is truly required

---

## Rule Files

- `rules/project-structure.md`
- `rules/routes.md`
- `rules/execution-model.md`
- `rules/data-fetching.md`
- `rules/server-actions.md`
- `rules/route-handlers.md`
- `rules/platform.md`
- `references/official/nextjs-docs.md`

Read the smallest set that covers the active change, but always start here.
