---
description: 개발 진행 방법 검토 및 옵션 제시. ultrathink + sequential thinking 3-7 필수. 코드 수정 없이 계획만.
allowed-tools: Read, Glob, Grep, Bash(git:*, ast-grep:*), Task, Write, mcp__sequential-thinking__sequentialthinking
argument-hint: <feature to develop or problem to solve>
---

<critical_instruction>

**CRITICAL: 사용자와의 모든 커뮤니케이션은 반드시 한국어로 작성하세요.**

- 내부 사고와 분석은 영어로 해도 됨
- 설명, 요약, 보고서, 피드백 등 사용자에게 전달하는 모든 내용은 반드시 한국어
- 사용자가 영어로 말하더라도 답변은 한국어로
- 진행 상황 업데이트와 상태 보고는 반드시 한국어

이 규칙은 절대적이며 예외가 없습니다.

</critical_instruction>

---


# Plan Command

> Review development approach and present 2-3 options with pros/cons.

**Planning target**: $ARGUMENTS

---

<argument_validation>

## Verify ARGUMENT is provided

```
No $ARGUMENTS → Ask immediately:

"What should we plan? Please be specific.

Examples:
- Add new feature
- Fix bug
- Refactor
- Change architecture"

$ARGUMENTS provided → Proceed to next step
```

</argument_validation>

---

<workflow>

## Execution Flow

| Step | Task | Tool |
|------|------|------|
| 1. Validate input | Verify ARGUMENT, ask if missing | - |
| 2. Judge complexity | Determine analysis scope with Sequential Thinking | sequentialthinking (step 1) |
| 3. Explore codebase | Understand current state, explore related files | Task (Explore) + Read/Grep |
| 4. Derive options | Generate 4-5 possible approaches → select 2-3 main | sequentialthinking (steps 2-6) |
| 5. Present options | Present pros/cons, impact scope, recommendation | - |
| 6. User selection & document generation | Wait for option selection, then generate plan document | Write |

</workflow>

---

<agent_usage>

## @refactor-advisor Agent Usage

**When to use:**
- Establish refactoring plan
- Code quality improvement needed
- Reduce complexity, remove duplication

**How to call:**
```bash
@refactor-advisor
# or natural language
"Create refactoring plan for this code"
"Analyze code improvements"
```

**Benefits:**
- Auto-analyze complexity, duplication, patterns
- Derive improvements with Sequential Thinking (3-5 steps)
- Prioritized refactoring plan (High/Medium/Low)
- Concrete Before/After code examples
- Propose incremental change stages

**Analysis areas:**
- Complexity (function length, nesting depth)
- Duplication (identical/similar code)
- Naming (variable/function names)
- Structure (files/modules)
- Patterns (anti-patterns)
- Types (remove any)

**Difference from plan command:**
- plan: New feature/architecture change planning
- @refactor-advisor: Existing code improvement planning (no feature change)

**After refactoring execution:**
```bash
# 1. Refactoring plan
@refactor-advisor

# 2. After plan approval, implement
@implementation-executor

# 3. Validation
@deployment-validator
```

</agent_usage>

---

<thinking_strategy>

## Sequential Thinking Guide

### Judge complexity (thought 1)

```
thought 1: Judge complexity
- Impact scope: number of files, modules
- Dependencies: external libraries, system integration
- Risk: impact on existing features, rollback possibility
- Technical difficulty: new patterns, unknown areas
```

### Strategy by complexity

| Complexity | Thoughts | Criteria | Pattern |
|------------|----------|----------|---------|
| **Simple** | 3 | 1-2 files, clear changes | Judge complexity → current state → derive options |
| **Medium** | 5 | 3-5 files, logic changes | Judge complexity → current state → explore approaches → compare options → recommendation |
| **Complex** | 7+ | multiple modules, architecture change | Judge complexity → deep analysis → constraints → approaches → compare → detailed analysis → recommendation |

