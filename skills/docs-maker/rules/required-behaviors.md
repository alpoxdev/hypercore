# Required Behaviors

**Purpose**: Rules that must be followed in docs-maker create and refactor work.

## 1. Work Start

### Required 1: Plan before major edits

Use `sequential-thinking` before non-trivial create or refactor work.

| Complexity | Minimum steps | Typical work |
|------|------|------|
| LOW | 1-2 | Quick read, small wording fix |
| MEDIUM | 3-5 | Document refactor, rule cleanup |
| HIGH | 5-8+ | Multi-file skill redesign, harness restructuring |

### Required 2: Read before edit

Read the target files before modifying them. For refactors, identify:

- critical intent to preserve
- repeated rules to collapse
- stale guidance to remove
- provider-sensitive guidance to isolate

### Required 3: Read independent files in parallel

When 3+ independent files are needed to understand the current rule set, read them in parallel.

### Required 4: Choose the target layer before editing

Before writing, decide whether the content belongs in:

- canonical core
- provider reference
- local overlay

## 2. Documentation Authoring

### Required 5: Preserve intent, improve shape

In refactor mode:

- preserve the original operational intent unless it is stale or contradicted by stronger guidance
- improve clarity, density, and validation shape
- remove mixed concerns and duplicate content

### Required 6: Keep rules explicit and testable

Every important rule should answer:

- what to do
- when it applies
- how to validate it

### Required 7: Use stable structure

Prefer explicit sections, tables, and compact checklists when they make retrieval more reliable.

### Required 8: Keep examples attached to rules

For non-obvious rules, include a copy-paste-ready example or pattern.

### Required 9: Use one term per concept

Do not alternate between multiple names for the same concept unless the document explains the distinction.

## 3. Harness Documentation

### Required 10: Separate core rules from provider-sensitive rules

Use this split:

- canonical core: durable, provider-neutral guidance
- provider references or adapters: dated vendor-specific details
- local preferences: project-specific conventions

### Required 11: Keep canonical docs free of fixed model literals

In canonical skill and rule files:

- prefer capability profiles such as `frontier reasoning model` or `snapshot-pinned production model`
- move concrete model strings to provider reference files, migration notes, or deployment examples

### Required 12: Source provider-sensitive claims

If a rule depends on Anthropic or OpenAI behavior, attach or update a reference entry with:

- `source_url`
- `last_verified_at`
- `applies_to`
- `summary`
- `implication_for_docs_maker`

### Required 13: Resolve source conflicts explicitly

When official sources differ:

- prefer the more direct developer or API documentation
- keep the canonical rule stable
- put volatile provider-specific details in the reference layer

### Required 14: Document the full harness, not only the prompt

When the scope involves harness engineering, cover the relevant parts explicitly:

- prompt assets and templates
- tool contracts and descriptions
- eval datasets and graders
- safety and approval gates
- context ordering, state, and compaction
- model and version profile strategy

## 4. Validation

### Required 15: Validate mixed-concern cleanup

After refactoring, confirm the docs-maker default surface no longer contains rules that belong to unrelated implementation stacks or project-specific workflows.

### Required 16: Validate source freshness

For provider-sensitive guidance, confirm the cited official sources are current enough for the claim being made.

### Required 17: Validate wording and grep hygiene

Run repository searches when useful to confirm:

- stale fixed model literals are removed from canonical docs
- duplicate phrases are collapsed
- moved rules are not still duplicated in old files

### Required 18: Apply reviewer-fail criteria

Before declaring the skill update complete, confirm none of these reviewer-fail conditions are true:

- canonical docs mix core rules with vendor details without boundaries
- references exist but do not materially support the rules that cite them
- a harness document claims completeness while omitting tool, eval, safety, or context boundaries that are clearly in scope
- examples are more specific than the rules and silently smuggle in local preferences

### Required 19: Report what changed

Completion reporting should include:

- changed files
- simplifications made
- remaining risks or follow-up work

### Required 20: Do a readback pass

Before completion, read the updated canonical files as if you were a new maintainer and confirm:

- the skill purpose is obvious within the first screen
- the boundary between core rules and provider references is explicit
- the validation path is discoverable without searching across unrelated files
