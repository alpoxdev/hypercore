# Skill Test Matrix

**Purpose**: Decide what must be tested before a skill can be trusted.

## Required dimensions

| Dimension | What to test | Typical evidence |
|---|---|---|
| Trigger precision | Requests that should and should not activate the skill | Positive/negative prompt table |
| Boundary routing | Requests that overlap neighboring skills | Routing rationale |
| Workflow completeness | Whether each phase gives the agent a next action | Phase-by-phase simulation |
| Resource integrity | Linked rules/references/scripts/assets exist and are placed correctly | Static file check |
| Validation strength | Whether completion requires evidence | Checklist/readback |
| Edge resilience | Missing inputs, malformed paths, localization, conflicts, and unsupported targets | Edge scenario table |
| Regression risk | Known or likely failures from similar skills | Regression scenario |

## Minimum matrix

Create at least these cases unless the user explicitly asks for a smaller smoke test:

- 3 positive trigger scenarios.
- 2 negative trigger scenarios.
- 2 boundary scenarios.
- 2 edge-case scenarios.
- 1 regression scenario.

## Severity guide

- `critical`: wrong skill activates for destructive or high-risk work, or required resources are missing.
- `high`: core trigger/workflow fails for normal target requests.
- `medium`: boundary behavior is ambiguous but recoverable.
- `low`: wording, maintainability, or report quality issue without immediate misrouting.

## Exit rule

A skill passes only when normal positive scenarios route correctly, negative scenarios stay out of scope, support files resolve, and the workflow cannot plausibly claim completion without validation evidence.
