# Runtime Primitives

> Korean version: [`runtime-primitives.ko.md`](runtime-primitives.ko.md)

Which capability each runtime actually ships, under what status label, and with which documented limit. Read this before writing invocation syntax into a loop; read it again before assuming another runtime behaves the same way.

Status and limits below were read on 2026-11-03. Vendor features move faster than this table; the source column exists so a stale row is checkable rather than arguable.

## Capability matrix

| Capability | Claude Code | Codex | LangChain |
|---|---|---|---|
| Repeat until a condition holds | `/goal`, session-scoped, model-evaluated | `/goal`, a persisted objective | `create_agent` plus middleware |
| Repeat on an interval | `/loop` (local), cloud scheduled tasks | Automations with a time schedule | Deployment cron |
| Start on an external event | Scheduled tasks: API and GitHub triggers | Automations: Gmail, Slack, GitHub events | Deployment webhooks, channels |
| Independent check | Stop hook with a prompt type; `/goal` evaluator | Not a documented evaluator feature | `RubricMiddleware`, `after_agent` hook, or a deterministic grader |
| Parallel isolation | Git worktrees, subagents, dynamic workflows | Worktree per thread (as described by practitioners) | Process-level; describe it yourself |
| Persistent state | Files in the repository (your design) | `AGENTS.md` plus files (your design) | Files or a store (your design) |
| Hard caps | Turns in the condition, agent counts, task counts | Provider-side usage limits | Your code |
| Observability | `/usage`, `/workflows`, transcript verdicts | Run history and results inbox | Traces in the platform |
| Unattended permission model | Permission modes, sandbox, hooks | Sandbox policy plus approval policy | Your deployment |

Two rows in that matrix are "your design" for every runtime. State and caps are not features you install; they are parts you add, which is why the root contract treats them as required parts rather than as vendor capabilities.

## Claude Code

| Primitive | What it does | Status / limit |
|---|---|---|
| `/goal <condition>` | Ends each turn by sending the condition and the transcript to a small fast model, which returns not-yet-met, met, or impossible with a reason | One goal per session; condition up to 4,000 characters; evaluator has no tools; no-progress stop after several turns without tool use |
| `/loop <interval> <prompt>` | Re-runs a prompt on an interval inside the current session | Bundled skill; minimum interval 1 minute; fires only while the session is open and idle; 50 tasks per session; recurring tasks expire after 7 days; no catch-up |
| Cloud scheduled tasks (`/schedule`, formerly routines) | Saved configuration (prompt, repositories, connectors) run on Anthropic-managed infrastructure | **Research preview** — "Behavior, limits, and the API surface may change"; triggers: schedule, API, GitHub; 100 scheduled runs per hour per account, 30 per hour per task for run-now/API/one-off, 100 API fires per hour per account, no overage |
| Dynamic workflows | A JavaScript script Claude writes that orchestrates subagents and holds the loop and branching itself | No preview label on the page; available on paid plans and through API and cloud providers; 1,000 agents per run, 16 concurrent by default, 4,096 items per parallel or pipeline call; resume replays completed agents from cache |
| Permission modes | Six modes including a classifier-gated `auto` | Auto mode "reduces permission prompts but does not guarantee safety" |
| Stop hook (prompt type) | Model-evaluated check that runs when a turn ends; `/goal` is a session-scoped wrapper around it | Default 30-second timeout; runs on the background model unless overridden |
| Worktrees | Separate working directory and branch per session, sharing repository history | Isolates file edits; does not isolate the `.git` directory or external side effects |

Three implementation notes matter more than the table. First, `/loop` requires an open session: "tasks only fire while Claude Code is running and idle", so it is a workstation primitive, not a production scheduler. Second, the cloud scheduled-task feature is in research preview, so its API surface — including the beta header and the `/fire` endpoint — is not a stable contract. Third, `/goal` is documented as unavailable when hooks are disabled by policy, because the evaluator is part of the hooks system; a loop that depends on the evaluator inherits the hooks permission model.

## Codex

| Primitive | What it does | Documented behavior |
|---|---|---|
| `/goal <objective>` | Attaches a persisted objective to the active chat; `/goal edit`, `/goal pause`, `/goal resume`, `/goal clear` | Objective must be non-empty and at most 4,000 characters; "the goal text becomes both the first prompt and the completion criteria"; does not grant broader access |
| Automations | Scheduled or event-triggered tasks; results land in a Scheduled inbox | Event triggers are available on the web and mobile but "aren't available in the ChatGPT desktop app, Codex CLI, or the IDE extension"; one task can use several event triggers but "can't combine event triggers with a time-based schedule"; custom cadence as an RFC 5545 recurrence rule |
| Sandbox policy | `read-only`, `workspace-write`, `danger-full-access` | Governs filesystem and network access during command execution |
| Approval policy | `on-request`, `never`, or granular | `untrusted` is documented as unsupported and can prevent a client from starting |

The important portability difference: as documented at this revision, Codex's `/goal` is a **persisted objective**, not a keep-going loop with an evaluator model. The docs describe no verdict states, turn counter, or token readout for it, and a full-text search of the documentation for "run until" returns nothing. A loop written against the Claude Code `/goal` semantics has no direct equivalent there; the closest construction is an automation whose prompt states the completion criteria.

## LangChain

