---
name: autoresearch-skill
description: "[Hyper] Optimize an existing Codex skill through baseline-first experiments, binary evaluation, and one-mutation-at-a-time iteration. Use for skill autoresearch, measured trigger/workflow improvement, self-optimizing a skill, or benchmarking skill changes."
compatibility: Works best with read/edit/write tools, shell search, repeated evaluations, and artifact logging for skill experiments.
---

@rules/experiment-loop.md
@rules/validation-and-exit.md

# Skill Autoresearch

> Improve an existing skill through measurable experiments instead of one large rewrite.

<purpose>

- Capture the current skill baseline, score outputs with binary evals, and keep only changes that improve the score without regression.
- Improve ambiguous triggers, bloated core instructions, weak support-file placement, missing validation, or unclear workflow boundaries.
- Leave the improved skill plus resumable artifacts under `.hypercore/autoresearch-skill/[skill-name]/`: `results.tsv`, `results.json`, `changelog.md`, `dashboard.html`, and `SKILL.md.baseline`.

</purpose>

<routing_rule>

Use `autoresearch-skill` when the user wants to optimize an existing skill through repeated experiments and evaluation.

Use `skill-maker` when the main job is creating a new skill or doing one structural refactor without an experiment loop.

Do not use `autoresearch-skill` when:

- There is no existing skill to optimize.
- The work is general document improvement rather than skill improvement.
- The user wants a one-off manual edit without baseline, evals, or repeated scoring.

</routing_rule>

<trigger_conditions>

Positive examples:

- "Run autoresearch on `skills/web-clone/SKILL.md` and keep only changes that raise the score."
- "Benchmark this skill with binary evals and save the results under `.hypercore`."
- "Improve this skill prompt and references through repeated experiments."

Negative examples:

- "Create a new Codex skill for browser QA."
- "Rewrite this runbook for readability."

Boundary example:

- "Polish this skill once and review it."
  If repeated experiments are not requested, direct `skill-maker` refactoring is usually better.

</trigger_conditions>

<supported_targets>

- Existing skill folders, especially `SKILL.md` and directly linked `rules/` or `references/`.
- Trigger wording, workflow clarity, output discipline, and validation guidance.
- Skill structure refactors that measurably improve evaluation outcomes.
- Experiment artifacts that let the next operator resume without re-discovery.

</supported_targets>

<required_inputs>

Collect these before the first mutation:

1. Target skill path.
2. Three to five test prompts or scenarios.
3. Three to six binary evaluations.
4. Runs per experiment. Default: `5`.
5. Interval between timed-loop runs. Default: `2 minutes`.
6. Selection budget or stopping limit.

Input policy:

- If the user gave a clear intent and scope and the work is low-risk, infer conservative defaults and record them before the baseline.
- Ask only when missing information would make evals meaningless or push the skill in the wrong direction.
- Do not mutate the target skill until the baseline plan is explicit.

When autoresearching this or another skill without a supplied prompt pack:

- Use [references/self-test-pack.md](references/self-test-pack.md) as the default prompt/eval harness.
- Include realistic user-language requests when they are needed to validate trigger boundaries.
- Record any harness deviation in the experiment log before scoring.

</required_inputs>

<language_support>

- User prompts, eval wording, and artifact descriptions may be in the user's language when that reflects real usage.
- Keep machine-consumed strings such as filenames, key names, paths, and code identifiers compatible with existing ASCII contracts.
- The core skill and self-test pack should include realistic in-language positive and negative examples when trigger coverage depends on them.

</language_support>

<autoresearch_integration>

This skill is not complete from standalone `.hypercore` experiment logs alone. When used through `$autoresearch`, also satisfy this bridge contract.

Default validation mode:

- `architect-review`

State storage:

- Record these values in `.omx/state/.../autoresearch-state.json`:
  - `validation_mode`: `architect-review`
  - `completion_artifact_path`: `.omx/specs/autoresearch-{skill-name}/result.json`
  - `validator_prompt`: architect-review prompt that approves or rejects target skill output and experiment logs against the mission
  - `output_artifact_path`: `.hypercore/autoresearch-skill/{skill-name}/results.json`

Completion artifact example:

```json
{
  "status": "passed",
  "passed": true,
  "architect_review": {
    "verdict": "approved",
    "summary": "trigger precision improved without losing required workflow constraints"
  },
  "output_artifact_path": ".hypercore/autoresearch-skill/skill-maker/results.json"
}
```

Exit rules:

- A higher `.hypercore` score is necessary evidence, not sufficient evidence.
- The loop completes only when `completion_artifact_path` exists and `architect_review.verdict` is `approved`.
- If the eval set, prompt pack, or target file scope changes, record a reset event in both `.hypercore` results and `.omx/specs/.../result.json`.

</autoresearch_integration>

<autonomy_contract>

After the baseline plan is explicit:

- Reuse the same prompt pack and eval set throughout the experiment.
- Do not stop between experiments unless blocked by safety, a bad eval set, or a true execution blocker.
- Apply exactly one mutation at a time.
- Log any eval-set or scoring-method change as an explicit event before continuing.

