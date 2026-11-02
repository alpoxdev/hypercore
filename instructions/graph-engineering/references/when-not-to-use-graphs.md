# When Not to Use Graphs

The screening questions, the cost model, and the alternative that costs less. Graphs are the right answer for a minority of agent systems, and the sources that promote them say so.

> Korean version: [`when-not-to-use-graphs.ko.md`](when-not-to-use-graphs.ko.md)

## Why this document exists

Every source cited in this area is written by someone who benefits from more graphs being built. LangChain publishes the term and sells LangGraph; PuppyGraph publishes a graph explainer and sells a graph query layer. That does not make their claims false — their limitations are specific and measured — but it does mean the "when not" question has to be answered from their own admissions rather than from their enthusiasm.

Three admissions matter most:

1. LangChain reports moving its own early deep research off predefined graphs onto a more agentic core loop, and that GPT Researcher made the same move.
2. PuppyGraph calls over-engineering "the most common of all" failure modes, describing "a graph built where one loop would have sufficed."
3. Anthropic's standing advice is to find the simplest solution and add complexity only when the simpler one falls short.

## Screening procedure

Ask in this order and stop at the first answer that closes the case. The order matters: each question is cheaper to answer than the next.

| # | Question | If the answer is… | Then |
|---|---|---|---|
| 1 | Can one LLM call with retrieval and a couple of examples do it? | Yes | Do that, then stop |
| 2 | Can you draw the possible workflow before the input arrives? | No | Use an agent harness (see below) |
| 3 | Do all participants need the same context, or do subtasks depend on each other heavily? | Yes | Keep one agent; fan-out loses here |
| 4 | Which specific ceiling does the graph remove? | None of the four | Do not build the graph |
| 5 | Is the coordination cost less than the benefit, measured? | No or unknown | Stay with a loop and instrument first |
| 6 | Is there a minimum viable topology — one added node or one cycle? | Yes | Start there, not with the full design |
| 7 | Can you write the eval for each node boundary? | No | Fix the decomposition before writing runtime code |

Question 2 is Google Cloud's own test, stated for its own product: "can you draw the possible workflow before the input arrives?" Question 4 comes from PuppyGraph's list of ceilings. Question 5 is the token measurement below.

## The four ceilings

A graph is justified when it removes a limit that a single loop provably hits. PuppyGraph names four, and they are the most useful checklist this area has produced.

| Ceiling | How it shows up | The graph answer | Cheaper alternative to try first |
|---|---|---|---|
| Context exhaustion | Quality degrades before the window is full | Separate agents with their own windows | Compaction, retrieval, artifacts to disk |
| Serialized latency | Ten independent items take ten times as long | Parallel branches | Concurrent tool calls inside one loop |
| Missing isolation | One failing retrieval pollutes unrelated reasoning | Separate contexts per branch | Tighter tool scoping |
| Self-grading | The producer's verdict is never wrong | A verifier node | A deterministic check where one exists |

Note that three of the four cheaper alternatives are loop-level or context-level fixes. That is the point: the ceiling should be measured after those fixes, not before.

## The cost model

Anthropic's measured multipliers are the only concrete cost numbers in the cited set, and they are worth carrying into the decision.

| Configuration | Tokens relative to a chat interaction | Source |
|---|---|---|
| Single agent | about 4x | Anthropic, June 2025 |
| Multi-agent system | about 15x | Anthropic, June 2025 |

The same writeup reports the gain that pays for it: a multi-agent research system outperformed a single agent by 90.2% on an internal research eval. Both numbers are needed to make a decision, and the ratio between them is the actual argument — a 15x cost buys a 90.2% improvement only on tasks whose value exceeds the difference.

Three cost properties follow, which a design document should state:

- **Fan-out is multiplicative.** Each worker multiplies spend whether or not it contributes; the ceiling is set per node and per run (GE-F-2).
- **Coordination cost grows with edges, not with nodes.** Every additional permitted transition is a path that must be tested, traced, and reviewed.
- **Recovery cost is per-run, not per-node.** Without checkpoints, a failure at step nine pays for steps one through nine again.

## The agent-harness alternative

LangChain's recommendation for tasks "more agentic by nature" is not a smaller graph but a different object: an agent harness, where planning, delegation, and context management emerge from the model rather than being hardcoded in a graph. Claude Code's dynamic workflows sit on the same axis but move the other way — the plan goes into a script, intermediate results into script variables, and "who decides what runs next" becomes the script rather than the model.

