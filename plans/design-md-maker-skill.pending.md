# design-md-maker 스킬 생성 계획

상태: pending approval
작성일: 2026-06-07
대상: `skills/design-md-maker` 및 `plugins/hypercore/skills/design-md-maker`

## 결론

`design-md-maker`는 일반 문서 작성 스킬이 아니라, 사용자 요청·프로젝트 UI 근거·디자인 레퍼런스를 읽어 AI agent가 구현 가능한 `DESIGN.md`를 생성/갱신하는 전용 스킬로 만든다. 승인 전까지 구현, 소스 수정, 커밋, PR, 실행 스킬 위임은 하지 않는다.

## 근거

- 로컬 기준: `instructions/skill/SKILL_AUTHORING.md`, `skills/skill-maker/SKILL.md`, `skills/skill-maker/rules/*`, `skills/docs-maker/SKILL.md`, `skills/readme-maker/SKILL.md`, `README.md`, `plugins/hypercore/.codex-plugin/plugin.json`.
- 외부 참고:
  - https://stitch.withgoogle.com/docs/design-md/overview — Google Stitch 페이지 metadata는 `DESIGN.md`를 “AI agents read to generate consistent UI across your project”인 design system document로 설명한다. 본문 fetch는 제한적이므로 source notes에 caveat를 둔다.
  - https://github.com/VoltAgent/awesome-design-md — `DESIGN.md`를 프로젝트에 넣어 AI agent가 일관된 UI를 생성하도록 하는 plain markdown design system file로 설명하고, 실제 `DESIGN.md` 예시 모음을 제공한다.
  - https://getdesign.md/ — production-grade `DESIGN.md` analysis를 “patterns, tokens, and rules” 기반으로 제공하며 2026-06-07 기준 72개 파일을 표시한다.
- 관찰한 샘플 구조: YAML frontmatter에 `version`, `name`, `description`, `colors`, `typography`, `rounded`, `spacing`, `components`를 두고, 이후 `Overview`, `Colors`, `Typography`, `Layout`, `Components`, `Interaction`, `Motion`, `Implementation guidance` 류의 markdown 섹션을 둔다.

## RALPLAN-DR 요약

### 원칙

1. 프로젝트 근거 우선: 사용자 명시 요청 > 기존 `DESIGN.md` > 프로젝트 UI/source/theme/tokens/screenshots > local docs > 외부 예시.
2. AI-readable 출력 우선: 미학적 감상보다 구현 가능한 token, component rule, layout, interaction, motion constraint를 쓴다.
3. light/dark 완결성: 사용자가 요청하면 두 모드를 모두 작성하고 token/component variant parity를 검증한다.
4. Lean core + progressive disclosure: `SKILL.md`는 trigger/계약/workflow/read order만 담고 반복 세부는 `rules/`, 외부 source 관찰은 `references/`로 분리한다.
5. bilingual pairing: English canonical markdown과 Korean `.ko.md` mirror를 구조적으로 맞춘다.

### 결정 동인

1. `docs-maker`, `readme-maker`, `prd-maker`, architecture/implementation 요청과 충돌하지 않는 trigger 정확도.
2. 매번 다른 디자인 요청에도 반복 가능한 `DESIGN.md` 출력 품질과 검증 가능성.
3. root `skills/`와 Codex plugin mirror의 배포 표면 일관성.

### 고려한 옵션

| 옵션 | 장점 | 단점 | 결정 |
|---|---|---|---|
| 단일 `SKILL.md` | 빠르고 파일 수가 적음 | core 비대화, 검증/출력 규칙 혼합 | 기각 |
| `SKILL.md` + `rules/` + source reference | lean core, 기존 skill anatomy와 일치, 유지보수 용이 | 파일 수 증가 | 선택 |
| `assets/design-md.template.md` 포함 | 출력 shape 고정 | 프로젝트별 디자인 다양성 저하, 초기 과설계 | 보류 |
| `docs-maker` 확장 | 새 skill 추가 없음 | 디자인 token/component/light-dark 검증이 일반 문서 규칙에 묻힘 | 기각 |

