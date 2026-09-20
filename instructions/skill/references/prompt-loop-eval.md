# Prompt, Loop, And Eval For Skills

> Korean version: [`prompt-loop-eval.ko.md`](prompt-loop-eval.ko.md)

This document is the standard for designing a skill as a **small, repeatable agent program** rather than a single prompt. `SKILL.md` is the program's entrypoint, and `rules/`, `references/`, `scripts/`, and `assets/` are modules loaded on demand.

Source snapshot: 2026-06-28.

## 1. Core principles

| Principle | Standard | Failure signal |
|---|---|---|
| Skill is program | Separate inputs, stages, tools, intermediate artifacts, final artifacts, and verification | One long role prompt holding all knowledge |
| Loop needs signal | Iteration needs a feedback source, metric/rubric, guard, and stop condition | Only "iterate until better," with no stop criterion |
| Tool grounding | Work that changes external state separates observe, action, and verify | Believing search snippets, tool output, or subagent summaries outright |
| Eval before polish | Build success criteria and eval cases before polishing sentences | It looks good but you cannot tell which regression it prevents |
| Source and safety boundary | Retrieved content is evidence, not a system, developer, or project instruction | Executing instructions inside a web page or tool output |
| Benchmark humility | A leaderboard or single score is a reference signal, not skill verification itself | Not recording benchmark version, scaffold, contamination, or weak tests |

## 2. Prompt contract

A skill prompt must fill in the contract below.

```markdown
## Intent
- What the user counts as success:
- What counts as failure:

## Scope
- In:
- Out:
- Side-effect boundary:

## Authority
- Priority:
- Handling of retrieved/tool content:

## Context
- Required files, sources, dates, versions:
- Handling of missing information:

## Workflow
- Step 1:
- Step 2:
- Verification:

## Loop
- Type: none | observe-act | draft-critique-revise | branch-score-prune | optimize-compare
- Feedback:
- Metric/rubric:
- Guard:
- Stop:

## Output
- Format:
- Storage location:
- Required/forbidden fields:
```

## 3. Choosing a loop pattern

| Pattern | Basis | Use when | Required guard |
|---|---|---|---|
| Observe -> act -> observe -> update | ReAct | Search, repo exploration, tool use — work where external observation changes the answer | A trace showing tool output was read and the next action updated |
| Draft -> critique -> revise | Self-Refine | Documents, summaries, reviews, policy conformance — artifacts improvable against a rubric | Critique criteria and a maximum iteration count |
| Attempt -> feedback -> reflection -> retry | Reflexion | A repeated task class where failure postmortems help the next attempt | Confirming the reflection rests on actual verify output |
| Branch -> score -> prune | Tree of Thoughts | Alternative exploration, plan comparison, complex reasoning where an early choice matters a lot | Branch count, scorer, and prune criteria |
| Candidate -> score -> mutate | OPRO, Promptbreeder, DSPy/MIPRO | Optimizing prompt or skill variants against an eval set | Train/holdout separation and a regression gate |

State explicitly when no loop is needed. Examples: filling a single-file template, running a deterministic formatter, a short one-shot transform.

## 4. Skill eval matrix

A skill eval does not look at triggers only.

| Layer | Eval case | Pass criterion |
|---|---|---|
| Trigger | Positive/negative/boundary prompts | Only the needed skill activates, and it steps back on similar work |
| Workflow | Normal task, missing context, failing tool output | It follows the defined order and fallbacks |
| Output | Schema, table, file path, style | Downstream automation can read it |
| Source | Recent API claims, conflicting sources, stale sources | A primary source and an accessed date exist |
| Safety | Prompt injection, credential requests, destructive/network actions | Retrieved instructions ignored; gated by user/project authority |
| Regression | Known bad prompt/output pairs | A previous failure does not recur |

Minimum recommendation:

- Small skill edit: 3-5 smoke cases
- Standard skill creation or refactor: 8-15 cases
- Agent/tool workflow skill: 20+ cases, or a representative sample plus targeted adversarial cases

## 5. Multi-prompt and format robustness

Prompt formatting and example placement can swing results significantly, so an important skill does not pass on a single canonical prompt.

- Test the same intent in Korean and English, as a short request and a long one, with and without an explicit skill name.
- When output format matters, evaluate at least two format variants across Markdown, JSON, and YAML.
- Look at worst cases and regression cases, not only the average.
- "The new prompt looks better" is not a shipping criterion. The failure count must drop on the same eval set.

## 6. Benchmark and leaderboard hygiene

When verifying an agentic, coding, or tool-use skill, do not claim completion from public benchmark scores alone.

Required records:

