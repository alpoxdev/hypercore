# Harness Engineering Guide for Docs Maker

**Purpose**: Define how docs-maker should document the system around the prompt, not just the prompt itself.

## 0. Layering Rule

Document harnesses using three explicit layers:

- core rules
- provider references
- local overlays

If a sentence depends on vendor-specific behavior, it belongs in the provider-reference layer or must cite it directly.

## 0.1 Source Precedence

When provider guidance conflicts, prefer:

1. official developer or API docs
2. official migration or safety guides
3. official examples and business guides

## 1. Prompt Assets

- Document the prompt as an asset with a clear role, inputs, outputs, and validation expectations.
- Separate stable instructions from variable inputs and per-run state.
- Prefer templates and variables over duplicating near-identical prompts.
- When provider-specific behavior matters, cite the official source and verification date.

Pattern:

```markdown
## Prompt Asset
- Purpose:
- Stable instructions:
- Variable inputs:
- Output contract:
- Validation method:
```

## 2. Tool Contracts

- Describe each tool in terms of purpose, inputs, outputs, failure modes, and approval boundaries.
- Prefer reusable tool contracts over one-off prompt prose.
- State when the tool should be used and when direct work is better.
- If tool access is sensitive, document the guardrail or approval step explicitly.

Pattern:

```markdown
## Tool Contract: [Tool Name]
- Use when:
- Do not use when:
- Inputs required:
- Output expected:
- Approval or guardrail:
- Failure handling:
```

## 3. Eval Loops

- Define success criteria before recommending prompt or harness iteration.
- Document the eval set, graders, acceptance threshold, and failure triage path.
- Distinguish prompt regressions from tool, state, or policy regressions.

Pattern:

```markdown
## Eval Plan
- Success criteria:
- Test set:
- Graders:
- Acceptance threshold:
- What to change if the eval fails:
```

## 4. Safety and Approval Gates

- Document what inputs are untrusted.
- Document what actions require approval, confirmation, or human review.
- State how prompt injection and data leakage risks are reduced.
- If MCP or external tools are involved, note the expected approval posture.

## 5. Context Ordering and Caching

- Document what content is static and what content is variable.
- Place reusable, stable instructions where the target provider benefits most from shared prefixes or stable top-of-context content.
- State how long documents, examples, and user-specific inputs should be ordered.

Pattern:

```markdown
## Context Layout
1. Stable instructions
2. Reusable reference material
3. Variable user inputs
4. Current task or query
```

## 6. Conversation State and Compaction

- Document what state persists across turns.
- State what must survive compaction and what can be summarized away.
- For long-running harnesses, keep the active plan, current constraints, and unresolved risks explicit.
- Avoid treating task state as permanent policy.

Pattern:

```markdown
## State Policy
- Persistent:
- Compactable:
- Reconstructable:
- Must survive compaction:
```

## 7. Model and Version Profiles

- Canonical docs should describe capability profiles, not fixed model literals.
- If a deployment needs exact model strings or snapshots, place them in provider references or deployment examples.
- Document when version pinning is required for stability and when a provider-default latest model is acceptable.

## 8. Worked Example

```markdown
# Research Harness

## Prompt Asset
- Purpose: Compare vendor SDK documentation quality
- Stable instructions: gather official sources first, summarize differences, cite each key claim
- Variable inputs: target vendors, product area, output format
- Output contract: executive summary, findings, citations, recommendation
- Validation method: source count threshold + reviewer readback

## Tool Contract: Web Search
- Use when: the question is recency-sensitive or source attribution matters
- Do not use when: the user explicitly forbids browsing and the task can be solved locally
- Inputs required: query, domain filter, recency if needed
- Output expected: official URLs and supporting passages
- Approval or guardrail: only cite official docs for normative vendor guidance
- Failure handling: narrow the query or switch to a more direct source

## Eval Plan
- Success criteria: all key claims cite official sources; no stale model literals in the canonical rule file
- Test set: 5 representative harness-doc sections
- Graders: source-grounding, clarity, maintainability, rule-boundary hygiene
- Acceptance threshold: all must-pass checks true
- What to change if the eval fails: update references first, then rewrite the dependent rule

## Context Layout
1. Stable instructions
2. Reusable official references
3. Variable task inputs
4. Active query

## State Policy
- Persistent: accepted rules, source references, active constraints
- Compactable: completed sub-analyses
- Reconstructable: intermediate drafting notes
- Must survive compaction: current plan, unresolved risks, validation status
```

## 9. Source Metadata

For provider-sensitive guidance, keep a reference entry with:

- `source_url`
- `last_verified_at`
- `applies_to`
- `summary`
- `implication_for_docs_maker`
- `refresh_when`

## 10. Reference Refresh Workflow

- Refresh provider references when:
  - a canonical rule starts depending on undocumented behavior
  - a migration guide changes
  - model, tool, or context features materially shift
  - a reviewer cannot trace a provider-sensitive claim to an official source
- On refresh:
  - update the reference entry first
  - then update the canonical or adapter rule that depends on it
  - then run grep or readback checks for stale phrasing that the new source invalidates

## 11. Drift Signals

Watch for these drift signals:

- canonical docs mention a vendor behavior without a dated source
- a provider reference explains behavior that no canonical rule consumes
- examples become more concrete than the rules they support
- references disagree with each other about the same capability

## 12. Validation Checklist

- [ ] Prompt asset contract documented
- [ ] Tool contract documented when tools are in scope
- [ ] Eval plan documented when optimization is in scope
- [ ] Safety and approval gates stated when actions can affect systems or data
- [ ] Context ordering documented for long or cache-sensitive prompts
- [ ] State and compaction policy documented for long-running workflows
- [ ] Provider references include refresh-ready metadata
- [ ] Canonical docs avoid fixed model literals

## 13. Failure Triage

When a harness doc still feels weak after a refactor, inspect in this order:

1. missing core-vs-reference boundary
2. missing success criteria or eval plan
3. missing tool approval or safety rule
4. missing state or compaction policy
5. examples that are more specific than the governing rule
## 14. Minimum Eval Case Format

Use this shape for prompt/instruction regression cases:

```yaml
id: unique-case-id
intent: user goal
context:
  files: []
  sources: []
input: |
  user request
expected:
  must:
    - required behavior
  must_not:
    - forbidden behavior
metrics:
  - instruction_following
  - factuality
  - tool_use
  - safety
  - completion
```

## 15. Parallel / Subagent Trace Rules

When the document covers parallel agents, verify the trajectory as well as the final output:

| Assertion | Pass condition |
|---|---|
| bounded_spawn | objective, scope, output, and stop condition are present |
| independent_or_sequenced | parallel work has no hidden dependency or is explicitly sequenced |
| ownership_declared | edit-capable work has a declared write set |
| least_privilege_tools | read-only work does not require write or side-effect tools |
| child_reports_evidence | child output includes files, links, test output, or changed paths |
| parent_integrates | parent synthesizes conflicts, duplication, and gaps |
| parent_verifies | parent reads final tests/evals/source checks before completion |

## 16. Instruction Change Loop

```text
Define success → collect baseline cases → run current doc → diagnose failures → patch smallest surface → re-run → document risk
```
