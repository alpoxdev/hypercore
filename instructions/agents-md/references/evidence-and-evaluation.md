# Evidence and Evaluation

> Korean version: [`evidence-and-evaluation.ko.md`](evidence-and-evaluation.ko.md)

**Purpose**: separate what is *measured* about agent instruction files from what is *vendor prescription*, so authors stop treating heuristics as proven facts.

Read this before adding a rule "because it seems helpful." The strongest single result in this literature is that a badly written or stale context file makes agents **worse**, not neutral.

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

### 2.1 Context files usually do not improve task success

*Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?* — 138 CTXbench instances from 12 niche repositories that already carry developer-committed context files, plus SWE-bench Lite, four agent/model pairs (Claude Code with Sonnet-4.5, Codex with GPT-5.2 and with GPT-5.1 mini, Qwen Code with Qwen3-30b-coder), three conditions (no context file / LLM-generated / developer-written).

> "providing context files does not generally improve task success rates, while increasing inference cost by over 20% on average."

- LLM-generated files: resolution rate **-0.5%** on SWE-bench and **-2%** on CTXbench — no significant effect (p=87% and p=37%) — while steps rose 2.45 and 3.92 and cost rose **20%** and **23%** on average (p<0.001%).
- Developer-written files: **+2.4%** on average, also not statistically significant (p=21%), at up to 19% higher cost and 3.34 more steps.
- Agents generally *did* follow the instructions. The instructions caused more testing, searching, file reading, and reasoning.
- Two ablations matter for authors: "the length of context files has no significant impact", and "repository overviews, although popular and recommended by model providers, are not helpful."

Authors' conclusion:

> "while context files are useful for specifying non-standard coding practices, any attempts to improve performance should be rigorously evaluated before deployment."

**Scope limits**: "The current evaluation is focused on Python", one sampled completion per configuration, generated task descriptions and tests. This is not a universal claim across all models and repositories.

<https://arxiv.org/html/2602.11988v3> (submitted 2026-02-12, latest revision 2026-09-29, checked 2026-11-03)

### 2.2 A file's presence can cut runtime and tokens

*On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents* — 10 repositories, 124 pull requests, OpenAI Codex with GPT-5.2, same tasks with and without a root `AGENTS.md`.

> "The presence of AGENTS.md is associated with a lower median runtime (Δ 28.64%) and reduced output token consumption (Δ 16.58%), while maintaining a comparable task completion behavior."

**Scope limits**: correctness and semantic quality were explicitly **out of scope**; only a manual sanity check on 50 tasks was performed. This supports "a good file reduces exploration cost." It does **not** show that `AGENTS.md` improves correctness.

<https://arxiv.org/html/2601.20404v2> (submitted 2026-01-28, latest revision 2026-03-30, checked 2026-11-03)

### 2.3 Four 2026 results that refine the picture

The headline "files don't help correctness" is now well replicated, but the same period produced results that say *why*, and one that shows a large gain from a small change:

| Study | Design | Result |
|---|---|---|
| *Do Context Files Help Coding Agents? A Two-Agent Ablation Study on Real Repositories* (Khatri; REALM 2026 workshop, ACL Anthology `2026.realm-1.5`) | Claude Code and Codex, 17 real tasks from 3 repositories, 288 runs, gold tests | "Context strategy does not measurably move correctness on either agent (bounded to ≤10–15pp via equivalence testing)." Failures were implementation-skill failures, not context failures |
| *Probe-and-Refine Tuning of Repository Guidance for Coding Agents* (Shepard, Albrecht; arXiv:2606.20512) | Iterative probing of the repository to *derive* the file | 33.0% mean resolve rate vs 28.3% for the static knowledge base and 25.5% for no guidance (p < 0.001) — the gain comes from how the content was produced, not from having a file |
| *Why Does CLAUDE.md Keep Growing? Catastrophic Remembering in Agentic Coding* (Chakrabarti; arXiv:2608.11095) | 247,694 instruction lifetimes in 1,867 repositories | Files grow "more than tripling over their lifetime (+226%), gaining +4.9 net instructions every commit"; filtering entries that encode latent reasoning "remove 99.3% of excess instructions" |
| *Stale Instruction Files Override the Code in Coding Agents: A One-Sentence Fix* (Xu, Wu; arXiv:2610.30571) | 320 runs against repositories where the file contradicts the code | "Without the sentence, 90.1% of the agents' choices followed the stale file"; the fix "raised the share of choices that follow the code from 4.2% to 91.4%" and took the test pass rate from 89.4% to 100% |

