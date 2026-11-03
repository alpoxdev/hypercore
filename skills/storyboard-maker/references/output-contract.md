# Output Contract

> Korean version: [`output-contract.ko.md`](output-contract.ko.md)

Read this before building a document or changing the renderer. This file owns the input schema, the camera geometry derived from it, the output folder, the `StoryboardCore` and `window.storyboardStudio` API, and every code the checker can raise.

## Contents

- [1. Input document](#1-input-document)
- [2. Camera values and derived geometry](#2-camera-values-and-derived-geometry)
- [3. Output layout](#3-output-layout)
- [4. Renderer API](#4-renderer-api)
- [5. Codes and suppression](#5-codes-and-suppression)
- [6. Running the core without a browser](#6-running-the-core-without-a-browser)

## 1. Input document

One JSON object with `version: 1`. Every key below is required unless the row says optional. Unknown keys are ignored, not rejected.

### 1.1 Top level

| Key | Type | Required | Default | Rule |
|---|---|---|---|---|
| `version` | number | yes | — | Must be `1`. |
| `title` | string | yes | — | Non-empty. Printed in the page header and in the report. |
| `aspect` | string | no | `16:9` | One of `16:9`, `2.39:1`, `1.85:1`, `4:3`, `9:16`. |
| `sensorLongMm` | number | no | `35` | Long axis of the sensor in millimetres. Only feeds the vertical field of view. |
| `panelsPerPage` | integer | no | `3` | `1`–`4`. Panels per printed A4 landscape page. |
| `style` | string | no | `grayscale manga storyboard line art, clean ink lines, 2-3 flat gray tones, no text, no speech bubbles` | Non-empty. The look carried into every panel prompt (1.7). It never changes the drawn line art. |
| `characters` | object[] | yes | — | At least one. |
| `scenes` | object[] | yes | — | At least one, in story order. |

Each `characters[]` entry:

| Key | Type | Required | Default | Rule |
|---|---|---|---|---|
| `id` | string | yes | — | Unique in the document. Referenced by `focus`, `subjects`, `blocking`, `subjectMoves`, `pov`, `over`, `axis`. |
| `name` | string | yes | — | Non-empty. Printed on panels and floor plans. |
| `heightM` | number | no | `1.70` | Metres. Drives framing and the camera-height calculation. |
| `look` | string | no | absent | Non-empty. One short, original line of appearance (build, hair, clothing) used by the panel prompt so the same character reads the same way in every generated panel. Never name a real actor or a living person. |

### 1.2 Scenes

| Key | Type | Required | Default | Rule |
|---|---|---|---|---|
| `id` | string | yes | — | Unique in the document. |
| `number` | number | yes | — | Shown as `SC <number>`. |
| `heading` | string | yes | — | Set heading printed on every panel of the scene. |
| `planImage` | object or `null` | no | absent | A finished overhead picture of the scene's floor plan, with the same fields and checks as a shot `image` (1.7). It is drawn below the technical floor plan, which stays unchanged and remains the reference for positions, cameras, and the axis. |
| `props` | object[] | yes | — | May be empty. |
| `blocking` | object[] | yes | — | Initial positions of the characters in this scene. |
| `axis` | `[string, string]` or `null` | yes | — | Two character ids defining the 180° line, or `null` when the scene has no line. |
| `shots` | object[] | yes | — | At least one, in cut order. |

Each `props[]` entry:

| Key | Type | Required | Default | Rule |
|---|---|---|---|---|
| `id` | string | yes | — | Unique in the scene. Referenced by `focus`. |
| `label` | string | yes | — | Non-empty. Printed on the floor plan. |
| `x` | number | yes | — | Metres. Runs to the scene's right. |
| `z` | number | yes | — | Metres. Runs away from the viewer. |
| `w` | number | yes | — | Metres. Width along `x`. |
| `d` | number | yes | — | Metres. Depth along `z`. |
| `h` | number | yes | — | Metres. Height above the base. |
| `y` | number | no | `0` | Metres. Base elevation above the floor (`props[].y`). A cup on a table of `h: 0.75` uses `y: 0.75`. It must be `0` or greater: a negative value is `SCHEMA_RANGE` and a non-number is `SCHEMA_TYPE`. The drawn box spans `y` to `y + h`; the floor plan ignores `y` because it is a plan view. |

A prop with no `y` stands on the floor and its drawn box is unchanged; prop-focus shots now centre on `y + h / 2`, so existing documents with prop-focus shots get a different camera height.

`blocking[]` entries: `character` (character id present in `blocking` semantics: one entry per character, unique), `x`, `z` (metres), `facingDeg` (degrees, `0` = facing `+z`, positive turns toward `+x`), `pose` (one of `stand`, `walk`, `sit`, `reach`, `crouch`).

### 1.3 Shots

| Key | Type | Required | Default | Rule |
|---|---|---|---|---|
| `id` | string | yes | — | Unique in the scene. Also seeds the sketch jitter, so a changed id changes the drawing. |
| `size` | string | yes | — | One of `ECU`, `CU`, `MCU`, `MS`, `COWBOY`, `MWS`, `FS`, `WS`, `ELS`, `OTS`. |
| `focus` | string | yes | — | Character id or prop id. It sets the framing box and the orbit target. |
| `subjects` | string[] | no | `[focus]` when `focus` is a character, `[]` when it is a prop | Character ids framed together with the focus. The framing box becomes the union of the focus box and every subject box. |
| `camera` | object | yes | — | See 1.4. |
| `move` | object or `null` | yes | — | See 1.5. `null` means no camera movement. |
| `subjectMoves` | object[] | yes | — | May be empty. See 1.5. |
| `blockingOverride` | object[] | no | absent | Entries with the same shape as `blocking[]`; they replace that character's blocking for this shot only. |
| `action` | string | yes | — | Present-tense action line. |
| `dialogue` | object[] | no | absent | `{ "speaker": string, "line": string }`. `speaker` is printed verbatim before the colon; use the character name. |
| `sound` | string | no | absent | Sound note printed on the panel. |
| `image` | object or `null` | no | absent | A finished picture for this panel. See 1.7. When present it replaces the line art; every note and movement mark stays. |
| `durationSec` | number | yes | — | `0.2`–`600`. |
| `transition` | string | yes | — | One of `CUT`, `DISSOLVE`, `FADE IN`, `FADE OUT`, `WIPE`, `SMASH CUT`, `MATCH CUT`. Printed as the transition into the next panel. |
| `crossing` | object or `null` | yes | — | See 1.6. |
| `intent` | string | yes | — | Why this shot exists. Not printed on the panel; kept in the document for review. |

### 1.4 Camera

| Key | Type | Required | Default | Range / rule |
|---|---|---|---|---|
| `pitchDeg` | number | no | `0` | `-90`–`90`. Positive looks down. Mutually exclusive with `heightM`. |
| `heightM` | number | no | — | `0.05`–`50`. Mutually exclusive with `pitchDeg`. |
| `yawDeg` | number | yes | — | `-180`–`180`. Orbital azimuth around the focus, measured from the focus's facing direction (for a prop focus, from `+z`). `0` = camera in front of the subject, positive values put the subject's nose toward screen-left, `±180` = behind the subject. |
| `rollDeg` | number | yes | — | `-45`–`45`. Dutch angle about the view axis. |
| `focalMm` | number | yes | — | `10`–`300`. |
| `distanceM` | number | no | — | Metres. Replaces the computed framing distance. Forbidden for `pov` and `OTS` shots. |
| `pov` | string | no | — | Character id. The camera sits at that character's eye point and looks at the focus. Forbidden together with `pitchDeg`, `heightM`, or `distanceM`, and forbidden with `size: "OTS"`. |
| `over` | string | no | — | Character id. Required when `size` is `OTS`, rejected for every other size. |

When neither `pitchDeg` nor `heightM` is given the pitch is `0`. When both are given the document is rejected with `SCHEMA_CONFLICT`.

### 1.5 Movement

`move` object: `type` (one of `STATIC`, `PAN L`, `PAN R`, `TILT UP`, `TILT DOWN`, `PUSH IN`, `PULL OUT`, `ZOOM IN`, `ZOOM OUT`, `DOLLY IN`, `DOLLY OUT`, `TRUCK L`, `TRUCK R`, `PED UP`, `PED DOWN`, `CRANE UP`, `CRANE DOWN`, `ROLL L`, `ROLL R`, `HANDHELD`), `endSize` (a `size` enum value; required when the type is `PUSH IN`, `ZOOM IN`, `DOLLY IN`, `PULL OUT`, `ZOOM OUT`, or `DOLLY OUT`), `primary` (boolean).

`subjectMoves[]` entries: `character` (character id), `to` (`{ "x": number, "z": number }` in metres), `label` (string), `primary` (boolean).

A move counts toward `PRIMARY_MOVE_OVERLOAD` when its `primary` is `true`. The camera `move` can contribute at most one primary; every primary `subjectMove` contributes one more.

### 1.6 Crossing the line

`crossing` is `null` or an object with `method` (one of `neutral`, `subject-move`, `camera-move`, `both`, `none`), `intentional` (boolean), and `reason` (non-empty string). `none` means the cut crosses the line without a bridging device. Any shot that declares `crossing` suppresses the three line-related warnings for the cut into it and is recorded in `intentional[]`, whether or not `intentional` is `true`.

### 1.7 Pictures, style and look

A panel normally carries line art drawn from its camera values. `shots[].image` lets one panel carry a finished picture instead, and `doc.style` plus `characters[].look` describe the art that an image generator should produce.

`image` is `null` or an object:

| Key | Type | Required | Rule |
|---|---|---|---|
| `src` | string | yes | A data URI only: `data:image/png;base64,`, `data:image/jpeg;base64,`, or `data:image/webp;base64,` followed by base64 characters. An `http:`, `https:`, `file:`, or blob URL is `SCHEMA_TYPE`; the board never fetches anything. |
| `provenance` | string | yes | `generated` when an image generator made the picture, `supplied` when a person provided it. Any other value is `SCHEMA_ENUM`. |
| `prompt` | string | no | The prompt that produced the picture, kept for review and never printed on the board. |

A shot with `image` draws the picture clipped to the frame as `data-part="panel-image"` with `preserveAspectRatio="xMidYMid slice"`, so it fills the frame without stretching. The mannequins and line art are skipped for that panel, but the movement arrows, the end frame and the subject-move arrows stay and print on top of the picture. The full panel note (camera line, action, dialogue, sound, duration, transition) is unchanged. A shot without `image` keeps the line art.

`style` is a single phrase for the whole document; it reaches only `compilePanelPrompt()` (section 4), never the SVG. Keep it free of lettering instructions that contradict the no-text clause that every prompt ends with.

### 1.8 Minimal document

This block is a complete, valid document. `aspect`, `sensorLongMm`, `panelsPerPage`, `style`, `look`, `image`, `subjects`, `blockingOverride`, and `sound` are omitted here to show their defaults; every other key that the schema requires is present.

```json
{
  "version": 1,
  "title": "부엌의 아침",
  "characters": [
    { "id": "minsu", "name": "민수", "heightM": 1.72 }
  ],
  "scenes": [
    {
      "id": "s1",
      "number": 1,
      "heading": "INT. 부엌 - 아침",
      "props": [
        { "id": "table", "label": "식탁", "x": 0, "z": 1.2, "w": 1.4, "d": 0.8, "h": 0.74 }
      ],
      "blocking": [
        { "character": "minsu", "x": 0, "z": 0, "facingDeg": 0, "pose": "stand" }
      ],
      "axis": null,
      "shots": [
        {
          "id": "10",
          "size": "MS",
          "focus": "minsu",
          "camera": { "yawDeg": 0, "rollDeg": 0, "focalMm": 35 },
          "move": null,
          "subjectMoves": [],
          "action": "민수가 식탁 너머 창밖을 본다.",
          "dialogue": [
            { "speaker": "민수", "line": "오늘은 일찍 나가야 해." }
          ],
          "durationSec": 4,
          "transition": "CUT",
          "crossing": null,
          "intent": "인물과 공간을 한 번에 소개한다."
        }
      ]
    }
  ]
}
```

## 2. Camera values and derived geometry

Everything here is computed by `layoutShot()` and must not be supplied in the document.

### 2.1 Sensor axis and vertical field of view

Parse `aspect` into a ratio (`16:9` → `1.7778`, `9:16` → `0.5625`). Then

```text
sensorAxisMm = ratio >= 1 ? sensorLongMm / ratio : sensorLongMm
vfovDeg      = 2 * atan(sensorAxisMm / (2 * focalMm)) * 180 / PI
```

The long sensor axis is used directly for portrait aspects, because there it is the vertical axis. With the default 35 mm sensor the expected values are:

| `focalMm` | `aspect` | `vfovDeg` |
|---|---|---|
| 50 | `16:9` | 22.28 |
| 24 | `16:9` | 44.60 |
| 50 | `9:16` | 38.58 |
| 50 | `2.39:1` | 16.66 |

### 2.2 Framing box

Framing is expressed as a vertical span of the focus character's height `H`. The framing height is the span's length and the framing centre is its midpoint above the floor.

| `size` | Vertical span | Framing height |
|---|---|---|
| `ECU` | `0.90`–`0.98` × `H` | `0.08H` |
| `CU` | `0.80`–`1.02` × `H` | `0.22H` |
| `MCU` | `0.70`–`1.02` × `H` | `0.32H` |
| `MS` | `0.52`–`1.03` × `H` | `0.51H` |
| `COWBOY` | `0.40`–`1.04` × `H` | `0.64H` |
| `MWS` | `0.28`–`1.05` × `H` | `0.77H` |
| `FS` | `-0.03`–`1.06` × `H` | `1.09H` |
| `WS` | person fills half the frame height | `2H`, centred at `0.5H` |
| `ELS` | person fills a quarter of the frame height | `4H`, centred at `0.5H` |
| `OTS` | focus framed as `MCU` | `0.32H` |

A prop focus uses `1.6 × prop h`, centred at `y + h / 2`, where `y` is the prop's base elevation (`props[].y`, default `0`). With `subjects`, the box is the union of the focus box and every subject box, and the union's midpoint becomes the orbit target's height.

### 2.3 Distance and orbit

```text
d      = distanceM ?? framingHeight / (2 * tan(vfovDeg / 2))
target = (focus x, framing centre height, focus z)
camera = target + d * (sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
```

`rollDeg` rotates the frame about the view axis and changes no position. `distanceM`, when supplied, replaces `d` outright; the subject may then no longer fill the intended size, and no warning is raised.

### 2.4 Pitch and height

`pitchDeg` and `heightM` are two ways to state the same vertical offset, so at most one is accepted.

- With `heightM`: `pitch = asin((heightM - framingCentre) / d)`. If `|heightM - framingCentre| > d` the camera cannot reach that height and the shot fails with `CAMERA_GEOMETRY`.
- With `pitchDeg`: `height = framingCentre + d * sin(pitch)`. A height below `0.05` m fails with `CAMERA_GEOMETRY`; the camera may not go under the floor.
- With neither: `pitch = 0`, and the height follows from the framing distance.

### 2.5 POV and OTS

- `pov`: the camera sits at that character's eye point (`0.94 × heightM`) and looks at the focus framing centre. `pitchDeg`, `heightM`, and `distanceM` are forbidden and are returned as computed values.
- `OTS`: the camera sits `0.35` m behind the `over` character's shoulder and frames the focus as `MCU` whatever `size` says. The lateral offset shrinks so the shoulder stays in frame: `lateral = min(0.35, 0.115 * over.heightM + 0.80 * 0.35 * tanH)` with `tanH = tan(vfovDeg / 2) * aspect`. A fixed `0.35` m lateral offset would push the near shoulder out of frame and lose the over-the-shoulder cue. `pitchDeg`, `heightM`, and `distanceM` are forbidden here too.
- `pov` together with `size: "OTS"` is a `SCHEMA_CONFLICT`.
- The computed body position must be usable: a `pov` or `OTS` camera that resolves below `0.05` m, or closer than `0.2` m to the focus, fails with `CAMERA_GEOMETRY`.

### 2.6 Horizon and ground visibility

- `horizonVisible` is true when `|pitchDeg| < vfovDeg / 2`. Otherwise the horizon is off frame and the panel emits the `HORIZON_OFFFRAME` info entry.
- `groundVisible` is true when at least one line of the focus-centred 6 m × 6 m floor grid (0.5 m spacing) projects inside the frame after clipping. When false, the panel draws no `data-part="ground"` element and relies on the head construction lines and the camera line label.

### 2.7 Names

Names are display labels; the numbers are authoritative.

| `pitchDeg` / height | `angleName` | Korean |
|---|---|---|
| `-5` to `5` | `EYE LEVEL` | 아이레벨 |
| `5` to `75` (exclusive) | `HIGH` | 부감 |
| `-75` to `-5` (exclusive) | `LOW` | 앙각 |
| `75` or more | `OVERHEAD` | 오버헤드 |
| `-75` or less, or `heightM` at or below `0.3` | `WORM'S EYE` | 웜즈아이 |

`WORM'S EYE` overrides `LOW` when the height condition holds.

| Absolute `yawDeg` | `yawName` | Korean |
|---|---|---|
| `0`–`15` | `FRONT` | 정면 |
| `15`–`60` | `3/4` | 3/4 |
| `60`–`120` | `PROFILE` | 측면 |
| `120`–`165` | `3/4 BACK` | 3/4 뒷모습 |
| `165`–`180` | `BACK` | 뒷모습 |

Ranges are inclusive at the upper bound. A non-zero yaw appends ` L` or ` R` from its sign: positive yaw turns the subject toward screen-left, so it reads `3/4 L`.

| `heightM` | `heightName` |
|---|---|
| below `0.3` | `GROUND` |
| below `0.7` | `KNEE` |
| below `1.1` | `HIP` |
| below `1.45` | `SHOULDER` |
| below `1.75` | `EYE` |
| `1.75` and above | `ABOVE` |

## 3. Output layout

Deliver under `.hyper/storyboard-maker/<slug>/`, where `<slug>` is a short kebab-case name for the film.

```text
index.html        # the studio asset with this document embedded
storyboard.json   # the exact document that was rendered
shot-list.md      # Korean shot table for the whole board
manifest.json     # getReport() for this build
```

`index.html` is a copy of `assets/storyboard-studio.html` whose `<script type="application/json" id="storyboard-doc">` element holds the document. Escape every `</` in the JSON text as `<\/` so the embedded object cannot close its own script element; no other escaping is required. The file must open and render with no network access.

`storyboard.json` is written byte-for-byte as rendered, so a later reader can rebuild the same board.

`shot-list.md` is Korean regardless of the document language and holds one row per shot in document order:

| 씬 | 샷 | 크기 | 앵글 | 방위 | 렌즈 | 카메라 높이 | 무브 | 액션 | 대사 | 길이 | 전환 | 비고 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 10 | MS | 아이레벨 0° | 정면 | 35mm | 1.33m (숄더) | STATIC | 민수가 창밖을 본다 | 민수: 오늘은 일찍 나가야 해 | 4s | CUT | — |

`앵글` carries `angleName` and the pitch in degrees, `방위` carries `yawName`, `카메라 높이` carries the computed height and `heightName`, `무브` carries `move.type` plus `endSize` when present, `대사` joins the dialogue lines with ` / `, and `비고` lists the warning codes for that shot plus its `crossing` method and reason. After the table, list every `intentional[]` entry as `SH <id> · <method> · <intentional> · <reason>`.

`manifest.json` is the `getReport()` object, unchanged:

```json
{
  "errors": [],
  "warnings": [],
  "info": [],
  "intentional": [],
  "panels": 6,
  "scenes": 2
}
```

`panels` counts rendered panels and `scenes` counts rendered floor plans. When any error stands both are `0` and `index.html` shows the error status instead of panels.

Every panel `<svg>` tags what it drew, so a check can assert the drawing without reading prose:

| `data-part` | Drawn when | Meaning |
|---|---|---|
| `frame` | always | White frame with the ink border. |
| `panel-image` | the shot has `image` | The picture, clipped to the frame and scaled to fill it. The mannequins, props, ground and horizon are skipped for that panel. |
| `ground` | no picture, and the grid projects inside the frame | The 6 m ground grid. |
| `horizon` | no picture, and the horizon is inside the frame | The horizon line. |
| `head`, `hair`, `face`, `chest` | no picture | Mannequin markers; `hair` appears only from behind, `chest` only when the torso front faces the camera. |
| `foreground` | no picture, on an `OTS` shot | The over-the-shoulder character, clipped to the frame. |
| `end-frame`, `end-frame-group` | a `PUSH IN`, `ZOOM IN`, `DOLLY IN`, `PULL OUT`, `ZOOM OUT`, or `DOLLY OUT` move | The dashed end frame and its corner arrows. Prints over a picture too. |
| `subject-move` | a `subjectMoves` entry | The ground arrow and label for a character move. Prints over a picture too. |
| `guide-frame` | `renderGuideSvg()` only | The outer border of the composition guide. |

## 4. Renderer API

`StoryboardCore` lives in `<script id="storyboard-core">` and runs without a DOM. Every function is pure: the same document returns the same string, and no function reads the clock, the network, or global state.

| Function | Signature | Returns |
|---|---|---|
| `validate` | `validate(doc)` | `{ errors: Issue[], info: Issue[] }` |
| `lint` | `lint(doc)` | `{ warnings: Issue[], info: Issue[], intentional: IntentionalEntry[] }` |
| `layoutShot` | `layoutShot(doc, sceneId, shotId)` | the layout object below, or `null` when the ids do not resolve |
| `renderPanelSvg` | `renderPanelSvg(doc, sceneId, shotId)` | one `<svg>` string, or `""` when the ids do not resolve |
| `compilePanelPrompt` | `compilePanelPrompt(doc, sceneId, shotId)` | one English prompt string, or `""` when the ids do not resolve |
| `compileFloorPlanPrompt` | `compileFloorPlanPrompt(doc, sceneId)` | one English top-down floor-plan prompt string (props and characters with plan positions and facing, `+z` toward the top), or `""` when the scene does not resolve |
| `renderGuideSvg` | `renderGuideSvg(doc, sceneId, shotId)` | one grey guide `<svg>` string, or `""` when the ids do not resolve |
| `renderFloorPlanSvg` | `renderFloorPlanSvg(doc, sceneId)` | one `<svg>` string, or `""` when the scene does not resolve |
| `render` | `render(doc)` | the board markup as one HTML string (scene sections, pages, panels, floor plans; no `<html>` wrapper), or `""` when `validate()` returns any error. It never returns the report: read `errors` from `validate()` and `warnings`, `info`, and `intentional` from `lint()`. |
| `vfovDeg` | `vfovDeg(focalMm, aspect, sensorLongMm)` | the vertical field of view in degrees |

An `Issue` is `{ "code": string, "message": string, "path": string }`, where `path` is a dotted/indexed location such as `scenes[0].shots[2].camera.focalMm`. An `IntentionalEntry` is `{ "shot": string, "method": string, "intentional": boolean, "reason": string }`.

`layoutShot()` returns:

| Field | Type | Meaning |
|---|---|---|
| `cameraPos` | `{ x, y, z }` | Camera position in scene metres. |
| `target` | `{ x, y, z }` | Orbit target in scene metres. |
| `pitchDeg` | number | Effective pitch, including a pitch derived from `heightM` or from `pov`/`OTS`. |
| `heightM` | number | Effective camera height. |
| `distanceM` | number | Effective distance from `target`. |
| `vfovDeg` | number | Vertical field of view for the shot's lens. |
| `horizonVisible` | boolean | Whether the horizon line falls inside the frame. |
| `groundVisible` | boolean | Whether any of the 6 m grid projects inside the frame. |
| `facingScreen` | `"left"`, `"right"`, or `"center"` | Where the focus's nose points on screen: the sign of `yawDeg`, or `center` when the nose points nearly straight at or away from the camera (magnitude of `sin(yawDeg)` below `0.1`) and when the focus is a prop. |
| `angleName` | string | Angle label from 2.7. |
| `yawName` | string | Azimuth label from 2.7. |
| `heightName` | string | Height label from 2.7. |

Input and computed values are separate:

| Field | Accepted as input | Returned by `layoutShot()` |
|---|---|---|
| `pitchDeg` | yes, unless `heightM`, `pov`, or `OTS` applies | always |
| `heightM` | yes, unless `pitchDeg`, `pov`, or `OTS` applies | always |
| `distanceM` | yes, unless `pov` or `OTS` applies | always |
| `cameraPos`, `target`, `vfovDeg` | never | always |
| `horizonVisible`, `groundVisible`, `facingScreen` | never | always |
| `angleName`, `yawName`, `heightName` | never | always |

`compilePanelPrompt()` reads the same projection that draws the panel, so one prompt and one panel never disagree. The string, in this order, holds the shot size in English, the yaw view when the focus is a character — `front view, subject faces the camera`, `three-quarter view`, `profile view (side view)`, `three-quarter back view, face mostly hidden`, or `back view, subject's face not visible`, with `, subject facing screen-left` or `, subject facing screen-right` appended to the three-quarter and profile views — the framing clause for a character focus, one per shot size from `FRAME_RANGES` (`framed from mid-chest to just above the head, small headroom, top of the head fully inside the frame` for `MCU`, `full figures head to feet with floor visible` for `WS`, `over the near character's shoulder` for `OTS`) — the angle name with the absolute pitch (for example `low angle 12°`), the lens in millimetres, the camera height name with metres, `dutch angle, horizon tilted 8° to the right` (or `to the left`) whenever `rollDeg` is not zero, a positive `rollDeg` tilting the drawn horizon to the right, `N characters in frame` with each framed character's `look` when two or more characters are framed (`Characters:` when there is one), the `Blocking:` sentence that puts every framed figure on its projected side (`on screen-left`, `at the centre of frame`, `on screen-right`) with its blocking pose (`standing`, `walking`, `sitting`, `reaching`, `crouching`) and its facing against the camera (`facing screen-left`, `facing screen-right`, `facing the camera`, `facing away from the camera`), the action text as written, the props whose centre projects inside the frame, and finally `doc.style`. A prop focus has no view, framing, or facing clause. It never copies `dialogue` and it always ends by asking for no text, letters, numbers, captions, or speech bubbles, because lettering is added in the board, not in the picture. Same document, same string.

`renderGuideSvg()` returns a plain grey-on-white composition reference for the inspector: the same camera projection with mannequins, the ground grid, and the horizon, and nothing else — no arrows, no labels, no props, no notes. Its `viewBox` is `0 0 1600 900` at the default `16:9` and follows the document's aspect ratio otherwise. View it beside the returned picture during inspection; never rasterize it and never attach it, because panel pictures are generated with no reference image of any kind.

`image`, `image.src`, `image.provenance`, `image.prompt`, `style`, and `characters[].look` are input only; no function computes them. `compilePanelPrompt()` and `renderGuideSvg()` outputs are derived and never written back into the document.

`window.storyboardStudio` is the DOM-facing wrapper. It is what a QA pass calls in a browser.

| Call | Returns | Behaviour |
|---|---|---|
| `load(doc)` | the report object | Validates, renders, and replaces the current board. |
| `getReport()` | `{ errors, warnings, info, intentional, panels, scenes }` | Reads the current state without re-rendering. |
| `render()` | the report object | Re-renders the current document, used by the editor button. |

`window.storyboardStudio.render()` is the page wrapper, not core `render(doc)`: the markup goes into the page and the call returns the report object.

On load, a non-empty `storyboard-doc` element is rendered immediately. An empty element switches the page to a JSON paste editor with a render button. Any error resolves to zero panels, a `#status[data-error="true"]` state, and the error list; warnings never block rendering and appear as panel badges plus a summary above the board.

## 5. Codes and suppression

Errors stop the build: no panel is rendered while one stands.

| Code | Raised when |
|---|---|
| `SCHEMA_REQUIRED` | A required key is missing, a key that the schema does not declare nullable is `null`, or `size` is `OTS` without `camera.over`. |
| `SCHEMA_TYPE` | A value has the wrong JSON type, `camera.over` appears with a size other than `OTS`, or `image.src` is not a base64 `data:image/png`, `data:image/jpeg`, or `data:image/webp` URI. |
| `SCHEMA_ENUM` | `size`, `pose`, `move.type`, `transition`, `crossing.method`, or `image.provenance` is outside its enumeration. |
| `SCHEMA_RANGE` | A number falls outside its allowed range: `pitchDeg`, `heightM`, `yawDeg`, `rollDeg`, `focalMm`, `durationSec`, `panelsPerPage`. |
| `SCHEMA_DUPLICATE` | A character id, scene id, prop id, or shot id repeats inside its scope. |
| `SCHEMA_REFERENCE` | `focus`, a `subjects` entry, `blocking.character`, `axis`, `subjectMoves.character`, `pov`, or `over` names an id that does not exist. |
| `SCHEMA_CONFLICT` | `pitchDeg` and `heightM` together; `pov` with `pitchDeg`, `heightM`, or `distanceM`; `OTS` with any of those three; `pov` with `size: "OTS"`. |
| `CAMERA_GEOMETRY` | `heightM` is farther from the framing centre than `d`; a height derived from `pitchDeg` falls below `0.05` m; a `pov` or `OTS` camera resolves below `0.05` m; or a `pov` or `OTS` camera resolves closer than `0.2` m to the focus. |

Warnings never block and are printed as badges on the affected panel.

| Code | Raised when | Suppressed by |
|---|---|---|
| `AXIS_CROSSED` | Two consecutive shots in a scene sit on opposite sides of `axis`. | `crossing` on the later shot. |
| `EYELINE_MISMATCH` | Two consecutive solo shots frame the two characters of `axis` separately and both report the same `facingScreen`. | `crossing` on the later shot. |
| `JUMP_CUT` | Two consecutive shots share the same `focus` and `size` and their azimuth around the focus differs by less than 30°. | Nothing; change the angle or size. |
| `SCREEN_DIRECTION_FLIP` | The same character's `subjectMoves` screen-x direction reverses between consecutive cuts. | `crossing` on the later shot. |
| `PRIMARY_MOVE_OVERLOAD` | A shot carries more than one primary move: the camera move counts when `primary` is true, and every primary `subjectMove` counts. | Nothing; split or demote a move. |
| `WIDE_LENS_FACE` | `focalMm` is `18` or less and `size` is `ECU` or `CU`. | Nothing; change the lens or the size. |

| Code | Kind | Raised when |
|---|---|---|
| `HORIZON_OFFFRAME` | info | The absolute pitch is at or above `vfovDeg / 2`, so no horizon line is drawn. |

Suppression is per cut and only applies to the three line-related warnings. `crossing` never silences `JUMP_CUT`, `PRIMARY_MOVE_OVERLOAD`, `WIDE_LENS_FACE`, or any error. Every shot with `crossing` appears once in `intentional[]` as `{ shot, method, intentional, reason }`, including the bridging shots that are not deliberate violations; read `intentional` to tell them apart.

## 6. Running the core without a browser

Extract the core script and call it with any Node-compatible JavaScript runtime, with no browser. Both commands resolve the renderer from the installed skill directory, the folder that holds `SKILL.md`, so no repository checkout is involved: set `SKILL_DIR` to that folder and run the command from the project folder, where `.hyper/storyboard-maker/<slug>/` holds the delivered document. Without `SKILL_DIR` the asset is read from the current directory instead.

```bash
SKILL_DIR=/path/to/installed/storyboard-maker node -e '
const fs = require("fs"), path = require("path"), vm = require("vm");
const dir = process.env.SKILL_DIR || ".";
const html = fs.readFileSync(path.join(dir, "assets/storyboard-studio.html"), "utf8");
const m = html.match(/<script[^>]*id="storyboard-core"[^>]*>([\s\S]*?)<\/script>/);
if (!m) throw new Error("storyboard-core script not found");
const ctx = vm.createContext({});
vm.runInContext(m[1] + "\n;globalThis.StoryboardCore = StoryboardCore;", ctx);
const doc = JSON.parse(fs.readFileSync(".hyper/storyboard-maker/my-film/storyboard.json", "utf8"));
const core = ctx.StoryboardCore;
console.log(JSON.stringify({ validate: core.validate(doc), lint: core.lint(doc) }, null, 2));
console.log("svg elements:", (core.render(doc).match(/<svg/g) || []).length);
'
```

`bun -e` does the same without `vm`:

```bash
SKILL_DIR=/path/to/installed/storyboard-maker bun -e '
const path = require("path");
const dir = process.env.SKILL_DIR || ".";
const html = await Bun.file(path.join(dir, "assets/storyboard-studio.html")).text();
const src = html.match(/<script[^>]*id="storyboard-core"[^>]*>([\s\S]*?)<\/script>/)[1];
const core = new Function(src + "\nreturn StoryboardCore;")();
const doc = JSON.parse(await Bun.file(".hyper/storyboard-maker/my-film/storyboard.json").text());
console.log(JSON.stringify({ errors: core.validate(doc).errors, warnings: core.lint(doc).warnings }, null, 2));
'
```

Both print the report as JSON and exit non-zero only on a thrown exception, not on a document with errors — read `errors` and `warnings` from the output. `render()` returns empty markup while an error stands, so a zero SVG count means the document has errors, not that the renderer is missing. Point the reader at the delivered `storyboard.json`, not at `index.html`, because the injected copy carries the `<\/` escapes.

## Sources

> Checked 2026-11-03.

| Claim | Source |
|---|---|
| Vertical field of view is `2·atan(H / 2f)`, and a shorter focal length widens it | [Understanding Focal Length and Field of View, Edmund Optics](https://www.edmundoptics.com/knowledge-center/application-notes/imaging/understanding-focal-length-and-field-of-view/) |
| Camera `fov` is the vertical field of view, and the film gauge is measured on the long axis | [PerspectiveCamera, three.js](https://threejs.org/docs/pages/PerspectiveCamera.html) |
| Crossing the 180° line reverses the apparent positions of the players | [180-Degree Rule, Columbia Film Language Glossary](https://filmglossary.ccnmtl.columbia.edu/term/180-degree-rule/) |
| Successive shots of the same subject need at least 30° of angular change or they read as a jump cut | [30-degree rule, Wikipedia](https://en.wikipedia.org/wiki/30-degree_rule) |
| Arrow-style movement labels such as `PAN L` and `PUSH IN` are the conventional vocabulary | [Storyboard Arrows, StoryboardArt](https://storyboardart.org/storyboard-tutorials/storyboard-arrows/) |
| A4 landscape printing is expressed with `@page { size: …; margin: … }` | [@page, MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@page) |

This file documents this package's own renderer asset.
