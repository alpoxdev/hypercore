---
name: execute
description: Immediately start working on a given task with adaptive thinking depth — light thinking for easy tasks, deep thinking for hard ones. Use when the user wants immediate execution, not diagnosis, planning, or review.
compatibility: Use in environments with code exploration (Read/Grep/Glob), editing (Edit/Write), and validation commands (Bash).
---

# Execute

> Receive a task, classify its difficulty, think proportionally, and start working immediately.

<request_routing>

## Positive triggers

- A direct task instruction with a clear deliverable: "add pagination to the user list", "implement dark mode toggle", "유저 리스트에 페이지네이션 추가해줘", "다크모드 토글 구현해".
- An explicit execution request: "do this", "build this", "make this work", "이거 해줘", "이거 만들어줘", "이거 되게 해줘".
- A scoped feature or change request that does not require extended planning: "리팩터링해줘", "테스트 추가해줘", "이 컴포넌트 정리해줘".

## Out-of-scope

- Bug reports with error messages or failing symptoms. Route to `bug-fix`.
- Repository-wide build or CI failures. Route to `build-fix`.
- Strategic planning or architecture decisions. Route to `plan`.
- Code review or quality audit. Route to `code-review`.
- Security analysis. Route to `security-review`.

## Boundary cases

- If the request mixes a bug fix with new work, execute owns it when the primary intent is the new work.
- If the task scope is genuinely unclear (no deliverable identifiable), ask one clarifying question — then execute.
- If the task turns out to require architectural decisions mid-flight, pause and consult the user rather than guessing.

</request_routing>

<argument_validation>

If ARGUMENT is missing or too vague to identify a deliverable, ask briefly:

```text
What should I execute?
- Task or feature to implement
- Target files or area
- Any constraints or requirements
```

Do not over-interrogate. One round of clarification maximum, then start working.

</argument_validation>

<difficulty_classification>

Classify before thinking. Use these signals:

| Difficulty | Signals | Thinking depth |
|------------|---------|----------------|
| **Easy** | Single file, clear scope, familiar pattern, mechanical change | 1-3 thoughts |
| **Medium** | Multi-file, some ambiguity, moderate scope, requires context gathering | 4-6 thoughts |
| **Hard** | Cross-cutting, architectural impact, unfamiliar domain, complex interactions | 7+ thoughts |

For compound tasks (e.g. "refactor + add tests"), classify by the hardest sub-task. Treat the compound as one deliverable, not separate jobs.

When uncertain, round up one level. It is cheaper to over-think slightly than to redo work.

</difficulty_classification>

<mandatory_reasoning>

## Adaptive Sequential Thinking

Always run `sequential-thinking` before implementation. The number of thoughts scales with difficulty:

**Easy (1-3 thoughts)**:
1. What exactly needs to change
2. Where to change it
3. How to verify

**Medium (4-6 thoughts)**:
1. Scope and deliverable clarity
2. Relevant code exploration plan
3. Implementation approach
4. Edge cases or risks
5. Verification strategy
6. (Optional) Alternative approach comparison

**Hard (7+ thoughts)**:
1. Scope and deliverable clarity
2. Codebase context and dependencies
3. Design approach
4. Implementation breakdown
5. Edge cases and failure modes
6. Cross-cutting impact
7. Verification strategy
8+ (as needed) Revision, branching, deeper analysis

Announce the classification briefly before starting:

```
Difficulty: [easy/medium/hard] — [one-line reason]
```

</mandatory_reasoning>

<execution_rules>

## Core principle: act, don't deliberate

- Start implementing after thinking. Do not present options or wait for confirmation.
- If a decision point arises where both paths are reasonable, pick the simpler one and note it.
- Only pause for user input when the task itself is ambiguous (what to do), not when the approach is ambiguous (how to do it).
- Keep scope to what was asked. Do not add unrequested improvements.

## Implementation

- Read relevant code before editing.
- Make targeted changes — smallest diff that achieves the deliverable.
- Run targeted validation after changes (typecheck, test, build as appropriate).
- If validation fails, fix it within scope. Do not leave broken state.

</execution_rules>

<workflow>

| Step | Task | Tool |
|------|------|------|
| 1 | Validate input — identify the deliverable | - |
| 2 | Classify difficulty (easy/medium/hard) | - |
| 3 | Think proportionally | sequential-thinking |
| 4 | Explore relevant code | Read/Grep/Glob |
| 5 | Implement | Edit/Write |
| 6 | Validate (typecheck/test/build) | Bash |
| 7 | Report outcome and changed files | - |

Steps 4-6 may repeat as needed. The goal is a working deliverable, not a single pass.

</workflow>

<completion_report>

After execution, report briefly:

```markdown
## Done

**Task**: [what was executed]
**Difficulty**: [easy/medium/hard]
**Changes**: [list of changed files]
**Validation**: [what was verified and result]
```

If anything remains unverified, say what and why.

</completion_report>

<validation>

Execution checklist:

- [ ] ARGUMENT validated — deliverable is clear
- [ ] Difficulty classified
- [ ] sequential-thinking completed (proportional depth)
- [ ] Relevant code read before editing
- [ ] Implementation complete
- [ ] Validation executed (typecheck/test/build)
- [ ] Outcome reported with changed files

Forbidden:

- [ ] Presenting options and waiting for selection (this is execute, not diagnose)
- [ ] Over-thinking easy tasks (1-3 thoughts max for easy)
- [ ] Under-thinking hard tasks (7+ thoughts minimum for hard)
- [ ] Expanding scope beyond what was asked
- [ ] Claiming completion without running validation

</validation>
