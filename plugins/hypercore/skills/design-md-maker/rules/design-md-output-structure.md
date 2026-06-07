# DESIGN.md Output Structure

**Purpose**: Keep generated `DESIGN.md` files structured, implementable, and close to observed DESIGN.md practice without freezing every project into one template.

## 1. Required Shape

A `DESIGN.md` should contain:

1. YAML frontmatter with design tokens and component references.
2. Markdown explanation that tells agents how to apply the system.
3. Evidence or source notes when values are proposed, derived, or reference-inspired.

Use this as a rubric, not a static template. Adapt section names only when the project already uses a compatible structure.

## 2. Frontmatter Keys

Recommended minimum keys:

```yaml
---
version: alpha
name: project-design-system
description: "One-sentence visual system summary."
colors: {}
typography: {}
rounded: {}
spacing: {}
components: {}
---
```

Rules:

- Keep YAML parseable.
- Use stable lowercase token keys where possible.
- Prefer semantic names (`canvas`, `surface-1`, `ink`, `primary`, `border`) over one-off visual names.
- Components may reference tokens with `{colors.primary}`, `{typography.body}`, `{rounded.md}`, or equivalent existing project conventions.
- Do not include secrets, private credentials, or production-only URLs.

## 3. Light/Dark Token Models

When both modes are requested, choose one clear structure and use it consistently.

Preferred semantic grouping:

```yaml
colors:
  light:
    canvas: "#ffffff"
    surface-1: "#f7f7f8"
    ink: "#111111"
    primary: "#..."
  dark:
    canvas: "#0b0b0c"
    surface-1: "#151518"
    ink: "#f6f6f7"
    primary: "#..."
```

Acceptable alternative when the existing project uses flat tokens:

```yaml
colors:
  canvas-light: "#ffffff"
  canvas-dark: "#0b0b0c"
```

Required parity:

- Every core semantic color in one mode has a counterpart in the other mode.
- Component definitions explain mode-specific background, text, border, hover, focus, and disabled states when relevant.
- If one mode is only a proposal, label that in markdown.

## 4. Markdown Sections

Use these sections unless the existing `DESIGN.md` has a better compatible order:

1. `## Overview`
2. `## Design principles`
3. `## Colors`
4. `## Typography`
5. `## Layout and spacing`
6. `## Components`
7. `## Interaction states`
8. `## Motion`
9. `## Accessibility`
10. `## Implementation guidance`
11. `## Evidence and assumptions` when values are derived or references are used

Each section should guide implementation, not merely describe mood.

## 5. Component Guidance

For each important component, include:

- Purpose and when to use it.
- Token references for background, text, border, radius, spacing, and typography.
- Variants such as primary, secondary, destructive, ghost, compact, or featured.
- States such as default, hover, active, focus, disabled, loading, selected, and error when applicable.
- Light/dark differences when requested.

Common component candidates:

- `button-primary`, `button-secondary`, `button-ghost`
- `card`, `feature-card`, `pricing-card`, `surface-panel`
- `text-input`, `select`, `checkbox`, `form-field`
- `top-nav`, `sidebar`, `footer`
- `badge`, `status-pill`, `alert`, `modal`, `table-row`

Include only components relevant to the project or user request.

## 6. Typography Guidance

Define a usable hierarchy:

- display or hero style
- heading levels
- body and body-small
- caption or helper text
- button text
- mono/code style when relevant

For each style, include family, size, weight, line-height, and letter-spacing when known or proposed.

## 7. Layout, Interaction, Motion, Accessibility

Cover implementation-critical rules:

- Layout rhythm, max widths, grid behavior, section spacing, card density, and responsive behavior.
- Interaction states for focus, hover, active, disabled, loading, selected, and error.
- Motion principles, duration ranges, easing, and what should not animate.
- Accessibility constraints: contrast, focus visibility, text size, hit target, reduced motion, semantic color backup.

## 8. Evidence and Assumptions

End with a short trace when helpful:

| Claim | Evidence | Confidence |
|---|---|---|
| Primary color | user request / theme file / reference URL | high/medium/low |

Use `Proposed`, `Assumption`, or `TODO` for unsupported values.
