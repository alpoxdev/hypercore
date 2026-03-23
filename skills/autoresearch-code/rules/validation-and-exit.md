# Validation and Exit

**Purpose**: Make autoresearch completion evidence-based instead of aspirational.

## 1. Validate Triggerability

Check that the skill clearly distinguishes:

- requests that should trigger autoresearch
- requests that should not trigger it
- edge cases where direct editing is enough

Minimum bar:

- at least 3 positive trigger examples
- at least 2 negative trigger examples
- at least 1 boundary example

## 2. Validate the Skill Anatomy

Confirm:

- the core `SKILL.md` explains the job without loading every support file
- experiment policy lives in `rules/`, not duplicated in the core
- detailed artifact formats and baseline guidance live in `references/`
- support files are easy to discover from the core
- reference chains stay one level deep

## 3. Validate the Eval Surface

Confirm:

- evals are binary
- evals do not substantially overlap
- evals test things the user actually cares about
- at least one eval checks the user's real code bottleneck rather than superficial formatting

## 4. Validate the Run Artifacts

Confirm the workspace contains:

- `dashboard.html`
- `results.json`
- `results.tsv`
- `changelog.md`
- `baseline.md`

Expected location:

- `.hypercore/autoresearch-code/[codebase-name]/`

Also confirm `results.json` and `results.tsv` tell the same story about score, pass rate, and keep/discard status.
Also confirm the dashboard was rendered from the canonical template rather than hand-edited drift.

If the workflow opens `dashboard.html` directly in a local browser, also confirm the dashboard renders data under `file://` rather than showing an empty state because local JSON fetch is blocked.

## 5. Validate the Final Claim

Do not claim success unless one of these is true:

- the final score is higher than baseline
- the codebase is materially simpler with no regression and the simplification is called out explicitly
- the run proved the current codebase is already near the score ceiling and further mutation is unjustified

## 6. Final Report Checklist

The final report must include:

- baseline to final score
- total experiments
- keep rate
- top changes that helped most
- remaining failure patterns
- paths to the experiment artifacts

## 7. Suggested Checks

```bash
find skills/autoresearch-code -maxdepth 3 -type f | sort
wc -l skills/autoresearch-code/SKILL.md
rg -n "results.tsv|results.json|dashboard.html|changelog.md|baseline.md" skills/autoresearch-code/SKILL.md skills/autoresearch-code/references skills/autoresearch-code/rules
find .hypercore -maxdepth 2 -type f | sort | rg "autoresearch-code"
```
