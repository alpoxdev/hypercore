---
name: pre-deploy
description: "[Hyper] Run deploy-readiness validation and fix reproduced lint/typecheck/build blockers for Node.js, Rust, and Python repos. Use for pre-deploy checks, deploy-ready requests, or final quality/build gates before deployment."
allowed-tools: Bash Read Edit Write TodoWrite mcp__sequential-thinking__sequentialthinking
compatibility: Requires local toolchains for at least one supported stack (node/rust/python), scripts under skills/pre-deploy/scripts, and optionally a runtime with bounded subagent/background-agent support for independent remediation lanes.
---

@rules/parallel-remediation.md
@rules/tracked-remediation.md

# Pre-Deploy Skill

> Prove a repository is deploy-ready, or fix only the reproduced quality/build blockers that prevent that proof.

<request_routing>

## Positive triggers

- "Run a pre-deploy check" or "check if this is ready to deploy."
- "Make this repo deploy-ready" or "fix blockers before deploying."
- "Run final lint/typecheck/build validation before release."
- "Validate this Node/Rust/Python workspace before deployment."

## Out-of-scope

- A concrete failed deployment log, platform build failure, CI-only environment mismatch, or production deploy issue. Route to `deploy-fix`.
- A runtime bug with reproduction steps or wrong application behavior. Route to `bug-fix`.
- New feature work, broad refactors, or speculative cleanup not tied to a reproduced pre-deploy blocker. Route to `execute` or the relevant implementation skill.
- Unsupported repositories with no root marker for `package.json`, `Cargo.toml`, `pyproject.toml`, `requirements.txt`, `setup.py`, `Pipfile`, or `poetry.lock`.

## Boundary cases

- If the user asks for validation only, run checks and report blockers without editing.
- If the initial check exposes one obvious low-risk blocker, use Fix-now.
- If failures span multiple stacks, workspaces, or ambiguous dependency/config chains, use tracked remediation and parallel lanes where available.
- If a failure is actually a deploy-platform or runtime app issue, stop pre-deploy remediation and hand off instead of absorbing the wrong problem.

</request_routing>

<argument_validation>

- If no argument is provided, default to the current repository root.
- If the user names a subdirectory or workspace, verify it exists, switch commands to that directory, and restart stack detection there.
- If the user says validate-only, report-only, audit-only, or similar, do not edit files.
- Always run stack detection from the target root before claiming the skill applies.
- If no supported stack is detected, stop immediately and report that `pre-deploy` does not apply; do not enter a fake fix loop.

</argument_validation>

<scripts>

## Available scripts

Run scripts with the current working directory set to the target root so detection is accurate. If the target root is the repository root, use these repository-relative paths; if the target is a subdirectory/workspace, invoke the same scripts by absolute path or by the correct relative path back to the repository root:

| Script | Purpose |
|------|------|
| `skills/pre-deploy/scripts/stack-detect.sh` | Detect project stacks (`node`, `rust`, `python`) |
| `skills/pre-deploy/scripts/deploy-check.sh` | Full verification (`lint/type checks + build`) |
| `skills/pre-deploy/scripts/lint-check.sh` | Run stack-specific quality checks |
| `skills/pre-deploy/scripts/build-run.sh` | Run stack-specific build phase |
| `skills/pre-deploy/scripts/pm-detect.sh` | Node package manager detection (`npm/yarn/pnpm/bun`) |

Notes:

- Helper scripts detect stacks and package managers relative to the current working directory.
- `lint-check.sh` already runs independent Node typecheck and lint commands concurrently when both are configured; do not duplicate that internal parallelism with extra agents.
- Treat skipped checks as "not configured" or "tool unavailable," not as passed.

</scripts>

<mandatory_reasoning>

## Adaptive Sequential Thinking

Use `sequential-thinking` before implementation and scale depth to the failure shape:

| Complexity | Thinking depth | Signals |
|------|------|------|
| Simple | 3 thoughts | One stack, one failing command, clear root cause, low-risk fix |
| Medium | 5 thoughts | Multiple related failures in one stack, moderate config/dependency impact |
| Complex | 7+ thoughts | Multiple stacks/workspaces, ambiguous fix strategy, shared config, dependency chain, or CI/deploy boundary |

Recommended sequence: classify -> read exact failure output -> identify root cause -> choose targeted validation -> decide direct fix, parallel lanes, tracked remediation, or handoff.

</mandatory_reasoning>

<complexity_classification>

Classify after the first full deploy check fails:

