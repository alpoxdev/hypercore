# Workflow

> Korean version: [`workflow.ko.md`](workflow.ko.md)

Read before starting a run. This file owns the end-to-end procedure from intake to delivery. The eleven numbered steps run in this order; do not open a later step while an earlier one is still undecided.

## Originality and language

Two rules apply to every step below.

- Build the board from the script's own space. Never copy frames, boards, or shot-for-shot sequences from an existing film, and never trace a published storyboard. Camera values, blocking, and poses are derived from this story and these characters. A reference may teach the notation; it may not supply the staging.
- Write everything the board shows and everything the user reads in Korean: scene headings, action lines, `intent`, the shot list, and the delivery note. Keep dialogue in the language the source gives it unless the user asks for a translation.

## 1. Intake

Ask once, in one message, and only for the items the brief leaves open:

- the source: a script or a synopsis, and whether the script is the final text or a draft;
- the aspect ratio, defaulting to `16:9`;
- the scope: the whole script, one scene, or a selected sequence, and how many panels are expected;
- the characters that appear, with names and approximate heights;
- the tone, when the source does not fix it.

State the defaults you will use if the answer is silent: `16:9`, a 35 mm sensor, three panels per A4 landscape page. Await the reply, then do not ask again. This skill has no script parser, so read the script yourself and carry the beats forward in step 2.

## 2. Beat breakdown

Split the source into beats before thinking about cameras. A beat is one change of information: a decision, a reveal, a reversal, a refusal.

- Write one line per beat: what the audience learns, who wants what, and where it happens.
- Group the beats into scenes and give each scene the script's heading (`INT.` / `EXT.`, place, time) and a scene number.
- Mark the beat that turns each scene, because that beat usually earns the closest shot.
- Drop beats that change nothing. A board carries the story, not every line of the script.

The beat sheet, not the shot list, decides how many scenes the board has.

## 3. Shot list

Turn each beat into one or more shots, then number them.

- Number shots in tens: `10`, `20`, `30`. The gaps exist so an insert can be added later as `15` without renumbering the scene. Continue the tens across scenes in story order unless the source numbers them otherwise.
- One panel carries one action. If a line needs two poses, it needs two shots.
- Every shot names its size, its focus, and the reason it exists. A shot with no new information is cut.
- Cover the scene from the widest useful angle inward: an establishing shot, then the coverage the exchange needs.
- An insert that a wide shot cannot show (a hand, a screen, an object) takes the gap number, `15` between `10` and `20`, or `25` between `20` and `30`.

## 4. Scene blocking and axis

Place every character and prop on a floor plan before choosing a camera.

- Coordinates are metres on the scene floor: `x` runs to the scene's right, `z` away from the viewer, and the floor is `y = 0`.
- Give every character `x`, `z`, `facingDeg` (`0` faces `+z`, positive turns toward `+x`), and a `pose` from `stand`, `walk`, `sit`, `reach`, `crouch`.
- Give every prop `x`, `z`, `w`, `d`, `h`, and `y` whenever it does not stand on the floor. `y` is the base elevation in metres, so a cup resting on a table with `h: 0.75` gets `y: 0.75`; leave it out and the prop sits on the floor at `0`. A prop-focus shot frames the box from `y` to `y + h`, so this height decides whether an insert shows the object or only the tabletop under it.
- Declare `scene.axis` as the two character ids that carry the exchange, or `null` when the scene has no line.
- Check the floor plan before the panels: the camera side of the axis, the distance between the camera and each subject, and the direction each character faces. The floor plan drawn for each scene in `index.html` is this check.

The 180° rule, the four bridges, eyeline matching, and the 30° rule live in [`continuity.md`](continuity.md). Read it while blocking, not after rendering.

## 5. Camera values and intent

For each shot, write numbers, not adjectives.

- `size` from the enumeration, `focus` as one character or prop id, and `subjects` for the characters framed with the focus.
- `yawDeg`, `rollDeg`, and `focalMm` on every shot.
- `pitchDeg` or `heightM`, at most one of the two. Use `heightM` when the camera has a physical position (a table edge, a floor), and `pitchDeg` when the angle is the instruction.
- `distanceM` only when the computed framing distance is wrong for the space; `pov` and `over` only under the rules in [`../references/output-contract.md`](../references/output-contract.md) §1.4.
- `move` with `endSize` for the in and out families, and `subjectMoves` for characters who change position inside the shot.
- `durationSec` and `transition`.
- `intent`: one sentence on why this angle serves this beat. The panel does not print it, and reviewers read it.

Angle boundaries, the horizon rule, Korean names, and the focal-length table are in [`../references/camera-and-framing.md`](../references/camera-and-framing.md).

## 6. Build the JSON

Assemble one document per [`../references/output-contract.md`](../references/output-contract.md) §1: `version: 1`, `title`, optional `aspect`, `sensorLongMm`, `panelsPerPage`, then `characters` and `scenes`.

- Every id resolves: `focus`, `subjects`, `blocking.character`, `axis`, `subjectMoves.character`, `pov`, and `over` name something that exists.
- No id repeats inside its scope, and every enum value comes from the listed set.
- Write this document to `storyboard.json` first, because the next step embeds the same bytes.

## 7. Inject into the studio copy

Copy [`../assets/storyboard-studio.html`](../assets/storyboard-studio.html) to the delivery folder as `index.html`, and place the document inside its document element:

```html
<script type="application/json" id="storyboard-doc">{ ...document... }</script>
```

Escape every `</` in the JSON text as `<\/` so the embedded object cannot close its own script element. Nothing else needs escaping. Do not edit the core script, the styles, or the print rules; the copy differs from the asset only in that one element.

