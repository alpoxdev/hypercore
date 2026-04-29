---
name: autoresearch-code
description: "[Hyper] Optimize an existing codebase through baseline-first experiments, binary evaluation, and one-mutation-at-a-time iteration. Use for codebase autoresearch, measured bottleneck reduction, benchmarked code optimization, and evidence-backed refactors."
compatibility: Works best with read/edit/write tools, shell execution, code validation commands, repeatable evals, and artifact recording.
---

@rules/experiment-loop.md
@rules/validation-and-exit.md

# Code Autoresearch

> Improve an existing codebase through measurable experiments instead of one large rewrite.

<purpose>

- Capture the current baseline first, score outcomes with binary evaluations, and keep only changes that improve the score without regression.
- Systematically improve slow paths, unclear structure, duplicated logic, oversized outputs, unstable validation, or weak developer workflows.
- Leave improved code plus resumable artifacts under `.hypercore/autoresearch-code/[codebase-name]/`: `results.tsv`, `results.json`, `changelog.md`, `dashboard.html`, and `baseline.md`.

</purpose>

<routing_rule>

Use `autoresearch-code` when the user wants iterative, evaluation-based optimization of an existing codebase.

Prefer direct execution for a single obvious bug fix, one small refactor, or a small change with obvious validation.

Route neighboring work elsewhere:

- Clear single bug: `bug-fix` or a direct scoped fix.
- New skill creation or skill folder refactor: `skill-maker`.
- Runbook, spec, or documentation as the main output: `docs-maker`.
- Version bump or version-file synchronization: `version-update`.

Do not use `autoresearch-code` when:

- There is no existing codebase to optimize.
- The user wants new-project scaffolding rather than iterative optimization.
- The user wants a one-off manual change without baseline, evals, or repeated scoring.

</routing_rule>

<trigger_conditions>

Positive examples:

- "Run autoresearch on this repository and keep only optimizations that improve the score."
- "Benchmark build time, bundle size, and test stability, then iterate experimentally."
- "Find the bottleneck in this codebase and improve it with measurable experiments."

Negative examples:

- "Create a new Vite app."
- "Fix this one test and stop."

Boundary example:

- "Clean up this codebase once and review it."
  If repeated experiments are not requested, direct cleanup or review is usually better.

</trigger_conditions>

<supported_targets>

- Existing repositories and multi-file code areas.
- Performance, maintainability, reliability, DX, and cost bottlenecks.
- Baseline capture, experiment logging, and artifact dashboards.
- Structural refactors that produce measurable improvement.

</supported_targets>

<required_inputs>

Collect these before the first mutation:

1. Target scope. Default: current repository root.
2. Optimization goal, such as build time, bundle size, latency, flaky tests, query count, duplication, or memory usage.
3. Eval pack: `generic`, `web`, `node`, `api`, or `monorepo`.
4. Proof command for current behavior. Prefer existing build, test, typecheck, benchmark, or smoke commands.
5. Three to five test prompts or scenarios.
6. Three to six binary evaluations.
7. Runs per experiment. Default: `5`.
8. Selection budget or stopping limit.

Input policy:

- If the user already gave a clear goal and the work is low-risk, infer conservative defaults and record them before the baseline.
- Ask only when missing information would make the eval meaningless or push optimization toward the wrong bottleneck.
- Do not mutate the codebase until the baseline plan is explicit.

For broad optimization requests without a prompt pack:

- First choose a domain pack from [references/self-test-pack.md](references/self-test-pack.md).
- Fall back to the generic pack only when no domain pack fits.
- Record the chosen pack, pack version, and any harness deviations in the experiment log before scoring.

</required_inputs>

<language_support>

- User prompts, eval wording, and dashboard labels may be in the user's language when that reflects real usage.
- Keep machine-consumed strings such as commands, filenames, JSON keys, and code identifiers compatible with the existing ASCII contracts.
- The core skill and self-test pack should include realistic user-language examples where they are needed to validate trigger boundaries.

</language_support>

<scope_contract>

Before experiment `0`:

