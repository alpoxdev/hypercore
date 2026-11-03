# Autoresearch Prior Art and Benchmarks

> Korean version: [`prior-art-and-benchmarks.ko.md`](prior-art-and-benchmarks.ko.md)

This document records what published systems and benchmarks establish about metric-driven autonomous iteration, and what they do not establish. They are design evidence, not endorsements, deployment targets, or proof that an unattended loop produces valid results in your project.

## 1. The shared outer loop

Every system surveyed here runs the same shallow loop: propose a candidate, score it with an automated evaluator, select or reject, repeat. They differ in how wide the search is and how much each candidate costs.

| System | Candidate surface | Evaluation | Selection memory |
|---|---|---|---|
| AlphaEvolve (white paper, 2025-06) | source code of a program | one or more automated evaluators | programs database implementing an evolutionary algorithm |
| ShinkaEvolve (2025-09) | program code, LLM as mutation operator | evaluator per candidate | archive of evaluated programs |
| Darwin Gödel Machine (2025-05, ICLR 2026) | the agent's own scaffolding code | coding benchmarks (SWE-bench, Polyglot) | archive of self-modified agents |
| `karpathy/autoresearch` (2026-03) | one file, `train.py` | fixed 5-minute training run, `val_bpb` | one advanced branch, `results.tsv` log |
| OpenEvolve (open source) | program code | problem-defined scorer | MAP-Elites plus island populations |

Two consequences for a design standard:

- The loop shape is easy to state and hard to make trustworthy. Each system above pins three things before searching: the candidate surface (which files may change), the evaluator (which code scores a candidate), and the cost per candidate. A loop that leaves any of the three implicit produces attempts that cannot be compared.
- Selection memory is a budget decision, not a taste decision. A single frontier is appropriate when each evaluation is expensive and the metric is smooth; an archive or population pays for itself when evaluations are cheap relative to the search and the metric has many local optima. If you keep several lineages, each one needs its own frontier identity, restore path, and attribution, which is the cost that a single frontier avoids.

## 2. Benchmarks normalize by budget, not by score

| Benchmark | Scale | Scoring | Headline result at publication |
|---|---|---|---|
| MLE-bench (OpenAI, 2024-10) | 75 Kaggle ML-engineering competitions | medal thresholds calibrated against human leaderboards | o1-preview with AIDE scaffolding reached at least bronze-medal level in 16.9% of competitions |
| RE-Bench (METR, 2024-11) | 7 open-ended ML research-engineering environments, 71 eight-hour attempts by 61 human experts | normalized score, human baseline | best agents scored about 4× human experts at a 2-hour budget; humans narrowly exceeded the best agent at an 8-hour budget and reached about 2× the best agent's score at 32 total hours |

RE-Bench is the clearest published demonstration that an agent ranking is a function of the time budget: the same comparison reverses between 2 hours and 32 hours. A benchmark score without its budget triple (agent, time, compute) is not a measurement. Apply the same rule inside a project loop: the per-candidate measurement budget belongs to the metric definition, not to the scheduler, because changing it silently invalidates every stored frontier value.

MLE-bench also shows the ceiling of external calibration. The benchmark itself is a proxy built from public competitions; a project's own metric has no such calibration, so cross-project comparisons of "improvement" are not meaningful.

## 3. Long-horizon research agents

- **AI Scientist-v2** (2025-04) runs hypotheses, experiments, analysis, and manuscript writing end to end, and reports the first entirely AI-generated paper to clear a workshop peer-review threshold. That is a workshop-level acceptance, not validation of the system's scientific claims.
- **Kosmos** (2025-11) reports runs of up to about 12 hours and roughly 200 agent rollouts per objective, with a structured world model to carry information between steps. Its stated constraint is the number of actions an agent can take before losing coherence.
- **Co-Scientist** (2025-02) generates and ranks hypotheses through a multi-agent tournament, with in-vitro validation of selected hypotheses reported by the authors.

The design lesson is not "run longer." It is that long autonomous runs are bounded by coherence and by human validation of the output, so the run must checkpoint: an uninterrupted multi-hour loop with no persisted frontier and no resumable state is unrecoverable on failure, and its findings cannot be separated from its own drift.

## 4. Eval-driven optimization of instructions

