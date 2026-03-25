# Architecture Rules Reference

> Consolidated official-first rule set for Next.js projects, with App Router as the default mode.

Brownfield adoption rule: untouched legacy `pages/` code is not an automatic failure. Safety, boundary, and data-leak issues still block immediately, especially in touched code.

---

## Project Modes

| Mode | Indicators | Enforcement |
|------|------------|-------------|
| App Router | `app/` or `src/app/` | Full skill applies |
| Shared Next.js | `pages/` only | Apply shared platform, env, boundary, and safety rules only |
| Mixed | both `app/` and `pages/` | Apply App Router rules to touched `app/` code, avoid broad migration unless requested |

---

## Core Principles

- Follow the official Next.js docs before local taste.
- Default to Server Components and add `'use client'` only at interactive leaves.
- Prefer Server Actions for internal UI mutations and forms.
- Keep privileged data access in server-only modules or a DAL.
- Make cache behavior intentional, not accidental.
- Treat every Server Action as externally reachable and re-authorize inside it.
- Use Route Handlers for HTTP-native concerns, not as the default internal mutation surface.
- Use Proxy only when redirects, rewrites, headers, or render-time logic are insufficient.

---

## Forbidden

| Category | Forbidden |
|----------|-----------|
| Routing | `page.tsx` and `route.ts` at the same route segment |
| Client Boundary | Broad top-level `'use client'` without real interaction need |
| Secrets | Private env, DB clients, or server-only modules imported into Client Components |
| Data Safety | Passing broad raw records from Server Components into Client Components |
| Cache Intent | Relying on implicit caching or dynamic rendering without understanding why |
| Server Actions | Trusting client input, skipping auth/authz, or returning raw internal objects |
| Side Effects | Mutating during render instead of through a Server Action or explicit event path |
| Route Handlers | Using `route.ts` as default internal RPC when a Server Action or Server Component is the right surface |
| Route Handlers | Using `NextResponse.next()` inside a Route Handler |
| Proxy | Adding `proxy.ts` when `next.config.*` or render-time logic is enough |
| Env Setup | Expecting `.env*` files to load from `src/` |

---

## Required

| Category | Required |
|----------|----------|
| Validation | Confirm Next.js mode before editing |
| Routing | Place special files in valid route segments |
| Boundaries | Keep Client Components narrow and their props serializable |
| Safety | Use `server-only` or an equally clear server boundary for privileged modules |
| Freshness | Revalidate or otherwise refresh data after mutations |
| Auth | Re-check authentication and authorization inside each Server Action |
| Platform | Keep env handling and config explicit |
| Reporting | Label repo-local conventions as conventions, not framework law |

---

## Decision Order

1. Is this an App Router surface or legacy Pages Router surface?
2. Is this code server-only, client-interactive, or shared?
3. Does this need HTML/UI rendering, an internal UI mutation, or an HTTP-native endpoint?
4. Should the read be cached, dynamic, or explicitly revalidated?
5. Does the change affect deployment-sensitive config such as env, Proxy, or Server Action origins?

Default surface order:

1. Server Components for initial reads and server-rendered UI
2. Server Actions for internal UI writes and forms
3. Route Handlers for HTTP-native endpoints
4. Proxy only when pre-render interception is truly required

---

## Rule Files

- `rules/routes.md`
- `rules/execution-model.md`
- `rules/data-fetching.md`
- `rules/server-actions.md`
- `rules/route-handlers.md`
- `rules/platform.md`
- `references/official/nextjs-docs.md`

Read the smallest set that covers the active change, but always start here.