Two consequences for authoring, both stronger than anything in the vendor docs:

- **A stale instruction file outranks the code.** The agent trusts the document over the source it can read, so every stale command or superseded architecture note is an active defect, not neutral noise. Say plainly, in the file, that the code wins when they disagree — that single sentence is what the fourth study fixed.
- **Growth is the default trajectory, not an accident.** Left alone, the file accretes ~5 instructions per commit and triples. Pruning is a maintenance task with a schedule, and the pruning criterion that worked was deleting entries that restate reasoning the agent can derive.

Sources for the table, all checked 2026-11-03: <https://aclanthology.org/2026.realm-1.5/> (proceedings, Oct 2026; preprint <https://arxiv.org/abs/2607.27250>, 2026-07-28), <https://arxiv.org/abs/2606.20512> (2026-06-18), <https://arxiv.org/abs/2608.11095> (2026-08-11), <https://arxiv.org/abs/2610.30571> (2026-10-22). Only the REALM paper is peer-reviewed; treat the others' effect sizes as indications, not thresholds.

### 2.4 Reading the results together

These are not contradictory, and the combination is the practical lesson:

- An instruction file reliably changes **how much work the agent does** to orient itself.
- It does **not** reliably change **whether the agent gets the task right** — two independent designs tested this with equivalence or significance testing and found no measurable correctness movement.
- What *does* move results is content quality: guidance derived by probing the repository beat both a static file and no file, and a single sentence about precedence over the code moved code-following from 4.2% to 91.4%.

So the value case for an instruction file is **cost, consistency, and specifying what the code cannot say about itself**; the risk case is **wrong, stale, or bloated content degrading results while charging more for it**. Write accordingly: few rules, each earned, and one of them saying the code wins on conflict.

---

## 3. Descriptive evidence (D)

*Agent READMEs: An Empirical Study of Context Files for Agentic Coding* — 2,303 context files across 1,925 repositories, covering Claude Code, OpenAI Codex, and GitHub Copilot files. Most common content (share of files):

| Content category | Share |
|---|---|
| Test procedures | 75.9% |
| Implementation details | 70.8% |
| Architecture | 68.1% |
| Security | 14.8% |
| Performance | 14.5% |

This measures **what developers write, not what works**. Read it as a warning in two directions: implementation detail is over-represented (and is exactly what agents can discover themselves), while security and performance constraints — which agents cannot infer and cannot safely guess — appear in roughly one file in seven.

<https://arxiv.org/html/2511.12884v2> (submitted 2025-11-17, latest revision 2026-08-09, checked 2026-11-03)

---

## 4. On length limits

**No rigorous dose-response evidence exists.** No reviewed study establishes an optimal line or token count, and the one controlled ablation that varied length found none: "the length of context files has no significant impact" on resolution rate (§2.1). Vendors nonetheless publish numbers, and those numbers are worth following as defaults because they reflect each runtime's own loading cost — not because they were measured against task success.

| Claim | Type | Source |
|---|---|---|
| "Size: target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." | V | Claude Code memory docs |
| "Keep CLAUDE.md under 200 lines. Move reference material to skills, which load on demand." | V | Claude Code features overview |
| A launch-time `CLAUDE.md` over 4 MiB is skipped entirely; a nested one over its own limit is loaded only in part | V | Claude Code memory docs |
| "Instructions must be no longer than 2 pages" | V | GitHub Copilot docs — appears only inside GitHub's copy-paste authoring prompt, not as a documented limit |
| "Keep rules under 500 lines" | V | Cursor docs, stated for rules generally |
| Observed files averaged 641 words (range 24–2,003) | D | CTXbench study |
| Instructions per file grow +226% over their lifetime, +4.9 net per commit | M | Catastrophic-remembering study (§2.3) |

Two mechanics behind the Anthropic number are worth internalizing, because they explain *why* a cap exists at all:

Claude Code reads `CLAUDE.md` files at the start of every session: those at or above the working directory load at launch, and those in subdirectories load when Claude first reads or edits a file there.

The cost is paid **every session, before any work happens**, whether or not the content turns out to be relevant. That is what distinguishes an instruction file from documentation the agent reads on demand — and it is why "move reference material to skills, which load on demand" is the recommended escape hatch rather than a longer file. The measured growth numbers above are the counter-argument to "a few extra lines won't hurt": they are how the file ends up tripled.

Treat every number above as a vendor heuristic tied to its own runtime, never as a validated quality threshold. The defensible rule is **relevance per line**, not a line count. Anthropic's current framing is an admission rule plus a pruning rule, not a budget:

