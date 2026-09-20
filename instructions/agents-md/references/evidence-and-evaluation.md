# Evidence and Evaluation

> Korean version: [`evidence-and-evaluation.ko.md`](evidence-and-evaluation.ko.md)

**Purpose**: separate what is *measured* about agent instruction files from what is *vendor prescription*, so authors stop treating heuristics as proven facts.

Read this before adding a rule "because it seems helpful." The strongest single result in this literature is that a badly written context file makes agents **worse**, not neutral.

---

## 1. Evidence grades

| Grade | Meaning | Weight when they conflict |
|---|---|---|
| **M** Measured | Controlled or paired experiment with a reported effect size | Highest, within its stated scope |
| **D** Descriptive | Observational study of what people actually write | Tells you norms, never effectiveness |
| **V** Vendor prescription | Official docs/blog guidance from the runtime's own team | Authoritative for *that runtime's mechanics*, heuristic for quality |
| **C** Community opinion | Blog posts, "top-performing file" listicles | Not evidence; use only for hypotheses |

A vendor's statement about **its own loading mechanics** (discovery order, size caps, import depth) is a fact about that product. The same vendor's statement about **what makes a file good** is a heuristic. Do not conflate the two.

---

## 2. Measured evidence (M)

### 2.1 Context files can reduce task success

*Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?* — 138 AGENTbench tasks plus 300 SWE-bench Lite tasks, four coding agents, three conditions (no context file / LLM-generated / developer-written).

> "Context files tend to reduce task success rates compared to providing no repository context, while also increasing inference cost by over 20%."

- LLM-generated files: **-0.5%** resolution on SWE-bench Lite, **-2%** on AGENTbench, **+20%/+23%** average cost.
- Developer-written files: **+4%** on average versus no file, but with more steps and higher cost.
- Agents generally *did* follow the instructions. The instructions caused more testing, searching, file reading, and reasoning.

Authors' recommendation:

> "Human-written context files should describe only minimal requirements."

**Scope limits**: Python-heavy benchmark, one sampled completion per configuration, generated task descriptions and tests. This is not a universal claim across all models and repositories.

<https://arxiv.org/html/2602.11988v1> (checked 2026-09-19)

### 2.2 A file's presence can cut runtime and tokens

*On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents* — 10 repositories, 124 pull requests, OpenAI Codex with GPT-5.2, same tasks with and without a root `AGENTS.md`.

> "The presence of AGENTS.md is associated with a lower median runtime (Δ 28.64%) and reduced output token consumption (Δ 16.58%), while maintaining a comparable task completion behavior."

**Scope limits**: correctness and semantic quality were explicitly **out of scope**; only a manual sanity check on 50 tasks was performed. This supports "a good file reduces exploration cost." It does **not** show that `AGENTS.md` improves correctness.

<https://arxiv.org/html/2601.20404v2> (checked 2026-09-19)

### 2.3 Reading the two together

These are not contradictory, and the combination is the practical lesson:

- An instruction file reliably changes **how much work the agent does** to orient itself.
- It does **not** reliably change **whether the agent gets the task right**.
- Only *developer-written, minimal* files showed a success gain. Generated, comprehensive files showed a loss.

So the value case for an instruction file is **cost and consistency**, and the risk case is **wrong or bloated content actively degrading results**. Write accordingly: few rules, each earned.

---

## 3. Descriptive evidence (D)

*Agent READMEs: An Empirical Study of Context Files for Agentic Coding* — 2,303 instruction files across 1,925 repositories. Most common content:

| Content category | Share |
|---|---|
| Implementation details | 69.9% |
| Architecture | 67.7% |
| Build and run commands | 62.3% |
| Security | 14.5% |
| Performance | 14.5% |

This measures **what developers write, not what works**. Read it as a warning in two directions: implementation detail is over-represented (and is exactly what agents can discover themselves), while security and performance constraints — which agents cannot infer and cannot safely guess — appear in roughly one file in seven.

<https://arxiv.org/html/2511.12884v1> (checked 2026-09-19)

---

## 4. On length limits

**No rigorous dose-response evidence exists.** No reviewed study establishes an optimal line or token count. Vendors nonetheless publish numbers, and those numbers are worth following as defaults because they reflect each runtime's own loading cost — not because they were measured against task success.

| Claim | Type | Source |
|---|---|---|
| "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." | V | Claude Code memory docs |
| "Keep CLAUDE.md under 200 lines. Move reference material to skills, which load on-demand." | V | Claude Code features overview |
| "Instructions must be no longer than 2 pages" | V | GitHub Copilot docs — appears inside GitHub's sample generation prompt under `<Limitations>`, not as a standalone general rule |
| "Keep rules under 500 lines" | V | Cursor docs, stated for rules generally |
| Observed files averaged 641 words (range 24–2,003) | D | AGENTbench study |

