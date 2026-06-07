---
name: tanstack-start-architecture
description: "Use this skill when reviewing or changing an existing TanStack Start/Router project architecture, especially routes, loaders, server functions, importProtection, SSR/hydration, and nested shared folders such as src/lib or src/services. Do not use for generic React/Vite projects or docs-only summaries."
---

@architecture-rules.md
@rules/project-structure.md
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
@references/official/current-docs-2026-06-02.md

# TanStack Start Architecture Enforcement

> Apply hypercore's TanStack Start architecture rules without confusing team conventions with official TanStack requirements.

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

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

<routing_rule>

Use this skill when the requested output is architecture enforcement, implementation guidance, or review for an existing TanStack Start / TanStack Router project. This includes route structure, route-local folders, loaders, server functions, server routes, middleware, import protection, SSR/hydration, platform setup, and shared nested folder organization.

Do not use this skill when:

- the project is not TanStack Start or TanStack Router
- the user only wants a generic React/Vite architecture review
- the task is a docs-only summary with no project audit or implementation guidance
- the main task is security, deployment, or test repair unrelated to Start architecture

When official TanStack guidance and Hypercore conventions differ, enforce official and safety rules first, then apply Hypercore conventions only to touched architecture surfaces.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Keep TanStack Start projects architecturally safe, maintainable, and aligned with official Start/Router behavior plus labelled Hypercore conventions. |
| Trigger | Existing Start/Router project work involving routes, loaders, server functions, import boundaries, SSR/hydration, middleware, server routes, platform setup, or shared folder layout. |
| Scope | Review and guide touched project architecture, topic rule files, official references, validation notes, and small reversible architecture fixes. |
| Authority | User/project instructions outrank this skill. Official TanStack docs outrank Hypercore conventions for API facts. Safety policy blocks risky runtime or import-boundary changes. |
| Evidence | Use project indicators, local config/package files, touched source paths, topic rules, official references, package typechecks, and validation command output. |
| Tools | Use local search/read/edit/validation commands; use current official docs when API drift matters; gate destructive migrations, credential access, network side effects, and production changes. |
| Output | Korean architecture decision or review with rule classifications, changed files if any, validation evidence, remaining risks, and official-doc ambiguity notes. |
| Verification | Run `rules/validation.md` checks relevant to touched surfaces and skill-anatomy checks when this skill folder changes. |
| Stop condition | Stop after applicable safety gates pass, Hypercore conventions are applied or explicitly deferred, validation evidence is recorded, and unresolved API drift is dated and sourced. |

</instruction_contract>

<activation_examples>

Positive:

- "Audit this TanStack Start app for server-function, loader, and importProtection violations."
- "Add a TanStack Start route with search params and keep the architecture compliant."
- "Refactor Start route folders, hooks, and server functions to follow hypercore rules."
- "Check the loader boundaries and server function structure in this TanStack Start project."
- "Review this TanStack Start folder structure and enforce nested src/lib or src/services grouping."

Negative:

- "Review this generic React/Vite app that does not use TanStack Start."
- "Create a browser QA skill for Codex."
- "Summarize TanStack Router docs without changing or auditing a project."

Boundary:

- "Make a copy-only edit in a static TanStack Start privacy page."
  Use this skill only for a quick boundary check; publishing-only pages do not need generated `-hooks/`, `-components/`, or `-functions/` folders unless logic/server integration is introduced.

</activation_examples>

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
   - `rules/project-structure.md` — official Start project shape, `src/routes`, route tree generation, custom route directory, shared nested folders.
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
5. `references/official/current-docs-2026-06-02.md` when current Start docs, plugin config, import protection, server functions, or execution-control APIs affect the decision.
6. `references/official/api-drift-notes.md` when docs conflict or current package behavior is uncertain.
7. `rules/validation.md` before claiming completion.

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
- Keep routes thin: route/page UI -> hooks/query -> server functions -> services/lib/db layer.
- Enforce nested shared folders such as `src/lib/<domain>/`, `src/services/<domain-or-provider>/`, `src/db/<area>/`, `src/server/<area>/`, and `src/config/<area>/` when touched shared code is added or reorganized; do not add new direct leaf files like `src/lib/foo.ts` or `src/services/foo.ts` unless an explicit project exception is recorded.
- Use kebab-case filenames, explicit return types, no `any`, const arrow functions, and Korean block comments for meaningful code groups.

</hypercore_conventions_summary>

<validation>

Before declaring the work done:

- Run the task-specific checks in `rules/validation.md`.
- Confirm official-vs-hypercore labels are preserved in any edited rule.
- Confirm support files are directly linked from `SKILL.md` and do not require following an indirect reference chain.
- Confirm English and Korean entrypoints still describe the same trigger, boundary, workflow, contract, and read order.
- Confirm touched `src/lib`, `src/services`, and similar shared folders use logical nested grouping or record an explicit exception.
- Record any unresolved TanStack API ambiguity with a source link and exact date.

</validation>