> "Add to it when: Claude makes the same mistake a second time"

> "the file works best when it only holds what Claude couldn't work out from the code itself"

The older phrasing — "For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it." — no longer appears in the documentation; it was replaced by the two statements above, and `/doctor` now proposes the cuts mechanically for a checked-in `CLAUDE.md`.

Note also that "minimal" is not the same as "short":

> "Good context engineering means finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

The post explicitly adds that minimal does not necessarily mean short. A long file of load-bearing constraints beats a short file of vague ones.

<https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> (published 2025-09-29, last modified 2026-10-18, checked 2026-11-03)

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
| Stale commands, versions, architecture notes | Measured: agents follow the stale file over the code (90.1% of choices) | M |
| Unbounded accretion of instructions | +226% over a file's life; each append is cheaper than a safe delete | M |
| Presenting a codebase overview as the file's job | Recommended by vendors, measured as not helpful | M |

On the enforcement point, Anthropic is explicit that prose is advisory and that deterministic needs belong elsewhere:

> "If the instruction is something that must run at a specific point, such as before every commit or after each file edit, write it as a hook instead. Hooks execute as shell commands at fixed lifecycle events and apply regardless of what Claude decides to do."

If an action must happen every time, do not write a sentence asking for it — enforce it in a hook, a CI check, a lint rule, or a schema. An instruction file is the wrong tool for guarantees.

---

## 6. Evaluating a change to your own instruction file

Because the measured effects are small, can be negative, and depend on how the content was produced, treat a significant instruction change as an experiment rather than an improvement.

1. **Start from the failure.** Add a rule only after a repeated observed mistake or a durable discovery — not speculatively.
2. **Write the smallest rule that would have prevented it.** Name a scope or an observable check.
3. **Pick representative tasks.** A handful of real tasks from this repository beats a synthetic set.
4. **Compare with and without.** Track task success, runtime, tokens, tool calls, and regressions — success alone hides a cost blowup, and cost alone hides a correctness loss.
5. **Delete on no effect, on a schedule.** A rule that does not change behavior is pure context cost, and without pruning the file grows about five instructions per commit. Re-read the whole file at a fixed interval, not only when adding to it.

This mirrors the harness discipline in [`../../harness-engineering/HARNESS_ENGINEERING.md`](../../harness-engineering/HARNESS_ENGINEERING.md): a rule you cannot evaluate is a rule you cannot justify keeping.

---

## Sources

| Source | Grade | URL | Checked |
|---|---|---|---|
| Evaluating AGENTS.md (CTXbench) | M | <https://arxiv.org/html/2602.11988v3> | 2026-11-03 |
| Impact of AGENTS.md on Efficiency | M | <https://arxiv.org/html/2601.20404v2> | 2026-11-03 |
| Agent READMEs empirical study | D | <https://arxiv.org/html/2511.12884v2> | 2026-11-03 |
| Two-agent context-file ablation (REALM 2026) | M | <https://aclanthology.org/2026.realm-1.5/> | 2026-11-03 |
| Probe-and-refine repository guidance | M | <https://arxiv.org/abs/2606.20512> | 2026-11-03 |
| Catastrophic remembering in CLAUDE.md | M | <https://arxiv.org/abs/2608.11095> | 2026-11-03 |
| Stale instruction files override the code | M | <https://arxiv.org/abs/2610.30571> | 2026-11-03 |
| Anthropic — effective context engineering | V | <https://www.anthropic.com/research/effective-context-engineering-for-ai-agents> | 2026-11-03 |
| Anthropic — Claude Code best practices | V | <https://code.claude.com/docs/en/best-practices> | 2026-11-03 |
| Claude Code memory documentation | V | <https://code.claude.com/docs/en/memory> | 2026-11-03 |
| Claude Code features overview | V | <https://code.claude.com/docs/en/features-overview> | 2026-11-03 |
| GitHub Copilot custom instructions | V | <https://docs.github.com/en/copilot/concepts/prompting-and-context/custom-instructions> | 2026-11-03 |
| GitHub Copilot repository instructions | V | <https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions> | 2026-11-03 |
| Cursor rules documentation | V | <https://cursor.com/en-US/docs/rules> | 2026-11-03 |

## Related documents

- [`../AGENTS_MD.md`](../AGENTS_MD.md)
- [`content-contract.md`](content-contract.md)
- [`discovery-and-precedence.md`](discovery-and-precedence.md)
- [`../../validation/index.md`](../../validation/index.md)
