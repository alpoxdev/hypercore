# Skill Authoring

> Korean version: [`SKILL_AUTHORING.ko.md`](SKILL_AUTHORING.ko.md)
>
> Pinned snapshot: `skills/skill-maker/references/local/instructions-skill-authoring.md` keeps a pinned summary of `instructions/skill/**` (not a copy) so that skill stays self-contained; where the two disagree, this base wins. Refresh that summary deliberately when this base changes; nothing syncs it automatically.

This is the base document to read when creating or improving `skills/*`. Its purpose is to let you hand an AI a repeatable role and procedure by designing a skill as a **triggerable execution package** and a **verifiable small program**, not a plain prompt.

## Core definition

A skill is a folder-shaped execution contract for reliably performing a class of tasks. The minimum unit is `SKILL.md`, with `rules/`, `references/`, `scripts/`, `assets/`, and runtime-specific metadata added as needed.

A skill must satisfy all of the following at once.

| Axis | Question |
|---|---|
| Intent | Which repeated task does it perform better? |
| Trigger | On which user requests must it activate, and on which must it not? |
| Scope | Which files, actions, and artifacts does this skill own? |
| Authority | Which wins: user/project instructions, official docs, or an existing skill? |
| Workflow | In what order must the executor read, judge, and act? |
| Loop | Is iteration needed? If so, what are the metric/rubric, guard, and stop condition? |
| Resources | Which detailed knowledge, templates, and scripts should load only on demand? |
| Verification | How is it proven that the skill met trigger, execution, output, and safety criteria? |
| Stop condition | When does it switch to complete, abort, or ask the user? |

## Summary of official evidence

> All sources below were re-read on 2026-11-03. The Agent Skills pages carry no visible publication date; the page-embedded `dateModified` metadata is given where it exists. The OpenAI Codex skill documentation lives at `learn.chatgpt.com/docs/build-skills`; `developers.openai.com/codex/skills` still resolves only as a 308 redirect to that page, so the canonical URL is the one cited.

