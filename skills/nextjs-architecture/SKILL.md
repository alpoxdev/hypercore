---
name: nextjs-architecture
description: Use when working on Next.js projects or introducing App Router into a codebase. Enforces official Next.js architecture rules for app structure, Server and Client Component boundaries, server-first data fetching, and a default decision order of Server Components for reads, Server Actions for internal writes, Route Handlers for HTTP-native endpoints, and Proxy only as a last resort.
compatibility: Works best with repo inspection, official Next.js docs verification, and direct code edits in Next.js applications.
---

# Next.js Architecture Enforcement

## Overview

Enforces official Next.js architecture rules before code changes. Validate that the target is actually a Next.js project, determine whether App Router is in use, then apply strict rules for routing, Server and Client Component boundaries, server-first data fetching, Server Actions, Route Handlers, Proxy, and environment setup.

**This skill is official-first.** Treat the Next.js documentation as the source of truth. If a repo-local convention is stricter than the framework, label it clearly instead of silently presenting it as a framework rule.

**OPERATING MODE:** This skill is self-contained. Do not block on external orchestration just to apply architecture rules. If the user wants exhaustive verification, keep verifying. Otherwise proceed with this skill's own validation flow.

**IMPORTANT:** App Router is the default path for this skill. If the repo is Pages Router only, apply only the shared platform and boundary checks and do not force App Router-only file conventions unless the user is migrating or explicitly adding `app/`.

**IMPORTANT:** Prefer Server Actions for internal UI writes, especially forms and app-originated mutations. Use Route Handlers when the surface is genuinely HTTP-native, such as webhooks, feeds, CORS-sensitive endpoints, or machine-readable/public endpoints.

**IMPORTANT:** Treat every Server Action as a reachable POST entry point. Validation, authentication, authorization, and return-value filtering must happen inside the action or the delegated server-only data layer, not only in the page that renders the form.

## Quick Surface Chooser

Use this table before reading the full gates:

| If the task sounds like... | Default surface | Do not default to... |
|------|------|------|
| `Add a form or internal app mutation in App Router` | Server Action | `route.ts` |
| `Add a webhook, feed, CORS endpoint, or public machine-readable endpoint` | Route Handler | Server Action |
| `Fetch initial page data for UI` | Server Component | Client-first fetching without a real need |
| `Need redirect logic before render across many requests` | `next.config.*` or Proxy, with Proxy last | Server Action |
| `Client Component imports DB code or private env` | move the code behind a server-only boundary | leaving secrets in client-reachable code |
| `Pages Router only repo and no migration requested` | shared Next.js safety checks only | forcing App Router file conventions |

If the task matches one of these rows, start there, then read the linked rule file in Step 2 for detail.

## Trigger Examples

### Positive

- `Audit this Next.js app before I add more App Router routes.`
- `Refactor a Next.js feature so Server Components, client boundaries, caching, and server actions follow the official docs.`
- `Add a Next.js Route Handler or Server Action and keep the architecture compliant.`

### Negative

- `Create a generic React architecture guide.`
- `Review a Remix or TanStack Start app.`

### Boundary

- `Make a tiny copy-only text change in a Next.js page.`
Direct editing can be enough if no architectural boundary is affected, but touched files still need a quick boundary check.

- `This repo is Pages Router only and I am not migrating to App Router.`
This skill still applies for shared Next.js platform, env, and boundary checks, but App Router-specific file rules must be relaxed.

## Step 1: Project Validation

Before any work, confirm a Next.js project and detect router mode:

```bash
rg -n '"next"' package.json
find . -maxdepth 3 \( -path './app' -o -path './src/app' -o -path './pages' -o -path './src/pages' \)
test -f next.config.ts -o -f next.config.mjs -o -f next.config.js
```

Interpretation:

- No `next` dependency found: stop, this skill does not apply.
- `app/` or `src/app/` present: full App Router mode.
- `pages/` or `src/pages/` present without App Router: shared Next.js mode only.
- Mixed `app/` and `pages/`: prefer App Router rules for touched `app/` code and avoid breaking legacy `pages/` code without explicit migration intent.

## Step 2: Read Architecture Rules

Load the detailed rules reference:

