# OpenAI Official References for Skill-Maker

## Refresh Policy
- last_verified_at: 2026-03-19
- refresh_when:
  - skills guide changes materially
  - evaluation or state guidance changes in ways that affect skill validation
  - prompt engineering guidance changes in ways that affect trigger wording
  - a core skill-maker rule cites OpenAI behavior more directly
- supports_rules:
  - `rules/trigger-design.md`
  - `rules/validation-and-iteration.md`
  - `rules/progressive-disclosure.md`

## Skills Guide
- source_url: https://developers.openai.com/api/docs/guides/tools-skills
- last_verified_at: 2026-03-19
- applies_to: skills as agent behavior assets
- summary: Skills guide agent behavior, and local shell usage depends on correct skill file handling.
- implication_for_skill_maker: A skill must be designed as a triggerable asset, not just a text file.

## Prompt Engineering
- source_url: https://developers.openai.com/api/docs/guides/prompt-engineering
- last_verified_at: 2026-03-19
- applies_to: instruction clarity and examples
- summary: Clear instructions, examples, and explicit formatting improve followability.
- implication_for_skill_maker: Keep core skill instructions explicit and example-backed.

## Agent Builder
- source_url: https://developers.openai.com/api/docs/guides/agent-builder
- last_verified_at: 2026-03-19
- applies_to: system design with tools and guardrails
- summary: Agents are systems composed of instructions, tools, guardrails, and handoffs.
- implication_for_skill_maker: Skills should document the full operational surface when needed, not only prose guidance.

## Working with Evals
- source_url: https://developers.openai.com/api/docs/guides/evals
- last_verified_at: 2026-03-19
- applies_to: evaluation criteria
- summary: Evaluations need data sources and testing criteria or graders.
- implication_for_skill_maker: Skill validation should define observable trigger and usage checks.

## Conversation State and Compaction
- source_url: https://developers.openai.com/api/docs/guides/conversation-state
- last_verified_at: 2026-03-19
- applies_to: long-running skill-driven workflows
- summary: State and compaction are explicit system design choices.
- implication_for_skill_maker: Long or layered skills should make state and support-file placement legible.
