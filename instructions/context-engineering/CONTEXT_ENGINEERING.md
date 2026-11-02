# Context Engineering

Standards for designing instruction, context, tools, memory, and validation so that multiple agent runtimes — Codex, Claude Code, Cursor, GitHub Copilot, and others — work toward the same intent.

> Korean version: [`CONTEXT_ENGINEERING.ko.md`](CONTEXT_ENGINEERING.ko.md)

## Core definition

Context engineering is not "dressing up a prompt with nice sentences." It is designing the **goal, scope, evidence, tools, constraints, and verification criteria** the model receives as an executable system. A role prompt is subject to the same rule: it is not a persona declaration but a contract of success criteria and verifiable behavior the role is accountable for.

Anthropic frames it as "the set of strategies for curating and maintaining the optimal set of tokens (information) during LLM inference," and calls it "the natural progression of prompt engineering" (published 2025-09-29, page revised 2026-10-18; checked 2026-11-03). Its sizing rule is "the minimal set of information that fully outlines your expected behavior," with the explicit caveat that "minimal does not necessarily mean short." Chroma supplies the empirical reason: across 18 models in four families, performance degraded as input length grew while task difficulty was held constant, so context size is a quality variable and not only a cost variable ([`references/core-principles.md`](references/core-principles.md) §2).

## Core Contract

| Section | Must state | Avoid |
|---|---|---|
| Intent | What the user counts as success, and as failure | Persona work and inflated role-play |
| Scope | What may be read, modified, or created | Unbounded scope such as "everything related" |
| Authority | Instruction priority and conflict resolution | Mixing user, project, and tool instructions |
| Evidence | Which sources to trust | Treating a search snippet or LLM answer as a primary source |
| Tools | When to use which tool and when to stop; ownership and verification duty under parallel delegation | Letting the model imagine tools that do not exist |
| Output | Artifact format, file location, language/tone, completion criteria | Vague completion conditions such as "tidy it up nicely" |
| Verification | Test, eval, review, and source-check criteria | Declaring completion without verification |
| Iteration | Prompt version, failure cases, reason for change | Endlessly polishing sentences that merely look good |

## Context lifecycle

A prompt contract governs one turn. A long task also needs the four levers LangChain names write, select, compress, and isolate (checked 2026-11-03). Treat them as a checklist when a run degrades and the model is not the cause.

| Lever | What it does | Concrete means | Failure if skipped |
|---|---|---|---|
| Write | Moves state out of the window so it survives truncation | Notes, spec file, to-do list, external memory directory, artifact paths | The plan is lost the moment the window truncates |
| Select | Pulls in only what the current step needs | JIT reference loading, narrow tool set, targeted search | Low-signal tokens crowd out the rule that mattered |
| Compress | Keeps the meaning, drops the tokens | Server-side compaction, summary handoff, tool-result clearing | Cost and latency rise while accuracy falls |
| Isolate | Splits context across workers or sandboxes | Subagent with its own window returning a summary; sandbox returning only results | One worker's verbose output contaminates every later decision |

Rules that hold across runtimes:

1. **Move before summarizing.** Clear or relocate what can be reconstructed (tool output, file dumps); summarize only what cannot.
2. **Keep the authoritative plan outside the window**, then re-read it after every compaction. A summary of a plan is not the plan.
3. **A handoff is a summary plus paths**, not a transcript. The receiver must be able to reopen the evidence.
4. **Log the trigger.** Record what crossed the threshold, what was dropped, and what had to be re-read, or you cannot tell a lost fact from a wrong one.
5. **Prefer clearing tool results over rewriting history.** It is the lightest compression step and it preserves the record of which tools ran.

Per-vendor parameters, thresholds, and model exclusions are in [`references/context-management.md`](references/context-management.md). The instruction-side analogue (a stable cacheable prefix plus a volatile tail) is in [`../cache/CACHE.md`](../cache/CACHE.md).

## Runtime-neutral pattern

```xml
<task_contract>
  <intent>What must be achieved</intent>
  <scope>Target files, systems, and blast radius on users</scope>
  <authority>Which instruction wins on conflict, and which assumptions are forbidden</authority>
  <evidence>Trusted source channels and grades</evidence>
  <workflow>Explore -> plan -> execute -> verify -> report</workflow>
  <tools>Available tools and side-effect limits</tools>
  <verification>Tests, evals, or reviews that prove completion</verification>
  <output>Final artifact format</output>
</task_contract>
```