**REQUIRED:** Read `architecture-rules.md` in this skill directory before writing code.

Then read the relevant rule files for the change:

- `rules/routes.md` - App Router structure, special files, route groups, private folders, and segment boundaries
- `rules/execution-model.md` - Server vs Client Components, `use client`, providers, serializable props, and `server-only`
- `rules/data-fetching.md` - server data fetching, streaming, cache intent, dynamic rendering triggers, and revalidation
- `rules/server-actions.md` - `use server`, validation, auth, authz, DAL delegation, revalidation, redirect ordering, and side-effect rules
- `rules/route-handlers.md` - when `route.ts` is justified, method handling, caching defaults, and HTTP-only surfaces
- `rules/platform.md` - environment variables, `next.config.*`, `typedRoutes`, Proxy, and deployment-sensitive setup

If framework behavior may have drifted, also read:

- `references/official/nextjs-docs.md` - official doc map for the rules this skill depends on

## Step 3: Pre-Change Validation Checklist

Before writing any code, verify the planned change against these gates:

### Brownfield Adoption Rule

- Do not treat every untouched legacy deviation as an immediate project-wide failure.
- Safety and boundary issues still block immediately, especially in touched files.
- Legacy `pages/` code can remain in place when the task is local and non-migratory.
- Any file you touch should be brought into compliance unless that would require a materially risky migration.

### Gate 1: Routing and File Conventions

