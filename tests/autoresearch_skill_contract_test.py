#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "autoresearch-skill" / "SKILL.md"
SKILL_KO = ROOT / "skills" / "autoresearch-skill" / "SKILL.ko.md"
WORKSPACE = ROOT / ".hypercore" / "autoresearch-skill" / "autoresearch-skill"
COMPLETION = ROOT / ".omx" / "specs" / "autoresearch-autoresearch-skill" / "result.json"
STATE = ROOT / ".omx" / "state" / "autoresearch-skill" / "autoresearch-state.json"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def has_all(text: str, needles: list[str]) -> bool:
    return all(needle in text for needle in needles)


def direct_refs_exist(text: str) -> bool:
    for line in text.splitlines():
        if line.startswith("@"):
            if not (SKILL.parent / line[1:]).is_file():
                return False
    return True


def markdown_pairs_exist() -> bool:
    for path in (ROOT / "skills" / "autoresearch-skill").rglob("*.md"):
        if path.name.endswith(".ko.md"):
            source = path.with_name(path.name[:-6] + ".md")
            if not source.exists():
                return False
        else:
            ko = path.with_name(path.stem + ".ko.md")
            if not ko.exists():
                return False
    return True


def artifact_files_complete() -> bool:
    required = [
        "dashboard.html",
        "results.json",
        "results.js",
        "results.tsv",
        "changelog.md",
        "score-explanation.md",
        "final-report.md",
        "run-contract.md",
        "source-ledger.md",
        "trace-summary.md",
        "SKILL.md.baseline",
        "baseline-files.json",
    ]
    return all((WORKSPACE / item).is_file() for item in required)


def artifact_json_complete() -> bool:
    if not (WORKSPACE / "results.json").is_file():
        return False
    data = json.loads((WORKSPACE / "results.json").read_text(encoding="utf-8"))
    experiments = data.get("experiments", [])
    return (
        data.get("status") == "complete"
        and data.get("best_score") == 100.0
        and data.get("baseline_score", 100.0) < 100.0
        and data.get("score_explanation", {}).get("summary_ko")
        and len(experiments) >= 2
        and experiments[0].get("status") == "baseline"
        and experiments[-1].get("status") in {"keep", "keep-reworked"}
    )


def completion_artifact_complete() -> bool:
    if not COMPLETION.is_file() or not STATE.is_file():
        return False
    completion = json.loads(COMPLETION.read_text(encoding="utf-8"))
    state = json.loads(STATE.read_text(encoding="utf-8"))
    return (
        completion.get("architect_review", {}).get("verdict") == "approved"
        and state.get("validation_mode") == "prompt-architect-artifact"
        and state.get("completion_artifact_path") == ".omx/specs/autoresearch-autoresearch-skill/result.json"
        and state.get("output_artifact_path") == ".hypercore/autoresearch-skill/autoresearch-skill/results.json"
    )


def checks() -> list[tuple[str, bool, str]]:
    text = read(SKILL)
    ko = read(SKILL_KO) if SKILL_KO.exists() else ""
    return [
        (
            "metadata_trigger_boundary",
            "Use this skill when" in text
            and "Do not use" in text
            and "without a target" in text,
            "description must name in-scope use, out-of-scope use, and no-target behavior",
        ),
        (
            "concrete_localized_examples",
            has_all(
                text,
                [
                    "skills/foo/SKILL.md",
                    "이 스킬을 반복 실험으로 개선해서 점수 올려줘.",
                    "새 브라우저 QA 스킬을 만들어줘.",
                    "문서 문장을 자연스럽게 다듬어줘.",
                ],
            ),
            "positive and negative examples must include concrete Korean prompts, not placeholders",
        ),
        (
            "missing_target_handling",
            has_all(
                text,
                [
                    "<missing_target_behavior>",
                    "ask one concise question",
                    "Do not create or mutate",
                ],
            ),
            "plain autoresearch-skill invocation must ask before mutation/artifact writes",
        ),
        (
            "support_read_order_explicit",
            has_all(
                text,
                [
                    "<support_file_read_order>",
                    "references/self-test-pack.md",
                    "references/artifact-spec.md",
                    "rules/validation-and-exit.md",
                ],
            ),
            "core must expose next-file read order from core alone",
        ),
        (
            "binary_eval_contract",
            has_all(
                text,
                [
                    "3 to 6 binary evals",
                    "Verify score and Guard checks are separate",
                    "Do not change the eval set to make a mutation pass",
                ],
            ),
            "Verify/Guard and immutable eval set must be explicit",
        ),
        (
            "artifact_completion_bridge",
            has_all(
                text,
                [
                    ".omx/specs/autoresearch-[skill-name]/result.json",
                    "architect_review.verdict",
                    ".omx/state/[session-or-skill]/autoresearch-state.json",
                ],
            ),
            "OMX completion bridge paths and verdict gate must be concrete",
        ),
        (
            "manual_qa_gate",
            has_all(
                text,
                [
                    "<manual_qa_gate>",
                    "tmux",
                    "Manual QA",
                    "Tests alone do not prove completion",
                ],
            ),
            "manual QA must be required separately from tests",
        ),
        (
            "korean_mirror_alignment",
            "대상 없는 호출" in ko and "Manual QA" in ko and "100.0" in ko,
            "Korean mirror must carry the new trigger and verification contract",
        ),
        (
            "direct_resource_integrity",
            direct_refs_exist(text) and markdown_pairs_exist(),
            "direct @ references and markdown Korean pairs must exist",
        ),
        (
            "artifact_files",
            artifact_files_complete(),
            "completed autoresearch workspace must contain required files",
        ),
        (
            "artifact_json",
            artifact_json_complete(),
            "results.json must record baseline <100 and final 100 complete run",
        ),
        (
            "completion_artifact",
            completion_artifact_complete(),
            "OMX completion artifact and bridge state must be approved and path-aligned",
        ),
    ]


def run_score() -> int:
    rows = checks()
    passed = sum(1 for _, ok, _ in rows if ok)
    for name, ok, message in rows:
        status = "PASS" if ok else "FAIL"
        print(f"{status}\t{name}\t{message}")
    print(f"SCORE {passed}/{len(rows)}")
    if passed != len(rows):
        return 1
    return 0


def run_scenario(name: str) -> int:
    text = read(SKILL)
    scenarios = {
        "happy": [
            "repeated experiments",
            "baseline",
            "results.json",
            "dashboard.html",
            "SCENARIO happy PASS",
        ],
        "boundary": [
            "<missing_target_behavior>",
            "ask one concise question",
            "Do not create or mutate",
            "SCENARIO boundary PASS",
        ],
        "regression": [
            "Use `skill-maker`",
            "Use `skill-tester`",
            "Use `docs-maker`",
            "SCENARIO regression PASS",
        ],
    }
    if name not in scenarios:
        print(f"unknown scenario: {name}", file=sys.stderr)
        return 2
    needed = scenarios[name][:-1]
    missing = [needle for needle in needed if needle not in text]
    if missing:
        print(f"SCENARIO {name} FAIL missing: {', '.join(missing)}")
        return 1
    print(scenarios[name][-1])
    return 0


def test_autoresearch_skill_scores_100() -> None:
    failed = [(name, message) for name, ok, message in checks() if not ok]
    assert not failed, "\n".join(f"{name}: {message}" for name, message in failed)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--scenario", choices=["happy", "boundary", "regression"])
    args = parser.parse_args()
    raise SystemExit(run_scenario(args.scenario) if args.scenario else run_score())
