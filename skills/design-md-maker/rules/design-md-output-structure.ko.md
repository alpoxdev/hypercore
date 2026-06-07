# DESIGN.md Output Structure

**Purpose**: 생성되는 `DESIGN.md`가 구조적이고 구현 가능하며, 모든 프로젝트를 하나의 고정 template로 얼리지 않으면서 관찰된 DESIGN.md 관행과 가깝게 유지합니다.

## 1. Required Shape

`DESIGN.md`에는 다음이 있어야 합니다.

1. design token과 component reference를 담은 YAML frontmatter.
2. agent가 system을 어떻게 적용할지 알려주는 Markdown explanation.
3. 값이 proposed, derived, reference-inspired인 경우 evidence 또는 source notes.

이 문서는 static template이 아니라 rubric입니다. 기존 프로젝트가 호환되는 구조를 이미 사용하면 section name을 조정할 수 있습니다.

## 2. Frontmatter Keys

권장 최소 key:

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

- YAML은 parseable하게 유지합니다.
- 가능한 경우 stable lowercase token key를 사용합니다.
- 일회성 visual name보다 semantic name(`canvas`, `surface-1`, `ink`, `primary`, `border`)을 선호합니다.
- Component는 `{colors.primary}`, `{typography.body}`, `{rounded.md}` 또는 기존 project convention과 같은 token reference를 사용할 수 있습니다.
- secrets, private credentials, production-only URLs를 포함하지 않습니다.

## 3. Light/Dark Token Models

두 mode가 요청되면 하나의 명확한 구조를 선택하고 일관되게 사용합니다.

권장 semantic grouping:

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

기존 프로젝트가 flat token을 쓰는 경우 허용되는 대안:

```yaml
colors:
  canvas-light: "#ffffff"
  canvas-dark: "#0b0b0c"
```

필수 parity:

- 한 mode의 모든 core semantic color에는 다른 mode counterpart가 있습니다.
- Component definition은 관련될 때 mode-specific background, text, border, hover, focus, disabled state를 설명합니다.
- 한 mode가 proposal일 뿐이라면 markdown에서 이를 label합니다.

## 4. Markdown Sections

기존 `DESIGN.md`에 더 좋은 호환 순서가 없으면 다음 section을 사용합니다.

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
11. 값이 derived이거나 reference가 사용되면 `## Evidence and assumptions`

각 section은 분위기만 설명하지 말고 implementation을 guide해야 합니다.

## 5. Component Guidance

중요 component마다 다음을 포함합니다.

- 목적과 사용 시점.
- background, text, border, radius, spacing, typography token reference.
- primary, secondary, destructive, ghost, compact, featured 같은 variants.
- 적용 가능한 default, hover, active, focus, disabled, loading, selected, error states.
- 요청된 경우 light/dark differences.

일반 component 후보:

- `button-primary`, `button-secondary`, `button-ghost`
- `card`, `feature-card`, `pricing-card`, `surface-panel`
- `text-input`, `select`, `checkbox`, `form-field`
- `top-nav`, `sidebar`, `footer`
- `badge`, `status-pill`, `alert`, `modal`, `table-row`

프로젝트 또는 사용자 요청과 관련 있는 component만 포함합니다.

## 6. Typography Guidance

사용 가능한 hierarchy를 정의합니다.

- display 또는 hero style
- heading levels
- body와 body-small
- caption 또는 helper text
- button text
- 관련 있는 경우 mono/code style

각 style에는 알려졌거나 proposed인 family, size, weight, line-height, letter-spacing을 포함합니다.

## 7. Layout, Interaction, Motion, Accessibility

implementation-critical rule을 다룹니다.

- Layout rhythm, max widths, grid behavior, section spacing, card density, responsive behavior.
- Focus, hover, active, disabled, loading, selected, error interaction states.
- Motion principles, duration ranges, easing, animate하지 말아야 할 것.
- Accessibility constraints: contrast, focus visibility, text size, hit target, reduced motion, semantic color backup.

## 8. Evidence and Assumptions

도움이 될 때 짧은 trace로 끝냅니다.

| Claim | Evidence | Confidence |
|---|---|---|
| Primary color | user request / theme file / reference URL | high/medium/low |

Unsupported value에는 `Proposed`, `Assumption`, 또는 `TODO`를 사용합니다.