| Check | Rule |
|-------|------|
| `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, or `route.ts` placed outside the expected segment structure? | BLOCKED |
| `route.ts` and `page.tsx` created at the same route segment? | BLOCKED |
| App Router feature work done in `pages/` even though `app/` already exists for that surface? | BLOCKED unless explicitly requested |
| Route groups or private folders used without understanding URL impact? | WARNING. `(group)` does not affect URL, `_folder` stays private |
| Segment needs loading/error/not-found UX but no boundary exists? | WARNING. Add `loading.tsx`, `error.tsx`, or `not-found.tsx` intentionally |

### Gate 2: Server and Client Boundaries

| Check | Rule |
|-------|------|
| Interactive component missing `'use client'`? | BLOCKED |
| `'use client'` added high in the tree without need? | BLOCKED. Keep client boundaries as narrow as possible |
| Client Component imports server-only code, secrets, DB clients, or `process.env` private values? | BLOCKED |
| Server-only helper missing `import 'server-only'` or equivalent protected placement? | WARNING. Add a clear server-only boundary |
| Client Component props include broad DB records or non-serializable values? | BLOCKED |
| Context provider placed at the document root when a deeper boundary works? | WARNING. Render providers as deep as possible |

### Gate 3: Data Fetching and Caching

| Check | Rule |
|-------|------|
| Initial page data fetched in a Client Component when a Server Component can do it? | BLOCKED unless there is a real client-only need |
| Layout reads uncached runtime data and blocks same-segment `loading.tsx` without a closer `<Suspense>` boundary? | BLOCKED |
| Cache behavior is accidental or unclear? | BLOCKED. Choose and explain the cache strategy |
| Sensitive or privileged reads happen outside a DAL/server-only module without justification? | WARNING for prototypes, BLOCKED for production-oriented code |
| Mutation completes without `revalidatePath`, `revalidateTag`, redirect, or another freshness strategy where the UI depends on new data? | BLOCKED |

### Gate 4: Server Actions

| Check | Rule |
|-------|------|
| Internal UI mutation or form submit implemented with `route.ts` even though a Server Action fits? | BLOCKED unless real HTTP semantics are required |
| Action trusts form data, params, headers, or search params without validation or re-verification? | BLOCKED |
| Action relies only on page-level auth checks? | BLOCKED. Re-authorize inside the action |
| Action returns raw database rows or broad internal objects? | BLOCKED |
| Action performs DB or secret-heavy work directly when a server-only DAL exists or should exist? | WARNING for small code, BLOCKED for repeated domain logic |
| Action mutates during rendering instead of from an explicit action path (`form`, event, transition)? | BLOCKED |
| `redirect()` called before required revalidation? | BLOCKED. Revalidate first, then redirect |

### Gate 5: Route Handlers and Proxy

| Check | Rule |
|-------|------|
| Internal UI mutation implemented as `route.ts` even though a Server Action fits better? | BLOCKED unless real HTTP semantics are required |
| Route Handler used for webhooks, feeds, CORS, or public machine endpoints? | ALLOWED |
| Route Handler uses `NextResponse.next()` to forward like Proxy? | BLOCKED |
| Proxy added when `redirects`, `rewrites`, headers, or render-time logic would be enough? | BLOCKED. Proxy is last resort |
| `proxy.ts` not placed at project root or `src/` root level next to `app` or `pages`? | BLOCKED |
| Proxy matcher is missing or too broad for the actual need? | BLOCKED |

### Gate 6: Platform and Environment

| Check | Rule |
|-------|------|
| `.env*` files assumed to load from `src/`? | BLOCKED. They belong at project root |
| Client code reads non-`NEXT_PUBLIC_` env vars? | BLOCKED |
| Runtime client env needed but treated as build-time inlined config? | BLOCKED. Expose via server path/API instead |
| Multi-proxy or reverse-proxy deployment uses Server Actions without checking `serverActions.allowedOrigins` needs? | WARNING |
| Next config toggles caching, routing, or server action behavior without clear intent? | BLOCKED |
| Typed route safety would materially reduce routing mistakes but `typedRoutes` is ignored in a TypeScript codebase? | WARNING. Consider enabling it intentionally |

## Step 3.5: Auto-Remediation Policy

Auto-fix directly when the issue is local, reversible, and low-risk.

- narrow an overly broad `'use client'` boundary
- add `loading.tsx`, `error.tsx`, or `not-found.tsx` for a touched segment
- move privileged reads into a server-only helper or DAL
- add `server-only` markers and tighten client props
- add missing revalidation after a Server Action mutation
- move a misused internal `route.ts` mutation to a Server Action when the change is small and local
- tighten Proxy matcher scope or move simple redirects into `next.config.*`
- correct `.env` / `NEXT_PUBLIC_` usage and explicit config wiring

Do not auto-apply broad or potentially breaking migrations without explicit justification.

- mass route tree rewrites
- Pages Router to App Router migrations across large surfaces
- sweeping cache model changes
- turning many Route Handlers into Server Actions in one pass
- deployment-sensitive Server Action origin or encryption-key changes

## Step 4: Implementation

Carry these acceptance criteria into the active task:

```text
- [ ] Next.js project mode validated before editing
- [ ] App Router rules applied only where they actually fit
- [ ] Routing files live in the correct route segment structure
- [ ] Server and Client Component boundaries are explicit and minimal
- [ ] Client code cannot reach server-only data, env, or modules
- [ ] Data fetching and caching strategy is intentional
- [ ] Server Actions are the default surface for internal UI writes
- [ ] Server Actions validate input, re-authorize, and return minimal data
- [ ] Route Handlers exist only for real HTTP-native needs
- [ ] Proxy is used only when simpler surfaces are insufficient
- [ ] Environment handling and next.config setup are boundary-safe
```

## Step 5: Post-Change Verification

After writing code, verify:

1. project mode still matches the edited surface (`app/`, `pages/`, or mixed)
2. route segment file placement is valid
3. `'use client'` boundaries are as small as possible
4. client code does not import server-only modules or private env
5. data freshness after mutations is explicit (`revalidatePath`, `revalidateTag`, redirect flow, or documented alternative)
6. Route Handlers and Proxy usage are still justified
7. `next.config.*`, env loading, and deployment-sensitive settings remain coherent

## Quick Reference: App Router Shape

```text
app/
├── layout.tsx
├── page.tsx
├── dashboard/
│   ├── page.tsx
│   ├── loading.tsx
│   ├── error.tsx
│   ├── not-found.tsx
│   ├── _components/
│   └── _lib/
├── api/
│   └── webhooks/
│       └── route.ts
└── (marketing)/
    └── about/
        └── page.tsx
```

Key meaning:

- `(group)` organizes routes without affecting the URL
- `_folder` is a private implementation folder and does not become a route segment
- `route.ts` is for HTTP handling, not page UI
- `loading.tsx`, `error.tsx`, and `not-found.tsx` are route-segment boundaries, not general-purpose components
