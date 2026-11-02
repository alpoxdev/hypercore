# Graph as Context

The third sense of "graph": a graph built over content and read as context, not a graph that decides what runs next. Kept separate because it has a different lifetime, a different failure mode, and a different reviewer.

> Korean version: [`graph-as-context.ko.md`](graph-as-context.ko.md)

## Why this is separated

Three different artifacts are called a graph in 2026 writing, and two of them share only a word.

| | Execution graph | Context graph |
|---|---|---|
| What the nodes are | Units of work: functions, model calls, agents, approvals | Entities, claims, paragraphs, or code lines |
| What the edges are | Permitted control transitions | Relationships: citations, references, dependencies |
| Lifetime | One run | Across runs, until sources change |
| Answers | Which component acts next | What is connected to what |
| Failure mode | Wrong order, unbounded cost, unreviewed action | Wrong or stale fact, lost provenance |
| Reviewed as | Topology, state contract, eval per node | Retrieval quality, provenance, rebuild policy |
| Evaluated by | Task completion, node assertions, trace | Comprehensiveness, diversity, faithfulness, citation consistency |

PuppyGraph states the split plainly: an execution graph "models control and state… its lifetime is a single run," a knowledge graph "models a domain… it persists across runs," and "the two are designed by different people for different reasons, and a system can use one, both, or neither." LangChain's evidence-graph post draws the same boundary from the other side: "the graph's job is evidence navigation, not modeling everything the organization knows."

**GC-1.** A context graph never justifies a control-flow decision, and an execution graph never justifies a factual claim. If a document argues for one using evidence about the other, the argument has changed subject.

## Two families that matter in practice

### Corpus graphs for retrieval (GraphRAG)

GraphRAG builds a graph index over a document collection in two stages: an LLM derives an entity knowledge graph from the sources, then pregenerates community summaries for groups of closely related entities. At query time each community summary produces a partial response, and the partial responses are summarized into the final answer.

The reported result is narrow and worth quoting precisely: for "a class of global sensemaking questions over datasets in the 1 million token range," GraphRAG showed "substantial improvements over a conventional RAG baseline for both the comprehensiveness and diversity of generated answers." It targets global questions — "what are the main themes" — that chunk retrieval handles badly, not local lookups.

### Evidence and code graphs for navigation

Two later variants show where this is heading:

- **Evidence graphs.** LangChain turned wiki citations into typed edges between claims, paragraphs, pages, and topics — `cite`, `supersede`, `refers_to` — so an agent follows a stable path instead of rediscovering links per question. Edges are materialized from existing references, so construction needs no additional model calls.
- **Repository code graphs.** RepoGraph builds a repository-level structure in which "each node in the graph represents a line of code, and edges represent the dependencies of code definitions and references," and uses it as "repository-wide navigation" for AI software engineering.

## What the evidence actually shows

LangChain's benchmark is the most specific public measurement, and its shape matters more than its headline numbers.

| Condition | Result |
|---|---|
| Simple lookup questions: search vs compiled wiki | No meaningful gain (0.84 vs 0.83 accuracy); latency rose from 9s to 12s |
| Connected questions: search vs compiled wiki | Accuracy rose from 0.10 to 0.52 — roughly 5x |
| Connected questions: wiki alone vs wiki plus evidence graph | Accuracy +27%, citation consistency doubled, cost per correct answer −58% |
| Compilation cost | 111 documents compiled for $4.15; 17 added later at about $0.09 each |

Two caveats belong next to those numbers. The corpus was synthetic (111 long-form insurance documents with a 972-fact ledger), and the benchmark was run by the vendor that sells the tooling. Read it as an existence proof of the shape — cross-source questions benefit, single-passage lookups do not — not as a general effect size.

The design lesson is stable across both sources: **the value of a context graph is concentrated in questions that require following relationships.** For local lookups it adds latency and nothing else, which is the same conclusion as GraphRAG's own scoping to global sensemaking.

## Rules

- **GC-2.** Edges are claims, not facts. Every edge carries its provenance: the source document, the extraction step, and the date. An unprovenanced edge cannot be reviewed or retired.
- **GC-3.** Staleness is detected mechanically where possible. LangChain's mechanism — hash the supporting lines, and let a changed hash flag affected claims without a model call — is the pattern to copy; only flagged claims go to a model for confirmation, revision, or retraction.
- **GC-4.** A rebuild is a run with a budget, not a query cost. GraphRAG's index construction is LLM work; budget it explicitly and decide the rebuild cadence from how fast the sources change.
- **GC-5.** Evaluate context graphs as retrieval. Comprehensiveness, diversity, faithfulness, and citation consistency are the metrics; a task success rate alone hides a lucky answer.
- **GC-6.** A node queries a context graph; the context graph does not query itself. The retrieval call is a node with an input, an output, and a failure path like any other.
- **GC-7.** Do not put orchestration state in the context graph. Mixing the two means a rebuild of the index can invalidate a run in flight.

## Where the two graphs meet

They meet at exactly one place, and it is worth designing deliberately.

- **A node reads the graph.** Any node that touches enterprise data has to express a query, and the execution graph has no opinion about whether that query is meaningful.
- **A rejection can be a routing signal.** PuppyGraph argues that a query validated against an enforced ontology and then rejected becomes structured feedback an edge can route on, sending work back to the node that produced it. This is a vendor claim about its own product, and the pattern is sound independently of the implementation: validation failure is a transition, not an exception.
- **Independence still holds.** The graph tells you when a node read; only the data model tells you whether what it read was true.

## When not to use a context graph

- The questions are local lookups over a small corpus — plain retrieval is faster and equal.
- The corpus changes faster than the index can be rebuilt, and the staleness mechanism cannot flag what changed.
- The relationships are not explicit in the sources and extracting them needs a model per rebuild: cost grows with corpus size, and errors become indistinguishable from facts.
- The real problem is ordering, not knowledge. A topology problem cannot be fixed by better retrieval.

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| Conflating the two graphs | "We have a graph" means two unrelated diagrams | Name the artifact: execution graph or context graph |
| Untyped edges | An edge says two things are related, not how | Type every edge (`cite`, `supersede`, `refers_to`) |
| No provenance | A claim cannot be traced to a source line | Store the source, hash, and date (GC-2, GC-3) |
| Rebuild on every query | Latency and cost grow with corpus size | Compile once, refresh on change |
| Task score as the only metric | A lucky answer looks like good retrieval | Measure citation consistency separately |
| Graph-shaped ceremony | Entities extracted that no question needs | Model only what a query traverses |

## Sources

> Links checked 2026-11-03: all were opened and read in full, and all resolve without a redirect.

| Claim | Source | Published / updated |
|---|---|---|
| GraphRAG: LLM-built entity graph plus community summaries; global sensemaking questions; 1M-token corpora; comprehensiveness and diversity | <https://arxiv.org/abs/2404.16130> | 2024-04-24 |
| Evidence graph with typed edges, hashed staleness detection, benchmark numbers and caveats, "evidence navigation" | <https://www.langchain.com/blog/building-agent-memory-openwiki-graphs> | 2026-10-28 |
| RepoGraph: line-level nodes, dependency edges, repository-wide navigation | <https://arxiv.org/abs/2410.14684> | v1 2024-10-03, v2 2025-03-18 |
| Execution graph vs knowledge graph: lifetime, purpose, and the disclaimer that they share a word | <https://www.puppygraph.com/learn/graph-engineering> | 2026-08-24 |