| Primitive | Role in a loop | Documented behavior |
|---|---|---|
| `create_agent` | The agent loop | Model calls tools in a loop until the task is complete |
| `RubricMiddleware` or an `after_agent` hook | The verification loop | A grader checks output against a rubric and sends failures back with feedback; graders may be deterministic or agentic |
| Deployment cron, webhooks, channels | The event-driven loop | External events or schedules start runs |
| LangSmith Engine | The hill-climbing loop | An analysis agent reads production traces and rewrites the harness configuration |

The framework's own framing is that the verification layer "increases latency and cost per run", which is the trade to price before enabling it (checked 2026-11-03).

## Documented limits worth designing around

| Limit | Value | Runtime |
|---|---|---|
| Condition or objective length | 4,000 characters | Claude Code `/goal`; Codex `/goal` |
| Minimum interval | 1 minute | Claude Code `/loop` |
| Scheduled-task lifetime | 7 days for recurring tasks | Claude Code `/loop` |
| Tasks per session | 50 | Claude Code `/loop` |
| Cloud scheduled runs | 100 per hour per account; 30 per hour per task | Claude Code scheduled tasks |
| Agents per workflow run | 1,000 | Claude Code workflows |
| Concurrent workflow agents | 16 by default, 1–256 configurable | Claude Code workflows |
| Items per `parallel()` or `pipeline()` call | 4,096 | Claude Code workflows |
| Automatic retries before pausing | 3 | Claude Code `/goal` |
| Check-in interval for background work | 30 minutes, doubling to 1 hour then 2 hours; at most 3 idle check-ins per goal | Claude Code `/goal` |

Read these as design constraints, not trivia. A loop that schedules 200 runs an hour will be silently capped; a `/loop` task that must survive a laptop closing will not; a fan-out of 2,000 items will be rejected, and the correct design is to chunk the work rather than to raise the cap.

## Portability rules

1. **Capability first, syntax second.** Write the loop as trigger → work source → check → caps → escalation, then map each part onto the runtime. A loop that exists only as one vendor's syntax cannot be moved.
2. **Never assume the same name means the same behavior.** Two runtimes both ship `/goal`; one evaluates the condition after every turn, the other persists an objective. The difference decides whether the loop can stop by itself.
3. **Check the status label.** A research-preview feature has no stable API contract, and a loop built on it inherits that instability. Record the label next to the loop definition.
4. **Record the limits you relied on.** If a loop depends on 16 concurrent agents or a 30-minute check-in, note the number and the date in the loop definition, so a vendor change surfaces as a review item instead of as an incident.
5. **Local and cloud are different loops.** A local interval loop stops when the machine sleeps; a cloud scheduled task keeps running and keeps billing. Choose by what the work depends on, and say which one the loop is.
6. **Do not port a permission model.** Modes, sandbox policies, and approval policies do not translate one-to-one. Re-derive the boundary from the sandbox and the allowlist, not from the mode name.

## Related documents

- [`../LOOP_ENGINEERING.md`](../LOOP_ENGINEERING.md) — the contract these primitives implement.
- [`loop-types.md`](loop-types.md) — which type each primitive instantiates.
- [`stop-conditions-and-verification.md`](stop-conditions-and-verification.md) — the check mechanics in detail.
- [`cost-and-safety.md`](cost-and-safety.md) — permissions, budgets, and blast radius.

## Sources

| Claim | Source | Date |
|---|---|---|
| `/goal` mechanics, limits, verdicts, evaluator model, check-ins, unavailable when hooks are disabled | <https://code.claude.com/docs/en/goal> | updated 2026-10-29, checked 2026-11-03 |
| `/loop` behavior, minimum interval, open-session requirement, task cap, expiry | <https://code.claude.com/docs/en/scheduled-tasks> | checked 2026-11-03 |
| Cloud scheduled tasks: research preview, cloud execution, three trigger types, hourly limits, beta API surface | <https://code.claude.com/docs/en/routines> | updated 2026-10-30, checked 2026-11-03 |
| Dynamic workflows: script orchestration, availability wording, agent and item caps | <https://code.claude.com/docs/en/workflows> | updated 2026-10-27, checked 2026-11-03 |
| Permission modes and classifier limits | <https://code.claude.com/docs/en/permission-modes> | checked 2026-11-03 |
| Stop hook prompt type, background model, timeout | <https://code.claude.com/docs/en/hooks> | checked 2026-11-03 |
| Worktree isolation scope | <https://code.claude.com/docs/en/worktrees> | checked 2026-11-03 |
| Usage and cost reporting | <https://code.claude.com/docs/en/costs> | checked 2026-11-03 |
| Codex `/goal` objective, edit/pause/resume/clear, 4,000-character cap, no broader access | <https://learn.chatgpt.com/docs/codex/cli> | checked 2026-11-03 |
| Codex automations: triggers, inbox, client availability, recurrence rules | <https://learn.chatgpt.com/docs/automations> | checked 2026-11-03 |
| Sandbox and approval policies; `untrusted` unsupported | <https://learn.chatgpt.com/docs/agent-approvals-security> | checked 2026-11-03 |
| Credit billing | <https://learn.chatgpt.com/docs/pricing> | checked 2026-11-03 |
| Stacked-loop primitives: `create_agent`, rubric middleware, deployment triggers, hill-climbing engine; verification cost | <https://www.langchain.com/blog/the-art-of-loop-engineering> | 2026-06-16, checked 2026-11-03 |
| Worktree-per-thread and the five primitives across both products (**practitioner account**) | <https://addyosmani.com/blog/loop-engineering/> | 2026-06-07, checked 2026-11-03 |
| Agent loops as tool use with environmental feedback, and iteration caps | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, rev. 2026-10-09, checked 2026-11-03 |
