---
name: tanstack-start-architecture
description: "[Hyper] Enforce TanStack Start architecture in existing Start projects, especially route structure, server functions, loader/client-server boundaries, importProtection, hooks, SSR/hydration, and hypercore conventions. Use before structural code changes, route work, server function work, or architecture audits in TanStack Start codebases."
---

@architecture-rules.md
@rules/routes.md
@rules/services.md
@rules/hooks.md
@rules/import-protection.md
@rules/middleware.md
@rules/execution-model.md
@rules/server-routes.md
@rules/ssr-hydration.md
@rules/platform.md
@rules/validation.md
@references/official/tanstack-start-2026-04-30.md
@references/official/tanstack-router-2026-04-30.md
@references/official/api-drift-notes.md

# TanStack Start Architecture Enforcement

> Apply hypercore's TanStack Start architecture rules without confusing team conventions with official TanStack requirements.

<purpose>

- Validate that the project is a TanStack Start / TanStack Router project before applying this skill.
- Enforce safety boundaries for loaders, server functions, import protection, middleware, server routes, and SSR/hydration.
- Apply hypercore conventions for route folders, hooks, file naming, comments, and layering when they are in scope.
- Keep official TanStack API facts in `references/official/` so rapidly changing framework details can be refreshed without bloating the core skill.

</purpose>

<operating_mode>

This skill is self-contained. Do not depend on global skills or external orchestration before applying it.

Rules are classified as:

- **Official** — documented TanStack behavior or API requirement.
- **Safety policy** — local blocking rule for security/runtime correctness.
- **Hypercore convention** — local/team standard that may be stricter than official TanStack defaults.

If a user explicitly asks for official TanStack defaults, relax hypercore-only conventions but keep official and safety rules.

</operating_mode>

<trigger_examples>

Positive:

- "Audit this TanStack Start app for server-function, loader, and importProtection violations."
- "Add a TanStack Start route with search params and keep the architecture compliant."
- "Refactor Start route folders, hooks, and server functions to follow hypercore rules."
- "TanStack Start 프로젝트에서 loader 경계랑 server function 구조 점검해줘."

Negative:

- "Review this generic React/Vite app that does not use TanStack Start."
- "Create a browser QA skill for Codex."
- "Summarize TanStack Router docs without changing or auditing a project."

Boundary:

- "Make a copy-only edit in a static TanStack Start privacy page."
  Use this skill only for a quick boundary check; publishing-only pages do not need generated `-hooks/`, `-components/`, or `-functions/` folders unless logic/server integration is introduced.

</trigger_examples>

<project_validation>

Before enforcing rules, confirm at least one Start/Router indicator exists:

```bash
ls app.config.ts 2>/dev/null
grep -r "@tanstack/react-start" package.json 2>/dev/null
grep -r "@tanstack/react-router" package.json 2>/dev/null
ls src/routes/__root.tsx 2>/dev/null
```

If none are present, stop using this skill and route to the normal implementation/review path.

</project_validation>

<support_file_read_order>

Read only what the task needs:

1. `architecture-rules.md` for the rule taxonomy and blocking gate summary.
2. Topic rules by changed surface:
   - `rules/routes.md` — route organization, search validation, loaders, route lifecycle.
   - `rules/services.md` — server functions, validation, query/mutation layering.
   - `rules/hooks.md` — hook extraction, internal hook order, `useServerFn` wrapper policy.
   - `rules/import-protection.md` — client/server import boundaries and `vite.config.ts` deny rules.
   - `rules/middleware.md` — function/request middleware and `sendContext` validation.
   - `rules/execution-model.md` — isomorphic loaders and environment-only functions.
   - `rules/server-routes.md` — justified HTTP endpoints vs internal app RPC.
   - `rules/ssr-hydration.md` — deterministic first render, `ClientOnly`, route SSR modes.
   - `rules/platform.md` — `getRouter()`, env validation, path aliases, operational endpoints.
3. `references/official/tanstack-start-2026-04-30.md` when Start API behavior matters.
4. `references/official/tanstack-router-2026-04-30.md` when Router/file-route/search/loading behavior matters.
5. `references/official/api-drift-notes.md` when docs conflict or current package behavior is uncertain.
6. `rules/validation.md` before claiming completion.

</support_file_read_order>

<workflow>

| Phase | Task | Output |
|---|---|---|
| 0 | Validate this is a TanStack Start/Router project | Scope decision |
| 1 | Identify touched surfaces and load only relevant rule/reference files | Minimal evidence set |
| 2 | Classify each applicable rule as Official, Safety policy, or Hypercore convention | Enforcement plan |
| 3 | Apply safe, local, reversible fixes automatically | Code or skill changes |
| 4 | Defer broad migrations unless explicitly requested | Backlog or handoff note |
| 5 | Run validation checks from `rules/validation.md` | Evidence-backed completion |

</workflow>

<blocking_safety_summary>

Always block or fix before proceeding when touched code would:

- Read secrets, DB clients, filesystem, or privileged SDKs from isomorphic loader/client-reachable code.
- Keep server-only imports alive outside compiler-recognized boundaries such as `createServerFn` or `createServerOnlyFn`.
- Disable import protection or overwrite an existing `tanstackStart()` config instead of extending it.
- Use server functions for mutations without runtime input validation.
- Treat untrusted `sendContext` values as validated server data.
- Introduce hydration-unstable first render output such as `Date.now()`, random IDs, or locale/time-zone divergence without a stabilization strategy.

</blocking_safety_summary>

<hypercore_conventions_summary>

Apply these to touched files unless the user asks for official defaults only:

- Prefer route directories over flat route files for app pages.
- Pages/components with interactive logic extract logic into `-hooks/`; publishing-only static pages are exempt.
- Server-integrated pages use `-functions/` and route-local hooks/components where appropriate.
- Use `export const Route = createFileRoute(...)` for file routes.
- Keep routes thin: route/page UI -> hooks/query -> server functions -> feature/database layer.
- Use kebab-case filenames, explicit return types, no `any`, const arrow functions, and Korean block comments for meaningful code groups.

</hypercore_conventions_summary>

<validation>

Before declaring the work done:

- Run the task-specific checks in `rules/validation.md`.
- Confirm official-vs-hypercore labels are preserved in any edited rule.
- Confirm support files are directly linked from `SKILL.md` and do not require following an indirect reference chain.
- Confirm English and Korean entrypoints still describe the same trigger, boundary, workflow, and read order.
- Record any unresolved TanStack API ambiguity with a source link and exact date.

</validation>
