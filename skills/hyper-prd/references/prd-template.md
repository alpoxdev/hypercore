# PRD Template

Use this reference when creating or restructuring `prd.md`. It owns the section order, the skeleton, and one worked example.

## Contents

- Section order
- Skeleton
- Worked example
- Rules

## Section order

1. Meta: status, platforms, size, updated
2. One-line definition
3. Problem and evidence
4. Target users and explicit exclusions
5. Goals and metrics
6. Scope: P1/P2/P3 stories, non-goals, must-not-change behavior
7. Functional requirements
8. Acceptance scenarios
9. Platform requirements
10. Assumptions
11. Open questions
12. Risks and dependencies
13. Change history
14. Handoff block

Delete a section that does not apply. Never keep a heading without content, and never write `N/A`.

## Skeleton

```markdown
# <Product or feature name> PRD

## Meta

- Status: draft | ready | revised
- Platforms: web | ios | android | desktop (one or more)
- Size: S | M | L
- Updated: YYYY-MM-DD

## Definition

<One sentence. What this is, for whom, and what changes.>

## Problem and evidence

- One concrete case: <who, when, what happened, with real values>
- Current alternative: <what people do today instead>
- Evidence grade: observed | reported | assumed

## Target users and exclusions

- Users: <the people this serves, specifically>
- Excluded: <who this deliberately does not serve>

## Goals and metrics

| Goal | Metric | Target | Measurement means | Measurement time |
|---|---|---|---|---|
| <goal> | <primary metric> | <number + unit> | <where the number comes from> | <window> |
| <goal> | <secondary metric> | <number + unit> | <source> | <window> |
| <goal> | <counter-metric> | <floor + unit> | <source> | <window> |

## Scope

### P1 - <story name>

- Priority reason: <why now, what breaks if it slips>
- Independent test: <how this story alone is proven>
- Requirements: FR-001, FR-002

### P2 - <story name>

- Priority reason: <...>
- Independent test: <...>
- Requirements: FR-003

### P3 - <story name>

- Priority reason: <...>
- Independent test: <...>
- Requirements: FR-004

### Non-goals

- <A thing this deliberately does not do, and what it would have added>
- <A second thing, cutting a different part of the scope>

### Must not change

- FR-010 WHEN <existing condition>, the system SHALL CONTINUE TO <existing behavior>.

## Functional requirements

| Id | Priority | Requirement | Verification |
|---|---|---|---|
| FR-001 | P0 | <EARS sentence> | <what a reviewer does and sees> |
| FR-002 | P1 | <EARS sentence> | <...> |

## Acceptance scenarios

### <Story name>

```text
Scenario: <happy path name> (FR-001, FR-002)
Given <concrete starting state>
When <one action>
Then <observable outcome>

Scenario: <failure or edge name> (FR-002)
Given <concrete starting state>
When <one action>
Then <observable outcome>
```

## Platform requirements

### web

<The decided platform, and the obligations its checklist must settle. Where a checklist exists it fills this block.>

## Assumptions

- A-001: <statement>
  - Evidence grade: repo fact | convention default | guess
  - Basis: <path, quote, or convention>
  - If wrong: <what changes>

## Open questions

- Q-001: <question>
  - Answerer: <role>
  - Blocking: yes | no
  - History: Q: <question> → A: <answer or unanswered>

## Risks and dependencies

- Risk: <what could fail, and the early signal>
- Dependency: <what this needs from outside this document>

## Change history

| Date | Mode | What changed |
|---|---|---|
| YYYY-MM-DD | create | Initial document |

## Handoff

- Platforms: <decided platforms>
- Size: <S | M | L>
- P1 scope: <the stories and requirements that ship first>
- Remaining blocking questions: <Q ids, or "none">
- Inputs for the next stage: <what the next stage reads from this document>
```

## Worked example

