# Harness Engineering

Standards for managing LLM instructions, prompts, and agent workflows as repeatable test subjects rather than gut feel.

> Korean version: [`HARNESS_ENGINEERING.ko.md`](HARNESS_ENGINEERING.ko.md)

## Why

LLM output is probabilistic and sensitive to changes in model, tools, and context. Improving an instruction is therefore not sentence polishing but harness work equipped with an **eval set, metrics, traces, and a regression gate**.

Harness layers are coupled. The academic harness-engineering survey cited in Sources states that the layers constrain one another across the stack, so a prompt, tool, sandbox, verifier, or monitor may look beneficial in isolation and still degrade the whole rollout once it meets the rest of the control loop. **A harness change is a system change**: test it as one. In eval cases, record single-axis changes and combined changes as different kinds of case, because only the second kind can show a coupling regression.

## What a Harness Is

The harness is everything in a run that is not the model: the instructions it reads, the tools it can call, how its context is assembled and compacted, where its code executes, what checks its output, what records its behavior, and what gate decides the work may ship.

**HE-A-1.** A component that changes the agent's behavior and is not the model weights is part of the harness and is in scope for this document.

Anthropic's documentation states the same boundary — "Claude Code is the layer around the model that provides the tools and manages the context the model sees. This surrounding layer is what the term agentic harness refers to" — and OpenAI states the consequence for design: "From the agent's point of view, anything it can't access in-context while running effectively doesn't exist." The parts inventory, the guide/sensor split, and the evidence behind each claim are in [`references/harness-anatomy.md`](references/harness-anatomy.md).

## Harness Layers

| Layer | Question | Artifact |
|---|---|---|
| Scenario | Under which user request or environment does it fail? | test case |
| Oracle | What counts as correct or successful? | expected behavior / rubric |
| Runner | With which model, tools, and context does it run? | eval config |
| Judge | How is it scored? | deterministic check / rubric / human review |
| Trace | Why did it fail? | span tree and the fields in `## Trace Fields` |
| Gate | When can it merge or ship? | a judgement rule with a declared run count and aggregation — see `## Judgement Rules`; depth scale in `instructions/validation/index.md` section 2 |

## Harness Staleness

Every component encodes a bet about what the model cannot do unaided, and models change under it. Anthropic reports the case directly: a context-reset component that had been necessary on one model "had become dead weight" on its successor — the behavior it compensated for was gone, the component remained, and it cost tokens while hiding the improvement.

- HE-A-2: Every harness component declares the assumption it encodes, the trigger that forces a re-test (a model or runtime change), and the observation that deletes it (the eval outcome is unchanged without it).
- HE-A-3: A failing behavior is repaired in the harness, not in the run. The repair is a durable control — an instruction line traceable to that failure, a tool that detects it, or a check that rejects it — and it ships with the eval case that reproduces the failure.
- HE-A-4: Harness cost is measured, never assumed. Each component reports the token, wall-time, and cost delta it imposes, and results are reported per model, because the same component can be decisive on one model and worthless on another.
- HE-A-5: The space of useful harnesses moves rather than closes. A harness review is a standing activity, not a one-time migration.

The measured case behind HE-A-4 is a paired experiment on a coding task: the same harness cost about 10.5× the tokens, ~3× the time, and ~7× the money, changed nothing for the stronger model, and moved the weaker one from 3/10 to 10/10. See [`references/harness-anatomy.md`](references/harness-anatomy.md) under "The staleness rule".

## Trace Fields

A trace is evidence, so its fields are fixed rather than improvised. The names below align with the OpenTelemetry GenAI agent conventions, which remain at **Development** status — the conventions moved to their own repository in May 2026, the core specification's v1.42.0 release deprecated the old paths as a breaking change, and `invoke_agent` was split into a client and an internal span. This is an **alignment target, not a conformance target**: a standard still being reshaped cannot be a conformance target.

