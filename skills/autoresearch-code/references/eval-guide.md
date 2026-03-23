# Eval Guide

How to write eval criteria that actually improve a codebase instead of giving you false confidence.

## The Golden Rule

Every eval must be a yes/no question. Not a scale. Not a vibe check. Binary.

Why: scaled scoring drifts too easily across runs. Binary evals give you a cleaner signal for keep/discard decisions.

## Good Evals vs Bad Evals

### Build and Tooling

Bad evals:

- "Is the build faster?"
- "Does the dev experience feel better?"

Good evals:

- "Does `npm run build` finish under 30 seconds on the same machine?" 
- "Does the main bundle stay under 250 KB gzip?"
- "Does the linter complete without timeouts or retry steps?"

### Backend and APIs

Bad evals:

- "Is the server more efficient?"
- "Does the endpoint scale better?"

Good evals:

- "Does the hot endpoint stay under 200 ms p95 in the defined test scenario?"
- "Does the query count for this request stay at or below 3?"
- "Do all external calls on the optimized path keep explicit error handling?"

### Frontend and Rendering

Bad evals:

- "Does the UI feel smoother?"
- "Is the component architecture cleaner?"

Good evals:

- "Does the target screen render without React warnings or hydration mismatches?"
- "Does the interaction avoid more than one unnecessary network request?"
- "Does the optimized route keep the same visible behavior in the regression scenario?"

### Maintainability and Cleanup

Bad evals:

- "Is the code nicer?"
- "Did we refactor enough?"

Good evals:

- "Does the changed module remove duplicated logic without increasing public API surface?"
- "Do targeted tests pass before and after the cleanup?"
- "Were no new dependencies added during this experiment?"

## Common Mistakes

### 1. Too many evals

More than 6 evals and the codebase starts gaming the test instead of improving the real bottleneck.

Fix: Pick the 3 to 6 checks that matter most.

### 2. Surrogate metrics

If the user cares about latency, scoring only line count or file count is noise.

Fix: include at least one eval tied directly to the user's bottleneck.

### 3. Overlapping evals

If one eval checks build success and another checks typecheck success, make sure they are truly distinct in this repo.

Fix: each eval should test a different failure surface.

### 4. Unmeasurable by an agent

"Would a user like this more?" is too subjective for a loop.

Fix: translate it into measurable signs such as threshold, warning count, test outcome, or request count.

## Writing Your Evals: The 3-Question Test

Before finalizing an eval, ask:

1. Could two different agents score the same output and agree?
2. Could the codebase game this eval without actually improving?
3. Does this eval test something the user actually cares about?

## Template

Copy this for each eval:

```text
EVAL [N]: [Short name]
Question: [Yes/no question]
Pass: [What "yes" looks like - one sentence, specific]
Fail: [What triggers "no" - one sentence, specific]
```

Example:

```text
EVAL 1: Build threshold
Question: Does the target build finish under 30 seconds with the agreed command and environment?
Pass: The same build command completes within the threshold with exit code 0
Fail: The build exceeds the threshold, fails, or requires manual retries
```

Codebase structure example:

```text
EVAL 2: No regression on hot path
Question: Does the optimized path preserve the same visible or API behavior in the agreed regression check?
Pass: The regression scenario produces the expected output with no new warnings or failing assertions
Fail: The scenario changes behavior, introduces warnings, or breaks assertions
```
