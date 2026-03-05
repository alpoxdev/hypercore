# Sequential Thinking Pattern

**Purpose**: Solve complex problems by decomposing them into structured steps.

## Core Principle

**Run Sequential Thinking before starting non-trivial work.**

## Thinking Depth by Complexity

| Complexity | Steps | Typical Work |
|--------|---------|------|
| **LOW** | 1-2 | Simple question, file read, quick search |
| **MEDIUM** | 3-5 | Feature implementation, bug fix, documentation work |
| **HIGH** | 7-10+ | Architecture design, large refactor, complex debugging |

## When to Use

| Situation | Required |
|------|----------|
| New feature implementation | ✅ Required (3-5 steps) |
| Bug fixing | ✅ Required (3-5 steps) |
| Refactoring | ✅ Required (5-7 steps) |
| Architecture design | ✅ Required (7-10 steps) |
| File reading | ❌ Optional (1 step) |
| Simple search | ❌ Optional (1 step) |

## Parameters

| Required | Description |
|------|------|
| `thought` | Current reasoning statement |
| `nextThoughtNeeded` | Whether another thought is needed (`true`/`false`) |
| `thoughtNumber` | Current thought index (starts at 1) |
| `totalThoughts` | Estimated total steps (can be adjusted dynamically) |

| Optional | Description |
|------|------|
| `isRevision` | Whether this revises prior reasoning |
| `revisesThought` | Which thought number is being revised |
| `branchFromThought` | Branch starting point |
| `branchId` | Branch identifier |

## Code Examples

### Example 1: Simple task (2 steps)

```typescript
// Thought 1: file exploration plan
mcp__sequential-thinking__sequentialthinking({
  thought: "Need to inspect src/functions/ to locate user-related files",
  thoughtNumber: 1,
  totalThoughts: 2,
  nextThoughtNeeded: true
})

// Thought 2: execution decision
mcp__sequential-thinking__sequentialthinking({
  thought: "Run Glob search with pattern **/*user*.ts",
  thoughtNumber: 2,
  totalThoughts: 2,
  nextThoughtNeeded: false
})
```

### Example 2: Medium complexity (5 steps)

```typescript
// Thought 1: problem definition
mcp__sequential-thinking__sequentialthinking({
  thought: "Type error in login API. Need to inspect src/functions/auth.ts",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// Thought 2: exploration plan
mcp__sequential-thinking__sequentialthinking({
  thought: "Read auth.ts and related type file src/types/auth.ts in parallel",
  thoughtNumber: 2,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// Thought 3: root-cause analysis
mcp__sequential-thinking__sequentialthinking({
  thought: "LoginInput type is missing email. Zod schema and TypeScript type are inconsistent",
  thoughtNumber: 3,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// Thought 4: solution
mcp__sequential-thinking__sequentialthinking({
  thought: "Add email: string to LoginInput. Existing Zod schema is already correct",
  thoughtNumber: 4,
  totalThoughts: 5,
  nextThoughtNeeded: true
})

// Thought 5: execution decision
mcp__sequential-thinking__sequentialthinking({
  thought: "Edit src/types/auth.ts, then run tsc again",
  thoughtNumber: 5,
  totalThoughts: 5,
  nextThoughtNeeded: false
})
```

### Example 3: Dynamic adjustment (3 -> 5 steps)

```typescript
// Thought 1
mcp__sequential-thinking__sequentialthinking({
  thought: "Start implementing API endpoint. Estimated in 3 steps",
  thoughtNumber: 1,
  totalThoughts: 3,
  nextThoughtNeeded: true
})

// Thought 2
mcp__sequential-thinking__sequentialthinking({
  thought: "Found that auth middleware is required while checking existing patterns; increase step count",
  thoughtNumber: 2,
  totalThoughts: 5, // increased from 3 to 5
  nextThoughtNeeded: true
})

// Continue thought 3-5...
```

## Key Capabilities

### 1. Dynamic adjustment

**`totalThoughts` is not fixed:**
- Re-evaluate complexity during execution.
- Increase or decrease steps when needed.

### 2. Revision

**Revisit prior reasoning:**

```typescript
mcp__sequential-thinking__sequentialthinking({
  thought: "Thought 3 root-cause was incorrect. Actual issue is DB schema mismatch",
  thoughtNumber: 6,
  totalThoughts: 7,
  isRevision: true,
  revisesThought: 3,
  nextThoughtNeeded: true
})
```

### 3. Branching

**Explore multiple approaches:**

```typescript
mcp__sequential-thinking__sequentialthinking({
  thought: "Approach A: use REST API",
  thoughtNumber: 4,
  totalThoughts: 8,
  branchFromThought: 3,
  branchId: "approach-a",
  nextThoughtNeeded: true
})

mcp__sequential-thinking__sequentialthinking({
  thought: "Approach B: use GraphQL",
  thoughtNumber: 4,
  totalThoughts: 8,
  branchFromThought: 3,
  branchId: "approach-b",
  nextThoughtNeeded: true
})
```

## Forbidden Language Patterns

**Avoid the following expression styles:**

| Forbidden style | Why | Replacement |
|----------|------|----------|
| "should" without evidence | speculative | state validated fact |
| "probably" | uncertain | "decide after verification" |
| "seems to" | ambiguous | "analysis shows ~" |
| "maybe" | speculative | "verification needed" |
| "looks like" | uncertain | direct factual statement |

**Correct style:**

```typescript
// ❌ weak statement
thought: "Changing this file will probably fix it"

// ✅ precise statement
thought: "Missing type definition confirmed. Fix in src/types/user.ts resolves the issue"
```

## Checklist

Before starting:

- [ ] Determine complexity (LOW/MEDIUM/HIGH)
- [ ] Set minimum step count
- [ ] Write first thought as problem definition
- [ ] Set `nextThoughtNeeded=false` only on the final thought

During execution:

- [ ] End each thought with a concrete conclusion
- [ ] Avoid speculative language
- [ ] Adjust `totalThoughts` when needed
- [ ] Use revision/branching if uncertain

**Start all non-trivial tasks with Sequential Thinking.**
