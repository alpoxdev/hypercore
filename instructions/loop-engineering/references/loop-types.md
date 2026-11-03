# Loop Types

> Korean version: [`loop-types.ko.md`](loop-types.ko.md)

Every loop is a choice on two axes: what starts an iteration, and what ends the loop. Vendor taxonomies name points on those axes; they do not replace them. Use this file to pick a type deliberately, not to shop for a product feature.

Source basis: the four-type taxonomy and its stated sorting criteria are the Claude Code team's (checked 2026-11-03); the role-based taxonomy (execution, task, product, system, oversight) is Laurie Voss's (checked 2026-11-03); the stacked-loop framing is swyx's, restated with primitives by LangChain (both checked 2026-11-03). Where a claim belongs to a practitioner's opinion rather than to documented behavior, it is marked **opinion**.

## Axis 1 — trigger

| Trigger class | Fires when | Latency to first action | What breaks |
|---|---|---|---|
| Human turn | A person sends a prompt | Seconds | Adherence depends on the person, not the design |
| Condition, human-started | A person states the condition once; each turn re-checks it | Seconds to minutes | The condition is vague, so the checker cannot fail it |
| Interval | A timer elapses | Up to the interval | The interval is shorter than the rate of change |
| Event | A repository event, webhook, or queue item arrives | Seconds | The event source is untrusted, or storms arrive at once |
| Chained | The previous turn ends without human input | Immediate | It becomes a spin without a progress signal |

## Axis 2 — stop

| Stop class | Checked by | Trust level | Cost behavior |
|---|---|---|---|
| Model judgement | The working agent | Lowest — self-graded | Unpredictable; ends early or late |
| Condition + independent checker | A separate model that sees only the transcript | Medium | Per-turn evaluator cost, usually small beside main turns |
| Condition + tool-using checker | A verifier that runs commands or reads files | Higher, and higher cost | Verifier work per iteration |
| Deterministic oracle | Tests, exit codes, schema validation, counts | Highest | Cheapest per iteration |
| Work queue empty | The queue | High, if the queue is authoritative | Bounded by input size |
| Budget exhausted | The counter | Certain | A stop, not a success |
| Human cancel | The operator | Certain | Depends on the pause path working |

Ordering the `Trust level` column by trust is the point: an independent model is better than self-judgement, and a deterministic oracle is better than both. The Claude Code team states the same preference from the other direction, calling deterministic criteria "so effective" for goal-based loops because the agent no longer decides what "good enough" means (checked 2026-11-03).

## The four named types

| Type | Trigger | Stop criteria as the vendor states them | Best used for | Usage control the vendor recommends |
|---|---|---|---|---|
| Turn-based | A user prompt | "Claude judges it has completed the task or needs additional context" | Shorter tasks outside a regular process or schedule | Specific prompts and verification encoded as skills, to reduce the number of turns |
| Goal-based (`/goal`) | A manual prompt | "Goal achieved OR maximum number of turns reached" | Tasks with verifiable exit criteria | A specific completion criterion and an explicit turn cap |
| Time-based (`/loop`, `/schedule`) | A specified time interval | "You cancel it, or the work completes (the PR merges, the queue is empty)" | Recurring work, or interfacing with an external system | Longer intervals, or react to events instead of time |
| Proactive | An event or schedule, no human in real time | Each task exits when its goal is met; "the routine itself runs until you turn it off" | Recurring streams of well-defined work | Route routines to smaller models; reserve capable models for judgement |

Two properties are easy to miss. The time-based type has **no completion semantics of its own** — the work completing and the loop stopping are separate events, which is why an interval loop that polls a finished queue keeps polling until someone cancels it. The proactive type has the opposite shape: each item stops on its own goal, and the routine has no terminal state at all. Copy the wrong one and you get either a stalled loop or an endless one.

## The types the four-name taxonomy leaves out

| Type | Shape | Origin | When it is the right choice |
|---|---|---|---|
| Task loop ("Ralph") | An outer shell re-runs the agent against the same specification, one work item per iteration, until the backlog is empty | Geoffrey Huntley, 2025-07-14 (checked 2026-11-03) | Greenfield or well-specified work where each unit is independent and the specification is the contract |
| Verification loop | An inner loop whose grader rejects and returns feedback | LangChain's level 2 (checked 2026-11-03) | Whenever output correctness matters more than latency |
| Event-driven loop | External event starts the agent run | LangChain's level 3 | Work that arrives from outside the project |
| Hill-climbing loop | An analysis pass rewrites the harness (prompt, tools, grader) from production traces | LangChain's level 4 | After enough runs exist to learn from |
| Optimization loop | One falsifiable hypothesis per iteration, metric, guard, log, rollback | [`../../autoresearch/AUTORESEARCH.md`](../../autoresearch/AUTORESEARCH.md) | Measurable improvement with a faithful metric |
| Oversight loop | Sets goals, allocates budget, culls work; human-owned | Voss (checked 2026-11-03) | Whenever more than one loop runs, because something must decide which loops survive |