XML tags remain the documented default for Claude models: current Anthropic guidance says XML tags "help Claude parse complex prompts unambiguously" (checked 2026-11-03), and its agent guidance recommends organizing prompts into distinct sections with XML tags or Markdown headers while noting that the exact formatting "is likely becoming less important as models become more capable." The point is **section separation**, not XML itself. In Codex/AGENTS.md, Cursor Rules, and Copilot instructions the same structure can be expressed with Markdown headings and tables.

## Prompt authoring contract

Write a role prompt in the following order. Follow [`references/prompt-authoring.md`](references/prompt-authoring.md) for the detailed template.

1. **Intent**: what the user counts as success, and as failure.
2. **Role as responsibility**: responsibility, judgment criteria, and forbidden actions rather than a role title.
3. **Scope / non-goals**: the read, modify, create, and external-action boundary, plus exclusions.
4. **Authority**: instruction priority, and the evidence boundary for tool, web, and retrieved content.
5. **Context packet**: source, date, trust grade, and missing information.
6. **Workflow**: explore, plan, execute, verify, report — or a task-specific decomposition.
7. **Output contract**: format, required fields, language, storage location.
8. **Verification**: which of smoke eval, source-check, deterministic assertion, or human review proves the pass.

## Instruction layers

| Layer | Example | Content | Principle |
|---|---|---|---|
| Project root | `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` | Shared project rules | Short and strong |
| Instructions base | `instructions/**` | Shared methodology, validation, sourcing | JIT-loaded as references |
| Runtime rules | `.cursor/rules`, Codex config, Claude memory | Per-tool behavioral differences | Minimize duplication |
| Skill/command | `skills/**/SKILL.md`, slash commands | Specific task workflows | Narrow and executable |
| Task prompt | The current user request | Latest priority and concrete requirements | Resolve conflicts with earlier rules explicitly |

## Criteria for a good instruction

- **Measurable**: give pass/fail criteria instead of "well."
- **Executable**: write it with verbs the agent can act on immediately.
- **Clearly scoped**: name the target directory, files, and artifact location.
- **Conflict-safe**: give stop conditions for destructive, external, or credential-gated actions.
- **Verifiable**: state which of lint, typecheck, test, eval, or source-check is the proof.
- **Model neutral**: keep vendor-specific features in a runtime profile only.

## Anti-patterns

| Anti-pattern | Problem | Replace with |
|---|---|---|
| Persona stacking | Adds tokens without real quality criteria | Translate the role into responsibility, scope, and verification criteria |
| Overusing CRITICAL | Dulls the importance signal | Emphasize only truly blocking rules |
| Listing every edge case | Wastes context and increases conflicts | Principle + representative example + verification loop |
| Hidden assumptions | Makes the agent over-conservative or over-eager | State scope and stop conditions |
| Hardcoding tool names | Fails on other runtimes | Express as a capability, e.g. "best available doc/fetch tool" |
| Improving prompts without verification | Looks better but can regress | Compare with a harness or eval cases |

## When to load references

| Need | Additional document |
|---|---|
| Per-runtime instruction file placement and priority | [`references/runtime-profiles.md`](references/runtime-profiles.md) |
| Role prompt template | [`references/prompt-authoring.md`](references/prompt-authoring.md) |
| Reasoning, few-shot, structured output, tool-use techniques | [`references/techniques.md`](references/techniques.md) |
| Abstraction level and context budget | [`references/core-principles.md`](references/core-principles.md) |
| Compaction, tool-result clearing, memory, and per-runtime context parameters | [`references/context-management.md`](references/context-management.md) |
| Parallel work and subagent delegation | [`references/parallel-workflows.md`](references/parallel-workflows.md) |
| Prompt/eval harness | [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md) |
| Repeated iteration, stop conditions, budgets, escalation | [`../loop-engineering/LOOP_ENGINEERING.md`](../loop-engineering/LOOP_ENGINEERING.md) |
| Fan-out and fan-in topology, joins, durable graph state | [`../graph-engineering/GRAPH_ENGINEERING.md`](../graph-engineering/GRAPH_ENGINEERING.md) |

## Sources

> Claims marked 2026-11-03 were re-read that day. Rows that still carry an older check date were not re-read in this revision and keep their date rather than inheriting a new one.

