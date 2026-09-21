# Agent Skills Standard References for Skill-Maker

## Contents

- Refresh Policy
- Agent Skills Specification
- Best Practices for Skill Creators
- Evaluating Skill Output Quality
- Optimizing Skill Descriptions
- Using Scripts in Skills
- Sources

The open standard every reviewed runtime builds on. This snapshot is the `PRIMARY` source for
frontmatter constraints and for the progressive-disclosure budgets; the provider snapshots next to it
record what each vendor adds on top.

## Refresh Policy

- last_verified_at: 2026-09-20
- refresh_when:
  - the specification changes a frontmatter constraint (name, description, compatibility, allowed-tools)
  - a progressive-disclosure budget changes (the listing-stage, instructions-stage, or line limits)
  - the reference validator (`skills-ref`) changes what it checks
  - the script-authoring page changes materially
- supports_rules:
  - `rules/skill-anatomy.md`
  - `rules/trigger-design.md`
  - `rules/progressive-disclosure.md`
  - `rules/resource-placement.md`
  - `rules/validation-and-iteration.md`

## Agent Skills Specification

- source_url: https://agentskills.io/specification
- last_verified_at: 2026-09-20
- applies_to: frontmatter fields and their constraints, directory conventions, progressive disclosure, file-reference depth, the reference validator
- summary: A skill is a directory containing at minimum `SKILL.md`, with YAML frontmatter followed by
  Markdown body content. `name` and `description` are required; `license`, `compatibility`, `metadata`,
  and `allowed-tools` are optional. The body has no format restrictions. `scripts/`, `references/`, and
  `assets/` are optional conventions, not requirements.
- implication_for_skill_maker: Enforce the required-field and constraint set exactly as stated below,
  and treat the optional directories as conventions this repository chose rather than as spec mandates.

### Frontmatter constraints as stated by the source

| Field | Required | Constraint |
|---|---|---|
| `name` | Yes | 1-64 characters. Lowercase letters, digits, and hyphens only. Must not start or end with a hyphen. Must not contain consecutive hyphens. **Must match the parent directory name** |
| `description` | Yes | 1-1024 characters. Non-empty. Describes both what the skill does and when to use it, and should carry the keywords an agent would match against |
| `license` | No | A license name or a reference to a bundled license file. Keep it short |
| `compatibility` | No | **1-500 characters if provided.** Only when the skill has environment requirements such as intended product, system packages, or network access |
| `metadata` | No | A map from string keys to string values. Keep keys unique to avoid collisions |
| `allowed-tools` | No | A space-separated string of pre-approved tools. **Experimental** - support varies between implementations |

- implication_for_skill_maker: `name` matching the parent directory is a spec requirement, not a
  stylistic preference, so the rule text must say **must** and the validator must enforce it.

### Progressive disclosure and file references

- Three stages: metadata (`name` + `description`, loaded for all skills at startup, about 100 tokens),
  then the full `SKILL.md` body when the skill activates (under 5,000 tokens recommended), then
  `scripts/`, `references/`, and `assets/` as needed.
- Keep the main `SKILL.md` under 500 lines; move detailed material to separate files.
- Reference other files by relative path from the skill root, and keep references **one level deep**
  from `SKILL.md`; avoid deeply nested reference chains.
- implication_for_skill_maker: the 500-line and 5,000-token figures are the source's; this repository
  additionally gates at 300 lines in `scripts/check-sources.sh`, which scopes to `instructions` only.
  Keep the two figures distinct rather than presenting 300 as sourced.

### Validation

- The source names a reference implementation, `skills-ref validate ./my-skill`, which checks that
  `SKILL.md` frontmatter is valid and follows the naming conventions.
- implication_for_skill_maker: this repository runs it through `uvx` from
  `scripts/validate-skills.sh`, which is network-dependent and is **not** part of
  `bun run --cwd scripts verify`; do not fold it into the offline gate silently.

## Best Practices for Skill Creators

