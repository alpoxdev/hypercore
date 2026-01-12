---
description: 버그 원인 분석 및 수정. sequential thinking 3-5 + Task (Explore) 필수.
allowed-tools: Read, Grep, Glob, Task, Edit, Bash(npm:*, yarn:*), mcp__sequential-thinking__sequentialthinking
argument-hint: <bug description or error message>
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

# Bug Fix Command

> Command for bug cause analysis, fix option presentation, and implementation.

**Bug Target**: $ARGUMENTS

---

<argument_validation>

## ARGUMENT Verification Required

```
No $ARGUMENTS → Ask immediately:

"What bug needs fixing? Please provide details.

Examples:
- Error message and location
- Expected vs actual behavior
- How to reproduce
- Relevant file paths"

Has $ARGUMENTS → Proceed to next step
```

</argument_validation>

---

<workflow>

## Execution Flow

| Step | Task | Tool |
|------|------|------|
| 1. Input Verify | Validate ARGUMENT, ask if missing | - |
| 2. Complexity Judge | Determine analysis scope with Sequential Thinking | sequentialthinking (step 1) |
| 3. Reproduce Bug | Reproduce error, identify related files | Read/Grep/Glob |
| 4. Analyze Cause | Explore related code with Task (Explore) | Task (Explore) |
| 5. Derive Options | Generate 2-3 fix methods | sequentialthinking (steps 2-4) |
| 6. Present Options | Show pros/cons and impact scope | - |
| 7. User Choice | Wait for user to select fix method | - |
| 8. Implement | Fix code with selected method | Edit |
| 9. Verify | Run tests, confirm build | Bash |

</workflow>

---

<thinking_strategy>

## Sequential Thinking Guide

### Complexity Judgment (thought 1)

```
thought 1: Complexity judgment
- Error type: syntax/runtime/logic/type
- Impact scope: single file vs multiple files
- Dependencies: external libraries, API integration
- Reproducibility: always vs intermittent
```

### Complexity Strategy

| Complexity | Thoughts | Criteria | Pattern |
|------------|----------|----------|---------|
| **Simple** | 3 | Clear error, 1-2 files | Judge → Analyze cause → Fix method |
| **Normal** | 5 | Logic error, 3-5 files | Judge → Reproduce → Analyze → Compare options → Recommend |
| **Complex** | 7+ | Intermittent error, multi-module | Judge → Try reproduce → Deep analyze → Explore options → Compare → Recommend |

### Normal Complexity Pattern (5 steps)

```
thought 1: Complexity judgment and analysis scope
thought 2: Bug reproduction and error message analysis
thought 3: Related code exploration and cause identification
thought 4: Compare 2-3 fix methods
thought 5: Final recommendation and rationale
```

### Core Principles

```text
✅ Output thinking process for actual thinking to happen
✅ Judge high when uncertain (expandable 3→5)
✅ Concrete analysis required in each thought (no abstract)
✅ Use isRevision to modify previous thought if needed
```

</thinking_strategy>

---

<exploration>

## Task (Explore) Usage

### Exploration Strategy

| Bug Type | Explore Target | Prompt Example |
|----------|-----------------|-----------------|
| **Type Error** | Type definition, usage | "Find type X definition and usage files" |
| **Runtime Error** | Function call chain | "Find function Y call path and related files" |
| **Logic Error** | State management, data flow | "Find where state Z changes and its impact" |
| **API Error** | Endpoint, request/response | "Find API /path related code structure" |

### Task Invocation Pattern

**Single Exploration:**

```typescript
Task({
  subagent_type: 'Explore',
  description: 'Explore error-related code',
  prompt: `
    Understand error-related code structure:
    - Exact location where error occurs
    - Related functions/components
    - Dependent modules/libraries
    - Recent change history (git blame)
  `
})
```

**Parallel Exploration (complex cases):**

```typescript
// Multiple Task calls in single message
Task({
  subagent_type: 'Explore',
  prompt: 'Analyze frontend error component'
})

Task({
  subagent_type: 'Explore',
  prompt: 'Analyze backend API endpoint'
})

Task({
  subagent_type: 'Explore',
  prompt: 'Analyze type definitions and interfaces'
})

// → Collect results and identify cause
```

### Exploration Checklist

```text
✅ Exact error location
✅ Related functions/classes/components
✅ Data flow and state changes
✅ External dependencies (libraries, APIs)
✅ Recent changes (git log/blame)
```

</exploration>

---

<option_presentation>

## Option Presentation Format

### Present 2-3 Options