| Claim | Source | Checked |
|---|---|---|
| Context engineering as "curating and maintaining the optimal set of tokens," minimal-set sizing, right altitude, compaction, note-taking, and subagent compression | <https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> | 2026-11-03 (published 2025-09-29, revised 2026-10-18) |
| XML tags, long documents first, queries last, prefill unsupported from Claude 4.6 | <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices> | 2026-11-03 |
| Context editing and tool-result clearing parameters | <https://platform.claude.com/docs/en/build-with-claude/context-editing> | 2026-11-03 |
| Compaction modes and model exclusions | <https://platform.claude.com/docs/en/build-with-claude/compaction> | 2026-11-03 |
| Compaction via `context_management` / `compact_threshold` | <https://developers.openai.com/api/docs/guides/compaction> | 2026-11-03 |
| Six-level instruction hierarchy; untrusted data has "no authority by default" | <https://model-spec.openai.com/2026-10-29.html> | 2026-11-03 |
| Input length degrades performance across 18 models; distractors compound | <https://www.trychroma.com/research/context-rot> | 2026-11-03 (published 2025-07-14) |
| The four levers: write, select, compress, isolate | <https://www.langchain.com/blog/context-engineering-for-agents> | 2026-11-03 (published 2025-07-02) |
| Multi-agent token multipliers and shared-context limits | <https://www.anthropic.com/research/multi-agent-research-system> | 2026-11-03 (published 2025-06-13) |
| Codex instruction aggregation and AGENTS.md behavior | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> | 2026-07-29 |
| AGENTS.md format and nesting precedence ("the closest file wins; an explicit user chat prompt overrides everything"). Stewarded by the Agentic AI Foundation under the Linux Foundation | <https://agents.md/> | 2026-07-29 |
| Claude Code subagents / agent teams | <https://code.claude.com/docs/en/sub-agents>, <https://code.claude.com/docs/en/agent-teams> | 2026-07-29 |
| Google prompt design strategies (context first, instructions last, few-shot) | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/prompts/prompt-design-strategies?hl=en> | 2026-11-03 (updated 2026-10-30) |
| Cursor Rules (Always Apply / Apply Intelligently / Apply to Specific Files / Apply Manually), nested `AGENTS.md`, no documented Memories feature | <https://cursor.com/docs/rules> | 2026-11-03 |
| GitHub Copilot repository / path-specific (`applyTo`) / agent instructions and precedence (personal > repository > organization) | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 2026-07-29 |
| MCP security principles and the prompt/tool boundary. Clients **MUST** treat tool annotations as untrusted unless they come from a trusted server | <https://modelcontextprotocol.io/specification/2026-07-28> | 2026-09-19 |
| MCP `2026-07-28` breaking changes (stateless transition, `server/discover`, MRTR, Roots/Sampling/Logging deprecation) | <https://modelcontextprotocol.io/specification/2026-07-28/changelog> | 2026-09-19 |
| OpenAI evaluation guidance. The Evals platform is **deprecated** (read-only 2026-10-31, shutdown 2026-11-30; Datasets is the successor), while the agent-evals guidance is current | <https://developers.openai.com/api/docs/guides/evals>, <https://developers.openai.com/api/docs/guides/agent-evals> | 2026-07-29 |
| Anthropic success-criteria definition and eval construction | <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests> | 2026-07-29 |
| Google Vertex Gen AI evaluation adaptive rubrics | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/evaluation-overview?hl=en> | 2026-07-29 |
| LangSmith evaluation datasets/evaluators | <https://docs.langchain.com/langsmith/evaluation> | 2026-07-29 |
| Promptfoo LLM-as-a-judge / red teaming | <https://www.promptfoo.dev/docs/guides/llm-as-a-judge/>, <https://www.promptfoo.dev/docs/red-team/> | 2026-07-29 |

**Corrected**: an earlier revision of this table cited `ai.google.dev/gemini-api/docs/prompting-strategies` and listed Cursor "Memories" as an instruction surface. The Gemini API page now redirects through an auth endpoint when fetched without a session, so the Cloud prompt-design page is cited instead; the Cursor Rules page documents no Memories feature, so the runtime profile no longer claims one.

Local re-verification cache (untracked): `.hyper/research/2026-06-02-official-llm-prompt-instructions-update.md`, `.hyper/research/2026-07-29-instructions-base-source-refresh.md`. `.hyper/` is covered by `.gitignore` and does not exist in another clone. The URLs above are the evidence; the cache paths do not substitute for them.
