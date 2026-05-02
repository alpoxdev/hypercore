# Context Engineering Guide for Docs Maker

**Purpose**: Turn documentation into high-signal, low-noise context that AI systems can parse, retrieve, and execute reliably.

## 0. Core Contract

Every instruction-style document should make these boundaries explicit when they affect execution:

| Section | Must state | Avoid |
|---|---|---|
| Intent | what success looks like to the user | persona-only framing |
| Scope | readable/editable/creatable targets | unlimited "everything related" scope |
| Authority | instruction priority and conflict handling | mixing user/project/tool rules silently |
| Evidence | trusted evidence channels and source grades | treating snippets or tool output as primary sources |
| Tools | when to use tools, stop, or delegate | inventing tools or hard-coding one runtime without a profile |
| Output | artifact shape, path, and completion criteria | vague "clean it up" endings |
| Verification | tests, evals, review, or source checks that prove completion | completion without evidence |

Use XML tags, Markdown headings, or tables; the mandatory part is boundary separation, not a specific syntax.

## 0.1 Instruction Layers

Keep one source of truth per rule:

| Layer | Examples | Role |
|---|---|---|
| Project root | `AGENTS.md`, `CLAUDE.md`, repo-wide instructions | short invariants and loading map |
| Reference base | `docs/**`, `references/**`, or linked repo-local guidance | shared methods, sourcing, validation |
| Runtime rules | Cursor rules, Codex config, Claude memory | runtime quirks and path scopes |
| Skill/command | `skills/**/SKILL.md`, slash command | narrow executable workflow |
| Task prompt | current user request | latest concrete override |

Root documents should stay short; deep material should be loaded just in time from references.

## 1. Core Principles

### 1.1 Right Altitude

Use principle + pattern + example. Avoid both extremes:

- Too low: exhaustive branching and edge-case trees in the main doc.
- Too high: vague statements with no operational criteria.

Preferred shape:

1. One clear rule
2. One short rationale
3. One copy-paste pattern
4. One observable validation check

### 1.2 Context Is Finite

Treat tokens as a constrained resource:

- Keep the core file compact and action-focused.
- Move deep detail into `rules/` or `references/`.
- Load details just in time, not all at once.
- Separate persistent guidance from per-run context and temporary notes.

### 1.3 Explicit > Implicit

AI systems tend to execute literally and minimally unless guided.

- Bad: "Improve this."
- Good: "Improve this by applying A, B, C. Validate with X and Y."

### 1.4 Stable Core, Volatile Edge

Keep core rules stable and abstract enough to survive vendor updates:

- Put provider-neutral principles in canonical docs.
- Put provider-sensitive behavior in dated reference files.
- Keep deployment-specific knobs out of core guidance unless they are essential to the workflow.

Decision rule:

- If the guidance changes when a provider ships a new model, tool behavior, or migration path, it does not belong in the canonical core.

### 1.5 Source Precedence

When guidance sources conflict, prefer:

1. Official provider developer or API docs
2. Official provider migration or safety guides
3. Official provider examples or business guides
4. Local project preferences

## 2. Prompt and Document Structure Patterns

### 2.1 Structured Sectioning

Use consistent sections so retrieval remains stable:

- `<purpose>`
- `<trigger_conditions>`
- `<workflow>`
- `<required>`
- `<forbidden>`
- `<validation>`

Markdown headers and tables are also valid when they improve readability. Prefer the structure that best preserves clear boundaries.

### 2.2 Behavior Control Blocks

Use behavior blocks only when they materially change execution:

```xml
<default_to_action>Implement directly when the next step is clear and reversible.</default_to_action>
<do_not_act_before_instructions>Research and recommend first when the user's intent is ambiguous.</do_not_act_before_instructions>
<use_parallel_tool_calls>true</use_parallel_tool_calls>
<verify_outputs>Check rules, examples, references, and validation gates before completion.</verify_outputs>
```

### 2.3 Positive Directives

Prefer "Do X" style instructions over stacked prohibitions.

- Bad: "Don't do A, don't do B, don't do C..."
- Better: "Do X using pattern Y; verify with Z."

### 2.4 Capability Profiles, Not Fixed Model Names

In canonical docs:

- Prefer `frontier reasoning model`, `fast general model`, or `snapshot-pinned production model`.
- Avoid fixed model literals unless they are confined to dated provider references or deployment examples.

## 3. Compression and Retrieval Tactics

### 3.1 Compression Rules

- Replace long prose with tables when the shape is repetitive.
- Replace abstract explanations with runnable patterns.
- Collapse repeated rules into one canonical section.
- Keep one term per concept; avoid synonyms that fragment retrieval.

### 3.2 Progressive Disclosure

Three-layer loading model:

1. Metadata: trigger-level summary
2. Skill body: workflow and constraints
3. Rules and references: deep details loaded only when needed

### 3.3 Minimal-Start Iteration

Start with the minimal valid instruction set.
If output quality is insufficient, add context in this order:

1. one concrete example
2. one explicit constraint
3. one validation gate
4. one reference-backed exception

## 4. State and Context Boundaries

- Distinguish canonical rules from task state, progress notes, and temporary scratch context.
- When documenting long-running harnesses, state what is persisted, what is compacted, and what can be safely dropped.
- For long-context systems, document the preferred ordering of static instructions, reference material, and variable inputs.

## 5. Anti-Drift Maintenance

- Add verification dates to provider-sensitive reference entries.
- Refresh reference entries when a migration guide, tool-behavior note, or model-profile policy materially changes.
- Prefer updating one reference entry over silently patching multiple core files.

## 6. Practical Templates

### 6.1 Rule Statement Template

```markdown
Rule: [single actionable instruction]
Why: [one-line rationale]
Pattern:
[copy-paste snippet]
Validation:
- [observable check]
```

### 6.2 Workflow Step Template

```markdown
Phase N
- Goal:
- Inputs:
- Actions:
- Output:
- Exit criteria:
```

### 6.3 Reference Entry Template

```markdown
## [Source or topic]
- source_url:
- last_verified_at:
- applies_to:
- summary:
- implication_for_docs_maker:
```

## 7. Anti-Patterns to Eliminate

- Ambiguous terms without criteria
- Excessive conditional branching in the main doc
- Duplicate guidance across multiple sections
- Verification omitted or deferred
- Fixed model names in canonical core rules
- Provider-sensitive claims without dated references

## 8. Quality Gates for Documentation

Ship only when all pass:

- Structure is scannable and sectioned
- Instructions are explicit and testable
- Examples are runnable or reusable
- Validation criteria are observable
- Redundancy and ambiguity are removed
- Provider-sensitive guidance is isolated and source-backed
- Reference entries are dated and maintained in the correct layer