- The Agent Skills specification (page metadata `dateModified` 2026-08-04) requires only `name` (1-64 chars, lowercase alphanumerics and hyphens, no leading/trailing hyphen, no `--`, must match the folder name) and `description` (1-1024 chars). `license`, `compatibility` (1-500 chars), `metadata`, and `allowed-tools` (Experimental) are optional, and `scripts/`, `references/`, `assets/` are optional directories. <https://agentskills.io/specification>
- **Codex (checked 2026-11-03).** A skill packages instructions, resources, and optional scripts. Explicit invocation is `@` in ChatGPT and `/skills` or `$` in Codex CLI and the IDE extension; implicit invocation matches the `description`. The initial list is capped at **2% of the model context window, or 8,000 characters when the context window is unknown**, and `skills.max_context_tokens` raises it up to 10,000 tokens. Codex reads `.agents/skills` from `$CWD` up to the repository root, plus `$HOME/.agents/skills`, `/etc/codex/skills`, and bundled system skills; two skills with the same `name` are not merged; symlinked skill folders are followed; `[[skills.config]]` in `~/.codex/config.toml` disables a skill. `agents/openai.yaml` carries UI metadata, `policy.allow_implicit_invocation`, and tool dependencies. For distribution, OpenAI points to plugins. <https://learn.chatgpt.com/docs/build-skills>
- **Claude Code (checked 2026-11-03).** Skills load from `.claude/skills/` (enterprise, personal `~/.claude/skills/`, project, nested, `--add-dir`, plugin, claude.ai account) and are invoked as `/skill-name`; custom commands have been merged into skills. Frontmatter accepts many more fields than the spec, and the listing budget is **1% of the model context window**, with each entry's combined `description` + `when_to_use` capped at **1,536 characters**; when the listing overflows, Claude Code drops descriptions starting with the least-invoked skills. <https://code.claude.com/docs/en/skills>
- **Anthropic platform (checked 2026-11-03).** Metadata (~100 tokens per skill) is always loaded, the `SKILL.md` body loads on trigger and should stay **under 5k tokens**, and bundled files cost nothing until read. `name` additionally cannot contain XML tags or the reserved words `anthropic`/`claude`. Skills run in a filesystem sandbox; the API supports at most **20 skills per request** and gives them no network access. <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview>
- **Anthropic enterprise guidance (checked 2026-11-03).** Skills reach production through Git, the Skills API, plugins, or managed settings. Pin production skills to a version, treat every update as a new deployment with a full security review, keep the previous version as a rollback, and checksum reviewed skills at deploy time. Custom skills do not sync across surfaces (API, claude.ai, Claude Code). <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise>
- **Vercel `skills` CLI (checked 2026-11-03).** `npx skills` installs, finds, updates, and removes skills from one source format for roughly 80 coding agents — the README names OpenCode, Claude Code, Codex, Cursor, and "75 more"; project installs land in the agent's project directory, and many agents share `.agents/skills/` as the canonical project path (Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode, and others), with `~/.agents/skills/` as the shared global path. It requires Node.js 22.20 or later, and `npx skills init` scaffolds a skill. <https://github.com/vercel-labs/skills>
- **Skill value is not assumed (paper, 2026-03-16).** SWE-Skills-Bench measured 98 public skills on repository-pinned tasks with executable verifiers: 92 of 98 showed no statistically significant effect, and the average pass ratio moved only from 76.6% to 76.9%. The helpful skills supplied procedures the agent would otherwise omit (gains up to +17.7 points); the harmful ones anchored the agent on their own template and overrode the task's explicit instructions. <https://arxiv.org/abs/2603.15401>
- The OpenAI API Skills guide treats a skill as a versioned bundle compatible with the open Agent Skills standard, and warns that skills are privileged instructions and code because of prompt injection and exfiltration risk. <https://developers.openai.com/api/docs/guides/tools-skills>
- Anthropic's engineering note (published 2025-10-16) names progressive disclosure — metadata, then full instructions, then referenced files and scripts — as the core design principle, and warns to install skills only from trusted sources and to audit untrusted ones down to bundled files, dependencies, and outbound network calls. <https://www.anthropic.com/research/equipping-agents-for-the-real-world-with-agent-skills>
- OpenAI's skill eval guidance treats skill improvement like prompt quality improvement and checks four axes with small repeatable evals: **outcome (task completion), process (correct invocation and procedure), style (conventions and output format), and efficiency (finishing without unnecessary commands or tokens)**, starting from 10-20 prompts across explicit, implicit, contextual, and negative-control categories. <https://developers.openai.com/blog/eval-skills>
- Research lines such as ReAct, Self-Refine, Reflexion, Tree of Thoughts, OPRO, Promptbreeder, and DSPy/MIPRO support designing a skill as an observe/critique/score/iterate workflow rather than a "prompt written well once." Follow [`references/prompt-loop-eval.md`](references/prompt-loop-eval.md) for application detail.

## Base principles for this repository

1. **Local first**: a skill built in this project takes its primary evidence from `skills/`, `instructions/`, `scripts/`, and `README.md` inside the repository.
2. **Trigger first**: `description` states clearly up front *when to use it*, not what features it has.
3. **Contract first**: fix intent, scope, authority, evidence, output, verification, and stop condition before persona.
4. **Design it like a program**: separate inputs, material to read, work stages, tools, intermediate artifacts, final artifacts, and verification. A "re-runnable procedure" beats a "good prompt."
5. **Loops are conditional**: add an iteration loop only when feedback, metric/rubric, guard, and stop condition exist. Unbounded improvement, unlimited exploration, and self-grading-only loops are forbidden.
6. **Progressive disclosure**: keep `SKILL.md` thin; push recurring policy to `rules/`, detailed knowledge to `references/`, deterministic helpers to `scripts/`, and output templates and eval fixtures to `assets/`.
7. **Verification built in**: include trigger smoke tests, workflow trace checks, source grounding, safety cases, local link/fence checks, and an eval or readback checklist inside the skill itself.
8. **Safety boundary**: keep network, credential, destructive action, production side effect, and broad tool permission explicitly gated inside the skill.
9. **Korean output by default**: user-facing artifacts, reports, and verification notes in this repository default to Korean. Machine-readable fields and official keys keep their original form.
10. **Match specificity to fragility**: set the level of instruction detail to how easily the task breaks. Write brittle steps strictly; leave room for agent judgement where the task tolerates it. The earlier principles say *what goes where*; this one says *how strictly to write it*.
11. **Self-contained by default**: a skill ships whole. It must not require another skill's installation, invocation, path, or documents; when content from elsewhere is genuinely needed, bring it into the skill's own `references/` as a local snapshot. A user instruction is the only exception, and it is recorded.
12. **Portable core, documented extensions**: the six specification fields are the part every runtime understands. A runtime-only field may be added, but the skill must still work when that field is stripped, and the field's runtime is named where it is used.

