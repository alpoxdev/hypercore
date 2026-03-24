---
name: autoresearch-code
description: "Optimize an existing codebase with baseline-first experiments, binary evals, targeted mutations, and keep/discard scoring. Use when: analyze code bottlenecks, run autoresearch on a repo, benchmark code optimizations, improve performance or maintainability with measured iterations, or add eval-driven rigor to a code refactor."
compatibility: Works best with read/edit/write, shell execution, and code validation tools for inspection, repeated evaluation, and artifact logging.
---

@rules/experiment-loop.md
@rules/validation-and-exit.md

# Autoresearch for Code

> Improve an existing codebase with measured iterations instead of one-shot rewrites.

<purpose>

- Optimize an existing codebase by establishing a baseline, scoring outcomes with binary evals, and keeping only changes that improve the score.
- Strengthen weak code areas when failures come from slow paths, unclear architecture, duplicated logic, oversized outputs, flaky validation, or fragile developer workflows.
- Produce an improved codebase plus durable experiment artifacts under `.hypercore/autoresearch-code/[codebase-name]/`: `results.tsv`, `results.json`, `changelog.md`, `dashboard.html`, and `baseline.md`.

</purpose>

<routing_rule>

Use `autoresearch-code` when the user wants repeated, eval-driven optimization of an existing codebase.

Use direct editing when the main job is a single bug fix, one-pass refactor, or a small change with obvious validation.

Route to a neighboring workflow instead when:

- the request is a single concrete bug with a clear failing symptom. Use `bug-fix` or a direct scoped fix path.
- the output should be a new skill or a refactor of a skill folder. Use `skill-maker`.
- the output is mainly a runbook, spec, or documentation artifact. Use `docs-maker`.
- the user wants a version bump or version-file synchronization task. Use `version-update`.

Do not use `autoresearch-code` when:

- there is no existing codebase to optimize
- the user wants a new project scaffold rather than iterative code optimization
- the user only wants one manual change with no baseline, no eval suite, and no repeated scoring

</routing_rule>

<trigger_conditions>

Positive examples:

- "Run autoresearch on this repo and keep only score-improving optimizations."
- "Benchmark build speed, bundle size, and test reliability, then iterate."
- "Find bottlenecks in this codebase and improve them with measured experiments."

Negative examples:

- "Create a new Vite app for me."
- "Fix this one failing test and stop."

Boundary example:

- "Tighten this codebase once and review it." Prefer direct editing unless the user explicitly wants repeated eval-driven optimization.

</trigger_conditions>

<supported_targets>

- Existing repositories and multi-file code areas
- Performance, maintainability, reliability, developer-experience, and cost-related code bottlenecks
- Baseline capture, experiment logging, and artifact dashboards that let future agents continue the optimization
- Structural refactors that materially improve measured outcomes

</supported_targets>

<required_inputs>

Collect these before the first mutation:

1. Target scope. Default: current repository root.
2. Optimization goals. Example: build time, bundle size, latency, flaky tests, query count, duplication, memory usage.
3. Evaluation pack. Choose one of: `generic`, `web`, `node`, `api`, or `monorepo`.
4. Proof commands for the current behavior. Prefer existing build, test, typecheck, benchmark, or smoke commands.
5. Three to five test prompts or scenarios.
6. Three to six binary evals.
7. Runs per experiment. Default: `5`.
8. Optional budget cap.

Input policy:

- If the user already gave clear goals and the work is low-risk, infer conservative defaults and record them before the baseline.
- Ask for clarification only when missing information would make the eval meaningless or point the run at the wrong bottleneck.
- Do not start mutating the codebase before the baseline plan is explicit.

For broad code optimization when the user does not supply a prompt pack:

- use [references/self-test-pack.md](references/self-test-pack.md) to choose a domain pack first
- fall back to the generic pack only when no domain pack fits
- record the selected pack, pack version, and any deviations in the experiment log before scoring

</required_inputs>

<scope_contract>

Before experiment `0`:

- resolve whether the run owns the repository root, a subdirectory, or one package inside a larger codebase
- do not mix multiple repositories in one experiment loop
- record the owned scope and package or module boundaries in `baseline.md`
- if the owned scope changes later, reset the baseline before scoring again

</scope_contract>

<baseline_contract>

Before experiment `0`:

- choose the proof commands you will reuse across the whole run
- write `baseline.md` before editing any code
- record current metrics, pass/fail observations, and the non-regression constraints that matter
- if proof commands or scoring conditions change later, log that as a suite reset before scoring again

Use [references/code-baseline-guide.md](references/code-baseline-guide.md) when the baseline shape is still unclear.

</baseline_contract>

<autonomy_contract>

Once the baseline plan is explicit:

- reuse the same prompt pack and eval suite across experiments
- do not pause between experiments unless a blocker, safety issue, or invalid eval suite forces a stop
- keep the loop to one mutation at a time
- log any suite reset or scoring-method change as an explicit event before continuing

</autonomy_contract>

<skill_architecture>

Keep the core skill focused on trigger, owned job, workflow, and mutation discipline.

Load support files intentionally:

