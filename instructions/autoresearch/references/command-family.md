# Autoresearch Command Family

> Korean version: [`command-family.ko.md`](command-family.ko.md)

This document maps command-shaped upstream examples into runtime-neutral archetypes. It does not promise that every runtime exposes the same command name, syntax, hooks, or artifact set.

## Shared contract

Every archetype declares Goal, Scope, Verify/Evidence, Guard, Budget, Stop, and Authorization. A mutating loop follows:

```text
Preflight -> Baseline -> Hypothesis -> Checkpoint -> Verify -> Guard
-> Decide -> Restore if needed -> Record -> Stop/Handoff
```

The bare-command upstream surface routes among forced classic config-driven execution, goal-directed orchestration, and guided setup. Only archetypes with a trustworthy predicate loop automatically; subjective or terminal tasks may be single-pass or human-gated. Every command in the pinned surface also carries a default iteration count, so an unbounded run is an explicit `Iterations: unlimited` opt-in rather than the default.

## Bare command, orchestration, and mode detection

The bare command is a dispatcher, and its routing is printed rather than implied:

| Input | Mode |
|---|---|
| a `Metric:` or `Verify:` declaration | classic loop, unchanged |
| free-form natural-language goal | orchestrator |
| nothing | interactive setup |
| `--classic` | force classic |
| `--auto` | force orchestrator |

Orchestration is a meta-loop over the same subcommands: it classifies the goal into an archetype, derives a success predicate (a concrete command plus expected result), confirms once, dry-runs the predicate to prove it returns a value, prints its cycle budget, then routes between subcommands until the predicate holds, a plateau is reached (five flat cycles), or a ceiling is hit (default 50 cycles). Ship still requires explicit approval, and the orchestrator never edits code itself.

Two design consequences: a derived predicate is a proposed contract until a human confirms it, and the confirmation step is what makes the run auditable later. A predicate that cannot be dry-run into a value is not a predicate.

## Plan

Use for a broad goal that needs decomposition and measurable selection.

- Compare bounded plan candidates against one locked rubric or metric.
- Keep decision rationale and rejected alternatives.
- A plan does not authorize implementation or side effects.

## Debug

Use when the cause is unknown.

- Hypothesis -> minimal probe -> evidence -> keep/discard hypothesis.
- Preserve crash/timeout/parser/infra outcomes separately.
- A code fix is a new iteration after root-cause evidence, not an in-place rewrite of the failed probe.

## Fix

Use when a failure is reproducible.

- Pin the failing behavior first.
- Make one falsifiable change.
- Require the regression proof and mandatory guards to pass before keep.

## Reason

Use when the deliverable is a decision rather than code.

- Generate alternatives, assumptions, counterexamples, and disconfirming evidence.
- Lock decision criteria before ranking.
- Record unresolved uncertainty; do not manufacture a winner.

## Probe

Use for bounded feasibility or data gathering.

- Keep the probe reversible and isolated.
- Separate observed capability from production readiness.
- Promote retained findings into project-owned tests, docs, or a follow-up plan.

## Learn

Use to extract a reusable pattern from repeated evidence.

- Require more than one independent case or label the result provisional.
- Record scope and counterexamples.
- Do not turn one repository-specific incident into a universal rule.

## Predict

Use when a forecast can be scored later.

- Predeclare horizon, outcome schema, scoring rule, and resolution source.
- Timestamp predictions before outcomes are known.
- Never edit a forecast after resolution evidence appears.

## Improve

Use for an existing artifact with a faithful evaluator.

- Preserve baseline behavior and target one measured weakness.
- Treat style/quality scores as profile-specific evidence, not inherently objective numbers.
- Use an untouched confirmation set when repeated adaptation can overfit the evaluator.

## Scenario

Use when a seed feature, flow, or failure domain needs systematic edge-case coverage.

```text
seed -> coverage dimensions -> generate -> classify new/extension/duplicate
-> log -> saturation check -> repeat
```

- Bound dimensions and iterations.
- Stop at declared saturation or budget.
- Scenario discovery is not proof that implementation handles the scenario. Convert retained scenarios into project-owned tests or acceptance checks.

## Iteration analytics

Use to analyze `results.tsv` or equivalent recorded evidence.

- Detect trend, plateau, crash clusters, invalid runs, and promising hypotheses; the documented analyzer entry point takes a results file, for example `/autoresearch:evals --file *-results.tsv`.
- Do not relabel previously finalized outcomes.
- Distinguish this local/upstream TSV analyzer from behavioral evals and from the legacy OpenAI Evals platform.

