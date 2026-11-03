# Loop Engineering

Standards for designing the system that prompts the agent: trigger, work source, isolation, state, maker-checker separation, stop condition, budgets, and escalation.

> Korean version: [`LOOP_ENGINEERING.ko.md`](LOOP_ENGINEERING.ko.md)

## Why

Loop engineering is the level at which agent work gets designed after prompt, context, and harness engineering: instead of prompting an agent turn by turn, you build the system that issues those prompts. Three 2026 sources define it that way from different directions — a practitioner essay, an encyclopedia entry, and a repository-mining study — while a vendor article from the Claude Code team supplies the operational vocabulary the industry now shares (all checked 2026-11-03).

Two findings shape the rest of this document, and neither is optional context.

- **The vocabulary is settled; the value is not.** A literature review plus a mining study of 36,487 repositories concluded: "broad agreement on the building blocks of loop engineering but no systematic evidence for its claimed benefits" (arXiv 2608.21884, checked 2026-11-03). Treat this as a design discipline with a shared vocabulary, not as a proven productivity technique.
- **Adoption is rare and narrow.** The same study confirmed autonomous agent loops in 217 of those repositories (0.59%), most of them pull-request review or scheduled maintenance, and "found no loop state files on the default branches that we scanned" (checked 2026-11-03). A loop is not the default; it is a cost you justify.

A separate caution applies to every claim of the form "the loop made me faster": in the cited randomized trial, experienced developers using an early-2025 AI assistant took **19% longer** while believing they had been sped up by 20% (arXiv 2507.09089, checked 2026-11-03). Measure the loop, do not feel it.

## Definition

A loop is a repeated unit of work with a declared trigger, a declared work source, and a stop condition that is checked by something other than the actor doing the work.

Definitions in circulation, which this contract narrows rather than repeats:

| Source | Definition | What it contributes |
|---|---|---|
| Claude Code team | "loops as agents repeating cycles of work until a stop condition is met" | the stop condition as the defining property |
| Addy Osmani | "replacing yourself as the person who prompts the agent. You design the system that does it instead" | who holds authorship of the next prompt |
| IBM | "designing agentic workflows, or loops, that iteratively guide AI agents toward completing user-defined goals with minimal human intervention" | goal plus minimal intervention |
| arXiv 2608.21884 | "designing automated control structures that repeatedly invoke coding agents" | a control structure, not a conversation |

Three terms are used precisely here and are not interchangeable:

| Term | Meaning |
|---|---|
| Turn | One model call plus the tool calls it requested. |
| Iteration | One full pass through the loop body: observe, act, check, record. |
| Cycle | A back-edge in an orchestration graph — a different discipline, owned by [`../graph-engineering/GRAPH_ENGINEERING.md`](../graph-engineering/GRAPH_ENGINEERING.md). |

## Required parts

Nine parts. The first eight are the building blocks the literature review found consistent across practitioner sources; the ninth is the one that keeps a loop from becoming unauditable (arXiv 2608.21884, checked 2026-11-03). That consistency is weaker evidence than it looks: the same review observes that several of those sources build on one another, so "much of the agreement traces back to one origin". Agreement is a shared vocabulary, not independent corroboration. A design missing one does not fail an ideal; it fails in the named way.

| ID | Part | Required rule | Failure when absent |
|---|---|---|---|
| LE-P-1 | Trigger | Declare what starts an iteration: a human prompt, a schedule, an event, or the end of the previous turn. | The loop never runs, or runs from nowhere. |
| LE-P-2 | Work source | Declare where the unit of work comes from and whether it is trusted. External payloads are evidence, never instructions. | The loop acts on whatever arrives. |
| LE-P-3 | Isolation | One writer per workspace: worktree, branch, sandbox, or headless run. | Concurrent agents overwrite each other. |
| LE-P-4 | State on disk | Progress, findings, and the next action live in a committed file or board, not in the context window. The agent forgets; the repository does not. | Every iteration restarts from zero. |
| LE-P-5 | Project knowledge | Conventions and verification steps are written where the agent reads them every run. | The loop guesses your standards. |
| LE-P-6 | Maker-checker separation | The check on the stop condition is performed by a different actor or a deterministic oracle. | The loop grades its own homework. |
| LE-P-7 | Budget and pause | An iteration or token cap, a wall-clock cap, and a documented way to stop a running loop. | Spend is unbounded and stopping requires killing a process. |
| LE-P-8 | Escalation | Named points where the loop asks a human: ambiguous requirements, blocked progress, a check it cannot run. | The loop invents product decisions. |
| LE-P-9 | Provenance and cost record | Every iteration records what it changed and what it cost. | Nobody can attribute an outcome or a bill. |