## 파일 계획

```text
skills/design-md-maker/
├── SKILL.md
├── SKILL.ko.md
├── rules/
│   ├── project-design-discovery.md
│   ├── project-design-discovery.ko.md
│   ├── design-md-output-structure.md
│   ├── design-md-output-structure.ko.md
│   ├── validation.md
│   └── validation.ko.md
└── references/
    ├── design-md-source-notes.md
    └── design-md-source-notes.ko.md

plugins/hypercore/skills/design-md-maker/
└── root skill과 동일한 파일 mirror
```

### 파일별 책임

| 파일 | 책임 |
|---|---|
| `SKILL.md` / `SKILL.ko.md` | trigger, routing, instruction contract, workflow, support-file read order, required/forbidden, stop condition, validation 요약 |
| `rules/project-design-discovery.md` / `.ko.md` | 사용자 의도 파싱, 기존 `DESIGN.md`/UI/theme/token/source discovery, evidence priority, reference URL handling, 부족한 근거 처리, light/dark derivation rule |
| `rules/design-md-output-structure.md` / `.ko.md` | `DESIGN.md` YAML frontmatter/markdown section rubric, token naming, component rules, layout/interaction/motion/accessibility guidance, light/dark variant shape |
| `rules/validation.md` / `.ko.md` | trigger smoke, local link/fence, bilingual pair, DESIGN.md frontmatter/section, evidence-to-claim, token reference consistency, light/dark parity 검증 |
| `references/design-md-source-notes.md` / `.ko.md` | Google Stitch/awesome-design-md/getdesign.md 관찰값, 샘플 구조, source caveat, drift 재확인 조건 |

### 만들지 않을 파일

- `assets/`: 초기에는 복사/채움 템플릿보다 output rubric이 적합하다.
- `scripts/`: 반복 schema validation 필요가 확인되기 전까지 one-off readback/Python check로 충분하다.
- `agents/`: 현재 소비하는 runtime/UI metadata 요구가 없다.

## trigger 설계

### description 초안

```yaml
description: "Use this skill when the user asks to create or update a project-specific DESIGN.md design system document for AI agents, including visual direction, tokens, components, layout, interaction, motion, and light/dark mode variants from user requests, project UI evidence, or design references. Do not use for README/docs authoring, product requirements, architecture rules, or implementing UI code."
```

### Positive

- “Create a DESIGN.md for this project from the current UI.”
- “Generate DESIGN.md with light and dark mode tokens.”
- “이 레퍼런스 기반으로 우리 앱 DESIGN.md 만들어줘.”

### Negative

- “Create a README.md.” → `readme-maker`.
- “Implement dark mode components.” → implementation/refactor task.
- “Make a reusable skill folder for DESIGN.md generation.” → `skill-maker`.

### Boundary

- “Document our design system.” → 산출물이 `DESIGN.md`일 때만 `design-md-maker`, 일반 문서는 `docs-maker`.
- “Research DESIGN.md examples.” → `DESIGN.md` 산출이 없으면 research/docs 경로.
- “Create DESIGN.md and then build UI.” → `DESIGN.md` 먼저, UI 구현은 별도 승인/실행.

## 실행 순서

1. `skills/design-md-maker/` skeleton 생성.
2. `SKILL.md` 작성: frontmatter, `<output_language>`, purpose, routing, instruction contract, activation examples, workflow, read order, required/forbidden, validation.
3. `SKILL.ko.md` 작성: 같은 heading/section order로 한국어 mirror.
4. 세 rule 파일과 `.ko.md` mirror 작성.
5. source notes reference와 `.ko.md` mirror 작성.
6. root skill을 `plugins/hypercore/skills/design-md-maker/`로 동일 mirror 반영.
7. README skill catalogue/count와 manifest keyword 영향 확인 후, public catalogue에 영향이 있으면 갱신.
8. local validation/readback 실행.

## 검증 계획

### 구조/readback

