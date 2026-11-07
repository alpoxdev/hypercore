# Workflow Routing

> Classify the requested output, add only the stages whose artifacts the job consumes, and run them in one fixed order.

## 1. Classify the Job

Decide the job from the requested output, then confirm it with repository files. Read the request first, then only the files a signal names.

| Job class | Requested output | Example words |
|---|---|---|
| Build | Changed code: a feature, fix, refactor, migration, or adoption; an MCP server, client, or host configuration; a designed or restyled interface or a faux product UI; or a created or refactored skill folder, document, or prompt artifact | 만들어, 추가해, 고쳐, 리팩토링해, 옮겨, 적용해, 연결해, 디자인해, 리디자인해, AI 티 빼줘, 스킬로 만들어, 문서로 정리해, 프롬프트 만들어, implement, refactor, migrate, connect, redesign |
| Report | A saved report, audit, review, or plan with no code change | 조사만, 점검만, 리뷰만, 리포트만, 계획만, audit only, just the plan |
| Resume | An earlier run continued | 이어서, 계속, 재개, resume, continue |

A request that is a one-place edit with no plan (a typo, one string, one config value), a commit-only request, a PRD or wireframe package, or a question is out of scope: do not route it.

## 2. Stage Signals

Add a stage only when one of its signals is present. Quote the signal in the route line.

| Stage | Add it when | Evidence to quote |
|---|---|---|
| `hyper-research` | The job depends on facts outside the repository: choosing between libraries or services, a new major version, an unfamiliar external API, or "최신" / "latest" behavior | The request phrase |
| `hyper-seo` | The job is about search or AI-answer visibility of a named site or page set | The request phrase and the target URL or app path |
| `hyper-architecture` | The job restructures folders, routes, modules, data or server boundaries, or platform setup, or adds a feature that creates a new route, module, or server boundary | The request phrase plus a stack manifest that was read, such as `package.json`, `pubspec.yaml`, or `Cargo.toml` |
| `hyper-mcp` | The job builds, fixes, migrates, audits, or connects an MCP (Model Context Protocol) server, client, or host MCP configuration, or prepares MCP registry metadata | The request phrase, plus the MCP dependency or configuration file that was read when one exists, such as `@modelcontextprotocol/*` in `package.json`, `mcp` in `pyproject.toml`, `.mcp.json`, or `server.json` |
| `hyper-ui-ux` | The requested output is an interface whose look is the point: a new screen, page, or component designed, an existing UI restyled, faux product UI for a hero, card, or demo, a design brief or `DESIGN.md`, or generic "AI look" patterns audited or removed | The request phrase, plus the target UI path and the styling or design-system file that was read when one exists, such as `DESIGN.md`, a tokens file, or `tailwind.config.*` |
| `hyper-plan` | A Build job touches several files or steps, or a Report job asks for a plan | The request phrase |
| `hyper-execute` | Only as the first stage: a plan file under `.hyper/plans/` already exists and the user wants it run or resumed | The plan path that was read |
| `hyper-mass` | The user asks for a dependency graph, a DAG, "의존성 그래프", "단계별 병렬", or several tasks where some must finish before others start, and no plan file is wanted | The request phrase |
| `hyper-skill` | The requested output is a reusable skill folder: a new skill, or a refactor of an existing skill's trigger, contract, resources, or validation | The request phrase, plus the target `skills/<name>/SKILL.md` when it already exists |
| `hyper-documentation` | The requested output is a documentation artifact, new or refactored: a README, an `AGENTS.md`, an AI-readable document (instruction base, agent guide, runbook, specification, or rule pack), or a reusable prompt artifact (role, system, or agent prompt, prompt template or pack, or prompt eval fixture) | The request phrase, plus the target path when it already exists |
| `hyper-git` | Only as the last stage, after a tail that does not deliver (`hyper-skill`, `hyper-documentation`, or `hyper-mcp` or `hyper-ui-ux` as the last build stage), when the user asks to commit and push or to merge into named branches and push; after `hyper-skill` or `hyper-documentation` also for a pull request | The delivery phrase and the named target branches |

## 3. Stage Order

Chosen stages always run in this order. Skip the ones that were not chosen.

```text
hyper-research -> hyper-seo -> hyper-architecture -> hyper-mcp -> hyper-ui-ux -> (hyper-plan [-> hyper-execute] | hyper-mass | hyper-execute | hyper-skill | hyper-documentation) [-> hyper-git]
```

