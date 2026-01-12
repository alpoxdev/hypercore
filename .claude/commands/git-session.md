---
description: 현재 세션에서 수정한 파일만 커밋 후 푸시
---

# Git Session Command

> Use the @git-operator agent to selectively commit and push only files modified in the current session.

---

<critical_requirements>

## ⚠️ CRITICAL: Required checks before proceeding

**This command must use the @git-operator agent.**

### MANDATORY: Call @git-operator with Task tool

```typescript
Task({
  subagent_type: 'git-operator',
  description: 'Commit and push session files only',
  prompt: `
    Session commit mode:
    - Selectively commit only files related to current session
    - Must push (git push)
    - Exclude incomplete work from previous sessions
  `
})
```

**❌ Absolutely forbidden:**
- Execute git commands directly with Bash tool
- Perform commit/push without @git-operator
- Analyze files directly in command

**✅ Required:**
- Call @git-operator agent with Task tool
- Delegate all git work to agent
- Select only current session files

---

**Self-check before proceeding:**
```text
□ Task tool ready to use?
□ Delegating work to @git-operator agent?
□ Not executing git commands directly with Bash?
```

**⚠️ Do not start if checklist is not complete.**

</critical_requirements>

---

<mode>

**Session commit mode**

- **Selectively commit only files related to current session**
- **Must push** (git push)

</mode>

---

<selection_criteria>

| Include | Exclude |
|---------|---------|
| Files related to current session | Incomplete work from previous sessions |
| Recently worked files | Auto-generated files (lock, cache) |
| Related feature files | Unrelated changes |

</selection_criteria>

---

<workflow>

1. Analyze all changes
2. **Select only files related to current session**
3. Group into logical units
4. Commit each group
5. Execute git push

</workflow>

---

<example>

```bash
# Situation: Working on login feature, previous profile feature incomplete

git status
# modified: src/auth/login.ts (current session)
# modified: src/auth/logout.ts (current session)
# modified: src/profile/edit.ts (previous session)

# ✅ Commit only login-related files
git add src/auth/login.ts src/auth/logout.ts && git commit -m "feat: Add login/logout functionality"
git push
```

</example>
