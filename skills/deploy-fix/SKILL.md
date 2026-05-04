---
name: deploy-fix
description: "[Hyper] Diagnose and fix build failures, CI pipeline errors, and deployment errors across the entire repository or a specific folder. Routes simple build breaks directly; tracks complex multi-system failures via .hypercore/deploy-fix/ JSON flow."
compatibility: Use in environments with code exploration (Read/Grep/Glob), editing (Edit), and shell execution (Bash).
---

# Deploy Fix Skill

> Diagnose a build, CI, or deployment failure, choose the safest repair path, and fix it — classify complexity first, then either fix directly or track progress through structured phases.

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<request_routing>

## Positive triggers

- A build command fails with a concrete error such as `Module not found`, type errors, or compilation failures.
- A CI pipeline step fails with a specific error in logs (lint, test, build, or deploy stage).
- A deployment fails with a concrete error such as function timeout, missing env vars, or platform-specific build errors.
- A specific folder or workspace within a monorepo fails to build.

## Out-of-scope

- Runtime bugs in application code with a reproduction path. Route to `bug-fix`.
- Security audits, exploit review, or trust-boundary analysis. Route to `security-review`.
- New feature work, refactors, or speculative cleanup not tied to a concrete failure.
- General performance optimization without a failing build or deploy.

## Boundary cases

- If the user asks for root-cause analysis only, stay in diagnosis mode and do not edit.
- If a CI failure is caused by a single runtime bug (e.g., a failing test from a code defect), this skill owns the CI-level fix; hand off the underlying code bug to `bug-fix` if the root cause is application logic.
- If the failure spans build + deployment + runtime, own the build/deploy layer and hand off runtime to `bug-fix`.

</request_routing>

<argument_validation>

If ARGUMENT is missing, ask immediately:

```text
What build/CI/deploy failure should be fixed?
- Error message or failing log output
- Build command or CI step that fails
- Full repo build or specific folder/workspace?
- CI provider (GitHub Actions, Vercel, etc.) if applicable
- Regression or new? (Did it work before? When did it start failing?)
- Consistent or intermittent?
- Recent changes, suspect commits, or environment details
- Relevant config files (package.json, tsconfig, CI config, vercel.json, etc.)
```

</argument_validation>

<mandatory_reasoning>

## Mandatory Sequential Thinking

Always run `sequential-thinking` before implementation. Depth scales with complexity:

- **Simple (3 thoughts)**: Identify failing step -> determine fix -> verify approach
- **Medium (5 thoughts)**: Classify -> reproduce locally -> hypothesize -> compare options -> recommend
- **Complex (7+ thoughts)**: Classify -> reproduce -> analyze dependency chain -> check CI config -> hypothesize multiple causes -> compare options -> assess cross-cutting impact -> recommend

Recommended sequence:

1. Complexity classification
2. Failure reproduction and log analysis
3. Root-cause hypotheses
4. Option comparison
5. Final recommendation

Before any edit, collect root-cause evidence from build logs, CI output, or deployment logs and reduce the problem to the narrowest failing boundary you can verify.

</mandatory_reasoning>

<complexity_classification>

## Complexity Classification

Classify immediately after sequential-thinking:

| Complexity | Signals | Examples | Path |
|------------|---------|----------|------|
| **Simple** | Single file/config, clear error message, obvious root cause, one fix path, low risk | Missing env var, single typo in config, one outdated dependency, clear type error in one file | **Fix-now** -- proceed directly without flow tracking |
| **Complex** | Multiple packages/configs involved, dependency chain issues, CI environment mismatch, fix has side effects across workspaces, multiple valid fix strategies | Cross-workspace type error chain, CI-only failure with no local repro, lockfile conflicts across multiple packages, build succeeds but deploy fails | **Tracked** -- create `.hypercore/deploy-fix/flow.json` |

Announce the classification:

```
Complexity: [simple/complex] -- [one-line reason]
```

When uncertain, classify as complex. It is cheaper to track than to lose investigation progress.

</complexity_classification>

<flow_tracking>

## Flow Tracking (Complex Path Only)

When classified as complex, initialize the flow:

```bash
mkdir -p .hypercore/deploy-fix
```

Write `.hypercore/deploy-fix/flow.json` and update it as each phase progresses. See `references/flow-schema.md` for the full schema.

### Phase progression

| Phase | Description | Next |
|-------|-------------|------|
| `investigate` | Reproduce failure, analyze logs, isolate root cause | `options` |
| `options` | Present 2-3 fix options with tradeoffs | `confirm` |
| `confirm` | Wait for and record user selection | `fix` |
| `fix` | Implement selected option | `verify` |
| `verify` | Run build/CI/deploy validation, report outcome | done |

### Resume support

If `.hypercore/deploy-fix/flow.json` already exists, read it first and continue from the last incomplete phase (`in_progress` or `pending`). Do not restart completed phases.

</flow_tracking>

<execution_modes>

Use one of these branches explicitly:

