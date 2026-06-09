# TanStack Start Architecture Skill Docs Refresh

## TL;DR
> Summary:      Refresh `skills/tanstack-start-architecture` against current official TanStack Start/Router documentation, preserving repo-local skill contracts and bilingual English/Korean alignment.
> Deliverables:
> - New dated official docs snapshot and Korean sibling under `skills/tanstack-start-architecture/references/official/`
> - Updated API drift notes, architecture rules, topic rules, entrypoints, and validation checks
> - Agent-executed evidence in `.omo/evidence/` for stale RED checks, GREEN validation, and final QA
> Effort:       Medium
> Risk:         Medium - current official pages and local notes show an API naming conflict around server-function validation, so the executor must record source evidence before choosing wording.

## Scope
### Must have
- Work only inside this repository and use repo-local files as the internal source of truth, per `AGENTS.md:8-12` and `AGENTS.md:24-31`.
- Update only `skills/tanstack-start-architecture/**`, generated QA evidence under `.omo/evidence/**`, and this plan's execution commits.
- Use official TanStack pages and package metadata only for API drift verification, because the request explicitly allows official TanStack docs for this refresh.
- Keep `SKILL.md` as the English canonical entrypoint and keep `SKILL.ko.md` structurally aligned, per `instructions/skill/SKILL_AUTHORING.md:105-117`, `README.md:257-260`, and `skills/skill-maker/SKILL.md:119-123`.
- Preserve the local skill anatomy: `SKILL.md`, optional `rules/`, `references/`, `scripts/`, and bilingual siblings, per `instructions/skill/SKILL_AUTHORING.md:7`, `instructions/skill/SKILL_AUTHORING.md:41-50`, and `README.md:237-250`.
- Refresh these candidate document groups:
  - Official snapshot: `references/official/current-docs-2026-06-09.md` and `.ko.md`
  - API drift: `references/official/api-drift-notes.md` and `.ko.md`
  - Setup/platform/project structure: `rules/platform.md`, `rules/project-structure.md`, and Korean siblings
  - Routing/execution/boundaries: `rules/routes.md`, `rules/execution-model.md`, `rules/import-protection.md`, `rules/ssr-hydration.md`, `rules/hooks.md`, and Korean siblings
  - Server functions/middleware/server routes: `rules/services.md`, `rules/middleware.md`, `rules/server-routes.md`, and Korean siblings
  - Entrypoints and summaries: `SKILL.md`, `SKILL.ko.md`, `architecture-rules.md`, `architecture-rules.ko.md`, `rules/validation.md`, `rules/validation.ko.md`
  - Validation harness: `scripts/validate-tanstack-start-architecture-skill.mjs`
- Keep local Hypercore conventions separate from official TanStack facts; current rules already classify facts and conventions in `skills/tanstack-start-architecture/architecture-rules.md:54-61` and `skills/tanstack-start-architecture/rules/project-structure.md:84-123`.
- Include exact source dates and source URLs in refreshed official notes, following the current snapshot pattern in `skills/tanstack-start-architecture/references/official/current-docs-2026-06-02.md:3-17`.

### Must NOT have (guardrails, anti-slop, scope boundaries)
- Do not read, cite, or modify global skill or agent directories under `~/`, per `AGENTS.md:8-12`.
- Do not modify product application code, package manifests, or unrelated skills.
- Do not treat a local Hypercore convention as an official TanStack requirement.
- Do not silently resolve the `.inputValidator()` versus `.validator()` conflict; record official page evidence, release/package evidence, and the decision rationale in API drift notes.
- Do not delete historical references unless the replacement is complete and linked from current source-priority sections.
- Do not use unofficial blogs, AI summaries, or non-TanStack pages as API authority.

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: TDD + Bash/Node static validation. Each implementation task starts with a stale RED check, updates docs, then runs GREEN checks.
- QA policy: every task has agent-executed scenarios
- Evidence: `.omo/evidence/task-<N>-<slug>.<ext>`

## Execution strategy
### Parallel execution waves
> Target 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks to maximize parallelism.

Wave 1 (no dependencies):
- Task 1: Refresh official docs snapshot
- Task 2: Resolve and document API drift
- Task 3: Update setup, platform, and project-structure rules
- Task 4: Update routing, execution, import-protection, SSR, and hook rules
- Task 5: Update server functions, middleware, and server route rules

Wave 2 (after Wave 1):
- Task 6: depends [1, 2, 3, 4, 5]
- Task 7: depends [1, 2, 3, 4, 5]
- Task 8: depends [1, 2, 3, 4, 5]

Wave 3 (after Wave 2):
- Task 9: depends [6, 7, 8]

Critical path: Task 1 -> Task 2 -> Task 6 -> Task 9

### Dependency matrix
| Task | Depends on | Blocks | Can parallelize with |
|------|------------|--------|----------------------|
| 1    | none       | 6, 7, 8 | 2, 3, 4, 5 |
| 2    | none       | 6, 7, 8 | 1, 3, 4, 5 |
| 3    | none       | 6, 7, 8 | 1, 2, 4, 5 |
| 4    | none       | 6, 7, 8 | 1, 2, 3, 5 |
| 5    | none       | 6, 7, 8 | 1, 2, 3, 4 |
| 6    | 1, 2, 3, 4, 5 | 9 | 7, 8 |
| 7    | 1, 2, 3, 4, 5 | 9 | 6, 8 |
| 8    | 1, 2, 3, 4, 5 | 9 | 6, 7 |
| 9    | 6, 7, 8 | none | none |

## Todos
> Implementation + Test = ONE task. Never separate.
> Every task MUST have: References + Acceptance Criteria + QA Scenarios + Commit.