### Medium complexity pattern (5 steps)

```
thought 1: Judge complexity and determine analysis scope
thought 2: Analyze current state (code, architecture, constraints)
thought 3: Enumerate possible approaches (4-5)
thought 4: Select 3 main options and analyze pros/cons
thought 5: Finalize options and derive recommendation
```

### Complex case pattern (7 steps)

```
thought 1: Judge complexity
thought 2: Deep analysis of current state
thought 3: Summarize technical constraints and requirements
thought 4: Explore possible approaches
thought 5: Comparative analysis of each approach
thought 6: Select 3 options and detailed pros/cons
thought 7: Recommendation and rationale
```

### Key principles

```text
✅ Output thinking process to actually think
✅ Estimate high if complexity uncertain (can expand 5→7)
✅ Concrete analysis needed per thought (no abstract descriptions)
✅ Revise previous thoughts with isRevision if needed
```

</thinking_strategy>

---

<codebase_exploration>

## Task Subagent Usage

### Subagent selection

| subagent_type | Purpose | Example |
|---------------|---------|---------|
| **Explore** | Understand codebase structure, explore related files | "Analyze current auth structure" |
| **Plan** | Establish implementation strategy, step-by-step planning | "Create migration plan" |
| **general-purpose** | Complex analysis, multi-system correlation | "Analyze dependencies between modules" |

### Task call patterns

**Single exploration:**

```typescript
Task({
  subagent_type: 'Explore',
  description: 'Analyze current auth structure',
  prompt: `
    Understand current authentication-related code structure.
    - Libraries in use
    - Session management approach
    - Files needing modification
  `
})
```

**Parallel exploration (complex cases):**

```typescript
// Multiple Task calls in single message
Task({
  subagent_type: 'Explore',
  prompt: 'Analyze frontend auth structure'
})

Task({
  subagent_type: 'Explore',
  prompt: 'Analyze backend API auth endpoints'
})

Task({
  subagent_type: 'Explore',
  prompt: 'Analyze database session schema'
})

// → Combine results then organize options
```

### Exploration checklist

```text
✅ Understand current implementation approach
✅ Libraries/framework versions in use
✅ Related file and directory locations
✅ Dependencies and related modules
✅ Existing constraints (security, performance, compatibility)
```

</codebase_exploration>

---

<option_presentation>

## Option presentation format

### Present 3 options (standard)

```markdown
## Analysis Results

### Option 1: [Option name] (Recommended)

**Approach:**
- Description 1
- Description 2

| Pros | Cons |
|------|------|
| Pro 1 | Con 1 |
| Pro 2 | Con 2 |

**Impact scope:**
- Files: `src/auth/`, `src/api/`
- Expected change size: Medium
- Risk: Low

---

### Option 2: [Option name]

**Approach:**
...

| Pros | Cons |
|------|------|
| ... | ... |

**Impact scope:**
...

---

### Option 3: [Option name]

**Approach:**
...

---

## Recommendation and rationale

I recommend Option 1.
- Rationale 1
- Rationale 2

Which option would you choose? (1/2/3)
```

### Present 2 options (when choices are clear)

```markdown
## Analysis Results

There are two approaches:

### Option A: [Option name]
...

### Option B: [Option name]
...

Which option would you choose? (A/B)
```

</option_presentation>

---

<document_generation>

## Document generation

### Automatic document creation

After user selects an option, automatically create a plan document at `.claude/plans/[feature-name].md`.

```
You selected Option [N].

Creating plan document at .claude/plans/[feature-name].md...
```

### Plan document template

**File location:** `.claude/plans/[feature-name].md`

