# Scenario Design

**Purpose**: Write realistic skill test cases that expose trigger, workflow, and edge-case failures.

## Scenario types

- `positive`: a request the target skill should own.
- `negative`: a request a neighboring skill or generic workflow should own instead.
- `boundary`: a plausible request near the edge of the skill's scope.
- `edge`: unusual but realistic conditions such as missing input, broken paths, unsupported language, conflicting constraints, or absent tools.
- `regression`: a known or likely failure from previous changes, similar skills, or current weak wording.

## Good scenario prompts

A good prompt is written like a real user would write it, not like a test label.

Prefer:

```text
$skill-maker Create a skill for testing browser automation prompts, with edge cases.
```

Avoid:

```text
Positive trigger for skill creation.
```

## Expected-observed format

Each scenario should define:

1. Prompt or condition.
2. Expected routing or workflow behavior.
3. Observed behavior from inspection, simulation, or an actual run.
4. Result: `pass`, `fail`, or `risk`.
5. Evidence: file, line, command output, or reasoning summary.

## Edge-case prompts to consider

- Missing target path: "Test this skill" with no attachment or path.
- Malformed path: target directory exists but `SKILL.md` is missing.
- Conflicting intent: "Test this skill and rewrite it completely."
- Localization: Korean or another supported language asks for the same behavior.
- Neighbor overlap: request could match skill creation, skill testing, or skill optimization.
- Resource failure: `@rules/foo.md` is linked but absent.
- Validation gap: workflow says to report success without command or readback evidence.

## Localization

If a skill has localized metadata or examples, include scenarios in those languages. Do not assume English-only trigger behavior when the repository supports translated `SKILL.*.md` files.