## Behavioral evals

Use when artifacts or agent traces need outcome, process, style, and efficiency evaluation.

- Lock cases, checks/rubrics, judge identities, and aggregation before candidates.
- Preserve trace/tool-call/handoff evidence when process is part of the claim.
- Apply the metric/judge reliability contract in [`config-and-metrics.md`](config-and-metrics.md).

## Regression

Use to test whether a changed state turns a green baseline red.

- Evaluate base and candidate in isolated owned state.
- Malformed, truncated, missing, or invalid evidence fails closed.
- List unavailable dimensions explicitly.
- Never report `STABLE` when no dimension produced an evaluable baseline.

## Security

Default to read-only review and proof. A finding is not authorization to fix, disclose, exploit, transmit, or access production.

- Pin trust boundaries and threat model.
- Separate verification from remediation.
- Route credentials, sensitive data, disclosure, and external actions through controlling authorization rules.

## Ship

Treat Ship as readiness verification followed by a separate finalization gate.

1. Run project-defined checks and inspect artifacts.
2. Report blockers and residual risk.
3. Stop before deploy, publish, push, release, destructive rollback, credential use, or production mutation unless the exact action is explicitly authorized.
4. Verify target identity and outcome after an authorized finalization action.

Repository override: an upstream `--auto` flag is not user approval.

## Runtime hook coverage

Hook guardrails are the least portable part of the surface, and the per-runtime statement is the one to read:

- Claude Code ships native hooks; pi ports the same guardrails onto extension events (`tool_call`, `before_agent_start`, `input`, `session_start`, `session_shutdown`).
- OpenCode, Codex, and Muse ship the skill, runtime, and install surface without hook parity.
- The documented hook programs are Node scripts that intercept tool calls and session events: scout-block, privacy-block, dangerous-cmd-block, iteration-context, subagent-context, dev-rules-reminder, simplify-gate, session-init, and stop-notify.
- Hooks are described as defense in depth and explicitly not a security sandbox or a substitute for host permissions. They also fail open: a crashing hook exits 0 and emits a diagnostic rather than blocking the run.

The portability rule follows. Never treat a hook, extension event, or gate that only exists in one runtime as an authorization control; it can reduce accidents but it cannot hold the authority boundary described in [`safety-and-observability.md`](safety-and-observability.md).

## Handoff and chaining

Do not assume every command writes a handoff. In the pinned upstream v2.3.0 surface, chain commands write `handoff.json` and downstream commands consume it. Local runtimes may use different artifacts.

A handoff is automatically resumable only when it satisfies [`core-loop.md`](core-loop.md) and [`safety-and-observability.md`](safety-and-observability.md). A summary filename without immutable frontier, explicit candidate, evidence, ownership, cleanup, redaction, and revalidation state is not a resume contract.

## Sources

> Sources checked 2026-11-03. Upstream behavior is described at release v2.3.0, commit `7bddd056dfd0b0ded8360588d8101b1ecb5c0baa`; the per-runtime hook statement is taken from the repository README at that commit, because `guide/hooks.md` still says guardrails are Claude Code-only.

- [v2.3.0 release](https://github.com/uditgoenka/autoresearch/releases/tag/v2.3.0)
- [Pinned README: runtimes, hook coverage, bounded-by-default iterations](https://github.com/uditgoenka/autoresearch/blob/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa/README.md)
- [Pinned root skill and router](https://github.com/uditgoenka/autoresearch/blob/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa/.agents/skills/autoresearch/SKILL.md)
- [Pinned scenario archetype](https://github.com/uditgoenka/autoresearch/blob/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa/.agents/skills/autoresearch/scenario.md)
- [Pinned regression archetype](https://github.com/uditgoenka/autoresearch/blob/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa/.agents/skills/autoresearch/regression.md)
- [Pinned chains and handoff behavior](https://github.com/uditgoenka/autoresearch/blob/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa/guide/chains-and-combinations.md)
- [Pinned orchestrator mode](https://github.com/uditgoenka/autoresearch/blob/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa/guide/autoresearch-orchestrator.md)
- [Pinned hooks reference: defense in depth, fail-open, hook inventory](https://github.com/uditgoenka/autoresearch/blob/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa/guide/hooks.md)
- [OpenAI skill evaluation guidance](https://developers.openai.com/blog/eval-skills)
