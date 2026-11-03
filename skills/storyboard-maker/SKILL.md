---
name: storyboard-maker
description: Use this skill when the user wants a film storyboard from a script, a synopsis, or a beat outline as HTML panels computed from numeric camera values, with continuity lint and A4 landscape print. When the runtime can make images, each panel and each scene floor plan gets a grayscale manga picture generated from the exact compiled prompt with no reference image; otherwise panels stay line art and each keeps a saved prompt. A script goes in; a self-contained `index.html` with panels, camera-value labels, movement arrows, a floor plan per scene, and continuity warnings comes out, beside `storyboard.json`, `shot-list.md`, and `manifest.json`. Not for animatics, video, GIF, PNG, or PDF files beyond the browser print dialog; not for photo or screenshot insertion, joint or drag editing, real people or celebrities in generated panels, or reproducing frames from an existing film.
compatibility: Self-contained Markdown skill plus one dependency-free HTML asset. A browser with DOM and CSS renders, prints, and reports the board; without one, the same core script runs under a `node` or `bun` runtime. Panel and floor-plan pictures are optional and need an observed image generation capability (a runtime image tool, a signed-in chat app driven through a browser, or an image API already configured); without one, panels keep line art and a saved prompt. No network, no login, no bundled font, no external library.
---

# Storyboard Maker

> Korean version: [`SKILL.ko.md`](SKILL.ko.md)

> Turn one script or synopsis into a self-contained HTML film storyboard whose panels are drawn from numbers, checked for continuity, and printed as A4 landscape.

<output_language>

Write every user-facing string in Korean: scene headings, action lines, `intent`, the shot list, the panel notes, and the hand-off message. Keep the source's dialogue language unless the user asks for a translation. JSON keys, enumeration values, file names, and error and warning codes stay in their original form, and a camera name printed on a panel always carries its number and its Korean term.

</output_language>

<purpose>

- Start from the source. Read the script and split it into beats before any camera decision; this skill bundles no script parser, so the reading is the agent's work.
- Derive every panel from five numbers — camera height, pitch, direction, roll, and lens — plus the shot size. A name such as low angle or close-up is printed from those numbers and is never an input.
- Draw line art that survives a thumbnail: boxes rather than stick lines, front markers only on the hemisphere that faces the camera, a hair mass on the back at every angle, and hidden-line removal so a limb behind the torso is not drawn through it.
- Generate each panel and floor-plan picture under this package's own image contract with the exact compiled prompt and no reference image, then inspect the returned picture before embedding it; when no image route is available or no picture passes, keep the line art and save the prompt for a later run.
- Print a camera line with numbers and Korean terms in a fixed order, so the panel can be shot from the page without asking what "low" meant.
- Lint continuity before delivery: the 180° axis, the 30° rule, eyeline matching, screen direction, jump cuts, and overloaded moves. Repair the geometry, or record the break with a method and a reason.
- Deliver one folder that opens from disk with no network: `index.html`, `storyboard.json`, `shot-list.md`, and `manifest.json`, with A4 landscape print and a floor plan per scene.
- Keep the renderer dependency-free. No library, no CDN, no web font, no remote request, and no image file outside the document.

</purpose>

<routing_rule>

Use `storyboard-maker` when the deliverable is a film storyboard: drawn panels for a script, a synopsis, or a scene list, with camera values, movement notation, and continuity checks.

Do not activate when:

- the deliverable is motion — an animatic, a video, a GIF, or a frame sequence — because this skill produces static panels only
- the user wants a photograph, a screenshot, or a recognizable real person in a panel — out of scope; panel pictures are drawn from this script's own staging and characters
- the user wants a UI wireframe, a comic page, or a presentation slide — the output shape is a film panel with a camera line
- the user wants an existing film's frames or boards reproduced or traced — refuse that part (see `<forbidden>`) and build the board from this script's own staging
- the user wants a script parser for another script format — the agent reads the script and writes the document

