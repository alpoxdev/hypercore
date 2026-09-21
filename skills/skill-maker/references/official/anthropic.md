# Anthropic Official References for Skill-Maker

## Contents

- Refresh Policy
- Claude Code Skills
- Skill Authoring Best Practices
- Skills for Enterprise
- Agent Skills Engineering Post
- Claude Skills Product Post
- Sources

## Refresh Policy

- last_verified_at: 2026-09-20
- refresh_when:
  - Claude Code or Agent Skills guidance changes materially
  - the frontmatter field table, the listing budget, or the spec-vs-extension split changes
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
- last_verified_at: 2026-09-20
- applies_to: `SKILL.md`, the full frontmatter surface, supporting files, invocation control, dynamic context injection, string substitution, the listing budget, discovery locations
- summary: Claude Code skills follow the Agent Skills open standard and extend it. **Claude Code reads
  the frontmatter only when the opening `---` is the file's first line**; otherwise it treats the whole
  file, `---` markers included, as skill content. The page documents twenty frontmatter fields, of which
  only six belong to the standard - `name`, `description`, `license`, `compatibility`, `metadata`,
  `allowed-tools`. The other fourteen are Claude Code extensions. On the claude.ai upload, Skills API,
  and `package_skill.py` distribution path, a field the spec does not allow is a **hard error** rather
  than a silently ignored key, and Claude Code-only body features such as dynamic context injection do
  not function there. Skills load from enterprise, personal, project, nested, `--add-dir`, plugin, and
  claude.ai-account locations; project skills come from `.claude/skills/` in the starting directory and
  every parent up to the repository root, while a nested `.claude/skills/` below the starting directory
  loads the first time Claude reads or edits a file in that subdirectory. `synced` is a reserved skill
  folder name in any capitalization and a skill authored at that name is skipped. A skill folder becomes
  a plugin by adding `.claude-plugin/plugin.json`.
- implication_for_skill_maker: separate the six standard fields from the fourteen extensions in the rule
  text, because a skill that mixes them is portable only to Claude Code. The first-line rule is already
  enforced by both repository gates, so it needs stating, not new tooling.

### Frontmatter fields as documented

Standard fields (portable): `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`.

Claude Code extensions: `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`,
`user-invocable`, `disallowed-tools`, `model`, `effort`, `context`, `agent`, `background`, `hooks`,
`paths`, `shell`.

| Field | Behaviour worth carrying into a rule |
|---|---|
| `description` | Combined with `when_to_use`, the text is truncated at **1,536 characters** in the skill listing. Put the key use case first |
| `when_to_use` | Extra trigger context, appended to `description` and counted against the same 1,536-character cap |
| `disable-model-invocation` | `true` stops Claude from loading the skill automatically, so only explicit invocation works. The Claude Code counterpart of Codex's `allow_implicit_invocation: false` |
| `user-invocable` | `false` hides the skill from the `/` menu so only Claude invokes it |
| `allowed-tools` | Tools Claude may use **without asking permission during the turn that invokes the skill**; the grant clears on the next message. A permissive grant, not a restrictive boundary |
| `disallowed-tools` | Tools removed from the pool while the skill is active; the restriction clears on the next message |
| `context` | Set to `fork` to run the skill in a forked subagent context, with `agent` choosing the subagent type and `background` controlling whether the turn waits |
| `paths` | Glob patterns that limit automatic activation to matching files |
| `shell` | Shell used for inline shell blocks; `bash` by default |
| `hooks` | Hooks registered when the skill is invoked and kept for the session |

### Body features

- **Dynamic context injection**: `` !`command` `` runs a command and replaces the line with its output
  before Claude sees the skill content. Claude Code-only; it does not function on the claude.ai or API path.
