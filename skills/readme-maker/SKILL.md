---
name: readme-maker
description: "[Hyper] Create or refactor a project README.md by carefully reading the codebase. Detects project shape (CLI, library, web app, monorepo, plugin, framework, docs site, service), entry points, scripts, configuration, license, and existing docs, then produces a structured README in the project's primary documentation language. Use when the user wants a new README, a refactor of a stale README, or a section update grounded in the actual code."
compatibility: Works best with read/edit/write and shell search tools for project structure scanning, manifest inspection, and source verification.
---

@rules/project-discovery.md
@rules/section-design.md
@rules/validation.md
@references/readme-templates.md

# README Maker

> Read the project carefully, then write the README the project actually deserves.

<purpose>

- Generate a project `README.md` grounded in the real codebase, not boilerplate.
- Refactor stale or generic READMEs so install, usage, structure, and examples match current code.
- Adapt section choice and depth to project shape (CLI, library, web app, monorepo, plugin, framework, docs site, service).
- Preserve evidence: every install command, script, badge, and example traces back to a file in the repo.

</purpose>

<routing_rule>

Use `readme-maker` when the primary deliverable is a `README.md` (root or sub-package) for a project, library, CLI, plugin, workspace, framework, docs site, or service.

Route neighboring work elsewhere:

- Use `docs-maker` when the output is a general doc, runbook, instruction base, or harness rule pack.
- Use `prd-maker` when the output is a product planning package (PRD, diagram, feature spec, user flow, wireframe).
- Use `seo-maker` when the output is an SEO/AEO/GEO audit or marketing-page optimization.
- Use `research` when the job is pure fact-finding with no README artifact.
- Use `version-update` when the main job is bumping a version or producing release notes.
- Use `git-commit` or `git-maker` when the main job is committing a README change after the README is finalized.

Do not use `readme-maker` when:

- the user wants only a `CHANGELOG.md`, `CONTRIBUTING.md`, `LICENSE`, or other non-README file
- the user wants source-code edits, refactors, or feature implementation and only mentions README in passing
- the user wants live external research with no README artifact
- the user wants AI-readable instruction docs or harness rule packs (use `docs-maker`)

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | Produce or improve a `README.md` that reflects the real shape, install, usage, and constraints of the target project. |
| Scope | Own the target `README.md` (root or package) and a short summary; do not edit source code, configuration, license, or unrelated docs unless the user asks. |
| Authority | User instructions and project-local docs (`AGENTS.md`, `CLAUDE.md`, root README, package manifests) outrank generic README conventions and external templates. |
| Evidence | Ground every install command, script invocation, file path, badge, and feature claim in a real file under the project. Do not invent commands or APIs. |
| Tools | Use read/edit/write and shell search (`find`, `grep`, `ls`) only inside the project. Do not run install, build, deploy, or release commands as part of authoring. |
| Output | A single written or updated `README.md`, plus a short summary noting which files were inspected and which sections changed. |
| Verification | Run project-discovery, shape, language, and evidence checks from `rules/validation.md` before completion. |
| Stop condition | Finish when checks pass and any uncertain claims are flagged with `<!-- TODO -->`; escalate when project shape is ambiguous, license is unclear, or commands cannot be verified from the repo. |

</instruction_contract>

<activation_examples>

Positive requests:

- "Read this project carefully and create a README.md."
- "Refactor the README so it matches the current CLI commands."
- "Generate a README for the `packages/color` workspace in this monorepo."
- "Update the install and usage sections of README to reflect the new entry point."
- "프로젝트 README.md 만들어줘." (Korean positive create request; should trigger.)
- "이 저장소를 꼼꼼히 읽고 README를 다시 써줘." (Korean refactor request; should trigger.)

Negative requests:

- "Create a CHANGELOG from the commit log." Use `git-commit`/`version-update` paths instead.
- "Write API documentation for this library." Use `docs-maker`.
- "Plan the next release of this project." Use `prd-maker` or `plan`.
- "이 코드베이스에 새 기능을 추가해줘." (Korean feature request; not a README task.)

Boundary requests:

- "Document this project."
  Use `readme-maker` only when the output is a `README.md`. Use `docs-maker` when the output is a guide, runbook, or instruction base.
- "Refactor this README and commit the change."
  Use `readme-maker` for the README itself; route the commit to `git-commit` or `git-maker` after the README is finalized.
- "이 README 리팩터하고 커밋도 같이 해줘." (Korean boundary; README first via `readme-maker`, then commit via `git-commit`/`git-maker`.)

</activation_examples>

<trigger_conditions>

