# Stage Handoff

> Give each stage a precise request, check its saved artifact on disk, and pass that artifact forward until the last stage proves completion.

## 1. Stage Contracts

Load each stage skill through the runtime's skill mechanism (or read its `SKILL.md` where skills are plain files) and follow it from its first phase. The stage owns everything inside its run.

| Stage | Request passed to the stage | Artifact that must exist before the next stage | Passed forward |
|---|---|---|---|
| `hyper-research` | The question the job depends on, with the decision it must support ("which state library fits this repo, to adopt it next") | `.hyper/research/[NN].<slug>.md` | Report path and its recommendation line |
| `hyper-seo` | The target, plus `recommend` as the allowed action in a Build job, or the user's own mode in a Report job | The report under `.hyper/seo/<slug>/` | Report path and its critical and warning findings |
| `hyper-architecture` | In a Build job: "architecture audit only; report findings with file paths; do not edit", plus the target paths. As the last stage: the user's request unchanged | Its routing line plus findings, copied into the workflow record's stage notes, because the stage saves no file of its own in audit mode | The stage-notes section path and the findings |
| `hyper-database` | Before a plan or mass stage: "review only; report findings, the design brief, or the engine choice with file paths; do not edit", plus the target paths and every upstream artifact path. As the last stage: the user's request unchanged, plus every upstream artifact path | `.hyper/database/<slug>/report.md`; as the last stage its verification section lists each check as run with its output or `not run` with the reason | Report path and its critical and high findings |
| `hyper-mcp` | Before a plan or mass stage: "audit only; report findings with file paths; do not edit", plus the target paths and every upstream artifact path. As the last stage: the user's request unchanged, plus every upstream artifact path | `.hyper/mcp/<slug>/report.md`; as the last stage its verification table also lists the MCP Inspector run in the era the target claims | Report path and its critical and high findings |
| `hyper-design` | Before a plan or mass stage: "report only; write the design brief for a new interface, or audit the existing one; do not edit", plus the target paths and every upstream artifact path. As the last stage: the user's request unchanged, plus every upstream artifact path | `.hyper/design/<slug>/brief.md` (brief-only) or `.hyper/design/<slug>/report.md`; as the last stage the report passes the stage's report validator and records the craft-floor result and the review mode | Brief or report path and its P0 and P1 findings |
| `hyper-plan` | The user's original request, every upstream artifact path as required reading, the delivery flag, and `--plan-only` or the approval hold when the user said so | `.hyper/plans/<slug>.md` with a `## Handoff` section | Nothing: the stage continues into `hyper-execute` itself |
| `hyper-execute` | The plan slug and the delivery flag | `.hyper/execute/<slug>/state.json` with `status` of `complete` and the printed completion block | - |
| `hyper-mass` | The goal, its success criteria, and every upstream artifact path | `.hyper/mass/<run-key>/run.jsonl` ending in a `run.settled` event with `status` of `completed` | - |
| `hyper-skill` | The user's original request, the target `skills/<name>/` path when it exists, and every upstream artifact path as required reading | `skills/<name>/SKILL.md` and `SKILL.ko.md`, plus the stage's validator run reporting zero errors in its validation handoff | The changed paths, when `hyper-git` follows |
| `hyper-documentation` | The user's original request, the target path when it exists, and every upstream artifact path as required reading | The created or updated artifact at the requested path, plus the selected mode's validation handoff and, for a machine-readable prompt artifact, its parse result | The changed paths, when `hyper-git` follows |
| `hyper-git` | The mode (commit, or workflow for a pull request or a whole-branch merge), the changed paths from the previous stage as the commit scope, the target branches in the user's order, and the user's limits ("커밋만", "main 빼고") unchanged | Each commit SHA it reports found on every remote target (`git fetch origin <target>`, then `git branch -r --contains <sha>` or `git cherry origin/<target> <branch>` with no `+` lines), or the pull request URL with its state from `gh pr view` | - |

Rules for every hand-off:

- Read the artifact from disk before marking the stage done. A stage's claim in chat without the file is a failed hand-off.
- A `hyper-git` stage starts only after the previous stage's completion evidence passed; a failed validator never reaches delivery.
- Pass upstream artifacts by path, and add at most three lines of the conclusion that the next stage needs. Do not paste whole reports.
- Pass the user's constraints (scope limits, excluded paths, "커밋하지 말고") to every stage unchanged.

## 2. The Plan-to-Execute Step

`hyper-plan` continues into `hyper-execute` in the same session when its own conditions hold. This skill never starts that execution itself.

After the plan stage returns, read the plan's `## Handoff` lines:

