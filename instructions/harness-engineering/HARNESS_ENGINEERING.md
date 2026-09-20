# Harness Engineering

Standards for managing LLM instructions, prompts, and agent workflows as repeatable test subjects rather than gut feel.

> Korean version: [`HARNESS_ENGINEERING.ko.md`](HARNESS_ENGINEERING.ko.md)

## Why

LLM output is probabilistic and sensitive to changes in model, tools, and context. Improving an instruction is therefore not sentence polishing but harness work equipped with an **eval set, metrics, traces, and a regression gate**.

## Harness Layers

| Layer | Question | Artifact |
|---|---|---|
| Scenario | Under which user request or environment does it fail? | test case |
| Oracle | What counts as correct or successful? | expected behavior / rubric |
| Runner | With which model, tools, and context does it run? | eval config |
| Judge | How is it scored? | deterministic check / rubric / human review |
| Trace | Why did it fail? | tool calls, retrieved sources, logs |
| Gate | When can it merge or ship? | pass threshold / blocking criteria |

## Prompt / Role Instruction Smoke Eval

Keep at least 3-5 smoke cases whenever you change a role prompt.

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

## Evaluation Types

| Type | Use When | Judge |
|---|---|---|
| Deterministic | JSON shape, exact label, file exists, tests pass | script/assertion |
| Rubric | quality, helpfulness, design review, reasoning adequacy | calibrated LLM or human |
| Pairwise | prompt/model A vs B | blinded preference |
| Trace-based | agent trajectory, tool order, retrieval behavior | tool-call assertions |
| Red-team | prompt injection, unsafe autonomy, data leak | adversarial cases |
| Production sampling | real user distributions | anonymized logs + human review |

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

## LLM-as-Judge Rules

- Judge prompts need rubrics and examples; “is this good?” is not enough.
- Calibrate LLM judge against human or deterministic checks on a small set.
- Prefer pairwise/classification/scoring over open-ended commentary.
- Keep judge model/version/date in the eval record.
- Do not let the candidate answer judge itself.

## Agent Harness Rules

- Evaluate final answer **and** trajectory.
- Log tool calls, files touched, sources retrieved, and permission boundaries.
- Test recoverable failures: missing file, failing test, conflicting source, stale docs.
- Include adversarial retrieved content: web page or tool result that says “ignore previous instructions.”
- Gate external side effects with explicit permission cases.

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

| Frequency | Eval set |
|---|---|
| Every instruction change | smoke eval: 5-20 fast cases |
| Every model/runtime change | regression eval: known failures + representative workflows |
| Before release | full eval: quality + safety + cost/latency |
| After incident | add reproduction case permanently |

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-19. Next re-verification 2026-10-29.

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

An earlier revision left this list as prose with no URLs, making it unverifiable. Each entry above was grounded by checking its URL directly on 2026-07-29.