| Situation | Mode |
|------|------|
| Project has no `README.md` | create |
| `README.md` exists but is stale, generic, or contradicts current code | refactor |
| Specific sections need updating after a feature, rename, or move | update |
| A sub-package or workspace inside a monorepo needs its own README | create |
| README needs to align with the project's primary documentation language | refactor |

</trigger_conditions>

<supported_targets>

- Root `README.md` of an app, library, CLI, plugin, framework, docs site, or service.
- Package-level `README.md` inside a monorepo workspace.
- README refactors that re-derive sections from current code.
- README updates that touch install, usage, configuration, scripts, examples, or project structure.
- Language alignment when project docs are predominantly Korean, English, or another language.

</supported_targets>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Confirm the deliverable is a `README.md`; pick `create`/`refactor`/`update` | Mode decision |
| 1 | Scan project structure and detect shape (`rules/project-discovery.md`) | Project profile |
| 2 | Read existing README, `AGENTS.md`, `CLAUDE.md`, license, manifests, and entry points | Evidence base |
| 3 | Pick sections, order, depth, and language (`rules/section-design.md`) | Section plan |
| 4 | Draft or refactor `README.md` using grounded examples and templates from `references/readme-templates.md` | Updated README |
| 5 | Run validation checks (`rules/validation.md`) and write the completion summary | Final README + summary |

### Phase 4 authoring rules

- Read first, write second. Never invent install commands, scripts, environment variables, or APIs.
- Match the project's primary documentation language. If `AGENTS.md`, `CLAUDE.md`, or the existing README is Korean, write the README in Korean.
- Prefer one accurate example over three speculative ones.
- Keep the README scannable: title, description, install, and quickstart belong above the fold.
- Move long deep-dive content out of the README and link to it; the README should orient, not exhaust.
- Do not add badges that cannot be verified (CI status, coverage, npm version) unless the project already publishes them.

</workflow>

<modes>

## create mode

- Start from the project profile and pick the matching template in `references/readme-templates.md`.
- Include only sections supported by real evidence in the repo.
- Mark unknowns explicitly with `<!-- TODO: confirm with maintainer -->` instead of fabricating.

## refactor mode

- Preserve correct existing content; rewrite only sections that drift from the code.
- Re-derive install, usage, scripts, and structure sections from current files.
- Keep links, badges, and prose that still hold; remove dead links and stale commands.

## update mode

- Touch only the sections the user named or the diff implies.
- Append a dated entry to a change-history section only if the project README already tracks one.

</modes>

<forbidden>

| Category | Avoid |
|------|------|
| Fabrication | Install commands, scripts, environment variables, or APIs not present in the repo |
| Drift | Stale screenshots, broken links, deprecated commands left in place |
| Overload | Embedding full API references, long tutorials, or design docs inside the README |
| Tone | Marketing fluff, vague superlatives, hype the code does not support |
| Side effects | Editing source code, configs, or licenses while authoring the README |
| Extra files | Creating `CHANGELOG.md`, `CONTRIBUTING.md`, or other docs unless the user asks |

</forbidden>

<required>

| Category | Required |
|------|------|
| Evidence | Every install/usage line maps to a manifest, script, source file, or existing doc in the repo |
| Shape match | Section selection matches the detected project type |
| Language match | README language matches the project's primary documentation language |
| Discoverability | Title, one-line description, install, and quickstart are above the fold |
| Verification | Validation checklist completed before claiming done |

</required>

<structure_blueprint>

Default README outline (adapt by project type per `references/readme-templates.md`):

1. Title + one-line description
2. Optional badges (only when verifiable)
3. Features or highlights (3-7 bullets max)
4. Install
5. Quickstart / Usage
6. Configuration / Environment
7. Commands or API surface (CLI, library, plugin)
8. Examples
9. Development (build, test, dev server, scripts)
10. Project structure (only when non-trivial)
11. Contributing (only if the project documents a process)
12. License

</structure_blueprint>

<validation>

| Check | Rule |
|------|------|
| Evidence | Each command and path in the README exists in the repo |
| Shape | The selected template matches the actual project type |
| Language | README language matches existing project docs |
| Above the fold | Title, description, install, and quickstart appear within the first screen |
| No fabrication | No invented APIs, scripts, env vars, or external badges |
| Lean body | Long content is linked, not inlined |
| Translation pair | If the skill itself or other markdown was edited, English/Korean files stay aligned |

Must-pass thresholds:
- [ ] Project shape detected and recorded in the completion summary
- [ ] At least one verified install command and one verified usage example
- [ ] Existing README sections that remain accurate are preserved (refactor/update mode)
- [ ] Unknowns are marked with `<!-- TODO -->`, not fabricated
- [ ] No dead links or removed scripts left in the new draft

</validation>
