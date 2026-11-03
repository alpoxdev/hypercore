# Stop Conditions and Verification

> Korean version: [`stop-conditions-and-verification.ko.md`](stop-conditions-and-verification.ko.md)

A loop is only as good as the check that ends it. This file covers how to write a condition a machine can fail, where to place the checker, and how to keep a checker honest.

## A condition is not a goal

| Form | Example | Why it fails |
|---|---|---|
| Wish | "make it better" | Nothing can be measured, so nothing can fail |
| Goal | "improve the checkout flow" | States a direction, not an end state |
| Condition | "all tests in `test/checkout` pass, `npm test` exits 0, and no other test file is modified; stop after 20 turns" | Testable, bounded, and falsifiable |

The vendor docs make the same distinction operationally: a condition that works across many turns has "one measurable end state", "a stated check" for how the agent proves it, and "constraints that matter" — anything that must not change on the way there — plus an optional turn or time clause (checked 2026-11-03). Conditions are also capped: 4,000 characters in the runtime that documents the limit.

## Anatomy

| Field | Content | Failure if omitted |
|---|---|---|
| End state | One measurable fact: test result, exit code, file count, empty queue | The checker debates quality instead of reading a fact |
| Check | The exact command or artifact that demonstrates the end state | The agent proves it some other way and calls it done |
| Constraints | What must not change: untouched files, unchanged public API, no new dependency | The loop reaches the goal by breaking something else |
| Cap | Turn, time, or token bound, stated as part of the condition | The loop has no ceiling when the end state is unreachable |
| Escalation | What to do when the check cannot run or the requirement is ambiguous | The loop invents a requirement |

## Worked conditions

| Weak | Why | Stronger |
|---|---|---|
| "Fix the failing test" | Which test, and what if it cannot be fixed? | "`pytest tests/auth` exits 0 and no file outside `src/auth/` changes; stop after 10 turns" |
| "Clean up the module" | Unfalsifiable | "Every file in `src/billing/` is under 400 lines, `bun test` exits 0, and the public exports in `index.ts` are unchanged" |
| "Get Lighthouse above 90" | Underspecified: which run, which URL | "Lighthouse performance on `/` is 90 or above on three consecutive runs, no new console errors, stop after 5 tries" |
| "Address the review comments" | The queue is not a condition | "The PR has zero unresolved review threads and CI is green; the loop re-checks after each push" |

The third row is the vendor's own example shape, chosen because the agent can run the audit and print the score, which is what makes it checkable by a model that cannot run tools (checked 2026-11-03).

## Where the check runs

| Placement | What it can see | Cost | Use when |
|---|---|---|---|
| The working agent | Everything it has | Free | Never as the only check — LE-S-1 |
| Separate model, no tools | Only what the agent surfaced in the transcript | One small call per turn | The end state is printed by the agent and the evidence is textual |
| Separate model with tools | The repository, commands, and the environment | Verifier work per iteration | The claim needs independent confirmation |
| Deterministic oracle | Whatever the oracle measures | Cheapest | A test, schema, exit code, or count can express the end state |
| Human | Everything, with judgment | Most expensive | The condition is product-level, or the cost of a wrong verdict is high |

The no-tools checker is the most underrated placement. Its blindness cuts both ways. Repository state cannot talk it into a verdict, because it never reads the repository, but a plausible-looking summary can, because the summary is all it has. That second half is the plausible-pass failure mode in the table below, and it is why the condition has to make the agent's own output prove success rather than assert it. The limitation is symmetric — anything the agent does not print does not exist for the checker. That constraint is stated outright in the runtime docs: the evaluator "doesn't run commands or read files independently" (checked 2026-11-03).

## The verdict machine

A check that returns a boolean loses the information the next iteration needs. Return a verdict and a reason.

| Verdict | Meaning | Loop action |
|---|---|---|
| Not yet met | The condition does not hold, and the reason names what is missing | Continue, passing the reason into the next turn |
| Met | The condition holds | Clear the loop and record an achieved entry |
| Impossible | The condition cannot be satisfied | Clear the loop and record a failed entry with the reason |
| Not evaluated — repository extension | Background work is still running, so the turn is not a complete unit | Defer evaluation to the next completed turn |
| No progress — repository extension | Several turns with no tool use or no state change | Stop, warn, return control with the loop still set |

