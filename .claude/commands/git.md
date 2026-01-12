---
description: Git 상태 확인 및 커밋 작업
argument-hint: [push|pull|commit instructions...]
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