The principles above that carry a normative id, in machine-readable form:

- SK-P-1: Match specificity to fragility — the level of instruction detail must match how easily the task breaks (principle 10).
- SK-P-2: Self-contained by default — a skill works from its own folder alone; a cross-skill reference exists only when the user explicitly asks for one, and that instruction is recorded (principle 11).
- SK-P-3: Portable core, documented extensions — the six spec fields carry the contract, and any runtime-only frontmatter is labelled with its runtime and must not be load-bearing (principle 12).

## Base folder structure

```text
skill-name/
├── SKILL.md                 # Required: metadata + core execution contract
├── SKILL.ko.md              # Recommended: Korean mirror
├── rules/                   # Recurring policy, workflow, verification criteria
├── references/              # Detailed knowledge and official doc summaries, loaded on demand
├── scripts/                 # Execution helpers needing repeatability and determinism
├── assets/                  # Templates, example artifacts, static resources
└── agents/                  # Runtime metadata only: e.g. Codex agents/openai.yaml
```

Read [`references/skill-anatomy.md`](references/skill-anatomy.md) for detailed structure rules.

## Minimum `SKILL.md` contract

The core file of a new skill must include every item below. The nine `instruction_contract` fields are the canonical set; any other document that sketches a prompt contract maps onto them rather than restating a shorter list.

```markdown
---
name: kebab-case-name
description: Use this skill when ...
compatibility: Optional runtime or dependency notes.
---

# Skill Name

<output_language>
...
</output_language>

<purpose>
...
</purpose>

<routing_rule>
...
</routing_rule>

<instruction_contract>
| Field | Contract |
|---|---|
| Intent | ... |
| Scope | ... |
| Authority | ... |
| Evidence | ... |
| Tools | ... |
| Loop | ... |
| Output | ... |
| Verification | ... |
| Stop condition | ... |
</instruction_contract>

<activation_examples>
Positive / Negative / Boundary examples
</activation_examples>

<workflow>
...
</workflow>

<validation>
...
</validation>
```

## Authoring workflow

| Stage | Work | Completion evidence |
|---|---|---|
| 0 | Decide whether the artifact is a general document or a skill | A "skill folder/refactor" scope decision |
| 1 | Collect the target task class and recurring failures | Real user sentences, local docs, observations of existing skills, known failures |
| 2 | Design the trigger | Positive/negative/boundary examples and a `description` draft |
| 3 | Write the prompt contract | The nine contract fields — intent, scope, authority, evidence, tools, loop, output, verification, and stop condition — are separated |
| 4 | Decide whether a loop is needed | Loop type, feedback source, guard, stop condition — or the reason for no loop |
| 5 | Split resources | rules/references/scripts/assets each have a justification and a load condition |
| 6 | Design verification | Trigger smoke set, workflow trace, source/safety cases, local links, script checks |
| 7 | Reconcile bilingual mirrors | Align structure with `*.ko.md` where needed |
| 8 | Handoff | Record changed files, verification results, and remaining risk |

## Prompt / loop / eval design

A skill author first decides "what small program is this skill?"

| Question | Where documented | Criterion |
|---|---|---|
| What are the inputs? | `SKILL.md` contract | Separate user request, files, sources, and tool output |
| Through which stages does it run? | `workflow` or `rules/` | Observable stages such as explore/plan/act/verify/report |
| Is iteration needed? | `Loop` contract or `rules/loop.md` | No loop without feedback and a stop condition |
| Is external evidence needed? | `Evidence`, source ledger, `references/official/` (recommended) or `references/local/` for pinned repository snapshots | Record source and accessed date for recency, vendor, and security claims |
| How are failures caught? | `validation`, `assets/evals/`, `scripts/` | Trigger, workflow, output, and safety regression cases |

Follow [`references/prompt-loop-eval.md`](references/prompt-loop-eval.md) for loop selection. In summary:

- When you must read external state and act, use a ReAct-style `observe -> act -> observe -> update` loop.
- When the artifact can be fixed against a rubric, use a Self-Refine-style `draft -> critique -> revise` loop.
- When learning from failures across a task class matters, use Reflexion-style postmortem memory, but verify that bad feedback does not accumulate.
- When alternative exploration is needed, use Tree-of-Thoughts-style branch/score/prune, but fix the branch count and the evaluator.
- To optimize a prompt, use OPRO/Promptbreeder/DSPy/MIPRO-style candidate comparison, but never adopt without a holdout and a regression set.