**GEPA** (2025-07, ICLR 2026 oral) treats a prompt or program as the candidate and trajectory feedback as the mutation signal, reporting a 10% average improvement over GRPO (up to 20%) with up to 35 times fewer rollouts, and reporting results on a held-out test split. The same contract applies when the artifact under optimization is an instruction file rather than code: the candidate is text, the compile error is an eval failure, and a held-out split is still required because the optimizer is directly fitting the development set.

## 5. What this evidence does not support

- No peer-reviewed result shows an unattended loop producing validated scientific discovery at production scale. The strongest public claim is a workshop-level acceptance.
- Benchmark scores do not transfer to a project metric. MLE-bench medals and RE-Bench normalized scores are calibrations against human baselines on public tasks, not predictions for your workload.
- The `karpathy/autoresearch` experiment is single-GPU and platform-specific by its own statement; its 12-experiments-per-hour and 100-per-overnight figures are estimates, and its results are explicitly not comparable across compute platforms. Its README frames the training setup as a simplified single-GPU implementation of the author's `nanochat`, and no successor repository replaces it: the pinned commit is still the repository head.
- ShinkaEvolve's sample-efficiency result is per problem family; it is not a universal evaluation budget.
- The AlphaEvolve publication is a self-described white paper, and the reproduced result (a 4×4 complex matrix product in 48 scalar multiplications, the first improvement on Strassen in this setting in 56 years) is a single demonstrated target, not a general capability claim.
- Self-reported loop improvements inside a vendor's own harness are secondary evidence about that harness, not about the underlying method.

## 6. Applying the prior art to a project loop

1. Make the candidate surface explicit and small; every surveyed system restricts it, and most allow exactly one artifact to change.
2. Pin the evaluator outside the mutable set. `karpathy/autoresearch` marks `prepare.py` read-only and forbids touching the evaluation harness, which is the same rule as our guard-integrity requirement.
3. Fix the cost per candidate before the first run, and record it with each frontier value.
4. Add an archive only when you accept the per-lineage bookkeeping cost.
5. Treat cross-benchmark transfer as unproven and test it explicitly if you rely on it.
6. Keep human validation as a separate gate for anything that claims a discovery rather than an improvement.

## Sources

> Checked 2026-11-03.

| Claim | Source | Grade |
|---|---|---|
| Evolutionary loop, programs database, 4×4 complex matrix product in 48 scalar multiplications | <https://arxiv.org/abs/2506.13131> | PRIMARY (white paper, not peer reviewed) |
| Archive of evaluated programs, sample-efficiency framing | <https://arxiv.org/abs/2509.19349> | PAPER |
| Self-modifying agent, SWE-bench 20.0% → 50.0%, Polyglot 14.2% → 30.7% | <https://arxiv.org/abs/2505.22954> | PAPER (ICLR 2026) |
| Open-source AlphaEvolve-style implementation using MAP-Elites and islands | <https://github.com/algorithmicsuperintelligence/openevolve> | PRACTITIONER |
| 75 Kaggle competitions, 16.9% bronze-medal level for o1-preview with AIDE | <https://arxiv.org/abs/2410.07095> | PAPER |
| 7 environments, 71 eight-hour expert attempts, 4× at two hours, humans narrowly ahead at eight hours and about 2× at 32 hours | <https://arxiv.org/abs/2411.15114> | PAPER |
| End-to-end agentic research system, workshop-level acceptance | <https://arxiv.org/abs/2504.08066> | PAPER |
| Up to 12-hour runs, ~200 rollouts, coherence limit | <https://arxiv.org/abs/2511.02824> | PAPER |
| Multi-agent hypothesis tournament with in-vitro validation | <https://arxiv.org/abs/2502.18864> | PAPER |
| Reflective prompt evolution, 10% average / up to 20% over GRPO with up to 35× fewer rollouts | <https://arxiv.org/abs/2507.19457> | PAPER (ICLR 2026 oral) |
| Single-GPU loop, fixed 5-minute budget, `val_bpb`, `results.tsv`, platform dependence, read-only `prepare.py` | <https://github.com/karpathy/autoresearch/tree/228791fb499afffb54b46200aca536f79142f117> | PRIMARY (repository) |
| Fourteen-command harness, hook coverage per runtime, bounded-by-default iterations | <https://github.com/uditgoenka/autoresearch/tree/7bddd056dfd0b0ded8360588d8101b1ecb5c0baa> | PRIMARY (repository) |

Every system above is third-party evidence about its own harness. Repository authority, this project's safety rules, and explicit user instructions remain controlling.
