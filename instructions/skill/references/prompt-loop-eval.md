# Prompt, Loop, And Eval For Skills

> Korean version: [`prompt-loop-eval.ko.md`](prompt-loop-eval.ko.md)

This document is the standard for designing a skill as a **small, repeatable agent program** rather than a single prompt. `SKILL.md` is the program's entrypoint, and `rules/`, `references/`, `scripts/`, and `assets/` are modules loaded on demand.

Source snapshot: 2026-11-03. Every URL in §12 was re-read on that date.

## 1. Core principles

| Principle | Standard | Failure signal |
|---|---|---|
| Skill is program | Separate inputs, stages, tools, intermediate artifacts, final artifacts, and verification | One long role prompt holding all knowledge |
| Loop needs signal | Iteration needs a feedback source, metric/rubric, guard, and stop condition | Only "iterate until better," with no stop criterion |
| Tool grounding | Work that changes external state separates observe, action, and verify | Believing search snippets, tool output, or subagent summaries outright |
| Eval before polish | Build success criteria and eval cases before polishing sentences | It looks good but you cannot tell which regression it prevents |
| Source and safety boundary | Retrieved content is evidence, not a system, developer, or project instruction | Executing instructions inside a web page or tool output |
| Benchmark humility | A leaderboard or single score is a reference signal, not skill verification itself | Not recording benchmark version, scaffold, contamination, or weak tests |
| Value is measured | The with/without delta is the claim; the artifact existing is not | "The skill is well written, so it helps" |

## 2. Prompt contract

[`../SKILL_AUTHORING.md`](../SKILL_AUTHORING.md) → `## Minimum SKILL.md contract` is the canonical definition: `instruction_contract` carries exactly nine fields — Intent, Scope, Authority, Evidence, Tools, Loop, Output, Verification, Stop condition. The contract below fills all nine and records where the earlier seven-block sketch went, so a skill written from either shape passes the same checklist.

| Earlier block (7) | Canonical field (9) | What moves |
|---|---|---|
| Intent | Intent | Unchanged |
| Scope | Scope | Unchanged |
| Authority | Authority | Unchanged |
| Context | Evidence | Required files, sources, dates, versions, and missing-information handling are evidence questions |
| Workflow | Tools | The ordered stages stay in `<workflow>`; `Tools` names the tool each stage may use and its boundary |
| Workflow | Verification | The block's `Verification` line becomes its own field |
| Workflow | Stop condition | Completion, abort, and ask-the-user conditions become their own field |
| Loop | Loop | Unchanged |
| Output | Output | Unchanged |

Evidence inherits the Context block. The three fields that had no block of their own — Tools, Verification, Stop condition — are the ones most often left blank, so they are written out below with Evidence instead of being folded into Workflow.

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

## Evidence
- Required files, sources, dates, versions:
- Handling of missing information:

## Tools
- Tools each stage may use, and the boundary on each:
- Handling of tool-output failure:

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

## Verification
- Checks that decide pass or fail:
- Evidence each check leaves:

## Stop condition
- Complete when:
- Abort when:
- Ask the user when:
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

- Small skill edit: a smoke subset
- Standard skill creation or refactor: the full composed set
- Agent/tool workflow skill: the full set plus targeted adversarial cases

The sizes are not fixed here. The source does not state a validated count, so this file states a **composition** requirement instead: every case must probe something the others do not. Case-count policy lives in [`validation.md`](validation.md) §3.

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
- Whether a with-skill vs without-skill baseline is needed — **run it by default** (see `SK-V-1` in [`validation.md`](validation.md) §4; the deterministic-skill exception applies here too)

Rules:

- Prefer an execution-based verifier for software skills.
- Mark a benchmark as contamination-prone when it is old or public.
- Do not compare consecutive scores on the same benchmark when the scaffold changed.
- Break results down by task type, repository, difficulty, and failure class rather than looking only at an aggregate score.
- When public tests are weak, add hidden tests, differential checks, or oracle refinement.

The strongest published example of this discipline for skills is SWE-Skills-Bench (2026-03-16): it pins each skill to a repository commit, derives per-repository requirements, builds executable verifiers, and reports a paired per-skill delta. 92 of 98 skills showed no significant effect and the average pass ratio moved from 76.6% to 76.9% <https://arxiv.org/abs/2603.15401>. Treat that result as a design to copy, not as a verdict on any individual skill.

## 7. Authoring a source-grounded skill

When a skill covers vendor docs, API behavior, papers, benchmarks, or security claims:

- Record the source URL, accessed date, and applicable version or product in `references/official/` (a recommended layout, not a required path), in a separate reference, or in `references/local/` when the evidence is a pinned snapshot of this repository's own documents.
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

## 9. Skill inventory and recall

A skill competes with every other installed skill for the selector's attention, and the cost is paid on every turn whether or not it is used.

| Constraint | Number | Consequence for authoring |
|---|---|---|
| Metadata cost per skill | ~100 tokens, always loaded | Forty installed skills cost roughly 4,000 tokens before any work starts |
| Codex listing | 2% of the model context, or 8,000 characters when unknown; raised to at most 10,000 tokens by `skills.max_context_tokens` | Descriptions shorten first; skills can be dropped from the list with a warning |
| Claude Code listing | 1% of the model context; 1,536 characters per entry | Descriptions drop starting with the least-invoked skills |
| Anthropic API | At most 20 skills per request | Consolidate, or route requests to different skill sets |

