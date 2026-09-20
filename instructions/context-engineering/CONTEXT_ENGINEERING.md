# Context Engineering

Standards for designing instruction, context, tools, memory, and validation so that multiple agent runtimes — Codex, Claude Code, Cursor, GitHub Copilot, and others — work toward the same intent.

> Korean version: [`CONTEXT_ENGINEERING.ko.md`](CONTEXT_ENGINEERING.ko.md)

## Core definition

Context engineering is not "dressing up a prompt with nice sentences." It is designing the **goal, scope, evidence, tools, constraints, and verification criteria** the model receives as an executable system. A role prompt is subject to the same rule: it is not a persona declaration but a contract of success criteria and verifiable behavior the role is accountable for.

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

XML tags are particularly useful with Claude models, but the point is **section separation**, not XML itself. In Codex/AGENTS.md, Cursor Rules, and Copilot instructions the same structure can be expressed with Markdown headings and tables.

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
| Parallel work and subagent delegation | [`references/parallel-workflows.md`](references/parallel-workflows.md) |
| Prompt/eval harness | [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md) |

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-19. Next re-verification 2026-10-29.

| Claim | Source |
|---|---|
| Codex instruction aggregation and AGENTS.md behavior | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> |
| AGENTS.md format and nesting precedence ("the closest file wins; an explicit user chat prompt overrides everything"). Stewarded by the Agentic AI Foundation under the Linux Foundation | <https://agents.md/> |
| Anthropic prompt engineering and structuring prompts with XML tags | <https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices> |
| Claude Code subagents / agent teams | <https://code.claude.com/docs/en/sub-agents>, <https://code.claude.com/docs/en/agent-teams> |
| Google Gemini prompt design strategies | <https://ai.google.dev/gemini-api/docs/prompting-strategies> |
| Cursor Rules (Always Apply / Apply Intelligently / Apply to Specific Files / Apply Manually) and nested AGENTS.md support | <https://cursor.com/docs/rules> |
| GitHub Copilot repository / path-specific (`applyTo`) / agent instructions and precedence (personal > repository > organization) | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> |
| MCP security principles and the prompt/tool boundary. Clients **MUST** treat tool annotations as untrusted unless they come from a trusted server | <https://modelcontextprotocol.io/specification/2026-07-28> |
| MCP `2026-07-28` breaking changes (stateless transition, `server/discover`, MRTR, Roots/Sampling/Logging deprecation) | <https://modelcontextprotocol.io/specification/2026-07-28/changelog> |
| OpenAI evaluation guidance. The Evals platform is **deprecated** (read-only 2026-10-31, shutdown 2026-11-30; Datasets is the successor), while the agent-evals guidance is current | <https://developers.openai.com/api/docs/guides/evals>, <https://developers.openai.com/api/docs/guides/agent-evals> |
| Anthropic success-criteria definition and eval construction | <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests> |
| Google Vertex Gen AI evaluation adaptive rubrics | <https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/evaluation-overview> |
| LangSmith evaluation datasets/evaluators | <https://docs.langchain.com/langsmith/evaluation> |
| Promptfoo LLM-as-a-judge / red teaming | <https://www.promptfoo.dev/docs/guides/llm-as-a-judge/>, <https://www.promptfoo.dev/docs/red-team/> |

**Unconfirmed**: the Cursor "Memories" feature cited by an earlier revision was not found in the current Rules documentation as of 2026-07-29. It may live in a separate document, so this is recorded as **unconfirmed** rather than absent. This document makes no claim resting on Memories.

Local re-verification cache (untracked): `.hyper/research/2026-06-02-official-llm-prompt-instructions-update.md`, `.hyper/research/2026-07-29-instructions-base-source-refresh.md`. `.hyper/` is covered by `.gitignore` and does not exist in another clone. The URLs above are the evidence; the cache paths do not substitute for them.
