# Continuity

> Korean version: [`continuity.ko.md`](continuity.ko.md)

Read while blocking a scene and again before delivery. This file owns the axis, the 180° rule, screen direction, eyeline matching, the 30° rule, and the way this package records an intentional break.

These are working conventions of film grammar, not laws. Audiences read a sequence as continuous when the picture keeps its spatial logic; a director may break that logic on purpose and the break then becomes part of the meaning. The renderer therefore warns and records rather than refuses.

## 1. The axis and the 180° rule

The axis is an imaginary line through the space of a scene. It runs between two people in a conversation, or along the direction a character or vehicle travels. The camera stays on one side of that line for the consecutive shots of the scene, so the viewer keeps one mental map of who is where.

- Declare it once per scene as `scene.axis: [characterId, characterId]`; the two ids name the line's endpoints. A travel axis may use the same pair with the moving character as one endpoint.
- Every camera position falls on one side of the line. `layoutShot()` projects the camera into scene space and the sign of that projection is the camera side.
- When consecutive shots in one scene flip the sign, the spatial map flips with them: the person who stood frame left now stands frame right, and the viewer reads it as a move or as a mistake.
- The renderer reports this as the `AXIS_CROSSED` warning, and only when the two shots are adjacent within the same scene.

`AXIS_CROSSED` is a warning, not an error. It appears as a panel badge and in the top summary, and it does not stop rendering.

## 2. Three or more characters

A scene with three or more people has more than one possible line.

- Find the pair that carries the exchange with the most weight and make that the scene axis. Everyone standing on the same side of it is grouped and treated as one endpoint for the purpose of coverage.
- When blocking splits the room into two clusters, keep the axis between the clusters rather than between individuals; the cluster axis is what the viewer is tracking.
- A second line exists in the room even if it is not declared. If a shot is composed across an undeclared line, the picture is still readable as long as the following shots keep the same side of it.
- Change the declared axis with a bridging shot, not between two shots of the same exchange.

Grouping is a reading aid: it lets a wide two-shot hold four people without making the viewer rebuild the room on every cut.

## 3. Screen direction

Screen direction is the left-right vector of movement inside the frame. A character walking frame right should keep walking frame right over the cut, or the audience reads a reversal.

- `SCREEN_DIRECTION_FLIP` fires when a character's subject move in one shot travels in the opposite screen x direction from the same character's move in the previous shot of the scene.
- Keep the travel vector stable across the scene. If the story turns the character around, show the turn.
- The floor plan is the place to check this: the arrow on the plan and the arrow on the panel should agree in direction.

## 4. Eyeline matching

Two people talking in single shots look at each other only if their gazes point at opposite frame edges.

- If A looks frame right in their single, B must look frame left in theirs.
- `layoutShot()` returns `facingScreen` as `left`, `right`, or `center` for each shot, computed from the character's facing and the camera position.
- `EYELINE_MISMATCH` fires when two adjacent singles in one scene, each holding one of the two axis characters alone, return the same `facingScreen` value. Both look right and the conversation reads as two people addressing the same off-screen third party.
- Fix it by moving the camera to the other side with a legal bridge, not by flipping the drawing. Mirroring the art mirrors costumes, props, lettering, and light as well, and creates fresh continuity errors.

## 5. Crossing the line: four ways, plus none

When a scene genuinely needs the other side, film practice bridges the crossing so the viewer crosses with the camera. The `crossing` object on a shot takes one of these values in `crossing.method`.

| `crossing.method` | What happens on screen | Practical form |
|---|---|---|
| `neutral` | Cut to a shot on the line itself, then continue on the far side | A straight-on two-shot, a shot down the axis, or a cutaway on the line |
| `subject-move` | A character walks across the line inside one shot while the camera holds | The camera stays put and the actor carries the viewer to the new side |
| `camera-move` | The camera travels across the line inside one shot, showing the space it passes | A pan, truck, or crane that sweeps the room and lands on the new side |
| `both` | Character and camera cross together in the same shot | A tracking move that follows the actor around the line |
| `none` | The cut jumps the line with no bridge at all | A deliberate, visible jump; record why |

`crossing.method: "none"` is a legitimate choice, not a missing value. It says the cut is meant to be felt.

A shot that carries `crossing` suppresses the three spatial warnings (`AXIS_CROSSED`, `EYELINE_MISMATCH`, `SCREEN_DIRECTION_FLIP`) for the cut that leads into it, and the report records `{shot, method, intentional, reason}` in `intentional[]`. Suppression without a crossing object is not available: the warning stays.

