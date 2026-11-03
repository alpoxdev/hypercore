# Harness Anatomy and Staleness

> Korean version: [`harness-anatomy.ko.md`](harness-anatomy.ko.md)

What a harness is, which parts it has, and the lifecycle rule that keeps those parts from
outliving the model they were built for. The **normative** rules live in
[`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under `## What a Harness Is` and
`## Harness Staleness`; this file holds the definition, the parts inventory, and the evidence.

## Working definition

Every first-party source converged on the same shape in 2025–2026: the harness is everything in a
run that is not the model.

| Source | Statement |
|---|---|
| Anthropic docs | "Claude Code is the layer around the model that provides the tools and manages the context the model sees. This surrounding layer is what the term agentic harness refers to." |
| OpenAI | "A capable agent is more than a prompt and a model response. It needs a way to understand a task, maintain context over time, inspect relevant information, call tools, expose progress, handle failures, request human approval when necessary, and return a useful result. That surrounding execution system is the harness." |
| Practitioner definition | "Agent = Model + Harness. If you're not the model, you're the harness." |
| Practitioner definition | "A raw model is not an agent. It becomes one once a harness gives it state, tool execution, feedback loops, and enforceable constraints." |

**HE-A-1.** A harness is the run-time system around a model: the instructions it reads, the tools
it can call, how its context is assembled and compacted, where its code executes, what checks its
output, what records its behavior, and what gate decides the work may ship. If a component changes
the agent's behavior and is not the model weights, it is part of the harness and it is in scope for
this document.

The definition has a sharp consequence, stated by OpenAI: "From the agent's point of view, anything
it can't access in-context while running effectively doesn't exist." An instruction that lives in a
wiki, a convention nobody wrote down, or a reviewer's memory is not a weak harness — it is an
absent one.

## Parts inventory

Each row is a part, the decision it owns, and the failure that appears when it is missing. The last
column names where this repository tests it.

| Part | Decision it owns | Failure when absent | Tested by |
|---|---|---|---|
| Instruction layer | What the model is told about goal, scope, and format | The agent optimizes the wrong objective confidently | Smoke eval, `## Prompt / Role Instruction Smoke Eval` |
| Tool surface | What actions exist, with which schemas and side effects | The agent improvises with the wrong tool or bypasses the gate | Trace assertions, `must_call` / `must_not_call` |
| Context manager | What enters the window, when, and by which route (preload, retrieval, compaction) | Context rot: recall falls as the window fills | Context variables in [`measurement.md`](measurement.md) |
| Execution boundary | Where model-authored code and commands actually run | A bad step reaches production or a credential | Isolation evidence, HE-E-5 |
| Verifier / sensors | What tells the agent it is wrong, in a form it can act on | The agent self-assesses positively and stops early | HE-R-4, red-team cases |
| Trace / monitor | What was attempted, in what order, with which arguments | Failures are invisible; only the final answer is reviewed | `## Trace Fields` |
| Gate | When a change may merge or ship | Regressions merge because the last run looked fine | HE-J-1 to HE-J-7 |
| Budget / bounds | How long, how deep, how many tokens | An open-ended prompt runs for hours | Loop bounds, see [`instructions/loop-engineering/LOOP_ENGINEERING.md`](../../loop-engineering/LOOP_ENGINEERING.md) |

## Guides and sensors

The most useful split for review comes from Birgitta Böckeler: harness controls are either
**feedforward** (they steer the agent before it acts) or **feedback** (they observe after it acts
and help it self-correct).

> "Guides (feedforward controls) - anticipate the agent's behaviour and aim to steer it before it
> acts." … "Sensors (feedback controls) - observe after the agent acts and help it self-correct.
> Particularly powerful when they produce signals that are optimised for LLM consumption, e.g.
> custom linter messages that include instructions for the self-correction - a positive kind of
> prompt injection."

Two practical readings:

- A rule in an instruction file is a guide. It is advisory by construction: the model may not read
  it, may misread it, or may trade it against another instruction.
- A hook, a failing check, or a tool that refuses the call is a sensor with teeth. The distinction
  matters when the consequence is irreversible: prose cannot enforce, and a hook can.

Böckeler also states the boundary condition the rest of this file depends on: "Not every codebase
is equally amenable to harnessing." A harness is not a portable artifact. It is a response to a
specific failure history.

## The staleness rule

Every component encodes a bet about what the model cannot do unaided, and models change under it.

> "every component in a harness encodes an assumption about what the model can't do on its own,
> and those assumptions are worth stress testing, both because they may be incorrect, and because
> they can quickly go stale as models improve."

Anthropic reported the concrete case about two weeks later: a context-reset component that had been
necessary on one model "had become dead weight" on its successor — the behavior it was compensating
for was gone, and the component remained, costing tokens and hiding the improvement.

**HE-A-2.** Every harness component declares three things in its own file: the assumption it
encodes ("the model will otherwise do X"), the trigger that forces a re-test (a model or runtime
change), and the observation that deletes it (the eval outcome is unchanged without it).

The deletion condition is the part that is usually missing, and it is the part that keeps a harness
from becoming folklore. A component with no delete condition accumulates by default, because
removing it requires an argument while keeping it requires none.

**HE-A-3.** A failing behavior is repaired in the harness, not in the run. The repair is a durable
control — an instruction line traceable to that failure, a tool the agent can use to detect it, or
a check that rejects it — and it ships with the eval case that reproduces the original failure.

This is the practice the term was coined for: "anytime you find an agent makes a mistake, you take
the time to engineer a solution such that the agent never makes that mistake again", paired with
"the most sure-fire way to achieve this is to give the agent fast, high quality tools to
automatically tell it when it is wrong." The same rule stated from the other side: "Every line in a
good AGENTS.md should be traceable back to a specific thing that went wrong."

**HE-A-4.** Harness cost is measured, never assumed. A component reports the token, wall-time, and
cost delta it imposes, and the result is reported per model, because the same component can be
decisive on one model and worthless on another.

The measurement that makes the rule necessary, from a paired experiment on an agentic coding task
(10 runs per condition, 178 acceptance checks):

| Model | Without harness | With harness | Overhead |
|---|---|---|---|
| Stronger model | 10/10 | 10/10 | ~10.5× tokens, ~3× time, ~7× cost |
| Weaker model | 3/10 | 10/10 | ~3.9× tokens, ~2.2× time, ~3.2× cost |

> "For GPT-6 Sol, the harness used about 10.5 times as many tokens, took nearly 3 times as long,
> and cost about 7 times more, yet both conditions succeeded in all 10 runs."

The same asymmetry appears in Anthropic's own cost report for a long-running build: a solo harness
finished in about 20 minutes for roughly $9, and the full planner/generator/evaluator harness took
about 6 hours for roughly $200 on the same one-line prompt. Both are legitimate; neither is
correct without naming the model and the task.

A harness also changes the score, which is why "the model got better" and "the harness got better"
must be reported separately: on ARC-AGI-3, retained reasoning and context compaction moved one
model's score from 13.3% to 38.3% while cutting output tokens sixfold.

**HE-A-5.** The space of useful harnesses moves rather than closes. When a model improves, the
components that compensated for its weakness lose value and the combinations that exploit its new
capability gain it, so a harness review is a standing activity, not a one-time migration.

> "From this work, my conviction is that the space of interesting harness combinations doesn't
> shrink as models improve. Instead, it moves, and the interesting work for AI engineers is to keep
> finding the next novel combination."

## Long-horizon shape

Two components recur in every long-running harness and are worth naming, because both are
staleness-prone.

- **Session bootstrap.** An initializer pass that sets up the environment, followed by worker
  passes that make incremental progress and leave artifacts: "an initializer agent that sets up the
  environment on the first run, and a coding agent that is tasked with making incremental progress
  in every session, while leaving clear artifacts for the next session." The durable artifacts are
  the mechanism: descriptive commits and a progress file, which is also what makes recovery
  possible after a compaction (HE-L-1).
- **Reset and handoff.** Clearing the window entirely and starting a fresh agent with a structured
  handoff, rather than compacting in place. This is a different control from summarization and it
  goes stale on a different schedule, as the dead-weight case above shows.

Both depend on the doer and the judge being separable: "Separating the agent doing the work from
the agent judging it proves to be a strong lever", which is the evidence behind HE-R-4.

## Anti-patterns

| Anti-pattern | Why it fails | Correction |
|---|---|---|
| A manual instead of a map | A long instruction file is context the agent pays for on every turn and recalls unreliably | "give Codex a map, not a 1,000-page instruction manual": a short index plus retrievable documents |
| Enforcement written as advice | Prose cannot refuse a call | Move irreversible consequences into hooks, checks, and tool-level policy |
| Components with no owner, date, or delete condition | Dead weight accumulates and hides model improvements | HE-A-2 |
| Fixing the run instead of the harness | The same failure returns on the next task | HE-A-3 |
| Reporting a harness win without cost | A 10× token bill for zero measured gain looks like progress | HE-A-4 |
| Verbose success logs | Failure signal drowns | "success is silent, failures are verbose" |

## Sources

> Checked 2026-11-03.

**Grade vocabulary.** One closed set for every source table in this directory; see
[`../HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under `## Sources`.

| Claim | Source | Grade |
|---|---|---|
| "the layer around the model … the term agentic harness refers to" | <https://code.claude.com/docs/en/how-claude-code-works> | VENDOR |
| "That surrounding execution system is the harness", and the ARC-AGI-3 13.3% → 38.3% / sixfold token result | <https://developers.openai.com/blog/codex-as-a-platform> (published 2026-08-19) | VENDOR |
| "Humans steer. Agents execute.", the map-not-a-manual rule, and "anything it can't access in-context while running effectively doesn't exist" | <https://openai.com/index/harness-engineering> (2026-02-11) | VENDOR |
| "Agent = Model + Harness" and the component taxonomy | <https://www.vtrivedy.com/posts/the-anatomy-of-an-agent-harness> (2026-03-10) | PRACTITIONER |
| "A raw model is not an agent…", the ratchet, hooks as enforcement, "success is silent", and doer/judge separation | <https://addyosmani.com/blog/agent-harness-engineering/> (2026-04-19) | PRACTITIONER |
| Guides versus sensors, LLM-consumable sensor output, and "not every codebase is equally amenable" | <https://martinfowler.com/articles/harness-engineering.html> (2026-04-02) | PRACTITIONER |
| Paired harness cost experiment: 10 runs, 178 acceptance checks, 10.5× tokens / ~3× time / ~7× cost for the stronger model, and the per-model divergence | <https://martinfowler.com/articles/are-harnesses-worth-the-cost.html> (2026-10-13) | PRACTITIONER |
| "anytime you find an agent makes a mistake…" and fast tools that tell the agent it is wrong | <https://mitchellh.com/writing/my-ai-adoption-journey> (2026-02-05) | PRACTITIONER |
| Initializer agent plus incremental sessions, descriptive commits, and the progress file | <https://www.anthropic.com/research/effective-harnesses-for-long-running-agents> (2025-11-26) | VENDOR |
| "every component in a harness encodes an assumption…", reset plus structured handoff, doer/judge separation, and the 20-minute/$9 versus 6-hour/$200 comparison | <https://www.anthropic.com/research/harness-design-long-running-apps> (2026-03-24) | VENDOR |
| Context resets becoming dead weight after a model upgrade, and harness assumptions needing frequent questioning | <https://www.anthropic.com/research/managed-agents> (2026-04-08) | VENDOR |
| Feedback sensors as a Radar technique, and the harness-evaluation practices around it | <https://www.thoughtworks.com/radar/techniques/feedback-sensors-for-coding-agents> | PRACTITIONER |

Dates in the vendor rows are the publication dates shown on the pages. The Claude Code docs page
carries no visible publication or update date, so none is asserted for it.