- [ ] 1. Refresh official docs snapshot

  What to do: Create `skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.md` and `skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.ko.md`. Capture current official guidance for getting started, build-from-scratch setup, Vite/Rsbuild plugin setup, routing, execution model, server functions, middleware, server routes, import protection, environment variables, hosting, SSR, search validation, and data loading. Include `checked_at: 2026-06-09`, source URLs, and a short "changed since 2026-06-02" section.
  Must NOT do: Do not edit entrypoints in this task. Do not use Context7, unofficial summaries, or global skill files as the source.

  Parallelization: Can parallel: YES | Wave 1 | Blocks: [6, 7, 8] | Blocked by: []

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/tanstack-start-architecture/references/official/current-docs-2026-06-02.md:3-17` - dated snapshot header and official-source summary style to replace with a new dated snapshot
  - Pattern:  `skills/tanstack-start-architecture/references/official/current-docs-2026-06-02.md:28-45` - server function/import-protection summary style to refresh
  - Pattern:  `instructions/skill/SKILL_AUTHORING.md:148-161` - local link and validation quality rules
  - API/Type: `skills/skill-maker/SKILL.md:119-123` - English canonical plus Korean sibling alignment requirement
  - Test:     `skills/skill-tester/scripts/validate-skill.mjs:5-9` - local skill validator invocation pattern
  - External: `https://tanstack.com/start/latest/docs/framework/react/overview` - current React Start overview and RC positioning
  - External: `https://tanstack.com/start/latest/docs/framework/react/getting-started` - current builder/CLI/example setup guidance
  - External: `https://tanstack.com/start/latest/docs/framework/react/build-from-scratch` - current build-from-scratch plugin and route setup
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/routing` - current file-route guidance
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/execution-model` - current isomorphic execution model
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns` - current server/client/isomorphic function primitives
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/server-functions` - current server-function docs
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/middleware` - current middleware docs
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/server-routes` - current server route docs
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/import-protection` - current import-protection docs
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables` - current env-var docs
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/hosting` - current hosting docs
  - External: `https://tanstack.com/router/latest/docs/how-to/setup-ssr` - current Router SSR guidance and Start recommendation
  - External: `https://tanstack.com/router/latest/docs/how-to/validate-search-params` - current search validation/Zod guidance
  - External: `https://tanstack.com/router/latest/docs/guide/data-loading` - current loader/data-loading model

  Acceptance criteria (agent-executable only):
  - [ ] Before editing, the stale snapshot check fails with old-date-only state: `bash -lc 'set -euo pipefail; test ! -f skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.md'`
  - [ ] After editing, this command returns matches from both English and Korean snapshots: `bash -lc 'set -euo pipefail; rg -n "checked_at: 2026-06-09|TanStack Builder|npx @tanstack/cli@latest create|@tanstack/react-start/plugin/(vite|rsbuild)|createServerFn|createMiddleware|sendContext|importProtection|ssr: .data-only.|Zod v4|https://tanstack.com/start/latest/docs/framework/react" skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.md skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.ko.md'`
  - [ ] The new snapshot states the `.inputValidator()`/`.validator()` ambiguity as a drift item instead of hiding it.

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: new official snapshot exists and contains current source anchors
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; test -f skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.md; test -f skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.ko.md; rg -n "checked_at: 2026-06-09|TanStack Builder|npx @tanstack/cli@latest create|@tanstack/react-start/plugin/(vite|rsbuild)|createServerFn|createMiddleware|sendContext|importProtection|Zod v4|https://tanstack.com/start/latest/docs/framework/react" skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.md skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.ko.md | tee .omo/evidence/task-1-official-snapshot.txt'
    Expected: command exits 0 and evidence contains matches from both snapshot files
    Evidence: .omo/evidence/task-1-official-snapshot.txt

  Scenario: new snapshot does not preserve stale Context7/date metadata
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; ! rg -n "checked_at: 2026-06-02|Context7" skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.md skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.ko.md | tee .omo/evidence/task-1-official-snapshot-error.txt'
    Expected: command exits 0 because stale metadata is absent from the new files
    Evidence: .omo/evidence/task-1-official-snapshot-error.txt
  ```

  Commit: YES | Message: `docs(tanstack-start): refresh official docs snapshot` | Files: [`skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.md`, `skills/tanstack-start-architecture/references/official/current-docs-2026-06-09.ko.md`, `.omo/evidence/task-1-official-snapshot.txt`, `.omo/evidence/task-1-official-snapshot-error.txt`]

- [ ] 2. Resolve and document API drift

  What to do: Update `api-drift-notes.md` and `.ko.md` with a 2026-06-09 verification pass. Re-run official-doc checks and package metadata checks for `@tanstack/react-start`, `@tanstack/react-router`, and `@tanstack/zod-adapter`. Record the current dist-tags and exact evidence for server-function validation naming. If official rendered docs and snippets disagree on `.validator()` versus `.inputValidator()`, document the conflict, source priority, package-type fallback, and the final guidance.
  Must NOT do: Do not make unsupported absolute claims. Do not block `.validator()` or promote `.inputValidator()` unless current official/package evidence supports that decision.

  Parallelization: Can parallel: YES | Wave 1 | Blocks: [6, 7, 8] | Blocked by: []

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/tanstack-start-architecture/references/official/api-drift-notes.md:3-14` - current verification/source-priority section
  - Pattern:  `skills/tanstack-start-architecture/references/official/api-drift-notes.md:16-33` - existing `.inputValidator()` versus `.validator()` decision to re-check
  - Pattern:  `skills/tanstack-start-architecture/references/official/api-drift-notes.md:35-56` - existing Zod/import-protection drift notes
  - Pattern:  `skills/tanstack-start-architecture/SKILL.md:193-203` - skill-level API ambiguity and source-date validation rule
  - Test:     `skills/vite-architecture/scripts/validate-vite-architecture-skill.mjs:29-37` - local validator phrase-check pattern
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/server-functions` - current server-function validation examples
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/middleware` - current middleware validation examples
  - External: `https://github.com/TanStack/router/releases` - official release history for Start/Router packages
  - External: `https://www.npmjs.com/package/@tanstack/react-start` - current package metadata to cross-check docs
  - External: `https://www.npmjs.com/package/@tanstack/react-router` - current router package metadata
  - External: `https://www.npmjs.com/package/@tanstack/zod-adapter` - current zod-adapter package metadata

  Acceptance criteria (agent-executable only):
  - [ ] Before editing, a stale-date check finds the old verification date: `bash -lc 'set -euo pipefail; rg -n "last_verified_at: 2026-04-30" skills/tanstack-start-architecture/references/official/api-drift-notes.md'`
  - [ ] After editing, `api-drift-notes.md` and `.ko.md` both contain `last_verified_at: 2026-06-09`, package metadata evidence, source priority, and a validation-method decision.
  - [ ] Dist-tag evidence is captured with: `bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; npm view @tanstack/react-start version dist-tags --json > .omo/evidence/task-2-react-start-npm.json; npm view @tanstack/react-router version dist-tags --json > .omo/evidence/task-2-react-router-npm.json; npm view @tanstack/zod-adapter version dist-tags --json > .omo/evidence/task-2-zod-adapter-npm.json'`

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: API drift notes record current verification and conflict handling
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; rg -n "last_verified_at: 2026-06-09|inputValidator|\\.validator\\(|package types|@tanstack/react-start|@tanstack/react-router|@tanstack/zod-adapter|source_priority|conflict|충돌" skills/tanstack-start-architecture/references/official/api-drift-notes.md skills/tanstack-start-architecture/references/official/api-drift-notes.ko.md | tee .omo/evidence/task-2-api-drift.txt'
    Expected: command exits 0 and evidence includes current date, both validation spellings when conflict exists, package names, and source-priority language
    Evidence: .omo/evidence/task-2-api-drift.txt

  Scenario: API drift notes avoid unsupported silent resolution
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; ! rg -n "silently pick|조용히 선택|no conflict" skills/tanstack-start-architecture/references/official/api-drift-notes.md skills/tanstack-start-architecture/references/official/api-drift-notes.ko.md | tee .omo/evidence/task-2-api-drift-error.txt'
    Expected: command exits 0 because unsupported silent-resolution wording is absent
    Evidence: .omo/evidence/task-2-api-drift-error.txt
  ```

  Commit: YES | Message: `docs(tanstack-start): update api drift notes` | Files: [`skills/tanstack-start-architecture/references/official/api-drift-notes.md`, `skills/tanstack-start-architecture/references/official/api-drift-notes.ko.md`, `.omo/evidence/task-2-api-drift.txt`, `.omo/evidence/task-2-api-drift-error.txt`, `.omo/evidence/task-2-react-start-npm.json`, `.omo/evidence/task-2-react-router-npm.json`, `.omo/evidence/task-2-zod-adapter-npm.json`]

- [ ] 3. Update setup, platform, and project-structure rules

  What to do: Refresh `rules/project-structure.md`, `rules/project-structure.ko.md`, `rules/platform.md`, and `rules/platform.ko.md` for current Start setup guidance. Cover TanStack Builder, `npx @tanstack/cli@latest create`, examples via official repo picking, Vite and Rsbuild plugin options, route root discovery from config, env-var rules, hosting targets, and local Hypercore project conventions.
  Must NOT do: Do not mark flat routes as invalid, because current local notes already say flat/directory/mixed routes are officially supported in `skills/tanstack-start-architecture/architecture-rules.md:54-61`. Do not introduce `src/env/` as the Hypercore default when the local rule says `src/config/env.ts` in `skills/tanstack-start-architecture/rules/platform.md:26-38`.

  Parallelization: Can parallel: YES | Wave 1 | Blocks: [6, 7, 8] | Blocked by: []

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/tanstack-start-architecture/rules/project-structure.md:16-42` - current default Start shape and route-folder rules to refresh
  - Pattern:  `skills/tanstack-start-architecture/rules/project-structure.md:44-64` - route-root discovery rules to extend for current config patterns
  - Pattern:  `skills/tanstack-start-architecture/rules/project-structure.md:84-123` - Hypercore route-local convention separation to preserve
  - Pattern:  `skills/tanstack-start-architecture/rules/platform.md:18-22` - current router setup note
  - Pattern:  `skills/tanstack-start-architecture/rules/platform.md:26-38` - current env policy to refresh without changing local default
  - Pattern:  `skills/tanstack-start-architecture/rules/platform.md:40-62` - starter-shape guidance to update
  - Test:     `skills/nextjs-architecture/scripts/validate-nextjs-architecture-skill.mjs:5-31` - required-file validation style
  - External: `https://tanstack.com/start/latest/docs/framework/react/getting-started` - builder/CLI/examples
  - External: `https://tanstack.com/start/latest/docs/framework/react/build-from-scratch` - Vite/Rsbuild setup and route roots
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables` - env-var behavior
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/hosting` - deployment targets

  Acceptance criteria (agent-executable only):
  - [ ] Before editing, stale setup wording is detectable with: `bash -lc 'set -euo pipefail; rg -n "TanStack Builder|@tanstack/cli@latest create|rsbuild" skills/tanstack-start-architecture/rules/project-structure.md skills/tanstack-start-architecture/rules/platform.md || true'`
  - [ ] After editing, English and Korean files mention current setup options and local conventions.
  - [ ] The rules still state local env placement and route conventions without claiming they are official TanStack requirements.

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: setup and platform rules contain current official setup options
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; rg -n "TanStack Builder|@tanstack/cli@latest create|vite.config.ts|rsbuild.config.ts|plugin/vite|plugin/rsbuild|routesDirectory|srcDirectory|src/config/env.ts|per-request|VITE_|hosting|배포" skills/tanstack-start-architecture/rules/project-structure.md skills/tanstack-start-architecture/rules/project-structure.ko.md skills/tanstack-start-architecture/rules/platform.md skills/tanstack-start-architecture/rules/platform.ko.md | tee .omo/evidence/task-3-setup-platform.txt'
    Expected: command exits 0 and evidence includes matches across English and Korean rule files
    Evidence: .omo/evidence/task-3-setup-platform.txt

  Scenario: local env convention remains explicit
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; rg -n "Do not create src/env/|src/config/env.ts|src/env/를 만들지" skills/tanstack-start-architecture/rules/platform.md skills/tanstack-start-architecture/rules/platform.ko.md | tee .omo/evidence/task-3-setup-platform-error.txt'
    Expected: command exits 0 and evidence shows `src/config/env.ts` remains the local convention
    Evidence: .omo/evidence/task-3-setup-platform-error.txt
  ```

  Commit: YES | Message: `docs(tanstack-start): update setup and platform rules` | Files: [`skills/tanstack-start-architecture/rules/project-structure.md`, `skills/tanstack-start-architecture/rules/project-structure.ko.md`, `skills/tanstack-start-architecture/rules/platform.md`, `skills/tanstack-start-architecture/rules/platform.ko.md`, `.omo/evidence/task-3-setup-platform.txt`, `.omo/evidence/task-3-setup-platform-error.txt`]

- [ ] 4. Update routing, execution, import-protection, SSR, and hook rules

  What to do: Refresh `rules/routes.*`, `rules/execution-model.*`, `rules/import-protection.*`, `rules/ssr-hydration.*`, and `rules/hooks.*` using official docs. Cover isomorphic defaults, route loaders, `validateSearch`, Zod v4 direct schemas versus adapter use, `createServerOnlyFn`, `createClientOnlyFn`, `createIsomorphicFn`, import-protection defaults/markers, SSR modes, `ClientOnly`, and `useServerFn` usage.
  Must NOT do: Do not broaden this task into server-function validation naming; Task 2 and Task 5 own that decision. Do not remove the publishing-only route exception from `skills/tanstack-start-architecture/rules/routes.md:16-23`.

  Parallelization: Can parallel: YES | Wave 1 | Blocks: [6, 7, 8] | Blocked by: []

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/tanstack-start-architecture/rules/routes.md:16-40` - publishing-only exception and route-folder convention
  - Pattern:  `skills/tanstack-start-architecture/rules/routes.md:54-99` - lifecycle and search-validation guidance to refresh
  - Pattern:  `skills/tanstack-start-architecture/rules/execution-model.md:17-48` - isomorphic/default execution model and primitive selection
  - Pattern:  `skills/tanstack-start-architecture/rules/import-protection.md:15-33` - official defaults and marker imports
  - Pattern:  `skills/tanstack-start-architecture/rules/ssr-hydration.md:23-40` - SSR/hydration fix order
  - Pattern:  `skills/tanstack-start-architecture/rules/hooks.md:54-87` - `useServerFn` and hook wrapper guidance
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/routing` - file routing and route tree
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/execution-model` - isomorphic execution model
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/code-execution-patterns` - server/client/isomorphic function primitives
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/import-protection` - import-protection behavior
  - External: `https://tanstack.com/router/latest/docs/how-to/validate-search-params` - search param validation
  - External: `https://tanstack.com/router/latest/docs/guide/data-loading` - route loader/data model

  Acceptance criteria (agent-executable only):
  - [ ] Before editing, capture current stale or incomplete matches with: `bash -lc 'set -euo pipefail; rg -n "createServerOnlyFn|createClientOnlyFn|createIsomorphicFn|ssr: .data-only.|Zod v4" skills/tanstack-start-architecture/rules/routes.md skills/tanstack-start-architecture/rules/execution-model.md skills/tanstack-start-architecture/rules/import-protection.md skills/tanstack-start-architecture/rules/ssr-hydration.md skills/tanstack-start-architecture/rules/hooks.md || true'`
  - [ ] After editing, all English and Korean files contain current boundary, SSR, search-validation, and loader guidance.
  - [ ] Files still classify official facts, safety policy, and Hypercore conventions separately.

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: routing and execution rule group contains current primitives and validation rules
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; rg -n "isomorphic|createServerOnlyFn|createClientOnlyFn|createIsomorphicFn|importProtection|server-only|client-only|ssr: .data-only.|ClientOnly|validateSearch|Zod v4|zodValidator|useServerFn|loader" skills/tanstack-start-architecture/rules/routes.md skills/tanstack-start-architecture/rules/routes.ko.md skills/tanstack-start-architecture/rules/import-protection.md skills/tanstack-start-architecture/rules/import-protection.ko.md skills/tanstack-start-architecture/rules/execution-model.md skills/tanstack-start-architecture/rules/execution-model.ko.md skills/tanstack-start-architecture/rules/ssr-hydration.md skills/tanstack-start-architecture/rules/ssr-hydration.ko.md skills/tanstack-start-architecture/rules/hooks.md skills/tanstack-start-architecture/rules/hooks.ko.md | tee .omo/evidence/task-4-routing-boundaries.txt'
    Expected: command exits 0 and evidence includes matches across the full rule group
    Evidence: .omo/evidence/task-4-routing-boundaries.txt

  Scenario: routing docs do not mislabel local conventions as official constraints
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; ! rg -n "flat routes are invalid|must always use route directories|official TanStack law|공식 TanStack 법칙" skills/tanstack-start-architecture/rules/routes.md skills/tanstack-start-architecture/rules/routes.ko.md skills/tanstack-start-architecture/rules/project-structure.md skills/tanstack-start-architecture/rules/project-structure.ko.md | tee .omo/evidence/task-4-routing-boundaries-error.txt'
    Expected: command exits 0 because over-claiming local route conventions is absent
    Evidence: .omo/evidence/task-4-routing-boundaries-error.txt
  ```

  Commit: YES | Message: `docs(tanstack-start): update routing and boundary rules` | Files: [`skills/tanstack-start-architecture/rules/routes.md`, `skills/tanstack-start-architecture/rules/routes.ko.md`, `skills/tanstack-start-architecture/rules/execution-model.md`, `skills/tanstack-start-architecture/rules/execution-model.ko.md`, `skills/tanstack-start-architecture/rules/import-protection.md`, `skills/tanstack-start-architecture/rules/import-protection.ko.md`, `skills/tanstack-start-architecture/rules/ssr-hydration.md`, `skills/tanstack-start-architecture/rules/ssr-hydration.ko.md`, `skills/tanstack-start-architecture/rules/hooks.md`, `skills/tanstack-start-architecture/rules/hooks.ko.md`, `.omo/evidence/task-4-routing-boundaries.txt`, `.omo/evidence/task-4-routing-boundaries-error.txt`]

- [ ] 5. Update server functions, middleware, and server route rules

  What to do: Refresh `rules/services.*`, `rules/middleware.*`, and `rules/server-routes.*`. Cover server functions as same-origin RPC endpoints, when server routes are appropriate for public/cross-origin endpoints, CSRF/fetch-metadata/origin/referer guidance when official docs require it, middleware `sendContext`, `createMiddleware({ type: 'function' })`, input validation, and trusted context boundaries.
  Must NOT do: Do not merge server routes and server functions into one recommendation. Do not trust client-controlled `sendContext` as authorization input.

  Parallelization: Can parallel: YES | Wave 1 | Blocks: [6, 7, 8] | Blocked by: []

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/tanstack-start-architecture/rules/services.md:5-15` - current server-function validation classification to revise based on Task 2 evidence
  - Pattern:  `skills/tanstack-start-architecture/rules/services.md:18-35` - canonical server-function example to refresh
  - Pattern:  `skills/tanstack-start-architecture/rules/middleware.md:7-14` - current middleware classification
  - Pattern:  `skills/tanstack-start-architecture/rules/middleware.md:24-40` - current middleware non-negotiables and approved patterns
  - Pattern:  `skills/tanstack-start-architecture/rules/server-routes.md:14-29` - server route use cases and server-function preference
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/server-functions` - server functions and security posture
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/middleware` - middleware API and `sendContext`
  - External: `https://tanstack.com/start/latest/docs/framework/react/guide/server-routes` - public endpoint guidance

  Acceptance criteria (agent-executable only):
  - [ ] Before editing, capture current server rule state with: `bash -lc 'set -euo pipefail; rg -n "inputValidator|\\.validator\\(|sendContext|server route|same-origin|CSRF" skills/tanstack-start-architecture/rules/services.md skills/tanstack-start-architecture/rules/middleware.md skills/tanstack-start-architecture/rules/server-routes.md || true'`
  - [ ] After editing, English and Korean files state the chosen validation method, the evidence status if ambiguous, server-function/server-route distinction, and `sendContext` trust boundary.
  - [ ] Server route guidance still prefers server functions for internal app data mutations unless official docs require a public/cross-origin route.

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: server rules contain current function, middleware, and server route guidance
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; rg -n "same-origin|CSRF|createCsrfMiddleware|Fetch Metadata|Origin|Referer|server route|public API|cross-origin|createMiddleware\\(\\{ type: .function. \\}\\)|sendContext|inputValidator|\\.validator\\(" skills/tanstack-start-architecture/rules/services.md skills/tanstack-start-architecture/rules/services.ko.md skills/tanstack-start-architecture/rules/middleware.md skills/tanstack-start-architecture/rules/middleware.ko.md skills/tanstack-start-architecture/rules/server-routes.md skills/tanstack-start-architecture/rules/server-routes.ko.md | tee .omo/evidence/task-5-server-functions.txt'
    Expected: command exits 0 and evidence includes the current validation spelling decision or documented ambiguity, middleware context, and route distinction
    Evidence: .omo/evidence/task-5-server-functions.txt

  Scenario: unsafe server/middleware claims are absent
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; ! rg -n "server routes for internal app RPC are preferred|trust sendContext|unvalidated sendContext|sendContext is authorization|sendContext를 신뢰" skills/tanstack-start-architecture/rules/services.md skills/tanstack-start-architecture/rules/services.ko.md skills/tanstack-start-architecture/rules/middleware.md skills/tanstack-start-architecture/rules/middleware.ko.md skills/tanstack-start-architecture/rules/server-routes.md skills/tanstack-start-architecture/rules/server-routes.ko.md | tee .omo/evidence/task-5-server-functions-error.txt'
    Expected: command exits 0 because unsafe claims are absent
    Evidence: .omo/evidence/task-5-server-functions-error.txt
  ```

  Commit: YES | Message: `docs(tanstack-start): update server function guidance` | Files: [`skills/tanstack-start-architecture/rules/services.md`, `skills/tanstack-start-architecture/rules/services.ko.md`, `skills/tanstack-start-architecture/rules/middleware.md`, `skills/tanstack-start-architecture/rules/middleware.ko.md`, `skills/tanstack-start-architecture/rules/server-routes.md`, `skills/tanstack-start-architecture/rules/server-routes.ko.md`, `.omo/evidence/task-5-server-functions.txt`, `.omo/evidence/task-5-server-functions-error.txt`]

- [ ] 6. Update skill entrypoints and support-file read order

  What to do: Update `SKILL.md` and `SKILL.ko.md` so direct support file links and `support_file_read_order` point to the 2026-06-09 snapshot, refreshed API drift notes, and refreshed rule groups. Keep trigger, output language, self-contained-mode, instruction contract, blocking safety summary, and validation sections aligned.
  Must NOT do: Do not overload core `SKILL.md` with long reference content; keep detailed guidance in `rules/` and `references/`, per `skills/skill-maker/SKILL.md:107-115`.

  Parallelization: Can parallel: YES | Wave 2 | Blocks: [9] | Blocked by: [1, 2, 3, 4, 5]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/tanstack-start-architecture/SKILL.md:1-21` - frontmatter and direct support links to refresh
  - Pattern:  `skills/tanstack-start-architecture/SKILL.md:129-149` - English read-order section to refresh
  - Pattern:  `skills/tanstack-start-architecture/SKILL.md:166-176` - blocking safety summary to synchronize with Tasks 2 and 5
  - Pattern:  `skills/tanstack-start-architecture/SKILL.md:193-203` - validation expectations to update for new snapshot
  - Pattern:  `skills/tanstack-start-architecture/SKILL.ko.md:6-21` - Korean direct support links to refresh
  - Pattern:  `skills/tanstack-start-architecture/SKILL.ko.md:129-149` - Korean read-order section to align
  - API/Type: `instructions/skill/SKILL_AUTHORING.md:54-103` - minimum `SKILL.md` contract sections
  - API/Type: `skills/skill-maker/SKILL.md:184-194` - triggerability, contract, anatomy, actionability, validation requirements
  - Test:     `skills/skill-tester/scripts/validate-skill.mjs:56-77` - trigger-example and support-file existence checks

  Acceptance criteria (agent-executable only):
  - [ ] Before editing, old snapshot links are detectable with: `bash -lc 'set -euo pipefail; rg -n "current-docs-2026-06-02" skills/tanstack-start-architecture/SKILL.md skills/tanstack-start-architecture/SKILL.ko.md'`
  - [ ] After editing, entrypoints link the new snapshot and no longer link the old snapshot in direct/read-order sections.
  - [ ] `node skills/skill-tester/scripts/validate-skill.mjs skills/tanstack-start-architecture` exits 0.

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: entrypoints reference the current snapshot and read order
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; rg -n "@references/official/current-docs-2026-06-09\\.md|@references/official/current-docs-2026-06-09\\.ko\\.md|support_file_read_order|official TanStack docs|api-drift-notes" skills/tanstack-start-architecture/SKILL.md skills/tanstack-start-architecture/SKILL.ko.md | tee .omo/evidence/task-6-entrypoints.txt'
    Expected: command exits 0 and evidence includes current snapshot links in both entrypoints
    Evidence: .omo/evidence/task-6-entrypoints.txt

  Scenario: entrypoints no longer link the old snapshot directly
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; ! rg -n "@references/official/current-docs-2026-06-02" skills/tanstack-start-architecture/SKILL.md skills/tanstack-start-architecture/SKILL.ko.md | tee .omo/evidence/task-6-entrypoints-error.txt'
    Expected: command exits 0 because old direct/read-order links are absent
    Evidence: .omo/evidence/task-6-entrypoints-error.txt
  ```

  Commit: YES | Message: `docs(tanstack-start): update skill entrypoints` | Files: [`skills/tanstack-start-architecture/SKILL.md`, `skills/tanstack-start-architecture/SKILL.ko.md`, `.omo/evidence/task-6-entrypoints.txt`, `.omo/evidence/task-6-entrypoints-error.txt`]

- [ ] 7. Refresh architecture summary and source-priority rules

  What to do: Update `architecture-rules.md` and `.ko.md` so the source-priority list points to the new 2026-06-09 snapshot and refreshed drift notes. Refresh the common-mistakes and auto-remediation summaries to match Tasks 3-5 while preserving the distinction between official facts, safety policy, and Hypercore conventions.
  Must NOT do: Do not duplicate full topic rules in `architecture-rules.md`; it should remain a routing/summary document.

  Parallelization: Can parallel: YES | Wave 2 | Blocks: [9] | Blocked by: [1, 2, 3, 4, 5]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/tanstack-start-architecture/architecture-rules.md:13-20` - current source-priority list to refresh
  - Pattern:  `skills/tanstack-start-architecture/architecture-rules.md:24-36` - blocking safety gates to align with refreshed API guidance
  - Pattern:  `skills/tanstack-start-architecture/architecture-rules.md:54-61` - official-vs-Hypercore clarification to preserve
  - Pattern:  `skills/tanstack-start-architecture/architecture-rules.md:77-107` - auto-remediation and common mistakes to refresh
  - API/Type: `skills/skill-maker/SKILL.md:107-115` - support-file layering model
  - Test:     `skills/vite-architecture/scripts/validate-vite-architecture-skill.mjs:29-37` - required phrase-check style

  Acceptance criteria (agent-executable only):
  - [ ] Before editing, old snapshot references are detectable with: `bash -lc 'set -euo pipefail; rg -n "current-docs-2026-06-02" skills/tanstack-start-architecture/architecture-rules.md skills/tanstack-start-architecture/architecture-rules.ko.md'`
  - [ ] After editing, architecture summaries reference `current-docs-2026-06-09`, current API drift, and refreshed setup/server/routing guidance.
  - [ ] Summary docs keep source-priority, blocking safety gates, topic files, auto-remediation policy, common mistakes, and completion rule sections.

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: architecture summary points to refreshed sources and rules
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; rg -n "current-docs-2026-06-09|Official|Safety policy|Hypercore convention|inputValidator|validator|Rsbuild|Vite|same-origin|server routes|공식|안전" skills/tanstack-start-architecture/architecture-rules.md skills/tanstack-start-architecture/architecture-rules.ko.md | tee .omo/evidence/task-7-architecture-summary.txt'
    Expected: command exits 0 and evidence shows refreshed source priority and classification wording in both files
    Evidence: .omo/evidence/task-7-architecture-summary.txt

  Scenario: architecture summary no longer references the old snapshot
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; ! rg -n "current-docs-2026-06-02" skills/tanstack-start-architecture/architecture-rules.md skills/tanstack-start-architecture/architecture-rules.ko.md | tee .omo/evidence/task-7-architecture-summary-error.txt'
    Expected: command exits 0 because stale snapshot references are absent
    Evidence: .omo/evidence/task-7-architecture-summary-error.txt
  ```

  Commit: YES | Message: `docs(tanstack-start): refresh architecture rule summary` | Files: [`skills/tanstack-start-architecture/architecture-rules.md`, `skills/tanstack-start-architecture/architecture-rules.ko.md`, `.omo/evidence/task-7-architecture-summary.txt`, `.omo/evidence/task-7-architecture-summary-error.txt`]

- [ ] 8. Update validation docs and add deterministic skill validator

  What to do: Refresh `rules/validation.md` and `.ko.md` so skill-anatomy checks look for the new snapshot, current API drift wording, current setup/routing/server guidance, and bilingual siblings. Add or update `skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs` using the local architecture-skill validator patterns. The script must support `HYPERCORE_TANSTACK_START_SKILL_ROOT=<path>` so QA can run a copied negative fixture without modifying real skill files.
  Must NOT do: Do not depend on network in the validator. Do not make validation pass if `current-docs-2026-06-02` remains in active entrypoints or summary docs.

  Parallelization: Can parallel: YES | Wave 2 | Blocks: [9] | Blocked by: [1, 2, 3, 4, 5]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/tanstack-start-architecture/rules/validation.md:34-65` - current skill-anatomy checks to refresh
  - Pattern:  `skills/tanstack-start-architecture/rules/validation.md:67-98` - trigger tests and completion checklist
  - Pattern:  `skills/vite-architecture/scripts/validate-vite-architecture-skill.mjs:5-27` - required-file array pattern
  - Pattern:  `skills/vite-architecture/scripts/validate-vite-architecture-skill.mjs:29-37` - required phrase pattern
  - Pattern:  `skills/vite-architecture/scripts/validate-vite-architecture-skill.mjs:71-89` - code-fence, Korean sibling, core-size, and reference-depth checks
  - Pattern:  `skills/nextjs-architecture/scripts/validate-nextjs-architecture-skill.mjs:60-84` - alternate local validator size and Korean sibling checks
  - Test:     `skills/skill-tester/scripts/validate-skill.mjs:84-86` - JSON success/error output style

  Acceptance criteria (agent-executable only):
  - [ ] Before editing, stale validation references are detectable with: `bash -lc 'set -euo pipefail; rg -n "current-docs-2026-06-02" skills/tanstack-start-architecture/rules/validation.md skills/tanstack-start-architecture/rules/validation.ko.md'`
  - [ ] After editing, `node skills/skill-tester/scripts/validate-skill.mjs skills/tanstack-start-architecture` exits 0.
  - [ ] After editing, `node skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs` exits 0 and prints JSON success.
  - [ ] Negative fixture validation exits non-zero when a copied entrypoint is changed back to `current-docs-2026-06-02`.

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: local skill validators pass on refreshed skill
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; node skills/skill-tester/scripts/validate-skill.mjs skills/tanstack-start-architecture | tee .omo/evidence/task-8-skill-tester.json; node skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs | tee .omo/evidence/task-8-validator.json'
    Expected: command exits 0 and both evidence files contain JSON success output
    Evidence: .omo/evidence/task-8-validator.json

  Scenario: validator rejects stale snapshot regression in a copied fixture
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; tmp="$(mktemp -d)"; cp -R skills/tanstack-start-architecture "$tmp/tanstack-start-architecture"; perl -0pi -e "s/current-docs-2026-06-09/current-docs-2026-06-02/g" "$tmp/tanstack-start-architecture/SKILL.md"; HYPERCORE_TANSTACK_START_SKILL_ROOT="$tmp/tanstack-start-architecture" node skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs 2>&1 | tee .omo/evidence/task-8-validator-error.txt; test "${PIPESTATUS[0]}" -ne 0'
    Expected: command exits 0 overall because the validator process fails on the stale copied fixture
    Evidence: .omo/evidence/task-8-validator-error.txt
  ```

  Commit: YES | Message: `test(tanstack-start): add skill validation harness` | Files: [`skills/tanstack-start-architecture/rules/validation.md`, `skills/tanstack-start-architecture/rules/validation.ko.md`, `skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs`, `.omo/evidence/task-8-skill-tester.json`, `.omo/evidence/task-8-validator.json`, `.omo/evidence/task-8-validator-error.txt`]

- [ ] 9. Run bilingual alignment and end-to-end skill refresh audit

  What to do: Run a final alignment pass across all changed English/Korean sibling files. Fix any missing mirrored sections, stale file references, unbalanced code fences, missing local support links, or undocumented official-source decisions. Use the validator from Task 8 plus direct text checks. Capture a tmux-based CLI QA transcript for the full skill.
  Must NOT do: Do not add new content categories outside the refreshed TanStack Start usage guidance. Do not rewrite unrelated wording just for style.

  Parallelization: Can parallel: NO | Wave 3 | Blocks: [] | Blocked by: [6, 7, 8]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `instructions/skill/SKILL_AUTHORING.md:105-117` - workflow includes bilingual/mirror updates
  - Pattern:  `instructions/skill/SKILL_AUTHORING.md:148-161` - validation criteria for links/code fences
  - Pattern:  `README.md:299-303` - skill changes require `SKILL.md` and `SKILL.ko.md` updates and evidence
  - Pattern:  `skills/skill-maker/SKILL.md:210-223` - validation thresholds for skill deliverables
  - Test:     `skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs` - deterministic local validator added in Task 8

  Acceptance criteria (agent-executable only):
  - [ ] Every changed English markdown file in `skills/tanstack-start-architecture` that requires a Korean sibling has one.
  - [ ] No active entrypoint, summary, or validation file references `current-docs-2026-06-02`.
  - [ ] `node skills/skill-tester/scripts/validate-skill.mjs skills/tanstack-start-architecture` and `node skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs` both exit 0.
  - [ ] A tmux session runs the final CLI QA and writes `.omo/evidence/task-9-tmux-qa.txt`.

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: end-to-end validators and stale-reference checks pass
    Tool:     bash
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; node skills/skill-tester/scripts/validate-skill.mjs skills/tanstack-start-architecture | tee .omo/evidence/task-9-skill-tester.json; node skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs | tee .omo/evidence/task-9-validator.json; ! rg -n "current-docs-2026-06-02" skills/tanstack-start-architecture/SKILL.md skills/tanstack-start-architecture/SKILL.ko.md skills/tanstack-start-architecture/architecture-rules.md skills/tanstack-start-architecture/architecture-rules.ko.md skills/tanstack-start-architecture/rules/validation.md skills/tanstack-start-architecture/rules/validation.ko.md | tee .omo/evidence/task-9-stale-links.txt'
    Expected: command exits 0, validators print success JSON, and stale-link evidence is empty
    Evidence: .omo/evidence/task-9-validator.json

  Scenario: tmux manual CLI QA captures the same final checks
    Tool:     tmux
    Steps:    cd /Users/alpox/Desktop/dev/kood/hypercore && bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; tmux kill-session -t tanstack-start-skill-qa 2>/dev/null || true; tmux new-session -d -s tanstack-start-skill-qa "cd /Users/alpox/Desktop/dev/kood/hypercore && set -euo pipefail; node skills/skill-tester/scripts/validate-skill.mjs skills/tanstack-start-architecture; node skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs; rg -n \"current-docs-2026-06-09|api-drift-notes|TanStack Builder|sendContext|importProtection\" skills/tanstack-start-architecture/SKILL.md skills/tanstack-start-architecture/architecture-rules.md skills/tanstack-start-architecture/rules/*.md; touch .omo/evidence/task-9-tmux-qa.done"; for i in $(seq 1 60); do test -f .omo/evidence/task-9-tmux-qa.done && break; sleep 1; done; tmux capture-pane -pt tanstack-start-skill-qa -S -2000 > .omo/evidence/task-9-tmux-qa.txt; test -f .omo/evidence/task-9-tmux-qa.done'
    Expected: command exits 0 and captured pane contains validator success and current-doc/reference matches
    Evidence: .omo/evidence/task-9-tmux-qa.txt
  ```

  Commit: YES | Message: `chore(tanstack-start): verify refreshed skill docs` | Files: [`skills/tanstack-start-architecture/**`, `.omo/evidence/task-9-skill-tester.json`, `.omo/evidence/task-9-validator.json`, `.omo/evidence/task-9-stale-links.txt`, `.omo/evidence/task-9-tmux-qa.txt`]