`Not yet met`, `Met`, and `Impossible` are the three verdicts the vendor evaluator returns. `Not evaluated` and `No progress` are this repository's extension: they report the runner's state rather than the condition, and they exist so the two problems named below have a reportable value. Read them as local vocabulary, not as something the vendor promises.

Three details make this machine work, and each is easy to drop when reimplementing it. `Impossible` must exist, or the loop burns its budget proving an impossibility. `Not evaluated` must exist, or a loop containing a long subagent task is judged on an incomplete turn. `No progress` must exist, or a model that keeps answering the checker without acting spins forever.

## Failure taxonomy

A failed turn is not one thing. Sort it before deciding what the loop does.

| Failure class | Examples | Loop behavior |
|---|---|---|
| Unrecoverable, operator must fix | Authentication failure, exhausted credit balance, context overflow that compaction could not clear, model unavailable | Clear the loop, name the cause, and tell the operator to set it again |
| Retryable | Overloaded server, dropped connection | Retry automatically; after three retries, pause |
| Repeatable, waiting helps | Rate limit, subscription usage limit, a hook that ended the turn | Pause, name the cause, resume when the limit resets |

The four unrecoverable classes are documented for `/goal` (checked 2026-11-03). Copy the taxonomy rather than the specific errors: the point is that a loop must distinguish "fix the world and re-arm me" from "wait" from "try again", because collapsing them either hides a real incident or burns attempts on something a retry cannot change.

## Implementing the checker

A stop check is a hook that runs when a turn ends. The reference implementation is a prompt-based stop hook: the runtime sends the condition and the conversation so far to a small fast model, and the model replies with a verdict and a short reason (checked 2026-11-03). The general hook contract in the same runtime supports a model-evaluated `prompt` type that receives the hook's JSON input through `$ARGUMENTS`, defaults to the background model, and returns `{"ok": …}` plus a reason (checked 2026-11-03). Build the loop's check on that contract when the runtime has one; when it does not, run the checker as an explicit step inside the iteration.

Three implementation rules survive the port:

1. The checker is session-scoped or loop-scoped, and its lifetime is stated. A check that silently outlives its loop is a surprise, and a check that silently disappears mid-loop is worse.
2. The checker's model is named and can be swapped. Evaluator tokens are billed separately, and the docs note they are "typically negligible compared to main-turn spend" — a claim that holds only when the checker is actually small (checked 2026-11-03).
3. The checker's verdict is written to the transcript, not just to memory. The transcript is the only evidence that the loop was judged at all.

## Keeping a checker honest

| Failure | Symptom | Countermeasure |
|---|---|---|
| Self-grading | The agent's own judgement ends the loop | LE-S-1: different actor or deterministic oracle |
| Verifier theater | Approvals with no executed check | Require the checker to cite the check it ran |
| Plausible-pass | The checker accepts prose that describes success | Make the end state a printed fact, not a narrative |
| Existence check | "The file exists" passes for "the file is correct" | Check content and behavior, not presence |
| Rubric drift | The checker's standard shifts between iterations | Fix the rubric in the loop definition; version it |
| Sympathetic context | The checker inherits the maker's reasoning | Fresh context for the checker; do not pass the maker's plan |
| Sampling luck | A flaky check passes once and the loop stops | Require repeat evidence for flaky or stochastic checks |

The last row is where loop design meets evaluation design: a single observation is not a verdict. The aggregation and repetition rules that govern non-deterministic judgements are in [`../../harness-engineering/HARNESS_ENGINEERING.md`](../../harness-engineering/HARNESS_ENGINEERING.md) (`HE-J-1` through `HE-J-7`), and they apply unchanged to a loop's checker.

## Stall, oscillation, and convergence

