# Verification Rules

Step 7 (Independent Verify). Three layers, applied at the depth the sample count allows, plus the Deliver rules for step 8.

## Layer 1: Profile lint — always runs

A mechanical check of the spec document itself:

- [ ] All seven meta fields are filled (profile_mode, source_scope, sample_count, observed_contexts, valid_at, unsupported_contexts, 규칙 충돌 우선순위).
- [ ] Every rule outside Meta carries exactly one strength (MUST / PREFER / AVOID).
- [ ] Quantities are bands, not invented percentages.
- [ ] Known Limits section exists and is not empty.
- [ ] The 맥락 변주 section is present when observed_contexts has 2+ entries, or the generalization gap is recorded in Known Limits.
- [ ] No rule restates a consumer writer's default (divergence-only test from `rules/spec-schema.md`).

A lint failure loops back to Draft. This layer never passes a spec that merely looks filled in — it passes a spec whose structure is complete.

## Layer 2: Holdout feature check — runs when a holdout exists

Requires the holdout separated at intake (`rules/sample-quality.md`). The holdout was never read during analysis or Draft.

1. Measure the same features the spec makes claims about, on the holdout sample: ending distribution, symbol patterns, sentence length, lexicon items, structural habits.
2. Compare each measurement against the spec's claims and their strengths.
3. Fail a claim when the holdout contradicts a MUST, or shows a claimed "dominant" pattern absent.

The primary verdict is the deterministic feature delta — counted endings and symbols against claimed bands. Fix the spec where it fails, then re-check. Do not widen a claim to survive a holdout; narrow or split it.

## Layer 3: Consumer reproducibility — runs when verification is possible

Checks that the spec alone reproduces the voice:

1. A consumer pass generates a short neutral-content passage following only the spec (no samples in its context).
2. The evaluator compares the generated passage against the holdout's feature targets. The evaluator does not see the spec or the samples.
3. The primary judgment is the deterministic feature delta again: does the generated passage hit the spec's ending, symbol, and structural claims?

An LLM judge may act as a secondary, blind check (does the passage "sound like" the target without knowing what rules it followed), but same-model free-form self-assessment — the model that wrote or built the spec grading its own output by vibes — is forbidden. If the harness offers only one model and no blind channel, record that reproducibility was not independently verifiable and put it in Known Limits.

## Degradation policy

Verification depth is a function of the evidence, not of ambition:

| Situation | Layers that run | Required records |
|---|---|---|
| extracted/hybrid, sample_count >= 3, holdout exists | 1 + 2 + 3 (if a consumer/blind channel exists) | Full results; any layer-3 gap noted. |
| extracted/hybrid, sample_count >= 3, no holdout (was not separated) | 1 only, and fix intake discipline | Known Limits: "holdout verification unavailable". |
| low-sample extracted (1–2 samples) | 1 only | Known Limits: "holdout verification unavailable"; no fidelity or reproducibility claim anywhere in the spec or summary. |
| preset_approximation (no samples) | 1 only — schema adherence of the preset instance | No holdout fidelity verification is performed at all; the phrase "preset fidelity verified" is forbidden. The spec says the preset is an approximation. |
| hybrid | 1 + 2 on the sample-derived claims; preset-derived claims stay approximation-labeled | Preset portions never claim fidelity. |

A fidelity claim without its layer is the exact circularity this file exists to prevent.

## Deliver rules (step 8)

- Remove analysis scaffolding: evidence quotes, per-axis working notes, reliability commentary, rule IDs from this package. The spec states rules; it does not show the detective work.
- Keep the provenance meta block intact — it is the spec's honesty, not scaffolding.
- Self-contained check: the document is readable and usable with no access to this skill package, this repository, or any external file. A consumer AI needs the spec alone.
- Save as `tone-profile-<name>.md` in the location the user's environment expects; state where it was saved in the summary.
- Summary to the user: what was captured, the profile_mode, what verification ran, and what Known Limits says — in two to four lines, not a process dump.

## Sources

> No external sources were used. Content checked 2026-09-21.

This rule file states this package's own rules and makes no external claim, so no external source is cited.
