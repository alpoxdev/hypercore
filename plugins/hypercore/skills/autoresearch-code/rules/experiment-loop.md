# Experiment Loop

**Purpose**: Keep code autoresearch runs measurable, reversible, and learnable.

## 1. Baseline First

- Never mutate the target codebase before experiment `0` is recorded.
- Keep the same test prompts and eval set for the baseline and follow-up experiments unless there is evidence that the eval itself is wrong.
- If the eval set must change, record it as a separate reset event instead of mixing scores.

## 2. Diagnose Failure Before Editing

Before choosing a mutation, classify the dominant failure:

- slow build or startup time
- excessive bundle or artifact size
- slow query, request, or render path
- duplicated logic or dead code
- flaky test or unreliable validation
- structural friction that blocks small safe changes
- high developer cost for repetitive work

Choose the failure that loses the most points or appears most often first.

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

## 4. Keep or Discard

- If the total score rises, **KEEP**.
- If the total score is unchanged and complexity rises, **DISCARD**.
- If the total score drops, **DISCARD**.
- If the score is unchanged but the codebase became materially simpler, keep it only when the simplification rationale and no-regression evidence are explicit.

## 5. Code Optimization Rules

When optimizing a codebase:

- prefer deletion over new layers
- protect behavior with targeted validation before broad cleanup
- reuse existing codebase patterns over new abstractions
- keep each experiment small enough to explain why the score changed

## 6. Logging Rules

Every experiment must record:

- experiment number
- score and maximum score
- pass rate
- keep or discard
- one sentence describing the mutation
- why this mutation was expected to help
- what actually changed in the eval results

## 7. Exit Conditions

Stop when one of these is true:

- the user stops the run
- the budget ceiling is reached
- the codebase records a `95%+` pass rate across three consecutive keep experiments
- remaining failures are judged to come from bad eval design rather than the codebase

If evals pass but the real result is still weak, fix the eval before adding more mutations.
