# Eval Guide

How to write eval criteria that lead to real skill improvement instead of false confidence.

---

## Core Principles

Every eval must be a yes/no question. It is not a scoring scale and not a vibe check. It is binary.

Reason: scale-based evaluation accumulates large run-to-run variance. Binary evaluation gives a more stable signal for keep/discard decisions.

---

## Good and Bad Evals

### Text/Copy Skills

**Bad eval**
- "Is the sentence good?"
- "Rate the engagement pull from 1 to 10."
- "Does it sound human-written?"

**Good eval**
- "Does it avoid every phrase in the banned list `[game-changer, here's the kicker, level up]`?"
- "Does the first sentence include a specific time, place, or sensory detail?"
- "Is the output between 150 and 400 words?"
- "Does the ending include a CTA that clearly instructs the next action?"

### Visual/Design Skills

**Bad eval**
- "Does it look professional?"
- "Rate visual quality from 1 to 5."
- "Is the layout good?"

**Good eval**
- "Is every text element in the image readable without clipping or overlap?"
- "Does the color palette use only soft colors, with no neon or high-saturation red?"
- "Does the layout read as a linear structure in one direction, either left-to-right or top-to-bottom?"
- "Does it avoid numbering, sequence labels, and ordinals?"

### Code/Technical Skills

**Bad eval**
- "Is the code clean?"
- "Does it follow best practices?"

**Good eval**
- "Does the code run without errors?"
- "Does the output contain no TODO or placeholder comments?"
- "Are function and variable names descriptive, with single-letter names used only for loop counters?"
- "Does every external call, including API calls, file I/O, and network access, have error handling?"

### Documentation Skills

**Bad eval**
- "Is it comprehensive enough?"
- "Does it reflect customer requirements well?"

**Good eval**
- "Does the document include every required section in `[list]`?"
- "Does every claim include a concrete number, date, or source?"
- "Is the document within [X] pages/words?"
- "Does the summary fit in one paragraph of three sentences or fewer?"

### Skill/Meta Skills

**Bad eval**
- "Did the skill get better?"
- "Is the prompt clearer?"
- "Will this trigger well?"

**Good eval**
- "Does `description` clearly say what the skill does and when to use it?"
- "Can the assigned work and boundary be understood from the first screen of core `SKILL.md`?"
- "Are reuse policies and detailed knowledge split into `rules/` and `references/` instead of duplicated in core?"
- "Is there at least one realistic positive example and at least one clear out-of-scope example?"
- "When reading Korean-language request examples, are the trigger boundary and next action still preserved?"
- "When external/current sources or tool use affect correctness, does it require a source ledger or trace assertion?"

---

## Common Mistakes

### 1. Too many evals

When there are more than 6 evals, the skill can learn test-passing tactics more easily than real quality.

**Fix:** Keep only the most important 3 to 6 evals.

### 2. Rules that are too narrow and rigid

Rules such as "must have exactly 3 bullets" may technically pass while making the output unnatural.

**Fix:** Test quality that truly matters, not arbitrary format.

### 3. Overlapping evals

When one failure naturally includes another, such as grammar and spelling, the same issue gets counted twice.

**Fix:** Make each eval inspect a distinct failure surface.

### 4. The agent cannot measure it

Questions such as "Will a person find it fun?" are hard to score reliably in a loop.

**Fix:** Translate subjective quality into observable signals.

### 5. Ignoring the real failure surface

When optimizing a skill, looking only at tone, brevity, or formatting misses the real problem.

**Fix:** At least one eval should inspect a real operational surface such as trigger quality, structure, or verification quality.

### 6. Not evaluating evidence and trajectory

For source-sensitive skills, scoring only the final sentence can miss search snippets, stale docs, or tool-output injection.

**Fix:** Include observable items such as source ledger, retrieved-content authority boundary, and trace assertion in the evals.

---

## Three Questions Before Using an Eval

1. Would two different agents give the same score after seeing the same output?
2. Can this eval be gamed without real improvement?
3. Is this something the user actually cares about?

If any answer is no, rewrite the eval.

---

## Template

Copy this format for each eval:

```text
EVAL [N]: [short name]
Question: [yes/no question]
Pass: [condition for yes - one specific sentence]
Fail: [condition for no - one specific sentence]
```

Example:

```text
EVAL 1: Text readability
Question: Is every text element in the output fully readable without clipping or overlap?
Pass: Every word can be read without guessing and no area is obscured
Fail: Some words are clipped, overlap another element, or are cut off at an edge
```

Meta-skill example:

```text
EVAL 2: Clear trigger boundary
Question: Does this skill include concrete examples of requests that should and should not trigger it?
Pass: At least one positive example and one out-of-scope example make the boundary clear
Fail: It only explains when to use the skill abstractly or omits boundary examples
```
