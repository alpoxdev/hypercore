# Experiment Loop

**Purpose**: Keep autoresearch runs measurable, reversible, and easy to learn from.

## 1. Baseline First

- Never mutate the target codebase before experiment `0` is recorded.
- Use the same test prompts and eval suite across baseline and follow-up experiments unless the evals themselves were proven wrong.
- If you must change the eval suite, log that as a separate reset event rather than silently mixing scores.

## 2. Diagnose Failures Before Editing

Classify the dominant failure before choosing a mutation:

- slow build or startup
- oversized bundle or artifact output
- slow query, request, or render path
- duplicated logic or dead code
- flaky tests or unreliable validation
- architecture friction that blocks small safe changes
- high developer-effort for routine work

Pick the failure that costs the most points or appears most often.

## 3. Change One Thing at a Time

Good mutations:

- simplify one hot path
- add one cache, batch, or guard for a measurable bottleneck
- remove one duplicated branch or dead dependency
- move one expensive operation off the critical path
- tighten one validation step that prevents rework
- delete one configuration or abstraction that adds measurable drag

Bad mutations:

- large rewrites with no isolated hypothesis
- multiple unrelated edits bundled into one experiment
- more tooling or dependencies without measured reason
- improving metrics that the user does not actually care about

## 4. Keep or Discard

- **KEEP** when total score improves.
- **DISCARD** when total score stays flat and the change adds complexity.
- **DISCARD** when total score drops.
- If a change keeps the same score but materially simplifies the codebase, document the simplification and keep it only when the no-regression case is explicit.

## 5. Code Optimization Rule

When optimizing a codebase:

- prefer deletion over new layers
- preserve behavior with targeted validation before broad cleanup
- reuse existing codebase patterns before introducing new abstractions
- keep each experiment small enough that the score delta is explainable

## 6. Logging Rule

Every experiment must record:

- experiment number
- score and max score
- pass rate
- keep or discard
- one-sentence description of the mutation
- why the mutation was expected to help
- what actually changed in the eval outcomes

## 7. Stop Conditions

Stop when any of these become true:

- the user stops the run
- the budget cap is reached
- the codebase reaches `95%+` pass rate for three consecutive kept experiments
- remaining failures are caused by bad eval design rather than the codebase itself

If the codebase is passing the evals but still producing weak real outcomes, fix the evals before running more mutations.
