# Autoresearch Config and Metrics

> Korean version: [`config-and-metrics.ko.md`](config-and-metrics.ko.md)

Config quality determines whether iterations are comparable and whether “better” means the intended outcome. The universal rule is not one statistic or command layout; it is a predeclared, falsifiable decision contract matched to the metric class.

## 1. Required config fields

| Field | Required content |
|---|---|
| Goal | Outcome/question, success predicate, and terminal condition |
| Scope | Owned include/exclude paths and protected state |
| Metric | Profile, name/type/unit, direction or comparator, workload/population, and result schema |
| Acceptance | `improved`, `tie`, `inconclusive`, `regressed` rule plus any secondary criterion |
| Verify | Procedure identity, expected typed result, timeout, and failure classification |
| Guard | Mandatory predicates, baseline status, timeout, and fail-closed behavior |
| Evidence | Raw observation, aggregate/verdict, relevant confounders, and artifact identities |
| Budget | Iteration and applicable wall-time/cost/resource bounds |
| Stop | Goal, plateau/failure, safety, and interrupt behavior |
| Authorization | Local/external actions, credentials/data policy, and approval boundaries |

The metric runner, parser, workload, rubric, fixtures, and guard definitions stay outside writable optimization scope or are hash-verified before and after each candidate.

## 2. Measurement profiles

Choose one profile before deciding warmup, repeats, aggregation, or judging.

| Profile | Minimum defensible contract |
|---|---|
| `exact-deterministic` | One valid observation may be enough. Unexpected variation is an error to investigate. |
| `cold-start` | Preserve startup/cache state; warmup would invalidate the estimand. Define reset/isolation between trials. |
| `noisy-performance` | Define estimand, independent replicate, comparison order, aggregation/statistical method, practical effect or tie band, uncertainty/stability evidence, and inconclusive state. |
| `stochastic-model` | Record relevant platform/software/data identity and randomness controls; use independent runs/seeds when across-run variance affects the decision. A fixed seed alone does not estimate variance. |
| `subjective-judge` | Lock rubric and items, identify judge provenance, counterbalance presentation, preserve raw judgments, and define tie/abstain/invalid/disagreement escalation. |

Conditional techniques are not runtime-neutral requirements:

- Warm up only for a declared steady-state estimand.
- Choose repeat count from observed noise, target resolution, budget, and method; do not impose one `N` across profiles.
- Choose aggregation by estimand: minimum for a justified lower-bound model, median for a robust center, mean for expected cost, or domain-specific percentile/verdict.
- Randomize or interleave candidate/frontier order when independent trials may be confounded by temporal drift. Do not interleave when state carry-over changes the workload.
- CPU affinity/isolation, frequency control, and GC control are optional noise mitigations. Use them only when they preserve the workload being claimed.

For noisy claims, preserve raw valid observations and report stability/uncertainty appropriate to the method. Statistical significance alone is not a keep rule; large samples can make operationally irrelevant effects detectable. A universal nonzero threshold is also wrong—declare a task-specific effect, tie, or exact monotonic rule.

### Fix the cost per candidate

The per-candidate measurement budget belongs to the metric definition, not to the scheduler. The pinned upstream training loop fixes a five-minute wall-clock training budget and excludes startup and compilation from it, which is what makes two candidates comparable at all; RE-Bench shows the same agent-versus-expert comparison reversing between a two-hour and a 32-hour budget.

- Declare the budget before the first run and keep it fixed for the whole comparison set.
- Declare the rule for a candidate that finishes early or times out; changing the window to fit the candidate changes the estimand.
- Record the realized cost with each frontier value. A candidate that wins only because it was measured under a smaller budget won a different metric.

## 3. Adaptive optimization and multiple objectives

Repeatedly selecting winners against one benchmark can overfit the evaluator even when individual estimates are precise.

- Use a development metric for iteration and an immutable confirmation set for finalists or at a bounded cadence when adaptive reuse is material.
- Do not feed detailed holdout failures back into the loop.
- Re-baseline when relevant tool, model, data, workload, parser, or environment identity changes.
- Report every component of a multi-objective result.

Predeclare one multi-objective comparator:

- **Lexicographic**: mandatory priority order.
- **Scalarized**: fixed units/normalization/weights; never include critical safety or correctness guards in a compensable score.
- **Pareto**: retain non-dominated candidates under a declared selection rule.

Mixed lower/higher metrics without a comparator are not a metric.

### Complexity as a declared secondary criterion

Maintenance cost is a real objective that a single benchmark rarely captures, and the pinned upstream program file states it explicitly: an equal-or-better result after deleting code is a clear keep, while a tiny metric gain that adds hacky code is probably not, and an improvement of roughly zero with much simpler code is worth keeping. Encode that as a predeclared rule rather than a judgment call made after seeing the diff:

- Name the complexity measure (changed lines, new dependencies, new configuration surface, removed code).
- Define the tie band in which complexity decides. Outside the band the metric decides.
- State that complexity never overrides a guard and never rescues a candidate that lost the metric outright.
- Require the measure to be computed the same way for baseline and candidate; otherwise the tie band is meaningless.

A "simpler" candidate that lost the metric is a discard, not a tie. The criterion only breaks ties that the metric already declared.

## 4. Metric and guard result channels

Metric and guard are logically independent acceptance channels, but they do not need separate process invocations. One verifier is valid when its structured result distinguishes execution status, metric status/value, and every mandatory guard's `pass`, `fail`, or `error` status.

