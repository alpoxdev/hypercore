# Graph Patterns

The recurring topologies a graph-engineered system is assembled from, what each one demands of state and edges, and how each is evaluated.

> Korean version: [`graph-patterns.ko.md`](graph-patterns.ko.md)

## Reading this document

The shapes below are not a framework menu. Anthropic named five of them in December 2024 as composable workflow patterns, before any of the 2026 vocabulary existed; LangChain, Google Cloud, PuppyGraph, and Microsoft's orchestrations document overlapping sets under different names. What is portable is the **contract** each shape imposes: what the state must carry, how the join decides, and what fails when it is assembled carelessly.

Two axes organize all of them:

- **Who fixes the path** — code (fixed edges), state (conditional edges), a model (route values), or runtime discovery (dynamic fan-out).
- **Whether work rejoins** — a linear chain never joins; fan-out must declare a join; a cycle rejoins by construction.

## P1 — Sequential pipeline (prompt chaining)

| Aspect | Contract |
|---|---|
| Shape | Node A → B → C, each consuming the previous output |
| Routing authority | Code, every edge fixed |
| State | The handoff artifact per step; no shared mutable field |
| Join | None |
| Failure | A bad intermediate artifact propagates silently unless a gate sits between steps |
| Evaluate | Per-step assertions on the artifact, plus the final output |

Anthropic's condition is that the task "can be easily and cleanly decomposed into fixed subtasks," with programmatic checks on intermediate steps. The pattern trades latency for accuracy by making each call easier. Google Cloud's version of the same advice is an edge list, read left to right.

Use it when the decomposition is known before the input arrives and each step is independently testable. Do not use it when a later step may need to send work back — that is P5.

## P2 — Routing

| Aspect | Contract |
|---|---|
| Shape | Classify → one of N specialized branches |
| Routing authority | Code (deterministic) or model (agent router) |
| State | The classification, plus the payload each branch expects |
| Join | None; branches terminate independently |
| Failure | Two branches drift apart in quality because only one is exercised by tests |
| Evaluate | Classification accuracy separately from branch quality |

Google Cloud's table is the cleanest statement of the choice: a deterministic router takes "rules in code" and needs no model call; an agent router interprets the input and requires one. The combination that works is an agent router inside a static graph — "the model's choice varies, while the possible connections stay the same."

Create a new branch only when it has a distinct prompt, toolset, or eval. A branch that shares everything with its sibling is a conditional, not a route.

## P3 — Parallel fan-out and gather

| Aspect | Contract |
|---|---|
| Shape | Split into independent branches, then join |
| Routing authority | Code for the split; code for the join condition |
| State | One field per branch, or a declared reducer if branches append to one field |
| Join | Declared shape: ADK's `JoinNode` returns a dict keyed by node name; `parallel_worker` returns a list in input order |
| Failure | A branch that finishes without output leaves the join with no value, and the error surfaces downstream |
| Evaluate | Branch-level correctness, join completeness, and end-to-end agreement |

Two variants, which Anthropic separates because they need different evals:

- **Sectioning** — different subtasks in parallel (a correctness pass, a security pass, a docs pass).
- **Voting** — the same task run several times; requires an aggregation rule (majority, threshold, any-hit) declared before the run.

Apply the bound from the root contract: fan-out is capped per node and per run (GE-F-2). Anthropic's early research system spawned fifty subagents for simple queries; its published guidance now scales effort to complexity instead.

## P4 — Orchestrator-worker

| Aspect | Contract |
|---|---|
| Shape | A lead node decomposes at runtime, delegates, then synthesizes |
| Routing authority | Model for the decomposition; code for the delegation envelope |
| State | Per-worker result slots plus the synthesis input; the number of workers is unknown before the run |
| Join | Synthesis node; must tolerate missing or failed workers explicitly |
| Failure | Duplicated work, gaps, and unbounded spend |
| Evaluate | Coverage of the decomposed subtasks, plus cost per run |

The distinction from P3 is that subtasks are not predefined: the orchestrator decides them from the input. Anthropic describes the delegation contract that makes this work — each subagent needs an objective, an output format, guidance on tools and sources, and clear task boundaries — and reports that vague instructions produced duplicated searches.

PuppyGraph's warning applies here most: the decision about which work becomes a separate node carries a price, and systems that grow nodes opportunistically pay it without reliably getting the benefit.

## P5 — Evaluator-optimizer (a cycle)

| Aspect | Contract |
|---|---|
| Shape | Producer → verifier → back-edge to producer while the verdict fails |
| Routing authority | Code, reading the verifier's structured verdict |
| State | The current artifact, the verdict, and the attempt counter |
| Join | The back-edge is the join; it must declare a maximum traversal count (GE-4) |
| Failure | The cycle stops on a threshold nobody declared, or never stops because the verifier is the producer |
| Evaluate | Pass rate per attempt count, plus the marginal gain of each additional iteration |

Two rules from the root contract bind here. The verifier is a different node from the producer (GE-V-1), and the cycle is bounded at the graph level, not only by the node's own condition.

