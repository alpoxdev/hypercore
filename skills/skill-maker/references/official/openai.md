# OpenAI Official References for Skill-Maker

## Contents

- Refresh Policy
- Codex Agent Skills
- Codex Skill Discovery and Distribution
- Evaluating Skills
- AGENTS.md Guide
- Prompt Engineering
- Evaluation Best Practices
- Safety in Building Agents
- Sources

## Refresh Policy

- last_verified_at: 2026-09-20
- refresh_when:
  - Codex skills guidance changes materially
  - Codex skill discovery locations, the listing budget, or `agents/openai.yaml` change
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

- source_url: https://learn.chatgpt.com/docs/build-skills
- last_verified_at: 2026-09-20
- applies_to: skill package shape, `name`/`description`, resources, scripts, progressive disclosure, the listing budget
- summary: A skill is a directory with a `SKILL.md` file plus optional scripts, references, and assets,
  and it must include `name` and `description`. ChatGPT and Codex start from each skill's name and
  description and load the full `SKILL.md` only when they decide to use it. In Codex the initial list
  also includes each skill's file path, and that list uses **at most 2% of the model's context window,
  or 8,000 characters when the context window is unknown**. If many skills are installed, Codex
  **shortens skill descriptions first**, and for large skill sets it **may omit some skills from the
  initial list entirely and show a warning**. The budget applies only to the initial list; the full
  `SKILL.md` is still read once the skill is selected.
- implication_for_skill_maker: the failure mode is not only a truncated description but a skill that
  never appears, so the key trigger must lead the description and the description must stay short. This
  repository's 38 descriptions already total 14,641 characters, so the Codex budget is exceeded today
  and any growth makes it worse.

## Codex Skill Discovery and Distribution

- source_url: https://learn.chatgpt.com/docs/build-skills
- last_verified_at: 2026-09-20
- applies_to: where Codex finds skills, how to disable one, UI metadata, invocation policy, distribution
- summary: Codex reads skills from repository, user, admin, and system locations. For repositories it
  scans `.agents/skills` in every directory from the current working directory up to the repository
  root: `$CWD/.agents/skills`, `$CWD/../.agents/skills`, and `$REPO_ROOT/.agents/skills`. The user
  location is `$HOME/.agents/skills` and the admin location is `/etc/codex/skills`; system skills are
  bundled by OpenAI. **If two skills share the same `name`, Codex does not merge them; both can appear
  in skill selectors.** Codex supports symlinked skill folders and follows the symlink target when
  scanning these locations. A skill is disabled without deletion through `[[skills.config]]` entries
  with `enabled = false` in `~/.codex/config.toml`, followed by a Codex restart. `agents/openai.yaml`
  configures UI metadata in the ChatGPT desktop app, sets the invocation policy, and declares tool
  dependencies: an `interface` block (`display_name`, `short_description`, `icon_small`,
  `icon_large`, `brand_color`, `default_prompt`), a `policy` block with `allow_implicit_invocation`
  (default `true`; when `false`, Codex will not invoke the skill implicitly while explicit `$skill`
  invocation still works), and a `dependencies.tools` list. For distribution beyond one repository,
  OpenAI documents **plugins** as the path, not raw skill folders. `$skill-installer` adds curated
  skills locally and `$skill-creator` walks a new skill through creation; Record & Replay drafts a
  reusable skill from a demonstrated workflow.
- implication_for_skill_maker: a "reusable Codex skill folder" is only half the story. State the
  discovery locations, note that the `.agents/skills` convention is shared with other runtimes rather
  than Codex-specific, and treat plugins as the documented distribution path. `allow_implicit_invocation:
  false` is the Codex equivalent of restricting a skill to explicit invocation.

## Evaluating Skills

- source_url: https://developers.openai.com/blog/eval-skills
- last_verified_at: 2026-09-20
- applies_to: trigger tests, process checks, output style checks, deterministic graders, the prompt-set size
- summary: Skill quality should be evaluated with small prompt sets and observable checks across four
  axes - **outcome (task completion), process (correct invocation and procedure), style (adherence to
  conventions and output format), and efficiency (finishing without unnecessary commands or tokens)**.
  It recommends starting with a small set of 10-20 prompts covering explicit, implicit, contextual, and
  negative-control invocations, and growing it from real failures. Manual triggering is the first pass
  that surfaces hidden assumptions; `codex exec` makes runs repeatable and streams progress to stderr
  with only the final result on stdout.