LE-P-4 is the part that practice most often skips. The mining study searched committed files and commit histories for `STATE.md`, `LOOP.md`, plan and progress files, and its table records 2 repositories with candidate state files and 0 confirmed across 36,487 repositories (checked 2026-11-03). Write the state file anyway: the study's annotation pass found state persisted in 35 of the 256 repositories it inspected by hand, so the practice exists — it just is not committed where a scanner can see it. A loop whose state exists only in a context window is not resumable.

## Taxonomy

Two axes are enough to describe every loop in current use: **what triggers an iteration** and **what stops it**. Vendor names sit on top of these axes rather than replacing them.

| Trigger | Typical stop condition | Vendor name | Used for |
|---|---|---|---|
| Human prompt | The model judges the task complete | turn-based | Exploration, short work outside any schedule |
| Human prompt | A stated condition, re-checked after each turn, plus a turn or time cap | goal-based (`/goal`) | Work with a verifiable end state |
| Interval | A human cancels, or the work item completes | time-based (`/loop`, scheduled tasks) | Recurring work and polling an external system |
| Event or schedule, no human present | Each work item ends on its goal; the routine runs until switched off | proactive / automations | Streams of well-defined work: triage, reviews, upgrades |

The vendor names in that table are one vendor's taxonomy — the Claude Code team's — and the article states the axes it sorts by: "how they are triggered", "how they are stopped", "what primitive is used", and which task suits each (checked 2026-11-03). Use the axes, not the names: another runtime may ship the same axis crossing under different words, or none of the primitives at all. [`references/loop-types.md`](references/loop-types.md) works through each combination, the stacked-loop patterns, and the failure mode specific to each type.

Two rows carry a caution the names hide. The turn-based row stops on "the model judges the task complete", which is exactly the self-graded stop LE-S-1 forbids, and [`references/loop-types.md`](references/loop-types.md) rates that stop class "Lowest — self-graded" in its Axis 2 table; read the row as a description of what a runtime does by default, not as a pattern to copy. The time-based row also lumps together two primitives with different lifetimes: `/loop` fires only while the local session is open and idle and its recurring tasks expire after 7 days, while cloud `/schedule` is a research preview whose behavior, limits, and API surface may change. [`references/runtime-primitives.md`](references/runtime-primitives.md) gives the details.

## Design procedure

Order matters. Steps 2 and 3 decide whether anything after them can work.

1. **Pick one bottleneck task.** Ask which piece of it you can hand off: "can you write the verification check? Is the goal clear enough? Does the work arrive on a schedule?" — the vendor article's own triage, and a better filter than task size (checked 2026-11-03).
2. **Write the stop condition first**, in a form a machine can check. See LE-S-1 through LE-S-7.
3. **Name the work source and its trust level.** A repository event, an API call, and a user prompt carry different authority. Untrusted content reaching an unattended loop is a security boundary, not a style question.
4. **Choose isolation before concurrency.** Decide one writer per workspace, then decide how many workspaces may exist.
5. **Put state on disk** (LE-P-4) with the fields the next iteration needs: what is done, what is next, what was tried and rejected.
6. **Place the checker.** Deterministic check where possible, independent model where not, human where neither is faithful.
7. **Set the caps.** Iterations, tokens, wall clock, and the pause or kill path, all four declared before the first run.
8. **Pilot on a slice** and read the per-iteration record before scaling. A loop that fans out to hundreds of agents should first run on tens of items.
9. **Fix the loop, not just the output.** When a run fails the standard, encode the missing check or constraint so the next iteration inherits the fix.

## Stop conditions and verification

