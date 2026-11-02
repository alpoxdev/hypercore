# Skill Anatomy

> Korean version: [`skill-anatomy.ko.md`](skill-anatomy.ko.md)

Skill anatomy defines what responsibility each file carries, more than which files a skill must have.

## 1. Required and optional

| Element | Requirement | Responsibility |
|---|---|---|
| `SKILL.md` | Required | Metadata, trigger, core execution contract, workflow, validation |
| `SKILL.ko.md` | Recommended | Korean user-facing mirror |
| `rules/` | Conditional | Recurring policy, decision rules, checklists |
| `references/` | Conditional | Official doc summaries, detailed knowledge, edge cases, long examples |
| `scripts/` | Conditional | Deterministic helpers, validators, formatters, data transforms |
| `assets/` | Conditional | Templates, schemas, example artifacts, static resources |
| `agents/` | Conditional | Runtime metadata, such as Codex `agents/openai.yaml` (UI text, invocation policy, tool dependencies) |

## 2. Frontmatter

Base frontmatter:

```yaml
---
name: skill-name
description: Use this skill when the user asks to ...
compatibility: Optional runtime/dependency requirements.
---
```

### Spec fields and constraints

Per the Agent Skills specification (<https://agentskills.io/specification>, checked 2026-11-03).

| Field | Required | Constraint |
|---|---|---|
| `name` | Required | 1-64 chars. Lowercase `a-z`, digits, and hyphens only. Cannot start or end with a hyphen, and no consecutive hyphens (`--`). **Must match the parent directory name** |
| `description` | Required | 1-1024 chars. Covers both what it does and when to use it |
| `license` | Optional | A license name or a reference to a bundled license file. Keep it short |
| `compatibility` | Optional | 1-500 chars when present. Only when there are environment requirements such as intended product, system packages, or network access |
| `metadata` | Optional | A string key-value map for properties the spec does not define. Keep keys unique to avoid collisions |
| `allowed-tools` | Optional | A space-separated string of pre-approved tools. **Experimental — support varies between implementations** |

That is the whole list: six fields, two required. Anthropic's platform documentation adds two constraints the spec table does not spell out — `name` cannot contain XML tags or the reserved words `anthropic` and `claude`, and `description` cannot contain XML tags (<https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview>, checked 2026-11-03).

### Runtime extension fields

Runtimes accept more than the spec. These fields are `VENDOR` facts about specific products, so a skill must still work without them (see `SK-P-3` in [`../SKILL_AUTHORING.md`](../SKILL_AUTHORING.md)).

| Runtime | Field | Effect |
|---|---|---|
| Claude Code | `when_to_use` | Appended to `description` in the listing; counts toward the 1,536-character per-entry cap |
| Claude Code | `argument-hint`, `arguments` | Autocomplete hint and named positional `$name` substitution |
| Claude Code | `disable-model-invocation`, `user-invocable` | Turns off automatic or manual invocation respectively |
| Claude Code | `allowed-tools`, `disallowed-tools` | Adds or removes tools while the skill is active |
| Claude Code | `model`, `effort`, `context`, `agent`, `background` | Model/effort override for the turn; `context: fork` runs the skill in a subagent |
| Claude Code | `hooks` | Registers hooks for the rest of the session when the skill is invoked |
| Claude Code | `paths`, `shell`, `metadata`, `license`, `compatibility` | Path-glob activation limit, inline-shell choice, and fields the spec already defines |
| Codex | `agents/openai.yaml` (a file, not frontmatter) | `interface` text and icons, `policy.allow_implicit_invocation`, `dependencies.tools` |

The portability cost is real: claude.ai uploads and the Skills API **reject** any field outside the spec's six with a hard error, so a skill carrying runtime extensions cannot be uploaded there unchanged (<https://code.claude.com/docs/en/skills>, checked 2026-11-03).

### Progressive disclosure budgets

The budget figures are **not restated here**. [`progressive-disclosure.md`](progressive-disclosure.md) §5 is the canonical statement of the stage budgets and the 500-line / 5,000-token limits; read it there. This section owns only what is specific to frontmatter and file layout:

- **Codex** caps the initial list at 2% of the model context, or 8,000 characters when the context window is unknown, and `skills.max_context_tokens` raises the cap up to 10,000 tokens. When many skills are installed, Codex shortens descriptions first and **may omit some skills from the initial list entirely**, with a warning (<https://learn.chatgpt.com/docs/build-skills>, checked 2026-11-03). Put the key trigger up front.
- **Claude Code** scales the listing to 1% of the model's context window, caps each entry's combined `description` + `when_to_use` at 1,536 characters, and drops descriptions starting with the least-invoked skills when the listing overflows. `skillListingBudgetFraction`, `SLASH_COMMAND_TOOL_CHAR_BUDGET`, and `skillListingMaxDescChars` change those budgets (<https://code.claude.com/docs/en/skills>, checked 2026-11-03).

Neither runtime reports a truncated description as an error, so a skill that is present but has lost its keywords looks identical to a skill that never matched.

**Codex runtime discovery (reported 2026-11-03, `VENDOR`).** Codex reads `.agents/skills` in every directory from the current working directory up to the repository root, plus `$HOME/.agents/skills` (user), `/etc/codex/skills` (admin), and bundled system skills. When two skills share the same `name`, Codex does **not** merge them and both can appear in the selector. Symlinked skill folders are followed to their target. Setting `policy.allow_implicit_invocation` to `false` in `agents/openai.yaml` disables implicit invocation so only explicit `$skill` calls work, and `[[skills.config]]` in `~/.codex/config.toml` disables a skill by absolute `path` or by `name`. These are Codex behaviors, not universal rules.

### Rules

- Write `name` in lowercase kebab-case and **match the folder name** (a spec requirement, not a recommendation).
- `description` is a trigger sentence. Do not merely enumerate features.
- Use `compatibility` only when there are runtime, network, system package, or tool requirements. Most skills do not need it.
- `allowed-tools` is Experimental per the spec, so use it only after confirming support in that runtime, and do not enforce it as a shared rule. The Claude Code grant also clears when the next message is sent.
- Write file references as paths relative to the skill root and keep them **one level deep**. Do not build deeply nested reference chains.
- Keep runtime-only fields out of the portable core, and name the runtime beside every one you do use.

### Validation tool

The official reference implementation can machine-validate frontmatter and naming conventions.

```bash
skills-ref validate ./my-skill
```

This repository runs `skills-ref validate` through `uvx` across all of `skills/**/SKILL.md` from [`scripts/validate-skills.sh`](../../../scripts/validate-skills.sh). Claude Code ships a second check for its own trees, `claude plugin validate .claude/skills`, which reports `SKILL.md` files whose frontmatter does not parse.

## 3. Core body responsibility

Keep only the following in `SKILL.md`.

1. Output language / localization contract
2. Purpose
3. Routing rule
4. Instruction contract
5. Activation examples
6. High-level workflow
7. Support-file read order
8. Validation checklist
9. A summary of forbidden and required behavior

Long API detail, many examples, official documentation summaries, and per-environment options must stay out of the core body. The body is not free once loaded: Claude Code keeps an invoked skill's content in context across later turns and does not re-read the file, so every line is a recurring cost and the most important instruction belongs near the top (<https://code.claude.com/docs/en/skills>, checked 2026-11-03).

## 4. Rule files responsibility

`rules/` holds "procedural policy that always applies."

Good examples:

- Trigger design criteria
- Resource placement criteria
- Validation checklists
- Anti-patterns
- Rules deciding when to read provider-sensitive guidance

Bad examples:

- Verbatim copies of official documentation
- Repeating the same sentences as the core workflow
- Long examples needed by only one specific task

## 5. References responsibility

`references/` holds detailed knowledge read on demand.

Good examples:

- Summaries of OpenAI and Anthropic official documentation
- API schemas
- Per-framework edge cases
- Long examples
- A domain glossary

Rules:

- Keep each reference focused on one topic.
- Link it from `SKILL.md` together with "when to read it."
- Avoid deep chains where one reference sends you to another.

## 6. Scripts responsibility

Add `scripts/` only when code is more reliable than prose.

Criteria to add:

- The same transform or validation repeats.
- The command sequence is fragile.
- Structured output is required.
- The failure message lets the agent self-correct.

Required documentation:

- How to run it
- Dependencies
- Input and output
- Failure modes
- Version pinning or environment requirements

## 7. Assets responsibility

`assets/` holds copy-or-fill targets needed to produce the artifact.

Examples:

- Report templates
- Schema JSON
- Style guide samples
- Prompt templates
- Fixture data

Assets do not substitute for reasoning. Put their usage conditions and fill rules in `SKILL.md` or `rules/`.

## 8. Quality gate

- [ ] Reading `SKILL.md` alone conveys the purpose, trigger, and completion conditions.
- [ ] Detailed material is split out to load on demand.
- [ ] Support files are referenced directly by relative path.
- [ ] Scripts and assets have a clear reason to exist.
- [ ] Every runtime-only field is labelled, and the skill still reads correctly without it.
- [ ] Files needing a Korean mirror are structurally synchronized.

## Sources

> Links re-read and re-checked 2026-11-03.

| Claim | Source |
|---|---|
| The frontmatter field table and its constraints (including the 1-500 character `compatibility` range), and the three-stage disclosure model | <https://agentskills.io/specification> |
| The 5,000-token and 500-line instruction budgets | <https://agentskills.io/skill-creation/best-practices> |
| Reserved words and XML-tag restrictions on `name`/`description`, the ~100-token metadata figure, and the sandbox limits | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| The 2%-of-context / 8,000-character listing budget, `skills.max_context_tokens`, the `.agents/skills` walk, the user/admin/system scopes, non-merging of same-`name` skills, symlink following, `[[skills.config]]`, and `agents/openai.yaml` | <https://learn.chatgpt.com/docs/build-skills> |
| The 1%-of-context listing budget, the 1,536-character entry cap, the full frontmatter extension list, the hard error on non-spec fields, the in-context lifecycle, and `claude plugin validate` | <https://code.claude.com/docs/en/skills> |

### Evidence grade

The frontmatter constraints are `PRIMARY` — the specification states them. The `compatibility` range of 1-500 characters is now stated by the specification itself ("Must be 1-500 characters if provided"), so the earlier note about an unsourced lower bound is retired. The runtime extension tables and discovery behaviours are `VENDOR` claims reported by one product each and are written as such.
