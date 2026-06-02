# OpenAI Official References for Docs Maker

## Refresh Policy
- last_verified_at: 2026-03-19
- refresh_when:
  - model snapshot or versioning guidance changes
  - agent, eval, context, or tool guidance changes materially
  - canonical docs-maker rules need a new OpenAI-specific exception
  - a concrete model string or capability note becomes stale
  - a reviewer cannot map a canonical provider-sensitive claim to a source below
- maintenance_note: Keep concrete model strings and snapshot-specific examples here, not in canonical core rules.

## Prompt Engineering
- source_url: https://developers.openai.com/api/docs/guides/prompt-engineering
- last_verified_at: 2026-03-19
- applies_to: Prompt structure, developer messages, examples, Markdown/XML boundaries
- refresh_when: message-structure or prompting guidance changes materially
- summary: Recommends clear instructions, examples, structured message boundaries, and explicit formatting guidance.
- implication_for_docs_maker: Keep sectioning and explicit rule wording central to the skill.

## Agent Builder
- source_url: https://developers.openai.com/api/docs/guides/agent-builder
- last_verified_at: 2026-03-19
- applies_to: Agent architecture and tool-enabled systems
- refresh_when: agent-architecture or tool orchestration guidance changes
- summary: Treats agents as systems composed of instructions, tools, handoffs, and guardrails.
- implication_for_docs_maker: Expand from prompt-only guidance to full harness documentation.

## Safety in Building Agents
- source_url: https://developers.openai.com/api/docs/guides/agent-builder-safety
- last_verified_at: 2026-03-19
- applies_to: Prompt injection, MCP tool safety, approvals, guardrails, evals
- refresh_when: approval posture or safety guidance changes
- summary: Recommends human approval for sensitive MCP operations, input guardrails, and trace graders or evals for agent behavior.
- implication_for_docs_maker: Tool documentation must include approval and safety boundaries, not only capabilities.

## Working with Evals
- source_url: https://developers.openai.com/api/docs/guides/evals
- last_verified_at: 2026-03-19
- applies_to: Eval setup and grading
- refresh_when: grader or eval configuration guidance changes
- summary: Evals require a data source configuration and testing criteria or graders.
- implication_for_docs_maker: Eval guidance should define the dataset, grader, and acceptance threshold explicitly.

## Agent Evals
- source_url: https://developers.openai.com/api/docs/guides/agent-evals
- last_verified_at: 2026-03-19
- applies_to: Agent trajectory, tool-use, and goal-completion evaluation
- refresh_when: agent-eval scope or trajectory grading guidance changes
- summary: Agent workflows require evaluation of trajectories, tool behavior, and goal completion, not only final text output.
- implication_for_docs_maker: Harness docs should evaluate behavior across steps, not just final responses.

## Prompt Caching
- source_url: https://developers.openai.com/api/docs/guides/prompt-caching
- last_verified_at: 2026-03-19
- applies_to: Shared prompt prefixes and cache efficiency
- refresh_when: prompt-caching mechanics or strategy changes
- summary: Stable repeated content should be placed early to maximize caching benefits.
- implication_for_docs_maker: Context layout rules should separate static shared prefix content from variable inputs.

## Conversation State
- source_url: https://developers.openai.com/api/docs/guides/conversation-state
- last_verified_at: 2026-03-19
- applies_to: Multi-turn applications and agent state management
- refresh_when: state persistence model or retained artifact guidance changes
- summary: Conversation state is a deliberate design concern and includes messages, tool calls, and tool outputs.
- implication_for_docs_maker: Harness docs should state what persists between turns and what belongs to transient task state.

## Compaction
- source_url: https://developers.openai.com/api/docs/guides/compaction
- last_verified_at: 2026-03-19
- applies_to: Long-running context management
- refresh_when: compaction behavior or retained-constraint guidance changes
- summary: Compaction should preserve active plans and critical constraints while summarizing completed work.
- implication_for_docs_maker: Require explicit state-retention policies in long-running harness documentation.

## Prompt Optimizer
- source_url: https://developers.openai.com/api/docs/guides/prompt-optimizer
- last_verified_at: 2026-03-19
- applies_to: Prompt iteration workflow
- refresh_when: optimizer workflow or iteration guidance changes
- summary: Prompts can be iterated systematically rather than edited ad hoc.
- implication_for_docs_maker: Encourage prompt assets, versioned iteration, and validation loops.

## GPT-5 Model Docs
- source_url: https://developers.openai.com/api/docs/models/gpt-5
- last_verified_at: 2026-03-19
- applies_to: Model behavior, tools support, snapshots
- refresh_when: snapshot or model behavior guidance changes
- summary: Snapshots can lock a specific model version so behavior remains consistent.
- implication_for_docs_maker: Canonical docs should describe capability profiles and mention version pinning strategy without hard-coding model names into core rules.

## 2026-06-02 Prompt Authoring Refresh

### Prompting
- source_url: https://platform.openai.com/docs/guides/prompting
- last_verified_at: 2026-06-02
- applies_to: prompt assets, reusable prompts, variables, prompt versioning, linked evals
- refresh_when: prompt asset/versioning or linked-eval workflow changes
- summary: Treats prompts as versioned assets that can use variables and linked evals so changes can be rerun against test criteria.
- implication_for_docs_maker: Docs should describe prompt artifacts as maintainable assets with explicit inputs, versions, and validation paths.

### Prompt Engineering
- source_url: https://platform.openai.com/docs/guides/prompt-engineering
- last_verified_at: 2026-06-02
- applies_to: roles, instruction structure, examples, delimiters, context blocks, output contracts
- refresh_when: official guidance changes for roles, message structure, or model-specific prompting
- summary: Emphasizes clear instructions, structured sections, examples, relevant context, and output-format guidance.
- implication_for_docs_maker: Role prompts should be written as explicit contracts with intent, scope, authority, context, output, and verification.

### Reasoning Best Practices
- source_url: https://platform.openai.com/docs/guides/reasoning-best-practices
- last_verified_at: 2026-06-02
- applies_to: reasoning-model prompts and rationale reporting
- refresh_when: reasoning-model prompting guidance changes
- summary: Reasoning-oriented prompts should be direct and specific; do not rely on generic chain-of-thought incantations when clearer goals and constraints are available.
- implication_for_docs_maker: Ask for decision evidence, test results, and concise rationale rather than hidden chain-of-thought text.

### Prompt Optimizer
- source_url: https://platform.openai.com/docs/guides/prompt-optimizer
- last_verified_at: 2026-06-02
- applies_to: prompt iteration, datasets, annotations, graders, optimization review
- refresh_when: prompt optimizer or grader workflow changes
- summary: Prompt optimization should be grounded in datasets, annotations, graders, and manual review before production use.
- implication_for_docs_maker: Prompt improvement guidance must include smoke evals or regression cases, not only better-looking prose.