## Final verification wave (MANDATORY - after all implementation tasks)
> Runs in PARALLEL. ALL must APPROVE. Surface results to the caller and wait for an explicit "okay" before declaring complete.
- [ ] F1. Plan compliance audit - every task done, every acceptance criterion met. Command: `bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; test -f .omo/plans/tanstack-start-architecture-docs-refresh.md; for n in 1 2 3 4 5 6 7 8 9; do ls .omo/evidence/task-${n}-* >/dev/null; done; git diff --name-only | tee .omo/evidence/f1-plan-compliance-files.txt'`
- [ ] F2. Code quality review - diagnostics clean, idioms match, no dead code. Command: `bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; node skills/skill-tester/scripts/validate-skill.mjs skills/tanstack-start-architecture | tee .omo/evidence/f2-skill-tester.json; node skills/tanstack-start-architecture/scripts/validate-tanstack-start-architecture-skill.mjs | tee .omo/evidence/f2-validator.json'`
- [ ] F3. Real manual QA - every QA scenario executed with evidence captured. Command: `bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; for n in 1 2 3 4 5 6 7 8 9; do ls .omo/evidence/task-${n}-* >/dev/null; done; tmux capture-pane -pt tanstack-start-skill-qa -S -2000 > .omo/evidence/f3-tmux-recapture.txt; test -s .omo/evidence/f3-tmux-recapture.txt'`
- [ ] F4. Scope fidelity - nothing extra shipped beyond Must-Have, nothing Must-NOT-Have introduced. Command: `bash -lc 'set -euo pipefail; mkdir -p .omo/evidence; git diff --name-only | tee .omo/evidence/f4-scope-files.txt; ! git diff --name-only | rg -v "^(skills/tanstack-start-architecture/|\\.omo/evidence/|\\.omo/plans/tanstack-start-architecture-docs-refresh\\.md$)" | tee .omo/evidence/f4-out-of-scope-files.txt'`

## Commit strategy
- One logical change per commit. Conventional Commits (`<type>(<scope>): <subject>` body + footer).
- Atomic: every commit builds and passes tests on its own.
- No "WIP" / "fix typo squash later" commits on the final branch - clean up before merge.
- Reference the plan file path in the final commit footer: `Plan: .omo/plans/tanstack-start-architecture-docs-refresh.md`.

## Success criteria
- All Must-Have shipped; all QA scenarios pass with captured evidence; F1-F4 approved; commit history clean.
