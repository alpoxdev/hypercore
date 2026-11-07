# Progressive Disclosure

> Korean version: [`progressive-disclosure.ko.md`](progressive-disclosure.ko.md)

Progressive disclosure is the core design principle for skills. If you assume the agent reads all content of every skill from the start, context is wasted and instruction conflicts multiply. Design a skill so it reads only the depth it needs, at the moment it needs it.

## 1. The three-stage model

| Stage | What loads | Design goal |
|---|---|---|
| Discovery | `name`, `description`, path | Accurate skill selection |
| Activation | The whole `SKILL.md` | Executing the core workflow and contract |
| Execution | `references/`, `scripts/`, `assets/` | Using detailed knowledge and tools on demand |

Anthropic's platform documentation gives the per-stage cost: metadata is always loaded at roughly **100 tokens per skill**, the body loads on trigger and should stay **under 5k tokens**, and bundled resources cost nothing until they are read. Scripts are the exception that proves the rule — the script's code never enters context, only its output (<https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview>, checked 2026-11-03).

## 2. What to keep in `SKILL.md`

- Trigger and scope
- Authority and evidence criteria
- The major workflow stages
- A summary of loop type, feedback source, and stop condition
- Gotchas the executor must know
- Navigation telling when to read support files
- Validation and stop conditions

Gotchas earn their place here specifically: they are environment facts that defy reasonable assumptions, and a separate reference file only helps if the agent recognizes the situation and reads it. If an agent would not know to look, the correction belongs in `SKILL.md` (<https://agentskills.io/skill-creation/best-practices>, checked 2026-11-03).

## 3. What to push down

| Content | Location |
|---|---|
| Long official documentation summaries | `references/official/*.md` |
| Recurring policy | `rules/*.md` |
| Prompt scaffolds and reusable prompt templates | `assets/prompts/` or `references/examples.md` |
| Detailed loop rules and failure-recovery order | `rules/loop.md` |
| Eval cases, fixtures, expected output | `assets/evals/` or `references/eval-cases.md` |
| Source ledger and vendor drift notes | `references/official/` or `references/sources.md` |
| Pinned snapshots of this repository's own documents | `references/local/*.md` |
| Prompt injection and side-effect safety notes | `rules/safety.md` or `references/safety.md` |
| Schema and API detail | `references/*.md` |
| Deterministic verification | `scripts/*.sh` |
| Templates | `assets/*` |
| Long example collections | `references/examples.md` or `assets/examples/*` |

`references/official/` is the conventional home for long official-documentation summaries and provider drift notes (for example `skills/hyper-skill/references/official/` and `skills/docs-maker/references/official/`), but the folder name is a recommendation, not a required path. What the rule requires is that provider detail stays out of the core. For a pinned snapshot of a document that lives in this repository, use `references/local/*.md` — that is the folder `skills/hyper-skill` uses for its summary of the skill-authoring documents.

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
Run `scripts/validate-skill.sh` when the skill includes scripts, generated assets, or eval fixtures.
```

The source states the same rule in the form of a condition, not a directory: "Read `references/api-errors.md` if the API returns a non-200 status code" is more useful than "see `references/` for details."

## 5. Context budget rules

- Keep the core `SKILL.md` within 500 lines — that limit comes from the agentskills.io best-practices guidance, not from this repository. This repository **additionally** enforces a 300-line gate on documents under `instructions/` (`scripts/check-sources.sh`, `MAX_LINES=300`, `DOC_SCOPE="instructions"`); that gate does not cover `SKILL.md` under `skills/`, so the 500-line guidance remains the `SKILL.md` budget. Treat 300 as **this repository's chosen default**, not as a sourced figure: 500 is what the best-practices page states, 300 is what this repository checks.
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
- SK-D-3: A skill is not automatically worth keeping because it is well written. The 2026 SWE-Skills-Bench measurement found 92 of 98 public skills had no statistically significant effect, and that the harmful ones worked by anchoring the agent on their own template and overriding the task's explicit instructions — so "it always follows my skill" is not evidence of value.

## 7. Listing budgets by runtime

The listing is the scarce resource: metadata for every installed skill is charged on every turn, whether or not the skill is used.

| Runtime | Listing budget | What happens on overflow |
|---|---|---|
| Agent Skills spec | Not specified — the client decides | Undefined |
| Codex | 2% of the model context, or 8,000 characters when unknown; `skills.max_context_tokens` raises it to at most 10,000 tokens | Descriptions are shortened first; some skills may be omitted from the list with a warning |
| Claude Code | 1% of the model context window; each entry's `description` + `when_to_use` capped at 1,536 characters | Descriptions are dropped starting with the least-invoked skills |
| Anthropic API | At most 20 skills per request | Requests are rejected; consolidate skills or route between sets |

Consequences for authoring: keep the trigger in the first sentence, assume the tail may never be seen, and watch the installed count as a budget rather than a free resource. Claude Code's `/skill-doctor` and `/doctor` report what each skill costs and which are never invoked (<https://code.claude.com/docs/en/skills>, checked 2026-11-03); Codex's `[[skills.config]]` disables a skill without deleting it.

## Sources

> Links re-read and re-checked 2026-11-03.

| Claim | Source |
|---|---|
| The 500-line and 5,000-token progressive-disclosure budgets, the removal question behind `SK-D-1` and `SK-D-2`, and the gotchas placement rule | <https://agentskills.io/skill-creation/best-practices> |
| The three-stage model (metadata, then full instructions, then referenced files) and the one-level-deep file reference rule | <https://agentskills.io/specification> |
| ~100 tokens of metadata per skill, the under-5k-token body, and script output as the only context cost | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| The 20-skills-per-request API limit | <https://platform.claude.com/docs/en/build-with-claude/skills-guide> |
| The 92-of-98 no-effect result and the template-anchoring failure mode behind `SK-D-3` | <https://arxiv.org/abs/2603.15401> |
| The 2%-of-context / 8,000-character Codex listing budget, `skills.max_context_tokens`, and `[[skills.config]]` | <https://learn.chatgpt.com/docs/build-skills> |
| The 1%-of-context Claude Code listing budget, the 1,536-character entry cap, the least-invoked-first drop order, and `/skill-doctor` | <https://code.claude.com/docs/en/skills> |

### Evidence grade

This file is the **canonical** statement of the disclosure budgets; [`skill-anatomy.md`](skill-anatomy.md) points here for the stage budgets and the 500-line limit, and repeats only the listing figures that frontmatter and file layout need. The 500-line and 5,000-token figures are `PRIMARY` — the agentskills.io best-practices page states them. The 300-line value is a repository gate on `instructions/`, labelled as such. `SK-D-3` rests on a single 2026 benchmark with its own statistical test, stated as one measurement rather than a law.
