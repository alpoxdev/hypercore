# OpenAI Official References for Skill-Maker

## Refresh Policy

- last_verified_at: 2026-06-02
- refresh_when:
  - Codex skills guidance changes materially
  - AGENTS.md/custom instruction guidance changes materially
  - skill evaluation guidance changes in ways that affect validation rules
  - agent safety or tool-calling guidance changes in ways that affect skill safety gates
- supports_rules:
  - `rules/trigger-design.md`
  - `rules/progressive-disclosure.md`
  - `rules/resource-placement.md`
  - `rules/context-and-harness-alignment.md`
  - `rules/validation-and-iteration.md`

## Codex Agent Skills

- source_url: https://developers.openai.com/codex/skills
- last_verified_at: 2026-06-02
- applies_to: skill package shape, `name`/`description`, resources, scripts, progressive disclosure
- summary: Codex skills package instructions, resources, and optional scripts so Codex can reliably follow reusable workflows.
- implication_for_skill_maker: Treat skills as triggerable execution packages, not standalone prompt text.

## Evaluating Skills

- source_url: https://developers.openai.com/blog/eval-skills
- last_verified_at: 2026-06-02
- applies_to: trigger tests, process checks, output style checks, deterministic graders
- summary: Skill quality should be evaluated with small prompt sets and observable checks for trigger behavior, process adherence, output shape, and efficiency.
- implication_for_skill_maker: Require trigger smoke tests and validation notes instead of prose-only review.

## AGENTS.md Guide

- source_url: https://developers.openai.com/codex/guides/agents-md
- last_verified_at: 2026-06-02
- applies_to: project instruction discovery, scope, precedence, local guidance layering
- summary: Repository instructions define scoped guidance for agents and should be considered when operating inside a project.
- implication_for_skill_maker: Local `instructions/` and project rules outrank generic provider examples.

## Prompt Engineering

- source_url: https://developers.openai.com/api/docs/guides/prompt-engineering
- last_verified_at: 2026-06-02
- applies_to: clear instructions, examples, structured context, explicit output formats
- summary: Clear instructions, examples, and explicit formatting improve followability.
- implication_for_skill_maker: Core skill instructions should be explicit, example-backed, and contract-shaped.

## Evaluation Best Practices

- source_url: https://developers.openai.com/api/docs/guides/evaluation-best-practices
- last_verified_at: 2026-06-02
- applies_to: AI system variability, eval-backed iteration
- summary: Model behavior varies, so production-facing behavior needs evaluations rather than intuition.
- implication_for_skill_maker: Important skill changes should include at least a small eval or smoke set.

## Safety in Building Agents

- source_url: https://developers.openai.com/api/docs/guides/agent-builder-safety
- last_verified_at: 2026-06-02
- applies_to: prompt injection, tool calling, MCP/tool safety, side-effect gates
- summary: Agent systems need safeguards around untrusted input, tools, permissions, and side effects.
- implication_for_skill_maker: Skills that mention network, credentials, destructive actions, or production side effects must gate those actions explicitly.