- source_url: https://agentskills.io/skill-creation/best-practices
- last_verified_at: 2026-09-20
- applies_to: where a skill's content should come from, iterating against real execution, spending context wisely, description optimization, train/validation splits
- summary: Skills should be grounded in real expertise rather than generated from general knowledge:
  extract from a hands-on task, or synthesize from existing project artifacts (internal docs, runbooks,
  API specifications, code-review comments, version-control history, real failure cases). Refine by
  running the skill against real tasks and reading execution traces, not just final outputs. It states
  the 500-line and 5,000-token budgets and recommends about 20 trigger queries split roughly 60/40 into
  train and validation sets.
- implication_for_skill_maker: require a named source of domain expertise before drafting a skill, and
  require reading traces rather than outputs when a skill is refined.

## Evaluating Skill Output Quality

- source_url: https://agentskills.io/skill-creation/evaluating-skills
- last_verified_at: 2026-09-20
- applies_to: test-case design, the with-skill/without-skill pair, per-run timing and grading records, assertions
- summary: A test case is a prompt plus a human-readable expected output plus optional input files.
  The core pattern is to run each case twice - once with the skill and once without it, or against a
  previous version - so the result has a baseline. Grading records PASS or FAIL **with evidence that
  quotes or references the output**. Mechanical checks (valid JSON, row counts, file existence) belong
  in a script; reserve judgement for what a script cannot decide. Start with 2-3 cases and expand.
- implication_for_skill_maker: the paired run and the evidence string are the load-bearing parts; a
  `passed: true` with no evidence string is not a record.

## Optimizing Skill Descriptions

- source_url: https://agentskills.io/skill-creation/optimizing-descriptions
- last_verified_at: 2026-09-20
- applies_to: trigger rate as the metric, per-case runs and thresholds, train/validation selection, the description length limit
- summary: Trigger behaviour is probabilistic, so a case carries its own repetition count and threshold
  and the run records the resulting rate. Split the query set into train and validation, select by
  validation performance, and remember that the best iteration may not be the last one. Descriptions
  grow while being optimized, so re-check the length limit on every edit; when tuning stops helping,
  change the structure rather than adding adjectives.
- implication_for_skill_maker: a run that reports only its final score is not evidence of improvement;
  report the per-iteration train and validation numbers.

## Using Scripts in Skills

- source_url: https://agentskills.io/skill-creation/using-scripts
- last_verified_at: 2026-09-20
- applies_to: when a skill should bundle executable code rather than prose, and how that code should be documented
- summary: Executable code belongs in a skill when it provides deterministic behaviour, precise
  processing, or an external-tool integration that prose cannot guarantee. Scripts should be
  self-contained or document their dependencies, emit helpful errors, and handle edge cases; their code
  never enters the context window, only their output does.
- implication_for_skill_maker: a script is justified by determinism or an external integration, not by
  convenience, and its output is what the reviewer reads.

## Sources

> Links checked 2026-09-20. Next re-verification: 2026-10-29, matching the cadence in `instructions/README.md`.

| Claim | Source |
|---|---|
| The frontmatter field table and every constraint in it, the required/optional split, the directory conventions, the three-stage disclosure model, the 500-line guidance, and the one-level-deep file reference rule | <https://agentskills.io/specification> |
| Grounding a skill in real expertise, refining it against real execution and traces, the 5,000-token budget, and the ~20-query train/validation split | <https://agentskills.io/skill-creation/best-practices> |
| The test-case shape, the with-skill/without-skill pair, grading with an evidence string, and script-for-mechanical-checks | <https://agentskills.io/skill-creation/evaluating-skills> |
| Trigger rate, per-case runs and threshold, train/validation selection, and the description length re-check | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| When to bundle executable code and what its documentation must state | <https://agentskills.io/skill-creation/using-scripts> |
| The page inventory used to find the five pages above | <https://agentskills.io/llms.txt> |

### Evidence grade

`PRIMARY` - the specification page states the frontmatter constraints and the disclosure budgets
directly. **Correction recorded for the base:** `instructions/skill/references/skill-anatomy.md` §2 says
the `compatibility` lower bound of 1 "is not stated by any source consulted". The live specification page
checked 2026-09-20 states "Must be 1-500 characters if provided". That base note is now outdated; the
correction is recorded here rather than edited into `instructions/**`, which this plan keeps out of scope.
