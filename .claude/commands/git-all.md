---
description: Commit all changes then push
---

# Git All Command

> Commit all changes and push using @git-operator agent.

---

<critical_requirements>

## ⚠️ CRITICAL: Verification required before start

**This command MUST use the @git-operator agent.**

### MANDATORY: Call @git-operator with Task tool

```typescript
Task({
  subagent_type: 'git-operator',
  description: 'Commit all changes then push',
  prompt: `
    Full commit mode:
    - Separate all changes into logical units and commit all
    - MUST push (git push)
    - Verify clean working directory
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
- Verify clean working directory after completion

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

**Full Commit Mode**

- Separate **all changes** into logical units and **commit all**
- **MUST push** (git push)
- Verify **no remaining changes** (clean working directory)

</mode>

---

<workflow>

1. Analyze all changes
2. Group into logical units
3. Commit each group (repeat)
4. Verify clean working directory
5. Execute git push

</workflow>
