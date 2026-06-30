---
name: nextjs-architecture
description: "[Hyper] Use when working on Next.js projects, especially App Router or App Router migration work. Enforces current official Next.js architecture rules for project/folder structure, nested shared `src/lib` / `src/services` organization, route/file conventions, Server and Client Component boundaries, Cache Components and data freshness, Server Actions for internal UI writes, Route Handlers for HTTP-native endpoints, Proxy as a last resort, and platform/env safety."
compatibility: Works best with repo inspection, official Next.js docs verification, and direct code edits in Next.js applications.
---

@architecture-rules.md
@rules/project-structure.md
@rules/routes.md
@rules/execution-model.md
@rules/data-fetching.md
@rules/server-actions.md
@rules/route-handlers.md
@rules/platform.md
@rules/validation.md
@references/official/nextjs-docs.md
@references/official/current-docs-2026-06-02.md

# Next.js Architecture Enforcement

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Confirm a repository is a Next.js project and identify App Router, Pages Router, or mixed mode before enforcing architecture rules.
- Enforce official Next.js behavior for file conventions, Server/Client Component boundaries, data/cache behavior, Server Actions, Route Handlers, Proxy, and env/platform safety.
- Apply Hypercore/repo-local conventions for nested shared folders such as `src/lib/<domain>/` and `src/services/<domain-or-provider>/` without presenting them as official Next.js law.
- Keep version-sensitive official facts in `references/official/` so the core skill stays lean and current docs can be refreshed independently.

</purpose>

<routing_rule>

Use this skill for architecture enforcement, implementation guidance, or review in existing Next.js projects, especially App Router work, App Router migration, Server/Client boundaries, cache/freshness, Server Actions, Route Handlers, Proxy, env/platform safety, and nested shared-folder organization.

Do not use this skill for generic React architecture, Remix/TanStack Start projects, docs-only summaries, or copy-only edits that do not touch architectural boundaries beyond a quick safety check. In Pages Router-only projects, apply shared Next.js safety/platform checks but do not force App Router-only file conventions unless migration is requested.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Keep Next.js projects architecturally safe and aligned with official docs plus labelled Hypercore/repo-local conventions. |
| Trigger | Next.js project work involving App Router, Pages Router, Server/Client boundaries, data/cache behavior, Server Actions, Route Handlers, Proxy, platform/env, or shared folder layout. |
| Scope | Review and guide touched project architecture, topic rule files, official references, validation notes, and small reversible architecture fixes. |
| Authority | User/project instructions outrank this skill. Current official Next.js docs outrank local conventions for framework behavior. Safety policy blocks risky runtime, auth, secret, and import-boundary changes. |
| Evidence | Use local package/config/router indicators, touched source paths, topic rules, official references, validation scripts, and project check output. |
| Tools | Use local search/read/edit/validation commands; use current official docs when API drift matters; gate destructive migrations, credentials, production side effects, and broad codemods. |
| Output | Korean architecture decision or review with rule classifications, changed files if any, validation evidence, remaining risks, and dated official-doc ambiguity notes. |
| Verification | Run `rules/validation.md` checks relevant to touched surfaces and `scripts/validate-nextjs-architecture-skill.mjs` when this skill folder changes. |
| Stop condition | Stop after project mode is known, applicable safety gates pass, local conventions are applied or deferred, validation evidence is recorded, and unresolved API drift is dated and sourced. |

</instruction_contract>

## Overview

Enforce official Next.js architecture rules before and after code changes. First prove that the target is a Next.js project and identify whether it uses App Router, Pages Router, or both. Then apply the smallest relevant rule set for routing, Server and Client Component boundaries, data/cache behavior, Server Actions, Route Handlers, Proxy, and platform configuration.

**Official-first rule:** the current Next.js docs are the source of truth for framework behavior. If a repo-local convention is stricter than Next.js, label it as a local convention instead of framework law.

**App Router default:** full enforcement applies to `app/` and `src/app/` work. In Pages Router-only projects, apply shared Next.js platform, env, and boundary checks without forcing App Router-only file conventions unless the user is migrating.

**Mutation default:** for App Router UI-originated writes, prefer Server Actions. Use Route Handlers for HTTP-native contracts such as webhooks, feeds, CORS endpoints, public machine-readable endpoints, and non-UI responses.

**Security default:** treat every Server Action as a reachable POST entry point. Validate input, authenticate, authorize, and shape minimal return values inside the action or a delegated server-only layer.

## Quick Surface Chooser

