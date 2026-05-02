# Validation and Exit

**Purpose**: Make code autoresearch completion evidence-based instead of wishful.

## 1. Validate Triggerability

Confirm that these are clearly distinguished:

- requests that should trigger autoresearch
- requests that should not trigger autoresearch
- boundary cases where direct editing is enough

Minimum criteria:

- at least 3 positive trigger examples
- at least 2 negative examples
- at least 1 boundary example
- at least 1 positive Korean-language example

## 2. Validate Skill Structure

Confirm that:

- reading only the core `SKILL.md` is enough to understand the task without opening every support file
- experiment policy lives in `rules/` and is not duplicated in the core document
- detailed artifact formats and the baseline guide live in `references/`
- support files are easy to find from the core
- the reference chain is no more than one level deep

## 3. Validate Eval Surface

Confirm that:

- every eval is binary
- evals do not overlap too much
- evals inspect what the user actually cares about
- at least one eval inspects the user's actual code bottleneck, not superficial formatting
- the selected eval pack is stated as matching the target domain or as the generic fallback

## 4. Validate Run Artifacts

Confirm that the workspace contains:

- `dashboard.html`
- `results.json`
- `results.tsv`
- `changelog.md`
- `baseline.md`

Expected location:

- `.hypercore/autoresearch-code/[codebase-name]/`

Also confirm that `results.json` and `results.tsv` describe the same score, pass rate, and keep/discard status.
Also confirm that the dashboard was rendered from the canonical template rather than hand-edited arbitrarily.
Also confirm that the artifact reproducibly records `scope`, `eval_pack`, `proof_commands`, `environment`, and rollback conditions.

If the workflow opens `dashboard.html` directly in a local browser, confirm that it renders real data rather than a blank screen in a `file://` environment.

## 5. Validate the `$autoresearch` Completion Artifact

When reporting a `$autoresearch`-based run, confirm that:

- `.omx/state/.../autoresearch-state.json` has `validation_mode: "mission-validator-script"`
- the same state has `completion_artifact_path` and `mission_validator_command`
- the JSON at `completion_artifact_path` exists and records `passed: true` or `status: "passed"`
- `output_artifact_path` points to `.hypercore/autoresearch-code/[codebase-name]/results.json`

If this artifact is missing, do not claim `$autoresearch` completion even if the score improved.

## 6. Validate the Final Claim

Do not claim success unless one of these is true:

- the final score is higher than the baseline
- the codebase became materially simpler with no regression, and that simplification is stated
- this run proved that the current codebase is already near the score ceiling and further mutation is not justified

## 7. Validate Promotion Stability

Before calling the winning experiment promotable, confirm that:

- volatile metrics still pass on repeated measurement
- rollback conditions were recorded before or during the keep experiment
- the experiment is explicitly marked as one of `hold`, `promote`, or `rollback`, not left implicit

## 8. Final Report Checklist

The final report must include:

- final score compared with baseline
- total experiment count
- keep ratio
- most effective change
- remaining failure patterns
- experiment artifact path

## 9. Recommended Check Commands

```bash
find skills/autoresearch-code -maxdepth 3 -type f | sort
wc -l skills/autoresearch-code/SKILL.md
rg -n "results.tsv|results.json|dashboard.html|changelog.md|baseline.md" skills/autoresearch-code/SKILL.md skills/autoresearch-code/references skills/autoresearch-code/rules
find .hypercore -maxdepth 2 -type f | sort | rg "autoresearch-code"
```
