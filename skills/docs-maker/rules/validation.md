# Validation Rules for Docs Maker

**Purpose**: Make completion claims evidence-backed instead of stylistic opinions.

## 1. Completion Contract

Every docs-maker completion should be able to answer:

```text
Claim → Evidence → Verification → Caveat
```

A final report should say what changed, what proves it, and what remains risky or unverified.

## 2. Scope Completeness

For bulk or "all X" documentation requests:

1. Search or glob the full candidate set.
2. Record include/exclude criteria.
3. Add newly discovered candidates or state why they are excluded.
4. Re-scan before completion.
5. Report anything intentionally left out.

## 3. Verification Menu

| Claim | Suitable verification |
|---|---|
| Markdown structure changed | heading/readback check, fence balance, link/path grep |
| Links or references changed | link existence, target path check, stale-ref grep |
| Source-backed claim changed | source ledger, claim-source matrix, official/current source check |
| Prompt/instruction changed | smoke eval cases, known failure readback, trace assertions |
| Harness workflow changed | eval plan, tool contract, safety boundary, context/state policy |
| Parallel/subagent workflow changed | bounded objective/scope/output/stop condition, ownership, parent integration/verification |

## 4. Trace Assertions for Agent Docs

When documenting agents, subagents, or background workflows, include trajectory checks when relevant:

- bounded spawn or handoff prompt
- independent work or explicit sequencing
- declared write ownership for edit-capable work
- least-privilege tool access
- child evidence reporting
- parent synthesis and final verification
- no conflicting edits to shared files/resources

## 5. Smoke Eval Shape

Use compact eval cases for instruction changes:

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

## 6. Readback Pass

Before completion, read the updated doc as:

- a new maintainer placing the next rule
- an agent executing the workflow under context pressure
- a reviewer looking for stale, unsupported, or mixed-concern claims

Fail the readback if the validation path requires searching unrelated files.

## 7. Final Report Shape

```markdown
Completed:
- [changed files and result]

Validated:
- [checks run and evidence]

Remaining risks:
- [none, or explicit caveats]
```

Do not hide skipped checks. State why they were not run.

## 8. Reviewer Quick Gate

Fail the document if any condition is true:

- canonical docs contain fixed model literals or runtime-only syntax treated as universal
- provider-sensitive or current claims lack suitable source support
- retrieved content or tool output is treated as instruction authority
- unrelated implementation-stack mandates appear in a general docs-maker surface
- harness docs omit eval, tool, safety, context, or validation boundaries that are clearly in scope
- English and Korean mirrors expose different phase order or incompatible readback paths
