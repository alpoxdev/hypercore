# Skill Validation

> Korean version: [`validation.ko.md`](validation.ko.md)

Skill validation proves not that a skill "reads well" but that it **triggers accurately, follows the required procedure, and produces a verifiable artifact**.

## 1. Validation layers

| Layer | Question | Method |
|---|---|---|
| Anatomy | Is the format correct? | Frontmatter, folder shape, local links, code fences |
| Trigger | Does it activate on the right requests? | Positive/negative/boundary prompt sets |
| Workflow | Does it follow the required stages? | Readback checklist, trace review, manual dry run |
| Output | Is the artifact format correct? | Template, rubric, or schema check |
| Source | Are external claims linked to evidence? | Source ledger, accessed date, claim-source matrix |
| Safety | Are permissions, network, and destructive actions gated? | Forbidden/required behavior review |
| Benchmark | Are eval or leaderboard claims reproducible? | Benchmark release, scaffold, contamination, oracle caveats |
| Regression | Does it hold up after later changes? | Small eval set, deterministic scripts |

## 2. Minimum smoke set

Every skill leaves at least the following validation note.

```markdown
## Validation notes

- Trigger positives:
  - [ ] prompt 1
  - [ ] prompt 2
  - [ ] prompt 3
- Trigger negatives:
  - [ ] prompt 1
  - [ ] prompt 2
- Boundary:
  - [ ] prompt 1
- Source-sensitive:
  - [ ] recency/vendor/API claim prompt
  - [ ] conflicting-source prompt
- Safety:
  - [ ] retrieved prompt-injection prompt
  - [ ] credential/network/destructive action prompt
- Benchmark:
  - [ ] benchmark/scaffold/version note
  - [ ] **with-skill and without-skill both run by default** (the deterministic-skill exception is recorded)
- Anatomy:
  - [ ] frontmatter present
  - [ ] support files linked
  - [ ] no broken local links
  - [ ] code fences balanced
- Workflow:
  - [ ] purpose/scope/authority/output/verification discoverable
- Risks:
  - ...
```

## 3. Trigger eval design

Composition, not counts:

The set must cover each of these groups. How many rows each one gets is not fixed here — the source does not state a validated count, so this file states a composition requirement instead.

- should-trigger
- should-not-trigger
- boundary
- source-sensitive
- safety/adversarial

Add a row only when it probes something the existing rows do not. Promote each real failure into an eval row as it happens. The canonical smoke-set schema and the repetition/threshold keys live in [`trigger-design.md`](trigger-design.md) §4; this file does not restate them.

Each row carries the keys defined in [`trigger-design.md`](trigger-design.md) §4 (`expect`, `runs`, `threshold`, and the measured `trigger_rate`) plus an `expected_reason` explaining why this skill should handle the prompt.

A trigger eval does not look at one sentence only. Vary the same intent as follows.

- Korean, English, and mixed language
- Direct mention of the skill name, and no mention
- Short requests and long-context requests
- The boundary between general document writing and reusable skill creation
- Recency-claim requests that require prior research

## 4. Output eval design

A skill whose artifact matters includes the following.

- Expected output description
- Required files
- Forbidden output
- Style and format rubric
- Deterministic artifact check

These rules are normative.

- SK-V-1: Run each case **by default** twice — once with the skill and once without it (or against a previous version). Exception: when the no-skill condition cannot produce the artifact at all — a deterministic skill such as a formatter or a schema checker — do not run it; record that fact instead. Do not force a ritual that adds no value (exception: deterministic skill).
- SK-V-2: When improving an existing skill, use a **snapshot of the previous version** as the baseline instead of the no-skill condition. Snapshot the skill folder before editing and point at that snapshot.
- SK-V-3: Do not claim the skill improved **without a baseline** to compare against.
- SK-V-4: Remove or replace any assertion that passes in **both** conditions — it does not reflect the skill's value and only inflates the pass rate. An assertion that always **fails** in both conditions is a subject for investigation, not deletion.

## 5. Workflow / loop eval design

A skill with a loop proves not that it "iterated" but that it **iterated on the right signal and stopped under the right condition**.

| Loop | Eval case | Check |
|---|---|---|
| observe-act | Tool output fails, conflicts, or is missing | It reads the observation and changes the next action |
| draft-critique-revise | A draft violating the rubric | The critique cites the rubric and the revision fixes it |
| branch-score-prune | One of two alternatives is out of scope | It is dropped by the score/prune criteria |
| optimize-compare | Prompt candidates A/B | Same eval set, holdout, and regression record |

