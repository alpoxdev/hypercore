# Camera And Framing

> Korean version: [`camera-and-framing.ko.md`](camera-and-framing.ko.md)

Read before assigning camera values to a shot. This file owns the five camera values, the relation between a pitch input and a height input, the shot-size framing ranges, the display-name thresholds, the focal-length field of view table, the horizon rule, and the face-exaggeration table. The renderer implements these numbers; this file explains where each number comes from and which ones are this package's assumptions.

## Contents

- [1. Five camera values](#1-five-camera-values)
- [2. Pitch, height, and camera geometry](#2-pitch-height-and-camera-geometry)
- [3. Shot size and framing range](#3-shot-size-and-framing-range)
- [4. Angle, direction, and height names](#4-angle-direction-and-height-names)
- [5. Focal length and vertical field of view](#5-focal-length-and-vertical-field-of-view)
- [6. The horizon rule](#6-the-horizon-rule)
- [7. Face exaggeration follows distance](#7-face-exaggeration-follows-distance)
- [8. Over-the-shoulder and point of view](#8-over-the-shoulder-and-point-of-view)
- [9. Korean terms](#9-korean-terms)
- [10. Input limits and error codes](#10-input-limits-and-error-codes)

## 1. Five camera values

A shot's camera is five independent numbers. Names such as low angle or close-up are labels printed from these numbers; they are never inputs.

| Value | Field | Range | What it changes in the drawing |
|---|---|---|---|
| Height | `camera.heightM` | 0.05–50 m | Where the horizon and the floor grid sit against the figure. |
| Pitch | `camera.pitchDeg` | -90–90 | How much of the crown or the chin the frame shows. Positive looks down from above the framing centre; negative looks up from below. |
| Direction | `camera.yawDeg` | -180–180 | Which side of the head is visible and which way the figure looks on screen. |
| Roll | `camera.rollDeg` | -45–45 | Tilt of the frame's horizon. Nonzero values print `DUTCH <n>°`. |
| Lens and size | `camera.focalMm`, `size` | 10–300 mm, size enum | How much of the body the frame holds and how strongly the nearest surfaces are exaggerated. |

Height and pitch are separate values for a reason: practitioners list ground, knee, hip, shoulder, and eye heights as one axis and high, eye, and low angles as another. A low camera can still look straight ahead, and a camera at eye height can tilt down.

## 2. Pitch, height, and camera geometry

The camera orbits the centre of the framing box. The framing height comes from the shot size ([section 3](#3-shot-size-and-framing-range)), and the distance is fixed first:

- `distanceM` wins when it is given.
- Otherwise `d = framingHeight / (2·tan(vfov/2))`, with `vfov` from [section 5](#5-focal-length-and-vertical-field-of-view).

Exactly one of `pitchDeg` and `heightM` may be given:

| Input | Derived value |
|---|---|
| `pitchDeg` only | `heightM = centre + d·sin(pitchDeg)` |
| `heightM` only | `pitchDeg = asin((heightM − centre) / d)` |
| Neither | `pitchDeg = 0` and `heightM = centre` |
| Both | Rejected with `SCHEMA_CONFLICT`; the two would over-determine the camera. |

`centre` is the midpoint of the framing range in metres. Two geometric limits follow:

- A computed `heightM` below 0.05 m is rejected with `CAMERA_GEOMETRY`. The camera may not sit under the floor.
- `|heightM − centre| > d` is rejected with `CAMERA_GEOMETRY`, because `asin` has no solution: the requested height lies outside the circle the camera can orbit at that distance.

Worked example, full shot at 50 mm on 16:9 with a 1.70 m character:

| Step | Value |
|---|---|
| Framing range (-0.03–1.06 H) | 1.853 m tall |
| Framing centre | 0.876 m |
| Vertical field of view | 22.28° |
| Distance | 1.853 / (2·tan 11.14°) = 4.71 m |
| `pitchDeg: -20` | height = 0.876 + 4.71·sin(-20°) = -0.73 m, rejected with `CAMERA_GEOMETRY` |
| `heightM: 0.40` | pitch = asin((0.40 − 0.876) / 4.71) = -5.80°, accepted |

The renderer returns `pitchDeg`, `heightM`, and `distanceM` in `layoutShot()` whichever way they were entered. Derived values are outputs, not inputs.

## 3. Shot size and framing range

`H` is the focused character's height, default 1.70 m. A shot size is a vertical range in units of `H`; that range is projected to fill the frame height, and the distance follows from it.

| Size | Vertical range (× H) | Frame holds |
|---|---|---|
| `ECU` | 0.90–0.98 | Eyes and mouth detail. |
| `CU` | 0.80–1.02 | Head and neck. |
| `MCU` | 0.70–1.02 | Chest up. |
| `MS` | 0.52–1.03 | Waist up. |
| `COWBOY` | 0.40–1.04 | Mid-thigh up. |
| `MWS` | 0.28–1.05 | Knees up. |
| `FS` | -0.03–1.06 | Full figure with a little floor and headroom. |
| `WS` | figure spans half the frame height | Wide shot; distance is solved from that fraction. |
| `ELS` | figure spans a quarter of the frame height | Extreme wide shot. |
| `OTS` | focus framed at `MCU` | Over-the-shoulder; the `over` character's shoulder sits in the foreground. |

Ranges exist because sources disagree at the edges: a medium shot reaches the hips in one guide and the waist in another, and the medium wide stops above the knee while the cowboy shot reaches mid-thigh. The range keeps both readings instead of quoting one boundary as a standard.

Two overriding rules:

- A prop focus uses the prop's height × 1.6 as the framing height. When `subjects[]` adds characters, the framing range is the union of the prop box and the character ranges.
- With two or more subjects the range is the union of every subject's range, so a two-shot at `MS` frames both bodies from the waist up and gets wider than a single `MS`.

## 4. Angle, direction, and height names

Names are printed on the panel and never parsed back. The thresholds below are **ASSUMED** for this package: they are chosen for consistent labels, not taken from a standard.

| Pitch | Name | Korean |
|---|---|---|
| -5 ≤ pitch ≤ 5 | `EYE LEVEL` | 아이레벨 |
| 5 < pitch < 75 | `HIGH` | 부감 |
| -75 < pitch < -5 | `LOW` | 앙각 |
| pitch ≥ 75 | `OVERHEAD` | 오버헤드 |
| pitch ≤ -75, or camera height ≤ 0.3 m | `WORM'S EYE` | 웜즈아이 |

| Absolute yaw | Name | Korean |
|---|---|---|
| ≤ 15 | `FRONT` | 정면 |
| 15 < yaw < 60 | `3/4` | 3/4 |
| 60 ≤ yaw ≤ 120 | `PROFILE` | 측면 |
| 120 < yaw < 165 | `3/4 BACK` | 3/4 뒷모습 |
| ≥ 165 | `BACK` | 뒷모습 |

The direction name takes an `L` or `R` suffix from the sign of `yawDeg`; the number stays authoritative because a mirrored naming convention is equally valid.

| Camera height | Name |
|---|---|
| < 0.3 m | `GROUND` |
| < 0.7 m | `KNEE` |
| < 1.1 m | `HIP` |
| < 1.45 m | `SHOULDER` |
| < 1.75 m | `EYE` |
| ≥ 1.75 m | `ABOVE` |

Numeric angle conventions are not standardized, and the difference is large: one widely read guide puts the overhead at 90° and calls anything less a high angle, while the open-source storyboard application Storyboarder sets its bird's-eye preset at 30°, high at 15°, low at 30°, and worm's eye at 45°. Three-quarter ranges move the same way: 30–45° in a drawing guide, front split at ±55° in that same application. The package thresholds are a labelling choice; the numeric values decide the drawing.

## 5. Focal length and vertical field of view

The renderer projects with the vertical field of view:

```
sensorAxisMm = aspect >= 1 ? sensorLongMm / aspect : sensorLongMm
vfovDeg      = 2 · atan(sensorAxisMm / (2 · focalMm)) · 180 / π
```

`sensorLongMm` defaults to 35 mm and is the long axis of the frame, so a landscape frame uses a shorter sensor axis than a portrait frame. The 35 mm figure matches the default `filmGauge` of a standard perspective camera model; it is not the 36 mm width of a full-frame stills sensor.

| Focal | 16:9 | 9:16 | 2.39:1 |
|---|---|---|---|
| 18 mm | 57.35° | 88.39° | 44.27° |
| 24 mm | 44.60° | 72.20° | 33.93° |
| 35 mm | 31.42° | 53.13° | 23.63° |
| 50 mm | 22.28° | 38.58° | 16.66° |
| 85 mm | 13.21° | 23.27° | 9.85° |
| 135 mm | 8.34° | 14.77° | 6.21° |

The 9:16 column equals the 16:9 horizontal field of view at the same focal length, because the long axis turns vertical. Horizontal field of view in 16:9 runs 88.39°, 72.20°, 53.13°, 38.58°, 23.27°, and 14.77° for the same six lenses.

Real cinema sensors are narrower than 35 mm across (Super 35 is about 24.9 mm), so the same lens gives a different angle on a real camera. `sensorLongMm` exists so the table can be rebuilt for another sensor instead of assuming one.

## 6. The horizon rule

The horizon line sits at the camera's height and stays level. For a target at frame centre, its offset from the frame centre in half-frame-height units is:

```
horizonOffset = tan(pitch) / tan(vfov / 2)
```

The horizon is inside the frame only while `|pitch| < vfov / 2`. At 50 mm on 16:9 the limit is 11.14°; a 15° tilt puts the horizon 1.36 half-frame heights from centre (0.68 frame heights) and off screen. The same absolute pitch keeps the horizon visible on a wide lens (limit 28.68° at 18 mm) and loses it on a long one (6.60° at 85 mm).

- Camera at the subject's eye height: the horizon crosses the eyes.
- Camera above the subject: the horizon rises above the head.
- Camera below: it drops below the chest.

When the horizon leaves the frame the renderer stops drawing `data-part="horizon"`, reports `HORIZON_OFFFRAME`, and shows the angle through the floor grid and the convergence of vertical lines. A close-up with no floor in frame has neither cue, so its camera line label and the curvature of the head construction lines carry the angle.

## 7. Face exaggeration follows distance

To fill the frame with a 0.30 m head, each lens needs its own distance. The distance follows from the same field of view formula:

| Focal | Vertical FOV (16:9) | Distance for a 0.30 m head | Nose enlargement over ear |
|---|---|---|---|
| 18 mm | 57.35° | 0.27 m | +57.4% |
| 24 mm | 44.60° | 0.37 m | +37.6% |
| 35 mm | 31.42° | 0.53 m | +23.1% |
| 50 mm | 22.28° | 0.76 m | +15.1% |
| 85 mm | 13.21° | 1.30 m | +8.4% |
| 135 mm | 8.34° | 2.06 m | +5.1% |

Method: `distance = 0.30 / (2·tan(vfov/2))` and `magnification = distance / (distance − 0.10)`. The 0.10 m face depth is **ASSUMED**; the ordering between lenses does not depend on it, while the absolute percentages do.

The decisive check is the same-distance test: at one metre, a 24 mm and an 85 mm lens produce an identical nose-to-ear ratio of 1.1111. Perspective comes from distance, not from the lens. A wide lens exaggerates because filling the frame forces the camera close to the face; a long lens compresses because the camera works from far away. That is why a 18 mm close-up reads as caricature and a 135 mm close-up reads as flat.

The renderer warns with `WIDE_LENS_FACE` when `focalMm ≤ 18` meets `ECU` or `CU`. A wider lens on a wider shot is not warned: the camera is farther away and the distortion is mild.

## 8. Over-the-shoulder and point of view

Both shots derive the camera position from a character instead of from height and pitch.

- **POV** (`camera.pov` = character id): the camera sits at that character's eye position and aims at the focus. The lens still sets the field of view; height, pitch, and distance are fixed by the body.
- **OTS** (`size: "OTS"`, `camera.over` = character id): the camera sits behind and 0.35 m to the side of the `over` character's shoulder and frames the focus at `MCU`. The near character's shoulder fills the foreground, and the back of the head stays outside the frame. The 0.35 m offset is this package's default (**ASSUMED**); another implementation uses 0.5 m.

Input rules for both:

- `over` is required when `size` is `OTS` (`SCHEMA_REQUIRED`) and rejected for any other size (`SCHEMA_TYPE`).
- `pitchDeg`, `heightM`, and `distanceM` are rejected with `SCHEMA_CONFLICT`, because the body position fixes all three.
- `layoutShot()` still returns `pitchDeg`, `heightM`, and `distanceM` for these shots. They are computed from the character's eye position, the framing, and the lens, so they belong in the label but never in the input.

An over-the-shoulder shot with no visible foreground shoulder is just a dirty single from an odd angle; draw the shoulder large and soft at the frame edge so the audience reads whose eyes they are behind.

## 9. Korean terms

| English | Korean | Meaning |
|---|---|---|
| `EYE LEVEL`, eye level | 아이레벨 | Camera at the subject's eye height. |
| `LOW`, low angle | 앙각 | Camera below the subject, looking up. |
| `HIGH`, high angle | 부감 | Camera above the subject, looking down. |
| `DUTCH`, canted angle | 사각, 사각앵글 | Frame tilted off level; the horizon slopes. |
| `OVERHEAD` | 오버헤드 | Straight down; no horizon in frame. |
| `WORM'S EYE` | 웜즈아이 | Camera at ground level looking up. |
| `3/4` | 3/4 | Between front and profile. |
| `PROFILE` | 측면 | Side view, about 90°. |

Panel labels print the English name and the Korean term together, for example `LOW 15°(앙각)`, because the Korean term alone does not say how far below the eye the camera is.

## 10. Input limits and error codes

| Field | Limit | Code when violated |
|---|---|---|
| `camera.pitchDeg` | -90 to 90 | `SCHEMA_RANGE` |
| `camera.heightM` | 0.05 to 50 | `SCHEMA_RANGE` |
| `camera.yawDeg` | -180 to 180 | `SCHEMA_RANGE` |
| `camera.rollDeg` | -45 to 45 | `SCHEMA_RANGE` |
| `camera.focalMm` | 10 to 300 | `SCHEMA_RANGE` |

- `pitchDeg` and `heightM` together: `SCHEMA_CONFLICT`.
- `pitchDeg`, `heightM`, or `distanceM` with `pov` or `OTS`: `SCHEMA_CONFLICT`.
- `heightM` below `0.05` after derivation, `|heightM − centre| > distance`, a `pov` or `OTS` camera below `0.05` m, or a `pov` or `OTS` camera closer than `0.2` m to the focus: `CAMERA_GEOMETRY`.
- A camera derived below the floor is not clamped to the floor. Clamping would change the angle the user asked for, so the shot fails and the value must be corrected.

## Sources

> Checked 2026-11-03.

| Claim | Source |
|---|---|
| Camera angle is the camera's position relative to the subject; high angle is above eye level, low angle below; reading an angle's effect as a fixed metaphor is inaccurate | <https://filmglossary.ccnmtl.columbia.edu/term/camera-angle/> |
| Ground, knee, hip, shoulder, and eye heights are listed separately from high, eye, and low angles; overhead is shot from 90° and anything less is a high angle | <https://www.studiobinder.com/blog/types-of-camera-shot-angles-in-film/> |
| Overhead looks straight down so no horizon line is visible; shot boundaries include medium shot to the hips and cowboy to mid-thigh | <https://storyboardart.org/storyboard-tutorials/camera-angles-for-storyboard-artists/> |
| Medium wide stops above the knee, medium shot above the waist, medium close-up above the chest | <https://www.studiobinder.com/blog/types-of-camera-shots-sizes-in-film/> |
| Field of view is `2·atan(sensor size / (2·focal length))`; a short focal length gives a wide angle | <https://www.edmundoptics.com/knowledge-center/application-notes/imaging/understanding-focal-length-and-field-of-view/> |
| A perspective camera's `fov` is the vertical field of view in degrees and its default film gauge is 35 mm on the long axis | <https://threejs.org/docs/pages/PerspectiveCamera.html> |
| Linear perspective changes come from distance, not from the lens itself | <https://en.wikipedia.org/wiki/Perspective_distortion> |
| The horizon line is the viewer's actual eye height and is always level | <https://courses.byui.edu/art110_new/art110/week01/eye_level.html> |
| Korean terms: eye level 아이레벨, low angle 앙각, high angle 부감, canted angle 사각앵글 | <https://www.mc-plus.net/news/articleView.html?idxno=5590> |
| A storyboard application's camera presets: bird's-eye 30°, high 15°, low 30°, worm's eye 45°, front ±55°, roll 5–35° | <https://github.com/wonderunit/storyboarder> |
