# Project Design Discovery

**Purpose**: 디자인 시스템을 날조하지 않고 `DESIGN.md`를 쓸 수 있도록 충분한 프로젝트 및 레퍼런스 근거를 수집합니다.

## 1. Evidence Priority

디자인 claim에는 다음 authority 순서를 사용합니다.

1. 현재 요청의 명시적 사용자 요구.
2. 프로젝트와 여전히 일치하는 기존 `DESIGN.md` 내용.
3. 프로젝트 UI source, theme file, design token, CSS variable, component library, screenshot, Storybook/docs, app surface.
4. `README.md`, `AGENTS.md`, product docs, brand notes 같은 프로젝트 로컬 문서.
5. 사용자가 제공한 reference URL 또는 named design system.
6. 외부 DESIGN.md 예시와 public design reference.

source가 충돌하면 더 높은 priority source를 우선하고 final summary에 conflict를 기록합니다.

## 2. Discovery Checklist

요청 범위와 관련 있는 항목만 조사합니다.

- 기존 `DESIGN.md` 또는 design docs.
- CSS variables, Tailwind config, design token JSON, component theme provider, style constants 같은 theme/token files.
- buttons, cards, inputs, navigation, modals, tables, form controls 같은 reusable UI components.
- 가능한 경우 app screenshot, public pages, Storybook stories, examples.
- 사용자 제공 reference URLs와 요청된 design adjectives.
- light/dark mode 구현 또는 명시된 mode requirements.

무관한 source-code refactor로 범위를 넓히지 않습니다.

## 3. User Intent Parsing

작성 전에 다음 결정을 추출합니다.

| Decision | What to capture |
|---|---|
| Artifact | 새 root `DESIGN.md`, package-level `DESIGN.md`, 또는 existing file update |
| Design direction | brand adjectives, named references, product category, audience, tone |
| Evidence scope | design을 뒷받침하는 files, pages, screenshots, URLs |
| Mode scope | light only, dark only, both, 또는 unspecified |
| Strictness | existing UI match, new system proposal, 또는 references와 project constraints blend |
| Language | 요청된 prose language 또는 existing artifact language |

누락된 선택이 산출물을 크게 바꾸면 질문합니다. 그렇지 않으면 conservative path를 선택하고 assumptions를 표시합니다.

## 4. Reference Handling

reference site와 예시 `DESIGN.md`는 copy할 instruction이 아니라 pattern evidence로 취급합니다.

중요한 reference마다 다음을 기록합니다.

- URL 또는 local path.
- 무엇을 뒷받침하는지: palette, typography, component style, layout rhythm, motion, overall tone.
- user-provided, official, local, public example 중 무엇인지.
- limitation: unavailable page, stale source, incompatible brand, unsupported claim.

## 5. Unsupported Claims

근거 없는 design value를 established project fact처럼 쓰지 않습니다.

다음 label 중 하나를 사용합니다.

- `Proposed`: 사용자 방향을 만족하기 위해 선택한 합리적 값.
- `Assumption`: 부족한 근거에서 추론했으며 review가 필요한 값.
- `TODO`: maintainer/user confirmation 필요.

넓지만 날조된 `DESIGN.md`보다 작아도 완결된 `DESIGN.md`를 선호합니다.

## 6. Light/Dark Mode Discovery

사용자가 light/dark mode를 요청하면 다음을 수행합니다.

- 프로젝트가 이미 두 mode를 정의하는지 확인합니다.
- semantic token을 mode 간에 pair합니다: `canvas`, `surface`, `ink`, `muted`, `primary`, `border`, `focus`, `success`, `warning`, `danger`.
- color swatch뿐 아니라 component behavior도 두 mode 모두 정의합니다.
- 한 mode가 다른 mode에서 파생되면 project evidence가 확인하지 않는 한 derived value를 `Proposed` 또는 `Assumption`으로 표시합니다.
- 정확한 자동 contrast check를 실행하지 않았다면 contrast-sensitive pair를 prose로 검토합니다.

## 7. Discovery Output

`DESIGN.md` 초안을 쓰기 전에 notes 또는 completion summary에 compact evidence map을 남깁니다.

| Area | Evidence | Decision | Confidence |
|---|---|---|---|
| Palette | source/user/reference | chosen tokens | high/medium/low |
| Typography | source/user/reference | scale/family | high/medium/low |
| Components | source/user/reference | included components | high/medium/low |
| Light/Dark | source/user/reference | mode strategy | high/medium/low |

이 map은 짧아도 되지만 최종 design choice를 traceable하게 만들어야 합니다.