- LE-S-1: A loop is never its own stop judge. The check runs on a different actor or a deterministic oracle than the one that did the work.
- LE-S-2: The condition names one measurable end state, the check that demonstrates it, the constraints that must not break, and a cap ("or stop after 20 turns"). A condition with no cap is not a condition.
- LE-S-3: The checker may only judge what the maker has surfaced unless it is given tools. Assume no tools and write the condition so the maker's own output proves it.
- LE-S-4: The checker returns a verdict **and a reason**, and the reason is fed to the next iteration. A verdict without a reason teaches the loop nothing.
- LE-S-5: `Impossible` is a verdict, not a failure. When the check cannot be met, the loop stops and escalates instead of thrashing.
- LE-S-6: No progress is a stop. Repeated iterations with no state change or no tool use end the loop and hand control back.
- LE-S-7: Budget exhaustion is a stop with a cause, never a success. Report `exhausted`, not `done`.

The vendor implementation shows the shape: after each turn a separate small model, which "doesn't run commands or read files independently", returns "Not yet met", "Met", or "Impossible" with a short reason, and the loop stops itself after several turns "without making progress (no tool use for several turns in a row)" (Claude Code `/goal` docs, checked 2026-11-03). That design is a constraint worth copying: a checker with no tools cannot be fooled by repository state it never reads, but it can be fooled by a plausible-looking claim, and it cannot verify anything the maker did not print.

The condition-authoring rules, the verdict state machine, the failure taxonomy (retry, pause, clear), and the failure modes of weak verifiers are in [`references/stop-conditions-and-verification.md`](references/stop-conditions-and-verification.md).

## Cost

- LE-C-1: Cost is per **successful** iteration, not per run. Report tokens and wall time per accepted outcome, and the rework rate.
- LE-C-2: Cost grows with iteration count, not with task size. Iterations that re-send growing context are the dominant term, so a cap is a cost control as much as a safety control.
- LE-C-3: Fan-out multiplies. One documented runtime caps a single workflow at 1,000 agents per run and 16 concurrent agents by default, and the vendor advises piloting because a fan-out "can spawn hundreds of agents" (checked 2026-11-03).
- LE-C-4: Deterministic steps belong in scripts. Running a script is cheaper than reasoning through the same steps each iteration.
- LE-C-5: Match the interval to how often the watched thing changes. A five-minute poll of a queue that fills hourly is pure waste.
- LE-C-6: Route by judgment, not by habit: cheap models for triage and per-iteration checking, capable models for the decisions that are expensive to get wrong.

Observed spend is the only spend you can budget against. One runtime's usage view now reports "a row for each of the heaviest `/loop` or other session-scoped scheduled tasks that ran recently … its total and per-run tokens, and when it last ran" (Claude Code cost docs, checked 2026-11-03). Where a runtime publishes no per-iteration figure, derive it from the run log (LE-P-9) rather than estimating.

## Safety and permissions

- LE-A-1: An unattended loop needs an approval policy chosen in advance, not inherited by accident. In the vendor docs, turning on a goal "doesn't change your permission mode"; unattended turns require the permissive mode to be selected deliberately (checked 2026-11-03).
- LE-A-2: Autonomy does not widen access. Setting a goal "keeps the same sandbox and approval policy and pauses when it needs a decision" (Codex docs, checked 2026-11-03).
- LE-A-3: A classifier-gated mode reduces prompts; it does not guarantee safety. The vendor says so outright, and a reviewer classifier is a mitigation, not an authority boundary.
- LE-A-4: Data that arrives through a trigger is untrusted. One runtime labels API-triggered payloads as untrusted data on arrival; treat every webhook, issue body, and PR comment the same way.
- LE-A-5: Declare what an unattended loop may change without approval — files, branches, environments, external systems — and enforce it outside the prompt.
- LE-A-6: The human gate is review capacity. Loops that open more pull requests than the team can read convert review into a rubber stamp, which the literature review lists among observed failure modes (checked 2026-11-03).
- LE-A-7: Keep a pause and kill path that works while an iteration is running, and test it before the loop runs unattended.

## Observability

