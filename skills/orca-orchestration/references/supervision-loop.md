# Supervision Loop Detail

Read this reference while a supervised worker is running. It carries the supervision-contract
reporter, the Run-level waiter, per-Dispatch progress cadences, stall classification, harness
linkage, the recovery ladder, and the supervision record fields.

## Contents

- [Supervision scope](#supervision-scope)
- [Branch A: supervision contract and Run-level waiter](#branch-a-supervision-contract-and-run-level-waiter)
- [Branch B: native supervised workers](#branch-b-native-supervised-workers)
- [Recovery ladder](#recovery-ladder)
- [Question non-response and multi-stall priority](#question-non-response-and-multi-stall-priority)
- [Stall classification](#stall-classification)
- [Harness linkage](#harness-linkage)
- [Supervision record](#supervision-record)
- [Sources](#sources)

## Supervision scope

Supervision starts at `prompt_delivered` and runs until a lifecycle terminal signal:
`worker_done`, `escalation`, `question`, or an explicit failure. Rolling waits are checkpoints,
not recovery. A wait timeout and `{count:0}` are not failures. Normal tasks take 15-60 minutes,
so quietness alone is not a signal.

## Branch A: supervision contract and Run-level waiter

Embed the supervision contract in the Task spec before launch. A native
`worker-start --agent <id>` worker (OMO via `pi`) delivers it as part of the native launch; a
custom-dispatch fallback delivers it inside the exact preamble. If
`dispatch-show --preamble` already returned the full Task, do not append the contract later.

```text
SUPERVISION CONTRACT
1. On accepting the task, send one status message with the current phase.
2. While working, send a heartbeat at least every 5 minutes.
3. When blocked, use the ask/question path instead of going silent.
4. Send worker_done exactly once with outcome succeeded or failed, then idle.
```

Worker-side status and heartbeat mail are produced by the managed OMO extension
[`../assets/extensions/omo-supervision-reporter.ts`](../assets/extensions/omo-supervision-reporter.ts).
Before recording `worker_active`, run `bun assets/extensions/install-extensions.ts --check --json`
from this skill directory; when the check reports a missing or diverged file, run the same command
without `--check` to provision it. The reporter never emits `worker_done`; completion authority
stays with the accepted Task contract.

Use one Run-level waiter:

```text
orca orchestration check --run <run> --wait --types worker_done,escalation,question,status,heartbeat --timeout-ms 900000 --json
```

Process the whole Delivery batch, then ack with `check --ack <delivery_id>`. A bound Run replays
the same Delivery until `--ack`. Progress-only Deliveries (`status` or `heartbeat` only) are
recorded, acked, and waiting continues.

Per-Dispatch progress signals are managed independently: heartbeat <=10 min, status <=15 min,
`terminal read --cursor` delta or terminal list `lastOutputAt` <=10 min, and a Working marker on
`terminal read --screen`. Repaint fragments prove activity, not meaningful progress.

## Branch B: native supervised workers

This is the primary path for a fresh worker: the default for a fresh OMO worker via
`worker-start --agent pi` and for any other registered agent. Use `worker-show` state. `ready`:
keep waiting, or run `worker-read --dispatch <id> --limit 50`. `failed` or `stopped`: recovery
ladder step 3. `outcome_unknown`: user approval required. Never apply this branch to custom
dispatch; `unsupervised`/`context_only` is expected ownership on that path.

## Recovery ladder

Shared across both branches: (1) confirmation via bounded read, unbounded and free; (2) nudge at
most once per Dispatch - native via `orchestration send --to dispatch:<id>` structured mail,
custom only after read-before-send confirms a receive-capable screen state (no draft, no question
pending) via `terminal send` one status query with a 2-minute success window; a nudge is not a
Task/preamble redelivery; (3) native-only automatic replacement only when `worker-show` reports
`failed` or `stopped`: `worker-start --task <task> --retry-of <dispatch_id>` once (does not
inherit placement; repeat `--on`/worktree and `--agent`/terminal choices); (4) user escalation
with an evidence bundle (stall timeline, nudge receipts, last output, classification). Automatic
actions end here.

## Question non-response and multi-stall priority

After receiving a question, if the delay in answering is 5 minutes, classify
`coordinator_blocked` (not a worker stall) and escalate to the user. Multi-stall priority:
question > `terminal_gone` > critical-path idle > other idle > `busy-unverified`.

## Stall classification

Stall classification is a set of parent-observed conditions:

- Diagnostic start: all signals unchanged for 20 minutes, or two consecutive 15-minute
  wait-window timeouts.
- `stalled-idle` declaration requires all of: Task/Dispatch active; no `worker_done`,
  `question`, or `escalation`; cursor/`lastOutputAt` unchanged for 30 minutes; no
  status/heartbeat for 30 minutes; two wait-window timeouts; three screen snapshots 1 minute
  apart identical; each snapshot an idle prompt (no Working marker); runtime healthy and
  terminal present.
- `busy-unverified`: Working marker persists. Diagnose at 30 minutes without meaningful
  progress; escalate at 60 minutes. If the screen proves busy, do not inject text.
- `waiting-for-input`: question mail is authoritative. Without mail, screen fallback needs
  all six conditions: `source=screen`, `tui-idle` succeeded, a prompt is present, no Working
  marker, question text is present, and two snapshots are identical.
- `terminal_gone`: runtime healthy and the exact handle is absent only. Never confuse this
  with a runtime outage.

## Harness linkage

Harness linkage is written in capability terms. Harnesses with persistent sessions and output
watchers wrap the wait in a persistent session and wake the parent only for actionable types
(`worker_done`, `question`, `escalation`, or an unknown type). Plain-shell harnesses supervise
with bounded 30s wait windows and treat lease/harness/session expiry as a parent-process
checkpoint: report a state summary to the user, then re-arm and continue or end supervision
on user instruction. Never classify the worker as failed, release it, or settle it without a
lifecycle terminal signal.

## Supervision record

Record `workerKind` (`custom-dispatch` or `native-supervised`), terminal ownership
(`parent-created`, `reused`, or `user-owned`), Run/Task/Dispatch/handle/worktree, send receipts,
supervision-contract embedded yes/no, state transition timestamps, Delivery ID and ack times,
latest signal times, nudge receipts and response evidence, final Task/Dispatch state, and
settlement choice plus receipt. Evidence root:
`<state-root>/runs/<run-id>/tasks/<task-id>/attempts/<dispatch-id>/`.

## Sources

> No external sources were used. Every condition above restates local Orca/OMO CLI observations
> recorded in [`runtime-cli-evidence.md`](runtime-cli-evidence.md), which was checked 2026-09-21.
