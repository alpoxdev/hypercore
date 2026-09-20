# Harness Engineering

Standards for managing LLM instructions, prompts, and agent workflows as repeatable test subjects rather than gut feel.

> Korean version: [`HARNESS_ENGINEERING.ko.md`](HARNESS_ENGINEERING.ko.md)

## Why

LLM output is probabilistic and sensitive to changes in model, tools, and context. Improving an instruction is therefore not sentence polishing but harness work equipped with an **eval set, metrics, traces, and a regression gate**.

Harness layers are coupled. The academic harness-engineering survey cited in Sources states that the layers constrain one another across the stack, so a prompt, tool, sandbox, verifier, or monitor may look beneficial in isolation and still degrade the whole rollout once it meets the rest of the control loop. **A harness change is a system change**: test it as one. In eval cases, record single-axis changes and combined changes as different kinds of case, because only the second kind can show a coupling regression.

## Harness Layers

| Layer | Question | Artifact |
|---|---|---|
| Scenario | Under which user request or environment does it fail? | test case |
| Oracle | What counts as correct or successful? | expected behavior / rubric |
| Runner | With which model, tools, and context does it run? | eval config |
| Judge | How is it scored? | deterministic check / rubric / human review |
| Trace | Why did it fail? | span tree and the fields in `## Trace Fields` |
| Gate | When can it merge or ship? | a judgement rule with a declared run count and aggregation — see `## Judgement Rules`; depth scale in `instructions/validation/index.md` section 2 |

## Trace Fields

A trace is evidence, so its fields are fixed rather than improvised. The names below align with the
OpenTelemetry GenAI agent conventions, which are at **Development** status at the revision recorded
in Sources: this is an alignment target, not a conformance target.

| Field | Contents |
|---|---|
| HE-T-1: operation name | one of the values this harness emits — `plan`, `invoke_agent`, `invoke_workflow`, `execute_tool`. The cited convention defines further well-known values (`chat`, `create_agent`, retrieval and memory operations) and permits custom ones; the four here are the subset this harness is required to use, not the whole domain |
| HE-T-2: agent identity | agent id, name, and version |
| HE-T-3: conversation id | the identifier that ties the spans of one session together |
| HE-T-4: model and provider | the requested model and the provider name |
| HE-T-5: token accounting | input and output tokens, plus cache read and cache write |
| HE-T-6: finish reasons | the array of stop reasons, with a missing reason recorded as an error rather than omitted |
| HE-T-7: tool calls | call order, and an **argument summary** per call |
| HE-T-8: content attributes | message bodies, system instructions, and tool definitions are opt-in and carry a PII warning |

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

