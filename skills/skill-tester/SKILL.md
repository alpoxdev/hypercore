---
name: skill-tester
description: "[Hyper] Test Codex/agent skills for intended triggering and behavior with realistic positive, negative, boundary, and edge-case scenarios. Use when validating a skill folder, SKILL.md, rules/references/scripts/assets, trigger precision, workflow correctness, or regression coverage before shipping skill changes."
compatibility: Works best with read/search tools, shell commands, optional skill execution harnesses, and edit tools when fixing discovered issues.
---

@rules/test-matrix.md
@rules/scenario-design.md
@rules/evidence-reporting.md
@references/prompt-pack-template.md

# Skill Tester

> Prove a skill works as intended before trusting it.

<output_language>

Default all user-facing deliverables, saved artifacts, reports, plans, generated docs, summaries, handoff notes, commit/message drafts, and validation notes to Korean, even when this canonical skill file is written in English.

Preserve source code identifiers, CLI commands, file paths, schema keys, JSON/YAML field names, API names, package names, proper nouns, and quoted source excerpts in their required or original language.

Use a different language only when the user explicitly requests it, an existing target artifact must stay in another language for consistency, or a machine-readable contract requires exact English tokens. If a localized template or reference exists (for example `*.ko.md` or `*.ko.json`), prefer it for user-facing artifacts.

</output_language>

<purpose>

- Test whether a skill triggers on the right user requests and stays inactive on the wrong ones.
- Verify the skill's workflow, support-file routing, scripts/assets, and validation instructions against realistic usage.
- Expand coverage around edge cases, boundary prompts, ambiguity, missing inputs, malformed resources, and regression risks.

</purpose>

<routing_rule>

Use `skill-tester` when the user wants to test, validate, QA, regression-test, or edge-case-test an existing skill or skill folder.

Use `skill-maker` when the main job is creating or structurally refactoring a skill.
Use `autoresearch-skill` when the main job is repeated measured optimization across experiments.
Use `qa` or project-specific QA skills when the target is an application feature rather than a skill.

Do not use `skill-tester` when:

- there is no skill or skill draft to evaluate
- the user wants only generic documentation review
- the task is app/browser QA unrelated to skill behavior
- the user has already requested a full experiment loop with scoring and mutations

</routing_rule>

<trigger_conditions>

Positive examples:

- "Test `skills/git-maker/` and tell me whether it triggers correctly."
- "Verify whether this skill works as intended, including edge cases." (Korean-language requests with the same meaning should also trigger.)
- "Create a regression test pack for this skill's trigger and workflow behavior."
- "Validate the `SKILL.md`, rules, references, and scripts before I ship this skill."

Negative examples:

- "Create a new Codex skill for browser QA." Route to `skill-maker`.
- "Run QA on my web app checkout flow." Route to app QA, not this skill.
- "Optimize this skill through repeated benchmark experiments." Route to `autoresearch-skill`.

Boundary example:

- "Review this skill and fix any issues you find."
  Start with `skill-tester` if the emphasis is evidence and failures; switch to `skill-maker` only for structural edits after the test findings are clear.

</trigger_conditions>

<supported_targets>

- Skill folders containing `SKILL.md` and optional localized variants such as `SKILL.ko.md`.
- Skill metadata, trigger descriptions, routing rules, and examples.
- Directly linked `rules/`, `references/`, `scripts/`, and `assets/`.
- Trigger prompt packs, workflow simulations, validation checklists, and regression reports.
- Edge cases around ambiguity, missing inputs, conflicting instructions, unsupported targets, and resource drift.

</supported_targets>

<required_inputs>

Minimum input:

1. Target skill path or pasted skill content.
2. Intended job of the skill, if not obvious from metadata.

If either is missing, inspect local context first. Ask only when the target skill or intended behavior cannot be inferred safely.

Optional but useful:

- Known prompts that should trigger.
- Known prompts that should not trigger.
- Expected outputs or workflow checkpoints.
- Recent failures, regressions, or edge cases to reproduce.

</required_inputs>