- Upstream stages (`hyper-research`, `hyper-seo`, `hyper-architecture`) produce evidence for the tail. In a Build job they run in report mode; the tail makes the code change.
- `hyper-mcp` is the tail when it is the last chosen stage: it builds, fixes, migrates, or connects and verifies the result itself. When `hyper-plan` or `hyper-mass` follows it, it runs in audit mode and its report is the plan's input.
- `hyper-ui-ux` is the tail when it is the last chosen stage: it designs, restyles, mocks up, or cleans the interface and verifies it itself. When `hyper-plan` or `hyper-mass` follows it, it runs in `brief-only` mode for an interface that does not exist yet or in `audit` mode for an existing one, and its saved brief or report is the plan's input.
- Otherwise the tail is exactly one of: `hyper-plan` (which continues into `hyper-execute` by itself), `hyper-mass`, `hyper-execute` alone for an existing plan, `hyper-skill` for a skill folder, or `hyper-documentation` for a document or prompt artifact.
- `hyper-git` is never a tail on its own: it runs after a tail that changed files but owns no delivery. `hyper-plan`, `hyper-execute`, and `hyper-mass` deliver for themselves, so `hyper-git` never follows them.
- In a Report job the chain ends at the last requested stage. A Report job that asks for a plan ends at `hyper-plan` with `--plan-only`.
- At most four stages run. A chain that seems to need more is two jobs: run the first and report the second as the next step.

## 4. Chain Recipes

| Job | Chain |
|---|---|
| Architecture review only | `hyper-architecture` |
| Refactor or restructure | `hyper-architecture` -> `hyper-plan` |
| Feature or fix across several files | `hyper-plan` |
| Feature that adds a route, module, or server boundary | `hyper-architecture` -> `hyper-plan` |
| Library or technology choice, then adoption | `hyper-research` -> `hyper-plan` |
| Framework or major-version migration | `hyper-research` -> `hyper-architecture` -> `hyper-plan` |
| MCP server or client built, fixed, migrated, or connected | `hyper-mcp` |
| MCP audit or report only | `hyper-mcp` in audit mode, alone |
| MCP server that wraps an unfamiliar external API ("Notion API를 MCP로") | `hyper-research` -> `hyper-mcp` |
| MCP change delivered as a PR or ship, or one that also changes non-MCP modules | `hyper-mcp` (audit) -> `hyper-plan` |
| Interface designed, restyled, mocked up, or cleaned of generic patterns | `hyper-ui-ux` |
| Interface audit or design direction only | `hyper-ui-ux` in `audit` or `brief-only` mode, alone |
| Interface work delivered as a PR or ship, or one that also needs API, data, or route changes | `hyper-ui-ux` (`audit` or `brief-only`) -> `hyper-plan` |
| Interface that depends on current external guidance ("최신 가이드라인 확인해서") | `hyper-research` -> `hyper-ui-ux` |
| Research report only | `hyper-research` |
| SEO audit or report only | `hyper-seo` |
| SEO score loop ("최대 점수까지", "keep improving the score") | `hyper-seo` in its optimize mode, alone |
| SEO fixes implemented as a planned change | `hyper-seo` -> `hyper-plan` |
| Dependency-ordered multi-agent phase | `hyper-mass`, with upstream stages before it when their signals are present |
| Existing plan run or resumed | `hyper-execute` |
| Skill folder created or refactored | `hyper-skill` |
| Skill folder that depends on current provider docs ("최신 규격", "latest spec") | `hyper-research` -> `hyper-skill` |
| README, `AGENTS.md`, document, rule pack, reusable prompt, template, pack, or prompt eval fixture created or refactored | `hyper-documentation` |
| Document or prompt that depends on current external sources or provider guidance | `hyper-research` -> `hyper-documentation` |
| Skill folder, document, MCP, or interface change, then commit and push ("커밋하고 푸시까지") | that chain -> `hyper-git` in commit mode |
| Same, then merge into named branches ("dev, main에 머지하고 푸시") | that chain -> `hyper-git` in commit mode with `&& <branch>` targets for this run's commits, or workflow mode when a whole work branch must be merged |
| Skill folder or document, then a pull request ("PR까지") | that chain -> `hyper-git` in workflow mode; an MCP or interface job with "PR까지" or "ship" keeps the audit -> `hyper-plan` route above |

Each `hyper-plan` row continues into `hyper-execute` unless the job is a Report job.

## 5. Tie-Breaks

