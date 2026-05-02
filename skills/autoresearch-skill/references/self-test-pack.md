# Self-Test Pack

Use this reference when the user has not provided a separate prompt pack or eval set for running skill autoresearch.

This pack is intentionally conservative. Its purpose is to verify the skill's real operational surface before inventing arbitrary scenarios.

## Default Test Prompts

Use the following five prompts as the default execution set for skill-targeted autoresearch:

1. ``Run autoresearch on `skills/web-clone/SKILL.md` and keep only changes that improve the score.``
2. `Benchmark this skill with binary evals and save artifacts under .hypercore.`
3. `Tidy up this skill once and review it.`
4. `Create a new Codex skill for browser QA.`
5. `Run autoresearch on this skill and keep only score-improving mutations.`

Expected routing:

- Prompts 1, 2, and 5 should trigger `autoresearch-skill`
- Prompt 3 is a boundary case, and direct editing is usually more appropriate unless repeated experimentation is requested
- Prompt 4 should route outside `autoresearch-skill`

## Default Binary Evals

When the target is a skill, use the following five evals by default:

```text
EVAL 1: Trigger boundary
Question: Can the agent clearly tell from core alone whether this prompt is in scope, out of scope, or a boundary case?
Pass: Scope classification is clear from the core skill alone
Fail: Scope classification relies on guessing or requires searching support files that core did not point to

EVAL 2: Workflow readiness
Question: Can the agent start the next action from this skill alone without guessing?
Pass: There is enough guidance to begin baseline-first execution or decide to route away
Fail: The next action is ambiguous, missing, or contradictory

EVAL 3: Artifact lifecycle
Question: For in-scope prompts, are artifact locations and update cadence clearly defined?
Pass: The `.hypercore` location, required files, and status/update expectations are specified
Fail: The artifact contract is incomplete, inconsistent, or missing

EVAL 4: Support-file discoverability
Question: Is the next file to read for deeper eval, structure, or artifact guidance immediately visible from core?
Pass: The next support file is clear from core alone
Fail: The agent has to hunt for the next file

EVAL 5: Autonomous execution discipline
Question: Does this skill reliably preserve a baseline-first, one-mutation-at-a-time loop?
Pass: Baseline scoring, single-change experiments, and explicit stop conditions are preserved
Fail: It allows eval drift, bundled mutations, or unclear stopping behavior

EVAL 6: Contract/evidence/traceability
Question: When external evidence, tools, or delegation affect the run, does it require a run contract, source policy, and trace assertion?
Pass: Contract/source/trace logging and reset conditions can be found in core or directly linked rules
Fail: It verifies only score increases and does not check evidence, authority, or tool trajectory
```

## Scoring Notes

- Default total score: `5 prompts x 6 evals = 30`
- Keep the same prompt pack and eval set across baseline and later experiments
- When there is no source/tool/delegation condition, score EVAL 6 by whether the requirement is specified, not as "not applicable"
- If this pack is replaced, log that replacement before scoring the next experiment

## When an Override Is Needed

Replace this pack in the following cases:

- The user provided better domain-specific prompts
- The target skill's domain is so narrow that these prompts cannot verify it enough
- The current failure is clearly domain-specific rather than structural
