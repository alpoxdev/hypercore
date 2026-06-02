# Anthropic 공식 참고 자료

## 갱신 정책

- last_verified_at: 2026-06-02
- refresh_when:
  - Claude Code 또는 Agent Skills guidance가 실질적으로 바뀜
  - skill anatomy, progressive disclosure, script, validation guidance가 바뀜
  - core skill-maker rules가 Anthropic behavior를 더 직접적으로 인용하게 됨
- supports_rules:
  - `rules/skill-anatomy.ko.md`
  - `rules/trigger-design.ko.md`
  - `rules/progressive-disclosure.ko.md`
  - `rules/resource-placement.ko.md`
  - `rules/validation-and-iteration.ko.md`

## Claude Code Skills

- source_url: https://code.claude.com/docs/en/skills
- last_verified_at: 2026-06-02
- applies_to: `SKILL.md`, frontmatter, supporting files, lifecycle, permissions
- summary: Claude Code skills는 task-specific behavior를 확장하기 위해 `SKILL.md`와 optional supporting files가 있는 folder를 사용합니다.
- implication_for_skill_maker: Core skill은 명확하게 유지하고 supporting detail은 명시적 파일로 보냅니다.

## Agent Skills Engineering Post

- source_url: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- last_verified_at: 2026-06-02
- applies_to: skill anatomy, progressive disclosure, scripts, eval-first iteration, trust boundary
- summary: Agent Skills는 instructions, scripts, resources가 담긴 folders이며 metadata에서 full instructions, referenced files, executable helpers로 점진적으로 로드됩니다.
- implication_for_skill_maker: Progressive disclosure, clear purpose가 있는 scripts, source/resource trust checks를 1급 규칙으로 둡니다.

## Claude Skills Product Post

- source_url: https://claude.com/blog/skills
- last_verified_at: 2026-06-02
- applies_to: portability, composability, scripts/resources as reusable capabilities
- summary: Skills는 specialized workflows를 portable하고 composable하게 만드는 instructions, scripts, resources가 있는 folders입니다.
- implication_for_skill_maker: Skills는 one-off prompts가 아니라 reusable packages로 유지해야 합니다.
