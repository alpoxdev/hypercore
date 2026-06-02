# Evidence Reporting

**Purpose**: Make skill test results actionable, reproducible, and easy to hand off.

## Verdicts

- `pass`: required scenarios passed and no high-risk gaps remain.
- `pass-with-risks`: core behavior works, but medium/low risks or untested areas remain.
- `fail`: normal target requests fail, wrong requests activate, required resources are broken, or validation is missing.

## Finding format

Use this shape for each issue:

```markdown
- **[severity] [taxonomy] Title**
  - Evidence: `path:section` or command output summary.
  - Impact: why this can misroute or mis-execute the skill.
  - Minimal fix: smallest safe edit or handoff.
```

## Evidence standards

Strong evidence includes:

- metadata and trigger wording read directly from `SKILL.md`
- links declared in the skill and confirmed on disk
- scenario table with expected vs observed behavior
- deterministic script output
- command output for static checks

Weak evidence includes:

- "looks fine" without scenarios
- broad opinions without file references
- pass claims without checking linked resources

## Handoff rules

- Hand off to `skill-maker` for structural edits, trigger rewrites, or resource placement fixes.
- Hand off to `autoresearch-skill` when the user wants repeated benchmark experiments or score-driven mutation.
- Hand off to app QA skills when the target under test is an application, not a skill.

## Final report checklist

- State the target and verdict first.
- Show scenario results before recommendations.
- Classify failures using the skill's failure taxonomy.
- Name commands run and files inspected.
- Name untested areas explicitly instead of implying full coverage.