Two mechanics behind the Anthropic number are worth internalizing, because they explain *why* a cap exists at all:

> "CLAUDE.md files are loaded into the context window at the start of every session, consuming tokens alongside your conversation."

The cost is paid **every session, before any work happens**, whether or not the content turns out to be relevant. That is what distinguishes an instruction file from documentation the agent reads on demand — and it is why "move reference material to skills, which load on-demand" is the recommended escape hatch rather than a longer file.

Treat every number above as a vendor heuristic tied to its own runtime, never as a validated quality threshold. The defensible rule is **relevance per line**, not a line count. Anthropic's own framing is a deletion test, not a budget:

> "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it."

Note also that "minimal" is not the same as "short":

> "Good context engineering means finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

The post explicitly adds that minimal does not necessarily mean short. A long file of load-bearing constraints beats a short file of vague ones.

<https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> (published 2025-09-29, checked 2026-09-19)

---

## 5. Consolidated failure modes

| Failure mode | Why it hurts | Evidence |
|---|---|---|
| Kitchen-sink file | Consumes context and reduces adherence to the rules that matter | V, M |
| LLM-generated file full of obvious facts | Measured success loss plus ~20% cost increase | M |
| Brittle if/then logic | Breaks on cases the author did not foresee | V |
| Vague rules ("write clean code") | Unfalsifiable; changes no behavior | V |
| Exhaustive edge-case lists | Crowds out load-bearing constraints | V |
| Restating what the repo already shows | Pure context cost, zero signal | V, M |
| Task-specific notes in a repo-wide file | Misapplies to unrelated work | V |
| Response style/length preferences | Not project knowledge; belongs to user settings | V |
| Conflicting global / root / nested files | Agent silently picks one | V |
| Treating Markdown as deterministic enforcement | Instructions are advisory; only hooks/CI enforce | V |
| Omitting security and performance constraints | Agents cannot infer these and will guess | D |
| Stale commands, versions, architecture notes | Actively misleads; worse than absence | V |

On the enforcement point, Anthropic is explicit that prose is advisory and that deterministic needs belong elsewhere:

> "If the instruction is something that must run at a specific point, such as before every commit or after each file edit, write it as a hook instead. Hooks execute as shell commands at fixed lifecycle events and apply regardless of what Claude decides to do."

If an action must happen every time, do not write a sentence asking for it — enforce it in a hook, a CI check, a lint rule, or a schema. An instruction file is the wrong tool for guarantees.

---

## 6. Evaluating a change to your own instruction file

Because the measured effects are small and can be negative, treat a significant instruction change as an experiment rather than an improvement.

1. **Start from the failure.** Add a rule only after a repeated observed mistake or a durable discovery — not speculatively.
2. **Write the smallest rule that would have prevented it.** Name a scope or an observable check.
3. **Pick representative tasks.** A handful of real tasks from this repository beats a synthetic set.
4. **Compare with and without.** Track task success, runtime, tokens, tool calls, and regressions — success alone hides a cost blowup, and cost alone hides a correctness loss.
5. **Delete on no effect.** A rule that does not change behavior is pure context cost. Removal is the default outcome, not the exception.

This mirrors the harness discipline in [`../../harness-engineering/HARNESS_ENGINEERING.md`](../../harness-engineering/HARNESS_ENGINEERING.md): a rule you cannot evaluate is a rule you cannot justify keeping.

---

## Sources

| Source | Grade | URL | Checked |
|---|---|---|---|
| Evaluating AGENTS.md (AGENTbench) | M | <https://arxiv.org/html/2602.11988v1> | 2026-09-19 |
| Impact of AGENTS.md on Efficiency | M | <https://arxiv.org/html/2601.20404v2> | 2026-09-19 |
| Agent READMEs empirical study | D | <https://arxiv.org/html/2511.12884v1> | 2026-09-19 |
| Anthropic — effective context engineering | V | <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> | 2026-09-19 |
| Anthropic — Claude Code best practices | V | <https://code.claude.com/docs/en/best-practices> | 2026-09-19 |
| Claude Code memory documentation | V | <https://code.claude.com/docs/en/memory> | 2026-09-19 |
| Claude Code features overview | V | <https://code.claude.com/docs/en/features-overview> | 2026-09-19 |
| GitHub Copilot repository instructions | V | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 2026-09-19 |
| GitHub Copilot response customization | V | <https://docs.github.com/en/copilot/concepts/prompting/response-customization> | 2026-09-19 |
| Cursor rules documentation | V | <https://cursor.com/en-US/docs/rules> | 2026-09-19 |

## Related documents

- [`../AGENTS_MD.md`](../AGENTS_MD.md)
- [`content-contract.md`](content-contract.md)
- [`discovery-and-precedence.md`](discovery-and-precedence.md)
- [`../../validation/index.md`](../../validation/index.md)