## 8. Panel images

Turn a panel from line art into a picture by delegating the picture to the `image-maker` skill. Read [`../references/panel-art.md`](../references/panel-art.md) first; it owns the style, the brief, the inspection rows, and the fallback. `image-maker` owns capability observation, the two-invocation limit per panel, refusal handling, and persistence under `.hyper/image-maker/<topic>/`.

- Call `compilePanelPrompt(doc, sceneId, shotId)` and keep the exact string. Read it once for errors of fact, then treat it as immutable.
- Call `renderGuideSvg(doc, sceneId, shotId)` and keep the guide for the storyboard side only: view it beside each returned picture during the inspection, as its composition reference. Do not rasterize it, and do not pass it to the image action.
- Invoke `image-maker` with the compiled prompt as the whole brief. Attach no reference image of any kind: not the guide, not an earlier panel, not a character sheet, not a style image, not an external image. Character consistency comes from the unchanged `characters[].look` text inside the compiled prompt alone.
- Inspect every returned picture against every row of the inspection table: shot size, angle, view, dutch tilt, facing side, subject count, letters, look, composition, and frame furniture. A picture that fails any row is not embedded.
- Embed an accepted picture on the shot as `shots[].image` with `src` a `data:image/png`, `data:image/jpeg`, or `data:image/webp` URI, `provenance: "generated"`, and `prompt` the exact compiled string. No URL, no file path, no blob.
- When `image-maker` is not installed, or it ends in `prompt_saved` or `blocked`, keep the line art and leave `image` absent. Write the compiled prompt into `shot-list.md` as a `PROMPT SAVED` note with a `SH <id>` block after the table, and name the fallback panel by id in the hand-off.

Process panels in shot order and inspect each before starting the next, so a design drift does not repeat down the sequence. When the panel pass ends, write the document with its accepted pictures back to `storyboard.json` and re-inject it into `index.html` with the same `<\/` escaping, so steps 9–11 read and deliver the same bytes.

## 9. Open in a browser and read the report

Open `index.html` in a browser and call `window.storyboardStudio.getReport()` from the console or through the browser automation you are using. Read the returned object, not the page's appearance:

- `errors` stops the build and leaves zero panels;
- `warnings` render as panel badges and a summary but do not block;
- `info` records expected states such as `HORIZON_OFFFRAME`;
- `intentional` lists every shot that carries a `crossing`;
- `panels` and `scenes` count what actually rendered.

A page that looks plausible can still sit in the error state, where `#status[data-error="true"]` and no panel exists. Check the object and the status attribute.

When no browser is available, run the core with `node` or `bun` exactly as [`../references/output-contract.md`](../references/output-contract.md) §6 shows and read `validate` and `lint` from the output. Point that run at `storyboard.json`, because the injected copy carries the `<\/` escapes. If neither a browser nor a JavaScript runtime exists, say so and deliver with the report marked as not captured.

## 10. Fix errors and review warnings

Errors are repaired, not explained away.

- Fix the document, re-render, and read the report again. A schema error usually sits at one path and a single edit clears it.
- Review every warning: repair the geometry. For `AXIS_CROSSED`, `EYELINE_MISMATCH`, or `SCREEN_DIRECTION_FLIP` you may instead record a `crossing` with `method`, `intentional: true`, and a `reason` that names the effect; `JUMP_CUT`, `PRIMARY_MOVE_OVERLOAD`, and `WIDE_LENS_FACE` cannot be recorded and must be repaired.
- Leave `HORIZON_OFFFRAME` alone when the angle intends it; the info entry is the record.
- One round is one edit pass, one re-render, and one re-read of the report. At most two rounds. After the second, deliver with the remaining warning codes named in the hand-off message; an unresolved error stops delivery. Do not keep tuning until the board looks good.
- After a repair that changes a pictured shot's `size`, camera values, `move`, or `subjects`, rerun step 8 for that shot with the rebuilt prompt, inside image-maker's two-invocation limit, or remove its `image` and save the prompt as a fallback panel; then re-inject the document before re-reading the report.

## 11. Deliver

Write the folder `.hyper/storyboard-maker/<slug>/`, where `<slug>` is a short kebab-case name for the film:

| File | Content |
|---|---|
| `index.html` | the studio copy with the document embedded |
| `storyboard.json` | the document exactly as rendered |
| `shot-list.md` | the Korean shot table from [`../references/output-contract.md`](../references/output-contract.md) §3, with a `SH <id>` prompt block for each panel that fell back to line art |
| `manifest.json` | the `getReport()` object, unchanged |

Run [`validation.md`](validation.md) before the folder is called done. The hand-off message names the folder, the report counts, and every warning or intentional break that remains.

## Sources

> Checked 2026-11-03.

| Claim | Source |
|---|---|
| Shot numbers advance in tens so an insert can be added later as 15 without renumbering | <https://storyboardart.org/storyboard-tutorials/storyboard-format-for-film/> |
| Panels are built from scene, shot size, camera note, action, optional dialogue, and transition | <https://storyboardart.org/storyboard-tutorials/storyboard-format-for-film/> |
| An A4 landscape print is declared with `@page { size: A4 landscape; margin: … }` and panels avoid page breaks | <https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@page> |
| The input document, report fields, and the browser-free core run for this package | [`../references/output-contract.md`](../references/output-contract.md) |
| The panel-image brief, delegation to image-maker without reference images, inspection, and fallback for this package | [`../references/panel-art.md`](../references/panel-art.md) |
| The four crossing methods and the recorded break for this package | [`continuity.md`](continuity.md) |
