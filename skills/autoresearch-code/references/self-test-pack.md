# Self-Test Pack

Use this reference when running autoresearch on a codebase and the user did not provide a custom prompt pack or eval set.

This file is now a pack selector, not the only pack. Pick the narrowest domain pack that matches the target:

| Target shape | Pack |
|------|------|
| Frontend performance, rendering, bundle work | [self-test-pack.web.md](self-test-pack.web.md) |
| Node runtime, CLI, background jobs | [self-test-pack.node.md](self-test-pack.node.md) |
| API latency, query count, request handling | [self-test-pack.api.md](self-test-pack.api.md) |
| Monorepo or workspace-level cleanup | [self-test-pack.monorepo.md](self-test-pack.monorepo.md) |
| No clear fit yet | generic pack in this file |

Pack selection order:

1. Use a trace-backed or incident-backed pack when available.
2. Use a domain pack when the bottleneck type is already clear.
3. Fall back to the generic pack only when the run is still exploratory.

## Generic Default Test Prompts

Use these prompts only when no domain pack clearly fits:

1. `Run autoresearch on this repo and keep only score-improving optimizations.`
2. `Benchmark this codebase with binary evals and store artifacts in .hypercore.`
3. `Find the main bottleneck in this codebase and improve it with measured iterations.`
4. `Fix this one bug and stop.`
5. `Create a new app from scratch.`

Expected routing:

- prompts 1, 2, and 3 should trigger `autoresearch-code`
- prompt 4 is a boundary case and should usually prefer direct editing unless the user asks for repeated eval-driven optimization
- prompt 5 should route away from `autoresearch-code`

## Generic Default Binary Evals

Use these evals only for the generic pack:

```text
EVAL 1: Trigger boundary
Question: Does the skill make the correct trigger or route-away decision for this prompt obvious?
Pass: The prompt is clearly in-scope, out-of-scope, or boundary-routed from the core skill
Fail: The route decision depends on guesswork or support files not signposted by the core

EVAL 2: Workflow readiness
Question: Could an agent start the correct next step from this skill without guessing?
Pass: The skill gives enough workflow guidance to start a baseline-first run or a route-away decision
Fail: The next action is unclear, missing, or contradictory

EVAL 3: Baseline discipline
Question: For in-scope prompts, does the skill define how to capture baseline metrics before edits?
Pass: The baseline location, inputs, and no-edit-before-baseline rule are explicit
Fail: The baseline contract is incomplete, inconsistent, or missing

EVAL 4: Artifact lifecycle
Question: Does the skill define the artifact location and update lifecycle clearly?
Pass: The `.hypercore` workspace, required files, and status/update expectations are explicit
Fail: The artifact contract is incomplete, inconsistent, or missing

EVAL 5: Mutation discipline
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
- the codebase owns a narrow bottleneck and these prompts would under-test it
- the current failures are obviously domain-specific rather than structural
