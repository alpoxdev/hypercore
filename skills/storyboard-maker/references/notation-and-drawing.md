# Notation and Drawing

> Korean version: [`notation-and-drawing.ko.md`](notation-and-drawing.ko.md)

Read before drawing a panel or writing a camera move into the document. This file owns arrow meaning, label vocabulary, where arrows sit, line hierarchy, panel note format, shot numbering, mannequin construction, and the readability tests a panel must pass before delivery.

## Contents

- [1. Every arrow answers four questions](#1-every-arrow-answers-four-questions)
- [2. Label vocabulary](#2-label-vocabulary)
- [3. Where arrows live](#3-where-arrows-live)
- [4. Frame-in-frame moves](#4-frame-in-frame-moves)
- [5. Compound and secondary moves](#5-compound-and-secondary-moves)
- [6. Line hierarchy](#6-line-hierarchy)
- [7. Panel notes and shot numbering](#7-panel-notes-and-shot-numbering)
- [8. Entrance, exit, hold, and transitions](#8-entrance-exit-hold-and-transitions)
- [9. Mannequin construction](#9-mannequin-construction)
- [10. Readability tests](#10-readability-tests)
- [11. Common mistakes](#11-common-mistakes)

## 1. Every arrow answers four questions

An arrow without all four answers is decoration, not a shooting instruction. Ask the four questions in order and write the answer into the label or into the geometry of the arrow.

1. **What moves?** The camera, or a subject inside the frame. A camera move and a character walk use different arrows in different places, and mixing them makes the panel unreadable.
2. **Which way?** Screen left, screen right, up, down, toward camera, or away. Camera moves use the camera's own direction; subject moves use the subject's direction, projected onto the ground.
3. **How far?** The end state, not just the direction: the end frame size for a push, pull, or zoom; the end position for a pan, truck, or pedestal; the end angle for a tilt or roll. `move.endSize` is required for the IN and OUT families.
4. **When?** When the move starts and ends relative to the action and the cut, and whether speed is constant or eased. An unqualified arrow reads as a constant move across the whole shot.

## 2. Label vocabulary

Every arrow carries a label. The table below is the full label vocabulary. The camera-move names accepted in `move.type` are `STATIC`, `PAN L`, `PAN R`, `TILT UP`, `TILT DOWN`, `PUSH IN`, `PULL OUT`, `ZOOM IN`, `ZOOM OUT`, `DOLLY IN`, `DOLLY OUT`, `TRUCK L`, `TRUCK R`, `PED UP`, `PED DOWN`, `CRANE UP`, `CRANE DOWN`, `ROLL L`, `ROLL R`, and `HANDHELD`; write them exactly, in capitals. `CHAR` and `OBJ` are subject-move labels written in `subjectMoves[].label`, not `move.type` values; prop movement is described in that label text or in the action note.

| Label | What moves | Arrow shape and placement |
|---|---|---|
| `PAN L` / `PAN R` | Camera pivots horizontally in place | Horizontal arrow below the frame, pointing left or right |
| `TILT UP` / `TILT DOWN` | Camera pivots vertically in place | Vertical arrow beside the frame |
| `PUSH IN` / `PULL OUT` | Camera body moves toward or away from the subject | Frame-in-frame with corner arrows |
| `ZOOM IN` / `ZOOM OUT` | Lens focal length changes; camera body stays put | Frame-in-frame with corner arrows, label is the only difference |
| `DOLLY IN` / `DOLLY OUT` | Camera body moves on a track or wheels | Frame-in-frame; label says the platform moved |
| `TRUCK L` / `TRUCK R` | Camera body moves sideways, parallel to the subject | Horizontal arrow below the frame |
| `PED UP` / `PED DOWN` | Camera body rises or lowers on a pedestal | Vertical arrow beside the frame |
| `CRANE UP` / `CRANE DOWN` | Camera arcs up or down on a crane arm | Curved vertical arrow beside the frame |
| `ROLL L` / `ROLL R` | Camera rotates around the lens axis | Curved arrow around the frame corner |
| `HANDHELD` | No controlled path | Label only; no arrow |
| `CHAR` | A named character moves | Solid arrow on the floor at the character's feet, pointing to the end position |
| `OBJ` | A prop or object moves | Arrow on the prop, pointing to the end position |

`STATIC` takes no arrow at all. A hand-held shot takes a label and nothing else because its path is not predictable enough to draw honestly.

`CHAR` and `OBJ` arrows follow the subject. They are not camera arrows and never sit outside the frame.

## 3. Where arrows live

Camera arrows sit outside the frame border or on its edge. The frame is the image the audience sees, and a camera arrow drawn inside it is easily mistaken for subject movement.

Subject arrows sit on the subject or immediately beside it, projected onto the floor when the move is a walk. A `CHAR` arrow starts at the feet, not at the head.

Keep every arrow off faces and hands. A line across a face destroys the one thing a small panel must communicate, and a line across the hands hides the action. When a camera arrow would cross a face, leave the frame border and re-enter on the other side instead of cutting through the head.

An arrow that would need to cross a face to be accurate is a sign that the panel is carrying too much. Split the panel or move the camera position in the document.

## 4. Frame-in-frame moves

Push, pull, dolly, and zoom are drawn as a frame inside the frame. The inner rectangle is the end frame, drawn dashed. Corner arrows point inward for the IN family and outward for the OUT family.

The inner rectangle stops where it meets a character silhouette instead of running through the body or the face. On a close shot, shorten the corner arrows to the outer margin and let the dashed rectangle sit beside the head, not across it.

`PUSH IN` and `ZOOM IN` share the same symbol, so the label carries the whole distinction:

- A push moves the camera through space. Foreground grows faster than background, and background lines converge more at the end frame.
- A zoom changes only the lens. The perspective relationship stays the same; background objects scale together with the subject.

Where the panel has room, hint the difference: draw a background edge converging into the inner frame for a push, and keep background edges parallel to the outer frame for a zoom. Never rely on the picture alone; the label is mandatory.

## 5. Compound and secondary moves

A move that combines two axes is drawn as an L-shaped arrow: one leg per axis, one label per leg. A pan that also tilts up is a horizontal leg plus a vertical leg, each labelled separately. Do not write a combined invented label such as `PAN TILT`; the document has no such enum value.

One panel carries one primary move, drawn thick. A second, smaller correction may be drawn thin: a slight pan during a dolly, a small tilt at the end of a crane move. The primary arrow is the move the director must execute; the thin arrow is a note on top of it.

Three simultaneous moves of the same weight mean the panel is overloaded. Split it into two panels. The validator reports `PRIMARY_MOVE_OVERLOAD` when more than one move is marked primary in a shot.

## 6. Line hierarchy

Stroke weight separates the frame from the drawing and the drawing from the notation. The values below are this package's house style for a 1600-wide `viewBox`; they are chosen for A4 landscape print, not copied from an external standard.

| Element | Width | Colour | Note |
|---|---|---|---|
| Frame border | 3 | `#111111` | Outer frame and panel edge; never jittered |
| Character outline | 2.5 | `#111111` | Body, head, limbs after hidden-line removal |
| Primary camera arrow | 2.5 | `#c0392b` | Exactly one per panel |
| Prop outline | 1.5 | `#111111` | Tables, doors, furniture |
| Secondary arrow | 1.5 | `#c0392b` | Thin correction on top of the primary move |
| Subject move arrow | 1.5 | `#c0392b` | `CHAR` and `OBJ` |
| Background and ground grid | 1 | `#999999` | Horizon, grid lines, perspective guides |

Two rules keep the hierarchy working in print:

1. Every stroke uses `vector-effect="non-scaling-stroke"`, so the weights hold when the panel is scaled down to a thumbnail.
2. Colour never carries meaning alone. The board must still read in grayscale, where the 2.5 and 1.5 weights separate the primary arrow from the secondary arrow.

There is no industry standard for arrow thickness, dash pattern, or colour. Storyboard conventions fix arrow shapes and labels, not their graphic weight. One board must be internally consistent; no source can settle a dispute about 2 versus 3 pixels. Square brackets and dashes are this package's choice, stated here so the renderer and a human artist produce the same panel.

## 7. Panel notes and shot numbering

Every panel carries the same note block, in the same order. The renderer writes it; a human artist must copy it exactly.

| Line | Content | Example |
|---|---|---|
| Header | Scene and shot | `SC 2 · SH 30 · INT. KITCHEN - NIGHT` |
| Camera | Size, angle, direction, lens, height, roll | `MCU · LOW 15°(앙각) · 3/4 L · 35mm · 카메라 1.20m(HIP) · DUTCH 10°` |
| Action | Present tense, one or two lines | `Mina sets the cup down and turns toward the door.` |
| Dialogue | Speaker and line, only when the line matters on this panel | `MINA: I'm not going back.` |
| Sound | Only when it changes how the shot is played | `off-screen door slam` |
| Duration | Seconds | `3.5s` |
| Transition | How this panel cuts to the next | `CUT` |

The camera line follows the order in the table and always carries numbers. A name alone, such as `LOW`, is not enough because the printed panel is small and the name boundaries differ between sources. Write `LOW 15°(앙각)`, not `LOW`. Omit the `DUTCH` fragment when the roll is zero.

Shot numbers run in tens: 10, 20, 30. The gaps exist so an insert can be added later as 15 without renumbering the scene. Scene numbers follow the script and do not restart the shot numbering unless the document says so.

## 8. Entrance, exit, hold, and transitions

Four short marks sit beside the frame and describe timing rather than movement:

- `IN` — a subject enters the frame here. Draw an arrow at the frame edge pointing inward, labelled `IN`, with the subject id.
- `OUT` — a subject leaves the frame here. Arrow at the edge pointing outward, labelled `OUT`.
- `HU` — hold until. The pose is held until the next shot reaches its matching pose. Use it for match cuts and for reaction shots that must land on a line.
- `CUT` — a hard cut to the next panel at this point. `CUT` is also a transition value, and the panel note uses it for the ordinary case.

Transitions belong to the outgoing panel: the note says how this panel hands over to the next one.

| Transition | Meaning | Board mark |
|---|---|---|
| `CUT` | Instant change to the next shot | `CUT` |
| `DISSOLVE` | Gradual overlap into the next shot | `DISSOLVE` with duration |
| `FADE IN` | From black into the image | `FADE IN` |
| `FADE OUT` | From the image to black | `FADE OUT` |
| `WIPE` | A boundary travels across the frame | `WIPE` plus the direction |
| `SMASH CUT` | Abrupt, deliberately jarring cut | `SMASH CUT` |
| `MATCH CUT` | Cut on a matching shape, pose, or movement | `MATCH CUT` plus what matches |

A transition drawn as an arrow inside the frame is wrong. Transitions are notes, not movement, and they belong in the note block.

## 9. Mannequin construction

The mannequin exists to make facing and pose readable at thumbnail size. It is built from a fixed set of parts, and the same part set is used at every camera angle.

- **Head.** A Loomis head: a sphere for the cranium, a centre line running from the top of the skull through the nose, a brow line crossing the centre line, a flattened side plane on each cheek, and a nose wedge on the front. The Loomis construction is what keeps the head pointing the right way when the camera moves around it.
- **Torso.** A box, not a line. A line has no front or back, which is why a stick figure cannot show a profile or a back view.
- **Limbs.** Boxes hinged at shoulder, elbow, hip, and knee. Arms sit outside the torso outline so the pose survives a black silhouette.
- **Front markers only when facing the camera.** The face cross, the eye dots, the nose wedge, and the chest line are drawn only on the hemisphere that faces the camera. They must disappear when the character turns away.
- **Hair mass always on the back.** A solid mass on the back of the skull is drawn at every angle, including a front view where it shows as a rim. Without it, a back view and a front view render almost identically.
- **Hidden-line removal.** Faces are filled white and painted in depth order, so a limb behind the torso is not drawn through it.

Never mirror a character to change which way they face. Mirroring flips costumes, props, text, and light direction, and it creates a new continuity error while fixing a small one. Change `facingDeg` or the camera yaw and redraw.

The supported poses are `stand`, `walk`, `sit`, `reach`, and `crouch`. A pose the part set cannot express is a signal to change the shot, not to add joints.

## 10. Readability tests

A panel is finished when it passes both tests at thumbnail size, not when it looks good at full size.

1. **Thumbnail silhouette test.** Fill the character solid black and shrink the panel to about 15 percent of its print size. The action must still read: who is where, which way they face, and what they are doing. If the arms disappear into the torso, the silhouette is weak and the pose must be opened up.
2. **Cold read.** Show the panel to someone who has not read the script and ask what moves and in which direction. If they cannot answer in a few seconds, the arrow, the label, or the staging is ambiguous.

Supporting checks:

- Print the page in grayscale. Primary and secondary arrows must still separate by weight.
- Look for any arrow touching a face or a hand.
- Check that every arrow has a label and every label has an arrow.
- Check that the horizon, when visible, sits at the camera height and does not run through a face.

## 11. Common mistakes

| Mistake | Why it fails | Fix |
|---|---|---|
| Purposeless cut | A new angle that adds no information only costs shoot time | Cut it, or give the shot a new piece of information |
| Camera move on every shot | Movement stops meaning anything and hides weak staging | Move only to reveal information or direct attention |
| Jump cut | Same subject at nearly the same size and angle reads as a mistake | Change angle by 30° or more, or change shot size deliberately |
| Weak silhouette | Arms inside the torso outline vanish at thumbnail size | Open the pose; move limbs outside the body |
| Arrows instead of panels | Three arrows cannot describe a complex action as clearly as one more pose | Draw the additional panel |
| Mirroring to fix an eyeline | Flips costume, props, text, and light; creates a new continuity error | Re-stage and redraw at the correct facing |
| Unlabelled arrow | Direction without a name is a guess | Add the exact label from the vocabulary |
| Two primary moves | The crew cannot tell which move is the instruction | Keep one thick, make the other thin or split the panel |
| Arrow across a face or hand | Hides the action and the emotion | Route the arrow outside the frame |
| End frame through a head | The inner rectangle cuts the face | Stop the rectangle and arrows at the silhouette |

## Sources

> Checked 2026-11-03.

| Claim | Source |
|---|---|
| Camera arrows sit outside the frame, subject arrows sit on the subject, every arrow is labelled, and one primary move is drawn thick per panel | https://storyboardart.org/storyboard-tutorials/storyboard-arrows/ |
| Push, pull, and zoom share a frame-in-frame symbol distinguished by label; compound moves use L-shaped arrows; arrow thickness and colour follow no industry standard | https://www.studiobinder.com/blog/storyboard-arrows-meaning/ |
| Panel notes carry scene and shot number, shot size, camera move, action, optional dialogue, and transition; shot numbers in tens leave room for inserts | https://storyboardart.org/storyboard-tutorials/storyboard-format-for-film/ |
| The Loomis head is built from a sphere, centre line, brow line, side plane, and nose wedge, and keeps the head readable at any angle | https://gridmakerpro.com/learn/loomis-method-step-by-step/ |
| The silhouette test and readable single-focus panels are the drawing standard for storyboards | https://storyboardart.org/storyboard-tutorials/fundamental-drawing-for-storyboard-artists/ |
| Thumbnail-stage boards solve composition, angle, and screen direction before detail | https://storyboardart.org/storyboard-tutorials/thumbnails-vs-storyboards/ |
| Purposeless cuts, needless camera moves, jump cuts, and mirroring to fix eyelines are recurring errors | https://www.skwigly.co.uk/storyboarding-tutorial-pt-1-the-dos-and-donts/ |