| `Auto-execute` value | Meaning | Next action |
|---|---|---|
| `yes` | Execution ran inside the plan stage | Check `.hyper/execute/<slug>/state.json`; `complete` finishes the chain, `active` or `paused` means execution is still running or stopped and its own report decides |
| `no (plan only requested)` or `no (approval requested)` | The user asked to stop after the plan | Finish the chain as a Report job |
| any other `no (...)` | The plan stage hit a hard stop | Stop the chain with that reason (§5) |

## 3. Workflow Record

Write `.hyper/workflows/<slug>.md` before the first stage. `<slug>` is a short kebab-case name of the job; add `-2`, `-3` when the file exists for a different job. Keep it in Korean except for paths, skill names, and flags.

```markdown
# <job title>

- 요청: <the user's request, verbatim>
- 작업 종류: build | report | resume
- 전달: local | make-pr | ship | plan-only | git:<mode> <targets>
- 상태: running | done | stopped
- 정지 사유: <reason, or 없음>

## 단계

| # | 단계 | 선택 근거 | 상태 | 산출물 |
|---|---|---|---|---|
| 1 | hyper-architecture | "폴더 구조 리팩토링" + package.json `next` | done | 단계 메모 1 |
| 2 | hyper-plan | 여러 파일 변경 | running | .hyper/plans/<slug>.md |

## 단계 메모

### 1. hyper-architecture
<routing line and findings with file paths>
```

Stage status values: `pending`, `running`, `done`, `skipped`, `stopped`. Update the row when a stage starts and when it ends, before printing the status line.

## 4. Stage Results

| Stage result | Action |
|---|---|
| Artifact exists and the stage reports success | Mark `done`, print `<#>/<total> <stage> 완료 - <artifact>`, start the next stage |
| `hyper-architecture` stops with an unsupported stack while it is an upstream stage | Mark `skipped` with the reason; continue, because its output was advisory evidence |
| A stage stops because the request is a different output shape | Re-route once (§6) |
| A stage stops for a user decision, a credential, a conflict, or a failed gate | Mark `stopped` and end the chain (§5) |
| The stage skill is not installed or cannot be loaded | Mark `stopped`; report the chain and `npx skills add alpoxdev/hypercore --skill <stage>` |

Never edit the stage's artifact to make it pass, never re-run a stopped stage with weaker inputs, and never continue past a stop that is not listed as a skip.

## 5. Stop Reporting

When the chain ends early, print in Korean:

1. the route line with each stage's final status
2. the stopped stage, its own reason in one line, and the one thing the user can do to unblock it
3. the record path, so a later "이어서" resumes from it

## 6. Re-Route and Resume

- Re-route: when a stage says the request is a different output shape (the plan stage reports that the job is really research), rebuild the chain from that evidence with `rules/workflow-routing.md`, record both chains, and continue. A second shape mismatch stops the run.
- Resume: on "이어서" / "resume", read the newest record whose `상태` is `running` or `stopped`, confirm the stopped stage's blocker is gone, and restart at the first stage that is not `done` or `skipped`. With no record, an open execution state routes to `hyper-execute` alone.

## 7. Closing Report

Report in Korean: the final chain with statuses, each artifact path, the last stage's completion evidence (the execution completion block, the mass run's verification result, the skill validator result, the documentation mode's validation handoff, the database report's verification section, the MCP report's verification table, the UI report's validator result and craft-floor line, the Git delivery's commit SHAs found on each remote target, or the report path), the delivery result (local commits, PR URL, or merge), and every skipped or stopped stage with its reason.

## Sources

> Checked 2026-11-07.

| Claim | Source |
|---|---|
| The stage artifact paths and state values (`.hyper/research/`, `.hyper/seo/<slug>/`, `.hyper/database/<slug>/report.md`, `.hyper/mcp/<slug>/report.md`, `.hyper/design/<slug>/brief.md` and `report.md`, `.hyper/plans/<slug>.md`, `state.json` `status`, `run.settled`, `skills/<name>/SKILL.md`, the documentation artifact paths, the Git delivery's remote-branch checks) | each stage skill's own `SKILL.md` and references in this repository, 2026-11-07 |
| The plan stage's `## Handoff` lines and its auto-continue into execution | the plan skill's handoff rule in this repository, 2026-11-06 |
| The architecture stage stops on an unsupported stack and reports the install command for a missing skill | the architecture skill's stack-detection rule in this repository, 2026-11-06 |
| Hand-off through saved artifacts and durable state rather than chat | `instructions/harness-engineering/HARNESS_ENGINEERING.md` |
| The workflow record shape, the skip rule, and the single re-route | this package's chosen design, not a validated optimum |
