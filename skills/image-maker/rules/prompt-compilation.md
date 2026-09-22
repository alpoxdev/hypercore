# Prompt Compilation Rules

Compile the request into a portable visual brief before choosing generation or prompt-file delivery. The brief describes the requested result; it does not encode a provider, model, command syntax, hidden control, or assumed capability.

## Resolve the request

Keep user-provided wording exact where exactness matters, especially text intended to appear in the image. Infer only reversible presentation details. Ask narrowly when a missing source, authority, rendered phrase, identity-preserving edit boundary, or preserve/change boundary prevents a faithful brief. Do not leave placeholders in a finished brief.

For an edit, name the supplied source's role, what must remain unchanged, and the requested change. Do not treat a reference as authority to alter it.

## Build one complete brief per image

Each requested image receives its own complete brief. State, in natural request-led prose:

- the intended use and principal subject, including distinguishing attributes;
- action or state and the environment;
- framing, viewpoint, scale, spatial order, and deliberately empty space;
- visible lighting direction, contrast, shadows, palette, materials, and medium;
- exact in-image wording, when requested, with role, placement, hierarchy, contrast, and a requirement for sharp, correctly spelled, legible text;
- supplied-reference roles and edit preservation/change constraints;
- requested count and any requested canvas shape or output characteristics.

The rendered text in the brief must be the exact text to render. Do not silently translate, normalize, duplicate, abbreviate, or add words. Put each required string once and make reading order explicit.

## Use observable constraints

Prefer visible instructions over empty praise. Describe the intended arrangement, surface, light, color, texture, and separation directly. Avoid artificial perfection and describe natural material or skin texture when relevant.

Exclusions follow a three-tier policy. Tier 0 (default): every scene exclusion is expressed as a positive, concrete condition, such as one isolated subject, an unbranded surface, or an uncluttered background; negative phrasing is not used because a scene negative can be rendered instead of removed. Tier 1 (text-render guard): only the whitelisted guard phrases below may use `no ...` form, and only when the brief contains rendered text.

| Tier 1 whitelist |
| --- |
| `no invented glyphs` |
| `no watermark` |

This whitelist is canonical in the validator constant `TIER1_NEGATIVE_WHITELIST`; the upstream kit's "exactly seven phrases" figure is unverified, so the set starts with the two evidenced phrases and grows only when an eval row proves the need. Tier 2: any other negative is allowed only when the requester explicitly opts in. Provider-style negative tails (`--no ...`) remain forbidden.

Do not borrow the name of a living artist, real person, or trademark as a visual shortcut when describable properties suffice. Authorized identity or brand material supplied for an edit may be preserved within the stated boundary.

## Series and variants

For a series, write shared invariants into every brief: the recurring visual language, palette family, type treatment when text exists, lighting/material behavior, and recurring motif. Change only the requested image-specific subject, layout, or concept axis. For exploration, vary one principal axis at a time. Unrelated variants are separate images, never competing instructions in one canvas.

## Compilation boundary

The compiled text must remain exact and ready to use as-is. Keep delivery reports, capability observations, paths, error explanations, and runtime parameters outside the prompt file. Do not add hidden provider flags, legacy shorthand, profile labels, fixed tiering, aspect-ratio tails, or static size assumptions. Pass supported structured fields separately only when the active runtime exposes them; their absence does not alter the rendered brief.

Before delivery, ensure every brief is complete, maps to one image, preserves exact requested text, identifies reference and edit boundaries, contains concrete visual constraints, and contains no report prose or unresolved choice.

## Sources

> No external sources were used. This file states rules that belong to the image-maker package itself. Content checked 2026-09-21.
