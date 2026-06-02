# Validation and Exit

**Purpose**: Make code autoresearch completion evidence-based instead of wishful, and make the code/score movement visible in Korean artifacts.

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
- detailed artifact formats, reporting templates, eval design, and the baseline guide live in `references/`
- support files are easy to find from the core
- the reference chain is no more than one level deep

## 3. Validate Eval Surface

Confirm that:

- every eval is binary
- evals do not overlap too much
- evals inspect what the user actually cares about
- at least one eval inspects the user's actual code bottleneck, not superficial formatting
- the selected eval pack is stated as matching the target domain or as the generic fallback
- guard checks are separate from scoring evals and cannot be ignored just because the score rose

## 4. Validate Run Artifacts

Confirm that the workspace contains:

- `dashboard.html`
- `results.json`
- `results.js`
- `results.tsv`
- `changelog.md`
- `baseline.md`
- `code-explanation.md` or `results.json.code_explanation` for completed runs
- `final-report.md` for completed runs
- `run-contract.md` when assumptions/defaults were inferred
- `trace-summary.md` when trace-backed evals or runtime traces were used
- `source-ledger.md` when external/current claims influenced code choices
- `details/` when long logs or proof snippets would otherwise bloat top-level files

Expected location:

- `.hypercore/autoresearch-code/[codebase-name]/`

Also confirm that `results.json` and `results.tsv` describe the same score, pass rate, and keep/discard/reset status.
Also confirm that the dashboard was rendered from the canonical template rather than hand-edited arbitrarily.
Also confirm that the artifact reproducibly records `scope`, `eval_pack`, `proof_commands`, `environment`, rollback conditions, changed files, proof results, and guard results.

If the workflow opens `dashboard.html` directly in a local browser, confirm that it renders real data and Markdown detail logs rather than a blank screen in a `file://` environment.

## 5. Validate the `$autoresearch` Completion Artifact

When reporting a `$autoresearch`-based run, confirm that:

- `.omx/state/.../autoresearch-state.json` has `validation_mode: "mission-validator-script"`
- the same state has `completion_artifact_path` and `mission_validator_command`
- the JSON at `completion_artifact_path` exists and records `passed: true` or `status: "passed"`
- `output_artifact_path` points to `.hypercore/autoresearch-code/[codebase-name]/results.json`

If this artifact is missing, do not claim `$autoresearch` completion even if the score improved.

## 6. Validate Code Improvement Claim

Do not claim success unless one of these is true:

- the final score is higher than the baseline and all required guards passed
- the codebase became materially simpler with no regression, and that simplification is stated with proof-command evidence
- this run proved that the current codebase is already near the score ceiling and further mutation is not justified

For any positive claim, the final report must show:

- where the score changed by metric/eval/category
- before/after values or pass counts
- changed files
- why each kept change was retained
- proof commands and guard results
- rollback or promotion state
- remaining failures or explicit “없음”

## 7. Validate Promotion Stability

Before calling the winning experiment promotable, confirm that:

- volatile metrics still pass on repeated measurement
- rollback conditions were recorded before or during the keep experiment
- every required guard passed after the winning change
- the experiment is explicitly marked as one of `hold`, `promote`, or `rollback`, not left implicit

A score increase with a guard failure is not promotable. Mark it `discard`, `rollback`, or `keep-reworked` only after the guard issue is fixed and revalidated.

## 8. Final Report Checklist

The final report must include, in Korean:

- final score compared with baseline
- exact score/pass-rate delta
- total experiment count
- keep ratio
- most effective change
- metric/eval/category where the score rose
- changed files and why each was kept
- proof command results
- guard results
- promotion/rollback state
- remaining failure patterns
- experiment artifact path
- dashboard path
- `.omx/specs/.../result.json` completion artifact path when `$autoresearch` is used

## 9. Recommended Check Commands

```bash
find skills/autoresearch-code -maxdepth 3 -type f | sort
wc -l skills/autoresearch-code/SKILL.md
rg -n "results.tsv|results.json|results.js|dashboard.html|changelog.md|baseline.md|code-explanation.md|final-report.md|run-contract.md|trace-summary.md|source-ledger.md" skills/autoresearch-code/SKILL.md skills/autoresearch-code/references skills/autoresearch-code/rules
bash -n skills/autoresearch-code/scripts/render-dashboard.sh
find .hypercore -maxdepth 3 -type f | sort | rg "autoresearch-code"
```