The choice between them is not about capability. It is about where the plan lives:

| Plan lives in | Consequence | Good for |
|---|---|---|
| The model, turn by turn (agent harness) | Adapts to what the run discovers; harder to bound and reproduce | Open-ended research, unfamiliar codebases |
| The graph (execution topology) | Bounded, reviewable, testable; must anticipate the paths | Compliance flows, migrations, anything with a policy |
| A script the runtime executes (dynamic workflow) | Repeatable orchestration, intermediate results out of the model's context | Large fan-outs, audits, repeated cross-checks |

An agent harness is not a lesser option; it is the correct option when question 2 fails. The failure mode in the other direction is a graph that has to grow a new node after every incident, which is a harness being built badly.

## Tasks that should stay a single loop

- A one-file edit with a test to run afterwards.
- A question answered by search plus synthesis.
- A refactor whose scope is discovered while reading the code.
- Any task where every step needs the same context.
- Any task where the subtasks are a chain of dependent judgments.

Anthropic's guidance for effort scaling applies even here: simple fact-finding needs one agent and a few tool calls; comparisons need a handful of subagents; only complex research justifies more than ten.

## Migration path

Move from a loop to a graph one decision at a time, and keep each step reversible.

1. **Instrument the loop.** Record token spend, wall time, and where quality degrades. Without these numbers, question 4 and question 5 cannot be answered.
2. **Add a node, not a topology.** Extract the step that needs a different context or a different model into its own node. Now there are two, and one edge.
3. **Fix the edges that carry policy.** Move any rule currently expressed in a prompt into a function node or a fixed edge.
4. **Add a verifier** as a separate node, with its verdict routed.
5. **Add parallelism** only where a measurement shows serialized latency or context pollution.
6. **Add a cycle** only where a retry or clarification genuinely needs one, with a declared traversal bound.
7. **Add durability** when a run becomes long enough that restarting is expensive.

Each step has its own eval. A step that cannot be evaluated on its own is the signal that the decomposition is wrong (GE-N-2).

## Graph justification record

Before building, write these six lines into the design document. If any line is missing, the graph is not ready.

```text
ceiling:        which of the four, and the measurement that shows it
topology:       node list, edge list, and the authority for each edge
state:          schema, plus the merge rule for every field a branch can write
bounds:         per-node budget, fan-out cap, back-edge traversal cap
approval:       which side effects block on a person, and at which node
rollback:       the single-loop configuration this replaces, and how to return to it
```

The rollback line is not ceremony. LangChain's and GPT Researcher's moves back to an agentic core loop were possible because the graph was a layer over a working system, not the system itself.

## Anti-signals

These statements usually mean a graph is being built for the wrong reason.

- "We want the architecture diagram to look serious."
- "The framework makes it easy to add another agent."
- "We will figure out the eval after it works."
- "The model can decide the routing; it is smart enough."
- "We need parallelism" without a measurement of serialized time.
- "Every step should be an agent" — including the lookups.

## Sources

> Links checked 2026-11-03: all were opened and read in full, and all resolve without a redirect.

| Claim | Source | Published / updated |
|---|---|---|
| Moving deep research off predefined graphs to an agentic core loop; agent harness as the alternative; 65M monthly downloads | <https://www.langchain.com/blog/3-years-of-graph-engineering-with-langgraph> | 2026-07-22 |
| The four ceilings; over-engineering as the most common failure; coordination cost | <https://www.puppygraph.com/learn/graph-engineering> | 2026-08-24 |
| 90.2% gain, ~4x and ~15x token multipliers, fit criteria, effort scaling, 50 subagents | <https://www.anthropic.com/research/multi-agent-research-system> | 2025-06-13, updated 2026-10-09 |
| "Find the simplest solution possible", complexity only when it improves outcomes, workflow vs agent | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, updated 2026-10-09 |
| "Can you draw the possible workflow before the input arrives?"; static vs dynamic orchestration | <https://cloud.google.com/blog/topics/developers-practitioners/graph-workflows-in-adk-everything-you-need-to-know> | 2026-09-30 |
| Dynamic workflows put the plan in a script and keep intermediate results out of the model's context | <https://code.claude.com/docs/en/workflows> | no date shown |