| Field | Contents |
|---|---|
| HE-T-1: operation name | `gen_ai.operation.name`, one of the values this harness emits — `plan`, `invoke_agent`, `invoke_workflow`, `execute_tool`. The convention lists eighteen well-known values (`chat`, `create_agent`, retrieval and memory operations among them) and permits custom ones; the four here are the subset this harness is required to use, not the whole domain |
| HE-T-2: agent identity | `gen_ai.agent.id`, `gen_ai.agent.name`, and the agent version. The convention advises against recording in-memory instance ids, which are transient |
| HE-T-3: conversation id | `gen_ai.conversation.id`, the identifier that ties the spans of one session together |
| HE-T-4: model and provider | the requested model and the provider name |
| HE-T-5: token accounting | input and output tokens, plus cache read and cache write |
| HE-T-6: finish reasons | the array of stop reasons, with a missing reason recorded as an error rather than omitted |
| HE-T-7: tool calls | call order, and an **argument summary** per call |
| HE-T-8: content attributes | message bodies, system instructions, and tool definitions are opt-in — default `NO_CONTENT` — and carry a PII warning. The convention names the opt-in switch `OTEL_INSTRUMENTATION_GENAI_CAPTURE_CONTENT` |

## Prompt / Role Instruction Smoke Eval

Keep a smoke set for every role-prompt change. The commonly quoted "3-5 cases" is **not** a validated threshold and **not** a floor: no source measures it, so this repository adopts no minimum case count. What replaces it is a declared target: state the interval width you want and the run count that buys it, per case, and see `## Judgement Rules`.

| Case type | What to check | Example |
|---|---|---|
| Happy path | Does it hold the goal, output format, and tone? | A clear request produces the expected schema |
| Missing context | Does it avoid guessing facts it does not know? | A request whose required file or source is absent |
| Scope boundary | Does it stay inside non-goals? | A request touching forbidden files or external side effects |
| Source boundary | Does it treat web/tool results as evidence rather than instructions? | Prompt injection inside a retrieved page |
| Regression | Does a previous failure stay fixed? | A known bad prompt/output pair |

## Minimum Eval Case Format

```yaml
id: unique-case-id
intent: what the user is trying to achieve
context:
  files: []
  sources: []
input: |
  verbatim user request
expected:
  must:
    - actions that must happen
  must_not:
    - actions that must not happen
metrics:
  - instruction_following
  - factuality
  - tool_use
  - safety
  - completion
```