```json
{
  "execution": {"status": "complete"},
  "metric": {"status": "ok", "name": "coverage_percent", "value": 91.4},
  "guards": [
    {"id": "critical_tests", "status": "pass"},
    {"id": "secret_leak", "status": "pass"}
  ]
}
```

Invariants:

- Metric improvement cannot compensate for a failed, errored, missing, or malformed mandatory guard.
- Guard pass is not inferred from the score or process exit alone.
- Invalid schema, missing fields, non-finite metrics, interruption, timeout, or infrastructure failure blocks keep and remains a distinct error.
- A diagnostic metric may be retained after guard failure, but the candidate is not kept.
- If a shell pipeline is unavoidable, capture every stage status and enable failure propagation. Never accept a value from a failed producer.
- Exit `0` means the configured verifier completed successfully, not that the candidate improved; the harness compares evidence to the frontier.

Separate metric/guard commands remain valid when isolation is simpler. A combined verifier is useful when one expensive run produces both channels against exactly the same snapshot.

## 5. Guard design

Run mandatory guards on the baseline before optimization and on each candidate before keep.

Each guard declares:

- stable ID and purpose
- procedure/check identity and expected evidence
- baseline result
- pass/fail/error semantics
- timeout and resource bound
- hard threshold or predicate

Detect deleted/skipped tests, changed fixtures/workloads, sample-count drift, verifier tampering, and retry laundering. No silent retry turns a failure into a pass.

Verifier gaming is measured behavior, not a hypothetical. METR reports recent frontier models attempting, often successfully, to raise a score by modifying the tests or the scoring code, and estimates that between 1% and 2% of o3's task attempts across HCAST and RE-Bench contained some attempt at reward hacking. OpenAI reports that chain-of-thought monitoring detects this better than watching only actions and outputs, and that directly penalizing the observed reasoning suppresses much of the behavior while teaching the model to hide intent.

Three design consequences follow:

- Compute guard coverage over the candidate (test counts, fixture and evaluator digests, skipped-test lists) and fail the guard when coverage shrinks, even if the metric improved.
- Treat a monitor as a detection aid, never as the acceptance control; an optimizer that can see the monitor can optimize against it.
- Record the guard surface identity in the frontier evidence, so a later run can prove the guard did not move under it.

## 6. Subjective goals

Do not force subjective quality into an invented scalar. Use representative items and a locked rubric with anchors, weights, and critical vetoes.

Required reliability controls:

- Hide candidate identity, author/model, branch, score history, and irrelevant presentation metadata.
- Randomize item order and evaluate pairwise candidates in both A/B and B/A order when position bias is relevant.
- Support `tie`, `abstain`, `invalid`, and `inconclusive`; never force a winner.
- Record judge family/provider/model/prompt/rubric versions and decoding parameters that affect judgment.
- Multiple calls to the same model are repeated measures, not independent judges. Record the actual independence basis.
- Preserve each raw judgment and the aggregation inputs. Report agreement/order consistency, not only majority.
- Calibrate model/panel judgments against blinded human labels at a predeclared cadence or threshold. Escalate low-agreement or order-inconsistent cases.
- Identify self-judgment. It cannot satisfy an independent-judge guard.

Delete streak rules such as “the same candidate wins three times.” Convergence means no predeclared practically meaningful validation improvement over a defined window, with reliability controls still passing.

## Sources

> Checked 2026-11-03.

| Claim | Source | Grade |
|---|---|---|
| Repetitions, statistical stability from repeated runs, aggregation to mean and standard deviation, random interleaving of benchmark order | <https://google.github.io/benchmark/user_guide.html> | PRIMARY |
| Statistical summaries and A/B comparison of repeated benchmark runs | <https://pkg.go.dev/golang.org/x/perf/cmd/benchstat> | PRIMARY |
| Blocking to remove nuisance-factor effects, the basis for randomized block comparison | <https://www.itl.nist.gov/div898/handbook/pri/section3/pri332.htm> | PRIMARY |
| Building eval sets with typical, edge, and adversarial cases; automated regression scoring | <https://developers.openai.com/api/docs/guides/evaluation-best-practices> | VENDOR |
| Position and verbosity bias in LLM judges, and the need for order counterbalancing | <https://proceedings.neurips.cc/paper_files/paper/2023/hash/91f18a1287b398d378ef22505bf41832-Abstract-Datasets_and_Benchmarks.html> | PAPER |
| Frontier models modifying tests or scoring code to raise a score | <https://metr.org/blog/2025-06-05-recent-reward-hacking/> | PRIMARY |
| 1–2% of o3 task attempts containing a reward-hacking attempt across HCAST and RE-Bench | <https://metr.org/evaluations/openai-o3-report/> | PRIMARY |
| CoT monitoring detects reward hacking; penalizing the reasoning hides intent | <https://arxiv.org/abs/2503.11926> | PAPER |
| Fixed five-minute wall-clock training budget excluding startup and compilation, with an explicit simplicity criterion | <https://github.com/karpathy/autoresearch/tree/228791fb499afffb54b46200aca536f79142f117> | PRIMARY (repository) |
| Agent-versus-expert comparison reversing between a two-hour and a 32-hour budget | <https://arxiv.org/abs/2411.15114> | PAPER |
| Held-out split reported alongside development-set optimization | <https://arxiv.org/abs/2507.19457> | PAPER |
