# Workflow Routing

> Classify the requested output, add only the stages whose artifacts the job consumes, and run them in one fixed order.

## 1. Classify the Job

Decide the job from the requested output, then confirm it with repository files. Read the request first, then only the files a signal names.

| Job class | Requested output | Example words |
|---|---|---|
| Build | Changed code: a feature, fix, refactor, migration, or adoption | 만들어, 추가해, 고쳐, 리팩토링해, 옮겨, 적용해, implement, refactor, migrate |
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
| `hyper-plan` | A Build job touches several files or steps, or a Report job asks for a plan | The request phrase |
| `hyper-execute` | Only as the first stage: a plan file under `.hyper/plans/` already exists and the user wants it run or resumed | The plan path that was read |
| `hyper-mass` | The user asks for a dependency graph, a DAG, "의존성 그래프", "단계별 병렬", or several tasks where some must finish before others start, and no plan file is wanted | The request phrase |

## 3. Stage Order

Chosen stages always run in this order. Skip the ones that were not chosen.

```text
hyper-research -> hyper-seo -> hyper-architecture -> (hyper-plan [-> hyper-execute] | hyper-mass | hyper-execute)
```

- Upstream stages (`hyper-research`, `hyper-seo`, `hyper-architecture`) produce evidence for the tail. In a Build job they run in report mode; the tail makes the code change.
- The tail is exactly one of: `hyper-plan` (which continues into `hyper-execute` by itself), `hyper-mass`, or `hyper-execute` alone for an existing plan.
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
| Research report only | `hyper-research` |
| SEO audit or report only | `hyper-seo` |
| SEO score loop ("최대 점수까지", "keep improving the score") | `hyper-seo` in its optimize mode, alone |
| SEO fixes implemented as a planned change | `hyper-seo` -> `hyper-plan` |
| Dependency-ordered multi-agent phase | `hyper-mass`, with upstream stages before it when their signals are present |
| Existing plan run or resumed | `hyper-execute` |

Each `hyper-plan` row continues into `hyper-execute` unless the job is a Report job.

## 5. Tie-Breaks

- A stage the user names inside a longer request ("hyper-research로 조사하고 바로 적용해") is chosen, and the other stages still follow the signals.
- `hyper-mass` and `hyper-plan` never run in one chain. Choose `hyper-mass` only on its explicit signal; otherwise choose `hyper-plan`.
- An existing plan file wins over a new plan only when the user points at it or says to resume. A new Build request with an unrelated old plan gets a new plan.
- When the stack is outside the architecture stage's supported set, keep the stage anyway: it decides support from files and stops with a reason, and `rules/stage-handoff.md` §4 records that stop as a skip.

## 6. Delivery and Report-Only Words

Pass these through to the stage that owns them; never pick one the user did not say.

| User words | Passed to the plan or execute stage |
|---|---|
| none | local delivery (the stage's default) |
| "PR까지", "PR만", "make a PR", `--make-pr` | `--make-pr` |
| "머지까지", "배포까지", "ship", `--ship` | `--ship` |
| "계획만", "실행하지 말고", "plan only", `--plan-only` | `--plan-only`; the chain ends after the plan |
| "승인은 내가 할게", "I'll approve" | The approval hold, passed as said; the chain ends after the plan |

## 7. Ambiguity

- When the files and the request decide the chain, route without asking.
- Ask one question only when two chains are equally supported and the wrong one would redo most of the work, such as "구조 바꿔줘" in a repository with two supported apps and no path named. Name the candidate chains, recommend one, and say that the run continues with the recommendation if no answer comes.
- When the request contradicts the repository (the user names a stack the manifests do not show), ask once with both pieces of evidence.

## 8. Route Line

Print one Korean line before the first stage:

```text
워크플로: <stage> -> <stage> -> ... (전달: local|make-pr|ship|plan-only) / 근거: <stage>=<signal>; <stage>=<signal>
```

A run that stops before the first stage prints the same line with the stop reason in place of the chain.

## Sources

> Checked 2026-11-06.

| Claim | Source |
|---|---|
| The six stage skills and the orchestrator role | user instruction, 2026-11-06 |
| Each stage's trigger, output, and exclusions, including `hyper-mass` excluding plan-file execution and `hyper-execute` requiring an existing plan | each stage skill's own `SKILL.md` in this repository, 2026-11-06 |
| The delivery words, the plan-only and approval-hold words, and the plan-to-execute auto-continue | the plan skill's handoff rule in this repository, 2026-11-06 |
| The stage order, the four-stage cap, the recipes, and the tie-breaks | this package's chosen design, not a validated optimum |
