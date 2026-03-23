# Experiment Loop

**Purpose**: Keep autoresearch runs measurable, reversible, and easy to learn from.

## 1. Baseline First

- Never mutate the target skill before experiment `0` is recorded.
- Use the same test prompts and eval suite across baseline and follow-up experiments unless the evals themselves were proven wrong.
- If you must change the eval suite, log that as a separate reset event rather than silently mixing scores.

## 2. Diagnose Failures Before Editing

Classify the dominant failure before choosing a mutation:

- trigger ambiguity
- workflow ambiguity
- missing anti-pattern
- weak or missing example
- bad support-file placement
- overgrown core `SKILL.md`
- poor output discipline

Pick the failure that costs the most points or appears most often.

## 3. Change One Thing at a Time

Good mutations:

- clarify one ambiguous instruction
- add one anti-pattern tied to a recurring failure
- move one buried instruction higher
- add one example that demonstrates the missing behavior
- split one overloaded section into `rules/` or `references/`
- delete one instruction that causes overfitting or noise

Bad mutations:

- large rewrites with no isolated hypothesis
- multiple unrelated edits bundled into one experiment
- longer prompts with no measured reason
- adding support files that duplicate the core

## 4. Keep or Discard

- **KEEP** when total score improves.
- **DISCARD** when total score stays flat and the change adds complexity.
- **DISCARD** when total score drops.
- If a change keeps the same score but materially simplifies the skill, document the simplification and keep it only when the no-regression case is explicit.

## 5. Structural Refactor Rule

When optimizing a skill rather than a general prompt:

- prefer moving content to the right layer over adding more core prose
- use `rules/` for reusable policy and validation
- use `references/` for detailed knowledge, examples, and schemas
- avoid turning the core `SKILL.md` into a mini-wiki

Use [../references/skill-refactor-guide.md](../references/skill-refactor-guide.md) when failures clearly come from anatomy rather than instruction wording.

## 6. Logging Rule

Every experiment must record:

- experiment number
- score and max score
- pass rate
- keep or discard
- one-sentence description of the mutation
- why the mutation was expected to help
- what actually changed in the eval outcomes

## 7. Stop Conditions

Stop when any of these become true:

- the user stops the run
- the budget cap is reached
- the skill reaches `95%+` pass rate for three consecutive kept experiments
- remaining failures are caused by bad eval design rather than the skill itself

If the skill is passing the evals but still producing weak real outputs, fix the evals before running more mutations.
