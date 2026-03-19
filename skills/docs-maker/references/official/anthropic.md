# Anthropic Official References for Docs Maker

## Refresh Policy
- last_verified_at: 2026-03-19
- refresh_when:
  - migration guidance changes
  - prompt/tool/context behavior changes materially
  - canonical docs-maker rules need a new Anthropic-specific exception
  - a concrete model string or capability note becomes stale
  - an architect or reviewer cannot map a canonical provider-sensitive claim to a source below
- maintenance_note: Keep concrete model strings and migration-specific examples here, not in canonical core rules.

## Prompting Best Practices
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags
- last_verified_at: 2026-03-19
- applies_to: Anthropic prompt engineering, tool use, long-context prompting, adaptive thinking behavior
- refresh_when: prompt/tool behavior guidance changes materially
- summary: Recommends clear/direct instructions, examples, XML tags, explicit tool guidance, careful use of parallel tool calls, and tuning prompts to avoid over-triggering or over-engineering.
- implication_for_docs_maker: Keep canonical rules explicit and structured, but avoid hard-coding model-specific steering into the core skill.

## Prompt Engineering Overview
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
- last_verified_at: 2026-03-19
- applies_to: General prompt engineering workflow
- refresh_when: prompt workflow guidance changes materially
- summary: Frames prompt engineering as iterative work supported by examples, system prompts, XML tags, and evaluation.
- implication_for_docs_maker: Preserve structure, examples, and validation as first-class parts of the skill.

## Prompt Templates and Variables
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/prompt-templates-and-variables
- last_verified_at: 2026-03-19
- applies_to: Prompt asset templating
- refresh_when: template or variables support changes
- summary: Encourages reusable prompt templates and parameterized variables for testing and maintenance.
- implication_for_docs_maker: Treat prompts as reusable assets rather than single-use prose blocks.

## Long Context Tips
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips
- last_verified_at: 2026-03-19
- applies_to: Long document prompts
- refresh_when: long-context ordering guidance changes
- summary: Recommends placing long-form data near the top, putting the query later, and structuring multi-document input with XML tags and quote-grounding.
- implication_for_docs_maker: Add explicit context layout rules when documenting long-context harnesses.

## Define Success
- source_url: https://docs.anthropic.com/en/docs/test-and-evaluate/define-success
- last_verified_at: 2026-03-19
- applies_to: Evaluation planning
- refresh_when: eval setup or success-criteria guidance changes
- summary: Recommends defining success criteria and building a minimum viable evaluation set before iterating.
- implication_for_docs_maker: Do not document prompt iteration without eval criteria and a test set.

## Context Windows
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/context-windows
- last_verified_at: 2026-03-19
- applies_to: Context sizing and limits
- refresh_when: context-window or sizing guidance changes
- summary: Treats context size as a managed resource rather than an excuse for unstructured accumulation.
- implication_for_docs_maker: Keep compaction and state retention policies explicit in long-running harness docs.

## Compaction
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/compaction
- last_verified_at: 2026-03-19
- applies_to: Long-running conversations and agents
- refresh_when: compaction strategy or agent-state guidance changes
- summary: Compaction is a first-class context-management concern.
- implication_for_docs_maker: Separate canonical rules from compactable task state and note what must survive summarization.

## Prompt Caching
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching
- last_verified_at: 2026-03-19
- applies_to: Reusable prompt prefixes
- refresh_when: prompt caching mechanics or strategy changes
- summary: Stable prefixes and cache breakpoints matter for efficiency and repeatability.
- implication_for_docs_maker: Include cache-aware prompt layout when the harness repeatedly reuses shared context.

## Agent Skills Best Practices
- source_url: https://docs.anthropic.com/en/docs/build-with-claude/agent-skills/best-practices
- last_verified_at: 2026-03-19
- applies_to: Skill and agent guidance design
- refresh_when: agent-skill packaging or contract guidance changes
- summary: Skills benefit from clear scope boundaries, explicit contracts, and compact reusable guidance.
- implication_for_docs_maker: Keep skill bodies compact and push specialized detail into rules and references.

## Migration Guide
- source_url: https://docs.anthropic.com/en/docs/about-claude/models/migration-guide
- last_verified_at: 2026-03-19
- applies_to: Model changes and compatibility drift
- refresh_when: new model family releases or migration notices appear
- summary: Model names and model behavior change over time and require migration-aware updates.
- implication_for_docs_maker: Ban fixed model literals from canonical core guidance and keep concrete model strings in dated provider references only.
