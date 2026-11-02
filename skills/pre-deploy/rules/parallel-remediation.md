# Parallel Remediation

**Purpose**: Use delegated lanes only when they shorten pre-deploy wall time without hiding integration risk.

**Read when**: triage marked two or more failures as disjoint by stack or file, and the delegation capability exists. Otherwise run the same work sequentially and skip this file.

## When a lane is justified

Spawn or hand off only when at least one condition holds:

- failures are independent by stack (`node`, `rust`, `python`)
- one lane is read-only diagnosis while the leader continues a non-overlapping fix
- edit ownership splits cleanly by file or directory
- a long log or dependency chain can be isolated from the main context

Do not spawn when:

- the next leader step is blocked on that exact result
- two lanes would touch the same file, lockfile, manifest, build config, or shared CI/deploy config
- the work has no concrete success condition
- the work needs an external, credential-gated, destructive, or production side effect
- coordination costs more than the fix

At most three lanes run at once, and each lane inherits its failure group's `MAX_FIX_ATTEMPTS` bound from `rules/tracked-remediation.md`.

## Leader contract

Before delegation, define:

1. Objective: one sentence naming the lane result.
2. Scope: stack, command, files, and target root.
3. Ownership: read-only, or the exact writable file set.
4. Forbidden actions: destructive commands, external side effects, unrelated refactors, edits outside ownership.
5. Output: files inspected or changed, command output, validation result, blockers.
6. Stop condition: complete, blocked, no reproducible failure, or ownership conflict.

During delegation:

- Continue non-overlapping work instead of waiting idle.
- Keep concurrent writers off the same file.
- Require escalation for a lockfile, manifest, build config, or CI/deploy config.

After delegation:

- Compare lane findings for conflicts, duplicate fixes, and missing checks.
- Inspect every changed file before the proof run.
- Run the final `bash skills/pre-deploy/scripts/deploy-check.sh` in the leader context.
- Report the lanes used and mark any unverified lane output as a caveat.

## Lane templates

### Read-only diagnosis lane

```markdown
Objective: Diagnose the [node|rust|python|tooling] pre-deploy failure from the captured output.
Scope: [target root], [stack], [failing command/output].
Mode: read-only.
Ownership: no file edits.
Forbidden: destructive commands, external side effects, unrelated refactors, editing files.
Output: root-cause hypothesis, evidence files and commands, recommended targeted check, blockers.
Stop condition: root cause identified, no reproducible cause found, or scope conflict.
```

### Disjoint edit lane

```markdown
Objective: Fix the reproduced [stack] blocker without touching other lanes.
Scope: [target root], [stack], [failing command/output].
Mode: edit-own-files.
Ownership: may edit only [file or directory list].
Forbidden: editing shared configs, lockfiles, or manifests unless listed in Ownership; destructive commands; external side effects; unrelated cleanup.
Output: changed files, rationale, targeted validation command and result, remaining blockers.
Stop condition: targeted check passes, blocked, ownership conflict, or a broader fix is required.
```

## Lane split

| Failure shape | Safe split |
|---|---|
| Node, Rust, and Python failures | One lane per stack, with no shared config edits |
| Node typecheck and Node lint | Do not split; `lint-check.sh` already runs both concurrently |
| Tooling failure plus application failure | One read-only tooling lane and one application fix lane |
| Lockfile or package manager issue | Leader only, or one exclusive owner |
| Shared build config failure | Leader only unless ownership can be made exclusive |

## Validation assertions

- [ ] Each lane received an objective, scope, ownership, output, and stop condition.
- [ ] Lanes were independent, or the sequencing was explicit.
- [ ] Writable lanes had non-overlapping ownership.
- [ ] No lane exceeded the attempt bound for its failure group.
- [ ] The leader integrated findings instead of forwarding them unchanged.
- [ ] The leader ran the final proof directly.
- [ ] Readiness was not delegated to a lane.

## Sources

> Checked 2026-11-03. This rule states this package's own workflow; its script paths were re-read on that date.

| Claim | Source |
|---|---|
| Delegation carries objective, scope, ownership, output, and stop condition, with no overlapping writers | `instructions/validation/index.md` |
| The parent integrates the lane results and runs the final verification itself | `instructions/harness-engineering/HARNESS_ENGINEERING.md` |
| Delegation is a capability, and gated side effects still need approval | `instructions/cli/capability-contract.md` |