```markdown
# Focus Timer PRD

## Meta

- Status: draft
- Platforms: ios, android
- Size: S
- Updated: 2026-11-07

## Definition

A single-purpose focus timer that starts a fixed session and blocks mid-session edits, for people who lose the thread when a timer is too configurable.

## Problem and evidence

- One concrete case: a support thread on 2026-10-28 reports a user restarting a 25-minute session four times because the settings screen offered six duration presets mid-session.
- Current alternative: a general timer app plus a paper note of the intended duration.
- Evidence grade: reported

## Target users and exclusions

- Users: individual knowledge workers who run several short focus blocks a day
- Excluded: teams needing shared session dashboards; people who need interval or pomodoro chaining

## Goals and metrics

| Goal | Metric | Target | Measurement means | Measurement time |
|---|---|---|---|---|
| A session runs to completion | completed-session rate | 70% or more of started sessions | session start and end events | first 14 days after release |
| Sessions start fast | median time from app open to session start | 5 seconds or less | start-timestamp event pairs | first 14 days after release |
| The block does not cost the rest of the app | crash-free session rate | 99.5% or more (counter-metric floor) | crash report per session | first 30 days after release |

## Scope

### P1 - Start and finish one session

- Priority reason: without a run-to-completion path there is no product; nothing else is measurable.
- Independent test: start a 25-minute session, background the app, return after 25 minutes, see the completion state.
- Requirements: FR-001, FR-002

### P2 - Resume after an interruption

- Priority reason: a killed process is the most common way a session dies; shipping resume doubles the useful sessions.
- Independent test: force-quit mid-session, relaunch, see the remaining time restored.
- Requirements: FR-003

### Non-goals

- Preset library and custom duration authoring: would add a settings surface and a second mental model for the same 25 minutes.
- Cross-device session sync: would add an account and a server dependency that the single-device case does not need.

### Must not change

- FR-010 WHEN the app returns from the background during a session, the system SHALL CONTINUE TO show the remaining time without restarting the session.

## Functional requirements

| Id | Priority | Requirement | Verification |
|---|---|---|---|
| FR-001 | P0 | WHEN the user starts a session, the timer SHALL begin counting down from the fixed duration and show the remaining time. | Start a session; the remaining time decreases each second. |
| FR-002 | P0 | IF the session reaches zero, THEN the timer SHALL show the completion state and stop counting. | Run a one-minute test session to zero; the completion state appears and the count stops. |
| FR-003 | P1 | WHEN the process is killed mid-session and relaunched within 24 hours, the timer SHALL restore the remaining time. [가정: users return within a day] | Kill the process at 10 minutes remaining, relaunch, see 10 minutes. |
| FR-004 | P1 | WHERE the device is in silent mode, the completion state SHALL appear without an audible alert yet still show a visible banner. [확인 필요: is a haptic required by the design review?] | Enable silent mode, run to zero, see the banner and no sound. |

## Acceptance scenarios

### Start and finish one session

```text
Scenario: session runs to completion (FR-001, FR-002)
Given a fresh install with no session in progress
When the user taps Start and waits 25 minutes
Then the completion state is shown and no countdown remains

Scenario: session survives a background return (FR-001, FR-010)
Given a session started 10 minutes ago
When the user backgrounds the app for two minutes and returns
Then the remaining time shows about 13 minutes and the session is still running
```

### Resume after an interruption

```text
Scenario: a force-quit restores the remaining time (FR-003)
Given a session with 10 minutes remaining
When the user force-quits the app and relaunches within 24 hours
Then the timer shows the restored remaining time and keeps counting

