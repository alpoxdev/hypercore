# Eval Guide

How to write eval criteria that lead to real codebase improvements instead of false confidence.

## Core Principle

Every eval must be a yes/no question. It is not a scoring scale and not a vibe check. It is binary.

Reason: scale-based assessments drift easily between runs. Binary evals give cleaner signals for keep/discard decisions.

## Good and Bad Evals

### Build and Toolchain

Bad evals:

- "Did the build get faster?"
- "Is the developer experience better?"

Good evals:

- "Does `npm run build` finish within 30 seconds on the same machine?"
- "Does the main bundle stay at or below 250 KB gzip?"
- "Does the linter finish without timing out or requiring manual retries?"

### Backend and API

Bad evals:

- "Is the server more efficient?"
- "Does the endpoint scale better?"

Good evals:

- "In the defined scenario, does the hot endpoint stay at or below p95 200 ms?"
- "Is the query count for this request 3 or lower?"
- "Do all external calls on the optimized path still have explicit error handling?"

### Frontend and Rendering

Bad evals:

- "Does the UI feel smoother?"
- "Is the component structure cleaner?"

Good evals:

- "Does the target screen render without React warnings or hydration mismatch?"
- "During interaction, is there no more than one unnecessary network request?"
- "Does the optimized route preserve the same visible behavior in the regression scenario?"

### Maintainability and Cleanup

Bad evals:

- "Is the code better?"
- "Was it refactored enough?"

Good evals:

- "Did the changed module remove duplicated logic without expanding its public API?"
- "Do the target tests pass both before and after cleanup?"
- "Did this experiment avoid adding new dependencies?"

## Common Mistakes

### 1. Too Many Evals

Once there are more than 6 evals, the codebase can more easily learn how to pass tests than how to solve the real bottleneck.

Fix: keep only the most important 3 to 6 evals.

### 2. Only Looking at Surrogate Metrics

If the user cares about latency, scoring line count or file count is noise.

Fix: connect at least one eval directly to the user's actual bottleneck.

### 3. Overlapping Evals

Build success and typecheck success may not be sufficiently different failure surfaces in some repositories.

Fix: make each eval inspect a different failure surface.

### 4. The Agent Cannot Measure It

"Will users like it more?" is hard to score reliably in the loop.

Fix: translate it into measurable signals such as thresholds, warning counts, test results, or request counts.

## 3 Questions Before Using an Eval

1. Could two other agents look at the same output and give the same score?
2. Could this eval be gamed without real improvement?
3. Is this something the user actually cares about?

## Template

Copy this format for each eval:

```text
EVAL [N]: [short name]
Question: [yes/no question]
Pass: [condition that means yes - one specific sentence]
Fail: [condition that means no - one specific sentence]
```

Example:

```text
EVAL 1: Build threshold
Question: Does the target build finish within 30 seconds under the agreed command and environment?
Pass: The same build command completes with exit code 0 within the threshold
Fail: The build exceeds the threshold, fails, or requires a manual retry
```

Codebase-structure example:

```text
EVAL 2: Hot path no regression
Question: Does the optimized path preserve the same screen or API behavior in the agreed regression scenario?
Pass: The regression scenario passes with the expected output and no new warnings or failed assertions
Fail: The scenario changes behavior, adds warnings, or breaks an assertion
```
