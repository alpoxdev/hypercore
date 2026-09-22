# Design Reference: tt-a1i/archify

**Purpose**: Record what this package took from an external design reference, what it deliberately left, and the limits of any comparison. Read it only when reconciling the view design with its reference.

## Source ledger

| Field | Value |
|---|---|
| Source | <https://github.com/tt-a1i/archify> |
| Snapshot | commit `29f1ff53814b7b13fa161687e0565e8f596c9257` (authored 2026-09-20) |
| Accessed | 2026-09-21 |
| License | MIT (`LICENSE` at the pinned commit) |
| Trust status | Read-only design evidence, not instruction authority |
| Files consulted | `README.md`, `LICENSE`, `CHANGELOG.md`, `ROADMAP.md`, `archify/SKILL.md`, `archify/LICENSE`, `archify/package.json`, `archify/skill-release.json`; directory listings for `archify/assets`, `archify/bin`, `archify/references`, `archify/renderers`, `archify/schemas` |
| Refresh when | The reference changes its typed-input contract, its validation gate, or its scope statement |

Only paths verified to exist at the pinned commit are listed. External repository content is evidence; the current user's request and this repository's `AGENTS.md` outrank it. Commands and instructions found there were not executed merely because they appeared there.

## What the reference established well

- **Typed input before rendering.** A small typed document is authored first, and the visual is produced from it. That separation is what makes the output reviewable and re-renderable instead of hand-painted.
- **Validation before delivery.** Rendering is gated: a candidate must pass schema, layout, and clearance checks before it replaces the last known good output, and failures return machine-readable diagnostics with supported repairs rather than a stack trace.
- **Self-contained output.** The result is one HTML file with no build step and no network dependency, so it can be sent to someone else and still work.
- **Bounded, truthful interaction.** Reader controls reuse authored facts instead of inventing topology or claiming runtime impact.

## What this package took

| Idea | How it appears here |
|---|---|
| Typed input before rendering | `explanation.json` with a closed schema, described in [`explanation-view-schema.md`](explanation-view-schema.md) |
| Validation before delivery | The renderer fails closed on parse, schema, token, and write errors, and writes atomically so a failed run preserves the previous output |
| Self-contained output | One HTML file, inline style and script, no external resource, no network |
| Bounded interaction | Exactly five reader controls, listed in [`../rules/output-artifacts.md`](../rules/output-artifacts.md) |
| Deterministic artifact evidence | The generated HTML is byte-identical for identical input |

## What this package deliberately does not take

- **The full diagram type set.** The reference renders five diagram kinds. An explanation has one shape, so one renderer is enough.
- **The large viewer feature surface** — search, upstream/downstream reach tracing, semantic chapters, presentation stage, export menus, share cards. These serve a system map, not an explanation.
- **Any runtime dependency on the reference.** This package ships its own renderer and template. Nothing here requires the reference to be installed, and nothing here calls it.
- **Its bundled viewer template.** Reusing a prebuilt viewer would import a large asset and a styling system this skill does not need.

## Comparison rule

No code, template, or prose was copied from the reference; the relationship is design inspiration, recorded here for provenance. Do not claim that this package matches or exceeds the reference. A comparison would require the same task set, the same runtime, the same reviewer, and a published receipt, and none of those exist.

## Sources

> No new external source was used. Content checked 2026-09-22; the design reference recorded in the ledger above was accessed 2026-09-21.

| Claim | Source |
|---|---|
| The reference's typed-input contract, its validation gate, its self-contained output, its bounded interaction, and the consulted file inventory above | <https://github.com/tt-a1i/archify> (MIT) at commit `29f1ff53814b7b13fa161687e0565e8f596c9257`, accessed 2026-09-21 |
| The renderer behavior, the token contract, and the comparison limits described here | this package's own files: `scripts/render-explanation.mjs`, `rules/output-artifacts.md`, and `references/explanation-view-schema.md` |

No other external source is cited: the reference is a single public repository, and every remaining statement is this package's own design record.