Behavioral evals and end-to-end benchmarks measure different things and neither replaces the other. A behavioral eval asserts one observable action (did the agent consult live search before answering); an end-to-end benchmark asserts the destination (does the task's final state match the goal). This distinction and the assertion-strictness guidance below come from the vendor article cited in Sources. Use behavioral evals to iterate and end-to-end benchmarks to confirm. Scale assertion strictness with task complexity: assert the specific action strictly when one path is optimal, and assert the outcome rather than the route when many paths are legitimate. Record the failure mode as well as the score — models differ, and one that abstains under uncertainty needs a different fix from one that answers confidently and wrongly.

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
- HE-J-4: Record the model and runtime version, the case-set hash, and the run count with every result. A result without them cannot be compared later.
- HE-J-5: Report `pass^k` (all k runs succeed) alongside `pass@k` (any run succeeds). They answer different questions, and only the first is a reliability claim.
- HE-J-6: A small-sample difference is not a gate. State the target interval width and the run count together.

- HE-J-7: Added context is an intervention. It does not become permanent context until it improves the target eval set — which is why a new reference document is registered in the index and **not** added to an always-loaded list until it has earned that place.

The derivation, the sample-size formula, and what those numbers do not claim are in
[`references/measurement.md`](references/measurement.md). The verification-depth scale these
rules attach to is `instructions/validation/index.md` section 2.

## Evidence Discipline

- HE-E-1: Verification evidence is written to a resolved path, never a typed one.
- HE-E-2: The evidence README carries four sections: what was tested, what was observed, why it is enough, and what was omitted.
- HE-E-3: No evidence file means the verification did not happen. There is no pass to record.
- HE-E-4: Live-surface proof and hermetic unit gates are labeled separately. One never substitutes for the other.
- HE-E-5: Isolation is proven, not assumed: before/after evidence of the untouched real state, the changed-path list, and the isolated directory path.
- HE-E-6: A run that could not execute is recorded as `SKIP`. A `SKIP` is not a pass.

The working shape of each rule, and which parts are a portable principle versus one repository's
implementation of it, are worked through in
[`references/evidence-and-recovery.md`](references/evidence-and-recovery.md) under Evidence discipline.

## Reducing Verification Cost

- HE-C-1: A decision to run fewer or cheaper checks is computed from durable state. Free-form prose never grants a reduction.
- HE-C-2: The reduction proof mirrors the computed selection exactly. A mismatch is fail-closed and the full set of checks stays in force.
- HE-C-3: At least one lane is never omitted: targeted verification against the real surface runs at every boundary.
- HE-C-4: Re-run avoidance requires a verified source-basis digest. A missing or unverified digest is fail-closed.

A worked reduction proof, field by field, is shown in
[`references/evidence-and-recovery.md`](references/evidence-and-recovery.md) under Reducing verification cost.

## Long-Horizon Recovery

A compaction that keeps the conversation but loses the contract has destroyed the work.

- HE-L-1: What survives a compaction is named in advance: the active goal, accepted scope and explicit non-goals, acceptance criteria, the current step and next action, and recorded blockers.
- HE-L-2: The recovery projection is read-only, and a projection that finds malformed, stale, unreadable, or tampered state degrades quietly. A projection failure never aborts the compaction.
- HE-L-3: Repeatedly recovering into the same next action is a stall. Fingerprint the projection, and after `MAX_UNCHANGED_RECOVERIES` unchanged recoveries — a named constant the workflow declares, not an adjective — emit an explicit `STALLED` directive that orders a durable blocker or escalation instead of repeating the action.
- HE-L-4: Tune the compaction prompt recall-first: maximize what it captures from the trace, then improve precision.

This bounds the loop; it does not claim to eliminate it. The projection, the stall counter, and the
survive-list are worked through in
[`references/evidence-and-recovery.md`](references/evidence-and-recovery.md) under Long-horizon recovery.

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
| Cost/latency | token budget, wall time, tool-call count |

Record the context itself as a variable, not a constant: total context tokens at the decision point, the number of distractor items included, and whether the relevant information was pre-loaded or retrieved just in time. A comparison that changes context length is a **different case**, and it must be labeled as one — see [`references/measurement.md`](references/measurement.md).

## LLM-as-Judge Rules

- Judge prompts need rubrics and examples; “is this good?” is not enough.
- Calibrate LLM judge against human or deterministic checks on a small set.
- Prefer pairwise/classification/scoring over open-ended commentary.
- Keep judge model/version/date in the eval record.
- Do not let the candidate answer judge itself.
- HE-R-1: Judge bias is not only self-preference. In the study cited in Sources, a judge scores lower-perplexity — more familiar — text higher than a human does, whether or not the judge produced it, so fluent prose can win on style. This is that study's finding for the judges it tested, not a property of every judge.
- HE-R-2: Calibrate in a fixed order: label a small human set, have the judge label the same set, compute the **alignment rate**, inspect the disagreements, revise the judge prompt, and repeat until the alignment rate clears a stated threshold. Only then use the judge.
- HE-R-3: Record the judge model, its version, and the achieved alignment rate in the eval record.

The calibration material here deliberately does not repeat the grader hierarchy and multi-sample
calibration guidance already in `instructions/validation/references/evaluation-design.md` section 4;
read that for the ordering of grader types.

## Agent Harness Rules

- Evaluate final answer **and** trajectory.
- Log tool calls, files touched, sources retrieved, and permission boundaries.
- Test recoverable failures: missing file, failing test, conflicting source, stale docs.
- Include adversarial retrieved content: web page or tool result that says “ignore previous instructions.”
- Gate external side effects with explicit permission cases.

## Agentic Security Minimums

Two design principles come first, stated by OWASP: **least agency** — limit not only what an agent
can access but how much freedom it has to act without checking back, because autonomy should be
earned rather than granted by default — and **strong observability** — you must see what the agent
is doing, why, and with whose identity. Neither is sufficient alone.

- HE-S-1: Tool authorization is checked per invocation and per **composition**, not per tool. Each tool may be authorized; the chain is not.
- HE-S-2: Untrusted input that reaches the planning loop does not get to change the goal. Include a case where retrieved content tries to.
- HE-S-3: External agents, MCP servers, plugins, prompt templates, and tool descriptors are pinned to a version and an authenticated source.
- HE-S-4: Cascading failures are bounded: chain-depth and runtime limits, validation between plan and execute, and a rollback path.

The threat enumeration behind these rules is in
[`references/agent-security.md`](references/agent-security.md).

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
| Every instruction change | smoke eval: a small fast set (the widely quoted 5-20 is unvalidated — see `## Prompt / Role Instruction Smoke Eval`) | aggregate pass rate over the batch; no single-run verdict (HE-J-1, HE-J-3) |
| Every model/runtime change | regression eval: known failures + representative workflows | compare against the recorded baseline with model/runtime version and case-set hash (HE-J-4) |
| Before release | full eval: quality + safety + cost/latency | report `pass^k` alongside `pass@k` for non-deterministic cases (HE-J-5) |
| After incident | add reproduction case permanently | the new case declares its `MIN_RUNS` and aggregation rule (HE-J-2) |

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-20. Next re-verification 2026-10-29.

The repository checker (`scripts/check-sources.sh`) issues HEAD requests and classifies the HTTP
status only; it does not read a response body. A **supplemental** check — extract each cited URL,
issue a GET, and inspect the status code together with the body for a not-found page — is what
catches a URL that answers 200 with a "page not found" body. Run the supplemental check when a link
carries a claim. When a source says its own content is out of date, point at the current methodology
page instead of quoting the stale figure as current.

| Claim | Source |
|---|---|
| OpenAI Evals API and the documented evaluation workflow. **Deprecated**: read-only for existing users on 2026-10-31, platform shutdown scheduled 2026-11-30; Datasets is the documented successor | <https://developers.openai.com/api/docs/guides/evals> |
| OpenAI dataset-backed prompt optimizer. **Deprecated** with the Evals platform on the same timeline | <https://developers.openai.com/api/docs/guides/prompt-optimizer> |
| OpenAI agent workflow evaluation — start with trace grading, expand to datasets and eval runs | <https://developers.openai.com/api/docs/guides/agent-evals> |
| Anthropic success criteria (specific, measurable, achievable, relevant) and eval construction | <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests> |
| Google Vertex Gen AI evaluation — adaptive rubrics that generate pass/fail criteria per prompt | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/evaluation-overview> |
| Adaptive rubric metric details (`INSTRUCTION_FOLLOWING`, `TEXT_QUALITY`, and others) | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/rubric-metric-details> |
| LangSmith evaluation — the dataset + evaluators + experiment workflow, and offline/online evaluation types | <https://docs.langchain.com/langsmith/evaluation>, <https://docs.langchain.com/langsmith/evaluation-types> |
| Promptfoo LLM-as-a-judge — a model grades against a rubric and returns pass, score, and reason | <https://www.promptfoo.dev/docs/guides/llm-as-a-judge/> |
| Promptfoo red teaming — adversarial input generation, with guides for RAG and agents | <https://www.promptfoo.dev/docs/red-team/> |
| Google Responsible GenAI safety evaluation | <https://ai.google.dev/responsible> |
| OpenAI skill eval axes (outcome / process / style / efficiency) | <https://developers.openai.com/blog/eval-skills> |
| Harness-engineering survey: layer coupling and the cross-layer constraints | <https://picrew.github.io/LLM-Harness/> |
| Harness-engineering vendor article: the behavioral-vs-end-to-end distinction, the three-step behavioral loop, and assertion strictness by task complexity | <https://developers.googleblog.com/the-anatomy-of-harness-engineering-how-to-evaluate-iterate-and-guard-ai-coding-agents/> |
| OpenTelemetry GenAI agent semantic conventions — operation names, agent identity, token accounting, finish reasons, and the **Development** status of the conventions | <https://github.com/open-telemetry/semantic-conventions-genai> |
| LLM-judge bias toward lower-perplexity (more familiar) text, independent of self-preference | <https://arxiv.org/abs/2410.21819> |

An earlier revision left this list as prose with no URLs, making it unverifiable. Each entry above was grounded by checking its URL directly on 2026-07-29.