| If the task sounds like... | Default surface | Avoid by default |
|---|---|---|
| Add a form or internal UI mutation in App Router | Server Action | `route.ts` RPC |
| Add a webhook, feed, CORS endpoint, public API, XML, JSON, or stream | Route Handler | Server Action |
| Fetch initial page data for UI | Server Component | Client-first fetching |
| Add interactivity, browser APIs, or client hooks | Narrow Client Component | Root-level `'use client'` |
| Cache repeatable data/UI in Next.js 16+ | `cacheComponents` + `use cache` / `cacheTag` / `cacheLife` | stale `fetch` default assumptions |
| Refresh UI after mutation | `updateTag`, `revalidateTag`, `revalidatePath`, `refresh`, or redirect flow | undocumented freshness |
| Redirect/rewrite before render across many requests | `next.config.*` first, then Proxy if needed | Proxy as generic middleware |
| Pages Router only and no migration requested | shared Next.js checks | App Router-only file rules |

<activation_examples>

Positive examples:

- "Audit this Next.js App Router feature for Server/Client boundaries and cache correctness."
- "Refactor this form to use Server Actions instead of an internal route handler."
- "Add a Route Handler for a webhook and verify it follows the current Next.js docs."
- "Next.js 16 cacheComponents 기준으로 data fetching 규칙을 점검해줘."
- "Next.js App Router에서 src/lib/auth/session.ts와 src/services/billing/mutations.ts처럼 nested shared folders로 정리해줘."

Negative examples:

- "Create a generic React architecture guide."
- "Review a Remix or TanStack Start app."
- "Write marketing copy for a Next.js landing page without touching architecture."

Boundary examples:

- "Make a tiny copy-only text change in a Next.js page."
  Direct editing can be enough if no architectural boundary is affected, but touched files still need a quick boundary check.
- "This repo is Pages Router only and I am not migrating to App Router."
  Apply shared Next.js platform, env, and server/client safety checks; relax App Router-only file conventions.

</activation_examples>

## Step 1: Project Validation

Before architectural work, confirm the project and router mode:

```bash
rg -n '"next"' package.json
find . -maxdepth 3 \( -path './app' -o -path './src/app' -o -path './pages' -o -path './src/pages' \)
test -f next.config.ts -o -f next.config.mjs -o -f next.config.js
```

Interpretation:

- No `next` dependency: stop; this skill does not apply.
- `app/` or `src/app/`: App Router mode.
- `pages/` or `src/pages/` without App Router: shared Next.js mode.
- Mixed `app/` and `pages/`: enforce App Router rules for touched `app/` code and avoid legacy migration unless requested.

## Step 2: Read the Smallest Relevant Rule Set

**Required first read:** `architecture-rules.md`.

Then load only the rule files needed for the touched surface:

- `rules/routes.md` — file conventions, segment rules, route groups, private folders, parallel/intercepted route cautions
- `rules/project-structure.md` — top-level project shape, `src/`, shared code placement, nested `src/lib`, repo-local organization conventions
- `rules/execution-model.md` — Server/Client Components, `'use client'`, providers, serializable props, `server-only` / `client-only`
- `rules/data-fetching.md` — server-first reads, streaming, Cache Components, `use cache` / `use cache: remote` / `use cache: private`, cache tags, revalidation, dynamic rendering
- `rules/server-actions.md` — `use server`, forms, validation, auth/authz, DAL delegation, `updateTag` / revalidation / redirect ordering
- `rules/route-handlers.md` — `route.ts`, HTTP methods, caching intent, params, non-UI responses, CORS/webhooks
- `rules/platform.md` — env, `next.config.*`, `typedRoutes`, Proxy, route segment config, deployment-sensitive settings

For drift-sensitive behavior, also read `references/official/current-docs-2026-06-02.md` first, then `references/official/nextjs-docs.md` and fetch official pages through `https://r.jina.ai/https://nextjs.org/docs/...` when browser-readable markdown is needed.

## Step 3: Pre-Change Gates

### Brownfield Adoption

- Do not fail untouched legacy deviations by default.
- Safety, secret, auth, and boundary issues block immediately in touched files.
- Bring touched files into compliance unless that requires a broad migration.

### Gate 1: Routing, File Conventions, and Project Structure