- **String substitutions**: `$ARGUMENTS`, `$ARGUMENTS[N]`/`$N`, named `$name` from the `arguments`
  list, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`,
  and, in plugin skills, `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_PLUGIN_DATA}`.
- `${CLAUDE_SKILL_DIR}` and `${CLAUDE_PROJECT_DIR}` are substituted in two places: the skill's markdown
  content and Bash rules in `allowed-tools`. Using the same variable in both lets a skill run a bundled
  script without a permission prompt - the documented pattern for shipping a script.

### The listing budget

- Claude Code loads a listing of skill names and descriptions into context. **The listing always
  contains every skill name, but when it overflows, Claude Code shortens descriptions to fit, starting
  with the skills you invoke least.** The budget scales at **1% of the model's context window**, and
  each entry's combined `description` + `when_to_use` text is capped at 1,536 characters regardless of
  budget. `skillListingBudgetFraction`, `SLASH_COMMAND_TOOL_CHAR_BUDGET`, and `skillListingMaxDescChars`
  change the budget, and `/doctor` estimates the listing's cost.
- implication_for_skill_maker: this is a second, tighter budget than Codex's 2%/8,000 characters, and it
  drops by usage frequency rather than by position. A skill that is rarely invoked is the first to lose
  its description, so the key trigger must lead.

## Skill Authoring Best Practices

- source_url: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- last_verified_at: 2026-09-20
- applies_to: frontmatter constraints Claude adds, naming, description voice, progressive disclosure patterns, reference-file structure, model coverage, degrees of freedom
- summary: Claude adds constraints on top of the standard: `name` cannot contain XML tags and cannot
  contain the reserved words **"anthropic"** or **"claude"**, and `description` cannot contain XML tags.
  Descriptions must be written in **third person** - the field is injected into the system prompt, and an
  inconsistent point of view causes discovery problems. Gerund-form names (verb + `-ing`) are the
  recommended convention, with noun phrases and action-oriented names acceptable and vague names such as
  `helper` or `utils` to avoid. Keep `SKILL.md` under 500 lines. Keep references **one level deep**,
  because Claude may partially read files referenced from other referenced files and preview them with
  `head -100` instead of reading them whole. **For reference files longer than 100 lines, include a
  table of contents at the top** so the full scope is visible even on a partial read. Test the skill on
  every model you plan to use, because "what works perfectly for Opus might need more detail for Haiku".
  Match specificity to fragility across three levels: high freedom (text instructions) when many
  approaches are valid, medium freedom (parameterised scripts) when a preferred pattern exists, and low
  freedom (an exact script, no parameters) when operations are fragile and consistency is critical.
- implication_for_skill_maker: the third-person rule, the reserved-word and XML-tag constraints, the
  gerund convention, and the >100-line table-of-contents rule are all checkable and belong in the rule
  text; the 500-line figure agrees with the specification.

## Skills for Enterprise

- source_url: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise
- last_verified_at: 2026-09-20
- applies_to: vetting a skill, the risk-tier table, evaluation dimensions including coexistence, version pinning
- summary: Vetting a skill means answering "is this safe" and "is this one safe". The risk-tier table
  lists seven indicators with a concern level: **code execution** (scripts in the skill directory run
  with full environment access - High), **instruction manipulation** (directives to ignore safety rules,
  hide actions, or alter behaviour conditionally - High), **MCP server references** (High), **network
  access patterns** (High), **hardcoded credentials** (High), **filesystem access scope** (Medium), and
  **tool invocations** (Medium). The review checklist adds verifying script behaviour against its stated
  purpose in a sandbox, checking for adversarial instructions, confirming redirect destinations, and
  verifying no data-exfiltration pattern. Evaluation is required before deployment across five
  dimensions, one of which is **coexistence: does adding this skill degrade other skills?** with the
  stated failure "new skill's description is too broad, stealing triggers from existing skills".
  Evaluation suites should hold 3-5 representative queries covering should-trigger, should-not-trigger,
  and ambiguous cases, tested across the models the organization uses. Skill installation is to be
  treated with the same rigor as installing software on production systems, and skills pinned to a
  version and re-reviewed when it changes.
- implication_for_skill_maker: the artifact audit must carry all seven risk rows, not a subset, and
  coexistence must be an evaluation dimension rather than an afterthought.

## Agent Skills Engineering Post

- source_url: https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
- last_verified_at: 2026-06-02
- recheck_status: not re-read in the 2026-09-20 pass - the date above is the last actual read
- applies_to: skill anatomy, progressive disclosure, scripts, eval-first iteration, trust boundary
- summary: Agent Skills are folders of instructions, scripts, and resources, loaded progressively from metadata to full instructions to referenced files and executable helpers.
- implication_for_skill_maker: Progressive disclosure, scripts with clear purpose, and source/resource trust checks are first-class rules.

## Claude Skills Product Post

- source_url: https://claude.com/blog/skills
- last_verified_at: 2026-06-02
- recheck_status: not re-read in the 2026-09-20 pass - the date above is the last actual read
- applies_to: portability, composability, scripts/resources as reusable capabilities
- summary: Skills are folders with instructions, scripts, and resources that make specialized workflows portable and composable.
- implication_for_skill_maker: Skills should be maintained as reusable packages rather than one-off prompts.

## Sources

> Links checked 2026-09-20. Next re-verification: 2026-10-29, matching the cadence in `instructions/README.md`.

| Claim | Source | Read in the 2026-09-20 pass |
|---|---|---|
| The twenty-field frontmatter table, the six standard fields, the hard error for non-spec fields on the claude.ai/API path, the first-line rule, discovery locations, the reserved `synced` name, `context: fork`, dynamic context injection, string substitutions, the `${CLAUDE_SKILL_DIR}`-in-`allowed-tools` pattern, and the 1% / 1,536-character listing budget with least-invoked-first dropping | <https://code.claude.com/docs/en/skills> | yes |
| The XML-tag and reserved-word constraints on `name`, the XML-tag constraint on `description`, third-person descriptions, the gerund convention, one-level-deep references and the partial-read reason, the >100-line table-of-contents rule, model-coverage testing, and the three degrees of freedom | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> | yes |
| The two required frontmatter fields and their Claude-specific constraints, and the three-level loading model with its token costs | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> | yes |
| The seven risk-tier rows with their concern levels, the review checklist, the five evaluation dimensions including coexistence, the 3-5 query suite, and version pinning | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> | yes |
| Skill anatomy, progressive disclosure, scripts, and the trust boundary | <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills> | no |
| Portability, composability, and skills as reusable packages | <https://claude.com/blog/skills> | no |

### Evidence grade

`VENDOR` - Anthropic's statements about its own products. Two rows above are carried forward unread from
the 2026-06-02 pass and are marked as such rather than given a refreshed date. The enterprise page's
severity labels are that page's assignment, not a controlled study's finding, so an audit against them
is a checklist that catches known artifact-level problems rather than a proof of safety.