```markdown
# [Feature name] Implementation Plan

## Overview

**Goal:** [What will be achieved]
**Selected approach:** [Option N]
**Expected impact scope:** [Files/modules list]

## Current state

- Current structure description
- Related code location
- Existing constraints

## Implementation stages

### Stage 1: [Stage name]

**Tasks:**
- [ ] Task 1
- [ ] Task 2

**Changed files:**
- `src/file1.ts`
- `src/file2.ts`

### Stage 2: [Stage name]

**Tasks:**
- [ ] Task 3

**Changed files:**
- `src/file3.ts`

### Stage 3: [Stage name]
...

## Considerations

### Risks

| Risk | Mitigation |
|------|-----------|
| Risk 1 | Plan 1 |
| Risk 2 | Plan 2 |

### Dependencies

- External libraries: [List]
- Other systems: [List]

### Rollback plan

How to rollback if issues occur.

## Validation methods

- Test item 1
- Test item 2
- Integration test

## References

- Related document links
- Reference materials
```

</document_generation>

---

<validation>

## Validation checklist

Before execution:

```text
✅ Verify ARGUMENT (ask if missing)
✅ Sequential Thinking minimum 3 steps
✅ Explore codebase with Task (Explore)
✅ Minimum 2 options, recommended 3
✅ List pros/cons for each option
✅ Present impact scope and estimated work
```

Absolutely forbidden:

```text
❌ Start analysis without ARGUMENT
❌ Use Edit tool (code modification forbidden)
❌ Sequential Thinking less than 3 steps
❌ Present only 1 option
❌ Suggest options by guessing without code exploration
❌ Start implementation without user choice
❌ List options without pros/cons
```

</validation>

---

<examples>

## Real-world examples

### Example 1: Change auth system

```bash
User: /plan Change user authentication from JWT to session-based

1. Sequential Thinking (7 steps):
   thought 1: "Auth system change - high complexity, multiple module impact"
   thought 2: "Current JWT implementation analysis: src/auth/jwt.ts, token validation middleware"
   thought 3: "Constraints: maintain existing user sessions, Redis/DB choice"
   thought 4: "Approaches: incremental migration, full replacement, hybrid"
   thought 5: "Incremental has low risk, hybrid high complexity"
   thought 6: "Select 3 options and analyze pros/cons"
   thought 7: "Recommend incremental migration - easy rollback, step-by-step validation"

2. Task exploration:
   Task (Explore): "Analyze current JWT auth implementation"
   → Understand src/auth/, src/middleware/, API endpoints

3. Present options:
   Option 1: Incremental migration (Recommended)
   - Pro: Easy rollback, low risk
   - Con: Longer implementation time

   Option 2: Full replacement
   - Pro: Clean structure
   - Con: High risk

   Option 3: Hybrid approach
   - Pro: Flexibility
   - Con: Increased complexity

4. User choice: 1

5. Automatically create .claude/plans/session-auth.md
```

### Example 2: Add real-time notifications

```bash
User: /plan Add real-time notification feature

1. Sequential Thinking (5 steps):
   thought 1: "Real-time notifications - medium complexity, new feature"
   thought 2: "Current communication: REST API, no polling"
   thought 3: "Approaches: WebSocket, SSE, Long Polling, Firebase"
   thought 4: "WebSocket bidirectional, SSE unidirectional but simpler"
   thought 5: "Recommend WebSocket, polling inefficient"

2. Task exploration:
   Task (Explore): "Analyze current API structure and client communication"

3. Options:
   Option 1: WebSocket (Recommended)
   Option 2: Server-Sent Events
   Option 3: Short Polling

4. After user selection, automatically create plan document
```

### Example 3: Simple refactoring

```bash
User: /plan Convert utils functions to TypeScript

1. Sequential Thinking (3 steps):
   thought 1: "Simple refactoring - simple, 1-2 files"
   thought 2: "Need to analyze current utils.js"
   thought 3: "Type definition → conversion → test validation"

2. Task exploration:
   Read: src/utils.js
   Grep: search utils usages

3. Options:
   Option A: Incremental conversion (per file)
   Option B: Batch conversion

4. After user choice → create plan document → implement
```

</examples>