<skill_architecture>

Load support files deliberately:

- Use [rules/test-matrix.md](rules/test-matrix.md) to choose what dimensions to test.
- Use [rules/scenario-design.md](rules/scenario-design.md) to write positive, negative, boundary, adversarial, and localization scenarios.
- Use [rules/evidence-reporting.md](rules/evidence-reporting.md) to report pass/fail evidence and next fixes.
- Use `scripts/validate-skill.mjs` for deterministic static checks when a filesystem skill folder is available.
- Use the localized sibling [references/prompt-pack-template.ko.md](references/prompt-pack-template.ko.md) by default for Korean prompt-pack artifacts; fall back to [references/prompt-pack-template.md](references/prompt-pack-template.md) only when the user requests English or exact English template text.

Keep test evidence close to the target skill when the user asks for reusable artifacts; otherwise report findings inline.

</skill_architecture>

<workflow>

| Phase | Task | Output |
|------|------|------|
| 0 | Identify target skill, intended behavior, and neighboring skills that might conflict | Test scope |
| 1 | Read `SKILL.md` and directly linked support files needed for the test | Baseline behavior map |
| 2 | Build a scenario matrix covering positive, negative, boundary, edge, and regression cases | Test matrix |
| 3 | Run static anatomy checks and inspect support-file references | Static findings |
| 4 | Simulate skill routing and workflow execution for each scenario | Pass/fail table |
| 5 | Classify failures by trigger, scope, resource placement, workflow, validation, or safety | Ranked defects |
| 6 | Recommend minimal fixes or hand off to `skill-maker`/`autoresearch-skill` when edits are needed | Evidence-backed report |

</workflow>

<test_requirements>

Every meaningful skill test should include at least:

- 3 positive trigger scenarios.
- 2 negative trigger scenarios.
- 2 boundary or ambiguous scenarios.
- 2 edge-case scenarios, such as missing inputs, malformed paths, unsupported language, conflicting instructions, or absent support files.
- 1 regression scenario for a known or likely failure.

For localized skills, include at least one scenario in each supported language when trigger behavior depends on language. In this repository, include at least one Korean positive or boundary request when testing skills that ship `SKILL.ko.md`.

</test_requirements>

<failure_taxonomy>

Classify each issue as one of:

- `trigger-miss`: target request may not activate the skill.
- `trigger-overreach`: unrelated request may activate the skill.
- `scope-conflict`: neighboring skill or workflow owns the request better.
- `workflow-gap`: instructions do not tell the agent what to do next.
- `resource-drift`: linked files are missing, stale, duplicated, or misplaced.
- `validation-gap`: completion can be claimed without evidence.
- `edge-case-gap`: missing handling for realistic boundary conditions.
- `safety-gap`: instructions allow risky or irreversible behavior without checks.

</failure_taxonomy>

<output_contract>

Default report format:

```markdown
## Skill Test Report

**Target**: `skills/example/`
**Intended behavior**: ...
**Verdict**: pass | pass-with-risks | fail

### Scenario results
| ID | Type | Prompt / condition | Expected | Observed | Result |
|----|------|--------------------|----------|----------|--------|

### Findings
1. [severity] [taxonomy] Evidence-backed issue and affected file/section.

### Edge cases covered
- ...

### Recommended fixes
- Minimal next edit or handoff target.

### Validation evidence
- Commands run, files read, and checks completed.
```

If the user asks for reusable tests, also create a prompt pack or checklist under the target skill's `references/` or a task-specific `.hypercore/` workspace.

</output_contract>

<validation_checklist>

Before declaring a skill tested, confirm:

- [ ] Target skill and directly linked resources were inspected.
- [ ] Intended behavior was inferred or supplied.
- [ ] Positive, negative, boundary, edge, and regression scenarios were covered.
- [ ] Trigger overlap with neighboring skills was considered.
- [ ] Static resource checks were run when a folder path exists.
- [ ] Failures were classified with evidence and minimal fix guidance.
- [ ] Remaining risks or untested areas were explicitly named.

</validation_checklist>
