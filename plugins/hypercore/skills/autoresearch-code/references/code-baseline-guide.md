# Code Baseline Guide

Use this reference before experiment `0` so the loop starts from an explicit and reproducible code baseline.

## 1. Define the Optimization Scope

Capture:

- repositories or subdirectories included in scope
- bottleneck category
- user-visible goal
- constraints that must never regress

Examples:

- "Reduce web app build time while preserving output behavior."
- "Lower the dashboard endpoint query count without weakening authentication."
- "Simplify the data-loading path while preserving route behavior."

## 2. Choose Baseline Commands

Prefer commands that already exist in the codebase when possible.

Common categories:

- build command
- test command
- typecheck command
- benchmark or profiling command
- app-specific smoke scenario

If no benchmark exists, define a conservative and repeatable check and record its limits.

## 3. Choose the Eval Pack Source

Pack source priority:

1. Trace-backed prompts from production traces, profiling output, or incident history
2. Incident-backed prompts from bug reports, regressions, or postmortems
3. Domain packs in `references/self-test-pack.*.md`
4. Generic pack in `references/self-test-pack.md`

Record:

- selected pack name
- pack version or timestamp
- whether the pack type is `trace-backed`, `incident-backed`, `synthetic`, or `mixed`
- why lower-priority packs were not used

## 4. Record the Current State

Write the following in `baseline.md`:

- selected pack name and pack type
- selected commands
- raw numbers or pass/fail observations
- test prompts or scenarios
- binary eval set
- risks and non-goals

## 5. Choose the First Failure Pattern

Before editing, classify the highest-value problem:

- slow critical path
- repeated or duplicated work
- large bundle or artifact size
- unstable validation
- structural friction
- configuration overhead

Choose the failure that causes the greatest user-value loss or blocks iteration the most.

## 6. Keep the Baseline Stable

- Use the same commands and environment throughout the experiment
- If a command changes, record it as a suite reset event
- Do not change metrics midway without documenting why
