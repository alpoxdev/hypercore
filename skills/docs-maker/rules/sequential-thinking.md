# Sequential Thinking Pattern

**Purpose**: Solve documentation and harness-design problems by decomposing them into structured steps.

## Core Principle

Run `sequential-thinking` before starting non-trivial create or refactor work.

## Thinking Depth by Complexity

| Complexity | Steps | Typical work |
|------|------|------|
| LOW | 1-2 | Small wording fix, one-file cleanup |
| MEDIUM | 3-5 | Document refactor, rule consolidation |
| HIGH | 5-8+ | Multi-file skill redesign, harness restructuring |

## When to Use

| Situation | Required |
|------|------|
| New documentation skeleton | Yes |
| Refactoring a long or repetitive skill | Yes |
| Reworking provider-sensitive guidance | Yes |
| Adding a small note to an already-stable doc | Optional |

## Parameters

| Required | Description |
|------|------|
| `thought` | Current reasoning statement |
| `nextThoughtNeeded` | Whether another thought is needed |
| `thoughtNumber` | Current thought index |
| `totalThoughts` | Estimated total steps |

| Optional | Description |
|------|------|
| `isRevision` | Whether this revises earlier reasoning |
| `revisesThought` | Which thought is being revised |
| `branchFromThought` | Branch origin |
| `branchId` | Branch identifier |

## Example: Refactoring a stale skill

```typescript
mcp__sequential_thinking__sequentialthinking({
  thought: "Need to refactor docs-maker so its core rules stay provider-neutral and remove mixed implementation concerns.",
  thoughtNumber: 1,
  totalThoughts: 4,
  nextThoughtNeeded: true
})

mcp__sequential_thinking__sequentialthinking({
  thought: "Read the skill body and rule files, then classify content into core, provider-reference, and local-overlay groups.",
  thoughtNumber: 2,
  totalThoughts: 4,
  nextThoughtNeeded: true
})

mcp__sequential_thinking__sequentialthinking({
  thought: "Rewrite canonical files to keep only documentation and harness rules. Move provider-sensitive details to reference files and confirm the layer placement is correct.",
  thoughtNumber: 3,
  totalThoughts: 4,
  nextThoughtNeeded: true
})

mcp__sequential_thinking__sequentialthinking({
  thought: "Run grep checks for stale model literals and review the final wording for consistency and validation coverage.",
  thoughtNumber: 4,
  totalThoughts: 4,
  nextThoughtNeeded: false
})
```

## Key Capabilities

### 1. Dynamic adjustment

`totalThoughts` is not fixed. Increase or reduce the step count when the document scope changes.

### 2. Revision

Revisit prior reasoning when a source check invalidates an assumption.

### 3. Branching

Use branching when comparing alternative document structures or rule-pack splits.

## Wording Rules for Thoughts

- End each thought with a concrete conclusion or next action.
- Avoid speculative language when the next step requires verification.
- Prefer statements grounded in file reads or source evidence.

## Checklist

- [ ] Determine complexity
- [ ] Set an initial step count
- [ ] Write the first thought as a problem definition
- [ ] Revise or branch if the scope changes
- [ ] Set `nextThoughtNeeded=false` only on the final thought
