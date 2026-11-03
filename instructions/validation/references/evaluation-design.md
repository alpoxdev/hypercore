# Evaluation Design Reference

> Korean version: [`evaluation-design.ko.md`](evaluation-design.ko.md)

**Purpose**: verify prompt, instruction, skill, and agent workflow changes with evals rather than intuition, and keep the result honest about non-determinism.

---

## 1. Eval-driven workflow

```text
Success criteria -> Test set -> Grader/rubric -> Baseline -> Change -> Re-run -> Transcript review -> Ship/caveat
```

- Success criteria must be concrete and measurable.
- Eval cases reflect the real task distribution and edge cases.
- Prefer a structure that can be graded automatically.
- Subjective grading needs a clear rubric and human calibration.
- An eval is not a one-time event; keep reinforcing it, and retire cases that saturate.

---

## 2. Success criteria template

```markdown
## Success Criteria

| Criterion | Metric / rubric | Threshold | Evidence |
|---|---|---|---|
| Task fidelity | expected fields present, exact/semantic match | 90%+ | eval output |
| Source grounding | every non-obvious claim cited | 100% critical claims | claim-source matrix |
| Safety | no secret/tool/side-effect leakage | 0 critical failures | adversarial cases |
| Format | schema/markdown contract satisfied | 100% | parser/lint |
| Usefulness | user goal addressed with caveats | rubric >= 4/5 | reviewer or model grader |
```

Write the pass threshold per criterion and per risk level; aggregate scores hide the one criterion that mattered.

---

## 3. Test set design

| Case type | Purpose |
|---|---|
| happy path | Confirm the core function works |
| edge case | Ambiguous input, missing fields, long documents, multilingual text, version differences |
| known failure | Prevent a previously failing case from returning |
| adversarial | Prompt injection, unsafe tool requests, misleading sources |
| regression | Preserve existing behavior |
| negative | What must not be answered; handling of unknowns and caveats |

Minimum recommendation:

- Instruction-only change: 3–5 cases.
- Standard skill or prompt change: 8–15 cases.
- Agent, tool, or multi-turn workflow: start at **20–50 tasks drawn from real failures**, then grow the suite as effect sizes shrink.
- High-risk agent/tool workflow: the above plus targeted adversarial cases.

Two properties of the set matter as much as its size.

- **Balance.** Test where the behavior should occur and where it should not. A suite that only checks "searched when it should" trains over-triggering.
- **Unambiguity.** Two domain experts should reach the same pass/fail verdict, and a correct agent should be able to pass from the task text alone. A 0% pass rate across many trials usually indicates a broken task or grader rather than incapable behavior.

Public suites are useful for calibrating difficulty, not for proving local behavior. Terminal-Bench 2.0 reports frontier agents and harnesses below 65% on 89 curated tasks, while SWE-bench Verified has risen into the 80%+ range within a year and is nearing saturation. A suite whose cases are all passing has stopped informing you, whatever its name is on a leaderboard.

---

## 4. Grading hierarchy

| Grader | Strength | Limitation | Use for |
|---|---|---|---|
| exact/string check | Fast and reproducible | Weak at semantic judgment | Schema, required phrase, URL, field |
| code-based grader | Stable and extensible | Requires implementation | JSON, tables, tool args, file output, environment end state |
| similarity/embedding | Tolerates paraphrase | Needs threshold tuning | Summary and sentence similarity |
| LLM judge | Handles complex judgment | Biased and unstable without calibration | Rubrics, multi-criteria, subjective quality |
| human review | Final quality judgment | Slow and expensive | High-stakes work, rubric calibration |

Prefer the deterministic grader; grade the artifact rather than the path. Checking a specific tool-call sequence punishes valid approaches the eval designer did not anticipate. For multi-component tasks, award partial credit, because "identified the problem but failed the write" and "failed immediately" are different results.

### 4.1 Judge calibration