This skill is self-contained. It owns the input schema, the renderer asset, the continuity rules, the validation loop, the image generation contract, and the decision to keep line art. No other skill needs to be installed: without an image capability the board is still complete as line art.

</routing_rule>

<instruction_contract>

| Field | Contract |
|---|---|
| Intent | After one intake pass, deliver `.hyper/storyboard-maker/<slug>/` holding `index.html` (the studio asset with the document embedded), `storyboard.json`, `shot-list.md`, and `manifest.json`. |
| Scope | Story analysis, beat and shot planning, blocking and axis, camera values, the input document, optional panel pictures, the rendered board, and its report. No motion, no file export other than the browser print. |
| Authority | User request and repository instructions > the script's own text > this package's defaults (`16:9`, a 35 mm sensor, three panels per A4 landscape page, a 1.70 m character) > any external storyboard guide. |
| Evidence | Every panel traces to a beat in the source; every camera value is a number in the document, never an adjective; every break is repaired or recorded with a non-empty `crossing.reason`; every embedded picture passed the `references/panel-art.md` inspection and carries `generated` provenance; the report object, not the page's appearance, is the evidence. |
| Tools | A file writer for the document and the delivery folder. A browser with DOM and CSS for the board, the report, and print; without one, a `node` or `bun` runtime for `validate`, `lint`, and `render`. An observed image generation capability for pictures, used with the compiled prompt and nothing attached; without one, the line art and the saved prompt are the delivery. No network. |
| Loop | Write → render → read `getReport()` → fix errors, then repair or record warnings. At most two rounds, then deliver with the remaining codes named. |
| Output | Korean board text, `index.html`, `storyboard.json`, `shot-list.md`, `manifest.json`, and `shots[].image` data URIs for every panel that carries a picture. Machine-readable: the `getReport()` object and the `StoryboardCore` results. |
| Verification | `window.storyboardStudio.getReport()`, or the browserless core run, plus the `validation` checklist and the per-panel image inspection when pictures were generated. On a package change, the corpus validator, the authoring validator with `--require-self-containment`, and `bun run --cwd scripts verify`. |
| Stop condition | Ask the intake items once, then work without re-asking. Deliver after the checklist and a report with zero errors; stop and name the missing input when a fact the board needs cannot be grounded. Never claim a panel, a print, or a manifest that was not produced. |

</instruction_contract>

<activation_examples>

Positive:

- "이 대본으로 영화 스토리보드 만들어줘. A4 가로로 인쇄할 수 있게."
- "부엌 대화 장면 6샷 콘티를 카메라 높이와 앵글 값까지 넣어서 그려줘."
- "이 줄거리로 씬마다 평면도랑 180도 검사까지 되는 선화 콘티를 만들어줘."
- "Turn this synopsis into a line-art storyboard with camera values, movement arrows, and an A4 landscape print."
- "이 장면 샷 리스트 뽑고 16:9로 패널까지 그려줘. 로우 앵글 하나 넣어줘."
- "이 대본 패널을 흑백 만화풍 그림으로 그려줘. 구도는 카메라 값대로." — activate; pictures are generated from the computed composition when the runtime can, and line art with saved prompts is the fallback.

Negative:

