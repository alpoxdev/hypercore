# Evidence and Recovery Reference

> Korean version: [`evidence-and-recovery.ko.md`](evidence-and-recovery.ko.md)

Derivation for the harness rules about evidence, verification-cost reduction, and long-horizon
recovery. The **normative** rules live in [`HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md)
under `## Evidence Discipline`, `## Reducing Verification Cost`, and `## Long-Horizon Recovery`.
This file shows the working shape of each rule and separates the **principle** from a
particular repository's **implementation** of it.
## Evidence discipline

### One resolved path

The evidence directory is **resolved, not typed**. A hand-typed path is how runs end up
somewhere no reviewer reads and no pull request can cite. The resolver returns an absolute
path and creates nothing; it rejects traversal, separators, absolute inputs, and non-git
roots. The resolver ships its own test, so a broken resolver fails before it can produce
misleading evidence.

**Principle** (portable): evidence location is computed, never asserted.
**Implementation** (contingent): the exact rejection rules and the script that enforces them.

### The four-part evidence README

| Section | What goes in it |
|---|---|
| What was tested | the command, the surface, the revision |
| What was observed | raw output or a faithful excerpt, not a paraphrase |
| Why it is enough | which gate this satisfies and what it does not cover |
| What was omitted | anything redacted, and why — secrets, tokens, headers, env dumps |

The fourth section is not optional. It is where a reader learns that the evidence has a hole.

### Live proof and unit gates are different claims

A hermetic unit gate and a real-surface run prove different things. Keep both, and label
which one you ran. A passing unit suite is not live proof, and a live run that skipped the
unit suite is not a regression guard.

### Isolation is proven, not assumed

| Field | Why it exists |
|---|---|
| before/after digest of the untouched real config or database | shows the run did not touch the real thing |
| changed-path list | shows what the run actually wrote |
| isolated directory path | lets a reviewer inspect the sandbox itself |

A whole-directory digest is supporting evidence, not proof by itself.

### Absence is not success

If the binary, credential, or network needed for a run is missing, record `SKIP` and say so in
the evidence README. **A `SKIP` is not a pass.** Counting skips as passes is how a gate quietly
stops covering anything.

## Reducing verification cost

Cutting expensive verification is legitimate. Doing it from prose is not.

A reduction decision is computed from durable state: the risk class, the size and shape of the
change, whether the change set was fully captured, and whether a source-basis digest exists.
Free-form reasoning can never grant a reduction, because the thing being reduced is the check
on that reasoning.

The shape of a defensible reduction:

```
riskClass: low
reasons: [single outstanding goal, known aggregate shape, no high-risk path touched]
omittedLanes: [expensive-review-lane]
sourceBasisDigest: <digest>
```

Two invariants:

- **The proof must mirror the computed selection exactly.** A mismatch is not a judgement call;
  it is a failure, and the full set of checks stays in force.
- **At least one lane can never be omitted.** Targeted verification against the real surface
  runs at every boundary. What may shrink is the expensive review, never the evidence that the
  thing works.

A digest that is missing or unverified fails closed. The digest binds the integration base,
the normalized path/status rows, the captured diff, and the content of untracked files, without
following symlink targets.

**Principle** (portable): reductions are computed, mirrored, and fail closed.
**Implementation** (contingent): which lanes exist, what the risk classes are named, and the
digest's exact composition.

## Long-horizon recovery

### What must survive compaction

A compaction that keeps the conversation but loses the contract has destroyed the work. The
list that must survive:

- the active goal,
- accepted scope and explicit non-goals,
- acceptance criteria,
- the current step and the next action,
- blockers already recorded.

### The projection is read-only and degrades quietly

Recovery reads canonical durable state through read-only access. A projection that finds
malformed, stale, unreadable, or tampered state returns nothing and the system falls back to a
thinner projection. **A projection failure must never abort the compaction** — the failure mode
of a recovery mechanism must not be worse than the failure it guards against.

### Bound the loop; do not claim to remove it

Repeatedly recovering into the same next action is a stall. Fingerprint the projection on each
attempt; after a small number of unchanged recoveries, emit an explicit `STALLED` directive that
orders a durable blocker or escalation instead of repeating the same action.

Say "this bounds the loop", not "this eliminates it". A bound is honest; elimination is a claim
you cannot support.

**Principle** (portable): name what survives, degrade safely, bound the repetition.
**Implementation** (contingent): the exact threshold, the projection's file format, and the
digest algorithm.

## Sources

> Checked 2026-09-20.

| Claim | Source | Grade |
|---|---|---|
| Compaction, structured note-taking, and sub-agent architectures for long-horizon work; recall-first compaction tuning | <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> | VENDOR |
| Read-only recovery projection, realpath confinement, digest verification, and a bounded zero-progress stall counter (implementation example) | <https://github.com/Yeachan-Heo/gajae-code/tree/07f59defbc691064a126d72e391e46ccd331f970> | REPO |
| Resolved evidence path, evidence README shape, isolation proofs, and `SKIP` handling (implementation example) | <https://github.com/code-yeongyu/oh-my-openagent/tree/496dcce68d62f223c37895e3792f6d5f65920769> | REPO |
| Batch evaluation and aggregate pass-rate practice | <https://developers.googleblog.com/the-anatomy-of-harness-engineering-how-to-evaluate-iterate-and-guard-ai-coding-agents/> | VENDOR |