- LE-O-1: Record per iteration: trigger, the condition and the verdict with its reason, turn count, tokens, changed paths, checker identity, and stop cause.
- LE-O-2: Log the verdicts, not just the final state. The transcript of verdicts is what tells you whether the loop is converging or oscillating.
- LE-O-3: Attribute output to the loop. Bot commits, branch prefixes, and trailers are the only provenance most repositories will have.
- LE-O-4: A run that could not be observed is not a pass. Annotate it as unverified rather than inferring success from a green pipeline — the mining study found successful workflow runs whose agent step was skipped or did no work (checked 2026-11-03).

## Anti-patterns

| Pattern | What it looks like | Why it fails | Rule |
|---|---|---|---|
| Self-grading | The agent declares its own work done | The writer is the worst judge of its own output | LE-S-1 |
| Verifier theater | A checker that approves without performing a real check | Produces green pipelines over broken work | LE-S-3 |
| Unbounded loop | "Keep going until it's good" | No convergence signal, no cost ceiling | LE-S-2, LE-C-2 |
| Token burn | Re-running a wide fan-out per event | Spend scales with trigger frequency, not value | LE-C-5, LE-C-3 |
| State in context | Progress tracked only in the conversation | Any restart loses the work; nothing resumes | LE-P-4 |
| Rubber-stamp review | Loops outpace human review capacity | The human gate stops being a gate | LE-A-6 |
| Comprehension debt | Code exists that no human understands | Velocity outruns understanding; defects become unattributable | LE-P-9, LE-O-3 |
| Cognitive surrender | Loops used to avoid thinking about understood work | Decisions get delegated to something that cannot own them | LE-P-8 |
| Loop per microtask | An orchestration layer wrapped around a single edit | Overhead exceeds the work | Design procedure, step 1 |

Comprehension debt and cognitive surrender are named in the practitioner and academic literature as the characteristic human costs of loops, not as tool failures. "Comprehension debt" is defined there as the gap between what exists in a repository and what the developer understands; "cognitive surrender" as using loops "to avoid thinking rather than to move faster on understood work" (arXiv 2608.21884 summarising Osmani and Greyling, checked 2026-11-03). Neither is fixed by a better prompt.

## Where it sits

| Area | Boundary | Rule that crosses it |
|---|---|---|
| [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md) | The harness is the environment for one agent run: model, tools, context, verifier, trace, gate. A loop sits above it and decides when to invoke the harness again. | A loop iteration inherits the harness's trace fields; a loop is not a substitute for evaluating the harness. |
| [`../autoresearch/AUTORESEARCH.md`](../autoresearch/AUTORESEARCH.md) | Autoresearch is one specialized loop: metric-driven, one hypothesis per iteration, guard, log, rollback. | Use its metric, guard, budget, and log vocabulary for any optimization loop instead of inventing a second one. |
| [`../context-engineering/references/parallel-workflows.md`](../context-engineering/references/parallel-workflows.md) | Fan-out inside an iteration is parallel work: ownership, isolation, integration, and the leader's verification contract all apply. | A loop that spawns workers is a leader; its stop condition does not transfer to its children. |
| [`../graph-engineering/GRAPH_ENGINEERING.md`](../graph-engineering/GRAPH_ENGINEERING.md) | A graph decides what runs and in what order; a loop decides when one unit stops iterating. A loop is the body of a cycle. | A back-edge declares its own bound at graph level, in addition to any stop condition inside the node. |
| [`../skill/references/prompt-loop-eval.md`](../skill/references/prompt-loop-eval.md) | The inner loop shapes inside a skill: none, observe-act, draft-critique-revise, branch-score-prune, optimize-compare. | Those are loop bodies; this document governs the outer trigger, caps, and checker placement. |

## Sources

> All links checked 2026-11-03; publication dates are as printed on each page and were read the same day.

