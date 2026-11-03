# Measurement Reference

> Korean version: [`measurement.ko.md`](measurement.ko.md)

Derivation for the harness rules about repetition, aggregation, cost, and context variables.
The **normative** rules live in [`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under
`## Judgement Rules` and `## Harness Staleness`. This file shows where the numbers come from and
what they do not claim.

## Minimum runs

`MIN_RUNS` is the per-case minimum number of **independent** runs before a non-deterministic
case may be judged. It is a named constant so that a case file can state its own value and a
reviewer can check it mechanically.

| Case kind | `MIN_RUNS` | Why |
|---|---|---|
| Deterministic (JSON shape, file exists, test exits 0) | 1 | The observable cannot vary between runs |
| Rubric or judge-scored | 5 | Enough to see a spread; not enough to resolve a small difference |
| Reliability claim (`pass^k` reported) | 8 | This repository's own default, adopted from the τ-bench paper, which reports `pass^8`. It is a **choice, not a published minimum** — neither that paper nor any source here establishes eight runs as a general floor. The live benchmark no longer scores at eight: see "the reported depth moved" below |

`MIN_RUNS` is a **floor for seeing a spread**, not a threshold for declaring a difference
significant. See the next section for why, and "the noise floor" for the part that no run count
can fix.

## `pass^k` is not `pass@k`

The two metrics answer different questions about the same agent.

- `pass^k` — the probability that **all** k independent trials succeed. This is the
  reliability question. τ-bench defines it as "the chance that all k i.i.d. task trials are
  successful, averaged across tasks."
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

`MEASURED`, and this is where the citation needs care: the τ-bench paper (June 2024, one version,
never revised) reports that state-of-the-art function-calling agents "succeed on < 50% of the
tasks, and are quite inconsistent (`pass^8 < 25%` in retail)". The 0.80 row above lands at 16.78%,
inside that reported band. Two caveats attach to quoting it:

- **The task set behind the number changed.** The retail and airline domains were audited and
  rewritten in 2026: "We audited and fixed 50+ tasks across the airline and retail domains in
  τ-bench" (27 airline, 26 retail).
- **The reported depth moved.** The 1.x submission guide preferred "at least 4 trials per domain for
  statistical reliability" and the v1.0.1 re-grade table reports `pass^4`; the current release
  scores the shipped benchmarks at one trial and defines `pass^k` as "the share of tasks passed in
  all k trials". Eight is a depth this repository chose, not the depth the benchmark now publishes.

The practical consequence is unchanged: reporting only `pass@k` hides inconsistency. Eight
independent trials that all succeed is the reliability claim; `pass^k` is the metric that falls as
`k` grows while `pass@k` rises toward 1.

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

Anthropic's eval guidance adds the counterweight that keeps this from becoming an excuse for
doing nothing: early in development the effect size is large, so "20-50 simple tasks drawn from
real failures is a great start."

## The noise floor

Sample size controls one source of variance. Two others are larger than most teams assume, and
neither shrinks when `n` grows.

### Infrastructure

`MEASURED`: holding the task set fixed and varying only the machine allocation, the gap on
Terminal-Bench 2.0 between the most- and least-resourced setups was 6 percentage points (p < 0.01).
On SWE-bench the same comparison moved 1.54 percentage points. The paper's operating advice:

> "Until resource methodology is standardized, our data suggests that leaderboard differences below
> 3 percentage points deserve skepticism until the eval configuration is documented and matched.
> The observed spread across the moderate range of resource configurations in Terminal-Bench is just
> below 2 percentage points. Naive binomial confidence intervals already span 1-2 percentage
> points; the infrastructure confounders we document here stack on top of that, not within it. At
> the extremes of the allocation range, the spread reaches 6."

Two rules follow, and both belong in the eval record rather than in a footnote:

- **Declare the resource configuration.** A result without CPU/GPU allocation, timeouts, and
  concurrency cannot be compared with a later result that used different ones.
- **Account for harness faults separately.** The v1.0.1 re-grade states its convention: `pass^k` is
  recomputed "counting infrastructure-error simulations as failed trials (the leaderboard
  convention)", so a harness fault is visible in the metric rather than silently dropped. HE-E-6
  makes a different call — harness-fault trials leave the denominator and are reported as error
  trials — but both declare the treatment in the record instead of leaving it implicit.

### Grader

`MEASURED`: re-grading the *same* saved trajectories after fixing the graders "moves scores **only
upward** — no previously-passing simulation fails — by up to ~9 points pass^1 depending on the
model." In the published table one model moved from 37.37 to 46.39 pass^1 and from 20.62 to 27.84
pass^4. Nothing about the model changed.