- **Diagnose-only**: reproduce failure, isolate the failing step, summarize evidence, and stop before code edits.
- **Fix-now** (simple path): If the user explicitly asks for a direct fix and one path is clearly the safest, say which path you are taking and implement without a second confirmation round. No flow tracking.
- **Option-first** (complex path): present 2-3 repair options with flow tracking and wait for user selection.
- **Handoff**: route runtime application bugs to `bug-fix` and security review requests to `security-review`.

</execution_modes>

<investigation_strategy>

## Investigation Strategy

Check these areas in order of likelihood:

1. **Build logs**: read the exact error output, identify the first failure point
2. **Dependency issues**: lockfile conflicts (`package-lock.json`/`pnpm-lock.yaml` integrity), missing packages, version mismatches, peer dependency warnings, hoisting problems
3. **Config files**: `tsconfig.json`, `package.json`, `next.config.*`, `vercel.json`/`vercel.ts`, CI workflow files, bundler config
4. **Environment**: Node.js version, env vars, platform-specific differences (local vs CI vs deploy target), memory limits (OOM during build)
5. **Build cache**: stale or corrupted build cache (`.next/`, `.turbo/`, `node_modules/.cache/`), `--force` rebuild to isolate
6. **Cross-workspace**: monorepo dependency graph, build order, shared package version drift
7. **Recent changes**: `git log` and `git diff` to find suspect commits that may have introduced the failure

</investigation_strategy>

<workflow>

## Simple Path (Fix-now)

| Step | Task | Tool |
|------|------|------|
| 1 | Validate input, sequential-thinking (3 thoughts) | sequential-thinking |
| 2 | Classify as simple | - |
| 3 | Reproduce failure locally, read error output | Bash + Read |
| 4 | Identify root cause from logs/config | Read/Grep/Glob |
| 5 | Announce fix path and implement | Edit |
| 6 | Run validation (build/lint/typecheck/deploy) | Bash |
| 7 | Report outcome and changed files | - |

## Complex Path (Option-first)

| Step | Task | Tool |
|------|------|------|
| 1 | Validate input, sequential-thinking (7+ thoughts) | sequential-thinking |
| 2 | Classify as complex, create `.hypercore/deploy-fix/flow.json` | Write |
| 3 | Deep investigation: reproduce, analyze logs, trace dependency chain -> update flow `investigate: completed` | Bash + Read/Grep/Glob + Edit |
| 4 | Present 2-3 fix options -> update flow `options: completed` | Edit |
| 5 | Wait for user selection -> update flow `confirm: completed` | Edit |
| 6 | Implement selected option -> update flow `fix: completed` | Edit/Write |
| 7 | Run validation -> update flow `verify: completed` | Bash + Edit |
| 8 | Report outcome, set flow status to `completed` | Edit |

</workflow>

<option_presentation>

Use this format (complex path):

```markdown
## Deploy Failure Analysis

**Root cause**: ...
**Failure scope**: [repo-wide / workspace / CI step / deploy target]
**Complexity**: complex

### Option 1: ... (Recommended)
- **Pros**:
- **Cons**:
- **Risk**:
- **Files**:

### Option 2: ...
- **Pros**:
- **Cons**:
- **Risk**:
- **Files**:

### Option 3: ... (Temporary)
- **Pros**:
- **Cons**:
- **Risk**:
- **Files**:

Recommendation: Option N (reason ...)
Which option should I apply? (1/2/3)
```

</option_presentation>

<implementation_rules>

- Do not modify code before user option selection unless in the explicit Fix-now branch.
- Avoid speculative edits; use evidence from build/CI/deploy logs only.
- Keep scope limited to the failing build/CI/deploy path and its direct dependencies.
- Always run targeted validation for the changed path: rebuild the failing target, re-run the failing CI step, or re-trigger the failing deploy.
- Report the commands run, the key result lines, and the touched files in the final report.
- If validation cannot run locally (e.g., CI-only environment), say why and what remains unverified.

## Reporting

After execution, report:

```markdown
## Done

**Failure**: [original error / failing step]
**Root cause**: [what was wrong]
**Fix applied**: [which option or approach]
**Changes**: [list of changed files]
**Validation**: [what was verified and result]
```

For complex path: also update `.hypercore/deploy-fix/flow.json` status to `completed`.

</implementation_rules>

<validation>

Execution checklist:

- [ ] ARGUMENT validated
- [ ] sequential-thinking completed (depth matches complexity)
- [ ] Complexity classified (simple/complex)
- [ ] Flow JSON created and maintained (complex path only)
- [ ] Root-cause evidence collected from logs/config
- [ ] 2-3 options presented (complex path) or fix path announced (simple path)
- [ ] User choice confirmed (complex path)
- [ ] Build/CI/deploy validation executed
- [ ] Outcome + touched files reported
- [ ] Flow JSON finalized with `completed` status (complex path only)

Forbidden:

- [ ] Speculative fix without build/CI/deploy log evidence
- [ ] Immediate implementation without options (complex path)
- [ ] Implementation without explicit user choice (complex path)
- [ ] Completion claim without running the failing build/CI/deploy command
- [ ] Skipping flow JSON updates in complex path

</validation>