Scenario: a relaunch outside the window starts a new session (FR-003)
Given a session that ended 25 hours ago
When the user relaunches the app
Then no session is restored and the start state is shown
```

## Platform requirements

### ios

Decided platform. The iOS checklist must settle in-app account handling, privacy declarations, and the review demo path before the build stage; until that checklist exists those items stay open and are not invented here.

### android

Decided platform. The Android checklist must settle the target API level deadline and the data-safety declaration before the build stage; those items stay open until that checklist exists.

## Assumptions

- A-001: users accept a fixed 25-minute duration with no in-session settings
  - Evidence grade: convention default
  - Basis: the cited support thread is about too many presets
  - If wrong: P1 gains a duration choice and the settings non-goal is removed

## Open questions

- Q-001: does the design review require a haptic on completion?
  - Answerer: design
  - Blocking: no
  - History: Q: is a haptic required? → A: unanswered

## Risks and dependencies

- Risk: background execution limits stop the countdown; the early signal is a session that jumps on return.
- Dependency: the store listing needs the final duration copy before submission.

## Change history

| Date | Mode | What changed |
|---|---|---|
| 2026-11-07 | create | Initial document |

## Handoff

- Platforms: ios, android
- Size: S
- P1 scope: FR-001, FR-002 with the start-and-finish story
- Remaining blocking questions: none
- Inputs for the next stage: the fixed duration, the completion state, the resume window, and the two platform obligations above
```

## Rules

- Copy the skeleton's section names exactly; they are the names a reviewer checks.
- Delete every placeholder you cannot fill with a fact, an assumption, or a marker. An empty section is a defect, not a template artifact.
- A `[가정: …]` that changes scope appears again as an `A-###` entry; a `[확인 필요: …]` that blocks scope becomes a `Q-###` with `Blocking: yes`.
- Every story gets one happy-path and one failure-or-edge scenario, so two stories produce four scenarios.
- At most three `[확인 필요: …]` markers in the whole document.
- The handoff block is the only place the next stage's inputs are described; this document never contains a task list, a design, or a flow.

## Sources

> Checked 2026-11-07.

| Claim | Source |
|---|---|
| One document as the canonical artifact, with a short question budget | [snarktank/ai-dev-tasks create-prd](https://raw.githubusercontent.com/snarktank/ai-dev-tasks/main/create-prd.md) - "Limit questions to 3-5 critical gaps in understanding." |
| Removing a non-applicable section instead of writing N/A | [spec-kit specify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/specify.md) - "When a section doesn't apply, remove it entirely (don't leave as 'N/A')." |
| Independently testable stories and numbered requirements | [spec-kit spec-template](https://raw.githubusercontent.com/github/spec-kit/main/templates/spec-template.md) - "Each user story/journey must be INDEPENDENTLY TESTABLE" |
| The WHEN/SHALL requirement sentence | [Kiro feature specs](https://kiro.dev/docs/specs/feature-specs.md) - "WHEN [condition/event] THE SYSTEM SHALL [expected behavior]" |
| State and unwanted-event requirement forms | [EARS](https://alistairmavin.com/ears/) |
| `SHALL CONTINUE TO` for unchanged behavior | [Kiro bugfix specs](https://kiro.dev/docs/specs/bugfix-specs.md) - "WHEN [condition] THEN the system SHALL CONTINUE TO [existing behavior]" |
| Inline markers at the gap | [deanpeters prd-development](https://github.com/deanpeters/Product-Manager-Skills) - "Tag inline where the gap appears, not just at the end." |
| Assumptions and open questions kept out of the body as fact | [phuryn create-prd](https://github.com/phuryn/pm-skills) - "Don't invent. What you don't know goes to 7.4 Assumptions and open questions, clearly marked, not into the body as fact." |
| Counter-metrics in the metric set | [TerminalSkills prd-writing](https://github.com/TerminalSkills/skills) - "Counter-metrics: [Metrics we don't want to hurt]" |
| A handoff block at the end of the document | [Citadel prd](https://github.com/SethGammon/Citadel) |
| No-naming of the internal build mechanism | [ai-conductor prd](https://github.com/jstoup111/ai-conductor) - "It MUST NOT name the new internal mechanism by which this feature is built." |

### Evidence grade

`LOCAL` - the section order and the worked example are this package's design. The sentence forms are quoted from the EARS and Kiro documentation; the marker and assumption rules are adapted from the cited guidance.