- A stage the user names inside a longer request ("hyper-research로 조사하고 바로 적용해") is chosen, and the other stages still follow the signals.
- `hyper-mass` and `hyper-plan` never run in one chain. Choose `hyper-mass` only on its explicit signal; otherwise choose `hyper-plan`.
- `hyper-skill` and `hyper-plan` never run in one chain. When the requested output is a skill folder, choose `hyper-skill`; a plan file is not its input.
- `hyper-documentation` never runs with `hyper-plan`. Choose by the primary deliverable: a README, `AGENTS.md`, document, or reusable prompt artifact goes to `hyper-documentation`, which picks its own mode, and a skill folder goes to `hyper-skill`.
- `hyper-mcp` and `hyper-skill` never run in one chain. When the requested output is a skill folder, even one about MCP, choose `hyper-skill`.
- `hyper-mcp` and `hyper-architecture` both run only when the job also restructures non-MCP folders, routes, or modules; an MCP-only job routes to `hyper-mcp` without the architecture stage.
- Delivery words ("PR까지", "ship") on an MCP job put `hyper-mcp` in audit mode before `hyper-plan`, because only the plan and execute stages own delivery.
- `hyper-ui-ux` never runs with `hyper-skill` or `hyper-documentation` in one chain. A skill folder, a general document, or a prompt about design goes to its own stage; a project's `DESIGN.md` that records the product's visual system goes to `hyper-ui-ux`.
- A feature whose main output is behavior (a new API, a data flow, a fix) routes by the existing rows even when it has a screen; add `hyper-ui-ux` only when the request asks for the look itself ("디자인 신경 써서", "AI 티 안 나게", "redesign").
- Delivery words ("PR까지", "ship") on an interface job put `hyper-ui-ux` in `audit` or `brief-only` mode before `hyper-plan`, because only the plan and execute stages own delivery.
- `hyper-git` never runs with `hyper-plan`, `hyper-execute`, or `hyper-mass` in one chain; their delivery flags carry the same words. A Git-only request with no other stage (commit, worktree, issue, or merge alone) is not a `hyper` job.
- On a `hyper-git` delivery stage, merges into `main`, `master`, the default branch, or a deploy branch happen only when the user named that branch.
- An existing plan file wins over a new plan only when the user points at it or says to resume. A new Build request with an unrelated old plan gets a new plan.
- When the stack is outside the architecture stage's supported set, keep the stage anyway: it decides support from files and stops with a reason, and `rules/stage-handoff.md` §4 records that stop as a skip.

## 6. Delivery and Report-Only Words

Pass these through to the stage that owns them; never pick one the user did not say.

| User words | Passed to |
|---|---|
| none | local delivery (the stage's default) |
| "PR까지", "PR만", "make a PR", `--make-pr` | `--make-pr` |
| "머지까지", "배포까지", "ship", `--ship` | `--ship` |
| "계획만", "실행하지 말고", "plan only", `--plan-only` | `--plan-only`; the chain ends after the plan |
| "승인은 내가 할게", "I'll approve" | The approval hold, passed as said; the chain ends after the plan |
| "커밋하고 푸시", "commit and push", after a non-delivering tail | `hyper-git` delivery stage in commit mode |
| "<branch>, <branch>에 머지하고 푸시", "merge into dev and main", after a non-delivering tail | `hyper-git` delivery stage with those targets, in the named order |
| "PR까지" after `hyper-skill` or `hyper-documentation` | `hyper-git` delivery stage in workflow mode (pull request) |

## 7. Ambiguity

- When the files and the request decide the chain, route without asking.
- Ask one question only when two chains are equally supported and the wrong one would redo most of the work, such as "구조 바꿔줘" in a repository with two supported apps and no path named. Name the candidate chains, recommend one, and say that the run continues with the recommendation if no answer comes.
- When the request contradicts the repository (the user names a stack the manifests do not show), ask once with both pieces of evidence.

## 8. Route Line

Print one Korean line before the first stage:

```text
워크플로: <stage> -> <stage> -> ... (전달: local|make-pr|ship|plan-only|git:<mode> <targets>) / 근거: <stage>=<signal>; <stage>=<signal>
```

A run that stops before the first stage prints the same line with the stop reason in place of the chain.

## Sources

> Checked 2026-11-07.

| Claim | Source |
|---|---|
| The eleven stage skills and the orchestrator role | user instruction, 2026-11-06; `hyper-skill`, `hyper-mcp`, and the documentation stage added by user instruction, 2026-11-07; the documentation stages merged into `hyper-documentation` by user instruction, 2026-11-07; `hyper-ui-ux` added by user instruction, 2026-11-07; `hyper-git` added as the delivery stage by user instruction, 2026-11-07 |
| Each stage's trigger, output, and exclusions, including `hyper-mass` excluding plan-file execution and `hyper-execute` requiring an existing plan | each stage skill's own `SKILL.md` in this repository, 2026-11-06 |
| The delivery words, the plan-only and approval-hold words, and the plan-to-execute auto-continue | the plan skill's handoff rule in this repository, 2026-11-06 |
| The stage order, the four-stage cap, the recipes, and the tie-breaks | this package's chosen design, not a validated optimum |
