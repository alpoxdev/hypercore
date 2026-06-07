# Validation

**Purpose**: 스킬이 올바르게 trigger되었고 생성된 `DESIGN.md`가 구조적이며, evidence-backed이고, AI UI generation에 유용함을 증명합니다.

## 1. Trigger Validation

이 스킬 자체에는 최소 다음 smoke set을 유지합니다.

| id | Prompt | Expected |
|---|---|---|
| p1 | "Create a DESIGN.md for this project from the current UI." | trigger |
| p2 | "Generate DESIGN.md with light and dark mode tokens." | trigger |
| p3 | "이 레퍼런스 기반으로 우리 앱 DESIGN.md 만들어줘." | trigger |
| n1 | "Create a README.md." | no trigger |
| n2 | "Implement dark mode components." | no trigger |
| n3 | "Make a reusable skill folder for DESIGN.md generation." | no trigger; `skill-maker` 사용 |
| b1 | "Document our design system." | artifact가 `DESIGN.md`일 때만 trigger |

## 2. Project Discovery Checks

`DESIGN.md` 작성 또는 갱신 전에 다음을 확인합니다.

- 요청된 artifact path를 알고 있거나 conservative하게 선택했습니다.
- 기존 `DESIGN.md`가 있으면 읽었습니다.
- 가능한 경우 관련 UI/theme/token/component files를 조사했습니다.
- 사용자 제공 URL 또는 예시는 evidence로만 취급했습니다.
- 누락되거나 추론된 값은 `Proposed`, `Assumption`, 또는 `TODO`로 표시했습니다.

## 3. DESIGN.md Shape Checks

기존 호환 구조가 예외를 정당화하지 않는 한 output frontmatter에는 다음 key가 있어야 합니다.

- `version`
- `name`
- `description`
- `colors`
- `typography`
- `rounded`
- `spacing`
- `components`

Markdown body에는 다음 section 또는 정당화된 equivalent가 있어야 합니다.

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
- reference, derived values, TODO가 있으면 `Evidence and assumptions`

## 4. Token Reference Checks

Component definition의 모든 token reference를 확인합니다.

- `{colors.*}`는 정의된 color token을 가리킵니다.
- `{typography.*}`는 정의된 typography token을 가리킵니다.
- `{rounded.*}`는 정의된 radius token을 가리킵니다.
- `{spacing.*}`는 사용된 경우 정의된 spacing token을 가리킵니다.
- light surface에 light text를 쓰는 것처럼 mode-specific token이 실수로 섞이지 않았습니다.

정확한 parsing이 실용적이지 않으면 manual readback을 수행하고 automated parser를 실행하지 않았다고 명시합니다.

## 5. Light/Dark Parity Checks

두 mode가 요청되면 다음을 확인합니다.

- core semantic colors가 두 mode 모두 존재합니다.
- primary components가 light와 dark behavior를 모두 설명합니다.
- 관련되는 hover, focus, disabled, selected, error states가 pair되어 있습니다.
- derived mode values는 project evidence가 확인하지 않는 한 proposed 또는 assumed로 label됩니다.
- Accessibility notes가 contrast, focus visibility, reduced motion을 언급합니다.

## 6. Evidence Mapping Checks

명백하지 않은 visual claim마다 최소 하나의 source를 확인합니다.

| Claim type | Acceptable evidence |
|---|---|
| Brand color | user request, theme token, CSS variable, existing `DESIGN.md`, caveat가 있는 screenshot/reference |
| Typography | CSS/font config, existing UI docs, user request, caveat가 있는 reference |
| Component behavior | source component, Storybook/example, existing docs, user request |
| Layout rhythm | source layout, screenshot, existing docs, user request |
| Motion | source animation, component docs, user request, 또는 explicitly proposed default |

## 7. Forward Test Scenario

새 `DESIGN.md`를 완료하거나 구조를 크게 갱신하기 전에 작은 mental 또는 written forward test를 실행합니다.

| Scenario | Expected proof |
|---|---|
| `Generate a compact DESIGN.md for a SaaS dashboard with light and dark mode.` | required frontmatter, paired `colors.light`/`colors.dark` tokens, 두 mode component variants, proposed value에 대한 `Evidence and assumptions` label이 있습니다. |
| `Update this existing DESIGN.md to match current button and card components.` | 정확한 기존 section은 보존되고, stale component rule은 project evidence로 교체되며, unsupported value는 TODO로 표시됩니다. |

작업이 `DESIGN.md` 구조 또는 mode behavior를 실질적으로 바꾸면 최종 summary에 Forward test 결과를 기록합니다.
## 8. Skill File Checks

이 스킬을 생성하거나 변경할 때 다음을 확인합니다.

- `SKILL.md`와 `SKILL.ko.md`가 모두 존재하고 section order가 정렬되어 있습니다.
- 모든 material markdown file에는 `.ko.md` sibling이 있습니다.
- `SKILL.md`는 deep reference chain 없이 support file을 직접 link합니다.
- documented purpose 없이 `assets/`, `scripts/`, `agents/` directory를 추가하지 않았습니다.
- 이 repo가 plugin mirror를 배포하면 plugin mirror files가 root skill files와 일치합니다.

## 9. Completion Summary

최종 사용자-facing summary는 한국어로 작성하고 다음을 포함합니다.

- 대상 `DESIGN.md` path.
- 조사한 evidence sources.
- light/dark mode가 generated, preserved, 또는 not requested인지.
- 통과한 validation checks.
- 남은 assumptions, TODOs, caveats.