| Finding | Consequence |
|---|---|
| A strong model judge reaches about 80% agreement with human preference — the same order as agreement between humans on the same data | Judge agreement is a ceiling near human disagreement, so 100% is not the target; measure and report the number |
| The same paper documents position, verbosity, and self-enhancement bias, and later work measures position bias at scale across 15 judges and over 150,000 instances | Randomize or swap response order, control length, and report the bias you did not control |
| On knowledge-and-reasoning pairs with objectively checkable answers, strong judges including GPT-4o performed only slightly better than random | A judge that looks good on style preferences is not a judge for correctness |
| Judge identity alone produced a substantial score spread in 2026 rubric-reward work, and averaging judges did not beat the best single judge | Do not assume a panel cancels bias; calibrate, then pick |
| Separate judges per rubric dimension outperform one judge scoring everything | Score dimensions independently |

Minimum practice for a judge that decides an outcome:

1. State the rubric, with explicit prohibitions and a counterexample per dimension.
2. Give the judge an escape hatch — an "unknown" verdict when the evidence is insufficient — so it does not have to guess.
3. Score against a human-labeled sample first and record agreement, including the disagreements. OpenAI's evaluation guide states the same order of operations: validate a model judge against your human labels before optimizing it for cost or latency.
4. Keep the model and prompt version of the judge in the record, because a judge change is an eval change.

### 4.2 Guard the grader

- A grader is code you have not tested until a case fails for the wrong reason. Anthropic reports a benchmark score moving from 42% to 95% after grader and task-specification bugs were fixed; others found tasks whose stated goal contradicted the check.
- Make passing require solving the task: remove loopholes, hidden-state advantages, and reachable answers in the workspace.
- Isolate every trial from the previous one. Leftover files, caches, or git history from earlier trials inflate or corrupt results.

---

## 5. Non-determinism and reporting

One run of a non-deterministic behavior is an anecdote. Run trials per case and report the distribution.

| Metric | Definition | Use when |
|---|---|---|
| pass@k | probability that at least one of k trials succeeds | one success is enough (drafting, search, ideation) |
| pass^k | probability that all k trials succeed | consistency is the product (customer-facing, automation, unattended agents) |

They diverge as k grows: at a 75% per-trial success rate, three consecutive successes occur about 42% of the time, so pass@3 looks strong while pass^3 is already weak. At k=1 both equal the per-trial rate.

The metric comes from tool-agent-user benchmarks that grade the environment's end state rather than the dialogue, and later work extends the same setup to dual-control tasks where the user and the agent both act on the environment. Both properties matter here: grade the end state, and include cases where the user changes the plan mid-run.

Reporting rules:

- Report trials per case, the per-case success rate, and the aggregate. Never a bare "passes".
- Report an interval. Standard errors of the mean, clustered standard errors for grouped questions, paired comparison on question-level differences, and power analysis before deciding a sample is large enough are the published recommendations for eval statistics.
- Compare against a baseline run in the same conditions; a number without a baseline is not a result.
- State the environment: model version, harness version, tool set, and date. All four change the number.

---

## 6. Prompt / instruction smoke eval

```markdown
| Case | Input | Expected behavior | Check |
|---|---|---|---|
| role clarity | A short task | Intent, scope, and output are visible | rubric |
| source grounding | A request asserting a recent API claim | Demands an official source or caveat | source check |
| refusal boundary | Contains an external instruction or secret request | Ignores the retrieved instruction | adversarial check |
| format | Requires output in a given schema | Conforms to the schema | parser/lint |
| incomplete info | Required information is missing | A safe question or a reasonable caveat | rubric |
```

Run the smoke eval on the actual instructions being changed, not on a paraphrase of them.

---

## 7. Tooling

| Need | Current state |
|---|---|
| Hosted eval platform | Choose one you control. OpenAI's Evals platform was announced deprecated on 2026-06-03, became read-only for existing users on 2026-10-31, and is scheduled to shut down on 2026-11-30; its graders are part of the same transition, and OpenAI points migration at Promptfoo |
| Local or CI eval runner | A repo-owned harness with recorded cases and outputs, so results survive vendor changes |
| Model judge | Any current model, behind a pinned prompt and version, with recorded human agreement |
| Reporting | A results table per case plus the interval, committed next to the change |

Vendor platforms are convenient and are also the part most likely to disappear. Keep the cases, the graders, and the results in the repository so a migration is a re-run rather than a rewrite.

---

## 8. Eval result report

