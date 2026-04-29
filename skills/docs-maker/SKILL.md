---
name: docs-maker
description: "[Hyper] Create and refactor AI-readable documentation and harness-ready rule packs for prompt, tool, eval, safety, and context workflows."
compatibility: Works best with read/edit/write and shell search tools for document analysis, source verification, and quality checks.
---

@rules/sequential-thinking.md
@rules/context-engineering.md
@rules/harness-engineering.md
@rules/forbidden-patterns.md
@rules/required-behaviors.md

# Docs Maker Skill

> Unified skill for creating and refactoring structured documentation and harness-ready guidance.

<purpose>

- Build new structured docs that AI systems can parse, retrieve, and execute reliably.
- Refactor existing docs to improve density, clarity, source-grounding, and maintenance safety.
- Design rule packs that support prompt assets, tool contracts, eval loops, safety gates, and context management.

</purpose>

<routing_rule>

Use `docs-maker` when the output is a structured document, runbook, spec, prompt artifact, or harness rule pack.

Use `skill-maker` instead when the output should become a reusable skill folder or a refactor of an existing skill.

Do not use `docs-maker` when:

- the main job is code changes, feature implementation, or bug fixing
- the user needs a reusable skill rather than a document
- the task is a product or architecture change and documentation is only a side effect

</routing_rule>

<activation_examples>

Positive requests:

- "Refactor this stale agent-operation guide so provider-specific rules move to references."
- "Create a harness rule pack for prompts, tools, evals, safety gates, and context management."
- "Refresh the OpenAI and Anthropic reference entries, then update the dependent canonical docs."

Negative requests:

- "Create a new Codex skill for browser QA."
- "Fix architecture violations in a TanStack Start route refactor."

Boundary request:

- "Create a guide for writing skills."
  Use `docs-maker` only if the output is a document or runbook. Use `skill-maker` if the output should become a reusable skill folder.

</activation_examples>

<trigger_conditions>

| Situation | Mode |
|------|------|
| New structured guidance is needed | create |
| Existing guidance is too long, repetitive, or vague | refactor |
| Team needs one canonical documentation shape | create/refactor |
| Harness rules for prompts, tools, evals, or safety are missing | create/refactor |

</trigger_conditions>

<supported_targets>

- Policy documents
- Playbooks and runbooks
- Technical specs and design notes
- Workflow and process guides
- Prompting and agent-operation guides
- Harness documentation for prompts, tools, evals, safety, and context

</supported_targets>

<documentation_architecture>

Use this layering model by default:

- Canonical core: durable rules that should survive provider and model churn
- Provider references: dated Anthropic/OpenAI facts, migration notes, and behavior differences
- Local overlays: project-specific conventions or workflow preferences

Do not mix these layers in one section unless the document explicitly labels the boundary.

</documentation_architecture>

<reference_routing>

Move guidance into official reference files when any of the following is true:

- the rule depends on vendor behavior that may change
- the rule mentions a migration, snapshot, or release-sensitive detail
- the rule is accurate only for one provider or one tool family

Keep guidance in canonical core files when it remains true across providers and model generations.

</reference_routing>

<support_file_read_order>

Read in this order:

1. The core `SKILL.md` to decide whether the task is `create`, `refactor`, or a route-away case.
2. `rules/sequential-thinking.md`, `rules/context-engineering.md`, and `rules/harness-engineering.md` when planning the structure, context shape, or harness coverage.
3. `rules/required-behaviors.md` and `rules/forbidden-patterns.md` before declaring the document done.
4. `references/official/openai.md` and `references/official/anthropic.md` only when provider-sensitive guidance materially changes the rule.

</support_file_read_order>

<mandatory_reasoning>

## Mandatory Sequential Thinking

- Always use `sequential-thinking` before major create/refactor work.
- In create mode: use it to design section structure, constraints, and verification.
- In refactor mode: use it to identify redundancy, ambiguity, stale references, and mixed concerns.
- Do not edit documents before the structure plan is complete.

</mandatory_reasoning>

<context_engineering_application>

Apply context-engineering defaults to every major edit:

- Choose the right instruction altitude.
- Treat tokens as finite; keep the core doc compact and push deep detail into `rules/` and `references/`.
- Use explicit, concrete directives with observable validation.
- Prefer stable sectioning and progressive disclosure over long mixed-concern prose.
- Keep canonical guidance provider-neutral where possible; isolate provider-sensitive guidance in references or adapter sections.

</context_engineering_application>

<modes>

## create mode

- Start from a minimal skeleton.
- Add only high-value rules, examples, and validation gates.
- Prefer tables, checklists, and compact patterns over long prose.

## refactor mode

- Preserve critical intent and operational behavior.
- Remove repetition, vague guidance, and stale provider coupling.
- Convert explanation-heavy sections into compact rules, examples, and references.