## When to add a support file

| Location | Add when | Do not add when |
|---|---|---|
| `rules/` | Policy, procedure, or verification criteria recurring across skill runs | One-off explanation, or pasted official documentation |
| `references/` | Detailed API, official doc summaries, edge cases, long examples, source/safety notes | Core trigger logic, required stop conditions |
| `scripts/` | The same parsing, validation, or generation logic must run reliably every time | The agent can handle it in one or two commands |
| `assets/` | Copy-or-fill targets such as templates, schemas, example artifacts, and eval fixtures | Reasoning-only explanation |
| `agents/` | Runtime metadata such as Codex `agents/openai.yaml`, or UI cards and dependency hints | As a substitute for core instructions |

Read [`references/resource-placement.md`](references/resource-placement.md) — that file is the **canonical** statement of placement criteria; this section is the summary.

## Trigger design rules

- Put the most important usage moment and keywords in the first sentence of `description`.
- Avoid generic descriptions such as "helps with X"; write in the form "Use when the user asks to...".
- Write in the third person. The description is injected into a system prompt, and a shifting point of view ("I can help you...") hurts selection.
- Split real user sentences into positive, negative, and boundary cases.
- Test both should-trigger and should-not-trigger.
- An overly broad skill produces false positives; an overly narrow one can cause several skills to load at once and conflict.

Read [`references/trigger-design.md`](references/trigger-design.md) — that file is the **canonical** statement of the trigger completion criteria; the checklist above does not restate them.

## Progressive disclosure rules

1. Discovery: assume the skill list carries only `name`, `description`, and path.
2. Activation: assume the whole `SKILL.md` loads only when the task matches.
3. Execution: design referenced files, scripts, and assets to be read or run only under stated conditions.

In short, keep only the always-needed material in `SKILL.md`. Split out detail together with "when to read it." Read [`references/progressive-disclosure.md`](references/progressive-disclosure.md) for detailed rules.

## Runtime differences that change the package

The folder format is shared; the surrounding machinery is not. Check these before claiming a skill is portable.

| Runtime | Discovery | What changes the package |
|---|---|---|
| Agent Skills spec | The client decides | Six frontmatter fields only; anything else is undefined behaviour |
| Claude Code | `.claude/skills/` at enterprise, personal, project, nested, added-directory, and plugin level | A large set of extra frontmatter and a 1%-of-context listing budget. claude.ai uploads and the Skills API reject non-spec fields with a hard error |
| Codex | `.agents/skills` from CWD to repo root, `$HOME/.agents/skills`, `/etc/codex/skills`, bundled | `agents/openai.yaml` for UI, invocation policy, and tool dependencies; `[[skills.config]]` and `[skills.bundled]` for enablement |
| Vercel `npx skills` | Writes each agent's own directory, with `.agents/skills/` shared by many | Nothing in the file itself; the install path differs per agent |

The exhaustive field list, the listing budgets, and the discovery order live in [`references/skill-anatomy.md`](references/skill-anatomy.md) §2 and [`references/progressive-disclosure.md`](references/progressive-disclosure.md) §7; this table exists so a reader notices the divergence before publishing.

Two consequences: keep the trigger and workflow readable from the six spec fields alone (SK-P-3), and state the runtime for every runtime-specific instruction so a reader on another client knows it does not apply.

## Judgement Rules

How a probabilistic check becomes a gate. These rules are normative; the `references/` files apply them.

- SK-J-1: Do not declare a trigger judgement from a single run. Run each query several times and compute a **trigger rate**.
- SK-J-2: The starting repetition count is **3 runs per query**.
- SK-J-3: A should-trigger query passes when its trigger rate is **above** the threshold; a should-not-trigger query passes when it is **below**. The default threshold is **0.5**.
- SK-J-4: Record the case count and the repetition count **together** — for example, 20 queries x 3 runs = 60 calls. A rate without its repetition count is not interpretable.
- SK-J-5: A trigger rate depends on the repetition count, so results produced under a different repetition count are not directly comparable to earlier results.
- SK-J-6: Do not record only per-case pass/fail. Keep the **distribution** of trigger rates: queries clustered near the threshold are the unstable points.

The values in `SK-J-2` and `SK-J-3` are source-stated and the source calls them a reasonable starting point and a reasonable default — not verified optima. Case files state their own `runs` and `threshold` rather than inheriting them, so the number is visible where it is used.

## Verification criteria

Minimum checks before completion:

