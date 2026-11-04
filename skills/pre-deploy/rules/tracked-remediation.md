# Tracked Remediation

**Purpose**: Preserve evidence, ownership, and resume state when pre-deploy blockers are too complex for a direct fix pass.

**Read when**: the baseline deploy check failed, triage classified the shape as Medium, Complex, or Laned, or a `.hyper/pre-deploy/flow.json` already exists. Nothing else needs this file.

Use it only after:

1. The target root exists and `bash skills/pre-deploy/scripts/stack-detect.sh` has run there.
2. A full `bash skills/pre-deploy/scripts/deploy-check.sh` run captured the baseline failure.
3. Triage classified the shape as Medium, Complex, or Laned.

## Flow file

Create or resume `.hyper/pre-deploy/flow.json` at the repository root. Keep it small, machine-readable, and updated at every phase transition.

```json
{
  "version": 1,
  "target_root": ".",
  "current_phase": "detect",
  "stacks": ["node"],
  "max_fix_attempts": 3,
  "phase_history": [
    { "phase": "detect", "status": "complete", "evidence": "stack-detect.sh output", "updated_at": "ISO-8601 timestamp" }
  ],
  "baseline": {
    "command": "bash skills/pre-deploy/scripts/deploy-check.sh",
    "exit_code": 1,
    "summary": "PRE_DEPLOY_SUMMARY executed=2 skipped=1"
  },
  "failure_groups": [
    {
      "id": "node-typecheck",
      "stack": "node",
      "command": "npm run typecheck",
      "priority": 1,
      "owner": "leader",
      "status": "open",
      "attempts": 0,
      "evidence": "exact failure excerpt"
    }
  ],
  "fixes": [
    {
      "failure_group": "node-typecheck",
      "files": ["src/example.ts"],
      "summary": "narrow fix tied to the reproduced blocker",
      "validation_command": "npm run typecheck",
      "validation_status": "passed"
    }
  ],
  "validation_history": [
    { "command": "bash skills/pre-deploy/scripts/deploy-check.sh", "status": "failed", "evidence": "exit code and summary line" }
  ],
  "verdict": null,
  "report_path": ".hyper/pre-deploy/report.md",
  "remaining_risks": []
}
```

## Phase transitions

Move in order: `detect` -> `baseline` -> `triage` -> `fix` -> `verify` -> `report`.

- `detect`: record the target root, detected stacks, or the unsupported-stack stop.
- `baseline`: record the command, its exit code, and its `PRE_DEPLOY_SUMMARY` line.
- `triage`: group failures by stack, command, priority, owner, and independence.
- `fix`: record each narrow edit, its group, the incremented `attempts`, and the targeted rerun.
- `verify`: record a fresh full deploy-check result produced in the leader context.
- `report`: write `.hyper/pre-deploy/report.md`, set `verdict` to `ready`, `unproven`, `exhausted`, or `handoff`, and summarize skips and risks.

## Attempt bound

`max_fix_attempts` carries the bound the skill's loop contract declares. It is not a suggestion and it is not per session.

- Increment `attempts` before running the targeted check, so an interrupted run cannot hide a try.
- Carried attempts survive a resume. Resuming never resets the counter.
- When `attempts` reaches the bound with the same root cause, set the group to `exhausted`, stop working on it, and report it as `exhausted`. Never relabel it `done`.
- A new root cause is a new group with its own counter.
- The targeted command or `bash skills/pre-deploy/scripts/deploy-check.sh` is the checker. The agent's own re-read of its diff is not.

## Resume rules

When the flow file already exists:

1. Read `current_phase`, `failure_groups`, `fixes`, `attempts`, and `validation_history` before running a new check.
2. Resume from the earliest incomplete or failed phase instead of restarting.
3. Append a `phase_history` event whenever the phase changes or a reset happens.
4. Reset to `baseline` only when the target root, the detected stack set, the package manager, or the validation command changes.
5. Run the final full deploy check again after the last edit; never mark `report` complete from an earlier run.

## Validation assertions

- [ ] `target_root`, `current_phase`, `stacks`, `phase_history`, `baseline`, `failure_groups`, and `validation_history` are present.
- [ ] Every failure group carries a stack, command, priority, owner, status, `attempts`, and evidence.
- [ ] Every fix maps back to a reproduced failure group.
- [ ] `attempts` never exceeds `max_fix_attempts` for one root cause.
- [ ] The verdict rests on a leader-run full deploy check, not only targeted checks.
- [ ] Skipped or unavailable checks are listed separately from passed checks.

## Sources

> Checked 2026-11-03. This rule states this package's own workflow; it was re-read with the package scripts on that date.

| Claim | Source |
|---|---|
| A failure group stops at a declared attempt bound and is reported as `exhausted` | `instructions/loop-engineering/LOOP_ENGINEERING.md` |
| The checker is separated from the actor doing the work | `instructions/harness-engineering/HARNESS_ENGINEERING.md` |
| A skipped check is recorded as `SKIP` and never counted as a pass | `instructions/harness-engineering/references/evidence-and-recovery.md` |
| The report carries what was tested, what was observed, why it is enough, and what was omitted | `instructions/harness-engineering/references/evidence-and-recovery.md` |