- Decide whether the run owns the repository root, a subdirectory, or one package inside a larger codebase.
- Do not mix multiple repositories in one experiment loop.
- Record ownership and package/module boundaries in `baseline.md`.
- If ownership changes mid-run, reset the baseline before scoring again.

</scope_contract>

<baseline_contract>

Before experiment `0`:

- Choose one proof command that will be reused throughout the run.
- Write `baseline.md` before editing code.
- Record current metrics, pass/fail observations, and non-regression constraints.
- If the proof command or scoring condition changes, log a suite reset and capture a new baseline.

Use [references/code-baseline-guide.md](references/code-baseline-guide.md) when the baseline shape is unclear.

</baseline_contract>

<autoresearch_integration>

This skill is not complete from `.hypercore` experiment logs alone. When used through `$autoresearch`, also satisfy this bridge contract.

Default validation mode:

- `mission-validator-script`

State storage:

- Record these values in `.omx/state/.../autoresearch-state.json`:
  - `validation_mode`: `mission-validator-script`
  - `completion_artifact_path`: `.omx/specs/autoresearch-{codebase-name}/result.json`
  - `mission_validator_command`: command that runs final proof/eval and updates result JSON
  - `output_artifact_path`: `.hypercore/autoresearch-code/{codebase-name}/results.json`

Completion artifact example:

```json
{
  "status": "passed",
  "passed": true,
  "summary": "best score improved without regression",
  "output_artifact_path": ".hypercore/autoresearch-code/my-repo/results.json"
}
```

Exit rules:

- A higher `.hypercore` score is necessary evidence, not sufficient evidence.
- The loop completes only when `completion_artifact_path` exists and records `passed: true` or `status: "passed"`.
- If the proof command, eval pack, or rollback condition changes, record a reset event in both `.hypercore` results and `.omx/specs/.../result.json`.

</autoresearch_integration>

<autonomy_contract>

After the baseline plan is explicit:

- Reuse the same prompt pack and eval set throughout the experiment.
- Do not stop between experiments unless blocked by safety, a bad eval set, or a true execution blocker.
- Apply exactly one mutation at a time.
- Log any eval-set or scoring-method change as an explicit event before continuing.

</autonomy_contract>

<skill_architecture>

Keep the core skill focused on triggers, owned work, workflow, and mutation discipline.

Load support files intentionally:

- Use [references/code-baseline-guide.md](references/code-baseline-guide.md) to collect initial metrics and constraints.
- Use [references/eval-guide.md](references/eval-guide.md) for binary eval design.
- Use [references/artifact-spec.md](references/artifact-spec.md) for dashboard, result file, changelog, and workspace schemas.
- Use [references/self-test-pack.md](references/self-test-pack.md) when the user gives only a broad optimization request.
- If the bottleneck type is already clear, use one of these domain packs directly:
  - [references/self-test-pack.web.md](references/self-test-pack.web.md)
  - [references/self-test-pack.node.md](references/self-test-pack.node.md)
  - [references/self-test-pack.api.md](references/self-test-pack.api.md)
  - [references/self-test-pack.monorepo.md](references/self-test-pack.monorepo.md)
- Render `dashboard.html` and `results.js` from the official dashboard template with `scripts/render-dashboard.sh`.

Artifact lifecycle requirements:

- Create a workspace under `.hypercore/autoresearch-code/[codebase-name]/`.
- Synchronize `results.tsv` and `results.json` after every experiment.
- Record ownership scope, chosen pack, environment, and rollback conditions in artifacts.
- Treat `dashboard.html` as a live view derived from `results.json`.
- Keep `results.json.status` as `running` during the loop and `complete` at exit.
- The dashboard must render when opened directly through a local `file://` URL.
- Open the dashboard immediately when the runtime can safely open local HTML.

When the codebase structure is weak:

- Prefer deleting dead code over adding a new abstraction.
- Move repeated policy into existing local docs or rules only when the codebase already supports that structure.
- Keep each experiment small enough to explain and verify.

