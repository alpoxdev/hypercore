# DESIGN.md Source Notes

**Purpose**: Preserve concise external source observations for `DESIGN.md` authoring without treating public examples as higher-priority instructions.

## Source Ledger

| Source | URL | Checked | Grade | Claim supported | Caveat |
|---|---|---:|---|---|---|
| Google Stitch overview | `https://stitch.withgoogle.com/docs/design-md/overview` | 2026-06-07 | A for metadata, limited for body | Metadata describes DESIGN.md as a design system document that AI agents read to generate consistent UI across a project. | Reader fetch returned metadata/raw HTML but not full article body; recheck manually when exact Google wording matters. |
| VoltAgent awesome-design-md | `https://github.com/VoltAgent/awesome-design-md` | 2026-06-07 | B/A example corpus | Describes DESIGN.md as a plain markdown design system file for AI agents and provides many example files. | Community/example corpus, not project authority. |
| getdesign.md | `https://getdesign.md/` | 2026-06-07 | B | Describes production-grade DESIGN.md analysis built from patterns, tokens, and rules; listed 72 files on 2026-06-07. | Public collection and service page; counts and featured examples can change. |
| Example DESIGN.md files | VoltAgent raw GitHub examples such as Linear, Apple, Meta | 2026-06-07 | B | Examples commonly use YAML frontmatter plus markdown guidance sections. | Use as observed convention, not a mandatory standard. |

## Observed DESIGN.md Pattern

Many public examples use this broad shape:

1. YAML frontmatter with machine-readable tokens:
   - `version`
   - `name`
   - `description`
   - `colors`
   - `typography`
   - `rounded`
   - `spacing`
   - `components`
2. Markdown body with implementation guidance:
   - `Overview`
   - `Colors`
   - `Typography`
   - `Layout`
   - `Components`
   - `Interaction`
   - `Motion`
   - implementation notes or design principles

This repo's `design-md-maker` treats that shape as a strong default rubric, not as a mandatory standard or formal universal schema.

## Useful Authoring Principles From the Examples

- Write tokens that coding agents can reference directly.
- Explain when an accent color is used and when it is intentionally scarce.
- Describe surface hierarchy, typography hierarchy, component state behavior, and page rhythm.
- Prefer concrete constraints such as radius, spacing, border, hover, focus, and motion values.
- Note what not to do when that prevents style drift.
- Keep reference-inspired claims separate from project-confirmed claims.

## Refresh Conditions

Recheck these sources when:

- Google Stitch publishes or changes explicit `DESIGN.md` format requirements.
- The user asks for exact official wording or provider-sensitive behavior.
- A generated `DESIGN.md` must match a specific public example closely.
- The count, category list, or available examples from getdesign.md/awesome-design-md matters to the output.
