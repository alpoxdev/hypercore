---
name: bug-fix
description: Analyze bugs, present repair options, then implement and verify the user-selected fix path. Routes simple bugs directly; tracks complex multi-phase investigations via .hypercore/bug-fix/ JSON flow.
compatibility: Use in environments with code exploration (Read/Grep/Glob), editing (Edit), and validation commands (Bash).
---

# Bug Fix Skill

> Diagnose a concrete bug, choose the safest repair path, and fix it — classify complexity first, then either fix directly or track progress through structured phases.

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

Always run `sequential-thinking` before implementation. Depth scales with complexity:

- **Simple (3 thoughts)**: Identify cause → determine fix → verify approach
- **Medium (5 thoughts)**: Classify → reproduce → hypothesize → compare options → recommend
- **Complex (7+ thoughts)**: Classify → reproduce → hypothesize multiple causes → explore dependencies → compare options → assess cross-cutting impact → recommend

Recommended sequence:

1. Complexity classification
2. Reproduction and symptom framing
3. Root-cause hypotheses
4. Option comparison
5. Final recommendation

Before any edit, collect root-cause evidence and reduce the problem to a minimal reproduction or the narrowest failing boundary you can actually verify.

</mandatory_reasoning>

<complexity_classification>

## Complexity Classification

Classify immediately after sequential-thinking:

| Complexity | Signals | Path |
|------------|---------|------|
| **Simple** | Single file, clear error message, obvious root cause, one fix path, low risk | **Fix-now** — proceed directly without flow tracking |
| **Complex** | Cross-cutting bug, multiple potential root causes, requires investigation across systems, fix has side effects, multiple valid fix strategies | **Tracked** — create `.hypercore/bug-fix/flow.json` |

Announce the classification:

```
Complexity: [simple/complex] — [one-line reason]
```

When uncertain, classify as complex. It is cheaper to track than to lose investigation progress.

</complexity_classification>

<flow_tracking>

## Flow Tracking (Complex Path Only)

When classified as complex, initialize the flow:

```bash
mkdir -p .hypercore/bug-fix
```

Write `.hypercore/bug-fix/flow.json` and update it as each phase progresses. See `references/flow-schema.md` for the full schema.

### Phase progression

| Phase | Description | Next |
|-------|-------------|------|
| `diagnose` | Reproduce, isolate root cause, collect evidence | `options` |
| `options` | Present 2-3 fix options with tradeoffs | `confirm` |
| `confirm` | Wait for and record user selection | `fix` |
| `fix` | Implement selected option | `verify` |
| `verify` | Run validation, report outcome | done |

### Resume support

If `.hypercore/bug-fix/flow.json` already exists, read it first and continue from the last incomplete phase (`in_progress` or `pending`). Do not restart completed phases.

</flow_tracking>

<execution_modes>

Use one of these branches explicitly:

- **Diagnose-only**: reproduce, isolate the failing path, summarize evidence, and stop before code edits.
- **Fix-now** (simple path): If the user explicitly asks for a direct fix and one path is clearly the safest, say which path you are taking and implement without a second confirmation round. No flow tracking.
- **Option-first** (complex path): present 2-3 repair options with flow tracking and wait for user selection.
- **Handoff**: route repo-wide build breakage to `build-fix` and security review requests to `security-review`.

</execution_modes>

<workflow>

## Simple Path (Fix-now)

| Step | Task | Tool |
|------|------|------|
| 1 | Validate input, sequential-thinking (3 thoughts) | sequential-thinking |
| 2 | Classify as simple | - |
| 3 | Explore relevant code, identify root cause | Read/Grep/Glob |
| 4 | Announce fix path and implement | Edit |
| 5 | Run validation (typecheck/test/build) | Bash |
| 6 | Report outcome and changed files | - |

## Complex Path (Option-first)

| Step | Task | Tool |
|------|------|------|
| 1 | Validate input, sequential-thinking (7+ thoughts) | sequential-thinking |
| 2 | Classify as complex, create `.hypercore/bug-fix/flow.json` | Write |
| 3 | Deep investigation → update flow `diagnose: completed` | Read/Grep/Glob + Edit |
| 4 | Present 2-3 fix options → update flow `options: completed` | Edit |
| 5 | Wait for user selection → update flow `confirm: completed` | Edit |
| 6 | Implement selected option → update flow `fix: completed` | Edit/Write |
| 7 | Run validation → update flow `verify: completed` | Bash + Edit |
| 8 | Report outcome, set flow status to `completed` | Edit |

</workflow>

<option_presentation>

Use this format (complex path):

```markdown
## Bug Analysis Result
**Root cause**: ...
**Impact scope**: ...
**Complexity**: complex

### Option 1: ... (Recommended)
- **Pros**:
- **Cons**:
- **Risk**:
- **Files**:

### Option 2: ...
- **Pros**:
- **Cons**:
- **Risk**:
- **Files**:

### Option 3: ... (Temporary)
- **Pros**:
- **Cons**:
- **Risk**:
- **Files**:

Recommendation: Option N (reason ...)
Which option should I apply? (1/2/3)
```

</option_presentation>

<implementation_rules>

- Do not modify code before user option selection unless in the explicit Fix-now branch.
- Avoid speculative edits; use evidence-based fixes only.
- Keep scope limited to the requested bug and direct impact.
- Always run targeted validation for the changed path, not just a generic command dump.
- Report the commands run, the key result lines, and the touched files in the final report.
- If validation cannot run, say why and what remains unverified.

## Reporting

After execution, report:

```markdown
## Done

**Bug**: [original symptom]
**Root cause**: [what was wrong]
**Fix applied**: [which option or approach]
**Changes**: [list of changed files]
**Validation**: [what was verified and result]
```

For complex path: also update `.hypercore/bug-fix/flow.json` status to `completed`.

</implementation_rules>

<validation>

Execution checklist:

- [ ] ARGUMENT validated
- [ ] sequential-thinking completed (depth matches complexity)
- [ ] Complexity classified (simple/complex)
- [ ] Flow JSON created and maintained (complex path only)
- [ ] Root-cause evidence collected
- [ ] 2-3 options presented (complex path) or fix path announced (simple path)
- [ ] User choice confirmed (complex path)
- [ ] typecheck/test/build executed
- [ ] outcome + touched files reported
- [ ] Flow JSON finalized with `completed` status (complex path only)

Forbidden:

- [ ] speculative fix without evidence
- [ ] immediate implementation without options (complex path)
- [ ] implementation without explicit user choice (complex path)
- [ ] completion claim without validation
- [ ] skipping flow JSON updates in complex path

</validation>