</skill_architecture>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Read the target scope and current validation surface | Baseline understanding |
| 1 | Convert success conditions into binary evals | Eval set |
| 2 | Initialize experiment workspace and artifacts | `.hypercore/autoresearch-code/[codebase-name]/` |
| 3 | Run experiment `0` against the unmodified codebase | Baseline score |
| 4 | Repeat one-mutation-at-a-time experiments | Keep/discard decision |
| 5 | Verify final results and summarize the run | Final report |

### Phase details

#### Phase 0: Understand the target

- Read the relevant code areas, build/test commands, and existing system documents.
- Confirm the owned repository or sub-scope before choosing commands.
- Identify whether the main failure is performance, reliability, DX, structure, output size, or something else.
- Choose the domain pack that matches the bottleneck before writing evals.
- Record non-regression constraints and the command that proves them.
- Capture initial metrics before editing anything.

#### Phase 1: Build the eval set

- Convert success criteria into binary pass/fail checks.
- Make evals non-overlapping, observable, and hard to game.
- Ensure at least one eval checks the user's actual bottleneck rather than generic code quality.

#### Phase 2: Prepare the workspace

- Create `.hypercore/autoresearch-code/[codebase-name]/` at the repository root.
- Record the original state in `baseline.md`.
- Initialize `results.tsv`, `results.json`, `changelog.md`, and `dashboard.html` according to [references/artifact-spec.md](references/artifact-spec.md).
- Render the official dashboard template with `scripts/render-dashboard.sh`.

#### Phase 3: Establish the baseline

- Run the current codebase before editing anything.
- Score every run against every eval.
- Record experiment `0` as `baseline`.

#### Phase 4: Experiment loop

- Find the highest-value failure pattern in the failed output.
- Form exactly one hypothesis.
- Apply exactly one mutation.
- Re-run the same eval set.
- Keep a mutation when score improves. Discard it when score is flat or worse unless it is a no-regression simplification.
- Record every experiment, including discarded ones.

#### Phase 5: Exit and handoff

- Stop only when [rules/validation-and-exit.md](rules/validation-and-exit.md) allows it: user stop, budget limit, or stable high score.
- Report score delta, total experiments, keep ratio, most effective change, remaining failure patterns, and whether the best experiment should remain `keep` or be promoted.

</workflow>

<mutation_defaults>

Prefer these mutation types:

- Remove duplicated logic from a hot path.
- Add one cache, batch, or guard to a measured bottleneck.
- Remove one duplicated branch or dead dependency.
- Move one expensive operation out of the critical path.
- Move one validation step earlier to reduce rework.
- Delete configuration or abstraction that adds measurable burden without value.

Avoid these mutation types:

- Rewriting the entire codebase from scratch.
- Bundling unrelated changes into one experiment.
- Adding dependencies without measurement.
- Optimizing only a surrogate metric the user does not care about.

</mutation_defaults>

<deliverables>

At exit, leave behind:

- The improved code changes.
- `.hypercore/autoresearch-code/[codebase-name]/dashboard.html`.
- `.hypercore/autoresearch-code/[codebase-name]/results.json`.
- `.hypercore/autoresearch-code/[codebase-name]/results.js` or an equivalent file-based bridge.
- `.hypercore/autoresearch-code/[codebase-name]/results.tsv`.
- `.hypercore/autoresearch-code/[codebase-name]/changelog.md`.
- `.hypercore/autoresearch-code/[codebase-name]/baseline.md`.
- `.omx/specs/autoresearch-[codebase-name]/result.json` completion artifact.
- `validation_mode` and `completion_artifact_path` bridge state in `.omx/state/.../autoresearch-state.json`.

Follow [references/artifact-spec.md](references/artifact-spec.md) for schemas and examples.

</deliverables>

<validation>

The run must satisfy:

- The core skill and self-test pack can validate trigger boundaries with realistic user-language examples.
- Baseline-first, one-mutation-at-a-time, and explicit stop conditions are preserved.
- Scope, pack, proof command, environment, and rollback conditions are recorded in artifacts.
- Dashboard and support documentation may be localized for readers, but data contracts remain stable.

</validation>