</autonomy_contract>

<skill_architecture>

Keep the core skill focused on trigger, owned work, workflow, and mutation discipline.

Load support files intentionally:

- Use [references/eval-guide.md](references/eval-guide.md) for binary eval design.
- Use [references/skill-refactor-guide.md](references/skill-refactor-guide.md) when failures point to weak skill structure, weak support files, or poor trigger wording.
- Use [references/artifact-spec.md](references/artifact-spec.md) for dashboard, result file, changelog, and workspace schemas.
- Use [references/self-test-pack.md](references/self-test-pack.md) when no prompt pack is supplied.
- Render `dashboard.html` and `results.js` from the official dashboard template with `scripts/render-dashboard.sh`.

Artifact lifecycle requirements:

- Create a workspace under `.hypercore/autoresearch-skill/[skill-name]/`.
- Save the original target skill as `SKILL.md.baseline` before editing.
- Synchronize `results.tsv` and `results.json` after every experiment.
- Record prompt pack, eval set, target files, environment, and rollback conditions in artifacts.
- Treat `dashboard.html` as a live view derived from `results.json`.
- Keep `results.json.status` as `running` during the loop and `complete` at exit.
- The dashboard must render when opened directly through a local `file://` URL.

When skill structure is weak:

- Prefer deleting duplication over adding more instructions.
- Move repeated policy into `rules/` and detailed knowledge into `references/` only when those files will actually be used.
- Keep each mutation small enough to explain and score.

</skill_architecture>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Read the target skill and current support-file shape | Baseline understanding |
| 1 | Convert success conditions into binary evals | Eval set |
| 2 | Initialize experiment workspace and artifacts | `.hypercore/autoresearch-skill/[skill-name]/` |
| 3 | Run experiment `0` against the unmodified skill | Baseline score |
| 4 | Repeat one-mutation-at-a-time experiments | Keep/discard decision |
| 5 | Verify final results and summarize the run | Final report |

### Phase details

#### Phase 0: Understand the target

- Read `SKILL.md` and only the directly linked support files needed for the target behavior.
- Identify whether the main weakness is trigger precision, core bloat, support-file placement, workflow clarity, or validation.
- Record non-regression constraints, including instructions that must not be lost.
- Save `SKILL.md.baseline` before editing anything.

#### Phase 1: Build the eval set

- Convert success criteria into binary pass/fail checks.
- Include positive, negative, and boundary trigger prompts.
- Ensure at least one eval checks the user's actual target improvement rather than generic writing quality.

#### Phase 2: Prepare the workspace

- Create `.hypercore/autoresearch-skill/[skill-name]/` at the repository root.
- Initialize `results.tsv`, `results.json`, `changelog.md`, and `dashboard.html` according to [references/artifact-spec.md](references/artifact-spec.md).
- Render the official dashboard template with `scripts/render-dashboard.sh`.

#### Phase 3: Establish the baseline

- Run the unmodified skill against the eval set.
- Score every run against every eval.
- Record experiment `0` as `baseline`.

#### Phase 4: Experiment loop

- Find the highest-value failure pattern.
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

- Tighten the `description` so it triggers on the right requests and avoids neighboring skills.
- Move repeated policy out of `SKILL.md` into a directly linked rule file.
- Add one missing validation check tied to a real failure.
- Replace vague examples with realistic positive, negative, and boundary prompts.
- Delete duplicated definitions across core and support files.

Avoid these mutation types:

- Rewriting the skill's purpose without evidence.
- Mixing unrelated trigger, workflow, and reference changes in one experiment.
- Adding scripts or assets without a reliability reason.
- Optimizing for a prompt pack that does not represent the target users.

</mutation_defaults>

<deliverables>

At exit, leave behind:

- The improved target skill changes.
- `.hypercore/autoresearch-skill/[skill-name]/dashboard.html`.
- `.hypercore/autoresearch-skill/[skill-name]/results.json`.
- `.hypercore/autoresearch-skill/[skill-name]/results.js` or an equivalent file-based bridge.
- `.hypercore/autoresearch-skill/[skill-name]/results.tsv`.
- `.hypercore/autoresearch-skill/[skill-name]/changelog.md`.
- `.hypercore/autoresearch-skill/[skill-name]/SKILL.md.baseline`.
- `.omx/specs/autoresearch-[skill-name]/result.json` completion artifact.
- `validation_mode` and `completion_artifact_path` bridge state in `.omx/state/.../autoresearch-state.json`.

Follow [references/artifact-spec.md](references/artifact-spec.md) for schemas and examples.

</deliverables>

<validation>

The run must satisfy:

- Positive, negative, and boundary trigger examples prove the intended trigger surface.
- Baseline-first, one-mutation-at-a-time, and explicit stop conditions are preserved.
- Support-file pointers are clear and no deeper than one level from `SKILL.md`.
- Scope, prompt pack, eval set, environment, and rollback conditions are recorded in artifacts.
- Dashboard and support documentation may be localized for readers, but data contracts remain stable.

</validation>
