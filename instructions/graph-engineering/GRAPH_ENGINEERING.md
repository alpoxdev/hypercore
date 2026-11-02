# Graph Engineering

Designing an agentic system as an explicit graph of nodes, edges, and shared state — and deciding, per step, whether code, a model, or a person chooses what runs next.

> Korean version: [`GRAPH_ENGINEERING.ko.md`](GRAPH_ENGINEERING.ko.md)

## Why

The label is new; the object is not. LangChain's retrospective dates the phrase to a single weekend in July 2026, triggered by one post, and files it beside prompt, context, harness, and loop engineering as the newest name to come out of the same channel ([LangChain, 2026-07-22](https://www.langchain.com/blog/3-years-of-graph-engineering-with-langgraph)). Google Cloud published a second definition ten weeks later ([Google Cloud, 2026-09-30](https://cloud.google.com/blog/topics/developers-practitioners/graph-workflows-in-adk-everything-you-need-to-know)), and a 35-author preprint had already formalized it as a paradigm in August ([arXiv 2608.21156](https://arxiv.org/abs/2608.21156)). Every one of those sources says the practice predates the word: state machines, DAGs, and workflow engines have modeled work this way for decades, and Anthropic named the recurring shapes in December 2024 without naming a discipline ([Anthropic, 2024-12-19](https://www.anthropic.com/research/building-effective-agents)).

