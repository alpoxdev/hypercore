# Experiment Loop

**Purpose**: Keep code autoresearch runs measurable, reversible, and learnable.

## 1. Baseline First

- Never mutate the target codebase before experiment `0` is recorded.
- Keep the same test prompts and eval set for the baseline and follow-up experiments unless there is evidence that the eval itself is wrong.
- If the eval set, proof command, scope, or scoring direction must change, record it as a separate `reset` event instead of mixing scores.
- Record baseline metric values, proof commands, guard checks, rollback conditions, and environment before editing.

## 2. Diagnose Failure Before Editing

Before choosing a mutation, classify the dominant failure:

- slow build or startup time
- excessive bundle or artifact size
- slow query, request, or render path
- duplicated logic or dead code
- flaky test or unreliable validation
- structural friction that blocks small safe changes
- high developer cost for repetitive work

Choose the failure that loses the most points or appears most often first. Name the target metric/eval before editing.

## 3. Change One Thing at a Time

Good mutations:

- simplify one hot path
- add one cache, batch, or guard to a measurable bottleneck
- remove one duplicate branch or dead dependency
- move one expensive operation out of the critical path
- tighten one validation step that prevents rework
- delete one configuration or abstraction that only creates measurable burden

Bad mutations:

- broad rewrites without an isolated hypothesis
- bundling multiple unrelated edits into one experiment
- adding tools or dependencies without measurement evidence
- improving metrics that the user does not actually care about

## 4. Keep, Rework, or Discard

- If the total score rises and all required guards pass, **KEEP**.
- If the total score rises but a required guard fails, **DISCARD** or **REWORK**; do not call it promotable.
- If the total score is unchanged and complexity rises, **DISCARD**.
- If the total score drops, **DISCARD**.
- If the score is unchanged but the codebase became materially simpler, keep it only when the simplification rationale, changed files, and no-regression proof are explicit.
- If the measuring hook crashes or metrics cannot be trusted, mark the experiment `crash`, `hook-blocked`, or `metric-error` and do not compare it with the baseline.

## 5. Code Optimization Rules

When optimizing a codebase:

- prefer deletion over new layers
- protect behavior with targeted validation before broad cleanup
- reuse existing codebase patterns over new abstractions
- keep each experiment small enough to explain why the score changed
- keep proof commands reproducible and rerun the same guard set before finalizing

## 6. Logging Rules

Every experiment must record:

- experiment number
- score and maximum score
- pass rate and score delta from baseline or previous best
- status: `baseline`, `keep`, `keep-reworked`, `discard`, `crash`, `no-op`, `hook-blocked`, `metric-error`, or `reset`
- one sentence describing the mutation in Korean
- why this mutation was expected to help
- target metric/eval and before/after values or pass counts
- changed files
- proof command and summarized output
- guard result and guard metric
- promotion state: `hold`, `promote`, or `rollback`
- rollback condition
- what actually changed in the eval results
- remaining failures or explicit “없음”

## 7. Exit Conditions

Stop when one of these is true:

- the user stops the run
- the budget ceiling is reached
- the codebase records a `95%+` pass rate across three consecutive keep experiments with guards passing
- remaining failures are judged to come from bad eval design rather than the codebase

Before final answer, write or update `code-explanation.md`/`results.json.code_explanation`, `final-report.md`, `results.js`, and `dashboard.html` so the user can inspect the score movement and Markdown-rendered details locally.

If evals pass but the real result is still weak, fix the eval before adding more mutations.