| Claim | Source | Published |
|---|---|---|
| Loop definition, four loop types with trigger and stop criteria, evaluator model, token-management guidance | <https://claude.com/resources/articles/getting-started-with-loops> | 2026-06-30 |
| Naming of the practice, five building blocks plus memory, maker-checker split, comprehension debt | <https://addyosmani.com/blog/loop-engineering/> | 2026-06-07 |
| Definition, four loop stages, eight components, human-in-the-loop risks | <https://www.ibm.com/think/topics/loop-engineering> | 2026-07-17 |
| Stacked loops: agent, verification (deterministic or agentic grader), event-driven, hill-climbing | <https://www.langchain.com/blog/the-art-of-loop-engineering> | 2026-06-16 |
| Building-block convergence, mining of 36,487 repositories, 217 confirmed loops (0.59%), no systematic evidence for benefits, state-file absence | <https://arxiv.org/abs/2608.21884> | 2026-08-22, rev. 2026-10-22 |
| Loop taxonomy by role: execution, task, product, system, oversight; "a loop without feedback is just a for statement" | <https://www.oreilly.com/radar/what-the-hell-is-a-loop-anyway/> | 2026-07-29 |
| Stacking loops: agent turn, goal loop, meta loop; when to go down or up a loop | <https://latent.space/p/loopcraft/> | 2026-06-12 |
| The unbounded task loop ("Ralph"): bash loop, one item per iteration, back pressure through tests | <https://ghuntley.com/ralph/> | 2025-07-14 |
| "Everything is a ralph loop": the loop as the unit of software work | <https://ghuntley.com/loop/> | 2026-01-17 |
| Interleaved reasoning and action as the basis of the agent loop | <https://arxiv.org/abs/2210.03629> | 2022-10-06 |
| Workflows vs agents, stopping conditions such as a maximum number of iterations, cost of compounding errors, when not to build an agent | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, rev. 2026-10-09 |
| Experienced developers 19% slower with an early-2025 assistant while believing they were 20% faster | <https://arxiv.org/abs/2507.09089> | 2025-07-12 |
| `/goal` mechanics: three verdicts, no-tool checker, condition length, turn caps, no-progress stop | <https://code.claude.com/docs/en/goal> | updated 2026-10-29 |
| Scheduled tasks (formerly routines): cloud execution, schedule, API and GitHub triggers, hourly limits, research preview | <https://code.claude.com/docs/en/routines> | updated 2026-10-30 |
| `/loop`: bundled skill, interval minimum, session must stay open, task cap and expiry | <https://code.claude.com/docs/en/scheduled-tasks> | checked 2026-11-03 |
| Dynamic workflows: scripted orchestration, 1,000 agents per run, 16 concurrent by default | <https://code.claude.com/docs/en/workflows> | updated 2026-10-27 |
| Permission modes including the classifier-gated mode, and its stated limits | <https://code.claude.com/docs/en/permission-modes> | checked 2026-11-03 |
| Stop hook: fires when the main agent finishes, supports a model-evaluated prompt type | <https://code.claude.com/docs/en/hooks> | checked 2026-11-03 |
| Worktree isolation: what it separates and what it shares | <https://code.claude.com/docs/en/worktrees> | checked 2026-11-03 |
| Usage reporting for scheduled tasks, per-run tokens, documented spend ranges | <https://code.claude.com/docs/en/costs> | checked 2026-11-03 |
| Codex scheduled tasks: event and time triggers, results inbox, unattended defaults | <https://learn.chatgpt.com/docs/automations> | checked 2026-11-03 |
| Codex `/goal`: persisted objective, edit/pause/resume/clear, 4,000-character cap | <https://learn.chatgpt.com/docs/developer-commands> | checked 2026-11-03 |
| Starting a goal keeps the same sandbox and approval policy | <https://learn.chatgpt.com/docs/long-running-work> | checked 2026-11-03 |
| Sandbox and approval modes for unattended runs | <https://learn.chatgpt.com/docs/agent-approvals-security> | checked 2026-11-03 |

Three source-hygiene notes. The vendor article's original `/blog/` URL now answers 308 and the canonical path is the `/resources/articles/` form cited above; the LangChain post's `blog.langchain.com` host answers 301 and is cited at its final host. Codex documentation moved from `developers.openai.com/codex/…` to `learn.chatgpt.com/docs/…`, so the latter is cited throughout.

[`references/loop-types.md`](references/loop-types.md) · [`references/stop-conditions-and-verification.md`](references/stop-conditions-and-verification.md) · [`references/cost-and-safety.md`](references/cost-and-safety.md) · [`references/runtime-primitives.md`](references/runtime-primitives.md)
