---
description: tsc/eslint 오류 검사 및 하나씩 꼼꼼히 수정. @lint-fixer 에이전트 필수 사용.
allowed-tools: Task
argument-hint: [file/directory paths...]
---

# Lint Fix Command

> Automatically fix tsc/eslint errors using the @lint-fixer agent.

---

<critical_requirements>

## ⚠️ CRITICAL: Required checks before proceeding

**This command must use the @lint-fixer agent.**

### MANDATORY: Call @lint-fixer with Task tool

```typescript
Task({
  subagent_type: 'lint-fixer',
  description: 'Fix tsc/eslint errors',
  prompt: `
    Handle $ARGUMENTS:
    ${$ARGUMENTS ? `Specific paths: ${$ARGUMENTS}` : 'Check entire project'}

    Tasks to perform:
    1. Run tsc + eslint in parallel
    2. Classify errors (simple/complex)
    3. Create error list with TodoWrite
    4. Simple errors: fix immediately
    5. Complex errors: analyze with Sequential Thinking then fix
    6. Verify with full recheck
  `
})
```

**❌ Absolutely forbidden:**
- Execute tsc/eslint directly with Bash tool and manually fix
- Fix errors without @lint-fixer
- Analyze/fix errors directly in command

**✅ Required:**
- Call @lint-fixer agent with Task tool
- Delegate all lint work to agent
- Agent automatically judges simple/complex and handles accordingly

**@lint-fixer agent benefits:**
- Simple errors fixed immediately (no Sequential Thinking needed)
- Complex errors analyzed with Sequential Thinking only (efficient)
- Auto-track progress with TodoWrite
- Auto-prioritize (type errors → lint errors)

---

**Self-check before proceeding:**
```text
□ Task tool ready to use?
□ Delegating work to @lint-fixer agent?
□ Not executing tsc/eslint directly with Bash?
```

**⚠️ Do not start if checklist is not complete.**

</critical_requirements>

---

<forbidden>

| Category | Forbidden |
|----------|-----------|
| **Avoidance** | Excessive `any` type, `@ts-ignore`, `eslint-disable` |
| **Strategy** | Fix multiple errors simultaneously, fix hastily based on error message alone |
| **Analysis** | Fix without Sequential Thinking |

</forbidden>

---

<agent_usage>

## @lint-fixer Agent Usage

**When to use:**
- 10+ errors
- Multiple complex type errors
- Want automatic fixing in background

**How to call:**
```bash
@lint-fixer
# or natural language
"Fix lint errors automatically"
```

**Benefits:**
- Simple errors fixed immediately (no Sequential Thinking needed)
- Complex errors analyzed with Sequential Thinking only (efficient)
- Run in independent context (can parallelize with main work)

**Direct fix vs Agent:**

| Situation | Recommended |
|-----------|-------------|
| 1-5 simple errors | Direct fix (command) |
| 10+ errors | @lint-fixer |
| Multiple complex type errors | @lint-fixer |
| Quick fix needed | Direct fix |
| Background execution | @lint-fixer |

</agent_usage>

---

<required>

| Category | Required |
|----------|----------|
| **Thinking** | Sequential Thinking 3-5 steps per error |
| **Tracking** | Track error list with TodoWrite |
| **Strategy** | Fix one → recheck → next error |
| **Validation** | Recheck each file after fixing |
| **Parallel** | 5+ independent errors → parallel analysis with Task |

</required>

---

<workflow>

1. **Check**
   ```bash
   npx tsc --noEmit
   npx eslint .
   ```

2. **Create TodoWrite**
   - Organize error list

3. **Sequential fix** (per error)
   - Sequential Thinking 3-5 steps
   - Apply fix
   - Recheck file
   - Update TodoWrite (completed)

4. **Full recheck**

</workflow>

---

<sequential_thinking>

**Required for each error:**

| Step | Content |
|------|---------|
| 1 | Analyze and understand error message |
| 2 | Identify relevant code context |
| 3 | Identify root cause |
| 4 | Review fix options (consider multiple) |
| 5 | Select and apply optimal fix |

**Parameters:**

```typescript
{
  thought: "Current thinking content",
  nextThoughtNeeded: true | false,
  thoughtNumber: 1, // current step
  totalThoughts: 5  // expected total steps (dynamic)
}
```

</sequential_thinking>

---

<parallel_strategy>

**With 5+ errors:**

```
1. Identify independent error groups
2. Parallel analysis with Task (multiple Task calls in single message)
3. Combine results then sequential fix
```

**Rules:**

| Rule | Description |
|------|-------------|
| Check independence | Same file/related type → sequential |
| Parallel analysis only | Always sequential fix application |
| Validate results | Conflicts → resolve with Sequential Thinking |

**subagent_type:**

| Type | Purpose |
|------|---------|
| `Explore` | Explore code context related to error |
| `general-purpose` | Deep analysis of complex type errors |

</parallel_strategy>

---

<commands>

**Check:**

```bash
# TypeScript (all)
npx tsc --noEmit

# TypeScript (specific file)
npx tsc --noEmit $ARGUMENTS

# ESLint (all)
npx eslint .

# ESLint (specific file/directory)
npx eslint $ARGUMENTS
```

**Argument handling:**

| Argument | Action |
|----------|--------|
| None | Check entire project |
| File path | Check that file only |
| Directory | Check that directory only |

</commands>

---

<examples>

**Example 1: Sequential Thinking workflow**

```
1. Run npx tsc --noEmit
   → TS2322: Type 'string' is not assignable to type 'number'

2. Start Sequential Thinking:
   thought 1: "TS2322 error. Assigning string to number"
   thought 2: "Need to check variable type and value in file"
   thought 3: "Function return type is number but returning string"
   thought 4: "Fix options: 1) Fix return value 2) Change type"
   thought 5: "Fixing return value to correct number is appropriate"

3. Apply fix with Edit

4. Recheck with npx tsc --noEmit $FILE → confirm resolution

5. Update TodoWrite (completed) → next error
```

**Example 2: Parallel processing (5+ errors)**

```
Found 3 independent file errors:

Task 1: "Analyze TS2322 in src/utils/api.ts - type mismatch cause and fix"
Task 2: "Analyze ESLint no-unused-vars in src/components/Form.tsx"
Task 3: "Analyze TS2532 in src/hooks/useAuth.ts - undefined check location"

→ Run 3 Tasks in parallel (single message)
→ Combine results then use Sequential Thinking to determine fix order
→ Apply sequential fixes
```

**Example 3: Priority**

| Priority | Type | Example |
|----------|------|---------|
| 1 | Type errors (blocks compile) | TS2322, TS2345 |
| 2 | Lint errors (error level) | no-unused-vars |
| 3 | Lint warnings (warning level) | prefer-const |

</examples>