- **Stall**: iterations continue, state does not change. Detect on repeated identical state digests, on turns with no tool use, or on a growing count of rejections with identical reasons. Bound it with a named constant, not an adjective.
- **Oscillation**: iteration *n* undoes iteration *n−1*. Detect by comparing the diff of successive iterations; stop and escalate, because a checker will keep approving both directions.
- **Weak convergence**: each iteration improves a little, and the budget runs out before the condition holds. Accept this as a normal outcome and report it as `exhausted`, with the distance to the condition.
- **Premature convergence**: the condition holds trivially because the work shrank. Guard it with a minimum scope in the condition ("all `src/billing/*.ts` still exported").

## Budget exhaustion and escalation

Exhaustion is a reportable outcome with four fields: which cap was hit, how far the condition was from holding, what the last verdict's reason said, and what state is persisted for a resume. Escalate on any of: the condition cannot be checked in this environment, the requirement is ambiguous and product-level, the loop cannot change what blocks it, or the loop would have to exceed its declared blast radius.

A worked escalation policy has three tiers: continue silently (normal), pause and notify (retryable or waiting), stop and require a human (unverifiable, ambiguous, or destructive). The runtime's own state labels — active, paused, cleared, achieved, failed — are a usable vocabulary for the first two (checked 2026-11-03).

## The iteration record

Every iteration writes one record. Without it, the loop cannot be debugged and its cost cannot be attributed.

```yaml
iteration: 12
trigger: schedule | event:<source> | human | chained
condition: "pytest tests/auth exits 0 and no file outside src/auth/ changes"
verdict: not_yet_met | met | impossible | not_evaluated | no_progress
reason: "2 of 5 tests fail in src/auth/session.py"
turns: 4
tokens: {input: 0, output: 0, cached: 0}
changed_paths: []
checker: {kind: model_no_tools | model_with_tools | oracle | human, model: "..."}
stop_cause: condition_met | budget | no_progress | error | human
```

## Related documents

- [`../LOOP_ENGINEERING.md`](../LOOP_ENGINEERING.md) — `LE-S-1` through `LE-S-7`.
- [`loop-types.md`](loop-types.md) — which types need which check.
- [`cost-and-safety.md`](cost-and-safety.md) — budgets, permissions, and escalation tiers.
- [`runtime-primitives.md`](runtime-primitives.md) — concrete hook and goal mechanics per runtime.

## Sources

| Claim | Source | Date |
|---|---|---|
| Condition anatomy (measurable end state, stated check, constraints), 4,000-character cap, turn clause | <https://code.claude.com/docs/en/goal> | updated 2026-10-29, checked 2026-11-03 |
| Three verdicts with reasons, no-tool evaluator, no-progress stop, unrecoverable vs retryable vs paused failures, background deferral, check-in backoff | <https://code.claude.com/docs/en/goal> | updated 2026-10-29, checked 2026-11-03 |
| Stop hook fires when the main agent finishes; prompt-type hooks with `$ARGUMENTS`, background model default, `ok`/reason response | <https://code.claude.com/docs/en/hooks> | checked 2026-11-03 |
| Deterministic criteria are effective because the agent stops deciding "good enough"; evaluator model checks the condition each time the agent tries to stop | <https://claude.com/resources/articles/getting-started-with-loops> | 2026-06-30, checked 2026-11-03 |
| Graders may be deterministic or agentic; verification adds latency and cost per run | <https://www.langchain.com/blog/the-art-of-loop-engineering> | 2026-06-16, checked 2026-11-03 |
| "Verifier theater" and other observed failure modes; maker/checker separation as the most emphasized block | <https://arxiv.org/abs/2608.21884> | 2026-08-22, rev. 2026-10-22, checked 2026-11-03 |
| Stopping conditions such as a maximum number of iterations; ground truth from the environment at each step | <https://www.anthropic.com/research/building-effective-agents> | 2024-12-19, rev. 2026-10-09, checked 2026-11-03 |
| A loop without feedback is just a `for` statement | <https://www.oreilly.com/radar/what-the-hell-is-a-loop-anyway/> | 2026-07-29, checked 2026-11-03 |
