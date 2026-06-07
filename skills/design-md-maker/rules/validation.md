# Validation

**Purpose**: Prove that the skill triggered correctly and the generated `DESIGN.md` is structured, evidence-backed, and useful for AI UI generation.

## 1. Trigger Validation

For this skill itself, keep at least this smoke set:

| id | Prompt | Expected |
|---|---|---|
| p1 | "Create a DESIGN.md for this project from the current UI." | trigger |
| p2 | "Generate DESIGN.md with light and dark mode tokens." | trigger |
| p3 | "이 레퍼런스 기반으로 우리 앱 DESIGN.md 만들어줘." | trigger |
| n1 | "Create a README.md." | no trigger |
| n2 | "Implement dark mode components." | no trigger |
| n3 | "Make a reusable skill folder for DESIGN.md generation." | no trigger; use `skill-maker` |
| b1 | "Document our design system." | trigger only when the artifact is `DESIGN.md` |

## 2. Project Discovery Checks

Before writing or updating `DESIGN.md`, confirm:

- The requested artifact path is known or conservatively chosen.
- Existing `DESIGN.md` was read when present.
- Relevant UI/theme/token/component files were inspected when available.
- User-provided URLs or examples were treated as evidence only.
- Missing or inferred values are marked as `Proposed`, `Assumption`, or `TODO`.

## 3. DESIGN.md Shape Checks

The output should include frontmatter with these keys unless an existing compatible structure justifies a deviation:

- `version`
- `name`
- `description`
- `colors`
- `typography`
- `rounded`
- `spacing`
- `components`

The markdown body should include these sections or justified equivalents:

- `Overview`
- `Design principles`
- `Colors`
- `Typography`
- `Layout and spacing`
- `Components`
- `Interaction states`
- `Motion`
- `Accessibility`
- `Implementation guidance`
- `Evidence and assumptions` when references, derived values, or TODOs exist

## 4. Token Reference Checks

Check all token references in component definitions:

- `{colors.*}` points to a defined color token.
- `{typography.*}` points to a defined typography token.
- `{rounded.*}` points to a defined radius token.
- `{spacing.*}` points to a defined spacing token when used.
- Mode-specific tokens are not mixed accidentally, such as using light text on a light surface.

If exact parsing is not practical, do a manual readback and state that no automated parser was run.

## 5. Light/Dark Parity Checks

When both modes are requested:

- Core semantic colors exist for both modes.
- Primary components describe both light and dark behavior.
- Hover, focus, disabled, selected, and error states are paired where relevant.
- Derived mode values are labeled as proposed or assumed unless project evidence confirms them.
- Accessibility notes mention contrast, focus visibility, and reduced motion.

## 6. Evidence Mapping Checks

For every non-obvious visual claim, verify at least one source:

| Claim type | Acceptable evidence |
|---|---|
| Brand color | user request, theme token, CSS variable, existing `DESIGN.md`, screenshot/reference with caveat |
| Typography | CSS/font config, existing UI docs, user request, reference with caveat |
| Component behavior | source component, Storybook/example, existing docs, user request |
| Layout rhythm | source layout, screenshot, existing docs, user request |
| Motion | source animation, component docs, user request, or explicitly proposed default |

## 7. Forward Test Scenario

Before declaring a new or substantially updated `DESIGN.md` complete, run a small mental or written forward test:

| Scenario | Expected proof |
|---|---|
| `Generate a compact DESIGN.md for a SaaS dashboard with light and dark mode.` | The output has required frontmatter, paired `colors.light`/`colors.dark` tokens, component variants for both modes, and `Evidence and assumptions` labels for proposed values. |
| `Update this existing DESIGN.md to match current button and card components.` | Correct existing sections are preserved, stale component rules are replaced from project evidence, and unsupported values are marked as TODO. |

Record the Forward test result in the final summary when the task materially changes `DESIGN.md` structure or mode behavior.
## 8. Skill File Checks

When this skill is created or changed, confirm:

- `SKILL.md` and `SKILL.ko.md` both exist and have aligned section order.
- Every material markdown file has a `.ko.md` sibling.
- `SKILL.md` links directly to support files with no deep reference chain.
- No `assets/`, `scripts/`, or `agents/` directory is added without documented purpose.
- Plugin mirror files match root skill files when this repo publishes plugin mirrors.

## 9. Completion Summary

Final user-facing summary should be Korean and include:

- Target `DESIGN.md` path.
- Evidence sources inspected.
- Whether light/dark mode was generated, preserved, or not requested.
- Validation checks passed.
- Remaining assumptions, TODOs, or caveats.
