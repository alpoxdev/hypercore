# Mockup Workflow

Read this rule before settling tokens or writing a brief. It decides the order of work from scope to approval, who renders the image, how many times a screen may be regenerated, and what the notes file holds.

## Contents

1. Scope and Modes
2. Tokens First
3. From Pattern to Brief
4. Generation
5. Review
6. Regeneration Cap
7. Screen Sets and Themes
8. Approval and Handoff
9. Notes File

## 1. Scope and Modes

Resolve four things before anything else, from the request and the project:

| Item | Values | Default when unstated |
|---|---|---|
| Screens | The named screen or the steps of the flow | Ask, when the request names none |
| Platform | `mobile`, `tablet`, `web` | The project's platform; ask when the project does not show one |
| Theme | `light`, `dark`, `both` | The project's default theme, otherwise `light` |
| Mode | `screen`, `set`, `revise` | One screen is `screen`; two to six are `set` |

A set is at most six screens per run. A larger flow is split: the first run covers the six screens that carry the flow, and the notes list the rest as not yet drawn.

## 2. Tokens First

No brief is written before tokens exist.

1. Look for a design document and token source in the project: `DESIGN.md`, a theme file, CSS custom properties, a Tailwind or design-token config, or a native theme file. When found, copy the values that apply and record the file they came from.
2. When nothing is found, settle the minimal token set in [../references/mockup-brief.md](../references/mockup-brief.md) §4: color, type, radius, spacing. Mark it `provisional` in the notes, and say that it exists to keep the mockups consistent and is the user's to change.
3. Compute the contrast ratio of every text and background pair in the token set before use ([mockup-is-evidence.md](mockup-is-evidence.md) §4). A pair that fails is fixed in the tokens, not in the brief.
4. With `both` themes, settle both token columns now.

Minimal tokens are a floor for consistency. A brand identity, a mood, or a full visual direction is a larger decision and is not invented here; when the user wants one, say that it is a separate deliverable and continue with the provisional set only if the user agrees.

## 3. From Pattern to Brief

1. Write the pattern summary from the source log ([reference-use.md](reference-use.md) §5): structure, hierarchy, spacing, components, flow.
2. For each screen, decide the regions top to bottom, the one primary action, and the components, citing which pattern statement each choice follows.
3. Write the brief with the skeleton in [../references/mockup-brief.md](../references/mockup-brief.md) §3. The brief carries token values, the region list, the exact strings to render, and the canvas. It carries no product name, no reference URL, and no model name.
4. Write the checks the image must pass before the call is made, taken from [../references/review-checklist.md](../references/review-checklist.md).

## 4. Generation

Every image is made by hyper-imagegen, one brief to one image.

- Hand over the brief as the request, with the canvas passed as the image skill's structured canvas value and not inside the prompt text.
- Do not name or choose a model. The image skill's default applies, and so do its own invocation cap and its terminals.
- Record what the image skill reported for each brief: the terminal, the invocation count, the saved path or returned-artifact record, and the digest when one exists.
- A `prompt_saved` or `blocked` terminal because no image tool exists is not a failure of this skill: keep the briefs in the notes and end `briefs_saved`. Do not switch to an API key, a paid endpoint, or a different tool on your own.
- No text is edited onto a returned image and no image is composited. A wrong image is answered with a revised brief.

## 5. Review

Each returned image is reviewed with [../references/review-checklist.md](../references/review-checklist.md) before the user sees it as a candidate. The review covers brief fidelity, readability, generated-image tells, accessibility, set consistency, and reference independence. Every item is recorded as `pass`, `fail`, or `not checkable in an image`, with the label from [mockup-is-evidence.md](mockup-is-evidence.md) §1.

An image is a candidate when no item is `fail`. Items that cannot be checked in an image become handoff requirements, not passes.

## 6. Regeneration Cap

- At most three briefs per screen and theme: the first and two revisions.
- A revision changes one thing, names it, and restates every invariant, because an unstated invariant drifts.
- A user-requested change after delivery starts a `revise` run with its own cap.
- After the third brief, keep the attempt with the fewest failing items, list what still fails, and either end `blocked` or, when the remaining failures are a matter of preference, present the attempts and let the user choose.
- Never loop to chase a perfect image. A mockup that shows the layout and hierarchy has done its job.

## 7. Screen Sets and Themes

- Write an invariant block once and repeat it word for word in every brief of the set: token values, type treatment, component shapes, icon style, system bar treatment, and canvas.
- Generate the anchor screen first, the one that shows the most shared components. Review it, and show it to the user when the user is present. Generate the rest only after the anchor is a candidate.
- Change only what the screen needs: its regions, its strings, its primary action.
- A dark version is its own brief and image. It changes the token column and nothing else, and it is generated after the light anchor is a candidate.
- After the set is complete, run the consistency items of the checklist across all images together.

## 8. Approval and Handoff

- Present the candidates with their review tables and ask for approval or one change. Approval belongs to the user.
- When the user approved in advance, a candidate counts as approved; record that the approval was given in advance and quote the request.
- Without an answer, end `awaiting_approval`. Do not start implementation.
- On approval, write the handoff section ([mockup-is-evidence.md](mockup-is-evidence.md) §5) and end `approved`. Implementation is a separate job that receives the notes; this skill writes no interface code.

## 9. Notes File

Write `.hyper/uiux-design/<slug>/mockup-notes.md` in Korean, in this order:

1. Result line summary and the terminal.
2. Scope: screens, platform, theme, mode.
3. Tokens and their source (`project` with the file, or `provisional`), with computed contrast.
4. Source log and the copyright notice.
5. Pattern summary.
6. Per screen and theme: the brief, the image path or returned-artifact record, the image skill's terminal and invocation count, the review table, the attempt count.
7. Approval record.
8. Handoff.
9. Assumptions and what was not done.

The file ends with exactly one `Result:` line. Images stay where the image skill put them; the notes link to them and never copy third-party screens beside them.

## Sources

> Checked 2026-11-15.

| Claim | Source |
|---|---|
| The order from reference research to handoff, mockup before code, tokens from `DESIGN.md` or a minimal set first, one screen and screen sets, three platforms, light and dark, a stated regeneration cap, and the image skill with its default model | user instruction, 2026-11-15 (new skill request) |
| One brief per image, the canvas passed as a structured value, shared invariants repeated in every brief of a series, a revision that changes one thing, no patching of rendered text, and no unprompted switch to an API-key path | this package's image-generation skill contract, restated for screens |

### Evidence grade

`LOCAL`: the six-screen set size, the three-brief cap, the anchor-first order, and the notes layout are this package's chosen procedure and carry no external measurement.