- Use [references/code-baseline-guide.md](references/code-baseline-guide.md) to capture the initial metrics and constraints before editing.
- Use [references/eval-guide.md](references/eval-guide.md) to design binary evals for code optimization.
- Use [references/artifact-spec.md](references/artifact-spec.md) for dashboard, results, changelog, and workspace schemas.
- Use [references/self-test-pack.md](references/self-test-pack.md) when the user gives only a broad optimization request and you need to pick a domain pack.
- Use one of the domain packs when the bottleneck shape is already clear:
  - [references/self-test-pack.web.md](references/self-test-pack.web.md)
  - [references/self-test-pack.node.md](references/self-test-pack.node.md)
  - [references/self-test-pack.api.md](references/self-test-pack.api.md)
  - [references/self-test-pack.monorepo.md](references/self-test-pack.monorepo.md)
- Use `scripts/render-dashboard.sh` to materialize `dashboard.html` and `results.js` from the canonical dashboard template.

Artifact lifecycle requirements:

- create the workspace under `.hypercore/autoresearch-code/[codebase-name]/`
- keep `results.tsv` and `results.json` synchronized after every experiment
- record the owned scope, selected pack, environment, and rollback conditions in the artifacts
- treat `dashboard.html` as a live view backed by `results.json`
- set `results.json.status` to `running` during the loop and `complete` when the run ends
- make the dashboard render correctly when opened directly via `file://` in a local browser
- open the dashboard immediately when the runtime can open local HTML safely

When the codebase itself is weakly structured:

- prefer deleting dead code over layering more abstractions
- move repeated policy into existing local docs or rules only when the codebase already supports that structure
- keep each experiment narrow enough to explain and validate clearly

</skill_architecture>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Read the target scope and current validation surfaces | Baseline understanding |
| 1 | Convert success criteria into binary evals | Eval suite |
| 2 | Initialize the experiment workspace and artifacts | `.hypercore/autoresearch-code/[codebase-name]/` |
| 3 | Run experiment `0` on the unmodified codebase | Baseline score |
| 4 | Run one-mutation-at-a-time experiments | Keep/discard decisions |
| 5 | Validate the final result and summarize the run | Final report |

### Phase details

#### Phase 0: Understand the target

- Read the relevant code area, build/test commands, and existing docs that define the system.
- Resolve the owned repository or subdirectory scope before choosing commands.
- Identify whether the dominant failure is performance, reliability, DX, architecture, or output size.
- Choose the domain pack that matches the bottleneck before writing evals.
- Record the non-regression constraints and the commands that prove them before writing evals.
- Capture the initial metrics before editing anything.

#### Phase 1: Build the eval suite

- Translate success criteria into binary pass/fail checks.
- Keep evals distinct, observable, and hard to game.
- Include at least one eval tied to the user's actual bottleneck rather than generic code quality.

#### Phase 2: Prepare the workspace

- Create `.hypercore/autoresearch-code/[codebase-name]/` at the repository root.
- Record the original state in `baseline.md`.
- Initialize `results.tsv`, `results.json`, `changelog.md`, and `dashboard.html` using [references/artifact-spec.md](references/artifact-spec.md).
- Render `dashboard.html` from the canonical template with `scripts/render-dashboard.sh`.

#### Phase 3: Establish the baseline

- Run the current codebase before editing anything.
- Score every run against every eval.
- Record experiment `0` as `baseline`.

#### Phase 4: Run the experiment loop

- Inspect failing outputs and identify the highest-value failure pattern.
- Form one hypothesis.
- Make one targeted mutation.
- Re-run the same eval suite.
- Keep score-improving mutations. Revert flat or worse mutations unless the change materially simplifies the codebase with no regression.
- Log every experiment, including discarded ones.

#### Phase 5: Finish and deliver

- Stop on user instruction, budget cap, or stable high performance per [rules/validation-and-exit.md](rules/validation-and-exit.md).
- Report score delta, total experiments, keep rate, strongest changes, remaining failure patterns, and whether the best mutation is only `keep` or ready to `promote`.

</workflow>

<mutation_defaults>

Prefer these mutation types:

- remove duplicated logic on a hot path
- cache or batch an expensive operation
- reduce repeated renders, queries, or file system work
- move an important validation or guard earlier
- simplify an overgrown module that blocks reliable iteration
- delete code or configuration that adds cost without measurable benefit

Avoid these mutation types:

- rewriting the whole codebase from scratch
- making many unrelated changes in one experiment
- adding dependencies without a measured reason
- optimizing a surrogate metric that does not reflect user value

</mutation_defaults>

<deliverables>

The completed run should leave:

- the improved code changes in place
- `.hypercore/autoresearch-code/[codebase-name]/dashboard.html`
- `.hypercore/autoresearch-code/[codebase-name]/results.json`
- `.hypercore/autoresearch-code/[codebase-name]/results.js` or an equivalent file-backed bridge when direct local browser opening requires it
- `.hypercore/autoresearch-code/[codebase-name]/results.tsv`
- `.hypercore/autoresearch-code/[codebase-name]/changelog.md`
- `.hypercore/autoresearch-code/[codebase-name]/baseline.md`

See [references/artifact-spec.md](references/artifact-spec.md) for file schemas and examples.

</deliverables>

<validation>

Minimum checks before declaring success:

- a baseline exists before mutations
- evals are binary and non-overlapping
- every mutation is logged as keep or discard
- the final score improved, or the codebase was explicitly simplified with no regression
- support files remain easy to discover and no deeper than one level from `SKILL.md`

Use [rules/validation-and-exit.md](rules/validation-and-exit.md) for the exit checklist.

</validation>

<final_report>

Always deliver:

1. Baseline score to final score
2. Total experiments run
3. Keep rate
4. Top changes that helped most
5. Remaining failure patterns
6. Location of the artifacts

</final_report>
