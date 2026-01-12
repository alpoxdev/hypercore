---
description: Git 상태 확인 및 커밋 작업
argument-hint: [push|pull|commit instructions...]
---

# Git Command

> Perform Git operations using @git-operator agent.

---

<critical_requirements>

## ⚠️ CRITICAL: Verification required before start

**This command MUST use the @git-operator agent.**

### MANDATORY: Call @git-operator with Task tool

```typescript
Task({
  subagent_type: 'git-operator',
  description: 'Git commit operation',
  prompt: `
    Process $ARGUMENTS:
    [User arguments or default behavior description]
  `
})
```

**❌ Absolutely forbidden:**
- Execute git commands directly with Bash tool
- Commit/push without @git-operator
- Directly analyze files in command

**✅ Required:**
- Call @git-operator agent with Task tool
- Delegate all git operations to agent

---

**Self-check before proceeding:**
```text
□ Task tool ready to use?
□ Delegate to @git-operator agent?
□ Not executing git directly with Bash?
```

**⚠️ Do not start unless checklist passes.**

</critical_requirements>

---

<mode>

**Default Mode**: Selective commit

- Commit some changes only
- Push is optional (only when specified)

</mode>

---

<arguments>

**Has $ARGUMENTS**: Execute those instructions first

| Example | Action |
|---------|--------|
| `push` | Commit then push |
| `pull` | Run git pull first |
| `login-feature-only` | Commit only that file |

**No $ARGUMENTS**: Default behavior

1. Analyze git status, git diff
2. Group into logical units
3. Selective commit

</arguments>