- [ ] `name` is kebab-case and matches the folder name.
- [ ] `description` covers both what it does and when to use it.
- [ ] Trigger examples cover positive, negative, and boundary cases. Case counts are not fixed here — [`references/validation.md`](references/validation.md) owns the set composition and [`references/trigger-design.md`](references/trigger-design.md) owns how a case is judged.
- [ ] `instruction_contract` contains intent, scope, authority, evidence, tools, loop, output, verification, and stop condition.
- [ ] If a loop exists, it has a feedback source, metric/rubric, guard, and stop condition.
- [ ] Recency, vendor, paper, and security claims carry a source URL and an accessed or snapshot date.
- [ ] Boundaries exist for prompt injection, credentials, and destructive/network/production side effects.
- [ ] Support files are referenced directly from `SKILL.md` by relative path.
- [ ] If scripts exist, dependencies, usage, expected output, and failure handling are documented.
- [ ] Runtime-only frontmatter is labelled with its runtime and is not load-bearing (SK-P-3).
- [ ] Local markdown links and code fences are not broken.
- [ ] Verification results and remaining risk are recorded in the handoff.

Read [`references/validation.md`](references/validation.md) for the detailed verification loop. These criteria are the canonical statement of *what* must hold; how each one is checked lives in that file.

## Related documents

- [`../context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md)
- [`../context-engineering/references/prompt-authoring.md`](../context-engineering/references/prompt-authoring.md)
- [`references/prompt-loop-eval.md`](references/prompt-loop-eval.md)
- [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md)
- [`../sourcing/reliable-search.md`](../sourcing/reliable-search.md)
- [`../sourcing/references/retrieval-safety.md`](../sourcing/references/retrieval-safety.md)
- [`../validation/index.md`](../validation/index.md)

## Sources

> All links below were re-read and re-checked 2026-11-03. Publication dates are given where the source states one.

| Claim | Source |
|---|---|
| `name` and `description` constraints, the optional fields, and the three-stage progressive-disclosure budgets | <https://agentskills.io/specification> |
| "Match specificity to fragility" and the removal question behind principle 10 | <https://agentskills.io/skill-creation/best-practices> |
| **Trigger rate**, **3 runs**, **0.5** threshold, and the "reasonable starting point / reasonable default" hedge behind `SK-J-2` and `SK-J-3` | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| With/without baseline as the core eval pattern, and the per-run cost record | <https://agentskills.io/skill-creation/evaluating-skills> |
| The 2%-of-context / 8,000-character listing budget, `skills.max_context_tokens`, the `.agents/skills` walk, the user/admin/system scopes, non-merging of same-`name` skills, symlink following, `[[skills.config]]`, `agents/openai.yaml`, `/skills` and `$` invocation, and the plugin recommendation | <https://learn.chatgpt.com/docs/build-skills> |
| Skill locations, `/skill-name` invocation, the merged command format, the 1%-of-context listing budget, the 1,536-character per-entry cap, and the Claude Code frontmatter extension list | <https://code.claude.com/docs/en/skills> |
| ~100-token metadata, the 5k-token body guidance, and the reserved name words | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| The 20-skills-per-request API limit | <https://platform.claude.com/docs/en/build-with-claude/skills-guide> |
| Version pinning, re-review on update, rollback, checksums, and the no-cross-surface-sync warning | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> |
| The `npx skills` command set, the supported-agent count, the shared `.agents/skills/` project path, and the Node 22.20 requirement | <https://github.com/vercel-labs/skills> |
| The 92-of-98 no-effect result, the 76.6% to 76.9% average, and the helpful-versus-harmful skill failure modes | <https://arxiv.org/abs/2603.15401> |
| Skills as versioned bundles, and the prompt-injection/exfiltration warning | <https://developers.openai.com/api/docs/guides/tools-skills> |
| Progressive disclosure as the core design principle, and the untrusted-skill audit rule (published 2025-10-16) | <https://www.anthropic.com/research/equipping-agents-for-the-real-world-with-agent-skills> |
| Outcome/process/style/efficiency eval axes and the 10-20 prompt starting set | <https://developers.openai.com/blog/eval-skills> |

### Evidence grade

The trigger-judgement values are stated by the source as starting points, not verified optima. The runtime-specific facts are `VENDOR` claims reported by each vendor about its own product; they are labelled with the runtime rather than written as universal rules. SWE-Skills-Bench is a single 2026 benchmark whose findings are stated with its own statistical test, not a law about every skill.