This is the pattern where the loop and graph contracts touch: the loop decides when *this* attempt is finished; the graph decides how many attempts exist. The stop-condition rules themselves belong to [`instructions/loop-engineering/LOOP_ENGINEERING.md`](../../loop-engineering/LOOP_ENGINEERING.md).

## P6 — Supervisor and handoff tree

| Aspect | Contract |
|---|---|
| Shape | A triage node transfers control to a specialist, or calls one and keeps control |
| Routing authority | Model, but the destination set is fixed in the graph |
| State | Conversation or task ownership must be explicit, because it moves |
| Join | None; control does not return implicitly |
| Failure | A specialist that never returns control, or a manager that bottlenecks every subtask |
| Evaluate | Routing accuracy, plus turn ownership after each handoff |

The distinction is the one OpenAI's SDK documents: with agents as tools, the manager keeps the conversation and calls a specialist for a bounded subtask; with a handoff, the specialist becomes the active agent for the rest of the turn. The graph must record which of the two each edge means, because the same drawn arrow covers both.

## P7 — Dynamic map-reduce

| Aspect | Contract |
|---|---|
| Shape | A node decides at runtime how many downstream nodes to create |
| Routing authority | Code, from a model-produced plan or a data-driven count |
| State | Per-branch state must be isolated or merged by a declared reducer; LangGraph's `Send` passes a distinct state to each send |
| Join | Collecting node; the branch count is part of the trace |
| Failure | Branch count unrecorded, so a failure cannot be reproduced (GE-E-3) |
| Evaluate | Per-item correctness, plus the collection's ordering and dedup rules |

LangGraph documents this as map-reduce: the exact edges are not known ahead of time, and a node routes work to one or more downstream nodes dynamically. Google Cloud's `parallel_worker` is the same shape for a list input, with results collected in input order.

## P8 — Nested graph (workflow as a node)

| Aspect | Contract |
|---|---|
| Shape | An entire graph becomes one node of a parent graph |
| Routing authority | Inherited; the child exposes only its own entry and exit |
| State | A declared input and output boundary between parent and child, not shared mutable state |
| Join | The child's terminal node |
| Failure | The boundary is not enforced, so the parent reaches into child internals |
| Evaluate | Child contract tests, then parent-level behavior |

Microsoft documents sub-workflows as executors inside larger graphs; ADK states that "a `Workflow` is also a node"; PuppyGraph lists hierarchical or nested graphs as a shape that came from the frameworks rather than from the original pattern set.

Nesting is how large systems stay reviewable, and it is also how a graph becomes untestable: if the child's boundary is not a real contract, the parent's tests reach inside it.

## Choosing a shape

| Question | Answer | Shape |
|---|---|---|
| Is the decomposition known before the input arrives? | Yes, ordered | P1 |
| Is there a small set of distinct input categories? | Yes | P2 |
| Are the subtasks independent and known? | Yes | P3 |
| Are the subtasks dependent on what the run discovers? | Yes | P4 |
| Does quality improve with another attempt? | Yes, and the criterion is expressible | P5 |
| Does a specialist need to own the remainder of the turn? | Yes | P6 |
| Is the branch count data-dependent? | Yes | P7 |
| Is the topology too large to review in one screen? | Yes | P8 |

Most production systems are combinations: a P2 router at the front, P3 inside a branch, P5 guarding the artifact, P8 wrapping each stage. The composition rule is the same as the primitive rule — one routing mechanism per node (GE-E-2) — applied at every level.

## Sources

> Links checked 2026-11-03: all were opened and read in full, and all resolve without a redirect.

| Claim | Source | Published / updated |
|---|---|---|
| Five workflow patterns, sectioning vs voting, "decomposed into fixed subtasks" | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, updated 2026-10-09 |
| Orchestrator-worker at scale, delegation contract, fifty subagents, effort scaling | <https://www.anthropic.com/research/multi-agent-research-system> | 2025-06-13, updated 2026-10-09 |
| `JoinNode` and `parallel_worker` output shapes, join failure surfacing downstream | <https://adk.dev/graphs/routes/> | no date shown |
| Deterministic vs agent router, edge lists, dynamic nodes, workflow as a node | <https://cloud.google.com/blog/topics/developers-practitioners/graph-workflows-in-adk-everything-you-need-to-know> | 2026-09-30 |
| `Send` for map-reduce, reducers, one routing mechanism per node | <https://docs.langchain.com/oss/python/langgraph/graph-api> | no date shown |
| Agents as tools vs handoffs | <https://openai.github.io/openai-agents-python/multi_agent/> | no date shown |
| Sub-workflows as executors; superstep execution model | <https://learn.microsoft.com/en-us/agent-framework/concepts/workflows/> | 2026-10-22, updated 2026-10-28 |
| Topology catalogue, over-engineering as the most common failure, cost of adding nodes | <https://www.puppygraph.com/learn/graph-engineering> | 2026-08-24 |
| Dynamic workflows holding the plan in a script, parallel agents per item | <https://code.claude.com/docs/en/workflows> | no date shown |
