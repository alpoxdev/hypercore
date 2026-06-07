# Autoresearch Skill 100 Local Eval Plan

## TL;DR
> Summary:      Finish the current partial `autoresearch-skill` improvement so the repo-local deterministic contract reaches 12/12, which is the local 100/100 gate, with RED->GREEN evidence and tmux manual QA.
> Deliverables:
> - `tests/autoresearch_skill_contract_test.py` locked as the RED/GREEN contract test
> - Updated `skills/autoresearch-skill/SKILL.md` and `SKILL.ko.md`
> - Synchronized `plugins/hypercore/skills/autoresearch-skill/**` mirror
> - Completed ignored runtime artifacts under `.hypercore/autoresearch-skill/autoresearch-skill/`
> - Completed ignored bridge artifacts under `.omx/specs/autoresearch-autoresearch-skill/` and `.omx/state/autoresearch-skill/`
> - tmux manual QA transcripts under `.omo/evidence/`
> Effort:       Short
> Risk:         Medium - the worktree is already dirty and runtime artifacts are ignored by git, so evidence must be preserved without reverting user/team changes.

## Scope
### Must have
- Preserve the current in-progress edits in `skills/autoresearch-skill/SKILL.md` and `skills/autoresearch-skill/SKILL.ko.md`; finish them instead of reverting.
- Treat `tests/autoresearch_skill_contract_test.py` as the deterministic scoring contract. Current observed RED baseline is `SCORE 7/12` from `python3 tests/autoresearch_skill_contract_test.py`.
- Make the named test function `test_autoresearch_skill_scores_100` pass by direct Python invocation because `python3 -m pytest --version` currently reports `No module named pytest`.
- Make all script scenarios pass: `--scenario happy`, `--scenario boundary`, and `--scenario regression`.
- Complete `.hypercore/autoresearch-skill/autoresearch-skill/` artifacts even though `.hypercore/` is ignored by `.gitignore`.
- Complete `.omx/specs/autoresearch-autoresearch-skill/result.json` and `.omx/state/autoresearch-skill/autoresearch-state.json` even though `.omx/` is ignored by `.gitignore`.
- Sync the Codex plugin mirror for `autoresearch-skill` because `scripts/validate-codex-plugin.mjs` requires plugin skill files to match root skills.
- Capture tmux manual QA evidence for happy, boundary, and regression scenarios.
- Obtain final `codex-ultrawork-reviewer` unconditional approval before declaring the goal complete.

### Must NOT have (guardrails, anti-slop, scope boundaries)
- Do not read, cite, or depend on home/global skill directories; `AGENTS.md:8-12` restricts work to repository-local files.
- Do not browse the web or update `last_verified_at` style claims; repo-local docs already define the needed contract.
- Do not delete, modify, or mirror the unrelated untracked `skills/git-issue/` directory unless the user explicitly asks.
- Do not weaken, delete, or bypass `tests/autoresearch_skill_contract_test.py`.
- Do not mark `.hypercore` results complete until tmux Manual QA artifacts and cleanup receipts exist.
- Do not treat the existing stored `36/36` `.hypercore` artifact as sufficient; the live contract test still fails until artifact JSON and OMX state match the test.
- Do not commit ignored `.hypercore/` or `.omx/` runtime state unless the user explicitly changes the repository policy.

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: TDD + Python contract script/function invocation. Existing contract test is RED and must be preserved before implementation changes.
- QA policy: every task has agent-executed scenarios
- Evidence: `.omo/evidence/task-<N>-<slug>.<ext>`

## Execution strategy
### Parallel execution waves
> Target 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks to maximize parallelism.

Wave 1 (no dependencies):
- Task 1: Lock the RED contract test and baseline evidence

Wave 2 (after Wave 1):
- Task 2: depends [1] - finish root skill contract exact-token fixes

Wave 3 (after Wave 2):
- Task 3: depends [2] - produce final `.hypercore` deterministic run artifacts
- Task 5: depends [2] - sync plugin mirror and tracked source/test commit

Wave 4 (after Wave 3):
- Task 4: depends [3] - produce OMX bridge state and approved completion artifact

Wave 5 (after Wave 4):
- Task 6: depends [2, 3, 4] - execute tmux manual QA and record evidence
- Task 7: depends [2, 3, 4, 5, 6] - run final local gates and reviewer handoff package

Critical path: Task 1 -> Task 2 -> Task 3 -> Task 4 -> Task 6 -> Task 7

### Dependency matrix
| Task | Depends on | Blocks | Can parallelize with |
|------|------------|--------|----------------------|
| 1    | none       | 2      | none                 |
| 2    | 1          | 3, 5, 6, 7 | none              |
| 3    | 2          | 4, 6, 7 | 5                   |
| 4    | 3          | 6, 7   | 5                    |
| 5    | 2          | 7      | 3, 4                 |
| 6    | 2, 3, 4    | 7      | none                 |
| 7    | 2, 3, 4, 5, 6 | final verification | none        |

