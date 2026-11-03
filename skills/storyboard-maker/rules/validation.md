# Validation

> Korean version: [`validation.ko.md`](validation.ko.md)

Read before delivery and whenever this package changes. This file owns the pre-delivery checklist, what to do with each report failure, the loop limit, and the checks a package change must pass.

## 1. Pre-delivery checklist

- [ ] The folder `.hyper/storyboard-maker/<slug>/` holds `index.html`, `storyboard.json`, `shot-list.md`, and `manifest.json`; `index.html` is the studio copy and opens from disk.
- [ ] The document sits inside `<script type="application/json" id="storyboard-doc">` and every `</` in it is escaped as `<\/`; the core script and the print rules are unmodified.
- [ ] The document in `storyboard.json` equals the document embedded in `index.html`, including every `shots[].image` and its prompt.
- [ ] `window.storyboardStudio.getReport()` was read in a real browser, or the core was run with `node` or `bun` as the output contract shows, and `errors` is empty.
- [ ] Line art reads at thumbnail size: the silhouette test passes, the face cross, eye dots, nose wedge, and chest line appear only when the character faces the camera, and the hair mass shows on the back at every angle, so front and back never read alike.
- [ ] Every panel's camera line carries numbers and Korean terms in the fixed order: size, angle name with pitch and Korean name, direction, lens, camera height with height name, and `DUTCH` only when the roll is non-zero.
- [ ] Every move other than `STATIC` and `HANDHELD` draws an arrow outside the subject with a label from the vocabulary; `HANDHELD` carries its label only. Each panel has at most one primary move, and no arrow crosses a face or a hand.
- [ ] Continuity warnings are resolved or recorded: no `AXIS_CROSSED`, `EYELINE_MISMATCH`, or `SCREEN_DIRECTION_FLIP` left unexplained, and each `intentional[]` entry carries `method`, `intentional`, and a non-empty `reason`.
- [ ] Panel notes carry scene and shot, camera line, action, dialogue, sound, duration, and transition, in that order, with the transition belonging to the outgoing panel.
- [ ] Shot numbers run in tens and any insert sits at `15` or `25`; scene numbers follow the script.
- [ ] Each scene has a floor plan that agrees with its panels: the camera sits on the declared side of the axis and each facing line on the plan agrees with the panel.
- [ ] Print CSS is intact: `@page { size: A4 landscape; margin: 12mm }`, `break-inside: avoid` on panels, and `panelsPerPage` honoured.
- [ ] `manifest.json` is the `getReport()` object unchanged, and its `panels` and `scenes` match the visible count.
- [ ] Every embedded picture has `provenance` set honestly to `generated` or `supplied`, and no picture is described as a photograph, a film frame, or a production still.
- [ ] Every picture passed the inspection rows before embedding: shot size, angle, view, facing side, no letters or logos, and look consistency with `characters[].look` and the earlier approved panel.
- [ ] No panel received more than two generation attempts, and each stored prompt is the compiled string unchanged, with no edit between attempts.
- [ ] Every fallback panel is named by id in the hand-off, keeps its line art, and carries a `PROMPT SAVED` note with its `SH <id>` block in `shot-list.md`.
- [ ] No generated panel holds a real person, a celebrity, or a recognizable likeness, and no existing film's frame, poster, or still was attached as a reference.
- [ ] No network: no remote script, no remote `src` or `href`, no `fetch`, no `XMLHttpRequest`, and no web font file; every `image.src` is a `data:image/...` URI, never a URL or a file path.
- [ ] Every user-facing string is Korean, including headings, action lines, the shot list, and `intent`.
- [ ] Nothing reproduces an existing film's frames or boards; staging, poses, and camera values come from this script.
- [ ] Every shot states `intent`, and no shot exists without new information.

## 2. Report failures and responses

Read the report object, not the page's appearance. A page can look finished while `#status[data-error="true"]` holds and no panel exists.

Errors stop the build and leave zero panels. Each one names a `path`; fix that path in the document.