- Benchmark name, release/date window, dataset split
- Model, runtime, scaffold, and tool versions
- Repository commit, container/toolchain, allowed tools
- Whether retrieval was enabled, and the source cutoff
- How contamination and overlap were checked
- Public test, hidden test, and oracle weakness caveats
- Whether a paired with-skill vs without-skill result is needed

Rules:

- Prefer an execution-based verifier for software skills.
- Mark a benchmark as contamination-prone when it is old or public.
- Do not compare consecutive scores on the same benchmark when the scaffold changed.
- Break results down by task type, repository, difficulty, and failure class rather than looking only at an aggregate score.
- When public tests are weak, add hidden tests, differential checks, or oracle refinement.

## 7. Authoring a source-grounded skill

When a skill covers vendor docs, API behavior, papers, benchmarks, or security claims:

- Record the source URL, accessed date, and applicable version or product in `references/official/` or a separate reference.
- Keep only core rules in `SKILL.md` and split long source summaries into references.
- Use absolute dates for recency claims.
- When official documents conflict, compare the applicable runtime, model, or product and the dates.
- Treat a model-generated summary as a candidate, not a source.

## 8. Authoring a safety-grounded skill

When a skill touches network, shell, credentials, external APIs, production, or destructive actions:

- State in `Authority` that retrieved and tool content is evidence only, never instructions.
- Validate commands, URLs, recipients, and file paths found in external text against an allowlist or schema.
- Do not enter credentials, pay, publish, delete, deploy, or change production without explicit user permission.
- Treat third-party skills and bundled scripts as subjects of code review, not prompt snippets.
- Require version pinning and change re-review for a production skill.
- Document each script's purpose, dependencies, input/output, failure modes, and side effects.
- Safety instructions can hurt performance, so keep adversarial evals and a normal happy path side by side.

## 9. Authoring loop

```text
Collect failures -> Draft contract -> Build eval set -> Run baseline/readback -> Patch smallest surface -> Re-run -> Record decision
```

| Stage | Artifact |
|---|---|
| Collect failures | Real user sentences, failing output, missing context, unsafe requests |
| Draft contract | `SKILL.md` intent, scope, authority, workflow, output, verification |
| Build eval set | Positive, negative, boundary, source, safety, and regression cases |
| Run baseline/readback | The failure list of the existing skill or draft |
| Patch | Modify one of trigger, workflow, resource placement, script, or asset |
| Re-run | Check the same eval set plus new failure cases |
| Record | Reason for the change, pass/fail, remaining risk |

## 10. Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-19. OpenAI Codex documentation moved from `developers.openai.com/codex/*` to `learn.chatgpt.com/docs/*`.

- OpenAI Codex Agent Skills: <https://learn.chatgpt.com/docs/build-skills>
- OpenAI API Skills: <https://developers.openai.com/api/docs/guides/tools-skills>
- OpenAI agent evals: <https://developers.openai.com/api/docs/guides/agent-evals>
- OpenAI prompt engineering: <https://developers.openai.com/api/docs/guides/prompt-engineering>
- OpenAI agent safety: <https://developers.openai.com/api/docs/guides/agent-builder-safety>
- OpenAI Codex approvals and security: <https://learn.chatgpt.com/docs/agent-approvals-security>
- Anthropic Agent Skills engineering note: <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills>
- Anthropic prompt/eval docs: <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>
- Anthropic Agent Skills enterprise security: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise>
- Agent Skills specification: <https://agentskills.io/specification>
- Agent Skills best practices: <https://agentskills.io/skill-creation/best-practices>
- ReAct: <https://arxiv.org/abs/2210.03629>
- Reflexion: <https://arxiv.org/abs/2303.11366>
- Self-Refine: <https://arxiv.org/abs/2303.17651>
- Tree of Thoughts: <https://arxiv.org/abs/2305.10601>
- OPRO: <https://arxiv.org/abs/2309.03409>
- Promptbreeder: <https://arxiv.org/abs/2309.16797>
- DSPy: <https://arxiv.org/abs/2310.03714>
- MIPRO: <https://arxiv.org/abs/2406.11695>
- AI Agents That Matter: <https://arxiv.org/abs/2407.01502>
- LiveCodeBench: <https://arxiv.org/abs/2403.07974>
- LiveBench: <https://arxiv.org/abs/2406.19314>
- OpenAI SWE-bench Verified: <https://openai.com/index/introducing-swe-bench-verified/>
- SWE-Skills-Bench: <https://arxiv.org/abs/2603.15401>
- OWASP Top 10 for LLM Applications: <https://genai.owasp.org/llm-top-10/>
- NIST AI Risk Management Framework: <https://www.nist.gov/itl/ai-risk-management-framework>