- "이 대본으로 애니매틱 영상 만들어줘." → out of scope (motion output, not panels)
- "스토리보드 느낌의 사진을 만들어줘." → out of scope (photographic frame, not a drawn panel)
- "이 배우 얼굴 그대로 패널에 넣어줘." → out of scope (a recognizable real person)
- "이 영화 콘티랑 똑같이 그려줘." → out of scope (reproducing an existing film's frames)
- "이 앱 화면 와이어프레임 그려줘." → out of scope (UI wireframe, no camera line)

Boundary:

- "스토리보드 만들어줘." — ask for the source, the aspect, and the scope in one message; activate once a script or synopsis is in hand.
- "샷은 20개쯤 필요해." — activate; number shots in tens and let the beat sheet, not the count, decide the scenes.
- "카메라 각도는 대충 해도 돼." — activate; the angles are still numbers, and the stated defaults (`16:9`, 35 mm, pitch 0) fill what the brief leaves open.
- "인쇄용 PDF도 같이 줘." — activate; a PDF comes only from the browser print dialog, and the skill generates no PDF file.
- "그림은 내가 그릴 테니 샷 리스트만 뽑아줘." — activate; deliver the shot table and the document, and say the panels were not drawn.

</activation_examples>

<trigger_conditions>

Activate when the request names a storyboard, a shot board, a conti, a shot list with drawn panels, camera angles for a scene, continuity checking for a sequence, or an A4 printable board for a script, and the deliverable is drawn panels plus camera values. Also activate when the user supplies a script, a synopsis, or a scene list and asks how to cover it shot by shot.

Do not activate for motion output, photographic frames, a recognizable real person's likeness, UI wireframes, or a request to reproduce an existing film's boards; handle those as the `routing_rule` states.

</trigger_conditions>

<skill_architecture>

| Part | Role | Load condition |
|---|---|---|
| `SKILL.md` | Trigger, contract, workflow, safety, validation | Always |
| `rules/workflow.md` | The end-to-end run: intake, beats, shot list, blocking, camera values, JSON, injection, report, repair, delivery | Before starting a run |
| `rules/continuity.md` | The 180° axis, three-character staging, the four bridges and `none`, the 30° rule, eyeline matching, screen direction, recorded breaks | While blocking a scene and whenever a continuity warning fires |
| `rules/validation.md` | The pre-delivery checklist, the response to each code, the loop limit, the package-change checks | Before delivery and on a package change |
| `references/output-contract.md` | Input schema, derived geometry, output layout, `StoryboardCore` and `window.storyboardStudio`, codes, the browserless run | Before building the document or calling the core |
| `references/camera-and-framing.md` | The five camera values, pitch and height geometry, shot-size ranges, angle and direction names, the focal-length table, the horizon rule, Korean terms | While choosing camera values |
| `references/notation-and-drawing.md` | Arrow answers and vocabulary, frame-in-frame moves, line hierarchy, panel notes, transitions, mannequin construction, readability tests | While reviewing or defending a panel |
| `references/image-generation.md` | Capability observation, route choice, the immutable brief with no reference image, the two-attempt limit, the browser-driven chat route, persistence under `images/`, result states | Before generating any panel or floor-plan picture |
| `references/panel-art.md` | Art style, per-panel flow, inspection, embedding and provenance, floor-plan picture, fallback, safety | Before generating a panel picture or choosing the line-art fallback |
| `assets/storyboard-studio.html` | The renderer: core functions, gallery, report, floor plans, print CSS | To render, report, and print the board |
| `assets/sample-storyboard.json` | A two-scene, eight-shot worked example with one recorded crossing | When the document shape is unclear or on a first run |

</skill_architecture>

<loop_policy>

The run has one bounded loop: write or edit the document, render, read `getReport()`, fix errors, and repair or record warnings. One round is one edit pass, one re-render, and one re-read of the report. At most two rounds; after the second, deliver with the remaining warning codes named. An unresolved error stops delivery and is never delivered with a note. `JUMP_CUT`, `PRIMARY_MOVE_OVERLOAD`, and `WIDE_LENS_FACE` are repaired, not recorded. There is no loop that continues until the board looks good, and no self-grading loop that skips the report. Picture generation has its own limit, at most two attempts per brief (`references/image-generation.md`), and does not reset the board loop.

</loop_policy>

<language_and_translation_default>

Deliver in Korean by default: scene headings, action lines, `intent`, the shot list, and the hand-off note. Dialogue stays in the language the source gives it unless the user asks for a translation. Keep JSON keys, enumeration values, codes, file names, and camera names in their original form. The package's Markdown is maintained as English/Korean pairs; read only one language version per run.

</language_and_translation_default>

<reference_routing>

- Before starting a run, read `rules/workflow.md`.
- Before building the document or calling the core, or when the schema shape is unclear, read `references/output-contract.md`.
- While choosing camera values, read `references/camera-and-framing.md`.
- While blocking a scene, or when a continuity warning appears, read `rules/continuity.md`.
- While reviewing arrows, labels, line weight, or the mannequin, read `references/notation-and-drawing.md`.
- Before generating any picture, read `references/image-generation.md` for how to produce it and `references/panel-art.md` for what it must show; when deciding to keep the line art, read `references/panel-art.md`.
- Before delivery and whenever this package changes, read `rules/validation.md`.
- When the document shape is unclear or a first board is needed, open `assets/sample-storyboard.json` and `assets/storyboard-studio.html`.

</reference_routing>

<support_file_read_order>

Read only one language version per run. Paths are relative to this installed skill directory, never a hard-coded checkout or plugin cache. File reads are explicit actions, not automatic includes.

1. Read `rules/workflow.md` before starting the run.
2. Read `references/output-contract.md` before building the document.
3. Read `references/camera-and-framing.md` while choosing camera values.
4. Read `rules/continuity.md` while blocking and when a continuity code appears.
5. Read `references/notation-and-drawing.md` while reviewing panels.
6. Use `assets/sample-storyboard.json` when the document shape is unclear.
7. Copy `assets/storyboard-studio.html` to `index.html` and embed the document; do not edit the core, the styles, or the print rules.
8. Read `references/image-generation.md` and `references/panel-art.md` before generating a panel or floor-plan picture or choosing the line-art fallback.
9. Read `assets/evals/storyboard-maker-cases.jsonl` when changing the trigger, the workflow, or the output behavior.
10. Read `rules/validation.md` before delivery and whenever this package changes.

</support_file_read_order>

<workflow>

Two rules run through every step: build the board from this script's own space, never from another film's frames, and write everything the board shows in Korean.

| Step | Work | Output |
|---|---|---|
| 1. Intake | Ask once, in one message, only for what the brief leaves open: the source and whether it is final, the aspect, the scope and the expected panel count, the characters and their heights, and the tone. State the defaults you will use (`16:9`, 35 mm, three panels per page). | Confirmed brief |
| 2. Beat breakdown | Split the source into beats, one line each: what the audience learns, who wants what, where it happens. Group the beats into scenes with the script's heading and a number, and mark the turning beat of each scene. | Beat sheet |
| 3. Shot list | Turn each beat into one or more shots, number them in tens, and give each shot a size, a focus, and a reason. An insert takes the gap number, `15` between `10` and `20`. | Numbered shot list |
| 4. Scene blocking and axis | Place every character and prop on the floor plan in metres, give each character a facing and a pose, and declare the two ids that carry the axis or `null`. Check the camera side before drawing panels. | Floor plan and axis |
| 5. Camera values and intent | Write `size`, `focus`, `subjects`, `yawDeg`, `rollDeg`, `focalMm`, and at most one of `pitchDeg` and `heightM`; add the move, the subject moves, the duration, the transition, and one sentence of `intent`. | Numbers per shot |
| 6. Build the JSON | Assemble one document per `references/output-contract.md` §1. Every id resolves, no id repeats inside its scope, every value sits in its enumeration, and the file is written as `storyboard.json` first. | `storyboard.json` |
| 7. Inject into the studio copy | Copy the studio asset to `index.html` and put the document in `<script type="application/json" id="storyboard-doc">`, escaping every `</` as `<\/`. Change nothing else. | `index.html` |
| 8. Panel images | For each shot, compile the brief with `compilePanelPrompt()` and keep it exact, then generate with that string alone under `references/image-generation.md`; attach no reference image of any kind, not the `renderGuideSvg()` guide, an earlier panel, a character sheet, a style image, or an external image. View the guide beside each returned picture during the inspection in `references/panel-art.md` and embed only a picture that passes every row; observe the capabilities, stay within two attempts per brief, and save every returned picture under `images/`. When no route is available, or the picture ends in `prompt_saved` or `blocked`, keep the line art and save the prompt. Each scene may also get a floor-plan picture from `compileFloorPlanPrompt()` under the same rules, stored as `scenes[].planImage`. Write the document with its pictures back to `storyboard.json` and re-inject it into `index.html` with the same `<\/` escaping. | `shots[].image` and a re-injected document, or a saved prompt |
| 9. Open in a browser and read the report | Read `getReport()`, not the page: `errors` stops the build, `warnings` badge the panels, `info` records expected states, `intentional` lists every shot that carries a `crossing`, bridge shots included, and the counts say what rendered. | `getReport()` |
| 10. Fix errors and review warnings | Fix every error at its `path`; repair each warning, or record a line-related one with `crossing`. One round is one edit, one re-render, one re-read; at most two rounds. | Clean or documented report |
| 11. Deliver | Write `index.html`, `storyboard.json`, `shot-list.md`, and `manifest.json` to `.hyper/storyboard-maker/<slug>/`, run the `validation` checklist, and name the folder, the counts, and every remaining code. | Delivery folder |

When the source already carries a shot list with camera values, steps 1–5 shrink to confirming it; steps 6–11 always run.

</workflow>

<required>

- Ask the intake items in one message and await the reply; do not repeat answered items, and do not demand a shot list the user does not have.
- State the defaults in the same message: `16:9`, a 35 mm sensor, three panels per A4 landscape page, character height 1.70 m when the source is silent.
- Split the source into beats before choosing a camera, and let the beat sheet decide the scene count.
- Number shots in tens and place an insert at `15` or `25` instead of renumbering the scene.
- Give every shot a numeric `size`, `focus`, `yawDeg`, `rollDeg`, `focalMm`, `durationSec`, `transition`, and a one-sentence `intent`.
- Provide at most one of `pitchDeg` and `heightM` per shot, and neither on a `pov` or an `OTS` shot; use `heightM` when the camera has a physical position and `pitchDeg` when the angle is the instruction.
- Place every character and prop on the floor plan, and declare `axis` as two ids or `null` before judging any cut.
- Keep every id resolvable and every enumeration value inside its list; the document is the single source of truth for the drawing.
- Report the shot size, angle, direction, lens, camera height, and `DUTCH` only when the roll is non-zero, in that fixed order, with the number before the Korean term.
- Keep one primary move per panel, draw every arrow outside the subject, and label every arrow with the vocabulary.
- Generate each panel picture with the exact `compilePanelPrompt()` string as its whole brief, and each floor-plan picture with the exact `compileFloorPlanPrompt()` string, and no reference image of any kind, and embed the returned picture only after it passes every inspection row in `references/panel-art.md`.
- Embed a picture as a data URI with `provenance: "generated"` and the exact prompt; on fallback keep the line art and write the prompt into `shot-list.md`.
- Read the report object after every render, and re-render after every edit; a page can look finished while no panel exists.
- Repair line-related warnings or record them with `method`, `intentional: true`, and a non-empty `reason` that names the effect.
- Deliver `manifest.json` as the `getReport()` object unchanged, and keep the rendered panel count equal to the document's shot count.
- Keep the delivered copy identical to the asset except for the embedded document: the core script, the styles, and the `@page`/`break-inside` print rules stay untouched.
- Say which check ran. A browser read, a browserless core run, and no run at all are three different claims.

</required>

<forbidden>

- Depending on another skill being installed, naming another skill, or depending on any path outside this package.
- Attaching a reference image of any kind to the image invocation: the rasterized guide, an earlier panel, a character sheet, a style image, or an external image.
- An animatic, a video, a GIF, a frame sequence, or a PNG or PDF file written by the skill; a PDF comes only from the browser's print dialog.
- Presenting a generated panel as a photograph, a film frame, a production still, or a supplied picture; presenting a rendered line drawing as a photograph.
- A real person, a celebrity, or a recognizable likeness in a generated panel; the script's real-world names are rendered as fictional characters of the described build and wardrobe.
- Exceeding two attempts for one brief, or editing, paraphrasing, or re-translating the brief between attempts.
- Reproducing, tracing, or copying the frames, boards, or shot-for-shot staging of an existing film; the staging comes from this script.
- Vendoring a JavaScript library, loading a CDN script, fetching a web font, or making any network request from the delivered page.
- Bundling a script that runs the renderer; the core lives in the asset and is called in the browser or by a runtime one-liner.
- A joint, IK, drag, or viewport editor; a real-time camera control panel; a 3D scene view.
- A parser for a script format; the agent reads the script and writes the document.
- Editing the core script, the styles, or the print rules in the delivered copy, or shrinking `panelsPerPage` to make a page fit.
- Deleting a shot to silence a warning, or clamping an out-of-range number instead of correcting the value or the unit.
- Reporting a panel, a rendered board, a print, or a `manifest.json` that was not produced, or presenting an unverified board as checked.
- Interpolating user text as HTML; the renderer uses text content and escapes every value, and no string in the document may carry markup.
- A `null`, `"N/A"`, or brace placeholder filling a field that carries no meaning; omit the field instead.

</forbidden>

<runtime_fallback>

If no browser with a DOM is available, do not claim the board was seen. Execute the minimum contract and disclose the skipped step.

1. Write `storyboard.json` first, then `index.html` with the document embedded and every `</` escaped as `<\/`.
2. Run the core with `node` or `bun` exactly as `references/output-contract.md` §6 shows, pointed at `storyboard.json` rather than the injected copy. Read `validate` and `lint` from the output: the commands exit non-zero only on a thrown exception, not on a document with errors.
3. Apply the loop to that output: fix errors, repair or record warnings, at most two rounds.
4. Write `manifest.json` only when that fallback run also executed `render(doc)` and could count panels and scenes; otherwise deliver without `manifest.json` and say the counts were not captured.
5. Image generation does not depend on the browser. When an image route is observed, run the panel-image step for each shot, compiling the brief with `compilePanelPrompt()` from the same core and attaching no reference image; when none is, keep the line art and save each compiled prompt in `shot-list.md`. Never claim a picture that was not returned and inspected.
6. If neither a browser nor a JavaScript runtime exists, deliver `storyboard.json`, `shot-list.md`, and the embedded `index.html`, with a one-line note that the report and the visual check were not captured. Never fabricate a report, a panel count, a print, or a `manifest.json`.
7. Never describe a panel's appearance that was not rendered, and never say the page prints correctly when the print dialog was not opened.

</runtime_fallback>

<validation>

- [ ] Intake answered in one message, the defaults stated, and the delivery matches the chosen aspect and `panelsPerPage`.
- [ ] The source was read and split into beats; the shot list is numbered in tens and any insert sits at `15` or `25`.
- [ ] Every character and prop has a floor-plan position, and each scene declares `axis` as two ids or `null`.
- [ ] Every shot carries numeric camera values, one of `pitchDeg` and `heightM`, and a one-sentence `intent`; no name is used as an input.
- [ ] `getReport()` was read and `errors` is empty; `panels` equals the document's shot count and `scenes` equals its scene count.
- [ ] Remaining warnings are repaired, and every recorded break appears in `intentional[]` with `method`, `intentional`, and a non-empty `reason`.
- [ ] Each panel's camera line carries size, angle with pitch and Korean name, direction, lens, camera height with height name, and `DUTCH` only when the roll is non-zero.
- [ ] Line art passes the thumbnail silhouette test, front markers appear only on the camera-facing side, and the hair mass shows on a back view.
- [ ] At most one primary move per panel, every arrow outside the subject with a label, and no arrow across a face or a hand.
- [ ] Panel notes carry scene and shot, camera line, action, dialogue when it matters, sound, duration, and transition, with the transition belonging to the outgoing panel.
- [ ] `index.html` is the asset plus the embedded document, with the core, the styles, the `@page` landscape rule, and `break-inside: avoid` untouched.
- [ ] Print was checked in the browser dialog when a browser was available; otherwise the note says it was not captured.
- [ ] `manifest.json` is the `getReport()` object unchanged.
- [ ] Every embedded picture is a `data:image/...` URI with `provenance` set to `generated` or `supplied`, and no picture is described as a photograph, a film frame, or a production still.
- [ ] Every picture was viewed at readable size beside the `renderGuideSvg()` guide and passed the shot size, angle, view, facing side, no-text, and look-consistency rows.
- [ ] No reference image of any kind was attached to an image invocation: no rasterized guide, earlier panel, character sheet, style image, or external image.
- [ ] At most two attempts were made per brief, each stored prompt is the compiled string unchanged, and every returned picture is saved under `images/` with its record.
- [ ] Every fallback panel is named by id in the hand-off, keeps its line art, and has its prompt marked `PROMPT SAVED` in `shot-list.md`.
- [ ] No generated panel holds a real person, a celebrity, or a recognizable likeness, and no external image entered the pipeline.
- [ ] No network request, no remote `src` or `href`, no web font, and no bundled script in the delivered folder; every `image.src` is a data URI, not a URL or a file path.
- [ ] No existing film's frames or boards were copied, traced, or followed shot for shot.
- [ ] Package change only: KO/EN parity holds, the corpus validator and the authoring validator with `--require-self-containment` pass, and `bun run --cwd scripts verify` passes.

</validation>

## Sources

> Checked 2026-11-03.

| Claim | Source |
|---|---|
| Storyboard panels built from scene, shot size, camera note, action, optional dialogue, and transition, with shot numbers in tens so an insert fits at 15 | <https://storyboardart.org/storyboard-tutorials/storyboard-format-for-film/> |
| The 180° axis, eyeline matching, and the four bridging devices that let a scene change sides | <https://storyboardart.org/storyboard-tutorials/continuity-for-storyboards/> |
| Arrow shapes and labels are the storyboard convention; no source fixes their line weight or colour | <https://storyboardart.org/storyboard-tutorials/storyboard-arrows/> |
| Angle and direction terminology, and the disagreement between guides on where each angle starts | <https://filmglossary.ccnmtl.columbia.edu/term/camera-angle/> |
| Perspective, field of view, and the relation between focal length, distance, and face exaggeration | <https://www.edmundoptics.com/knowledge-center/application-notes/imaging/understanding-focal-length-and-field-of-view/> |
| The 30° rule as a convention with the axial cut as its deliberate exception | <https://en.wikipedia.org/wiki/30-degree_rule> |
| A4 landscape printing and page breaks declared with `@page` and `break-inside` | <https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@page> |
| The five camera values, the framing ranges, the mannequin and front/back markers, and the line hierarchy of this package | [`references/camera-and-framing.md`](references/camera-and-framing.md), [`references/notation-and-drawing.md`](references/notation-and-drawing.md) |
| The schema, the report, the codes, and the browserless core run for this package | [`references/output-contract.md`](references/output-contract.md) |
| The panel art style, the prompt call, the inspection rows, and the fallback for this package | [`references/panel-art.md`](references/panel-art.md) |
| The image generation contract: capability observation, route, immutable brief without reference images, attempt limit, persistence, and result states | [`references/image-generation.md`](references/image-generation.md) |
| The procedure, the continuity rules, and the delivery checklist for this package | [`rules/workflow.md`](rules/workflow.md), [`rules/continuity.md`](rules/continuity.md), [`rules/validation.md`](rules/validation.md) |
