---
name: bug-fix
description: Analyze bugs, present repair options, then implement and verify the user-selected fix path.
compatibility: Use in environments with code exploration (Read/Grep/Glob), editing (Edit), and validation commands (Bash).
---

# Bug Fix Skill

> Diagnose a concrete bug, choose the safest repair path, and fix it only when the request is actually a scoped bug-fix task.

<request_routing>

## Positive triggers

- A specific runtime error with a reproduction path, such as `Cannot read properties of undefined`.
- A specific logic bug such as duplicate rendering, stale state, or wrong calculations in one feature.
- A concrete API bug with a failing request, response mismatch, or one broken integration path.

## Out-of-scope

- Repository-wide build or CI cleanup. Route that to `build-fix`.
- Security audits, exploit review, or trust-boundary analysis. Route that to `security-review`.
- New feature work, refactors, or speculative cleanup that are not tied to a concrete bug.

## Boundary cases

- If the user asks for root-cause analysis only, stay in diagnosis mode and do not edit.
- If the user asks for a direct fix on a single concrete bug, this skill owns it.
- If the request starts as a bug but expands into repo-wide build breakage, hand off to `build-fix`.

</request_routing>

<argument_validation>

If ARGUMENT is missing, ask immediately:

```text
Which bug should be fixed?
- Error message / failing symptom
- Expected vs actual behavior
- Reproduction steps
- Related files or call sites
- Recent change, suspect commit, or environment detail
```

</argument_validation>

<mandatory_reasoning>

## Mandatory Sequential Thinking

- Always run `sequential-thinking` before implementation.
- Simple bug: at least 3 thoughts
- Medium complexity: 5 thoughts
- High complexity: 7+ thoughts

Recommended sequence:

1. Complexity classification
2. Reproduction and symptom framing
3. Root-cause hypotheses
4. Option comparison
5. Final recommendation

Before any edit, collect Root-cause evidence and reduce the problem to a minimal reproduction or the narrowest failing boundary you can actually verify.

</mandatory_reasoning>

<execution_modes>

Use one of these branches explicitly:

- Diagnose-only: reproduce, isolate the failing path, summarize evidence, and stop before code edits.
- Option-first: present 2-3 repair options and wait when the safest fix is not obvious or tradeoffs are material.
- Fix-now: If the user explicitly asks for a direct fix and one path is clearly the safest, say which path you are taking and implement it without a second confirmation round.
- Handoff: route repo-wide build breakage to `build-fix` and security review requests to `security-review`.

</execution_modes>

<workflow>

| Step | Task | Tool |
|------|------|------|
| 1 | Validate input and summarize reproducible signals | - |
| 2 | Build analysis plan with sequential-thinking | sequential-thinking |
| 3 | Explore relevant code and isolate root cause | Read/Grep/Glob |
| 4 | Present 2-3 fix options | - |
| 5 | Wait for user selection | - |
| 6 | Implement selected option | Edit |
| 7 | Run type/test/build verification | Bash |
| 8 | Report outcome and changed files | - |

</workflow>

<option_presentation>

Use this format:

```markdown
## Bug Analysis Result
Root cause: ...
Impact scope: ...

### Option 1: ... (Recommended)
- Pros:
- Cons:
- Risk:
- Files:

### Option 2: ...
- Pros:
- Cons:
- Risk:
- Files:

### Option 3: ... (Temporary)
- Pros:
- Cons:
- Risk:
- Files:

Recommendation: Option N (reason ...)
Which option should I apply? (1/2/3)
```

</option_presentation>

<implementation_rules>

- Do not modify code before user option selection unless the request is in the explicit Fix-now branch.
- Avoid speculative edits; use evidence-based fixes only.
- Keep scope limited to the requested bug and direct impact.
- Always run targeted validation for the changed path, not just a generic command dump.
- Report the commands run, the key result lines, and the touched files in the final report.
- If validation cannot run, say why and what remains unverified.

</implementation_rules>

<validation>

Execution checklist:

- [ ] ARGUMENT validated
- [ ] sequential-thinking completed
- [ ] Root-cause evidence collected
- [ ] 2-3 options presented
- [ ] User choice confirmed
- [ ] typecheck/test/build executed
- [ ] outcome + touched files reported

Forbidden:

- [ ] speculative fix without evidence
- [ ] immediate implementation without options
- [ ] implementation without explicit user choice
- [ ] completion claim without validation

</validation>
