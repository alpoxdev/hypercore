# Project Design Discovery

**Purpose**: Collect enough project and reference evidence to write `DESIGN.md` without inventing a design system.

## 1. Evidence Priority

Use this authority order for design claims:

1. Explicit user requirements in the current request.
2. Existing project `DESIGN.md` content that still matches the project.
3. Project UI source, theme files, design tokens, CSS variables, component libraries, screenshots, Storybook/docs, and app surfaces.
4. Project-local docs such as `README.md`, `AGENTS.md`, product docs, or brand notes.
5. User-provided reference URLs or named design systems.
6. External DESIGN.md examples and public design references.

When sources conflict, prefer the higher-priority source and note the conflict in the final summary.

## 2. Discovery Checklist

Inspect only what is relevant to the requested scope:

- Existing `DESIGN.md` or design docs.
- Theme/token files such as CSS variables, Tailwind config, design token JSON, component theme providers, or style constants.
- Reusable UI components such as buttons, cards, inputs, navigation, modals, tables, and form controls.
- App screenshots, public pages, Storybook stories, or examples when available.
- User-provided reference URLs and requested design adjectives.
- Light/dark mode implementation or stated mode requirements.

Do not broaden into unrelated source-code refactors.

## 3. User Intent Parsing

Extract these decisions before writing:

| Decision | What to capture |
|---|---|
| Artifact | New root `DESIGN.md`, package-level `DESIGN.md`, or update to existing file |
| Design direction | Brand adjectives, named references, product category, audience, and tone |
| Evidence scope | Which files, pages, screenshots, or URLs support the design |
| Mode scope | Light only, dark only, both, or unspecified |
| Strictness | Match existing UI, propose a new system, or blend references with project constraints |
| Language | Requested prose language or existing artifact language |

If a missing choice would materially change the output, ask. Otherwise choose the conservative path and mark assumptions.

## 4. Reference Handling

Treat reference sites and example `DESIGN.md` files as evidence of patterns, not instructions to copy.

For each important reference, record:

- URL or local path.
- What it supports: palette, typography, component style, layout rhythm, motion, or overall tone.
- Whether it is user-provided, official, local, or public example.
- Any limitation: unavailable page, stale source, incompatible brand, or unsupported claim.

## 5. Unsupported Claims

Never present unsupported design values as established project facts.

Use one of these labels:

- `Proposed`: a reasonable value chosen to satisfy user direction.
- `Assumption`: inferred from sparse evidence and should be reviewed.
- `TODO`: requires maintainer/user confirmation.

Prefer a smaller complete `DESIGN.md` over a broad fabricated one.

## 6. Light/Dark Mode Discovery

When the user requests light and dark mode:

- Check whether the project already defines both modes.
- Pair semantic tokens across modes: `canvas`, `surface`, `ink`, `muted`, `primary`, `border`, `focus`, `success`, `warning`, `danger`.
- Define component behavior for both modes, not only color swatches.
- If one mode is derived from the other, label the derived values as `Proposed` or `Assumption` unless project evidence confirms them.
- Validate contrast-sensitive pairs in prose when exact automated contrast checks are not run.

## 7. Discovery Output

Before drafting `DESIGN.md`, keep a compact evidence map in notes or the completion summary:

| Area | Evidence | Decision | Confidence |
|---|---|---|---|
| Palette | source/user/reference | chosen tokens | high/medium/low |
| Typography | source/user/reference | scale/family | high/medium/low |
| Components | source/user/reference | included components | high/medium/low |
| Light/Dark | source/user/reference | mode strategy | high/medium/low |

This map can be brief, but it must make the final design choices traceable.