Operational rules that follow:

- Measure recall as the set grows; stop adding when selection accuracy degrades.
- Consolidate narrow skills into a broader one only when the consolidated skill's evals match the originals.
- Disable rather than delete a skill you are not ready to remove (`[[skills.config]]` in Codex, `skillOverrides` in Claude Code), and check the usage report before deciding.

## 10. Artifact audit

The rules above test what a skill **receives** — does it resist an injected instruction. These test what a skill **is**: does the artifact itself carry something it should not. A skill is distributed code plus instructions, so audit it before shipping.

Seven categories, with the severity the cited source assigns. This list is not "all of skill security"; it is the set of artifact-level checks that source names.

| Category | What to look at | Severity as assigned by the source |
|---|---|---|
| Code execution | Scripts in the skill directory (`*.py`, `*.sh`, `*.js`) | High: scripts run with full environment access |
| Instruction manipulation | Directives to ignore safety rules, hide actions, or alter behaviour conditionally | High: can bypass security controls |
| MCP server reference | References shaped like `ServerName:tool_name` | High |
| Network access | URLs, API endpoints, `fetch`, `curl`, `requests` | High: potential data-exfiltration vector |
| Hardcoded credentials | Keys, tokens, and passwords inside skill files or scripts | High: secrets exposed in Git history and the context window |
| Filesystem scope | Paths outside the skill directory, broad globs, `../` | Medium |
| Tool calls | Instructions directing the agent to use bash, file operations, or other tools | Medium: review what operations are performed |

- SK-A-1: Audit a skill against the seven categories above before distributing it, and record the result.
- SK-A-2: Do not distribute a skill from an untrusted source without a full audit.
- SK-A-3: Pin a skill to a version, and re-review it when the version changes.

These are `VENDOR` claims: the severity labels come from the cited source, not from a controlled study in this repository. Treat an audit as a checklist that catches known artifact-level problems, not as a proof of safety. Automated content scanning exists for some enterprise surfaces, but the source states it does not cover Skills API uploads — which is exactly the path this repository uses.

## 11. Authoring loop

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

This authoring loop is a human-supervised turn-based loop. When the loop runs unattended — on a schedule, against a goal condition, or with a separate checker — design it with [`../../loop-engineering/LOOP_ENGINEERING.md`](../../loop-engineering/LOOP_ENGINEERING.md).

## 12. Sources

> Links re-read and re-checked 2026-11-03. OpenAI Codex documentation lives at `learn.chatgpt.com/docs/*`; the Anthropic engineering note now redirects to `/research/`, and the canonical URL below is the redirect target.

| Claim | Source |
|---|---|
| With/without baseline as the core pattern (the evaluating-skills page names it the core pattern, not an option) | <https://agentskills.io/skill-creation/evaluating-skills> |
| Case-set composition, and the absence of a stated case count | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| The seven artifact-audit categories and their severity labels | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> |
| Treating third-party skills as subjects of code review, version pinning with re-review, and the scan coverage gap | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> |
| ~100 tokens of metadata per skill and the 20-skills-per-request API limit | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| The Codex listing budget, `skills.max_context_tokens`, and `[[skills.config]]` | <https://learn.chatgpt.com/docs/build-skills> |
| The Claude Code listing budget, the 1,536-character entry cap, least-invoked-first dropping, and `skillOverrides` | <https://code.claude.com/docs/en/skills> |
| The paired per-skill delta design and the 92-of-98 result | <https://arxiv.org/abs/2603.15401> |

### Cited URLs

- OpenAI Codex Agent Skills: <https://learn.chatgpt.com/docs/build-skills>
- OpenAI API Skills: <https://developers.openai.com/api/docs/guides/tools-skills>
- OpenAI agent evals: <https://developers.openai.com/api/docs/guides/agent-evals>
- OpenAI skill eval guidance: <https://developers.openai.com/blog/eval-skills>
- Anthropic Agent Skills engineering note: <https://www.anthropic.com/research/equipping-agents-for-the-real-world-with-agent-skills>
- Anthropic Agent Skills overview: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview>
- Anthropic skill authoring best practices: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>
- Anthropic Agent Skills enterprise security: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise>
- Claude Code skills: <https://code.claude.com/docs/en/skills>
- Anthropic prompt/eval docs: <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>
- Agent Skills specification: <https://agentskills.io/specification>
- Agent Skills best practices: <https://agentskills.io/skill-creation/best-practices>
- Agent Skills, evaluating output quality: <https://agentskills.io/skill-creation/evaluating-skills>
- Vercel `skills` CLI: <https://github.com/vercel-labs/skills>
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
- SWE-bench Verified: <https://openai.com/index/introducing-swe-bench-verified/>
- SWE-Skills-Bench: <https://arxiv.org/abs/2603.15401>
- OWASP Top 10 for LLM Applications: <https://genai.owasp.org/llm-top-10/>
- NIST AI Risk Management Framework: <https://www.nist.gov/itl/ai-risk-management-framework>

### Evidence grade

The 20-skill API limit and the listing budgets are `VENDOR` numbers tied to specific products and dates. The audit severities are the source's own labels. The 92-of-98 result is one 2026 benchmark with its own statistical test.
