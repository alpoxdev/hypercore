# Measurement Reference

> Korean version: [`measurement.ko.md`](measurement.ko.md)

Derivation for the harness rules about repetition, aggregation, and context variables.
The **normative** rules live in [`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under
`## Judgement Rules`. This file shows where the numbers come from and what they do not claim.

## Minimum runs

`MIN_RUNS` is the per-case minimum number of **independent** runs before a non-deterministic
case may be judged. It is a named constant so that a case file can state its own value and a
reviewer can check it mechanically.

| Case kind | `MIN_RUNS` | Why |
|---|---|---|
| Deterministic (JSON shape, file exists, test exits 0) | 1 | The observable cannot vary between runs |
| Rubric or judge-scored | 5 | Enough to see a spread; not enough to resolve a small difference |
| Reliability claim (`pass^k` reported) | 8 | This repository's own default, adopted because τ-bench reports `pass^8`. It is a **choice, not a published minimum** — neither that paper nor any source here establishes eight runs as a general floor |

`MIN_RUNS` is a **floor for seeing a spread**, not a threshold for declaring a difference
significant. See the next section for why.

## `pass^k` is not `pass@k`

The two metrics answer different questions about the same agent.

- `pass^k` — the probability that **all** k independent trials succeed. This is the
  reliability question.
- `pass@k` — the probability that **at least one** of k trials succeeds. This is the
  capability question.

`DERIVED`: for a per-trial success rate p, `pass^k = p^k` and `pass@k = 1 − (1 − p)^k`.
These are exact, not estimates.

| per-trial p | `pass^k` (k=8) | `pass@8` (rounded) |
|---|---|---|
| 0.50 | 0.39% | 99.61% |
| 0.60 | 1.68% | 99.93% |
| 0.70 | 5.76% | 99.99% |
| 0.80 | 16.78% | 100.00% |

No row reaches exactly 100%, though 0.80 rounds to it at two decimal places. `pass@k` approaches 1
quickly, which is the point: at p=0.50 it is already 99.61%, so a `pass@k` column carries almost no
information about consistency.

`MEASURED`: the τ-bench authors report that state-of-the-art function-calling agents succeed
on under 50% of their tasks and are "quite inconsistent (`pass^8 <25%` in retail)". The
0.80 row above lands at 16.78%, inside that reported band.

The practical consequence: reporting only `pass@k` hides inconsistency. Eight independent trials that
all succeed is the reliability claim; `pass^k` is the metric that falls as `k` grows while `pass@k`
rises toward 1.

## How many runs to judge a difference

`DERIVED`: to estimate a per-case success rate to within a half-width `h` at 95% confidence,
assuming independent runs and invoking the normal approximation,

```
n ≈ (1.96 · sqrt(p(1−p)) / h)²
```

This is the Wald interval, an **approximation**, not an identity: it is unreliable for p near 0 or 1
and for very small `n`. The counts below are the **ceiling** of that expression — a run count is an
integer, and rounding down would under-deliver the stated width.

| per-trial p | n for ±5pp | n for ±10pp |
|---|---|---|
| 0.50 | 385 | 97 |
| 0.70 | 323 | 81 |
| 0.90 | 139 | 35 |

**What this does and does not claim.** It claims that a handful of runs cannot resolve a
small difference: at p=0.70, five runs give a 95% interval roughly ±40 percentage points wide, so a
regression has to be very large before that sample could distinguish it from noise. It does **not**
claim that 323 is a number to write into a gate, and it does not convert an interval half-width into
a **minimum detectable difference** — that is a power calculation, which needs an assumed effect size
and is not what this formula computes. Correlated runs (same seed, same cache, same warm service)
need more runs, not fewer.

The rule this supports: state the target interval width and the run count **together**, and
gate on the aggregate trend across a batch rather than on a single run's verdict.

## Behavioral evals and end-to-end benchmarks

They measure different things and neither replaces the other.

| | Behavioral eval | End-to-end benchmark |
|---|---|---|
| Unit | one observable action | the whole task |
| Example assertion | the agent consulted live search before answering | the task's final state matches the goal |
| Failure signal | precise: which action was skipped | coarse: the composite score moved |
| Cost | seconds per case | far more per task |
| Use it to | iterate on a prompt, a tool schema, a model swap | confirm the destination still works |

Assertion strictness should follow task complexity:

- **One optimal path** — assert the specific action strictly (single-turn check).
- **Many valid paths** — assert the outcome, not the route. A rigid tool sequence rejects
  correct work that took a different road.

Record the **failure mode**, not only the score. Models differ: some abstain when uncertain,
others answer confidently and wrongly. A case set that only counts pass/fail cannot tell
those apart, and the two need different fixes.

## Context as a recorded variable

Context length is an experimental variable, not a constant. Record it per case:

- total context tokens at the decision point,
- number of distractor items included,
- whether the relevant information was pre-loaded or retrieved just in time.

`MEASURED`: in a controlled study holding task difficulty constant and varying only input
length, all 18 tested models degraded as input length grew; a single distractor degraded
performance and four compounded it; and focused prompts (~300 tokens) substantially
outperformed full prompts (~113k tokens) on the same question.

**Do not turn that finding into a context rule.** The study's authors state that two topics
are not enough to generalize from, and that they measured a specific retrieval task. What is
safe to write down is the measurement rule: a comparison that changes context length is a
different case, and it must be labeled as such.

The related rule that *is* normative lives in the main document: added context is an
intervention, and it does not become permanent context until it improves the target eval set.

## Sources

> Checked 2026-09-20.

| Claim | Source | Grade |
|---|---|---|
| `pass^k` definition, the `pass^8 <25%` retail figure, and the inconsistency finding | <https://arxiv.org/abs/2406.12045> | PRIMARY |
| Benchmark authors' framing of reliability over repeated trials | <https://sierra.ai/blog/tau-bench-shaping-development-evaluation-agents> | VENDOR |
| Task-length horizon metric and hierarchical-bootstrap confidence intervals | <https://metr.org/blog/2025-03-19-measuring-ai-ability-to-complete-long-tasks/> | PRIMARY |
| Input-length degradation, distractor compounding, and focused-vs-full prompt comparison | <https://www.trychroma.com/research/context-rot> | STUDY |
| Batch evaluation and aggregate pass-rate practice instead of single-run gating | <https://developers.googleblog.com/the-anatomy-of-harness-engineering-how-to-evaluate-iterate-and-guard-ai-coding-agents/> | VENDOR |

`pass^k = p^k` and the sample-size formula above were computed in this repository; see
`.omo/ulw-research/20260919-173136-harness-engineering/verification/passk_sim.py`.
