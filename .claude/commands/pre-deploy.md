---
description: Verify and fix typecheck/lint/build before deployment. Sequential thinking required.
allowed-tools: Bash(tsc:*, npx:*, yarn:*, npm:*, pnpm:*), Read, Edit, mcp__sequential-thinking__sequentialthinking
argument-hint: [file/directory paths...]
---

# Pre-Deploy Command

> Verify and fix typecheck/lint/build before deployment with Sequential Thinking

---

<forbidden>

| Category | Forbidden |
|----------|-----------|
| **Avoidance** | Deploy with errors, excessive `any` type, `@ts-ignore`, `eslint-disable` |
| **Strategy** | Fix multiple errors simultaneously, skip build, fix hastily based on error message |
| **Analysis** | Fix without Sequential Thinking |

</forbidden>

---

<agent_usage>

## @deployment-validator Agent Usage

**When to use:**
- Full validation before PR creation
- Quality assurance before deployment
- Local validation before CI/CD

**How to call:**
```bash
@deployment-validator
# or natural language
"Check if ready to deploy"
"Validate pre-deploy"
```

**Benefits:**
- Full automation of typecheck + lint + build
- Auto-analyze cause of build failure with Sequential Thinking
- Final judgment on deployment readiness
- Run in independent context (can parallelize with main work)

**Direct validation vs Agent:**

| Situation | Recommended |
|-----------|-------------|
| During rapid development | Direct validation (command) |
| Before PR creation | @deployment-validator |
| Final check before deployment | @deployment-validator |
| Local check before CI/CD | @deployment-validator |
| Automated validation | @deployment-validator |

</agent_usage>

---

<required>

| Category | Required |
|----------|----------|
| **Thinking** | Sequential Thinking 3-5 steps per error |
| **Tracking** | Track error list with TodoWrite |
| **Strategy** | Run typecheck + lint in parallel → sequential fix → build |
| **Validation** | Recheck each file after fixing |
| **Build** | Run build after all errors resolved and verify success |

</required>

---

<workflow>

1. **Parallel check**
   ```bash
   npx tsc --noEmit
   npx eslint .
   ```

2. **Create TodoWrite**
   - List typecheck errors
   - List lint errors
   - Priority: type errors → lint errors → lint warnings

3. **Sequential fix** (per error)
   - Sequential Thinking 3-5 steps
   - Apply fix
   - Recheck file
   - Update TodoWrite (completed)

4. **Run build**
   ```bash
   # Verify package.json scripts then run
   npm run build  # or yarn build, pnpm build
   ```

5. **Verify build success**
   - If errors occur, analyze and fix with Sequential Thinking
   - If successful, ready for deployment

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

# Build (requires package.json check)
npm run build
yarn build
pnpm build
```

**Argument handling:**

| Argument | Action |
|----------|--------|
| None | Check entire project + build |
| File path | Check that file only (skip build) |
| Directory | Check that directory only (skip build) |

</commands>

---

<examples>

**Example 1: Full workflow**

```
1. Run parallel check
   npx tsc --noEmit
   → TS2322: Type 'string' is not assignable to type 'number'

   npx eslint .
   → error: 'user' is assigned a value but never used (no-unused-vars)

2. Create TodoWrite
   - Fix TS2322 error (src/utils/calc.ts:15)
   - Fix no-unused-vars (src/components/Form.tsx:8)

3. Sequential Thinking (TS2322)
   thought 1: "TS2322 error. Assigning string to number"
   thought 2: "Check return value type and actual return in calc.ts:15"
   thought 3: "Function should return parseInt result but calling toString()"
   thought 4: "Fix options: 1) Remove toString() 2) Change return type"
   thought 5: "parseInt returns number so removing toString() is appropriate"

4. Fix with Edit → recheck with npx tsc --noEmit src/utils/calc.ts → resolved

5. Update TodoWrite (completed) → next error

6. After all errors resolved, run build
   npm run build → ✅ Build successful

7. Ready for deployment
```

**Example 2: Priority**

| Priority | Type | Example |
|----------|------|---------|
| 1 | Type errors (blocks compile) | TS2322, TS2345, TS2339 |
| 2 | Lint errors (error level) | no-unused-vars, no-undef |
| 3 | Lint warnings (warning level) | prefer-const, no-console |

**Example 3: Build failure scenario**

```
1. typecheck + lint pass

2. Run npm run build
   → Error: Cannot find module '@/utils/helper'

3. Sequential Thinking
   thought 1: "Import error during build"
   thought 2: "helper module doesn't exist or path error"
   thought 3: "Need to check file with Read"
   thought 4: "helper.ts doesn't exist, only helpers.ts"
   thought 5: "Fix import path to '@/utils/helpers'"

4. Fix with Edit → rerun npm run build → ✅ success
```

**Example 4: Partial check (with arguments)**

```bash
# Check only specific file (skip build)
/pre-deploy src/utils/calc.ts

→ npx tsc --noEmit src/utils/calc.ts
→ npx eslint src/utils/calc.ts
→ Fix errors
→ Don't run build
```

</examples>
