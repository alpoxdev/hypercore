# Self-Test Pack

Use this reference when the user did not provide a separate prompt pack or eval set for code autoresearch.

This file is now a pack selector, not a single pack. First choose the narrowest domain pack that best matches the target:

| Target Shape | Pack |
|------|------|
| Frontend performance, rendering, bundle work | [self-test-pack.web.md](self-test-pack.web.md) |
| Node runtime, CLI, background jobs | [self-test-pack.node.md](self-test-pack.node.md) |
| API latency, query count, request path | [self-test-pack.api.md](self-test-pack.api.md) |
| Monorepo, workspace-level cleanup | [self-test-pack.monorepo.md](self-test-pack.monorepo.md) |
| No clear classification yet | Generic pack in this file |

Pack selection order:

1. If a trace-backed or incident-backed pack exists, use it first.
2. If the bottleneck type is clear, use the domain pack.
3. If still in exploration, fall back to the generic pack.

## Generic Default Test Prompts

Use the prompts below only when there is no clear domain pack:

1. `Run autoresearch on this repository and keep only optimizations that improve the score.`
2. `Benchmark this codebase with binary evals and store the artifacts in .hypercore.`
3. `Find the biggest bottleneck in this codebase and improve it through measurable iterative experiments.`
4. `Fix only this one bug and then stop.`
5. `Run autoresearch on this repo and keep only score-improving optimizations.`

Expected routing:

- Prompts 1, 2, 3, and 5 should trigger `autoresearch-code`
- Prompt 4 is a boundary case, and direct fixing is usually more appropriate if it does not explicitly ask for iterative experiments

## Generic Default Binary Eval

Use these evals by default in the generic pack:

```text
EVAL 1: Trigger boundary
Question: Can the core alone clearly determine whether this prompt is in scope, out of scope, or a boundary case?
Pass: Scope classification is clear from the core skill alone
Fail: Scope classification depends on guessing or requires searching support files that the core did not point to

EVAL 2: Workflow readiness
Question: Can the agent start the next action from this skill alone without guessing?
Pass: There is enough guidance to start a baseline-first run or a route-away decision
Fail: The next action is ambiguous, missing, or contradictory

EVAL 3: Baseline discipline
Question: For in-scope prompts, is the method for capturing baseline metrics before code edits clearly defined?
Pass: Baseline location, inputs, and no-edit-before-baseline rules are explicit
Fail: The baseline contract is incomplete, inconsistent, or missing

EVAL 4: Artifact lifecycle
Question: Are artifact locations and update cadence clearly defined?
Pass: The `.hypercore` location, required files, and status/update expectations are explicit
Fail: The artifact contract is incomplete, inconsistent, or missing

EVAL 5: Mutation discipline
Question: Does this skill reliably maintain a baseline-first, one-mutation-at-a-time loop?
Pass: Baseline scoring, single-change experiments, and explicit exit conditions are preserved
Fail: It permits eval drift, bundled mutations, or unclear exit behavior
```

## Scoring Notes

- Default total score: `5 prompts x 5 evals = 25`
- Keep the same prompt pack and eval set for baseline and follow-up experiments
- If this pack is replaced, log that replacement before scoring the next experiment

## When Override Is Needed

Replace this pack in these cases:

- The user provided better domain-specific prompts
- The codebase bottleneck is narrow enough that the generic pack does not validate it sufficiently
- The current failure is clearly domain-specific rather than structural
