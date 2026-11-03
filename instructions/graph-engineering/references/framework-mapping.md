# Framework Mapping

How five runtimes name the same graph primitives, limited to what their documentation states. This is a translation table, not an equivalence claim.

> Korean version: [`framework-mapping.ko.md`](framework-mapping.ko.md)

## How to use this

Every row records a **documented** primitive. Where a runtime does not document a feature on the pages cited, the cell says so instead of inferring it from a sibling framework's behavior. The vocabularies differ enough that "node" in one document is a function, in another an executor with typed ports, and in a third an entire agent run; treating those as synonyms hides the design decisions this area is about.

Only two of the five use the phrase "graph engineering": LangChain popularized it, and Google Cloud's ADK post defines it. Microsoft documents "graph-based workflows" without the term, and OpenAI's and Anthropic's documentation predates it. Do not read a term's absence as a capability's absence.

## Primitive names

| Concept | LangGraph | Microsoft Agent Framework | Google ADK | OpenAI Agents SDK | Claude Code workflows |
|---|---|---|---|---|---|
| Unit of work | node, a function taking `state`, `config`, `runtime` | executor: receives inputs, performs work, emits outputs | node: an Agent, a tool, a human input task, or a code function | agent (instructions + tools + handoffs) | subagent invoked from the script |
| Fixed transition | `add_edge(a, b)` | edge | edge row starting with `START`, run in order | code: call the next agent | sequential statements |
| Conditional transition | `add_conditional_edges` | edge with condition | node emits `route`; edge row maps route values; `DEFAULT_ROUTE` | code: branch on structured output | `if` in the script |
| Model-chosen transition | conditional edge whose function calls a model | agent executor | agent router emitting a route value | handoff | not a runtime primitive; the script may branch on an agent's result |
| Transfer vs return of control | `Command(goto=...)` vs returning a value | edges route values; sub-workflows as executors | `Event(route=...)` vs passing output forward | handoff vs `Agent.as_tool()` | script function call vs awaited result |
| Shared state | `State` schema with a reducer per key | state management, durable and run-scoped | `ctx.state` plus `Event(output=...)` | conversation state per run | script variables |
| Parallel fan-out | multiple outgoing edges; `Send` for map-reduce | parallel edge groups, fan-out/fan-in | tuple in an edge row; `parallel_worker` | `asyncio.gather` in code | script-level concurrency |
| Join | next node reads merged state | fan-in group | `JoinNode` (dict by node name) or `parallel_worker` (list in input order) | code after `gather` | script collects results |
| Durability | checkpointer plus `thread_id` | checkpoint at superstep end | pause via `RequestInput`; completed calls replay from session history | not documented on the cited page | resumable in the same session |
| Human in the loop | `interrupt()` then `Command(resume=...)` | `RequestInfoExecutor` / `RequestInfo` | `RequestInput` with `rerun_on_resume` / `ctx.resume_inputs` | not documented on the cited page | run-level approval prompt before launch |
| Observability | step snapshots while streaming | spans, metrics, events, delivery status, visualization | per-node event stream | traces via the SDK's tracing | progress view per phase and agent |

## Execution model differences that change design

| Difference | LangGraph | Microsoft Agent Framework | Consequence for a design |
|---|---|---|---|
| Resume semantics | The node restarts from its beginning, so code before `interrupt()` runs again | Checkpoints at superstep end; pending requests are restored and re-emitted | Side effects must be replay-safe or moved into an idempotent child node |
| Scheduling | Node-level, with reducers merging updates | Bulk synchronous parallel: superstep boundaries synchronize all executors | A slow branch delays the whole superstep, not just its own consumer |
| Routing from one node | One mechanism only; mixing normal edges with dynamic routing lets both paths execute | Edges with conditions; fan-out groups | Pick conditional edges *or* `Command`/`Send`, never both from one node |
| Dynamic topology | `Send` returns from a conditional edge with a distinct state per send | Fan-out groups are declared in the builder | A data-dependent branch count must be recorded in the trace either way |

