---
name: autoresearch-skill
description: "Refactor and optimize an existing Codex skill with baseline-first experiments, binary evals, targeted prompt mutations, and keep/discard scoring. Use when: improve this skill, run autoresearch on a skill, benchmark a skill, self-optimize a skill, or add eval-driven rigor to a skill refactor."
compatibility: Works best with read/edit/write and shell search tools for skill inspection, repeated evaluation, and artifact logging.
---

@rules/experiment-loop.md
@rules/validation-and-exit.md

# Autoresearch for Skills

> Improve an existing skill with measured iterations instead of one-shot rewrites.

<purpose>

- Optimize an existing skill by establishing a baseline, scoring outputs with binary evals, and keeping only changes that improve the score.
- Strengthen weak skill structure when failures come from vague triggers, bloated core instructions, missing support files, or poor validation.
- Produce an improved skill plus durable experiment artifacts under `.hypercore/autoresearch-[skill-name]/`: `results.tsv`, `results.json`, `changelog.md`, `dashboard.html`, and `SKILL.md.baseline`.

</purpose>

<routing_rule>

Use `autoresearch-skill` when the user wants repeated, eval-driven optimization of an existing skill.

Use `skill-maker` instead when the main job is creating a new skill or doing a one-pass structural refactor without an experiment loop.

Do not use `autoresearch-skill` when:

- there is no existing target skill to optimize
- the user wants generic documentation rather than a skill improvement workflow
- the user only wants a single manual edit with no baseline, no evals, and no repeated scoring

</routing_rule>

<trigger_conditions>

Positive examples:

- "Run autoresearch on `skills/web-clone/SKILL.md`."
- "Benchmark this skill with binary evals and keep only improvements."
- "Improve this skill's prompt and references using repeated experiments."

Negative examples:

- "Create a new Codex skill for browser QA."
- "Rewrite this runbook for readability."

Boundary example:

- "Tighten this skill once and review it." Prefer direct editing unless the user explicitly wants repeated eval-driven optimization.

</trigger_conditions>

<supported_targets>

- Existing skill folders, especially `SKILL.md` plus related `rules/` and `references/`
- Trigger wording, workflow clarity, output discipline, and validation guidance
- Skill-structure refactors that materially improve measured results
- Experiment artifacts that let future agents continue the optimization

</supported_targets>

<required_inputs>

Collect these before the first mutation:

1. Target skill path
2. Three to five test prompts or scenarios
3. Three to six binary evals
4. Runs per experiment. Default: `5`
5. Run interval if the loop is time-based. Default: `2 minutes`
6. Optional budget cap

Input policy:

- If the user already gave the core intent and the work is low-risk, infer conservative defaults and record them before the baseline.
- Ask for clarification only when missing information would make the eval meaningless or push the skill toward the wrong behavior.
- Do not start mutating the target skill before the baseline plan is explicit.

</required_inputs>

<skill_architecture>

Keep the core skill focused on trigger, owned job, workflow, and mutation discipline.

Load support files intentionally:

- Use [references/eval-guide.md](references/eval-guide.md) to design binary evals.
- Use [references/skill-refactor-guide.md](references/skill-refactor-guide.md) when failures point to bad skill anatomy, weak support files, or poor trigger wording.
- Use [references/artifact-spec.md](references/artifact-spec.md) for dashboard, results, changelog, and workspace schemas.

When the target skill itself is weakly structured:

- keep the core `SKILL.md` lean
- move repeated policy into `rules/`
- move detailed knowledge and examples into `references/`
- add `scripts/` only when deterministic execution is clearly better than prose

</skill_architecture>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Read the target skill and linked support files | Baseline understanding |
| 1 | Convert success criteria into binary evals | Eval suite |
| 2 | Initialize the experiment workspace and artifacts | `.hypercore/autoresearch-[skill-name]/` |
| 3 | Run experiment `0` on the unmodified skill | Baseline score |
| 4 | Run one-mutation-at-a-time experiments | Keep/discard decisions |
| 5 | Validate the final result and summarize the run | Final report |

### Phase details

#### Phase 0: Understand the target

- Read the full target `SKILL.md`.
- Read any directly linked `rules/` and `references/`.
- Identify whether failures are behavioral, structural, or both.

#### Phase 1: Build the eval suite

- Translate success criteria into binary pass/fail checks.
- Keep evals distinct, observable, and hard to game.
- If the target is a skill, include at least one eval that checks trigger or structure quality, not just prose style.

#### Phase 2: Prepare the workspace

- Create `.hypercore/autoresearch-[skill-name]/` at the repository root.
- Back up the original file as `SKILL.md.baseline`.
- Initialize `results.tsv`, `results.json`, `changelog.md`, and `dashboard.html` using [references/artifact-spec.md](references/artifact-spec.md).

#### Phase 3: Establish the baseline

- Run the current skill before editing anything.
- Score every run against every eval.
- Record experiment `0` as `baseline`.

#### Phase 4: Run the experiment loop

- Inspect failing outputs and identify the highest-value failure pattern.
- Form one hypothesis.
- Make one targeted mutation.
- Re-run the same eval suite.
- Keep score-improving mutations. Revert flat or worse mutations.
- Log every experiment, including discarded ones.

#### Phase 5: Finish and deliver

- Stop on user instruction, budget cap, or stable high performance per [rules/validation-and-exit.md](rules/validation-and-exit.md).
- Report score delta, total experiments, keep rate, strongest changes, and remaining failure patterns.

</workflow>

<mutation_defaults>

Prefer these mutation types:

- clarify an ambiguous instruction
- add a narrow anti-pattern for a recurring failure
- move an important instruction earlier in the skill
- add or improve one worked example
- remove prompt weight that adds complexity without score gain
- refactor support-file placement when the core is carrying too much detail

Avoid these mutation types:

- rewriting the entire skill from scratch
- making many unrelated changes in one experiment
- adding large blocks of prose without a measured reason
- optimizing for a brittle format rule that does not reflect real quality

</mutation_defaults>

<deliverables>

The completed run should leave:

- the improved target skill in place
- `.hypercore/autoresearch-[skill-name]/dashboard.html`
- `.hypercore/autoresearch-[skill-name]/results.json`
- `.hypercore/autoresearch-[skill-name]/results.tsv`
- `.hypercore/autoresearch-[skill-name]/changelog.md`
- `.hypercore/autoresearch-[skill-name]/SKILL.md.baseline`

See [references/artifact-spec.md](references/artifact-spec.md) for file schemas and examples.

</deliverables>

<validation>

Minimum checks before declaring success:

- a baseline exists before mutations
- evals are binary and non-overlapping
- every mutation is logged as keep or discard
- the final score improved, or the skill was explicitly simplified with no regression
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