`crossing.intentional` is a separate boolean from `crossing.method`. Method names how the line was crossed; `intentional` says the crossing is a choice rather than an oversight. `crossing.reason` is a non-empty string and carries the dramatic purpose: what the viewer should feel at that cut.

## 6. The 30° rule and axial cuts

Cutting between two shots of the same subject with almost the same camera angle produces a jump: the subject appears to twitch in place. The convention is a minimum of 30° of angular change between consecutive setups on the same subject.

- `JUMP_CUT` fires when two adjacent shots share the same focus, share the same `size`, and the camera's yaw around the subject differs by less than 30°.
- The 30° figure is a convention, not a threshold physics supplies; a 25° change with a large size change still cuts cleanly, and a 40° change with identical size can still feel tight.
- The `axial` cut is the deliberate exception: the camera holds its angle and changes only the shot size, as in a jump from `MS` to `CU` on the same axis. It reads as a punch rather than an error, and it is a standard tool for emphasis.
- Because the axial cut keeps the same yaw, it satisfies the 30° rule only through the size change; when you want it, cut a wide size step and record the intent.

Deliveries should carry either 30° or more of angle change, or a size change large enough that the audience reads a new setup, or a recorded intention.

## 7. Exit and entry direction

A character who leaves the frame establishes a travel vector. The next time the audience sees that character moving, the vector should continue.

- Exit frame right, enter frame left: the character keeps travelling in the same world direction, and the cut reads as continuous time.
- Reversing the vector without showing the turn reads as a return to where they came from.
- The same test applies to props, vehicles, and gaze: whatever had a direction keeps it until the story shows the change.
- `SCREEN_DIRECTION_FLIP` also covers this case when the reversal appears in a subject move.

## 8. Recorded breaks are part of the grammar

The 180° rule, the 30° rule, and eyeline matching describe how continuity is normally built. Directors have broken each of them on purpose and the breaks became the style: Yasujirō Ozu crosses the line systematically in domestic dialogue scenes, and Jean-Luc Godard's jump cuts in *Breathless* made the discontinuity itself the subject. A board that warns on every such choice would be useless.

- Record the break, not the apology. Set `crossing` with the method, `intentional: true`, and a `reason` that names the effect.
- `getReport()` separates `warnings[]` from `intentional[]`; read the intentional list as the directorial notes for the sequence.
- A warning that remains after review means the shot is still an accident. Either fix the geometry or convert it into a recorded choice.
- A break with no reason is indistinguishable from a mistake, which is why `crossing.reason` must not be empty.

## 9. Codes, causes, and responses

| Code | Rule it protects | Cause | Response |
|---|---|---|---|
| `AXIS_CROSSED` | 180° rule | Adjacent shots in one scene sit on opposite sides of the declared axis | Bridge with `neutral`, `subject-move`, `camera-move`, or `both`; or record `crossing` with `method: "none"` |
| `EYELINE_MISMATCH` | Eyeline match | Two adjacent singles on the axis pair return the same `facingScreen` | Move one camera to the opposite side through a bridge, and re-check `layoutShot().facingScreen` |
| `JUMP_CUT` | 30° rule | Same focus, same size, yaw change under 30° | Change the angle, change the size for an `axial` cut, or record the intent |
| `SCREEN_DIRECTION_FLIP` | Screen direction and exit/entry | A character's move reverses screen x between cuts | Keep the travel vector, show the turn, or record the reversal |

Every row has the same shape: the code names the convention, the report names the shot, and the author either repairs the geometry or states the intention.

## Sources

> Checked 2026-11-03.

| Claim | Source |
|---|---|
| The 180° rule keeps consecutive shots on one side of an action axis, and crossing it reverses apparent positions | <https://filmglossary.ccnmtl.columbia.edu/term/180-degree-rule/> |
| The rule is a convention that Ozu and Godard deliberately violated, and four bridging methods (neutral shot, subject move, camera move, both) are standard | <https://storyboardart.org/storyboard-tutorials/continuity-for-storyboards/> |
| Eyeline matching, exit and entry direction, and continuity of screen direction between cuts | <https://open.library.okstate.edu/introfilmtv/part/editing/> |
| The 30° rule and the axial cut as its deliberate exception | <https://en.wikipedia.org/wiki/30-degree_rule> |
| Mirroring artwork to fix screen direction reverses costumes, props, and light with it | <https://www.localbanana.io/blog/ai-storyboard-screen-direction-guide> |