Microsoft's own summary of the trade-off is worth keeping: the functional API suits sequential pipelines and custom loops, while the graph API suits fixed graphs, fan-out and fan-in, and type-validated routing; both "produce the same observable workflow results."

## What is portable

These hold across all five and are safe to put in a runtime-neutral contract:

- A unit of work declares its inputs and outputs, and that declaration is the test boundary.
- A transition is either fixed or decided, and the deciding authority is part of the design.
- Parallel branches require an explicit merge rule.
- Long runs need a checkpoint boundary and a stated resume semantics.
- A human decision is a step with an incoming edge, not an instruction.
- The trace must record which path the run took.

## What is vendor-specific

Do not carry these between runtimes as if they were concepts:

- **The name of everything.** Node, executor, agent, step, stage.
- **The state model.** A reducer map, a run-scoped state object, and script variables solve the same problem with different guarantees about ordering and durability.
- **Resume behavior.** LangGraph's node restarts; ADK's dynamic nodes replay completed child calls. A design that assumes one behaves incorrectly on the other.
- **Whether the graph is the product.** Anthropic publishes patterns without a runtime; Claude Code ships a script runtime; Microsoft ships a workflow runtime with visualization; LangGraph and ADK ship graph builders.
- **Version surfaces.** ADK supports graph-based workflows from 2.0 in Python, TypeScript, and Go ([ADK routes](https://adk.dev/graphs/routes/)). Microsoft's functional workflow API is labeled experimental in Python. Pinning a version is part of citing a behavior.

## Feature claims worth re-checking before a decision

| Claim | Where it matters | What to verify at implementation time |
|---|---|---|
| Checkpointing at superstep boundaries | Recovery granularity | Whether your runtime checkpoints before or after side effects |
| Node restart versus replay on resume | Idempotency requirements | Whether the runtime re-executes the node body |
| Join output shape (dict vs list) | Downstream parsing | The actual return type of your join primitive |
| Parallel interrupt resumption | Multi-approval flows | Whether resume values are keyed by interrupt id |
| Cycle bounds | Termination guarantees | Whether the runtime enforces any traversal cap (ADK states it does not) |

## Sources

> Links checked 2026-11-03: all were opened and read in full, and all resolve without a redirect.

| Claim | Source | Published / updated |
|---|---|---|
| Nodes, edges, reducers, `Command`, `Send`, one routing mechanism per node | <https://docs.langchain.com/oss/python/langgraph/graph-api> | no date shown |
| `interrupt()`, `Command(resume=...)`, node restarts from its beginning, parallel interrupts, checkpointer and `thread_id` as the persistent cursor | <https://docs.langchain.com/oss/python/langgraph/interrupts> | no date shown |
| Executors, edges, events, state, graph vs functional APIs, superstep checkpoints, `RequestInfoExecutor` | <https://learn.microsoft.com/en-us/agent-framework/concepts/workflows/> | 2026-10-22, updated 2026-10-28 |
| Checkpoint contents including pending requests; restore re-emits requests | <https://learn.microsoft.com/en-us/agent-framework/workflows/checkpoints> | updated 2026-11-01 |
| Node kinds, edges array, route values, `DEFAULT_ROUTE`, `JoinNode` | <https://adk.dev/graphs/routes/> | no date shown |
| `RequestInput`, `rerun_on_resume`, `ctx.resume_inputs` | <https://cloud.google.com/blog/topics/developers-practitioners/graph-workflows-in-adk-everything-you-need-to-know> | 2026-09-30 |
| Agents as tools vs handoffs, orchestration via LLM vs via code | <https://openai.github.io/openai-agents-python/multi_agent/> | no date shown |
| Dynamic workflow as a JS script, resumable, progress view | <https://code.claude.com/docs/en/workflows> | no date shown |
| Five workflow patterns named before the term existed | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, updated 2026-10-09 |