| Check | Rule |
|---|---|
| `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, or `route.ts` placed outside valid segment structure | BLOCKED |
| `route.ts` and `page.tsx` created in the same route segment | BLOCKED |
| Route group used as if it changes the URL | BLOCKED |
| Private implementation files exposed as routable segments instead of `_folder` | BLOCKED |
| Shared `src/lib` / `src/services` organization forced flat or direct-leaf when nested domain/provider grouping would clarify touched code | WARNING. Prefer nested grouping |
| Repo-local folder preferences reported as official Next.js law | BLOCKED |
| Parallel/intercepted routes added without matching layout slots or hard-navigation behavior | WARNING/BLOCKED by risk |

### Gate 2: Server and Client Boundaries

| Check | Rule |
|---|---|
| Interactive component missing `'use client'` | BLOCKED |
| `'use client'` added high in the tree without need | BLOCKED |
| Client Component imports DB code, private env, `cookies()`, `headers()`, or server-only helpers | BLOCKED |
| Props crossing Server→Client are broad, secret-bearing, or non-serializable | BLOCKED |
| Provider wraps broader tree than needed | WARNING |

### Gate 3: Data Fetching, Cache, and Freshness

| Check | Rule |
|---|---|
| Initial UI data fetched in a Client Component without client-only need | BLOCKED |
| Cache behavior is accidental, undocumented, or based on stale defaults | BLOCKED |
| `cacheComponents` enabled but uncached runtime data lacks `use cache`, `connection()`, `loading.tsx`, or `<Suspense>` intent | BLOCKED |
| `use cache` reads `cookies()` / `headers()` inside the cached scope instead of receiving serializable arguments | BLOCKED unless explicitly using justified experimental `use cache: private` |
| `unstable_noStore` added for new App Router work instead of `connection()` | BLOCKED unless maintaining legacy code |
| Mutation lacks `updateTag`, `revalidateTag`, `revalidatePath`, `refresh`, redirect freshness, or documented alternative | BLOCKED |

### Gate 4: Server Actions

| Check | Rule |
|---|---|
| Internal UI mutation implemented with `route.ts` even though a Server Action fits | BLOCKED unless HTTP semantics are required |
| Action trusts `FormData`, params, headers, or search params without validation/reverification | BLOCKED |
| Action relies only on page-level auth checks | BLOCKED |
| Action returns raw DB rows or broad internal objects | BLOCKED |
| `redirect()` runs before required revalidation or tag update | BLOCKED |

### Gate 5: Route Handlers and Proxy

| Check | Rule |
|---|---|
| Route Handler used as default internal RPC for UI-only flow | BLOCKED |
| `NextResponse.next()` used inside a Route Handler | BLOCKED |
| Route Handler caching is assumed rather than explicit where correctness matters | BLOCKED |
| `use cache` placed directly in a Route Handler body instead of a helper function | BLOCKED |
| Fresh `middleware.ts` added instead of `proxy.ts` | BLOCKED |
| Proxy added when `next.config.*`, headers, redirects, rewrites, or render-time logic is enough | BLOCKED |
| Proxy matcher is missing, too broad, or fails to exclude metadata/static surfaces where needed | BLOCKED |

### Gate 6: Platform and Environment

| Check | Rule |
|---|---|
| `.env*` files assumed to load from `src/` | BLOCKED |
| Client code reads non-`NEXT_PUBLIC_` env vars | BLOCKED |
| Runtime client env treated as build-time public env | BLOCKED |
| Removed v16 route segment config options (`dynamic`, `revalidate`, `fetchCache`) used while `cacheComponents` is enabled | BLOCKED |
| `runtime: 'edge'` or Proxy runtime assumptions changed without platform compatibility checks | BLOCKED |
| Deployment-sensitive Server Action origin/config changes are undocumented | WARNING/BLOCKED by risk |

## Step 4: Implementation Policy

Auto-fix local, reversible issues: narrow client boundaries, move server-only code behind a DAL/helper, add `server-only`, add missing freshness, replace UI-only `route.ts` mutations with small Server Actions, tighten Proxy matcher, and clarify cache intent.

Do not auto-apply broad migrations: Pages→App Router rewrites, sweeping cache model changes, mass Route Handler→Server Action conversions, or deployment-sensitive origin/encryption changes.

<validation_checklist>

## Step 5: Post-Change Verification

Run the smallest project-specific checks that prove the claim, then report evidence:

1. project mode still matches the edited surface
2. special files are in valid segments and no `page`/`route` conflict exists
3. shared and segment-local folders follow project-structure rules, with nested `src/lib` / `src/services` grouping required for new touched shared code unless an explicit exception is recorded
4. `'use client'` boundaries are narrow and safe
5. client code cannot import server-only modules or private env
6. data/cache strategy is explicit and current-docs compatible
7. mutation freshness uses `updateTag`, `revalidateTag`, `revalidatePath`, `refresh`, redirect flow, or a documented alternative
8. Route Handler and Proxy usage remains justified
9. `next.config.*`, env loading, route segment config, and deployment settings are coherent

For this skill folder itself, run:

```bash
node skills/nextjs-architecture/scripts/validate-nextjs-architecture-skill.mjs
```

## Stop Condition

Finish when the Next.js mode is known, all touched surfaces pass the relevant gates, verification output is fresh, and any remaining repo-local convention or risk is explicitly reported.

</validation_checklist>
