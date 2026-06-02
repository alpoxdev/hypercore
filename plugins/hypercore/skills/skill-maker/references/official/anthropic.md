# Anthropic Official References for Skill-Maker

## Refresh Policy
- last_verified_at: 2026-03-19
- refresh_when:
  - skill authoring guidance changes materially
  - prompt structuring guidance changes in ways that affect skill design
  - evaluation guidance changes in ways that affect skill validation
  - a core skill-maker rule cites Anthropic behavior more directly
- supports_rules:
  - `rules/trigger-design.md`
  - `rules/progressive-disclosure.md`
  - `rules/validation-and-iteration.md`

## Skill Authoring Best Practices
- source_url: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- last_verified_at: 2026-03-19
- applies_to: skill descriptions, progressive disclosure, validation, anti-patterns
- summary: Emphasizes concise descriptions, appropriate degrees of freedom, progressive disclosure, clear workflows, testing with realistic tasks, avoiding time-sensitive content, and keeping support files one level deep.
- implication_for_skill_maker: Make trigger wording, resource placement, and realistic validation first-class concerns.

## Prompt Engineering Overview
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
- last_verified_at: 2026-03-19
- applies_to: structured instructions and examples
- summary: Prompt quality improves with clear instructions, examples, structured context, and iteration.
- implication_for_skill_maker: Keep skill bodies structured and example-driven, but lean.

## Long Context Tips
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips
- last_verified_at: 2026-03-19
- applies_to: placement of detailed references
- summary: Long inputs need intentional ordering and structure.
- implication_for_skill_maker: Put large details in references and make their placement intentional.

## Define Success
- source_url: https://docs.anthropic.com/en/docs/test-and-evaluate/define-success
- last_verified_at: 2026-03-19
- applies_to: evaluations and iteration
- summary: Define success criteria and build an evaluation set before iterating.
- implication_for_skill_maker: Require trigger and usage validation rather than prose-only review.
