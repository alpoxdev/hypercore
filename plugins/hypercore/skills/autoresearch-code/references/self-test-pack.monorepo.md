# Monorepo Pack

Use this pack when the bottleneck is workspace-wide build cost, duplicated configuration, package-boundary friction, or multi-package cleanup.

## Recommended Prompts

1. `Improve this monorepo bottleneck through measurable iterative experiments and keep only score-improving changes.`
2. `Before editing, benchmark workspace build cost, task fan-out, and regression safety.`
3. `Reduce cross-package drag while preserving package boundaries.`

## Recommended Proof Command

- workspace build
- affected package tests
- package graph or task runner output
- smoke command for the owned package group

## Recommended Binary Eval

- Is the selected proof set appropriate for the monorepo or workspace bottleneck?
- Does the run preserve package boundaries and avoid cross-repo mixing?
- Does it track concrete workspace metrics such as affected task count, build time, and removed duplicate configuration?
- Does the artifact clearly record the owned workspace scope?
- Does it avoid claiming success without repeated no-regression checks?
