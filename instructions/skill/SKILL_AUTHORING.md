# Skill Authoring

> Korean version: [`SKILL_AUTHORING.ko.md`](SKILL_AUTHORING.ko.md)

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

> Sources below were checked on 2026-07-29; their link resolution was re-checked on 2026-09-19. The OpenAI Codex skill documentation moved from `developers.openai.com/codex/skills` to `learn.chatgpt.com/docs/build-skills`.

- OpenAI Codex describes a skill as a reusable authoring format bundling instructions, resources, and optional scripts so Codex follows a workflow reliably. Skills are discovered in order: repository `.agents/skills`, user `$HOME/.agents/skills`, admin `/etc/codex/skills`, then bundled. Invocation is `@skill-name` in ChatGPT and `$skill-name` in Codex/IDE. At the listing stage only name and description load, budgeted at 2% of context or 8,000 characters. <https://learn.chatgpt.com/docs/build-skills>
- The OpenAI API Skills guide describes a skill as a versioned bundle compatible with the open Agent Skills standard, and warns that skills must be treated as privileged instructions and code because of prompt injection and exfiltration risk. <https://developers.openai.com/api/docs/guides/tools-skills>
- The OpenAI agent eval guide says to start agent workflow verification with trace grading and expand to datasets and eval runs when repeatability is needed. <https://developers.openai.com/api/docs/guides/agent-evals>
- Anthropic treats Agent Skills as a folder holding `SKILL.md`, scripts, and resources, and names progressive disclosure — metadata, then full instructions, then referenced files and scripts — as the core design principle. It warns to install skills only from trusted sources and to audit untrusted skills down to bundled files, dependencies, and outbound network connections. (Published 2025-10-16) <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills>
- Anthropic's prompt/eval documentation recommends defining success criteria and evaluations before improving a prompt. <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>
- The Agent Skills specification defines `name` and `description` as required frontmatter, with `license`, `compatibility`, `metadata`, and `allowed-tools` (Experimental) as optional fields, and `scripts/`, `references/`, and `assets/` as optional directories. Follow [`references/skill-anatomy.md`](references/skill-anatomy.md) for length limits and progressive disclosure budgets. <https://agentskills.io/specification>
- Research lines such as ReAct, Self-Refine, Reflexion, Tree of Thoughts, OPRO, Promptbreeder, and DSPy/MIPRO support designing a skill as an observe/critique/score/iterate workflow rather than a "prompt written well once." Follow [`references/prompt-loop-eval.md`](references/prompt-loop-eval.md) for application detail.
- OpenAI's skill eval guide treats skill improvement like prompt quality improvement and recommends checking four axes with small repeatable evals: **outcome (task completion), process (correct invocation and procedure), style (adherence to conventions and output format), and efficiency (finishing without unnecessary commands or tokens)**. Start the dataset at 10-20 prompts covering four categories: explicit, implicit, contextual, and negative control. <https://developers.openai.com/blog/eval-skills>

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

## Base folder structure

```text
skill-name/
├── SKILL.md                 # Required: metadata + core execution contract
├── SKILL.ko.md              # Recommended: Korean mirror
├── rules/                   # Recurring policy, workflow, verification criteria
├── references/              # Detailed knowledge and official doc summaries, loaded on demand
├── scripts/                 # Execution helpers needing repeatability and determinism
├── assets/                  # Templates, example artifacts, static resources
└── agents/                  # Only when runtime/UI metadata is needed
```

Read [`references/skill-anatomy.md`](references/skill-anatomy.md) for detailed structure rules.

## Minimum `SKILL.md` contract

The core file of a new skill must include every item below.

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
| 3 | Write the prompt contract | Intent, scope, authority, context, workflow, output, and verification are separated |
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
| Is external evidence needed? | `Evidence`, `references/official/`, source ledger | Record source and accessed date for recency, vendor, and security claims |
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
| `agents/` | UI cards, OpenAI/vendor metadata, or dependency hints are needed | As a substitute for core instructions |

Read [`references/resource-placement.md`](references/resource-placement.md) for detailed placement rules.

## Trigger design rules

- Put the most important usage moment and keywords in the first sentence of `description`.
- Avoid generic descriptions such as "helps with X"; write in the form "Use when the user asks to...".
- Split real user sentences into positive, negative, and boundary cases.
- Test both should-trigger and should-not-trigger.
- An overly broad skill produces false positives; an overly narrow one can cause several skills to load at once and conflict.

Read [`references/trigger-design.md`](references/trigger-design.md) for detailed rules.

## Progressive disclosure rules

1. Discovery: assume the skill list carries only `name`, `description`, and path.
2. Activation: assume the whole `SKILL.md` loads only when the task matches.
3. Execution: design referenced files, scripts, and assets to be read or run only under stated conditions.

In short, keep only the always-needed material in `SKILL.md`. Split out detail together with "when to read it." Read [`references/progressive-disclosure.md`](references/progressive-disclosure.md) for detailed rules.

## Verification criteria

Minimum checks before completion:

- [ ] `name` is kebab-case and matches the folder name.
- [ ] `description` covers both what it does and when to use it.
- [ ] There are at least 3 positive, 2 negative, and 1 boundary trigger examples.
- [ ] `instruction_contract` contains intent, scope, authority, evidence, tools, loop, output, verification, and stop condition.
- [ ] If a loop exists, it has a feedback source, metric/rubric, guard, and stop condition.
- [ ] Recency, vendor, paper, and security claims carry a source URL and an accessed or snapshot date.
- [ ] Boundaries exist for prompt injection, credentials, and destructive/network/production side effects.
- [ ] Support files are referenced directly from `SKILL.md` by relative path.
- [ ] If scripts exist, dependencies, usage, expected output, and failure handling are documented.
- [ ] Local markdown links and code fences are not broken.
- [ ] Verification results and remaining risk are recorded in the handoff.

Read [`references/validation.md`](references/validation.md) for the detailed verification loop.

## Related documents

- [`../context-engineering/CONTEXT_ENGINEERING.md`](../context-engineering/CONTEXT_ENGINEERING.md)
- [`../context-engineering/references/prompt-authoring.md`](../context-engineering/references/prompt-authoring.md)
- [`references/prompt-loop-eval.md`](references/prompt-loop-eval.md)
- [`../harness-engineering/HARNESS_ENGINEERING.md`](../harness-engineering/HARNESS_ENGINEERING.md)
- [`../sourcing/reliable-search.md`](../sourcing/reliable-search.md)
- [`../sourcing/references/retrieval-safety.md`](../sourcing/references/retrieval-safety.md)
- [`../validation/index.md`](../validation/index.md)
