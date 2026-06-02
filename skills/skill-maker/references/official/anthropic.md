# Anthropic Official References for Skill-Maker

## Refresh Policy

- last_verified_at: 2026-06-02
- refresh_when:
  - Claude Code or Agent Skills guidance changes materially
  - skill anatomy, progressive disclosure, script, or validation guidance changes
  - core skill-maker rules cite Anthropic behavior more directly
- supports_rules:
  - `rules/skill-anatomy.md`
  - `rules/trigger-design.md`
  - `rules/progressive-disclosure.md`
  - `rules/resource-placement.md`
  - `rules/validation-and-iteration.md`

## Claude Code Skills

- source_url: https://code.claude.com/docs/en/skills
- last_verified_at: 2026-06-02
- applies_to: `SKILL.md`, frontmatter, supporting files, lifecycle, permissions
- summary: Claude Code skills use a folder with `SKILL.md` and optional supporting files to extend task-specific behavior.
- implication_for_skill_maker: Keep the core skill clear and route supporting detail to explicit files.

## Agent Skills Engineering Post

- source_url: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- last_verified_at: 2026-06-02
- applies_to: skill anatomy, progressive disclosure, scripts, eval-first iteration, trust boundary
- summary: Agent Skills are folders of instructions, scripts, and resources, loaded progressively from metadata to full instructions to referenced files and executable helpers.
- implication_for_skill_maker: Progressive disclosure, scripts with clear purpose, and source/resource trust checks are first-class rules.

## Claude Skills Product Post

- source_url: https://claude.com/blog/skills
- last_verified_at: 2026-06-02
- applies_to: portability, composability, scripts/resources as reusable capabilities
- summary: Skills are folders with instructions, scripts, and resources that make specialized workflows portable and composable.
- implication_for_skill_maker: Skills should be maintained as reusable packages rather than one-off prompts.