The task loop deserves a warning attached to its origin. Its author describes it as "deterministically bad in an undeterministic world", requires one work item per iteration, and notes that the technique needs a tool that "does not cap tool calls and usage" (checked 2026-11-03). That is a deliberate bet on eventual consistency with no per-iteration cost ceiling: acceptable when the backlog is the bound and the spend is metered outside the loop, unacceptable as a default for maintenance work on a live repository.

## Stacking loops

Loops nest, and the outer loop dominates cost and latency.

| Layer | Cadence | What it iterates over | Failure signature |
|---|---|---|---|
| Turn | Seconds | Tool calls inside one response | The agent stops early and reports success |
| Goal loop | Minutes to hours | Turns, until a condition holds | Condition never met, or met by a weakened check |
| Event loop | Minutes to days | Work items arriving from outside | Storms and duplicate work |
| Meta loop | Days | The loop's own configuration | Improvement claims with no measurement |

The stacked view is the reason "add a loop" is never a local change: a defect at the turn layer is amplified by every layer above it. swyx's formulation is that the game is "to be able to stack loops as effectively as possible", going *down* a loop for reliability when something breaks and *up* a loop for leverage as models improve (checked 2026-11-03, **opinion**). LangChain's version adds the practical test: verification "increases latency and cost per run", so it belongs where a wrong result is expensive (checked 2026-11-03).

## Choosing a type

| Work shape | Start with | Escalate to |
|---|---|---|
| One-off change, unclear scope | Turn-based | Nothing — do not build a loop |
| Repeatable task with a check you can write | Goal-based with a turn cap | Scheduled, once the trigger is reliable |
| Recurring work whose inputs change, not its rules | Time-based | Event-driven, if the source can notify you |
| Stream of well-defined items (triage, reviews, upgrades) | Proactive with per-item goals | Stacked, with an oversight loop over it |
| Metric you can measure cheaply | Optimization loop | Hill-climbing, once traces exist |
| Correctness-critical output | Verification loop inside any type above | A deterministic oracle instead of an agentic grader |

Move up that table one row at a time. Every type above the first adds a failure mode that only appears in production, and the vendor's own advice is to "start with the simplest solution and use these patterns selectively" (checked 2026-11-03).

## Failure modes by type

| Type | Characteristic failure | Fix |
|---|---|---|
| Turn-based | Ends early, reports partial work as done | Encode the check as a skill; require evidence in the output |
| Goal-based | Condition written so loosely the checker always passes | Name an end state, a check, constraints, and a cap |
| Time-based | Keeps firing after the work is done; interval shorter than the change rate | Match interval to change rate; end on queue-empty |
| Proactive | Review backlog grows faster than humans can read it | Cap open items per cycle; route to a human queue with a WIP limit |
| Task loop | Iteration count grows with no quality gain; placeholder implementations | One item per iteration; tests as back pressure; a spend ceiling outside the loop |
| Verification loop | Grader approves without a real check | Give the grader a deterministic oracle or tools |
| Optimization loop | Metric improves, product regresses | Guard metric declared before the first iteration |
| Oversight loop | Nobody actually owns the budget | One named owner per loop inventory |

## Related documents

- [`../LOOP_ENGINEERING.md`](../LOOP_ENGINEERING.md) — the contract these types instantiate.
- [`stop-conditions-and-verification.md`](stop-conditions-and-verification.md) — how to write and place the check.
- [`runtime-primitives.md`](runtime-primitives.md) — which primitive implements which type in a given runtime.
- [`../../graph-engineering/GRAPH_ENGINEERING.md`](../../graph-engineering/GRAPH_ENGINEERING.md) — composing loops into a topology.

## Sources

| Claim | Source | Date |
|---|---|---|
| Four loop types, their triggers, stop criteria, best use, and usage controls; deterministic criteria preferred; "start with the simplest solution" | <https://claude.com/resources/articles/getting-started-with-loops> | 2026-06-30, checked 2026-11-03 |
| Stacked loops and the four levels, verification cost, graders deterministic or agentic | <https://www.langchain.com/blog/the-art-of-loop-engineering> | 2026-06-16, checked 2026-11-03 |
| "Loopcraft": stacking loops, going down for reliability and up for leverage (**opinion**) | <https://latent.space/p/loopcraft/> | 2026-06-12, checked 2026-11-03 |
| Task loop ("Ralph"): bash loop, one item per iteration, "deterministically bad in an undeterministic world", tools without usage caps | <https://ghuntley.com/ralph/> | 2025-07-14, checked 2026-11-03 |
| Role-based taxonomy including the oversight loop | <https://www.oreilly.com/radar/what-the-hell-is-a-loop-anyway/> | 2026-07-29, checked 2026-11-03 |
| Loop stages (goal, action, observation, adjustment) and the human-in-the-loop risks | <https://www.ibm.com/think/topics/loop-engineering> | 2026-07-17, checked 2026-11-03 |
| Interleaved reasoning and action as the inner loop | <https://arxiv.org/abs/2210.03629> | 2022-10-06, checked 2026-11-03 |
| Stopping conditions such as a maximum number of iterations; compounding-error risk | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, rev. 2026-10-09, checked 2026-11-03 |