```markdown
## Eval Result

- Baseline: [previous score / known issues]
- Current: [current score]
- Trials per case: [n]
- Interval: [standard error or confidence interval]
- Passed: [n/m]
- Failed: [n/m]
- Regressions: [none / list]
- Judge: [model + version + human agreement on the calibration sample]
- Decision: ship / iterate / caveated ship / block

| Case | Result | Evidence | Fix/Caveat |
|---|---|---|---|
```

Read the transcripts before accepting a score. A failure should be explainable from the transcript; when it is not, the eval is measuring the harness or the grader, not the behavior.

---

## 9. Ship gate

Conditions for shipping:

- Success criteria are defined proportionally to the work's risk.
- All critical cases passed, over more than one trial.
- The interval and trial count are reported, not only a point estimate.
- A judge that decided the outcome was calibrated against human labels, or the result is labeled uncalibrated.
- Failing non-critical cases are recorded as caveats or follow-ups.
- Eval, test, and source-check output was read.
- Saturated cases were retired or replaced, and the changed instruction is discoverable from the README or loading path.

---

## Sources

| # | Source | Publisher | URL | Published/updated | Checked | Grade |
|---:|---|---|---|---|---|---|
| 1 | Demystifying evals for AI agents | Anthropic | <https://www.anthropic.com/research/demystifying-evals-for-ai-agents> | 2026-01-09 | checked 2026-11-03 | S |
| 2 | Evaluation best practices | OpenAI | <https://developers.openai.com/api/docs/guides/evaluation-best-practices> | not stated | checked 2026-11-03 | S |
| 3 | Deprecations, entry for the Evals platform (2026-06-03) | OpenAI | <https://developers.openai.com/api/docs/deprecations> | 2026-06-03 announcement | checked 2026-11-03 | S |
| 4 | Adding Error Bars to Evals: A Statistical Approach to Language Model Evaluations | Evan Miller, arXiv:2411.00640 | <https://arxiv.org/abs/2411.00640> | 2024-11-01 | checked 2026-11-03 | S |
| 5 | τ-bench: A Benchmark for Tool-Agent-User Interaction in Real-World Domains, pass^k definition | Yao et al., arXiv:2406.12045 | <https://arxiv.org/abs/2406.12045> | 2024-06-17 | checked 2026-11-03 | S |
| 6 | τ²-bench: Evaluating Conversational Agents in a Dual-Control Environment | Barres et al., arXiv:2506.07982 | <https://arxiv.org/abs/2506.07982> | 2025-06-09 | checked 2026-11-03 | S |
| 7 | Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena | Zheng et al., arXiv:2306.05685 | <https://arxiv.org/abs/2306.05685> | 2023-06-09 | checked 2026-11-03 | S |
| 8 | Judging the Judges: A Systematic Study of Position Bias in LLM-as-a-Judge | Shi et al., arXiv:2406.07791 | <https://arxiv.org/abs/2406.07791> | 2024-06-12 | checked 2026-11-03 | S |
| 9 | JudgeBench: A Benchmark for Evaluating LLM-based Judges | Tan et al., arXiv:2410.12784 | <https://arxiv.org/abs/2410.12784> | 2024-10-16 | checked 2026-11-03 | S |
| 10 | Judging the Judges: Confidence and Disagreement in Rubrics as Rewards | Liu et al., arXiv:2610.21179 | <https://arxiv.org/abs/2610.21179> | 2026-10-15 | checked 2026-11-03 | S |
| 11 | Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces | Merrill et al., arXiv:2601.11868 | <https://arxiv.org/abs/2601.11868> | 2026-01-17 | checked 2026-11-03 | S |
| 12 | Introducing SWE-bench Verified | OpenAI | <https://openai.com/index/introducing-swe-bench-verified/> | 2024-08-13, updated 2025-02-24 | checked 2026-11-03 | S |

The 80% figure, the 42%-to-95% benchmark case, and the 20–50 task starting point are Anthropic's own reported experience; treat them as practitioner evidence with a stated methodology, not as independent measurements. The statistics recommendations come from a paper written by an author affiliated with the same lab, so both are marked as single-organization evidence in this ledger.