- implication_for_skill_maker: the four axes and the invocation-mode split are the load-bearing parts;
  keep the case count as a starting recommendation rather than a validated optimum.

## AGENTS.md Guide

- source_url: https://learn.chatgpt.com/docs/agent-configuration/agents-md
- last_verified_at: 2026-06-02
- recheck_status: not re-read in the 2026-09-20 pass - the date above is the last actual read
- applies_to: project instruction discovery, scope, precedence, local guidance layering
- summary: Repository instructions define scoped guidance for agents and should be considered when operating inside a project.
- implication_for_skill_maker: Local `instructions/` and project rules outrank generic provider examples.

## Prompt Engineering

- source_url: https://developers.openai.com/api/docs/guides/prompt-engineering
- last_verified_at: 2026-06-02
- recheck_status: not re-read in the 2026-09-20 pass - the date above is the last actual read
- applies_to: clear instructions, examples, structured context, explicit output formats
- summary: Clear instructions, examples, and explicit formatting improve followability.
- implication_for_skill_maker: Core skill instructions should be explicit, example-backed, and contract-shaped.

## Evaluation Best Practices

- source_url: https://developers.openai.com/api/docs/guides/evaluation-best-practices
- last_verified_at: 2026-06-02
- recheck_status: not re-read in the 2026-09-20 pass - the date above is the last actual read
- applies_to: AI system variability, eval-backed iteration
- summary: Model behavior varies, so production-facing behavior needs evaluations rather than intuition.
- implication_for_skill_maker: Important skill changes should include at least a small eval or smoke set.

## Safety in Building Agents

- source_url: https://developers.openai.com/api/docs/guides/agent-builder-safety
- last_verified_at: 2026-06-02
- recheck_status: not re-read in the 2026-09-20 pass - the date above is the last actual read
- applies_to: prompt injection, tool calling, MCP/tool safety, side-effect gates
- summary: Agent systems need safeguards around untrusted input, tools, permissions, and side effects.
- implication_for_skill_maker: Skills that mention network, credentials, destructive actions, or production side effects must gate those actions explicitly.

## Sources

> Links checked 2026-09-20. Next re-verification: 2026-10-29, matching the cadence in `instructions/README.md`.

| Claim | Source | Read in the 2026-09-20 pass |
|---|---|---|
| Skill package shape, required `name`/`description`, progressive loading, the 2% / 8,000-character listing budget, shorten-then-omit, and the four invocation/evaluation axes | <https://learn.chatgpt.com/docs/build-skills> | yes |
| The six discovery locations, same-`name` non-merge, symlinked skill folders, `[[skills.config]]`, `agents/openai.yaml` including `allow_implicit_invocation`, plugins as the distribution path, `$skill-installer`, `$skill-creator`, Record & Replay | <https://learn.chatgpt.com/docs/build-skills> | yes |
| The four evaluation axes, the 10-20 prompt starting set, manual triggering first, and `codex exec` for repeatable runs | <https://developers.openai.com/blog/eval-skills> | yes |
| AGENTS.md discovery and precedence | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> | no |
| Clear instructions, examples, and explicit output formats | <https://developers.openai.com/api/docs/guides/prompt-engineering> | no |
| Model variability and eval-backed iteration | <https://developers.openai.com/api/docs/guides/evaluation-best-practices> | no |
| Prompt injection, tool-calling, and side-effect safeguards | <https://developers.openai.com/api/docs/guides/agent-builder-safety> | no |

### Evidence grade

`VENDOR` - these are OpenAI's statements about OpenAI's own products. A vendor statement about its
own loading mechanics (discovery locations, size caps, invocation policy) is a fact about that product;
the same vendor's statement about what makes a skill good is a heuristic. Four rows above are carried
forward unread from the 2026-06-02 pass and are marked as such rather than given a refreshed date.
