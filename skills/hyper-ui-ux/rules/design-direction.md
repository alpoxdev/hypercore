# Design Direction

Read in `design`, `restyle`, `mockup`, and `brief-only` before the first token or markup. This file owns the brief, the visitor mode, the reference, the token plan, the rejected alternative, and the anti-convergence checks. The result is saved as `.hyper/ui-ux/<slug>/brief.md` using `assets/design-brief-template.ko.md`.

## 1. Why Direction Comes First

A model asked for "a nice page" samples the most common page it has seen. Adjectives such as "modern, clean, premium" describe a region of that distribution, not a point in it; banning one default moves the output to the next default. The fix is to decide, in writing, before markup: who this is for, what it must do, what it looks like by reference to something specific, and which obvious option was rejected.

## 2. Brief Sentence

Write one sentence, and list the unknowns beside it:

> This [surface] helps [audience] do [task] in [situation]; it keeps [confirmed identity, data, and behavior]; [unknowns] are unverified.

Read the inputs in the order of `references/context-signals.md`. A user's own words about the look outrank everything in this file.

## 3. Visitor Mode

Choose one from the surface, not from the product:

| Mode | The visitor wants to | Ambition shows as |
|---|---|---|
| Persuade | be convinced to act (landing, pricing, signup) | one memorable idea, strong hierarchy, real proof |
| Operate | get a task done repeatedly (dashboard, settings, admin, forms) | precision, density that fits the data, familiar patterns, fast feedback |
| Read | understand content (docs, articles, reports) | measure, rhythm, typographic hierarchy, quiet chrome |
| Experience | enjoy or explore (portfolio, campaign, media) | an authored moment, motion or imagery with a cause |

Default to `Operate` for application UI. An Operate screen made "expressive" is a failure, not ambition.

## 4. Reference

Name one specific reference that carries the direction, with what to take from it:

- good: "a printed train timetable: tabular figures, hairline rules, one signal color reserved for delays"
- good: "the product's own onboarding illustration style and its existing 6px radius"
- weak: "minimal and modern", "like Linear", "Apple-like"

A product's existing system is always the first reference in `restyle`. Copying a famous product's look is not a direction; it lands on a different median. Never reproduce a third-party brand's logo, mark, or proprietary assets.

## 5. Token Plan

Convert the direction into named values before markup, in the project's styling system. Minimum set:

| Group | Decide |
|---|---|
| Color | neutral ramp (canvas, surface, raised, line, text strong/default/muted), one accent with its on-color, status colors; each text pair's contrast |
| Type | one or two families with fixed jobs and a reason tied to the reference; a role scale (display, heading levels, body, small, label) with size, line height, weight, tracking |
| Space | one scale (4px-based or the platform's own); section, group, and element gaps |
| Shape | a radius scale tied to element size; nested radius = outer radius minus padding |
| Depth | at most a few elevation steps; borders or shadows, chosen once |
| Motion | duration ladder and easing per job; what never animates |
| Icons | one set, one stroke weight, one size per context |

In `restyle`, map the existing tokens first and change the fewest tokens that move the whole surface. In a component-library project, edit the library's tokens before touching components. Values come from `rules/craft-floor.md` where the floor sets a number.

## 6. Layout Plan and States

- Give every section a job: hook, explain, prove, explore, convert, navigate, or operate. A section with no job is removed.
- Order content by importance; let hierarchy come from size, weight, space, and position before boxes and color.
- List the states the surface has and how each looks: default, hover, focus-visible, active, disabled, loading, empty, error, success, offline. A design that shows only the happy path is not done.
- Use real content or clearly marked placeholders; never invent proof.

## 7. Rejected Alternative

Record at least one obvious option that was considered and rejected, with the reason ("a three-card feature row, rejected: the product has one primary feature and two minor ones"). A brief with no rejected option has not made a decision.

## 8. Anti-Convergence Check

Before building, answer in `brief.md`:

1. Would this same plan be produced for any other product in this category? If yes, change the plan where the product differs.
2. Is any choice here a known default (see `references/anti-pattern-catalog.md`, including the second-wave defaults: cream background with an italic serif display, bento grid as the escape, emerald as the "safe" accent)? If yes, keep it only with a reason from the brief or the reference.
3. Does every expressive element (a gradient, a glow, a motion, an illustration) have a job from the brief? If not, remove it.

Removing a default must not produce an empty or lifeless result: keep feedback motion, real states, and hierarchy alive.

## 9. Korean Interfaces

When the product language is Korean, the plan also states the Hangul font stack, body size, line height, and line-breaking rule from `rules/craft-floor.md` §6.

## Sources

> Checked 2026-11-07.

| Claim | Source |
|---|---|
| Models converge on statistically common choices, and banning one default moves them to another | <https://claude.com/resources/articles/improving-frontend-design-through-skills> (Anthropic, 2025-11-12) |
| Plan first, check "would this be produced for any similar page", and the brief's own words win | <https://github.com/anthropics/skills> (`frontend-design`, commit `2c5958e`) (Apache-2.0) |
| Visitor modes Persuade, Operate, Read, Experience, chosen from the surface | <https://github.com/pbakaus/impeccable/tree/687bc381bc9091bf252c0a05303640561014a425/.agent/skills/impeccable> (Apache-2.0) |
| A specific reference carries more than adjectives; tokens and ordered sections for a `DESIGN.md` | <https://github.com/google-labs-code/design.md/tree/1ed38aa9dd4451b9039f9aeb9ed1d2579edafddf> (Apache-2.0) |
| Section jobs and a recorded rejected alternative | <https://github.com/changeroa/StyleGallery> |
| Editing a few library tokens changes the look of every screen | <https://freedesignmd.com/blog/shadcn-looks-generic> (2026-04-28) |
| Second-wave defaults: cream, italic serif, bento, emerald | <https://github.com/febbhav/signs-of-ai-design/tree/854b46f18dee5cc174d45cec8cd4f3142fe46984> (CC BY-SA 4.0), <https://solodesign.cc/blog/ai-design-slop-the-tells/> |

### Evidence grade

The procedure is this package's synthesis. The mechanism (convergence on common choices) is stated by a model vendor without a public measurement; the sources agree on the order of steps, not on a single checklist.