| Complexity | Signals | Path |
|------|------|------|
| Simple | Single failing check, one stack, clear file/config owner, one safe fix path | Fix-now |
| Medium | Several failures in one stack or one workspace, independent enough for targeted fixes | Fix-now with TodoWrite tracking |
| Complex | Multi-stack failures, shared configs, monorepo/build graph issues, uncertain repair options, or likely cross-cutting side effects | Tracked remediation; use `rules/parallel-remediation.md` before subagents |

When uncertain, classify upward. It is better to preserve evidence and ownership than to silently make broad changes.

</complexity_classification>

<execution_modes>

- **Validate-only**: run detection and `deploy-check.sh`, report detected stacks, passed/failed/skipped checks, and blockers. No edits.
- **Fix-now**: for simple/medium reproduced blockers, create TodoWrite items, fix narrowly, re-run targeted checks, then re-run full deploy check.
- **Parallel remediation**: after failure grouping, use bounded subagents/background agents only for independent diagnosis or disjoint edit lanes. The leader owns integration and final verification. Load `rules/parallel-remediation.md` first.
- **Tracked remediation**: for complex cases, load `rules/tracked-remediation.md`, then create or resume `.hypercore/pre-deploy/flow.json` with phases `detect`, `baseline`, `triage`, `fix`, `verify`, `report`.
- **Handoff**: route platform deployment failures to `deploy-fix`, runtime application bugs to `bug-fix`, and unrelated implementation requests to `execute`.

</execution_modes>

<workflow>

## Full validation proof

From the repository root:

```bash
skills/pre-deploy/scripts/deploy-check.sh
```

Do not skip this initial command unless the target root has no supported stack. It establishes the baseline and captures exact blockers.

## Step-by-step validation

From the repository root:

```bash
# 1) quality checks
skills/pre-deploy/scripts/lint-check.sh

# 2) build phase
skills/pre-deploy/scripts/build-run.sh
```

Use step-by-step commands for targeted rechecks after a fix, but the final readiness claim still requires a full `deploy-check.sh` run.

## Stack behavior summary

- **Node.js**: typecheck/lint (if configured) + build script (if configured)
- **Rust**: `cargo fmt --check` + `cargo clippy` + `cargo check` + `cargo build --release`
- **Python**: lint (`ruff`/`flake8` if available) + type/syntax check (`mypy` or `compileall`) + build (`poetry build` or `python -m build`, fallback `compileall`)
- **Unsupported repository**: stop with the detected unsupported-stack error and do not continue into remediation

</workflow>

<implementation_rules>

- Read the exact command output before editing; do not guess failures.
- Convert failures into TodoWrite items by stack, command, and priority.
- Fix the first/root failure before chasing cascading errors unless failures are demonstrably independent.
- Keep each edit scoped to the reproduced blocker and its direct dependency.
- Re-run the narrowest relevant check after each edit.
- If using subagents, give each lane objective, scope, ownership, output, and stop condition; never let two lanes edit the same file or shared config concurrently.
- The leader must synthesize subagent results, inspect the final diff, and run the final proof command directly.

</implementation_rules>

<completion_report>

Use this report shape:

```markdown
## Done

**Scope**: [repo root or workspace]
**Stacks detected**: [node/rust/python]
**Mode**: [validate-only/fix-now/parallel remediation/tracked remediation/handoff]
**Initial blockers**: [none or summarized failures]
**Fixes applied**: [changed files or none]
**Validation**:
- `skills/pre-deploy/scripts/deploy-check.sh`: [passed/failed/not run with reason]
- Skipped/not configured checks: [list]
**Remaining risks**: [none or explicit caveats]
```

Only say "ready to deploy" when the final full `deploy-check.sh` run passed.

</completion_report>

<validation>

Execution checklist:

- [ ] Target root or workspace validated
- [ ] Supported stack detected, or unsupported stack reported and stopped
- [ ] Full `skills/pre-deploy/scripts/deploy-check.sh` run first for supported stacks
- [ ] Failures tracked by stack/command/priority
- [ ] Root-cause evidence collected before edits
- [ ] Sequential thinking completed at the right depth
- [ ] Parallel lanes, if used, were independent and bounded
- [ ] Targeted validation run after each fix
- [ ] Full deploy check passed before readiness claim
- [ ] Skipped checks reported separately from passed checks

Forbidden:

- [ ] Claiming deploy readiness without a passing full deploy check
- [ ] Editing without a reproduced failure unless the user explicitly requested implementation work outside this skill
- [ ] Treating skipped checks as passed
- [ ] Continuing after unsupported-stack detection
- [ ] Requiring product-specific subagent syntax as if every runtime supports it
- [ ] Letting subagents edit overlapping files or own the final readiness decision

</validation>