</modes>

<default_outputs>

Default output shapes:

- create mode: new canonical doc + any required rule/reference files + validation checklist
- refactor mode: updated canonical doc + collapsed rules + moved references + explicit simplification summary

</default_outputs>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Confirm the target layer (`core` / `reference` / `local overlay`) before writing | Placement decision |
| 1 | Read target docs and classify mode (`create`/`refactor`) | Scope + mode |
| 2 | Build structure plan with `sequential-thinking` | Section plan |
| 3 | Write/refactor canonical content | Updated document |
| 4 | Add or refresh official references when provider-sensitive guidance appears | Reference layer |
| 5 | Run a readback pass for drift, mixed concerns, and layer placement | Review notes |
| 6 | Validate quality, consistency, and source freshness | Finalized document |

### Phase 3 authoring rules

- Use explicit sections with stable headings.
- Prefer positive directives (`Do X`) over prohibition-only guidance when possible.
- Keep examples copy-paste ready and scoped to the rule they illustrate.
- Keep instructions specific. Replace terms like "appropriately" or "if needed" with criteria.
- Use one term per concept across the full document.
- Keep canonical rules provider-neutral unless a provider-specific difference materially changes behavior.
- Place content in the highest-stability layer that still preserves accuracy.
- Label provider-sensitive exceptions at the point where they appear.
- Keep sections small and scannable so retrieval is reliable under context pressure.

</workflow>

<forbidden>

| Category | Avoid |
|------|------|
| Structure | Unstructured long paragraphs with mixed concerns |
| Content | Redundant rules repeated in multiple sections |
| Guidance | Ambiguous instructions without decision criteria |
| Provider coupling | Fixed model literals in canonical core docs |
| Quality | Removing key constraints during refactor |

</forbidden>

<required>

| Category | Required |
|------|------|
| Clarity | Clear section hierarchy and concise wording |
| Actionability | Concrete workflow steps and validation checks |
| Examples | Runnable or directly reusable examples |
| Consistency | Same terminology and rule style across sections |
| Source grounding | Official references for provider-sensitive guidance |
| Maintainability | Separation between core rules, provider adapters, and local preferences |
| Placement | Content is stored in the right layer for its volatility and scope |

</required>

<structure_blueprint>

Use this default layout unless a better domain-specific layout is required:

1. Objective
2. Scope and assumptions
3. Rules (`required` / `forbidden`)
4. Execution workflow
5. Examples or patterns
6. Validation checklist
7. References when provider-sensitive guidance exists

</structure_blueprint>

<usage_examples>

### Example: refactor a stale skill

- Read the skill body and all default rule files.
- Classify content into core rules, provider references, and local overlays.
- Remove mixed implementation concerns from the canonical core.
- Add or refresh official reference entries for provider-sensitive claims.
- Run grep and readback checks before closing.

### Example: create a harness rule pack

- Define the prompt asset contract.
- Define tool contracts and approval boundaries.
- Define eval criteria and failure handling.
- Define context ordering and compaction policy.
- Add provider references only where vendor behavior materially changes the rule.

</usage_examples>

<validation>

| Check | Rule |
|------|------|
| Structure | Major sections are clearly separated |
| Density | Repetition removed; tables used where helpful |
| Actionability | Steps can be executed without guessing |
| Examples | Examples match actual workflow and tools |
| Safety | Critical constraints preserved after refactor |
| Context quality | Right altitude + explicitness + low redundancy |
| Source freshness | Provider-sensitive claims cite official docs and verification dates |
| Model neutrality | Canonical core docs avoid fixed model literals |

Completion checklist:
- [ ] Target layer decided before writing
- [ ] Mode decided (`create` or `refactor`)
- [ ] Sequential-thinking plan created first
- [ ] Context-engineering checks applied (`rules/context-engineering.md`)
- [ ] Harness-engineering checks applied when relevant (`rules/harness-engineering.md`)
- [ ] Provider-sensitive guidance moved to references or adapter sections
- [ ] Document updated with compact structure
- [ ] Readback pass confirms the updated docs still match the intended workflow
- [ ] Validation checks completed

Must-pass thresholds:
- [ ] At least 3 positive trigger examples
- [ ] At least 2 negative trigger examples
- [ ] At least 1 boundary trigger example
- [ ] Support-file read order is explicit enough to start without searching
- [ ] Route-away requests name the neighboring skill or direct surface
- [ ] English and Korean core workflows expose the same phase order and readback path

Reviewer quick gate:
- Fail if canonical docs contain fixed model literals.
- Fail if provider-sensitive claims appear without official references.
- Fail if unrelated implementation-stack mandates appear in the default docs-maker load path.
- Fail if a harness doc omits eval, tool, safety, or context boundaries that are clearly in scope.

</validation>