| Code | Response |
|---|---|
| `SCHEMA_REQUIRED` | Add the missing key, or supply `camera.over` for an `OTS` shot. |
| `SCHEMA_TYPE` | Correct the value's type; an `over` value belongs only on an `OTS` shot. |
| `SCHEMA_ENUM` | Replace the value with one from the listed enumeration. |
| `SCHEMA_RANGE` | Bring the number inside its range; do not clamp silently, because a value outside the range usually means the wrong unit or the wrong value. |
| `SCHEMA_DUPLICATE` | Rename one of the repeated ids inside its scope. |
| `SCHEMA_REFERENCE` | Point the field at an existing character or prop id. |
| `SCHEMA_CONFLICT` | Remove one of the over-determining inputs: `pitchDeg` against `heightM`, or a fixed value on a `pov` or `OTS` shot. |
| `CAMERA_GEOMETRY` | Move the camera into reach: pick a `heightM` within the framing distance, or a pitch whose derived height stays above the floor. |

Warnings never block. A line-related warning is repaired or recorded with `crossing`; the other three are repaired only.

| Code | Response |
|---|---|
| `AXIS_CROSSED` | Bridge the cut with `neutral`, `subject-move`, `camera-move`, or `both`, or record `crossing` with `method: "none"` and a reason. |
| `EYELINE_MISMATCH` | Move one camera to the other side through a bridge and re-read `layoutShot().facingScreen`. |
| `JUMP_CUT` | Change the angle by 30° or more, or make the size change an explicit `axial` cut. |
| `SCREEN_DIRECTION_FLIP` | Keep the travel vector, show the turn, or record the reversal with `crossing`. |
| `PRIMARY_MOVE_OVERLOAD` | Demote one move to secondary, or split the shot. |
| `WIDE_LENS_FACE` | Change the lens or the size; do not leave a wide lens on a close face. |

Two rules apply to every fix:

- Editing the document after a render leaves the old board on screen. Re-render and re-read the report before the checklist is trusted.
- A line-related warning is cleared by repairing the geometry or by recording a `crossing` reason; `JUMP_CUT`, `PRIMARY_MOVE_OVERLOAD`, and `WIDE_LENS_FACE` are cleared only by repairing. Deleting the shot to silence the code does not count as a fix.

## 3. Loop and stop

Run the checklist and the report together, fix what fails, and read again.

- One round is one edit pass, one re-render, and one re-read. At most two rounds.
- After the second round, deliver with the remaining warning codes named in the hand-off message. Do not keep editing until the board looks good, because that loop has no end and hides the real decision.
- Stop and name the missing input when a fact the board needs (a character height, the scene order, the aspect ratio) cannot be grounded in the source or the user's answer.
- Stop before delivery when an error remains. Errors are never delivered with a note.
- When a browser is available, never deliver a panel you have not seen rendered; when the documented browserless fallback is used, say the visual check was not captured.

## 4. Package-change checklist

Only when this package changes:

- [ ] KO/EN parity holds for every Markdown pair: the same `##` sections in the same order, the same list items, and the same table rows.
- [ ] The corpus validator passes for this package with `--only storyboard-maker --json` and reports `ok: true`.
- [ ] The authoring validator passes with `--require-self-containment` and this package's eval file as `--evals`, with no errors.
- [ ] `bun run --cwd scripts verify` exits 0.
- [ ] `README.md`'s skill count and catalog row are updated when this package is added or renamed.

## Sources

> Checked 2026-11-03.

| Claim | Source |
|---|---|
| Every renderer error and warning code, its cause, and its suppression rule for this package | [`../references/output-contract.md`](../references/output-contract.md) §5 |
| The front/back markers and the hidden-line rules that make the mannequin readable | [`../references/notation-and-drawing.md`](../references/notation-and-drawing.md) §9 |
| The report is the authority, and a page in the error state renders no panel | [`../references/output-contract.md`](../references/output-contract.md) §4 |
| The picture inspection rows, the two-attempt limit, the honest provenance, and the fallback receipt for this package | [`../references/panel-art.md`](../references/panel-art.md) |
| A4 landscape printing and panels that avoid page breaks use `@page` and `break-inside` | <https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@page> |
