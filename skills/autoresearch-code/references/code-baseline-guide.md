# Code Baseline Guide

Use this reference before experiment `0` so the loop starts from an explicit, reproducible code baseline.

## 1. Define the Optimization Scope

Capture:

- repository or subdirectory in scope
- bottleneck category
- user-facing goal
- constraints that must not regress

Examples:

- "Reduce build time in the web app without changing output behavior."
- "Lower query count on the dashboard endpoint without weakening auth."
- "Simplify the data-loading path while preserving route behavior."

## 2. Choose the Baseline Commands

Prefer commands that already exist in the codebase.

Common categories:

- build command
- test command
- typecheck command
- benchmark or profiling command
- app-specific smoke scenario

If no benchmark exists, define a conservative repeatable check and record the limitation.

## 3. Choose the Eval Pack Source

Prefer pack sources in this order:

1. trace-backed prompts from production traces, profiling output, or incident history
2. incident-backed prompts from bug reports, regressions, or postmortems
3. domain packs from `references/self-test-pack.*.md`
4. the generic pack from `references/self-test-pack.md`

Record:

- selected pack name
- pack version or timestamp
- whether the pack is `trace-backed`, `incident-backed`, `synthetic`, or `mixed`
- why the lower-priority pack types were not used

## 4. Record the Current State

Write `baseline.md` with:

- the selected pack name and pack type
- the chosen commands
- raw numbers or pass/fail observations
- the test prompts or scenarios
- the binary eval suite
- risks and non-goals

## 5. Pick the First Failure Pattern

Classify the highest-value problem before editing:

- slow critical path
- repeated or duplicated work
- high bundle or artifact size
- unstable validation
- architecture friction
- configuration drag

Choose the failure that costs the most user value or blocks iteration.

## 6. Keep the Baseline Stable

- use the same commands and environment across experiments
- log any command change as a suite reset event
- do not switch metrics mid-run without documenting why
