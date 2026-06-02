# Parallel Remediation

**Purpose**: Use subagents/background agents only when they reduce pre-deploy wall-clock time without hiding integration risk.

## When to use parallel lanes

Use parallel lanes after the initial full `skills/pre-deploy/scripts/deploy-check.sh` captures failures and the leader has grouped them.

Spawn or hand off only when at least one condition is true:

- failures are independent by stack (`node`, `rust`, `python`)
- one lane is read-only diagnosis while the leader continues another non-overlapping fix
- edit ownership can be split by disjoint files or directories
- a long log, dependency chain, or test output can be isolated from the main context

Do not spawn when:

- the next leader step is blocked on that exact result
- two lanes would touch the same file, lockfile, package manifest, build config, or shared CI/deploy config
- the task lacks a concrete success condition
- external, credential-gated, destructive, or production side effects are required
- the failure is simple enough that coordination overhead is larger than the fix

## Leader contract

Before delegation, the leader must define:

1. Objective: one sentence describing the lane result.
2. Scope: stack, command, files, and target root.
3. Ownership: read-only or exact writable file set.
4. Forbidden actions: destructive commands, external side effects, unrelated refactors, and editing outside ownership.
5. Output: files inspected/changed, evidence, command output, validation result, blockers.
6. Stop condition: complete, blocked, no reproducible failure, or ownership conflict.

During delegation:

- Continue non-overlapping work instead of idly waiting when safe.
- Do not let subagents edit overlapping files or shared config concurrently.
- Require escalation for lockfiles, package manifests, build config, CI/deploy config, or scope expansion.

After delegation:

- Compare lane findings for conflicts, duplicate fixes, and missing checks.
- Inspect all changed files before final validation.
- Run final `skills/pre-deploy/scripts/deploy-check.sh` directly in the leader context.
- Report subagent usage and any unverified lane output as caveats.

## Lane templates

### Read-only diagnosis lane

```markdown
Objective: Diagnose the [node|rust|python|tooling] pre-deploy failure from the captured output.
Scope: [target root], [stack], [failing command/output].
Mode: read-only.
Ownership: no file edits.
Forbidden: destructive commands, external side effects, unrelated refactors, editing files.
Output: root-cause hypothesis, evidence files/commands, recommended targeted check, blockers.
Stop condition: root cause identified, no reproducible cause found, or scope conflict.
```

### Disjoint edit lane

```markdown
Objective: Fix the reproduced [stack] blocker without touching other lanes.
Scope: [target root], [stack], [failing command/output].
Mode: edit-own-files.
Ownership: may edit only [file or directory list].
Forbidden: editing shared configs/lockfiles/package manifests unless listed in Ownership; destructive commands; external side effects; unrelated cleanup.
Output: changed files, rationale, targeted validation command and result, remaining blockers.
Stop condition: targeted check passes, blocked, ownership conflict, or broader fix required.
```

## Suggested lane split

| Failure shape | Safe lane split |
|------|------|
| Node + Rust + Python failures | one lane per stack, no shared config edits |
| Node typecheck + Node lint | usually do not split; `lint-check.sh` already runs them concurrently |
| Tooling/script failure + application failure | read-only tooling lane plus one application-fix lane |
| Lockfile/package manager issue | keep in leader or one single owner lane only |
| Shared build config failure | keep in leader unless ownership can be made exclusive |

## Validation assertions

- [ ] Each lane had objective, scope, ownership, output, and stop condition
- [ ] Parallel lanes were independent or explicitly sequenced
- [ ] Writable lanes had non-overlapping ownership
- [ ] The leader integrated findings instead of pasting them through
- [ ] The leader ran or read final verification directly
- [ ] Final readiness was not delegated to a subagent