```markdown
## Bug Analysis Results

**Cause:** [Cause explanation]

**Impact Scope:** [File and module list]

---

### Option 1: [Fix Method] (Recommended)

**Fix Content:**
- Change 1
- Change 2

| Pros | Cons |
|------|------|
| Pro 1 | Con 1 |
| Pro 2 | Con 2 |

**Files to Fix:**
- `src/file1.ts:line`
- `src/file2.ts:line`

**Risk:** Low

---

### Option 2: [Fix Method]

**Fix Content:**
...

| Pros | Cons |
|------|------|
| ... | ... |

**Files to Fix:**
...

**Risk:** Medium

---

### Option 3: [Fix Method] (Temporary)

**Fix Content:**
...

**Risk:** High (not root cause fix)

---

## Recommendation and Rationale

Recommend Option 1.
- Rationale 1
- Rationale 2

Which option to use? (1/2/3)
```

</option_presentation>

---

<implementation>

## Implementation Guide

### Fix Steps

```
1. Wait for user option selection
2. Fix code with Edit tool
3. Explain changes
4. Run tests/build (optional)
5. Verify results
```

### Post-Fix Verification

```bash
# Type check
npm run typecheck
# Or
tsc --noEmit

# Run tests
npm test
# Or
npm test -- <related test file>

# Verify build
npm run build
```

### Verification Checklist

```text
✅ Error resolved
✅ Existing functionality intact
✅ No type errors
✅ Tests pass
✅ Build succeeds
```

</implementation>

---

<validation>

## Validation Checklist

Before execution:

```text
✅ Verify ARGUMENT (ask if missing)
✅ Sequential Thinking minimum 3 steps
✅ Code exploration with Task (Explore)
✅ Cause analysis clear
✅ Minimum 2 options, recommend 3
✅ Specify pros/cons for each option
✅ Specify file location to fix (include line)
```

Absolute prohibitions:

```text
❌ Start analysis without ARGUMENT
❌ Less than 3 Sequential Thinking steps
❌ Fix by guess without code exploration
❌ Present only 1 option
❌ Start fixing without user choice
❌ Skip verification after fix
❌ List fix methods without pros/cons
```

</validation>

---

<examples>

## Real-world Examples

### Example 1: Type Error

```bash
User: /bug-fix Property 'name' does not exist on type 'User'

1. Sequential Thinking (3 steps):
   thought 1: "Type error - simple, check User type definition"
   thought 2: "Need to explore User type and usage locations"
   thought 3: "2 options: modify type definition vs modify usage"

2. Task Exploration:
   Task (Explore): "Find User type definition location and usage files"
   → Identified src/types/user.ts, src/components/UserProfile.tsx

3. Cause Analysis:
   name property missing from User type

4. Option Presentation:
   Option 1: Add name property to User type (Recommended)
   - Pro: Root cause fix
   - Con: None

   Option 2: Remove name from usage
   - Pro: Quick fix
   - Con: Feature loss

5. User Selection: 1

6. Edit:
   src/types/user.ts:3
   + name: string;

7. Verification:
   npm run typecheck → Success
```

### Example 2: Runtime Error

```bash
User: /bug-fix Cannot read property 'data' of undefined

1. Sequential Thinking (5 steps):
   thought 1: "Runtime error - normal complexity, missing null check"
   thought 2: "Need to identify error location, check stack trace"
   thought 3: "Explore related code: API calls, data access patterns"
   thought 4: "Fix methods: optional chaining, null check, init"
   thought 5: "Recommend optional chaining - concise and safe"

2. Task Exploration:
   Task (Explore): "Analyze error code and data flow"
   → Found src/hooks/useUserData.ts:15, missing API response check

3. Cause Analysis:
   response is undefined when API call fails

4. Options:
   Option 1: Use optional chaining (Recommended)
   Option 2: Null check with if statement
   Option 3: Wrap with try-catch

5. After selection → Implementation → Verification
```

### Example 3: Logic Error

```bash
User: /bug-fix User list showing duplicates

1. Sequential Thinking (5 steps):
   thought 1: "Logic error - normal complexity, state management issue"
   thought 2: "Suspect duplicate rerender or data fetch"
   thought 3: "Explore related component and state management code"
   thought 4: "Options: fix useEffect dependencies, add duplicate logic"
   thought 5: "Recommend useEffect dependency fix"

2. Task Exploration:
   Task (Explore): "Analyze user list render and state management"
   → Found UserList.tsx, useEffect dependency array issue

3. Cause: useEffect missing dependency, fetching every render

4. Option presentation → Selection → Implementation → Verification
```

</examples>