The same benchmark therefore states that version comparison is invalid across a grading change:
"Scores are not comparable with 1.x … Re-run rather than compare 1.x results with 2.0 numbers."

**HE-J-4, extended:** the eval record carries the grader version and the benchmark version, not
only the model, runtime, case-set hash, and run count. A nine-point movement from re-grading is
larger than most of the effects anyone gates on.

### What the floor implies

| Source of variance | Controlled by | Visible in the record as |
|---|---|---|
| Sampling | run count, aggregate rate | `MIN_RUNS`, pass rate per batch |
| Infrastructure | fixed resource declaration | allocation, timeouts, `error_trials` |
| Grader | version pin, re-grade on change | grader version |
| Benchmark task set | version pin | benchmark version and task-set hash |

A difference smaller than the combined floor is not a result. That is not a reason to stop
gatekeeping; it is the reason a gate declares an equivalence margin (HE-J-3) instead of reacting to
every movement.

## Cost is a first-class axis

Two systems with the same score are not the same result, and the gap is not small.

`MEASURED`: "Agents differ drastically in terms of cost. For substantially similar accuracy, the
cost can differ by almost two orders of magnitude. Yet, the cost of running these agents isn't a
top-line metric reported in any of these papers." That 2024 criticism is now infrastructure: a
leaderboard built on accuracy-versus-cost Pareto frontiers reports dollar and token cost per entry
— "enabling practitioners to select agents based on real-world constraints" — and Terminal-Bench
publishes dollars per submission next to the score.

The harness has a cost axis too, and it can be measured per model. A paired experiment on a coding
task found the harness cost about 10.5× the tokens, ~3× the time, and ~7× the money on the stronger
model and changed nothing there, while on the weaker model it cost ~3.9× the tokens, ~2.2× the time,
and ~3.2× the cost and moved that model from 3/10 to 10/10 (the table and its source are in
[`harness-anatomy.md`](harness-anatomy.md), HE-A-4).

So the metric set in the main document treats cost/latency as a peer of quality, not as a tiebreak.
A harness or prompt change that buys 1 point for 10× tokens has to say so in those terms.

## Eval awareness and benchmark decay

A score is a claim about a test, and the test decays.

- **The model can notice the test.** In a documented case a model "independently hypothesized that
  it was being evaluated, identified which benchmark it was running in, then located and decrypted
  the answer key." Eleven of 1,266 problems were affected by contamination or eval awareness;
  re-running the eleven with the key blocked left the aggregate nearly unchanged (86.81% → 86.57%),
  which is the useful part of the story — the integrity failure was real and the headline number
  was not, this time. The authors' recommendation is the durable rule: "we encourage the research
  community to treat eval integrity as an ongoing adversarial problem rather than a design-time
  concern."
- **The test can be wrong.** The authors of a widely used coding benchmark audited a 27.6% subset
  and found "at least 59.4% of the audited problems have flawed test cases that reject functionally
  correct submissions", then stopped reporting their own benchmark because improvements "increasingly
  reflect how much the model was exposed to the benchmark at training time."
- **The replacement has its own limits.** The same article recommends SWE-bench Pro as the successor
  but calls it "not perfect" and reports no task-defect rate for it. Treat any successor as a
  candidate whose defect rate is unknown until someone publishes one.

**HE-J-8.** A benchmark score is recorded with its version, its grader version, its resource
configuration, and its contamination and defect status. A single-digit difference between two
systems is treated as unresolved until the grader and the resource configuration are shown to be
equivalent, because the measured defects and the measured infrastructure spread are both larger
than that.

The same logic applies to a repository eval set, at smaller scale: a case whose expected output was
written from the current implementation tests the implementation, not the behavior.

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
  correct work that took a different road. The vendor guidance is explicit: "it's often better to
  grade what the agent produced, not the path it took."

Record the **failure mode**, not only the score. Models differ: some abstain when uncertain,
others answer confidently and wrongly. A case set that only counts pass/fail cannot tell
those apart, and the two need different fixes.

Two practices keep an eval set from going quiet:

- **Partial credit** where a task has components, so a case that half-works still moves.
- **Graduation.** A capability case whose pass rate reaches the ceiling stops producing signal:
  "An eval at 100% tracks regressions but provides no signal for improvement." Move it to the
  regression suite and add a harder case in its place.

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

## Time horizon