The label still earns its place, because it names a decision that used to stay implicit: **which parts of an agent system are allowed to be model-decided, and which must be code.** Once a system grows past one loop, prompt wording and loop tuning become local decisions inside a larger structure that now has to be designed on its own terms ([PuppyGraph, 2026-08-24](https://www.puppygraph.com/learn/graph-engineering)).

## Definition

**GE-1.** Graph engineering is the design work of decomposing an agentic system into nodes, connecting them with edges, and specifying the state that travels those edges, deciding per step whether code, a model, or a person chooses what runs next.

This is the repository's synthesis of three 2026 definitions, not a quotation of any one. Google Cloud defines the discipline as "breaking a task into nodes, connecting them with edges, and deciding where code, models, or people control the next step." PuppyGraph defines it as "designing the graph an agentic system executes in: the nodes that do the work, the edges that route work between them, and the shared state that travels along those edges." The first covers routing authority and omits state; the second covers state and omits routing authority. Both are needed.

**GE-2.** A graph is a contract, not a diagram. The shipping artifact is the node input and output schemas, the permitted edge set, and the state schema with a merge rule per field. The picture is a rendering of that contract; a diagram with no schema is documentation of an intention.

## Three senses of the term

The phrase is used for three different objects. Confusing them produces systems that cannot be reviewed, because the same word means "who runs next" in one document and "what the model has read" in another.

| Sense | Object | Lifetime | Who says it this way | Status here |
|---|---|---|---|---|
| 1. Execution topology | Nodes, edges, and shared state of one run | One run | LangChain, Google Cloud, this document | **Primary contract** |
| 2. Composition of loops | How many loops exist and how they connect; one loop is a node or a cycle | One run | PuppyGraph frames the discipline this way; LangChain: "loops are simple graphs" | Same object as sense 1, seen from the loop side |
| 3. Graph as context | An entity and relationship index over a corpus, retrieved into context | Persists across runs | GraphRAG, repository code graphs | **Excluded from this contract**: see [`references/graph-as-context.md`](references/graph-as-context.md) |

**GE-3.** Senses 1 and 2 are one object with two entry points, and this repository treats them as one: a loop is a cycle in a graph, so loop engineering designs a subgraph. Sense 3 has a different lifetime, a different failure mode, and a different reviewer — an execution graph can be wrong only about ordering, a context graph can be wrong about facts. Never cite one to justify the other.

Note on the label: Microsoft ships graph-based workflows — typed executors connected by edges and conditions — but its documentation says "graph-based workflows" and never uses "graph engineering" ([Microsoft Learn](https://learn.microsoft.com/en-us/agent-framework/concepts/workflows/)). Do not attribute the term to Microsoft.

## Where it sits

| Discipline | Owns | Question it answers |
|---|---|---|
| Prompt engineering | One call's instructions | What does the model read for this step? |
| Context engineering | What enters the window, from where, with what authority | What does the model know at this point? |
| Harness engineering | Tools, evaluators, traces, gates around model work | How do we know the model is behaving? |
| Loop engineering | One repeated unit: trigger, work source, stop condition, budget | When does this unit stop iterating? |
| **Graph engineering** | The topology that contains loops and the state that crosses it | What runs next, and who decides? |

The preprint places Graph Engineering after prompt, context, harness, and loop engineering in its lineage, arguing that a single agent's capacity runs out before a task's need for heterogeneous expertise, interdependent subtasks, parallel execution, independent verification, and persistent state ([arXiv 2608.21156](https://arxiv.org/abs/2608.21156)). LangChain makes the weaker, more useful claim: graph engineering "is the same idea behind loop engineering and harness engineering" — putting model reasoning in the right places with the right context at each step.

**GE-4.** A cycle declares its own bound at the graph level: the maximum number of times the back-edge may be traversed per run. This is separate from any stop condition inside the node. ADK's documentation states that "a graph cycle is not bounded automatically" and defines the loop itself as "a back-edge: a downstream node routes back to an earlier node" — which is why the bound belongs to the edge, not to the node ([ADK, graph routes](https://adk.dev/graphs/routes/)). The companion rule in [`instructions/loop-engineering/LOOP_ENGINEERING.md`](../loop-engineering/LOOP_ENGINEERING.md) is that a node which stops correctly can still be re-entered.

**GE-5.** The check that decides a cycle is finished is evaluated by a different actor or a deterministic oracle than the actor doing the work. At loop level this is the loop-engineering contract; at graph level it means the verifier is a node and its verdict is an edge.

## Graph contract

| Decision | Must be written down | What goes wrong when it is not |
|---|---|---|
| Node boundary | Input schema, output schema, and what the node may write to state | The node is a blob that can only be tested end to end |
| Permitted edges | The complete set of transitions, including error and abort paths | The model invents paths nobody reviewed |
| Routing authority | Per edge: code, model, or person | Policy silently moves into a prompt |
| State | Schema plus a merge rule for every field a branch may write | Concurrent writes drop data without an error |
| Bounds | Per-node budget, fan-out cap, back-edge traversals | A single request spends the month's budget |
| Durability | Checkpoint boundary and what re-runs on resume | A failure at step nine restarts at step one |
| Approval points | Which side effect blocks on a human decision | An unreviewed action reaches production |

## Nodes

A node is the unit of work and the unit of test. LangChain's worked example puts three kinds on one scale: a **fixed step** (code or an API call, no model), a **model step** (one LLM call without tools), and an **agent step** (a full agent with its own internal loop). A node can also be a router, a verifier, or a human approval checkpoint.

- **GE-N-1.** A node uses a model only for work that needs interpretation. The cheapest reliability win in this discipline is converting a model call that was doing bookkeeping into a function.
- **GE-N-2.** A node boundary is a test boundary. If a node's behavior cannot be asserted on its input and output alone, the decomposition is wrong.
- **GE-N-3.** A node that is itself an agent has a declared internal stop condition, and the graph does not rely on it to bound the overall run (see GE-4).
- **GE-N-4.** The smallest node that still has a name worth reviewing wins. Node granularity is a review decision, not a framework default.

## Edges

| Kind | Decided by | Use for | Evidence |
|---|---|---|---|
| Fixed | Code | Order that carries policy, cost, or approval | Google Cloud: "Use an edge list when it makes those connections clear" |
| Conditional | Code reading state | Branching on facts the system already has | LangGraph conditional edges |
| Model-chosen route | A model emitting a route value | Meaning that rules cannot capture | Google Cloud: "The model identifies the intent; the graph defines the available destinations" |
| Dynamic | Code at runtime | Work whose count is unknown until the input arrives | LangGraph `Send`; ADK dynamic nodes; Claude Code workflow scripts |

- **GE-E-1.** An edge that carries policy, cost, or an approval requirement is fixed in the graph, never left to a model to choose. PuppyGraph's framing is the operational form: fix the parts of the topology that carry policy, cost, and approval, and leave runtime flexibility where the work genuinely varies.
- **GE-E-2.** One routing mechanism per node. LangGraph's guidance is explicit that mixing normal edges and dynamic routing from the same node lets both paths execute and makes behavior harder to reason about.
- **GE-E-3.** A dynamic edge records the transition it created. Map-reduce style fan-out with an unrecorded branch count is indistinguishable from a bug when it fails.
- **GE-E-4.** Decide who keeps control when an edge fires. OpenAI's SDK separates *agents as tools* (a manager keeps the conversation and calls a specialist for a bounded subtask) from *handoffs* (the specialist becomes the active agent for the rest of the turn); choosing the wrong one yields either a bottleneck at the manager or a conversation that a specialist never returns ([OpenAI Agents SDK](https://openai.github.io/openai-agents-python/multi_agent/)).

## State

- **GE-S-1.** Every field a parallel branch can write declares how two writes combine. LangGraph's model is a reducer per state key, with override as the default when none is specified ([LangGraph Graph API](https://docs.langchain.com/oss/python/langgraph/graph-api)).
- **GE-S-2.** State is the only channel between nodes. Ambient globals, module-level caches, and files outside the declared state are invisible to replay and to review.
- **GE-S-3.** State carries a schema version, and a resumed run records which version it resumed. A checkpoint written before a schema change is a different program's state.

## Durability

- **GE-D-1.** Checkpoints happen at declared boundaries: at the end of a graph step in LangGraph, at the end of each superstep in Microsoft Agent Framework, where all executors in that superstep have completed.
- **GE-D-2.** Resume semantics are declared as "what re-runs". LangGraph restarts the node from its beginning when it resumes, so code before an `interrupt()` runs again; ADK's dynamic nodes instead replay completed child calls from history. Both are defensible; an undeclared one is not. Side effects belong in a node whose replay is safe.
- **GE-D-3.** Checkpoint storage is a trust boundary. Microsoft's documentation is direct: never load checkpoints from untrusted or potentially tampered sources.

## Human-in-the-loop

- **GE-H-1.** Approval is a node with an incoming edge, not an instruction in a prompt. PuppyGraph states the difference precisely: an approval requirement expressed as an instruction is a suggestion, while the same requirement expressed as a checkpoint node with an incoming edge is a structural constraint the run cannot route around.
- **GE-H-2.** A pending request is part of the checkpoint. In Microsoft Agent Framework, pending requests are saved with the checkpoint and re-emitted as events when the workflow is restored.
- **GE-H-3.** Parallel branches may interrupt at the same time; resume maps each interrupt identifier to its own value instead of relying on position (LangGraph documents both the pattern and the failure).

## Fan-out and fan-in

- **GE-F-1.** The join's output shape is declared. ADK's `JoinNode` returns a dictionary keyed by node name, while `parallel_worker` returns a list in input order; a consumer written against the wrong one fails quietly.
- **GE-F-2.** Fan-out is capped per node and per run. Anthropic reports early versions of its research system spawning fifty subagents for a simple query, and its own scaling guidance is explicit — one agent with a few tool calls for simple fact-finding, a handful of subagents for comparisons, more than ten only for complex research.
- **GE-F-3.** Partial-failure policy is declared, and "missing" is distinguishable from "empty". ADK warns that a predecessor finishing without an output leaves the join with no value for that branch, so the failure surfaces downstream, away from the node that caused it; Claude Code's research workflow marks a claim it could not check as unverified rather than counting it as refuted.
- **GE-F-4.** Sectioning and voting are different shapes with different evals. Sectioning splits a task; voting runs it repeatedly and needs an aggregation rule. Anthropic separates the two for exactly this reason.

## Verification nodes

- **GE-V-1.** The verifier is a different node from the producer. PuppyGraph names self-grading as one of the four ceilings that push a team from one loop to many: a model asked to judge its own output is a weak judge, and a single loop has nowhere else to put a verifier.
- **GE-V-2.** A verifier's verdict is an input to a routing decision. If the verdict changes nothing about what runs next, the node is logging, not verification.
- **GE-V-3.** Use a deterministic oracle where the criterion can be expressed as code and a rubric judge where it cannot. The choice is the same one [`instructions/harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md) makes between deterministic checks and rubric scoring.

## Worked example

A support request that can be answered, escalated, or refunded. The point of the example is not the domain; it is that every edge has a named authority.

| Step | Node kind | Routing authority | Why |
|---|---|---|---|
| Read the order | Fixed step | Code | One lookup, one ID, no judgment |
| Classify intent | Model step, structured output | Model emits a route value | Meaning is hard to capture in rules |
| Apply refund policy | Function node | Code | Same facts must produce the same decision, testable without a model call |
| Approve before paying out | Human node | Person | Side effect is irreversible |
| Write the reply | Model step | Code, after the decision | Wording, not policy |

Google Cloud's refund walkthrough is this shape: a deterministic policy function, an agent router for intent, three lookups fanned out and joined, and a human node for the manual-review branch. Its smallest useful lesson is that the policy step needs zero model calls, while the intent step needs one — the graph is where that distinction becomes inspectable.

## When not to use a graph

- **GE-A-1.** Name the ceiling the graph removes. PuppyGraph lists four: context exhaustion, serialized latency, missing isolation, and self-grading. A graph that removes none of them is decoration.
- **GE-A-2.** If you cannot draw the possible workflow before the input arrives, start with an agent harness instead. Google Cloud's screening question is exactly that; LangChain reports moving early deep research off predefined graphs and onto an agentic core loop, and GPT Researcher made the same move.
- **GE-A-3.** If every participant needs the same context, or the subtasks depend on each other heavily, fan-out loses. Anthropic says most coding tasks fall into this category.
- **GE-A-4.** Count the price before committing. Anthropic measures agents at roughly four times and multi-agent systems at roughly fifteen times the tokens of a chat interaction, and multi-agent research at 90.2% better on its internal eval — a gain that only pays on tasks valuable enough to justify it.
- **GE-A-5.** A graph that reproduces one loop's semantics is the most common failure mode in this discipline, and it carries coordination cost for parallelism the workload never needed.

The decision procedure, with the questions in order, is in [`references/when-not-to-use-graphs.md`](references/when-not-to-use-graphs.md).

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| One-loop graph | Every node is a step of the same agent | Collapse to a loop; see loop engineering |
| Policy in a prompt | The rule lives in an instruction string | Make it a fixed edge or a function node |
| Model-routed destructive action | The model picks whether to delete, pay, or send | Route through an approval node |
| Unbounded fan-out | Token spend grows with input size, not with need | Cap per node and per run (GE-F-2) |
| State without merge rules | Results silently disappear under load | Declare a reducer per shared field (GE-S-1) |
| Producer grades itself | Quality claims never contradict delivery | Separate verifier node (GE-V-1) |
| Checkpoint without a resume test | Recovery is assumed, never exercised | Test resume in the harness |
| DAG assumption | Retries and clarification loops force a rewrite | Design cycles in from the start |
| Unrecorded dynamic path | A failure cannot be reproduced | Record the transition (GE-E-3) |

## Observability

- **GE-O-1.** Trace per node and per edge, and record which rule or model chose each route. A graph's characteristic failure is non-deterministic routing, and a run that fails once may take a different path the next time.
- **GE-O-2.** Attribute cost to nodes. Aggregate spend hides the one worker that consumes most of the budget.
- **GE-O-3.** Evaluate at node boundaries and end to end, and label the two separately — a node with a defined contract can be tested in isolation, and the end-to-end run is what proves the topology.
- **GE-O-4.** Keep the rendered topology and the shipped contract in sync. Microsoft exposes workflow visualization as a capability for this reason; a diagram that has drifted from the edge list is worse than none.

## References

- [`references/graph-patterns.md`](references/graph-patterns.md) — the recurring topologies, their join semantics, and their evals.
- [`references/when-not-to-use-graphs.md`](references/when-not-to-use-graphs.md) — the screening procedure, cost model, and the agent-harness alternative.
- [`references/framework-mapping.md`](references/framework-mapping.md) — how LangGraph, Microsoft Agent Framework, Google ADK, the OpenAI Agents SDK, and Claude Code workflows name the same primitives.
- [`references/graph-as-context.md`](references/graph-as-context.md) — sense 3, kept apart from orchestration.

## Related documents

- [`instructions/loop-engineering/LOOP_ENGINEERING.md`](../loop-engineering/LOOP_ENGINEERING.md) — the cycle body: trigger, work source, stop condition, budget, escalation.
- [`instructions/context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md) — what each node is given to read.
- [`instructions/harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md) — traces, evals, and gates for the nodes and the whole graph.
- [`instructions/validation/index.md`](../validation/index.md) — what counts as proof before a topology change ships.

## Sources

> Links checked 2026-11-03: every one was opened and read in full, and every one resolves without a redirect.

| Claim | Source | Published / updated |
|---|---|---|
| Term origin, "loops are simple graphs", nodes as full agent runs, when not to use graphs, 65M monthly downloads | <https://www.langchain.com/blog/3-years-of-graph-engineering-with-langgraph> | 2026-07-22 |
| Definition (nodes, edges, who decides), deterministic vs agent router, static vs dynamic, fan-out and join, bounded investigation | <https://cloud.google.com/blog/topics/developers-practitioners/graph-workflows-in-adk-everything-you-need-to-know> | 2026-09-30 |
| Definition including shared state, loop-vs-graph table, four ceilings, topologies, execution vs knowledge graph, failure modes, observability | <https://www.puppygraph.com/learn/graph-engineering> | 2026-08-24 |
| Graph Engineering as a paradigm after prompt, context, harness, and loop engineering; System Intelligence | <https://arxiv.org/abs/2608.21156> | v1 2026-08-21, v2 2026-08-26 |
| Executors, edges, graph-based vs functional APIs, superstep checkpoints, requests saved in checkpoints | <https://learn.microsoft.com/en-us/agent-framework/concepts/workflows/> | 2026-10-22, updated 2026-10-28 |
| Checkpoint trust boundary, checkpoint at superstep end, human-in-the-loop request/response | <https://learn.microsoft.com/en-us/agent-framework/workflows/checkpoints> | updated 2026-11-01 |
| Nodes, edges, reducers per state key, `Command(goto)`, `Send` for map-reduce, one routing mechanism per node | <https://docs.langchain.com/oss/python/langgraph/graph-api> | no date shown |
| Dynamic interrupts, resume via `Command(resume=...)`, node restarts from its beginning, parallel interrupts | <https://docs.langchain.com/oss/python/langgraph/interrupts> | no date shown |
| Agents as tools vs handoffs; orchestration via LLM vs via code | <https://openai.github.io/openai-agents-python/multi_agent/> | no date shown |
| Workflows vs agents, five workflow patterns, simplicity principle, sectioning vs voting | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, updated 2026-10-09 |
| 90.2% gain, ~4x and ~15x token multipliers, fifty subagents, fit criteria, effort scaling | <https://www.anthropic.com/research/multi-agent-research-system> | 2025-06-13, updated 2026-10-09 |
| `JoinNode` semantics, cycle not bounded automatically, route values, dynamic workflows | <https://adk.dev/graphs/routes/> | no date shown |
| Node types, edges array, `DEFAULT_ROUTE`, graph vs dynamic taxonomy | <https://adk.dev/graphs/> | no date shown |
| Dynamic workflow as a script holding the plan; verifier treats unchecked claims as unverified | <https://code.claude.com/docs/en/workflows> | no date shown |
