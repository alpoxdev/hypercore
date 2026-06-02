# Prompt Pack Template

**Purpose**: Provide a reusable regression-test artifact shape for skill trigger and workflow testing.

Use this reference when the user asks to create a reusable prompt pack, regression test pack, or checklist for a target skill.

## File placement

Prefer one of these locations:

- `skills/<target-skill>/references/skill-test-pack.md` when the pack should travel with the skill.
- `.hypercore/skill-tester/<target-skill>/prompt-pack.md` when the pack is run-specific evidence.

Do not bury prompt packs deeper than one directory from the target skill's `SKILL.md` unless the repository already has a stronger convention.

## Required sections

```markdown
# [Target Skill] Skill Test Pack

## Target behavior
- Skill path: `skills/example/`
- Intended job: ...
- Neighbor skills to avoid: ...

## Scenario matrix
| ID | Type | Prompt / condition | Expected routing | Expected workflow checkpoint |
|----|------|--------------------|------------------|------------------------------|
| P1 | positive | ... | target skill activates | ... |
| N1 | negative | ... | route away to ... | ... |
| B1 | boundary | ... | conditional / handoff | ... |
| E1 | edge | ... | safe fallback | ... |
| R1 | regression | ... | previous failure stays fixed | ... |

## Expected-observed results
| ID | Expected | Observed | Result | Evidence |
|----|----------|----------|--------|----------|

## Binary evals
```text
EVAL 1: Trigger boundary
Question: ...?
Pass: ...
Fail: ...
```

## Untested risks
- ...
```

## Minimum coverage

- `positive`: at least 3 realistic target requests.
- `negative`: at least 2 requests owned by neighboring skills.
- `boundary`: at least 2 ambiguous or mixed-intent requests.
- `edge`: at least 2 unusual but realistic conditions.
- `regression`: at least 1 known or likely failure.

## Scenario writing rules

- Write prompts in real user language, including Korean when the target skill ships `SKILL.ko.md` or users are Korean.
- Keep expected behavior observable: route, next file read, workflow phase, command, or report field.
- Do not score with vague criteria such as "good" or "clear"; convert them to binary evals.
- Link every failure to the smallest likely fix or handoff target.
