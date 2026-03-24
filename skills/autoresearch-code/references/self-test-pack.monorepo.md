# Monorepo Pack

Use this pack when the bottleneck is mainly workspace-wide build cost, duplicated config, package-boundary friction, or multi-package cleanup.

## Suggested Prompts

1. `Improve this monorepo bottleneck with measured iterations and keep only score-improving changes.`
2. `Benchmark workspace build cost, task fan-out, and regression safety before editing.`
3. `Reduce cross-package drag while keeping each package boundary clear.`

## Suggested Proof Commands

- workspace build
- affected-package tests
- package graph or task-runner output
- smoke command for the owned package group

## Suggested Binary Evals

- Is the chosen proof set appropriate for a monorepo or workspace bottleneck?
- Does the run preserve package boundaries and avoid cross-repo mixing?
- Does the run track a concrete workspace metric such as affected-task count, build time, or duplicated config removed?
- Does the artifact record the owned workspace scope clearly?
- Does the run avoid claiming a win without a repeated non-regression check?
