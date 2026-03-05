# Context Engineering Guide for Docs Maker

**Purpose**: Turn documentation into high-signal, low-noise context that AI can parse, retrieve, and execute reliably.

## 1. Core Principles

### 1.1 Right Altitude

Use principle + pattern + example. Avoid both extremes:

- Too low: exhaustive branching and edge-case trees.
- Too high: vague statements with no operational criteria.

Preferred shape:

1. One clear rule
2. One short rationale
3. One copy-paste pattern

### 1.2 Context Is Finite

Treat tokens as a constrained resource:

- Keep core file compact and action-focused.
- Move deep detail into `rules/` or `references/`.
- Load details just in time, not all at once.

### 1.3 Explicit > Implicit (Claude 4.x)

Claude 4.x tends to execute literally and minimally unless guided.

- Bad: "Improve this."
- Good: "Improve this by applying A, B, C. Validate with X and Y."

## 2. Prompt/Doc Structure Patterns

## 2.1 XML-Segmented Layout

Use consistent sections so retrieval remains stable:

- `<purpose>`
- `<trigger_conditions>`
- `<workflow>`
- `<forbidden>`
- `<required>`
- `<validation>`

## 2.2 Behavior Control Blocks

Use only when needed:

```xml
<default_to_action>Implement directly.</default_to_action>
<do_not_act_before_instructions>Suggest only until approved.</do_not_act_before_instructions>
<use_parallel_tool_calls>true</use_parallel_tool_calls>
<avoid_minimal_implementation>Deliver complete implementation.</avoid_minimal_implementation>
<verify_implementation>Check requirements, tests, types, and quality gates.</verify_implementation>
```

## 2.3 Positive Directives

Prefer "Do X" style instructions over stacked prohibitions.

- Bad: "Don't do A, don't do B, don't do C..."
- Good: "Do X using pattern Y; verify with Z."

## 3. Reasoning Strategy Selection

| Complexity | Reasoning mode | Guidance |
|------|------|------|
| Low | direct execution | no extra reasoning block |
| Medium | structured CoT | short step-based reasoning |
| High | extended reasoning | broader search, compare options, then decide |

For docs-maker:

- Always run `sequential-thinking` before major create/refactor work.
- Use revision/branching when assumptions change.

## 4. Compression and Retrieval Tactics

## 4.1 Compression Rules

- Replace long prose with tables.
- Replace abstract explanations with runnable patterns.
- Collapse repeated rules into one canonical section.
- Keep one term per concept; avoid synonyms that fragment retrieval.

## 4.2 Progressive Disclosure

Three-layer loading model:

1. Metadata: trigger-level summary
2. SKILL body: workflow and constraints
3. Rules/references: deep details loaded only when needed

## 4.3 Minimal-Start Iteration

Start with minimal valid instruction set.
If output quality is insufficient, add context in this order:

1. one concrete example
2. one explicit constraint
3. one validation gate

## 5. Claude 4.x-Specific Authoring Rules

- Assume literal interpretation.
- Specify completeness criteria explicitly.
- Specify action posture explicitly (act now vs suggest first).
- Specify parallelization intent for independent operations.

Completeness checklist phrase pattern:

"Include required states, error handling, edge cases, and validation outputs."

## 6. Practical Templates

## 6.1 Rule Statement Template

```markdown
Rule: [single actionable instruction]
Why: [one-line rationale]
Pattern:
[copy-paste snippet]
Validation:
- [observable check]
```

## 6.2 Workflow Step Template

```markdown
Phase N
- Goal:
- Inputs:
- Actions:
- Output:
- Exit criteria:
```

## 7. Anti-Patterns to Eliminate

- Ambiguous terms without criteria ("appropriately", "as needed")
- Excessive conditional branching in main docs
- Duplicate guidance across multiple sections
- Verification omitted or deferred
- Declaring completion without objective checks

## 8. Quality Gates for Documentation

Ship only when all pass:

- Structure is scannable and sectioned
- Instructions are explicit and testable
- Examples are runnable/reusable
- Validation criteria are observable
- Redundancy and ambiguity are removed

