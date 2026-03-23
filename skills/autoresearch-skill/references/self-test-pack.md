# Self-Test Pack

Use this reference when running autoresearch on a skill and the user did not provide a custom prompt pack or eval set.

This pack is intentionally conservative. It is designed to validate the skill's operating surface before you invent custom scenarios.

## Default Test Prompts

Use these five prompts as the default run set for skill-on-skill autoresearch:

1. `Run autoresearch on skills/web-clone/SKILL.md and keep only score-improving mutations.`
2. `Benchmark this skill with binary evals and store artifacts in .hypercore.`
3. `Tighten this skill once and review it.`
4. `Create a new Codex skill for browser QA.`
5. `Rewrite this runbook for readability.`

Expected routing:

- prompts 1 and 2 should trigger `autoresearch-skill`
- prompt 3 is a boundary case and should usually prefer direct editing unless the user asks for repeated eval-driven optimization
- prompts 4 and 5 should route away from `autoresearch-skill`

## Default Binary Evals

Use these five evals when the target is a skill:

```text
EVAL 1: Trigger boundary
Question: Does the skill make the correct trigger or route-away decision for this prompt obvious?
Pass: The prompt is clearly in-scope, out-of-scope, or boundary-routed from the core skill
Fail: The route decision depends on guesswork or support files not signposted by the core

EVAL 2: Workflow readiness
Question: Could an agent start the correct next step from this skill without guessing?
Pass: The skill gives enough workflow guidance to start a baseline-first run or a route-away decision
Fail: The next action is unclear, missing, or contradictory

EVAL 3: Artifact lifecycle
Question: For in-scope prompts, does the skill define the artifact location and update lifecycle clearly?
Pass: The `.hypercore` workspace, required files, and status/update expectations are explicit
Fail: The artifact contract is incomplete, inconsistent, or missing

EVAL 4: Support-file navigation
Question: Does the core point to the right support file for deeper eval, structure, or artifact guidance?
Pass: The next file to read is obvious from the core
Fail: The agent would need to hunt for the next support file

EVAL 5: Autonomy discipline
Question: Does the skill preserve a stable eval loop with one mutation at a time?
Pass: The skill preserves baseline-first scoring, one-change experiments, and explicit stop conditions
Fail: The loop allows silent suite drift, bundled mutations, or undefined stopping behavior
```

## Scoring Notes

- Default total score: `5 prompts x 5 evals = 25`
- Use the same prompt pack and eval set across baseline and follow-up experiments
- If you replace this pack, log the replacement before scoring the next experiment

## When to Override

Override this pack when:

- the user supplied better domain-specific prompts
- the target skill owns a narrow domain and these prompts would under-test it
- the current failures are obviously domain-specific rather than structural
