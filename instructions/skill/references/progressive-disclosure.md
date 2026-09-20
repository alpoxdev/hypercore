# Progressive Disclosure

> Korean version: [`progressive-disclosure.ko.md`](progressive-disclosure.ko.md)

Progressive disclosure is the core design principle for skills. If you assume the agent reads all content of every skill from the start, context is wasted and instruction conflicts multiply. Design a skill so it reads only the depth it needs, at the moment it needs it.

## 1. The three-stage model

| Stage | What loads | Design goal |
|---|---|---|
| Discovery | `name`, `description`, path | Accurate skill selection |
| Activation | The whole `SKILL.md` | Executing the core workflow and contract |
| Execution | `references/`, `scripts/`, `assets/` | Using detailed knowledge and tools on demand |

## 2. What to keep in `SKILL.md`

- Trigger and scope
- Authority and evidence criteria
- The major workflow stages
- A summary of loop type, feedback source, and stop condition
- Gotchas the executor must know
- Navigation telling when to read support files
- Validation and stop conditions

## 3. What to push down

| Content | Location |
|---|---|
| Long official documentation summaries | `references/official/*.md` |
| Recurring policy | `rules/*.md` |
| Prompt scaffolds and reusable prompt templates | `assets/prompts/` or `references/examples.md` |
| Detailed loop rules and failure-recovery order | `rules/loop.md` |
| Eval cases, fixtures, expected output | `assets/evals/` or `references/eval-cases.md` |
| Source ledger and vendor drift notes | `references/official/` or `references/sources.md` |
| Prompt injection and side-effect safety notes | `rules/safety.md` or `references/safety.md` |
| Schema and API detail | `references/*.md` |
| Deterministic verification | `scripts/*.py`, `scripts/*.sh`, `scripts/*.mjs` |
| Templates | `assets/*` |
| Long example collections | `references/examples.md` or `assets/examples/*` |

## 4. Navigation sentences

Do not simply write "see references/." State when to read it.

Weak example:

```markdown
For more information, see references/.
```

Strong example:

```markdown
Read `references/official/openai.md` only when provider-specific Codex skill behavior changes the core rule.
Read `references/prompt-loop-eval.md` before adding an iterative loop, prompt optimizer, or eval fixture.
Read `rules/safety.md` before enabling network, credential, destructive, or production side effects.
Run `scripts/validate-skill.mjs` when the skill includes scripts, generated assets, or eval fixtures.
```

## 5. Context budget rules

- Keep the core `SKILL.md` within 500 lines — that limit comes from the specification, not from this repository. This repository **additionally** enforces a 300-line gate (`scripts/check-sources.sh`, `MAX_LINES=300`); treat 300 as **this repository's chosen default**, not as a sourced figure. The two are different: 500 is what the source states, 300 is what this repository checks.
- Keep each `references/` file focused on one topic.
- Do not build deep reference chains.
- If you created a support file, reference it directly from `SKILL.md`.
- Do not create explanations that did not need a support file.
- Put eval fixtures and prompt templates in `assets/` when they are actually run or copied, rather than in a prose reference.

## 6. Readback check

After splitting, answer the following.

- Can you tell what to do and when from `SKILL.md` alone?
- Is the condition for reading each support file clear?
- Is a definition duplicated between the core and a reference?
- Is every reference actually useful?
- Are scripts and assets being misused as reasoning files?

### Removal test

The questions above ask whether content is *useful*. These decide whether it *earns its place*.

- SK-D-1: For each instruction, ask **"if this were absent, would the agent get it wrong?"** If the answer is no, delete it. If you are not sure, test it rather than keeping it on suspicion.
- SK-D-2: If a task succeeds without the skill, that skill may add no value. A skill that restates what the agent already does reliably is cost without benefit.

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-20. Next re-verification 2026-10-29.

| Claim | Source |
|---|---|
| The 500-line and 5,000-token progressive-disclosure budgets, and the removal test behind `SK-D-1` and `SK-D-2` | <https://agentskills.io/skill-creation/best-practices> |
| The three-stage model (metadata, then full instructions, then referenced files) | <https://agentskills.io/specification> |

### Evidence grade

This file is the **canonical** statement of the disclosure budgets; [`skill-anatomy.md`](skill-anatomy.md) points here rather than restating them. The 500-line and 5,000-token figures are `PRIMARY` — the specification site states them. The 300-line value is a repository gate, labelled as such.
