# DESIGN.md Source Notes

**Purpose**: public example을 더 높은 priority instruction으로 취급하지 않으면서 `DESIGN.md` authoring을 위한 외부 source 관찰값을 간결하게 보존합니다.

## Source Ledger

| Source | URL | Checked | Grade | Claim supported | Caveat |
|---|---|---:|---|---|---|
| Google Stitch overview | `https://stitch.withgoogle.com/docs/design-md/overview` | 2026-06-07 | metadata는 A, body는 limited | Metadata는 DESIGN.md를 AI agent가 프로젝트 전체에서 일관된 UI를 생성하기 위해 읽는 design system document로 설명합니다. | reader fetch가 metadata/raw HTML은 반환했지만 full article body는 반환하지 않았습니다. 정확한 Google wording이 중요하면 수동 재확인이 필요합니다. |
| VoltAgent awesome-design-md | `https://github.com/VoltAgent/awesome-design-md` | 2026-06-07 | B/A example corpus | DESIGN.md를 AI agent용 plain markdown design system file로 설명하고 많은 example files를 제공합니다. | Community/example corpus이며 project authority가 아닙니다. |
| getdesign.md | `https://getdesign.md/` | 2026-06-07 | B | patterns, tokens, rules 기반 production-grade DESIGN.md analysis를 설명하며 2026-06-07 기준 72 files를 표시했습니다. | Public collection/service page입니다. count와 featured examples는 바뀔 수 있습니다. |
| Example DESIGN.md files | Linear, Apple, Meta 같은 VoltAgent raw GitHub examples | 2026-06-07 | B | 예시들은 대체로 YAML frontmatter와 markdown guidance sections를 함께 사용합니다. | mandatory standard가 아니라 observed convention으로 사용합니다. |

## Observed DESIGN.md Pattern

많은 public examples는 대략 다음 shape를 사용합니다.

1. Machine-readable token을 담은 YAML frontmatter:
   - `version`
   - `name`
   - `description`
   - `colors`
   - `typography`
   - `rounded`
   - `spacing`
   - `components`
2. Implementation guidance를 담은 Markdown body:
   - `Overview`
   - `Colors`
   - `Typography`
   - `Layout`
   - `Components`
   - `Interaction`
   - `Motion`
   - implementation notes 또는 design principles

이 repo의 `design-md-maker`는 이 shape를 mandatory standard나 formal universal schema가 아니라 강한 default rubric으로 취급합니다.

## Useful Authoring Principles From the Examples

- Coding agent가 직접 reference할 수 있는 token을 씁니다.
- accent color를 언제 쓰고 언제 의도적으로 아끼는지 설명합니다.
- surface hierarchy, typography hierarchy, component state behavior, page rhythm을 설명합니다.
- radius, spacing, border, hover, focus, motion values 같은 concrete constraints를 선호합니다.
- style drift를 막는 데 도움이 되면 하지 말아야 할 것도 기록합니다.
- reference-inspired claims와 project-confirmed claims를 분리합니다.

## Refresh Conditions

다음 경우 source를 다시 확인합니다.

- Google Stitch가 명시적인 `DESIGN.md` format requirement를 게시하거나 변경할 때.
- 사용자가 exact official wording 또는 provider-sensitive behavior를 요청할 때.
- 생성되는 `DESIGN.md`가 특정 public example과 밀접하게 맞아야 할 때.
- getdesign.md/awesome-design-md의 count, category list, available examples가 산출물에 중요할 때.