- `skills/design-md-maker`와 `plugins/hypercore/skills/design-md-maker` 파일 목록이 계획과 일치.
- root/plugin mirror 파일 목록과 내용 동일성 확인.
- `SKILL.md` frontmatter의 `name`이 folder와 일치하고 `description`이 “무엇/언제/route-away”를 포함.
- `@rules/...`, `@references/...` 링크는 한 단계 직접 링크이고 모두 존재.
- 모든 material markdown에는 `.ko.md` sibling이 존재하고 구조적으로 정렬.

### DESIGN.md 출력 규칙 검증

- required frontmatter: `version`, `name`, `description`, `colors`, `typography`, `rounded`, `spacing`, `components`.
- required sections: `Overview`, `Design principles`, `Colors`, `Typography`, `Layout`, `Components`, `Interaction`, `Motion`, `Accessibility`, `Implementation guidance`.
- token reference consistency: `{colors.*}`, `{typography.*}`, `{rounded.*}`가 정의된 key를 참조.
- 근거 없는 색상/폰트/컴포넌트 claim은 assumption/TODO/proposed로 표시.
- light/dark 요청 시 양쪽 token group과 component variants가 모두 존재.

### smoke set

| id | prompt | expected |
|---|---|---|
| p1 | “Create a DESIGN.md for this project from the current UI.” | trigger |
| p2 | “Generate DESIGN.md with light and dark mode tokens.” | trigger |
| p3 | “이 레퍼런스 기반으로 우리 앱 DESIGN.md 만들어줘.” | trigger |
| n1 | “Create a README.md.” | no trigger |
| n2 | “Implement dark mode components.” | no trigger |
| b1 | “Document our design system.” | artifact가 `DESIGN.md`이면 trigger, 아니면 docs route |

## 승인 기준

- 계획한 root skill과 plugin mirror가 생성되고 bilingual pair가 모두 존재한다.
- `SKILL.md`는 lean core를 유지하며 intent, trigger, scope, authority, evidence, tools, output, verification, stop condition을 노출한다.
- external references는 evidence/source notes로만 취급하고 project/user instructions보다 우선하지 않는다.
- `DESIGN.md` 생성 규칙은 YAML token schema와 markdown guidance를 모두 포함한다.
- light/dark 요청 처리와 검증 기준이 trigger, workflow, output, validation에 모두 나타난다.
- README/plugin catalogue 영향이 확인되고 필요한 경우 반영된다.
- 구현 중 UI code, build/test/lint, commit/PR은 별도 승인 없이 실행하지 않는다.

## ADR

- Decision: `DESIGN.md` 전용 skill을 `docs-maker` 확장이 아니라 별도 `design-md-maker`로 추가한다.
- Drivers: trigger specificity, UI evidence/token normalization, light/dark parity validation, distribution mirror consistency.
- Alternatives considered: 단일 core, docs-maker 확장, static asset template, validation script.
- Why chosen: `DESIGN.md`는 일반 문서보다 token/component/theme extraction과 검증이 중요하므로 별도 trigger와 rule set이 유지보수성이 높다.
- Consequences: root/plugin mirror와 README catalogue 갱신 부담이 생긴다. 대신 false trigger와 출력 drift를 줄인다.
- Follow-ups: 반복 사용 후 schema validation이 자주 필요하면 `scripts/validate-design-md.mjs` 추가를 재검토한다.

## 리뷰 결과

- Planner: 초기 구조 계획 작성 완료.
- Architect: `WATCH`; trigger/evidence/resource/validation/distribution 보강 요구.
- Critic: 개정안 `APPROVE`; required revisions 없음.

## 남은 리스크

- Google Stitch 본문 fetch가 제한적이므로 source notes에 refresh/caveat를 명시해야 한다.
- `DESIGN.md` 관행은 emerging format이라 “표준”이 아니라 “관찰된 반복 구조”로 표현해야 한다.
- static template을 두지 않기 때문에 validation rule이 충분히 구체적이어야 출력 shape drift를 막을 수 있다.