## Todos
> Implementation + Test = ONE task. Never separate.
> Every task MUST have: References + Acceptance Criteria + QA Scenarios + Commit.

- [ ] 1. Lock the RED contract test and baseline evidence

  What to do: Confirm `tests/autoresearch_skill_contract_test.py` is the local deterministic scorer, preserve it unchanged unless it is missing, and capture the current RED output before any further skill or artifact edits. If the test is still untracked, stage/commit it before source fixes so the RED test exists independently of the implementation.
  Must NOT do: Do not edit `skills/autoresearch-skill/**`, `.hypercore/**`, or `.omx/**` in this task. Do not install pytest or any network dependency.

  Parallelization: Can parallel: NO | Wave 1 | Blocks: [2] | Blocked by: []

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `tests/autoresearch_skill_contract_test.py:95` - the `checks()` list defines all 12 deterministic contract checks.
  - Pattern:  `tests/autoresearch_skill_contract_test.py:221` - scenario runner for happy/boundary/regression manual QA mapping.
  - Test:     `tests/autoresearch_skill_contract_test.py:256` - named `test_autoresearch_skill_scores_100` gate required by the ULW brief.
  - Pattern:  `.omo/ulw-loop/019ea0e6-0cfe-7b31-aa98-388e46af94ed/brief.md:7` - requires RED->GREEN proof from the contract test.
  - External: none; `AGENTS.md:8` and `AGENTS.md:12` require repository-local sources only.

  Acceptance criteria (agent-executable only):
  - [ ] Run this before edits and confirm nonzero RED output is captured:
    ```bash
    mkdir -p .omo/evidence
    set +e
    python3 tests/autoresearch_skill_contract_test.py > .omo/evidence/task-1-red-baseline.txt 2>&1
    code=$?
    set -e
    test "$code" -ne 0
    rg -n "SCORE [0-9]+/12" .omo/evidence/task-1-red-baseline.txt
    ```
  - [ ] Confirm pytest is not assumed:
    ```bash
    set +e
    python3 -m pytest --version > .omo/evidence/task-1-pytest-version.txt 2>&1
    code=$?
    set -e
    test "$code" -ne 0
    rg -n "No module named pytest" .omo/evidence/task-1-pytest-version.txt
    ```
  - [ ] If `tests/autoresearch_skill_contract_test.py` is untracked, stage it for the test-first commit:
    ```bash
    git status --short tests/autoresearch_skill_contract_test.py
    ```

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: RED scorer is reproducible
    Tool:     bash
    Steps:    mkdir -p .omo/evidence; set +e; python3 tests/autoresearch_skill_contract_test.py > .omo/evidence/task-1-red-baseline.txt 2>&1; code=$?; set -e; test "$code" -ne 0; rg -n "SCORE [0-9]+/12" .omo/evidence/task-1-red-baseline.txt
    Expected: command exits 0 overall after proving the scorer itself exited nonzero and printed SCORE less than 12/12
    Evidence: .omo/evidence/task-1-red-baseline.txt

  Scenario: Named function is directly callable
    Tool:     bash
    Steps:    mkdir -p .omo/evidence; set +e; python3 -c "import importlib.util; spec=importlib.util.spec_from_file_location('contract','tests/autoresearch_skill_contract_test.py'); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); m.test_autoresearch_skill_scores_100()" > .omo/evidence/task-1-red-function.txt 2>&1; code=$?; set -e; test "$code" -ne 0
    Expected: direct function call exits nonzero before implementation, proving the named test is RED
    Evidence: .omo/evidence/task-1-red-function.txt
  ```

  Commit: YES | Message: `test(autoresearch-skill): lock deterministic contract scorer` | Files: [tests/autoresearch_skill_contract_test.py]

- [ ] 2. Finish root skill contract exact-token fixes

  What to do: Reconcile the current dirty edits in `skills/autoresearch-skill/SKILL.md` and `SKILL.ko.md`. Add the exact canonical strings required by the scorer: lowercase `ask one concise question`, `Verify score and Guard checks are separate`, and `Do not change the eval set to make a mutation pass`. Keep the current trigger, missing-target, support-file-read-order, OMX bridge, and Manual QA sections, but remove duplicate examples introduced by the partial edit. Keep Korean mirror structure aligned and include the same machine-readable phrases where the scorer requires exact English tokens.
  Must NOT do: Do not rewrite the whole skill, do not remove existing Korean output-language behavior, and do not mutate `.hypercore`/`.omx` artifacts in this task.

  Parallelization: Can parallel: NO | Wave 2 | Blocks: [3, 5, 6, 7] | Blocked by: [1]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/autoresearch-skill/SKILL.md:52` - current `<missing_target_behavior>` section exists but misses the exact lowercase token expected by the boundary scenario.
  - Pattern:  `skills/autoresearch-skill/SKILL.md:96` - required inputs and guard policy; add exact Verify/Guard and immutable-eval wording here or nearby.
  - Pattern:  `skills/autoresearch-skill/SKILL.md:132` - current support-file read order already satisfies discoverability.
  - Pattern:  `skills/autoresearch-skill/SKILL.md:172` - Manual QA gate already exists and must stay.
  - API/Type: `tests/autoresearch_skill_contract_test.py:119` - `missing_target_handling` required strings.
  - API/Type: `tests/autoresearch_skill_contract_test.py:144` - `binary_eval_contract` required strings.
  - Test:     `tests/autoresearch_skill_contract_test.py:221` - `boundary` and `regression` scenario tokens.
  - Pattern:  `skills/skill-maker/SKILL.md:119` - material markdown skill edits require Korean sibling alignment.
  - External: none; `AGENTS.md:8-12` keeps authority local.

  Acceptance criteria (agent-executable only):
  - [ ] Boundary and regression scenarios pass:
    ```bash
    python3 tests/autoresearch_skill_contract_test.py --scenario boundary
    python3 tests/autoresearch_skill_contract_test.py --scenario regression
    ```
  - [ ] Core contract subset passes:
    ```bash
    python3 -c "import importlib.util; spec=importlib.util.spec_from_file_location('contract','tests/autoresearch_skill_contract_test.py'); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); rows={n: ok for n, ok, _ in m.checks()}; required=['metadata_trigger_boundary','concrete_localized_examples','missing_target_handling','support_read_order_explicit','binary_eval_contract','artifact_completion_bridge','manual_qa_gate','korean_mirror_alignment','direct_resource_integrity']; failed=[n for n in required if not rows.get(n)]; assert not failed, failed; print('core contract subset PASS')"
    ```
  - [ ] Static skill validation still exits 0:
    ```bash
    node skills/skill-tester/scripts/validate-skill.mjs skills/autoresearch-skill
    ```

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: Missing target boundary
    Tool:     tmux
    Steps:    mkdir -p .omo/evidence; tmux new-session -d -s arskill-boundary -c /Users/alpox/Desktop/dev/kood/hypercore 'zsh -lc "python3 tests/autoresearch_skill_contract_test.py --scenario boundary; printf \"\nEXIT:%s\n\" $?; sleep 5"'; sleep 1; tmux capture-pane -pt arskill-boundary -S -200 > .omo/evidence/task-2-core-boundary.txt; tmux kill-session -t arskill-boundary
    Expected: transcript contains SCENARIO boundary PASS and EXIT:0
    Evidence: .omo/evidence/task-2-core-boundary.txt

  Scenario: Neighbor routing regression
    Tool:     tmux
    Steps:    mkdir -p .omo/evidence; tmux new-session -d -s arskill-regression -c /Users/alpox/Desktop/dev/kood/hypercore 'zsh -lc "python3 tests/autoresearch_skill_contract_test.py --scenario regression; printf \"\nEXIT:%s\n\" $?; sleep 5"'; sleep 1; tmux capture-pane -pt arskill-regression -S -200 > .omo/evidence/task-2-core-regression.txt; tmux kill-session -t arskill-regression
    Expected: transcript contains SCENARIO regression PASS and EXIT:0
    Evidence: .omo/evidence/task-2-core-regression.txt
  ```

  Commit: NO | Message: `fix(autoresearch-skill): finish deterministic execution contract` | Files: [skills/autoresearch-skill/SKILL.md, skills/autoresearch-skill/SKILL.ko.md]

- [ ] 3. Produce final `.hypercore` deterministic run artifacts

  What to do: Update `.hypercore/autoresearch-skill/autoresearch-skill/` to represent a deterministic RED->GREEN run: baseline score below 100, final/best score 100.0, at least two experiments, first experiment `baseline`, final experiment `keep` or `keep-reworked`, Korean score explanation, final report, changelog, source ledger, trace summary, baseline snapshot, and details. Keep `results.tsv`, `results.json`, and `results.js` synchronized by rerunning the renderer.
  Must NOT do: Do not hardcode run-specific data into `dashboard.html`; use `results.json`, standard detail files, and `scripts/render-dashboard.sh`.

  Parallelization: Can parallel: YES | Wave 3 | Blocks: [4, 6, 7] | Blocked by: [2]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/autoresearch-skill/references/artifact-spec.md:5` - required workspace shape and base artifact list.
  - Pattern:  `skills/autoresearch-skill/references/artifact-spec.md:38` - support-file changes require `baseline-files.json` or `baseline/`.
  - API/Type: `skills/autoresearch-skill/references/artifact-spec.md:88` - `results.tsv` header and status conventions.
  - API/Type: `skills/autoresearch-skill/references/artifact-spec.md:105` - `results.json` minimum shape and required experiment fields.
  - Pattern:  `skills/autoresearch-skill/references/artifact-spec.md:187` - generated dashboard and `file://` fallback requirements.
  - Pattern:  `skills/autoresearch-skill/references/reporting-and-score-explanation.md:20` - required Korean `score_explanation` fields.
  - Pattern:  `skills/autoresearch-skill/scripts/render-dashboard.sh:42` - renderer top-level `results.json` validation.
  - Pattern:  `skills/autoresearch-skill/scripts/render-dashboard.sh:64` - renderer experiment-key/status validation.
  - API/Type: `tests/autoresearch_skill_contract_test.py:48` - artifact file list expected by the scorer.
  - API/Type: `tests/autoresearch_skill_contract_test.py:66` - artifact JSON shape expected by the scorer.
  - External: none; `.gitignore:36` confirms `.hypercore/` is ignored runtime state.

  Acceptance criteria (agent-executable only):
  - [ ] Artifact subset passes:
    ```bash
    python3 -c "import importlib.util; spec=importlib.util.spec_from_file_location('contract','tests/autoresearch_skill_contract_test.py'); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); rows={n: ok for n, ok, _ in m.checks()}; required=['artifact_files','artifact_json']; failed=[n for n in required if not rows.get(n)]; assert not failed, failed; print('artifact subset PASS')"
    ```
  - [ ] JSON and renderer validate:
    ```bash
    python3 -m json.tool .hypercore/autoresearch-skill/autoresearch-skill/results.json > .omo/evidence/task-3-results-json-pretty.json
    skills/autoresearch-skill/scripts/render-dashboard.sh .hypercore/autoresearch-skill/autoresearch-skill
    test -f .hypercore/autoresearch-skill/autoresearch-skill/results.js
    ```
  - [ ] Results record RED->GREEN semantics:
    ```bash
    python3 -c "import json; p='.hypercore/autoresearch-skill/autoresearch-skill/results.json'; d=json.load(open(p)); assert d['status']=='complete'; assert d['baseline_score'] < 100.0; assert d['best_score'] == 100.0; assert len(d['experiments']) >= 2; assert d['experiments'][0]['status']=='baseline'; assert d['experiments'][-1]['status'] in {'keep','keep-reworked'}; print('results RED->GREEN PASS')"
    ```

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: Happy artifact run
    Tool:     tmux
    Steps:    mkdir -p .omo/evidence; tmux new-session -d -s arskill-happy -c /Users/alpox/Desktop/dev/kood/hypercore 'zsh -lc "python3 tests/autoresearch_skill_contract_test.py --scenario happy; printf \"\nEXIT:%s\n\" $?; sleep 5"'; sleep 1; tmux capture-pane -pt arskill-happy -S -200 > .omo/evidence/task-3-artifacts-happy.txt; tmux kill-session -t arskill-happy
    Expected: transcript contains SCENARIO happy PASS and EXIT:0
    Evidence: .omo/evidence/task-3-artifacts-happy.txt

  Scenario: Renderer rejects malformed completion
    Tool:     bash
    Steps:    cp .hypercore/autoresearch-skill/autoresearch-skill/results.json /private/tmp/arskill-results.json; python3 -c "import json; p='/private/tmp/arskill-results.json'; d=json.load(open(p)); d.pop('score_explanation', None); open(p,'w').write(json.dumps(d, ensure_ascii=False))"; mkdir -p /private/tmp/arskill-bad; cp /private/tmp/arskill-results.json /private/tmp/arskill-bad/results.json; set +e; skills/autoresearch-skill/scripts/render-dashboard.sh /private/tmp/arskill-bad > .omo/evidence/task-3-renderer-error.txt 2>&1; code=$?; set -e; test "$code" -ne 0; rg -n "score_explanation|score-explanation" .omo/evidence/task-3-renderer-error.txt
    Expected: renderer fails because complete results lack a score explanation
    Evidence: .omo/evidence/task-3-renderer-error.txt
  ```

  Commit: NO | Message: `test(autoresearch-skill): record deterministic green artifacts` | Files: [.hypercore/autoresearch-skill/autoresearch-skill/**]

- [ ] 4. Produce OMX bridge state and approved completion artifact

  What to do: Create or update `.omx/state/autoresearch-skill/autoresearch-state.json` and `.omx/specs/autoresearch-autoresearch-skill/result.json` so the bridge points to `.hypercore/autoresearch-skill/autoresearch-skill/results.json`, uses `validation_mode: "prompt-architect-artifact"`, and records `architect_review.verdict: "approved"`. Keep the completion artifact consistent with the final deterministic score.
  Must NOT do: Do not claim `$autoresearch` completion without both state and completion JSON. Do not write bridge paths that only work on this machine as absolute paths.

  Parallelization: Can parallel: YES | Wave 4 | Blocks: [6, 7] | Blocked by: [3]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/autoresearch-skill/SKILL.md:147` - bridge contract says `.hypercore` logs alone are not completion.
  - Pattern:  `skills/autoresearch-skill/SKILL.md:155` - state storage keys and concrete self-run path guidance.
  - Pattern:  `skills/autoresearch-skill/rules/validation-and-exit.md:78` - `$autoresearch` completion artifact validation requirements.
  - API/Type: `tests/autoresearch_skill_contract_test.py:82` - exact paths and JSON keys expected by the scorer.
  - Pattern:  `.omo/ulw-loop/019ea0e6-0cfe-7b31-aa98-388e46af94ed/brief.md:10` - requires approved completion artifact.
  - External: none; `.gitignore:33` confirms `.omx/` is ignored runtime state.

  Acceptance criteria (agent-executable only):
  - [ ] Completion subset passes:
    ```bash
    python3 -c "import importlib.util; spec=importlib.util.spec_from_file_location('contract','tests/autoresearch_skill_contract_test.py'); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); rows={n: ok for n, ok, _ in m.checks()}; assert rows['completion_artifact'], 'completion_artifact failed'; print('completion artifact PASS')"
    ```
  - [ ] Full scorer reaches 12/12 after Tasks 2-4:
    ```bash
    python3 tests/autoresearch_skill_contract_test.py | tee .omo/evidence/task-4-full-score.txt
    rg -n "SCORE 12/12" .omo/evidence/task-4-full-score.txt
    ```
  - [ ] Direct named test function passes:
    ```bash
    python3 -c "import importlib.util; spec=importlib.util.spec_from_file_location('contract','tests/autoresearch_skill_contract_test.py'); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); m.test_autoresearch_skill_scores_100(); print('test_autoresearch_skill_scores_100 PASS')"
    ```

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: Completion bridge happy path
    Tool:     tmux
    Steps:    mkdir -p .omo/evidence; tmux new-session -d -s arskill-completion -c /Users/alpox/Desktop/dev/kood/hypercore 'zsh -lc "python3 tests/autoresearch_skill_contract_test.py; printf \"\nEXIT:%s\n\" $?; sleep 5"'; sleep 1; tmux capture-pane -pt arskill-completion -S -300 > .omo/evidence/task-4-completion-score.txt; tmux kill-session -t arskill-completion
    Expected: transcript contains SCORE 12/12 and EXIT:0
    Evidence: .omo/evidence/task-4-completion-score.txt

  Scenario: Completion bridge path alignment
    Tool:     bash
    Steps:    python3 -c "import json; s=json.load(open('.omx/state/autoresearch-skill/autoresearch-state.json')); c=json.load(open('.omx/specs/autoresearch-autoresearch-skill/result.json')); assert s['completion_artifact_path']=='.omx/specs/autoresearch-autoresearch-skill/result.json'; assert s['output_artifact_path']=='.hypercore/autoresearch-skill/autoresearch-skill/results.json'; assert c['architect_review']['verdict']=='approved'; print('bridge path alignment PASS')" > .omo/evidence/task-4-bridge-paths.txt
    Expected: evidence contains bridge path alignment PASS
    Evidence: .omo/evidence/task-4-bridge-paths.txt
  ```

  Commit: NO | Message: `test(autoresearch-skill): record approved autoresearch bridge` | Files: [.omx/specs/autoresearch-autoresearch-skill/result.json, .omx/state/autoresearch-skill/autoresearch-state.json]

- [ ] 5. Sync plugin mirror and tracked source/test commit

  What to do: Copy the final tracked `skills/autoresearch-skill/**` files into `plugins/hypercore/skills/autoresearch-skill/**`, including missing `references/reporting-and-score-explanation.md` and `.ko.md`. Keep the source skill and plugin mirror byte-identical for this skill. Stage/commit the tracked test, root skill, and plugin mirror changes together after Task 2 is GREEN.
  Must NOT do: Do not run broad mirror fixes for unrelated untracked `skills/git-issue/`. Do not use `scripts/validate-codex-plugin.mjs` as the only gate while `skills/git-issue/` remains untracked, because that script checks all root skill directories.

  Parallelization: Can parallel: YES | Wave 3 | Blocks: [7] | Blocked by: [2]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `README.md:54` - Codex plugin source is `plugins/hypercore` and includes a `skills/` mirror.
  - Pattern:  `README.md:235` - root skills and plugin mirror are both part of repository structure.
  - API/Type: `scripts/validate-codex-plugin.mjs:97` - plugin skill file list must mirror root skills.
  - API/Type: `scripts/validate-codex-plugin.mjs:102` - plugin file content must match root file content.
  - Pattern:  `skills/autoresearch-skill/SKILL.md:7` - direct support-file links must exist in both root and plugin mirrors.
  - Test:     `node skills/skill-tester/scripts/validate-skill.mjs skills/autoresearch-skill` - root static validation.
  - External: none; `AGENTS.md:24` says project-local rules outrank global settings.

  Acceptance criteria (agent-executable only):
  - [ ] Targeted mirror diff is empty:
    ```bash
    mkdir -p .omo/evidence
    if diff -qr skills/autoresearch-skill plugins/hypercore/skills/autoresearch-skill > .omo/evidence/task-5-plugin-mirror.diff; then :; else cat .omo/evidence/task-5-plugin-mirror.diff; exit 1; fi
    test ! -s .omo/evidence/task-5-plugin-mirror.diff
    ```
  - [ ] Full plugin validator is either green or only blocked by the pre-existing unrelated untracked `skills/git-issue/` directory:
    ```bash
    set +e
    node scripts/validate-codex-plugin.mjs > .omo/evidence/task-5-plugin-validator.txt 2>&1
    code=$?
    set -e
    if [ "$code" -ne 0 ]; then rg -n "plugins/hypercore/skills must mirror root skills directories" .omo/evidence/task-5-plugin-validator.txt; git status --short skills/git-issue; fi
    ```
  - [ ] Tracked change set is limited to the contract test, root autoresearch skill files, plugin mirror files, and the plan/evidence files intentionally produced:
    ```bash
    git status --short
    ```

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: Mirror is byte-identical for autoresearch-skill
    Tool:     bash
    Steps:    mkdir -p .omo/evidence; diff -qr skills/autoresearch-skill plugins/hypercore/skills/autoresearch-skill > .omo/evidence/task-5-plugin-mirror.diff; test ! -s .omo/evidence/task-5-plugin-mirror.diff
    Expected: diff command exits 0 and evidence file is empty
    Evidence: .omo/evidence/task-5-plugin-mirror.diff

  Scenario: Unrelated untracked skill is not touched
    Tool:     bash
    Steps:    git status --short skills/git-issue > .omo/evidence/task-5-unrelated-git-issue.txt; rg -n "^\\?\\? skills/git-issue/" .omo/evidence/task-5-unrelated-git-issue.txt
    Expected: evidence confirms `skills/git-issue/` remains untracked and untouched
    Evidence: .omo/evidence/task-5-unrelated-git-issue.txt
  ```

  Commit: YES | Message: `fix(autoresearch-skill): reach deterministic local contract` | Files: [tests/autoresearch_skill_contract_test.py, skills/autoresearch-skill/**, plugins/hypercore/skills/autoresearch-skill/**]

- [ ] 6. Execute tmux manual QA and record evidence

  What to do: Run the happy, boundary, and regression scenarios through tmux and capture transcripts, cleanup receipts, and final score evidence. Add references to these evidence paths in `.hypercore/autoresearch-skill/autoresearch-skill/trace-summary.md` or `final-report.md` so the runtime artifacts explain Manual QA completion.
  Must NOT do: Do not mark Manual QA complete from direct shell commands alone; the evidence must come from tmux transcript capture.

  Parallelization: Can parallel: NO | Wave 5 | Blocks: [7] | Blocked by: [2, 3, 4]

  References (executor has NO interview context - be exhaustive):
  - Pattern:  `skills/autoresearch-skill/SKILL.md:172` - Manual QA gate requires real surface evidence before completion.
  - Test:     `tests/autoresearch_skill_contract_test.py:221` - script scenario commands map to happy, boundary, and regression QA.
  - Pattern:  `skills/skill-tester/rules/scenario-design.md:29` - scenario evidence must include prompt/condition, expected behavior, observed behavior, result, and evidence.
  - Pattern:  `skills/skill-tester/rules/evidence-reporting.md:22` - strong evidence includes deterministic script output and scenario table.
  - Pattern:  `.omo/ulw-loop/019ea0e6-0cfe-7b31-aa98-388e46af94ed/brief.md:8` - requires tmux manual QA for happy, boundary, and regression scenarios.
  - External: none.

  Acceptance criteria (agent-executable only):
  - [ ] Happy transcript contains pass and cleanup receipt:
    ```bash
    rg -n "SCENARIO happy PASS|EXIT:0|tmux kill-session" .omo/evidence/task-6-happy-tmux.txt .omo/evidence/task-6-happy-cleanup.txt
    ```
  - [ ] Boundary transcript contains pass and cleanup receipt:
    ```bash
    rg -n "SCENARIO boundary PASS|EXIT:0|tmux kill-session" .omo/evidence/task-6-boundary-tmux.txt .omo/evidence/task-6-boundary-cleanup.txt
    ```
  - [ ] Regression transcript contains pass and cleanup receipt:
    ```bash
    rg -n "SCENARIO regression PASS|EXIT:0|tmux kill-session" .omo/evidence/task-6-regression-tmux.txt .omo/evidence/task-6-regression-cleanup.txt
    ```
  - [ ] Final score transcript contains `SCORE 12/12`:
    ```bash
    rg -n "SCORE 12/12|EXIT:0" .omo/evidence/task-6-score-tmux.txt
    ```

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: Happy path tmux QA
    Tool:     tmux
    Steps:    mkdir -p .omo/evidence; tmux new-session -d -s arskill-qa-happy -c /Users/alpox/Desktop/dev/kood/hypercore 'zsh -lc "python3 tests/autoresearch_skill_contract_test.py --scenario happy; printf \"\nEXIT:%s\n\" $?; sleep 5"'; sleep 1; tmux capture-pane -pt arskill-qa-happy -S -200 > .omo/evidence/task-6-happy-tmux.txt; tmux kill-session -t arskill-qa-happy > .omo/evidence/task-6-happy-cleanup.txt 2>&1 || true; printf "tmux kill-session arskill-qa-happy cleanup attempted\n" >> .omo/evidence/task-6-happy-cleanup.txt
    Expected: transcript contains SCENARIO happy PASS and EXIT:0; cleanup file records kill-session attempt
    Evidence: .omo/evidence/task-6-happy-tmux.txt

  Scenario: Boundary tmux QA
    Tool:     tmux
    Steps:    mkdir -p .omo/evidence; tmux new-session -d -s arskill-qa-boundary -c /Users/alpox/Desktop/dev/kood/hypercore 'zsh -lc "python3 tests/autoresearch_skill_contract_test.py --scenario boundary; printf \"\nEXIT:%s\n\" $?; sleep 5"'; sleep 1; tmux capture-pane -pt arskill-qa-boundary -S -200 > .omo/evidence/task-6-boundary-tmux.txt; tmux kill-session -t arskill-qa-boundary > .omo/evidence/task-6-boundary-cleanup.txt 2>&1 || true; printf "tmux kill-session arskill-qa-boundary cleanup attempted\n" >> .omo/evidence/task-6-boundary-cleanup.txt
    Expected: transcript contains SCENARIO boundary PASS and EXIT:0; cleanup file records kill-session attempt
    Evidence: .omo/evidence/task-6-boundary-tmux.txt

  Scenario: Regression tmux QA
    Tool:     tmux
    Steps:    mkdir -p .omo/evidence; tmux new-session -d -s arskill-qa-regression -c /Users/alpox/Desktop/dev/kood/hypercore 'zsh -lc "python3 tests/autoresearch_skill_contract_test.py --scenario regression; printf \"\nEXIT:%s\n\" $?; sleep 5"'; sleep 1; tmux capture-pane -pt arskill-qa-regression -S -200 > .omo/evidence/task-6-regression-tmux.txt; tmux kill-session -t arskill-qa-regression > .omo/evidence/task-6-regression-cleanup.txt 2>&1 || true; printf "tmux kill-session arskill-qa-regression cleanup attempted\n" >> .omo/evidence/task-6-regression-cleanup.txt
    Expected: transcript contains SCENARIO regression PASS and EXIT:0; cleanup file records kill-session attempt
    Evidence: .omo/evidence/task-6-regression-tmux.txt
  ```

  Commit: NO | Message: `test(autoresearch-skill): capture tmux manual qa evidence` | Files: [.omo/evidence/task-6-*.txt, .hypercore/autoresearch-skill/autoresearch-skill/trace-summary.md, .hypercore/autoresearch-skill/autoresearch-skill/final-report.md]

- [ ] 7. Run final local gates and prepare reviewer handoff

  What to do: Run all deterministic gates in one final evidence bundle, verify no source/artifact contradictions remain, and prepare the final reviewer handoff. The handoff must include changed tracked files, ignored runtime artifact paths, all `.omo/evidence/` paths, current git status, and note that `skills/git-issue/` is unrelated and untouched.
  Must NOT do: Do not declare complete from local checks alone; final verification wave and `codex-ultrawork-reviewer` approval still follow.

  Parallelization: Can parallel: NO | Wave 5 | Blocks: [final verification] | Blocked by: [2, 3, 4, 5, 6]

  References (executor has NO interview context - be exhaustive):
  - Test:     `tests/autoresearch_skill_contract_test.py:209` - script score prints `SCORE N/12`.
  - Test:     `tests/autoresearch_skill_contract_test.py:256` - named test function must pass.
  - Pattern:  `skills/autoresearch-skill/rules/validation-and-exit.md:53` - execution artifact validation.
  - Pattern:  `skills/autoresearch-skill/rules/validation-and-exit.md:90` - final claim validation.
  - Pattern:  `skills/autoresearch-skill/references/reporting-and-score-explanation.md:149` - final response checklist.
  - Pattern:  `.omo/ulw-loop/019ea0e6-0cfe-7b31-aa98-388e46af94ed/brief.md:11` - requires final `codex-ultrawork-reviewer` approval.
  - External: none.

  Acceptance criteria (agent-executable only):
  - [ ] Final command bundle exits 0:
    ```bash
    {
      python3 tests/autoresearch_skill_contract_test.py
      python3 -c "import importlib.util; spec=importlib.util.spec_from_file_location('contract','tests/autoresearch_skill_contract_test.py'); m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m); m.test_autoresearch_skill_scores_100(); print('test_autoresearch_skill_scores_100 PASS')"
      python3 tests/autoresearch_skill_contract_test.py --scenario happy
      python3 tests/autoresearch_skill_contract_test.py --scenario boundary
      python3 tests/autoresearch_skill_contract_test.py --scenario regression
      node skills/skill-tester/scripts/validate-skill.mjs skills/autoresearch-skill
      python3 -m json.tool .hypercore/autoresearch-skill/autoresearch-skill/results.json >/dev/null
      python3 -m json.tool .omx/specs/autoresearch-autoresearch-skill/result.json >/dev/null
      python3 -m json.tool .omx/state/autoresearch-skill/autoresearch-state.json >/dev/null
      skills/autoresearch-skill/scripts/render-dashboard.sh .hypercore/autoresearch-skill/autoresearch-skill
      diff -qr skills/autoresearch-skill plugins/hypercore/skills/autoresearch-skill
    } | tee .omo/evidence/task-7-final-local-gates.txt
    ```
  - [ ] Final evidence contains the decisive pass markers:
    ```bash
    rg -n "SCORE 12/12|test_autoresearch_skill_scores_100 PASS|SCENARIO happy PASS|SCENARIO boundary PASS|SCENARIO regression PASS|core contract subset PASS|render|렌더 완료" .omo/evidence/task-7-final-local-gates.txt .omo/evidence/task-2-core-boundary.txt .omo/evidence/task-6-score-tmux.txt
    ```
  - [ ] Handoff file exists:
    ```bash
    test -f .omo/evidence/task-7-reviewer-handoff.md
    rg -n "changed tracked files|ignored runtime artifacts|tmux evidence|skills/git-issue" .omo/evidence/task-7-reviewer-handoff.md
    ```

  QA scenarios (MANDATORY - task incomplete without these):
  > Name the exact tool AND its exact invocation - not "verify it works". Browser use: use Chrome to drive the page; if Chrome is not available, download and use agent-browser (https://github.com/vercel-labs/agent-browser). Computer use: OS-level GUI automation for a non-browser desktop app.
  ```
  Scenario: Final deterministic score
    Tool:     tmux
    Steps:    mkdir -p .omo/evidence; tmux new-session -d -s arskill-final-score -c /Users/alpox/Desktop/dev/kood/hypercore 'zsh -lc "python3 tests/autoresearch_skill_contract_test.py; printf \"\nEXIT:%s\n\" $?; sleep 5"'; sleep 1; tmux capture-pane -pt arskill-final-score -S -300 > .omo/evidence/task-6-score-tmux.txt; tmux kill-session -t arskill-final-score
    Expected: transcript contains SCORE 12/12 and EXIT:0
    Evidence: .omo/evidence/task-6-score-tmux.txt

  Scenario: Reviewer handoff completeness
    Tool:     bash
    Steps:    test -f .omo/evidence/task-7-reviewer-handoff.md; rg -n "task-1-red-baseline|task-6-happy-tmux|task-6-boundary-tmux|task-6-regression-tmux|results.json|autoresearch-state.json" .omo/evidence/task-7-reviewer-handoff.md
    Expected: handoff names RED evidence, all tmux scenarios, results artifact, and bridge state
    Evidence: .omo/evidence/task-7-reviewer-handoff.md
  ```

  Commit: NO | Message: `test(autoresearch-skill): finalize local gate evidence` | Files: [.omo/evidence/task-7-*.txt, .omo/evidence/task-7-reviewer-handoff.md]

## Final verification wave (MANDATORY - after all implementation tasks)
> Runs in PARALLEL. ALL must APPROVE. Surface results to the caller and wait for an explicit "okay" before declaring complete.
- [ ] F1. Plan compliance audit - every task done, every acceptance criterion met
- [ ] F2. Code quality review - diagnostics clean, idioms match, no dead code
- [ ] F3. Real manual QA - every QA scenario executed with evidence captured
- [ ] F4. Scope fidelity - nothing extra shipped beyond Must-Have, nothing Must-NOT-Have introduced
- [ ] F5. Ultrawork reviewer approval - spawn `codex-ultrawork-reviewer` with `.omo/evidence/task-7-reviewer-handoff.md`, tracked diff, ignored artifact paths, and final gate output; require unconditional approval

## Commit strategy
- One logical change per commit. Conventional Commits (`<type>(<scope>): <subject>` body + footer).
- Atomic: every commit builds and passes tests on its own.
- No "WIP" / "fix typo squash later" commits on the final branch - clean up before merge.
- Reference the plan file path in the final commit footer: `Plan: .omo/plans/autoresearch-skill-100-local-eval.md`.

## Success criteria
- All Must-Have shipped; all QA scenarios pass with captured evidence; F1-F5 approved; commit history clean.
