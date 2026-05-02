# Tracked Remediation

**Purpose**: Preserve evidence, ownership, and resume state when pre-deploy blockers are too complex for a direct Fix-now pass.

Use tracked remediation only after:

1. The target root exists and stack detection has run.
2. The initial full `skills/pre-deploy/scripts/deploy-check.sh` has captured the baseline failure, unless no supported stack was detected.
3. The leader has classified the failure shape as complex.

## Flow file

Create or resume `.hypercore/pre-deploy/flow.json` at the repository root. Keep it small, machine-readable, and updated after every phase transition.

Minimum schema:

```json
{
  "version": 1,
  "target_root": ".",
  "current_phase": "detect",
  "stacks": ["node"],
  "phase_history": [
    {
      "phase": "detect",
      "status": "complete",
      "evidence": "stack-detect.sh output",
      "updated_at": "ISO-8601 timestamp"
    }
  ],
  "baseline_command": "skills/pre-deploy/scripts/deploy-check.sh",
  "failure_groups": [
    {
      "id": "node-typecheck",
      "stack": "node",
      "command": "npm run typecheck",
      "priority": 1,
      "owner": "leader",
      "status": "open",
      "evidence": "exact failure excerpt"
    }
  ],
  "fixes": [
    {
      "failure_group": "node-typecheck",
      "files": ["src/example.ts"],
      "summary": "narrow fix tied to reproduced blocker",
      "validation_command": "npm run typecheck",
      "validation_status": "passed"
    }
  ],
  "validation_history": [
    {
      "command": "skills/pre-deploy/scripts/deploy-check.sh",
      "status": "failed",
      "evidence": "summary or path to captured output"
    }
  ],
  "remaining_risks": []
}
```

## Phase transitions

Move phases in order: `detect` -> `baseline` -> `triage` -> `fix` -> `verify` -> `report`.

- `detect`: record target root, detected stacks, and unsupported-stack stop evidence.
- `baseline`: record the full deploy-check command and exact failing output.
- `triage`: group failures by stack, command, priority, likely owner, and independence.
- `fix`: record each narrow edit and targeted validation command.
- `verify`: record the final full deploy-check result from the leader context.
- `report`: summarize blockers, fixes, skipped checks, remaining risks, and readiness status.

## Resume rules

When `.hypercore/pre-deploy/flow.json` already exists:

1. Read `current_phase`, `failure_groups`, `fixes`, and `validation_history` before running new checks.
2. Resume from the earliest incomplete or failed phase instead of restarting from scratch.
3. Append a `phase_history` event whenever the phase changes or a reset is required.
4. Reset to `baseline` only when the target root, detected stack set, package manager, or validation command changes.
5. Never mark `report` complete until the leader has read a fresh final full deploy-check result.

## Validation assertions

- [ ] `target_root`, `current_phase`, `stacks`, `phase_history`, `failure_groups`, and `validation_history` are present.
- [ ] Every failure group includes stack, command, priority, owner, status, and evidence.
- [ ] Every fix maps back to a reproduced failure group.
- [ ] Final readiness is based on a leader-run full deploy check, not only targeted checks.
- [ ] Skipped or unavailable checks are listed separately from passed checks.
