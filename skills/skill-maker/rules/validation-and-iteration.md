# Validation and Iteration

**Purpose**: Make skill quality observable rather than guessed.

## 1. Validate Triggerability

Test the skill against example requests:

- requests that should trigger
- requests that should not trigger
- edge cases near the boundary

Minimum expectation:

- at least 3 positive trigger examples
- at least 2 negative trigger examples
- at least 1 boundary example

## 2. Validate Anatomy

Confirm:

- the core body is not bloated
- support files are actually used
- scripts or assets are justified
- references are not duplicating the core

## 3. Validate Usability

Read the skill as if you were:

- a new maintainer
- a trigger model
- an agent following the workflow under context pressure

Also check whether the next file to read is obvious after each major section.

## 4. Forward-Test Questions

- Would the skill still make sense in 3 months?
- Would a realistic user request trigger it correctly?
- Would a maintainer know where to put the next piece of detail?
- Would an agent know what to read next?

## 5. Iterate with Evidence

When the skill feels weak, fix based on:

- failed trigger examples
- readback confusion
- duplicated or misplaced content
- missing validation

Do not iterate based only on vague aesthetic preference.

## 6. Exit Criteria

- Trigger examples are specific enough to distinguish this skill from neighboring skills
- The core `SKILL.md` remains readable within the first screen
- Support files are easy to discover from the core skill
- A new maintainer could place the next piece of information without guessing

## 7. Suggested Checks

```bash
find skills/skill-maker -maxdepth 3 -type f | sort
rg -n "README.md|CHANGELOG.md|QUICK_REFERENCE.md" skills/skill-maker
rg -n "description:" skills/skill-maker/SKILL.md skills/skill-maker/SKILL.ko.md
```
