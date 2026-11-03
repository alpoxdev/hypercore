# Panel Art

> Korean version: [`panel-art.ko.md`](panel-art.ko.md)

Read this before turning a panel from a line drawing into a picture. The line drawing stays the floor: it carries the camera geometry, the arrows, and the notes. This file owns the art style, the immutable brief handed to image-maker, the per-panel flow, the checks that a returned picture must pass, and the fallback when it cannot. A generated picture never replaces the drawing contract; it sits inside the frame while the drawing's overlays stay on top.

## Contents

- [1. Style target](#1-style-target)
- [2. Hand the brief to image-maker](#2-hand-the-brief-to-image-maker)
- [3. One panel at a time](#3-one-panel-at-a-time)
- [4. Camera values to prompt phrases](#4-camera-values-to-prompt-phrases)
- [5. Character consistency across panels](#5-character-consistency-across-panels)
- [6. Inspection before embedding](#6-inspection-before-embedding)
- [7. Embedding and provenance](#7-embedding-and-provenance)
- [8. Failure and fallback](#8-failure-and-fallback)
- [9. Safety and image sources](#9-safety-and-image-sources)
- [10. Common mistakes](#10-common-mistakes)

## 1. Style target

Every panel picture is grayscale manga-style storyboard ink line art. The look is a working board that a crew can read at thumbnail size, not a finished illustration and not a photograph.

| Property | Target |
|---|---|
| Line | Clean black ink contours with a little weight variation: heavier on the underside of forms and at the near edge, lighter inside. No rough pencil texture, no crosshatch clutter. |
| Tone | Two or three flat gray fills beside white and black. One light gray carries the background and the air; one mid gray carries clothing or shadow shapes; a darker gray is the exception, not the rule. No gradients, halftone dots, photographic grain, or color. |
| Value separation | The subject reads darker and more contrasty than the background. Background figures are flat light-gray silhouettes without facial detail, so they read as people without competing with the focus. |
| Faces | Believable proportions with manga simplification. Eyes, eyebrows, and mouth carry the expression; the expression matches the action line. A face is never a blank mannequin head. |
| Silhouette | One dominant action per panel, readable as a shape at thumbnail size. Limbs separate from the torso and do not merge into the background tone. |
| Composition | The panel's aspect ratio, shot-size crop, subject position, headroom, and floor follow the computed guide. The picture fills the frame edge to edge. |
| Forbidden marks | No letters, numbers, captions, speech bubbles, watermarks, logos, UI, frame borders, dividers, arrows, or camera labels inside the picture. The renderer draws the panel border, the movement arrows, and the panel note around and over the picture. |

The renderer's compiled prompt already carries the style sentence and the instruction not to draw text inside the picture. Read the compiled prompt before generating; do not add a second style sentence that contradicts it.

## 2. Hand the brief to image-maker

Panel picture generation is delegated to the `image-maker` skill. Do not call an image action directly, and do not re-implement its capability checks here. `image-maker` owns capability observation, the two-invocation limit per panel, refusal handling, and persistence under `.hyper/image-maker/<topic>/`.

What this skill supplies:

- One immutable brief per panel: the exact string from `compilePanelPrompt()`. It is the whole instruction; do not add a style sentence, a negative list, or a translation.
- No attachment of any kind. No reference image, no rasterized guide, no earlier panel, no character sheet, no style image, and no external image accompanies the brief.
- The `renderGuideSvg()` guide is kept on the storyboard side and viewed beside the returned picture during the inspection in section 6. It is never sent to the image action.

What `image-maker` returns:

- A generated picture, which this skill inspects before embedding; or
- `prompt_saved` or `blocked`, which keeps the line art and sends the panel to section 8; or
- no picture when the skill is not installed, which also sends the panel to section 8.

Record each panel's result as `generated`, `prompt_saved`, or `blocked` in the delivery report. Never upgrade a product name, a mention in documentation, or an earlier run into evidence that a picture exists now.

## 3. One panel at a time

Process panels in shot order, because a returned picture is inspected against one document and one brief. For each panel:

1. **Compute the layout.** Call `layoutShot(doc, sceneId, shotId)` and keep its returned `pitchDeg`, `heightM`, `facingScreen`, `angleName`, and `yawName`. These values, not a guess from the script, are what the picture must match. `facingScreen` applies only when the focus is a character; a prop-only insert has no facing side.
2. **Render the guide.** Call `renderGuideSvg(doc, sceneId, shotId)` and keep the returned SVG string. The guide holds the mannequin, the floor grid, and the horizon only; it has no arrows, labels, or notes. An empty string means the scene or shot id is wrong, so stop and fix the document. The guide is the inspector's composition reference; keep it on the storyboard side.
3. **Compile the brief.** Call `compilePanelPrompt(doc, sceneId, shotId)` and keep the exact string. The compiler emits the shot size, the crop and headroom for that size, the angle with its degrees, the facing side when the focus is a character, the lens, each visible character's `look`, the `Blocking:` sentence that gives every framed figure its screen side, pose, and facing, the action text, and the style sentence, and it omits dialogue and asks for no text inside the picture. Read it once for errors of fact; after that it is immutable.
4. **Invoke image-maker.** Hand the compiled string over as the whole brief with nothing attached. A reference image of any kind is not allowed, even when the action would accept one. Character consistency is carried by the `look` text inside the brief.
5. **Inspect.** View the returned picture at a readable size beside the guide and run every check in section 6. A picture that fails is not embedded; invoke image-maker again only within its remaining allowance, otherwise fall back.
6. **Embed.** Write the accepted picture into `shots[].image` as described in section 7, then move to the next shot.

Do not generate all panels in one batch and inspect them afterwards. A design drift found on panel four is cheaper to fix before panels five and six inherit it. Do not bypass image-maker because a direct image action looks available; that bypass loses the capability record, the limit, and the refusal handling.

## 4. Camera values to prompt phrases

The prompt is written in English and states camera geometry as plain photographic language. The numbers stay in the phrase so the picture can be checked against the panel's camera line. The compiled string is a fixed sequence of sentences:

```text
Storyboard panel, <size>[, <view>]. [Framing: <crop and headroom>.] Camera <angle> <degrees>°, <height> height <metres> m, <focal>mm lens[, dutch angle, horizon tilted <degrees>° to the <right|left>].
[<count> characters in frame: <name> (<look>); ... | Characters: <name> (<look>).] [Blocking: <name> <screen side>, <pose>, <facing>; ...]
Action: <action>. [Props in frame: <labels>.] Style: <style>.
Do not draw any text, letters, numbers, captions, or speech bubbles in the image.
```

The table below lists the exact fragments the compiler emits for each input. Read the compiled prompt against it; do not paraphrase the prompt before generation.

| Camera value | Prompt phrase |
|---|---|
| `size: ECU` | `extreme close-up` |
| `size: CU` | `close-up` |
| `size: MCU` | `medium close-up` |
| `size: MS` | `medium shot` |
| `size: COWBOY` | `cowboy shot` |
| `size: MWS` | `medium wide shot` |
| `size: FS` | `full shot` |
| `size: WS` | `wide shot` |
| `size: ELS` | `extreme wide shot` |
| `size: OTS` | `over-the-shoulder shot` |
| `yawDeg` FRONT | `front view, subject faces the camera` |
| `yawDeg` 3/4 | `three-quarter view, subject facing screen-left` or `three-quarter view, subject facing screen-right` |
| `yawDeg` PROFILE | `profile view (side view), subject facing screen-left` or `profile view (side view), subject facing screen-right` |
| `yawDeg` 3/4 BACK | `three-quarter back view, face mostly hidden` |
| `yawDeg` BACK | `back view, subject's face not visible` |
| `pitchDeg` 0 | `eye level 0°` |
| `pitchDeg` -12 | `low angle 12°` |
| `pitchDeg` +30 | `high angle 30°` |
| `pitchDeg` +90 | `overhead 90°` |
| `heightM` ≤ 0.3, or `pitchDeg` ≤ -75 | `worm's eye <degrees>°` |
| `heightName` KNEE, 0.5 m | `knee height 0.50 m` |
| `heightName` SHOULDER, 1.3 m | `shoulder height 1.30 m` |
| `heightName` ABOVE, 2.1 m | `above height 2.10 m` |
| `rollDeg` +8 | `dutch angle, horizon tilted 8° to the right` |
| `rollDeg` -8 | `dutch angle, horizon tilted 8° to the left` |
| `focalMm` 24 | `24mm lens` |
| `focalMm` 50 | `50mm lens` |
| `focalMm` 85 | `85mm lens` |
| two `subjects` | `2 characters in frame: <name> (<look>); <name> (<look>)` |
| Framing `size: ECU` | `framed from the chin to just above the head, tight on the face, small headroom, top of the head inside the frame` |
| Framing `size: CU` | `framed from the shoulders to just above the head, small headroom, the whole head inside the frame` |
| Framing `size: MCU` | `framed from mid-chest to just above the head, small headroom, top of the head fully inside the frame` |
| Framing `size: MS` | `framed from the waist to just above the head, headroom above the head` |
| Framing `size: COWBOY` | `framed from mid-thigh to just above the head, headroom above the head` |
| Framing `size: MWS` | `framed from the knees to just above the head, headroom above the head` |
| Framing `size: FS`, `WS` | `full figures head to feet with floor visible` |
| Framing `size: ELS` | `small full figures in a wide environment with floor visible` |
| Framing `size: OTS` | `over the near character's shoulder, near shoulder in the foreground, framed from mid-chest to just above the head with small headroom` |
| Blocking, left of frame | `<name> on screen-left, <pose>, <facing>` |
| Blocking, centre mark | `<name> at the centre of frame, <pose>, <facing>` |
| Blocking, right of frame | `<name> on screen-right, <pose>, <facing>` |
| Blocking pose | `standing`, `walking`, `sitting`, `reaching`, `crouching`, from `blocking[].pose` |
| Blocking facing | `facing screen-left`, `facing screen-right`, `facing the camera`, `facing away from the camera` |
| Blocking, OTS near shoulder | `<name> in the foreground, near shoulder only` |

The size and view fragments open the first sentence; the framing fragment follows it whenever the focus is a character, the angle, height, and lens fragments share the next sentence, and the roll fragment continues it. The view fragment appears only when the focus is a character. A roll is written to one decimal place, or as a whole number when it is whole.

The framing fragment names the crop the size actually draws, from `FRAME_RANGES`, and restates the headroom so a returned picture cannot cut the crown or reframe the body as a different shot. A prop focus has no framing fragment.

The `Blocking:` sentence places every framed figure. The screen side comes from the same projection the guide draws: the figure's head and chest are projected on its blocking mark, the outer thirds of the frame decide the side, and a figure in the middle third is placed against the other figures so a pair straddling the centre still reads as one screen-left and one screen-right. The facing comes from the figure's `facingDeg` against the camera: a face turned less than 15° from the camera reads `facing the camera`, one turned more than 120° away reads `facing away from the camera`, and every angle between keeps a side, `facing screen-left` or `facing screen-right`. The focus uses the same terms as the view fragment that opens the prompt, so the two sentences cannot disagree. The near shoulder of an OTS shot is named as foreground and gets no screen side, because the guide draws it wrapped around the frame edge instead of standing on the floor.

Two wording rules:

- The lens fragment names the field of view only. Never write that a short lens by itself distorts a face; the distance decides perspective, and a wide lens exaggerates only because filling the frame forces the camera close.
- The prompt describes the frame's starting composition. Movement stays in the overlay as arrows and labels; a moving camera does not add motion blur, speed lines, or a second frame to the picture.

## 5. Character consistency across panels

A character must look like the same person in every panel. Consistency comes from fixed text, not from an attached image:

- `characters[].look` is the design contract. It states age range, build, hair shape and length, clothing, and one or two distinguishing features, described by shape and gray value rather than color, for example "short black hair, lean build, dark gray hooded jacket, thin scar over the left eyebrow". The compiler copies it verbatim into every prompt that includes that character.
- Do not paraphrase, shorten, or restyle the `look` text between panels. A changed description produces a changed face.
- The compiled `look` text is the only identity carrier. No character sheet, no earlier panel, and no generated portrait is attached to any invocation.
- Do not let the model invent a wardrobe change, a hairstyle change, or a new principal character that the document does not contain. Background figures may be simplified silhouettes, but they must not read as extra named subjects.
- When a returned picture drifts from the `look` text, treat it as a failed inspection row and fall back rather than attaching a picture to correct it.

## 6. Inspection before embedding

Inspect the returned picture against the document, not against taste. Every row must pass before the picture is embedded.

| Check | Pass condition | On failure |
|---|---|---|
| Shot size | The crop matches `size`: `CU` holds head and neck, `MS` holds waist up, `FS` holds the whole figure with headroom and a little floor. | Retry within image-maker's allowance, then fall back. |
| Angle | The pitch sign is visible: a low angle shows the underside of the chin and a rising horizon; a high angle shows the crown and a falling horizon; an overhead has no horizon. | Retry within image-maker's allowance, then fall back. |
| View | When the focus is a character, the view matches `yawName` and the prompt's view phrase: front, three-quarter, profile, three-quarter back, or back, with the face hidden on a back view. | Retry within image-maker's allowance, then fall back. |
| Dutch tilt | A nonzero `rollDeg` produces the stated tilt, and its direction matches the sign: a positive roll lowers the horizon to the right, a negative roll to the left. Zero roll keeps the horizon level. | Retry within image-maker's allowance, then fall back. |
| Facing side | Applies only when the focus is a character and `yawName` is 3/4 or PROFILE, the only views whose prompt states a side: the subject looks toward `layoutShot().facingScreen`, screen-left or screen-right. FRONT, 3/4 BACK, and BACK are checked by the View row instead: face toward the camera, face mostly hidden, face not visible. A prop-only insert skips this row. A mirrored picture fails even when it is prettier. | Retry within image-maker's allowance, then fall back. |
| Blocking | Every entry of the prompt's `Blocking:` sentence is drawn as stated: the left-to-right order of the named figures matches the prompt, each figure stands in its named pose, and it faces the named way. A mirrored pair — the two figures swapped, or both turned the same way when the prompt gives them opposite sides — fails, even when the picture is prettier. The near shoulder of an OTS shot stays a foreground shoulder and is not drawn as a standing full figure. | Retry within image-maker's allowance, then fall back. |
| Subject count | Every `subjects[]` entry and the `focus` are present, and no invented principal figure appears. Background silhouettes do not count as subjects. | Retry within image-maker's allowance, then fall back. |
| Letters | No letters, numbers, speech bubbles, captions, watermarks, logos, or UI anywhere in the picture, including on clothing and props. | Retry within image-maker's allowance, then fall back. |
| Look | Hair, build, clothing, and distinguishing features match `characters[].look` in the compiled brief. No attached image supplies identity. | Invoke image-maker again within its allowance, then fall back. |
| Composition | The figure sits where the guide puts it, with the same headroom, floor, and horizon when the guide is viewed beside the picture. | Invoke image-maker again within its allowance, then fall back. |
| Frame furniture | No baked border, divider, arrow, label, or camera line inside the picture. Those belong to the renderer overlay. | Retry within image-maker's allowance, then fall back. |

An inspection failure is an objective failure and consumes one of image-maker's two invocations. When no accepted picture remains within that allowance, the panel keeps its line art and section 8 applies. "Close enough" is not a pass; a picture that fails the facing side or the subject count is worse than no picture, because it teaches the crew the wrong blocking.

## 7. Embedding and provenance

Only an accepted picture is embedded. Store it on the shot as a data URI, with the exact compiled prompt and an honest provenance:

```json
"image": {
  "src": "data:image/png;base64,<base64 bytes>",
  "provenance": "generated",
  "prompt": "<the exact string returned by compilePanelPrompt>"
}
```

Rules:

- `src` is a `data:image/png`, `data:image/jpeg`, or `data:image/webp` URI. No `http` or `https` URL, no file path, no blob URL; the panel must render with no network access. Convert the returned bytes rather than linking to them.
- `provenance` is `generated` only when this run's image action returned the picture. A picture the user supplied is `supplied`; never call it generated, and never present a supplied picture as the result of a prompt.
- `prompt` is the compiled string, unchanged. Do not store a shortened summary, a translated version, or a second prompt from a retry, because the retry uses the same text.
- Keep the picture at a size that keeps the HTML practical, but never crop it to hide a failed check. If it must be scaled, scale the whole frame.
- The delivery report names which panels were generated, which were supplied, and which stayed line art. A count without panel ids is not evidence.

A scene's overhead floor-plan picture follows the same rules. Its brief is `compileFloorPlanPrompt(doc, sceneId)`, sent with no attachment. It passes inspection only when it is a straight top-down view, every prop and character in the scene appears, their positions and facing match the technical floor plan (`+z` toward the top), and it carries no letters, labels, or arrows. Store it as `scenes[].planImage` with the same `src`, `provenance`, and `prompt` fields; the technical plan stays on the board as the reference.

## 8. Failure and fallback

Fall back to the line-art panel when any of these is true:

- `image-maker` is not installed.
- `image-maker` ends with `prompt_saved` or `blocked`.
- No accepted picture came back within image-maker's allowance.

The fallback is not a failure of the board. The line drawing already carries the camera geometry, the movement, and the notes; the picture is an addition.

On fallback:

1. Leave `shots[].image` absent. Never write a placeholder, a broken data URI, or the guide raster as if it were a picture.
2. For a fallback panel, the prompt lives in `shot-list.md`: mark the shot's note as `PROMPT SAVED` and repeat the prompt under a `SH <id>` block after the table. A generated panel keeps its exact prompt in `shots[].image.prompt`. `manifest.json` is the unchanged `getReport()` object and holds no prompts. The prompt must survive so a later run can produce the same picture.
3. Report the fallback by panel id and cause, for example "SH 30: image-maker prompt_saved, 선화 유지, 프롬프트 저장".
4. Never claim an image was generated, saved, or attached when only a prompt was kept.

A board may mix generated and line-art panels. That is a normal partial result, and it is reported panel by panel. Do not regenerate the whole board because one panel fell back.

## 9. Safety and image sources

- Do not depict real people, celebrities, or a recognizable likeness. A script that names a real person is rendered as a fictional character in that role, with the described wardrobe and build but not the face.
- Do not reproduce frames, boards, or promotional images from existing films. Do not attach a film still, a poster, or a frame grab as a reference image, even when the script cites that film as a reference for tone.
- No reference image enters the pipeline. The guide is viewed beside the returned picture during inspection and is never attached; earlier panels, character sheets, style images, and external images are never attached either.
- Generated pictures are labeled as generated by `provenance` and in the delivery report. Supplied pictures are labeled `supplied`. Neither is described as photography or as an original production frame.
- image-maker's refusal is respected as final. Change the request only when the document changes; do not disguise a refused subject with softer words.

## 10. Common mistakes

| Mistake | Why it hurts | Fix |
|---|---|---|
| Attaching the guide or an earlier panel to the invocation | A reference overrides the computed composition and breaks the no-reference rule, so the camera line becomes false. | Send the compiled brief alone; view the guide only during inspection. |
| Calling an image action directly instead of image-maker | Capability observation, the invocation limit, and refusal handling are lost or duplicated. | Delegate every panel picture to image-maker with the compiled brief. |
| Attaching a character sheet or a style image | Identity and style drift from the prompt, and the picture no longer traces to `characters[].look`. | Carry identity in the `look` text inside the brief and attach nothing. |
| Accepting a mirrored panel | Screen direction and eyelines flip, creating a continuity error the lint cannot see inside a picture. | Check `facingScreen` and regenerate. |
| Adding text to the picture to explain the action | The picture must read without words, and baked letters break the self-contained board. | Fix the pose or composition; keep text in the panel note. |
| Calling a saved prompt a generated image | The delivery overstates what exists and a later reader cannot reproduce it. | Report `PROMPT SAVED` and the panel id. |
| Generating every panel before inspecting any | A design drift repeats across the sequence. | Inspect each panel before the next. |
| Using a film still as a style reference | It copies an existing work and can reproduce a protected frame. | Attach no reference image at all; the compiled brief is the only input. |

## Sources

> Checked 2026-11-03.

| Claim | Source |
|---|---|
| Camera angle is the camera's position relative to the subject; a low angle sits below eye level and looks up, a high angle sits above and looks down | <https://filmglossary.ccnmtl.columbia.edu/term/camera-angle/> |
| Overhead looks straight down so no horizon is visible; angle names describe position while the numeric degrees stay authoritative | <https://storyboardart.org/storyboard-tutorials/camera-angles-for-storyboard-artists/> |
| Shot-size wording follows conventional crops: close-up to the neck, medium shot to the waist, cowboy shot to mid-thigh | <https://www.studiobinder.com/blog/types-of-camera-shots-sizes-in-film/> |
| Field of view is `2·atan(sensor size / (2·focal length))`, so focal length is stated in millimetres with the lens's field of view | <https://www.edmundoptics.com/knowledge-center/application-notes/imaging/understanding-focal-length-and-field-of-view/> |
| Perspective distortion comes from camera distance, not from the lens alone | <https://en.wikipedia.org/wiki/Perspective_distortion> |
| The horizon sits at the viewer's actual eye height and stays level | <https://courses.byui.edu/art110_new/art110/week01/eye_level.html> |
| Panel labels, arrows, and notes are drawn outside the picture frame, so the picture itself carries no letters | [`notation-and-drawing.md`](notation-and-drawing.md) |
| The image slot accepts only a data URI with `generated` or `supplied` provenance and keeps the compiled prompt | [`output-contract.md`](output-contract.md) |
| Camera values, shot sizes, and facing side come from the computed layout, not from the script's prose | [`camera-and-framing.md`](camera-and-framing.md) |
| The grayscale manga panel style target was set by user direction on 2026-11-03, and no reference image is attached when a picture is generated | User direction, 2026-11-03 |