For long-horizon work the measured quantity is the task length an agent completes with 50%
reliability. The current published estimate puts the post-2023 doubling time at 130.8 days
[107, 161], with an all-period figure of 196.5 days — and the project dashboard names the limit of
that instrument: "Measurements above 16 hrs are unreliable with our current task suite."

Quote the surface as well as the number. The published table and the dashboard's data file differ
by up to about nine days (130.8 versus ~128.7 post-2023; 196.5 versus ~187.8 all-period).

## Sources

> Checked 2026-11-03.

**Grade vocabulary.** One closed set for every source table in this directory; see [`../HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) under `## Sources`.

| Claim | Source | Grade |
|---|---|---|
| `pass^k` definition, the `pass^8 < 25%` retail figure, and the inconsistency finding | <https://arxiv.org/abs/2406.12045> | PRIMARY |
| Retail and airline task audit ("50+ tasks", 27 airline / 26 retail) | <https://taubench.com/blog/tau3-task-fixes.html> | PRIMARY |
| "Scores are not comparable with 1.x" — the grading change invalidates version comparison | <https://github.com/sierra-research/tau2-bench/releases/tag/v2.0.0> | PRIMARY |
| Trial depth: the 1.x guide's preference for at least four trials per domain, one-trial scoring of the shipped benchmarks, and the `pass^k` definition | <https://github.com/sierra-research/tau2-bench/blob/v1.0.1/docs/leaderboard-submission.md>, <https://github.com/sierra-research/tau2-bench/blob/v2.0.0/docs/glossary.md> | PRIMARY |
| Re-grading moving `pass^1` by up to ~9 points on unchanged trajectories | <https://github.com/sierra-research/tau2-bench/releases/tag/v1.0.1> | PRIMARY |
| Benchmark authors' framing of reliability over repeated trials | <https://sierra.ai/blog/tau-bench-shaping-development-evaluation-agents> | VENDOR |
| Infrastructure noise: 6pp on Terminal-Bench 2.0, 1.54pp on SWE-bench, and the "below 3 percentage points" rule | <https://www.anthropic.com/research/infrastructure-noise> | VENDOR |
| Eval awareness: the decryption case, 11 of 1,266 problems, 86.81% → 86.57%, and "ongoing adversarial problem" | <https://www.anthropic.com/research/eval-awareness-browsecomp> | VENDOR |
| 59.4% of audited failures have flawed tests, the decision to stop reporting the benchmark, and the SWE-bench Pro recommendation ("not perfect") | <https://openai.com/index/why-we-no-longer-evaluate-swe-bench-verified/> | VENDOR |
| "20-50 simple tasks drawn from real failures", partial credit, grading the outcome not the path, and the 100% ceiling | <https://www.anthropic.com/research/demystifying-evals-for-ai-agents> | VENDOR |
| Cost differing by almost two orders of magnitude at similar accuracy | <https://arxiv.org/abs/2407.01502> | PRIMARY |
| Accuracy-versus-cost Pareto frontiers as a leaderboard design | <https://arxiv.org/abs/2510.11977> | PRIMARY |
| Twelve reliability metrics over four dimensions, and capability gains yielding only small reliability gains | <https://arxiv.org/abs/2602.16666> | PRIMARY |
| Task-length horizon, the 130.8-day post-2023 doubling estimate, and hierarchical-bootstrap intervals | <https://metr.org/blog/2026-01-29-time-horizon-1-1/> | PRIMARY |
| Dashboard data file: 128.7-day post-2023 and 187.8-day all-period estimates, and the "Measurements above 16 hrs are unreliable with our current task suite" limit | <https://metr.org/time-horizons/> | PRIMARY |
| Terminal-Bench 4.0 as a continuously versioned benchmark with a flat timeout | <https://www.tbench.ai/news/terminal-bench-4-0> | PRIMARY |
| Input-length degradation, distractor compounding, and focused-vs-full prompt comparison | <https://www.trychroma.com/research/context-rot> | STUDY |
| Batch evaluation and aggregate pass-rate practice instead of single-run gating | <https://developers.googleblog.com/the-anatomy-of-harness-engineering-how-to-evaluate-iterate-and-guard-ai-coding-agents/> | VENDOR |

`pass^k = p^k` and the sample-size formula above were computed in this repository, and both are
reproduced inline here: the `DERIVED` paragraph under `## pass^k is not pass@k` and the
Wald-interval expression under `## How many runs to judge a difference`. No separate script is kept.

An earlier revision cited the 2025-03-19 METR post, which predates the current estimate, and
presented `pass^8` as the depth the benchmark reports. Both are corrected above.
