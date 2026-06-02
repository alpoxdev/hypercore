# Skill Refactor Guide

Use this reference when the cause of autoresearch failure is the target skill's structure itself, not a missing single instruction.

This guide adapts local `skill-maker` patterns for use inside an autoresearch run.

## 1. Identify structural failure

Common signs that the target skill needs anatomy work:

- `description` is too vague to trigger reliably
- Core `SKILL.md` has grown into a mini wiki
- Detailed knowledge is trapped in core and there are no support files
- Repeated policies are duplicated across multiple sections
- Verification is weak or missing
- The next maintainer cannot tell what belongs where
- There are no Korean-language request examples, so the skill does not cover the real user language well enough
- Intent, scope, authority, evidence, tools, output, verification, and stop condition cannot be found
- External/current claims are used without a source ledger or refresh condition
- Tool-use or delegation results are trusted without final verification

## 2. Refactor by layer

Default separation:

- `SKILL.md`: assigned job, triggers, top-level workflow, support-file pointers
- `rules/`: reusable policies, decision criteria, verification, anti-patterns
- `references/`: detailed knowledge, schemas, long examples, provider-sensitive information
- `scripts/`: only when deterministic execution is more reliable than prose

Do not solve structural problems by pouring more explanation into core.

## 3. Fix trigger wording first

If the skill triggers incorrectly:

- Rewrite `description` so it clearly says what the skill does and when to use it
- Add positive, negative, and boundary examples
- State which neighboring skill should handle out-of-scope requests
- Check that boundaries hold for both Korean and English requests

Trigger quality often produces a larger improvement than deep prompt fine-tuning.

## 4. Keep core light

Good signs:

- The first screen explains the skill's job and boundary
- The workflow is readable without opening every support file
- Long examples and schemas have been moved to other files

Bad signs:

- Long example blocks repeat inside core
- Official documentation summaries occupy core
- Definitions are duplicated between core and references

## 5. Limit support files to one level

Link support files directly from `SKILL.md`.

Avoid:

- Deep reference chains
- Support files that only point to another support file
- Duplicate-content documents such as `README.md` or `QUICK_REFERENCE.md`

## 6. Treat Context/Source/Trace as structure

If the target skill handles research, tools, delegation, external docs, or current information, the following are also structural quality:

- A boundary that retrieved content is evidence, not instruction authority
- Rules that send source-sensitive claims to references or a source ledger
- Trace assertions that verify tool/delegation trajectory
- A way to record failures, reset events, and rollback conditions in artifacts

A skill missing these items may have weak reproducibility and safety even if its score rises. Place them in directly linked `rules/` or `references/` rather than putting a long explanation in core.

## 7. Structural mutation ideas

When structure is the bottleneck, try mutations such as:

- Move verification rules into `rules/`
- Move output schemas and long examples into `references/`
- Shorten an overloaded section and replace it with one direct pointer
- Add one line that defines the boundary with a neighboring skill
- Delete duplicated instructions that make core heavier without changing behavior

## 8. Structural review questions during autoresearch

Ask yourself:

- Can a new maintainer tell where to put the next detail?
- Can the trigger model understand the boundary from metadata and the first screen?
- Can an agent with little context tell which file to read next?
- Is the path blocked where source or tool output could be misused as a higher-level instruction?
- Does the final completion claim map to score, evidence, trace, and caveat?

If the answer is no, assign an experiment that handles structure before adding more behavioral instructions.