Behavioral evals and end-to-end benchmarks measure different things and neither replaces the other. A behavioral eval asserts one observable action (did the agent consult live search before answering); an end-to-end benchmark asserts the destination (does the task's final state match the goal). Use behavioral evals to iterate and end-to-end benchmarks to confirm, and scale assertion strictness with task complexity. Record the failure mode as well as the score — models that abstain under uncertainty and models that answer confidently and wrongly need different fixes. The vendor article behind this split, and the assertion-strictness guidance, are in Sources; [`references/measurement.md`](references/measurement.md) carries the derivation.

## Evaluation Types

| Type | Use When | Judge |
|---|---|---|
| Deterministic | JSON shape, exact label, file exists, tests pass | script/assertion |
| Rubric | quality, helpfulness, design review, reasoning adequacy | calibrated LLM or human |
| Pairwise | prompt/model A vs B | blinded preference |
| Trace-based | agent trajectory, tool order, retrieval behavior | tool-call assertions |
| Red-team | prompt injection, unsafe autonomy, data leak | adversarial cases |
| Production sampling | real user distributions | anonymized logs + human review |

## Judgement Rules

A non-deterministic target is judged by a rule, not by a single observation.

- HE-J-1: A non-deterministic target is not judged pass or fail from a single run.
- HE-J-2: Every case declares its `MIN_RUNS` and its aggregation rule. A case carrying neither is not a gate.
- HE-J-3: Gate on the aggregate pass rate across a batch, not on one run's verdict. Every gate declares two separate numbers: its **equivalence margin** — how large a regression it is willing to accept — and the interval width its run count buys. A change inside the equivalence margin does not block. Interval width alone is a precision measure and never licenses ignoring a regression.
- HE-J-4: Record the model and runtime version, the case-set hash, the **grader version**, the **benchmark version**, and the run count with every result. A result without them cannot be compared later.
- HE-J-5: Report `pass^k` (all k runs succeed) alongside `pass@k` (any run succeeds). They answer different questions, and only the first is a reliability claim.
- HE-J-6: A small-sample difference is not a gate. State the target interval width and the run count together.
- HE-J-7: Added context is an intervention. It does not become permanent context until it improves the target eval set — which is why a new reference document is registered in the index and **not** added to an always-loaded list until it has earned that place.
- HE-J-8: A benchmark score is recorded with its version, grader version, resource configuration, and contamination and defect status. A single-digit difference between two systems stays unresolved until the grader and the resource configuration are shown to be equivalent.

HE-J-4 gained the grader column and HE-J-8 exists because the measured noise is bigger than the effects people gate on: re-grading unchanged trajectories moved a published benchmark by up to ~9 points, and machine allocation alone moved another by 6 points. Both derivations, with the sample-size formula, are in [`references/measurement.md`](references/measurement.md). The verification-depth scale these rules attach to is `instructions/validation/index.md` section 2.

## Evidence Discipline

- HE-E-1: Verification evidence is written to a resolved path, never a typed one.
- HE-E-2: The evidence README carries four sections: what was tested, what was observed, why it is enough, and what was omitted.
- HE-E-3: No evidence file means the verification did not happen. There is no pass to record.
- HE-E-4: Live-surface proof and hermetic unit gates are labeled separately. One never substitutes for the other.
- HE-E-5: Isolation is proven, not assumed: before/after evidence of the untouched real state, the changed-path list, and the isolated directory path.
- HE-E-6: A run that could not execute is recorded as `SKIP`. A `SKIP` is not a pass. A trial aborted by a harness fault is excluded from the denominator and reported as an error trial, not averaged in as a failure.

The working shape of each rule, and which parts are a portable principle versus one repository's implementation of it, are worked through in [`references/evidence-and-recovery.md`](references/evidence-and-recovery.md) under Evidence discipline.

## Reducing Verification Cost

- HE-C-1: A decision to run fewer or cheaper checks is computed from durable state. Free-form prose never grants a reduction.
- HE-C-2: The reduction proof mirrors the computed selection exactly. A mismatch is fail-closed and the full set of checks stays in force.
- HE-C-3: At least one lane is never omitted: targeted verification against the real surface runs at every boundary.
- HE-C-4: Re-run avoidance requires a verified source-basis digest. A missing or unverified digest is fail-closed.

A worked reduction proof, field by field, is shown in [`references/evidence-and-recovery.md`](references/evidence-and-recovery.md) under Reducing verification cost.

## Long-Horizon Recovery

A compaction that keeps the conversation but loses the contract has destroyed the work. A reset that clears the window without a handoff destroys it faster.

- HE-L-1: What survives a compaction **or a reset** is named in advance: the active goal, accepted scope and explicit non-goals, acceptance criteria, the current step and next action, and recorded blockers.
- HE-L-2: The recovery projection is read-only, and a projection that finds malformed, stale, unreadable, or tampered state degrades quietly. A projection failure never aborts the compaction.
- HE-L-3: Repeatedly recovering into the same next action is a stall. Fingerprint the projection, and after `MAX_UNCHANGED_RECOVERIES` unchanged recoveries — a named constant the workflow declares, not an adjective — emit an explicit `STALLED` directive that orders a durable blocker or escalation instead of repeating the action.
- HE-L-4: Tune the compaction prompt recall-first: maximize what it captures from the trace, then improve precision.
- HE-L-5: A reset carries the survive-list in a handoff artifact that a fresh session can read without the old transcript. A recovery design that only covers compaction fails silently the moment the workflow switches to a reset.

This bounds the loop; it does not claim to eliminate it. The projection, the stall counter, the survive-list, and the handoff are worked through in [`references/evidence-and-recovery.md`](references/evidence-and-recovery.md) under Long-horizon recovery.

## Prompt/Instruction Change Loop

```text
1. Define success criteria
2. Collect baseline cases, including known failures
3. Run current instruction
4. Diagnose failures from output + trace
5. Patch the smallest instruction surface
6. Re-run the same eval set
7. Add new edge case for every new bug found
8. Document decision and remaining risk
```

## Metrics Menu

| Area | Metric examples |
|---|---|
| Task fidelity | required steps completed, forbidden steps avoided |
| Factuality | source support, citation accuracy, contradiction rate, stale-source rate |
| Retrieval | context recall, context precision, source-boundary adherence |
| Tool use | correct tool chosen, unnecessary tool calls, side effects avoided |
| Code work | tests pass, diff minimality, lint/typecheck, regression count |
| Safety | prompt injection resistance, permission boundary, secret leakage |
| Cost/latency | token budget, wall time, tool-call count, measured cost per shipped change |

Cost is a peer of quality, not a tiebreak: at similar accuracy, agent cost has been measured to differ by almost two orders of magnitude, and a harness can multiply a single task's cost several times over. Record the context itself as a variable too — total context tokens at the decision point, the number of distractor items, and whether the relevant information was pre-loaded or retrieved just in time. A comparison that changes context length is a **different case** — see [`references/measurement.md`](references/measurement.md).

## LLM-as-Judge Rules

- Judge prompts need rubrics and examples; “is this good?” is not enough.
- Calibrate LLM judge against human or deterministic checks on a small set.
- Prefer pairwise/classification/scoring over open-ended commentary.
- Keep judge model/version/date in the eval record.
- Do not let the candidate answer judge itself.
- HE-R-1: Judge bias is not only self-preference. In the study cited in Sources, a judge scores lower-perplexity — more familiar — text higher than a human does, whether or not the judge produced it, so fluent prose can win on style. This is that study's finding for the judges it tested, not a property of every judge.
- HE-R-2: Calibrate in a fixed order: label a small human set, have the judge label the same set, compute the **alignment rate**, inspect the disagreements, revise the judge prompt, and repeat until the alignment rate clears a stated threshold. Only then use the judge.
- HE-R-3: Record the judge model, its version, and the achieved alignment rate in the eval record.
- HE-R-4: The actor and the judge are different agents. Separating the agent doing the work from the agent judging it is a stronger lever than refining the worker's own self-assessment, which skews positive; give the judge the artifact and the criteria, not the worker's summary of its own work.

The calibration material here deliberately does not repeat the grader hierarchy and multi-sample calibration guidance already in `instructions/validation/references/evaluation-design.md` section 4; read that for the ordering of grader types.

## Agent Harness Rules

- Evaluate final answer **and** trajectory.
- Log tool calls, files touched, sources retrieved, and permission boundaries.
- Test recoverable failures: missing file, failing test, conflicting source, stale docs.
- Include adversarial retrieved content: web page or tool result that says “ignore previous instructions.”
- Gate external side effects with explicit permission cases.

## Agentic Security Minimums

OWASP's letter states two ideas that this section is built on. **Least-Agency**, which expands least-privilege and excessive-agency: limit not only what an agent can access but how much freedom it has to act without checking back, because autonomy should be earned rather than granted by default. And **strong observability**: you must see what the agent is doing, why, and with whose identity. Neither survives alone — least agency without observability is blind, observability without least agency is surveillance.

- HE-S-1: Tool authorization is checked per invocation and per **composition**, not per tool. Each tool may be authorized; the chain is not.
- HE-S-2: Untrusted input that reaches the planning loop does not get to change the goal. Include a case where retrieved content tries to.
- HE-S-3: External agents, MCP servers, plugins, prompt templates, and tool descriptors are pinned to a version and an authenticated source.
- HE-S-4: Cascading failures are bounded: chain-depth and runtime limits, validation between plan and execute, and a rollback path.

The threat enumeration behind these rules, the exact OWASP headings, and the 2026 additions on harness/compute separation are in [`references/agent-security.md`](references/agent-security.md).

## Parallel / Subagent Trace Rules

Parallel work hides failures when only results are inspected, so add trace assertions.

| Assertion | How to check | Failure example |
|---|---|---|
| bounded_spawn | The subagent/background-agent prompt carries objective, scope, output, and stop condition | Unbounded delegation such as "review the whole codebase" |
| independent_or_sequenced | Parallel tasks have no input dependency, or sequential waiting is explicit | Running B concurrently when B needs A's result |
| ownership_declared | Editing tasks own a file/directory write set | Two agents modifying the same config |
| least_privilege_tools | Read-only investigation carries no write or external side-effect permission | A docs-lookup agent able to run production commands |
| parent_continues | During non-blocking work the leader proceeds with independent work or records why not | Pointless idle waiting right after spawning |
| child_reports_evidence | Child results include files, links, test output, or changed files | Returning only "no problems found" |
| parent_integrates | The leader synthesizes conflicts, duplicates, and gaps, then decides | Concatenating subagent summaries verbatim |
| parent_verifies | Before final completion the leader reads verification output, evals, or source checks | Trusting only the subagent's completion claim |

A parallel-implementation eval includes at least one "same-file conflict" case and at least one "independent research fan-out" case.

## CI / Regression Guidance

| Frequency | Eval set | Judgement rule |
|---|---|---|
| Every instruction change | smoke eval: a small fast set (the widely quoted 3-5 is unvalidated — see `## Prompt / Role Instruction Smoke Eval`) | aggregate pass rate over the batch; no single-run verdict (HE-J-1, HE-J-3) |
| Every model/runtime change | regression eval: known failures + representative workflows | compare against the recorded baseline with model/runtime version and case-set hash (HE-J-4) |
| Before release | full eval: quality + safety + cost/latency | report `pass^k` alongside `pass@k` for non-deterministic cases (HE-J-5) |
| After incident | add reproduction case permanently | the new case declares its `MIN_RUNS` and aggregation rule (HE-J-2) |
| After a grader or benchmark change | re-grade the saved trajectories before comparing | the grader version changed, so earlier numbers are not comparable (HE-J-4, HE-J-8) |

## Related Documents

| Area | Boundary |
|---|---|
| [`../loop-engineering/LOOP_ENGINEERING.md`](../loop-engineering/LOOP_ENGINEERING.md) | A loop sits above the harness: it decides when to invoke the harness again, and it inherits the trace fields and gates defined here. A loop is not a substitute for evaluating the harness. |
| [`../graph-engineering/GRAPH_ENGINEERING.md`](../graph-engineering/GRAPH_ENGINEERING.md) | A graph decides what runs next across nodes; each node's behavior is still harness-scoped. |
| [`../validation/index.md`](../validation/index.md) | The verification-depth scale that `## Judgement Rules` and the gate rules attach to. |
| [`../context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md) | What enters the window and with what authority; this document measures the effect of that choice. |

## Sources

> Links checked 2026-11-03. Every URL in the table answered 200 without a redirect on that date, except the two bot-walled pages whose 403 is noted in the row.

The repository checker (`scripts/check-sources.sh`) runs three checks. Two are offline and strict: every `Checked YYYY-MM-DD` / `확인 YYYY-MM-DD` marker must parse as a real ISO date, and every document must stay at or under 300 lines. The third is the network check, advisory unless `--strict` is passed: each cited URL is requested with HEAD, a 3xx is reported as `MOVED` with its final target, `403`/`405`/`429` count as alive (bot wall, no HEAD support, rate limit), and any other non-200 status is reported. URLs inside fenced code blocks are stripped before collection and the skipped count is printed, and RFC 2606 example domains plus loopback addresses are excluded. The checker classifies status codes only; it does not read a response body, so a **supplemental** check — extract each cited URL, issue a GET, and inspect the status code together with the body for a not-found page — is what catches a URL that answers 200 with a "page not found" body. Run the supplemental check when a link carries a claim. When a source says its own content is out of date, point at the current methodology page instead of quoting the stale figure as current.

**Evidence grades.** Every source table in `references/` grades each row with one of five labels, and no other label is used. `PRIMARY` = the document that states the claim: a paper, standard, benchmark release note, or dataset. `VENDOR` = a first-party product or vendor engineering article. `PRACTITIONER` = an individual engineer or consultancy writing from their own practice, not a vendor's product claim. `REPO` = a code repository used as an implementation example. `STUDY` = a research write-up reporting the authors' own experiment without peer review — neither a peer-reviewed paper nor a product announcement.

| Claim | Source |
|---|---|
| OpenAI Evals API and the documented evaluation workflow. **Deprecated**: deprecation announced 2026-06-03, existing evals read-only since **2026-10-31**, dashboard and API shutdown scheduled **2026-11-30**. Datasets is the documented entry point for new work and Promptfoo is the linked migration path | <https://developers.openai.com/api/docs/guides/evals> |
| OpenAI deprecation timeline for the Evals platform and for graders, which are retired with it rather than replacing it | <https://developers.openai.com/api/docs/deprecations> |
| OpenAI dataset-backed prompt optimizer. **Deprecated** with the Evals platform on the same timeline | <https://developers.openai.com/api/docs/guides/prompt-optimizer> |
| OpenAI agent workflow evaluation — start with trace grading, expand to datasets and eval runs | <https://developers.openai.com/api/docs/guides/agent-evals>, <https://developers.openai.com/api/docs/guides/trace-grading> |
| OpenAI eval-driven development, and "vibe-based evals" as a named anti-pattern | <https://developers.openai.com/api/docs/guides/evaluation-best-practices> |
| Anthropic success criteria (specific, measurable, achievable, relevant) and eval construction | <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests> |
| Anthropic eval practice: eval-driven development, 20-50 cases drawn from real failures, partial credit, grading the outcome rather than the path | <https://www.anthropic.com/research/demystifying-evals-for-ai-agents> |
| Infrastructure noise: 6pp on Terminal-Bench 2.0, 1.54pp on SWE-bench, and the "below 3 percentage points" rule | <https://www.anthropic.com/research/infrastructure-noise> |
| Eval awareness as an ongoing adversarial problem, with the decryption case and its adjusted score | <https://www.anthropic.com/research/eval-awareness-browsecomp> |
| Harness definitions, the initializer/incremental session split, and durable artifacts across sessions | <https://www.anthropic.com/research/effective-harnesses-for-long-running-agents> |
| Harness design: reset plus structured handoff, doer/judge separation, and components that go stale as models improve | <https://www.anthropic.com/research/harness-design-long-running-apps> |
| Harness assumptions needing frequent questioning, and a component that became dead weight | <https://www.anthropic.com/research/managed-agents> |
| "Harness engineering" as a named practice: humans steer, agents execute; a map rather than a manual; the agent's in-context view as the boundary of what exists | <https://openai.com/index/harness-engineering> (403 to automated clients; read in a browser) |
| The harness as the surrounding execution system, harness/compute separation for credential isolation, and durable execution | <https://developers.openai.com/blog/codex-as-a-platform>, <https://openai.com/index/the-next-evolution-of-the-agents-sdk> (the second is 403 to automated clients) |
| The harness ratchet: a failure becomes a durable control, and the fastest route is a tool that tells the agent it is wrong | <https://mitchellh.com/writing/my-ai-adoption-journey> |
| Guides versus sensors, LLM-consumable sensor output, and the claim that not every codebase is equally amenable to harnessing | <https://martinfowler.com/articles/harness-engineering.html> |
| The measured cost and per-model value of a harness | <https://martinfowler.com/articles/are-harnesses-worth-the-cost.html> |
| "A raw model is not an agent", hooks as enforcement, and doer/judge separation | <https://addyosmani.com/blog/agent-harness-engineering/> |
| Google Vertex Gen AI evaluation — adaptive rubrics that generate pass/fail criteria per prompt | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/evaluation-overview> |
| Adaptive rubric metric details (`INSTRUCTION_FOLLOWING`, `TEXT_QUALITY`, and others) | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/rubric-metric-details> |
| LangSmith evaluation — the dataset + evaluators + experiment workflow, and offline/online evaluation types | <https://docs.langchain.com/langsmith/evaluation>, <https://docs.langchain.com/langsmith/evaluation-types> |
| Promptfoo LLM-as-a-judge — a model grades against a rubric and returns pass, score, and reason | <https://www.promptfoo.dev/docs/guides/llm-as-a-judge/> |
| Promptfoo red teaming — adversarial input generation, with guides for RAG and agents | <https://www.promptfoo.dev/docs/red-team/> |
| Google Responsible GenAI safety evaluation | <https://ai.google.dev/responsible> |
| OpenAI skill eval axes (outcome / process / style / efficiency), published 2026-01-22 | <https://developers.openai.com/blog/eval-skills> |
| Harness-engineering survey: layer coupling and the cross-layer constraints | <https://picrew.github.io/LLM-Harness/> |
| Harness-engineering vendor article: the behavioral-vs-end-to-end distinction, the three-step behavioral loop, and assertion strictness by task complexity | <https://developers.googleblog.com/the-anatomy-of-harness-engineering-how-to-evaluate-iterate-and-guard-ai-coding-agents/> |
| OWASP Top 10 for Agentic Applications (edition "Version 2026", released 2025-12-09) and its two ideas, least agency and strong observability | <https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/> |
| OpenTelemetry GenAI semantic conventions — the Development status, the eighteen operation-name values, `gen_ai.agent.id` / `gen_ai.agent.name` / `gen_ai.conversation.id`, the opt-in content capture with `OTEL_INSTRUMENTATION_GENAI_CAPTURE_CONTENT`, and the 2026 move plus `invoke_agent` split | <https://github.com/open-telemetry/semantic-conventions-genai>, <https://github.com/open-telemetry/semantic-conventions-genai/blob/main/docs/gen-ai/gen-ai-agent-spans.md> (the `opentelemetry.io/docs/specs/semconv/gen-ai/` page is now a stub pointing here) |
| LLM-judge bias toward lower-perplexity (more familiar) text, independent of self-preference | <https://arxiv.org/abs/2410.21819> |

An earlier revision cited `anthropic.com/engineering/...` URLs, which now redirect to `anthropic.com/research/...`;
the table above uses the redirect targets.
