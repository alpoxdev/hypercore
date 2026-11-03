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

Two numbers circulate for this work and they measure different things. The evaluating-skills page's starting point is **2-3 test cases**, which are behavior eval cases: each one produces an artifact and is graded per assertion (§4). The **10-20 prompts** in [`trigger-design.md`](trigger-design.md) §3 come from OpenAI's skill eval guidance and count **trigger queries**, which ask only whether the skill activates and are judged by trigger rate (`SK-J-1` to `SK-J-6`). A behavior case grades the artifact; a trigger query grades the selection. Neither number replaces the other, and neither is a case-count target for this file.

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

- SK-V-1: Run each case **by default** twice — once with the skill and once without it (or against a previous version). Exception: when the no-skill condition cannot produce the artifact at all — a deterministic skill such as a formatter or a schema checker — do not run it; record that fact instead.
- SK-V-2: When improving an existing skill, use a **snapshot of the previous version** as the baseline instead of the no-skill condition. Snapshot the skill folder before editing and point at that snapshot.
- SK-V-3: Do not claim the skill improved **without a baseline** to compare against.
- SK-V-4: Remove or replace any assertion that passes in **both** conditions — it does not reflect the skill's value and only inflates the pass rate. An assertion that always **fails** in both conditions is a subject for investigation, not deletion.
- SK-V-5: Read the outputs, not only the grades, and record a per-case human note (`feedback.json` beside the eval directories). A specific complaint ("the chart has no axis labels") is actionable; "looks bad" is not; an empty string means the case passed review. The next iteration works from the complained-about cases.

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

A worked example of the paired design exists and is worth reading before making a utility claim: SWE-Skills-Bench pins each skill to a repository commit, derives requirements, builds executable verifiers, and reports a per-skill paired delta. Its result — 92 of 98 skills with no statistically significant effect, and an average pass ratio moving from 76.6% to 76.9% — is the kind of answer a skill eval should be able to produce, and it is a warning against assuming a skill helps (<https://arxiv.org/abs/2603.15401>, published 2026-03-16).

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

## 12. Tooling that runs this loop

Two tools implement the layout and comparisons described above, which is why the repository can adopt the file names rather than inventing them.

| Tool | What it does | What it requires |
|---|---|---|
| Anthropic `skill-creator` (Skill / plugin) | Splits the eval set, runs each case in a fresh session or subagent, grades assertions with evidence, aggregates `benchmark.json`, runs a blind A/B between two versions, and proposes description edits | Test cases in `evals/evals.json` inside the skill directory |
| `claude plugin eval` | Runs each prompt with and without the plugin in isolated sessions, scores with graders you define, and exits non-zero below a threshold so CI can gate on it | A plugin; `tool_used: Skill` graders to measure triggering |

Either way, a fresh session per run is mandatory: leftover context from authoring the skill masks gaps in the written instructions (<https://code.claude.com/docs/en/skills>, checked 2026-11-03).

## Sources

> Links re-read and re-checked 2026-11-03.

| Claim | Source |
|---|---|
| The with/without baseline as the core pattern, using a previous-version snapshot as the baseline, not claiming improvement without a baseline, and removing assertions that pass in both conditions — the basis of `SK-V-1` to `SK-V-4` | <https://agentskills.io/skill-creation/evaluating-skills> |
| Human review beside the grades, specific per-case feedback, and the 2-3 case starting point — the basis of `SK-V-5` | <https://agentskills.io/skill-creation/evaluating-skills> |
| Repetition count, threshold, and trigger rate as the trigger metric | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| The four invocation modes, the prompt-set composition, and the 10-20 trigger-query count | <https://developers.openai.com/blog/eval-skills> |
| The paired per-skill delta design, the 92-of-98 result, and the 76.6% to 76.9% average | <https://arxiv.org/abs/2603.15401> |
| `skill-creator`, `evals/evals.json`, blind A/B comparison, `claude plugin eval`, the fresh-session rule, and the CI exit code | <https://code.claude.com/docs/en/skills> |

### Evidence grade

The baseline rules above are `PRIMARY` and come from the evaluating-skills page, which names the with/without pair as the **core pattern** rather than an option. This file deliberately states **no normative case count**: no source consulted states a validated one, so a composition requirement takes its place; the 2-3 figure is quoted as the source's own starting point. The benchmark example is a single 2026 paper, presented as a design to copy rather than as a result that generalizes to every skill.