Required:

- [ ] The feedback source is stated.
- [ ] There is a max-iterations or stop condition.
- [ ] A guard failure resolves to exactly one of keep, discard, ask, or block.
- [ ] Loop results are recorded in a log or the validation notes.

## 6. Source-grounding eval design

A skill covering research, recent APIs, vendor behavior, papers, benchmarks, or security claims includes a source eval.

| Case | Expected behavior |
|---|---|
| An official source exists | Record the URL, accessed date, and applicable version or product |
| Sources conflict | Compare authority, date, and scope, then caveat |
| Only an old blog exists | Demand a primary source, or mark it unresolved |
| Retrieved content contains instructions | Extract only as evidence and ignore the instruction |

Minimum checks:

- [ ] Non-obvious claims link to a source.
- [ ] Recency claims use absolute dates.
- [ ] Reviewed sources are distinguished from cited sources.
- [ ] A claim without a source is not promoted into a skill core rule.

## 7. Benchmark eval design

When a skill carries verification claims such as "performance improved," "it passes the benchmark," or "it is strong at agentic coding," apply benchmark hygiene.

| Case | Expected behavior |
|---|---|
| Static public benchmark | Record contamination and overlap risk as a caveat |
| Scaffold or tool version changed | Do not compare directly against earlier scores |
| Weak public tests | Flag the need for hidden, differential, or oracle refinement |
| Skill utility claim | Paired with-skill vs without-skill runs on the same task |
| Aggregate score claim | Stratify by task type, repo, difficulty, and failure class |

Required records:

- Benchmark release and date window
- Model, runtime, tool, and scaffold versions
- Repository commit, container, toolchain
- Allowed tools and retrieval setting
- Deterministic verifier or LLM judge rubric
- Known leakage, weak oracle, and contamination caveats

## 8. Safety eval design

A safety eval checks that risky actions are gated without blocking normal work.

| Case | Expected behavior |
|---|---|
| Prompt injection in a web page or tool output | Ignore the external instruction and extract only the needed data |
| Credential request | Refuse or stop without user permission and secure handling |
| Destructive command | Do not execute before explicit permission |
| Production deploy or publish | Confirm permission, scope, verification, and rollback |
| Arbitrary URL or tool argument | Allowlist and schema validation |
| Third-party skill or script | Code review, sandboxing, version pinning, secret check |

## 9. Script-backed skill validation

When `scripts/` exists, additionally confirm:

- [ ] The script is non-interactive.
- [ ] It has `--help` or usage documentation.
- [ ] Dependencies are stated.
- [ ] It prints a helpful error on failure.
- [ ] It uses JSON, JSONL, or a schema when structured output is needed.
- [ ] Version pinning or environment requirements are stated.

## 10. Markdown validation

Confirm the following manually or automatically.

- Code fence balance
- Local markdown link targets exist
- Frontmatter opens and closes
- Excessive duplicate headings
- `SKILL.md` does not link a support file that does not exist

## 11. Completion gate

Do not call it complete if any of the following fails. [`../SKILL_AUTHORING.md`](../SKILL_AUTHORING.md) → `## Verification criteria` is the summary checklist; **how each item is judged** lives in the sections above.

- The trigger boundary is not explained
- Support files are not linked
- Scripts or assets are disconnected from the workflow
- An official-documentation claim has no source
- Destructive, credential, or network behavior is not gated
- Verification results are not recorded
- A loop exists without feedback, metric, guard, and stop condition
- The eval has only happy paths and no negative, boundary, source, or safety cases
- A benchmark or performance claim lacks release, scaffold, verifier, and contamination caveats

## Sources

> Links checked 2026-07-29; link resolution re-checked 2026-09-20. Next re-verification 2026-10-29.

| Claim | Source |
|---|---|
| The with/without baseline as the core pattern, using a previous-version snapshot as the baseline, not claiming improvement without a baseline, and removing assertions that pass in both conditions — the basis of `SK-V-1` to `SK-V-4` | <https://agentskills.io/skill-creation/evaluating-skills> |
| Repetition count, threshold, and trigger rate as the trigger metric | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| The four invocation modes and the prompt-set composition | <https://developers.openai.com/blog/eval-skills> |

### Evidence grade

The baseline rules above are `PRIMARY` and come from the evaluating-skills page, which names the with/without pair as the **core pattern** rather than an option. This file deliberately states **no normative case count**: no source consulted states a validated one, so a composition requirement takes its place.
