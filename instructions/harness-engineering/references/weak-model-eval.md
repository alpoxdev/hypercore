# Weak-Model Workflow Eval

> Korean version: [`weak-model-eval.ko.md`](weak-model-eval.ko.md)

A repeatable check that the `hyper` skill's workflow devices (route banner, stage banners, disk state, closing checklist) survive a low-capability model. It counts what the model left out, not how well it reasoned. Scripts: `scripts/weak-model-eval.sh`; scenarios: `scripts/fixtures/weak-model-eval/`.

## What it measures

| Count | Checks | Why it is counted |
|---|---|---|
| Step omissions | The `[라우팅: ...]` banner; `[현재 단계: k/N <stage> ... 진행 중]` and `... 완료` for every expected stage; `[현재 단계: s/9` for each of the nine debug steps | A missing banner is the first visible sign that the model stopped tracking where it is in the chain |
| State omissions | `.hyper/workflows/<slug>/state.json` exists; `hyper-workflow-state.sh verify` passes on it; `.hyper/debug/<slug>.md` exists; its last line is `Result: <terminal>` | State on disk is what lets a resumed or compacted session continue; banners alone can be printed without the work |
| Checklist omissions | The closing checklist line (`[체크리스트: 1=예 ... 6=예]`, bracketed or not) answers items 1 to 6 | The checklist is the last gate before a completion claim; an unanswered item means the gate was skipped. The bracket is format, so its absence alone is not counted |
| Outcome | The scenario's own tests pass; no file changed outside `src/`, `test/`, `.hyper/`, `.gitignore` | Separates "followed the workflow but broke the task" from "skipped the workflow" |

`answered_no` lists items answered `아니오`. That is honest reporting, not an omission, and it is kept apart from the omission count.

## Scenarios

All three are one-file runtime bugs with a failing `node --test test/`. The prompt never names a stage skill, so the model must route through `hyper` to `hyper-debug` on its own.

| Scenario | Bug | Expected chain |
|---|---|---|
| `paginate-off-by-one` | Page slice ends one item early | `hyper-debug` |
| `timeout-zero-default` | `timeoutMs: 0` falls back to 30000 through `||` | `hyper-debug` |
| `slugify-spaces` | Leading, trailing, and repeated spaces become extra hyphens | `hyper-debug` |

## Run procedure

1. Prepare a fresh workdir per run: `bash scripts/weak-model-eval.sh prepare --scenario <id> --out <dir>`. It copies the scenario repo, commits it, copies this repository's `skills/` to `<dir>/.agents/skills/`, and writes `<dir>/.eval/prompt.txt`. The prompt tells the model to read `.agents/skills/hyper/SKILL.md` first, so every runtime sees the same skill text whatever its own skill loader does.
2. Run the agent under test inside `<dir>` with the prompt and save everything it printed to `<dir>/.eval/transcript.*`. Use the runtime rows below.
3. Score: `bash scripts/weak-model-eval.sh score --scenario <id> --workdir <dir> --transcript <file>`. It prints one JSON object; `omissions.total` is the headline number.
4. Repeat each scenario three times per model and record every run; a single run is not a result (see [`measurement.md`](measurement.md)).

| Runtime | Command | Status |
|---|---|---|
| omp | `omp -p --mode json --no-rules --no-context-files --no-skills --model <model> --cwd <dir> "$(cat <dir>/.eval/prompt.txt)" > <dir>/.eval/transcript.jsonl` | Flags checked against `omp --help` (v19.1.1). `--no-rules` and `--no-context-files` keep the operator's own rules out of the measurement; `--no-skills` keeps installed copies of the skills from shadowing the copy under test |
| Codex | `codex exec --json -C <dir> -m <model> "$(cat <dir>/.eval/prompt.txt)" > <dir>/.eval/transcript.jsonl` | `--json`, `-C`, `-m` checked against `codex exec --help`; sandbox and approval flags not checked |
| Claude Code | `claude -p --output-format stream-json --verbose --model <model> "$(cat <dir>/.eval/prompt.txt)" > <dir>/.eval/transcript.jsonl`, run from `<dir>` | Assumed from the CLI documentation; not checked on this machine |
| Antigravity | The owner opens a new interactive session in `<dir>`, pastes `prompt.txt`, and saves the session screen as the transcript | Headless print mode is not used: the account-protection rule forbids it, so this row is run by hand |

Run long agent commands as background jobs, not in the operator's own shell, and give each run its own workdir.

## Recording results

Record one row per run: date, runtime, model, scenario, run number, `omissions.steps`, `omissions.state`, `omissions.checklist`, `outcome.tests_pass`, and `outcome.out_of_scope`. A model passes a scenario when all three runs have `omissions.total == 0`, `tests_pass == true`, and an empty `out_of_scope`. Report the failing check ids, not just the totals, because each id points at the skill line that did not hold.

## Limits

- Banner checks match transcript text. A model can print a banner without doing the step; the state checks are the counterweight, not a proof of the work.
- Three bugs in one language exercise one chain (`hyper` -> `hyper-debug`). They do not measure routing accuracy across chains; the trigger evals under each skill's `assets/evals/` cover that.
- Three runs per cell detect a gross failure, not a small rate difference.

## Sources

> Checked 2026-11-23.

| Claim | Source | Grade |
|---|---|---|
| Banner, state-file, and closing-checklist contracts the scorer checks | `skills/hyper/SKILL.md`, `skills/hyper-debug/SKILL.md`, `skills/hyper-debug/rules/working-loop.md` in this repository | `REPO` |
| Repeated runs per case and behavioral checks kept apart from end-to-end outcome | [`measurement.md`](measurement.md), [`../HARNESS_ENGINEERING.md`](../HARNESS_ENGINEERING.md) | `REPO` |
| omp and Codex flags | `omp --help` (omp v19.1.1) and `codex exec --help`, run 2026-11-23 | `REPO` |
