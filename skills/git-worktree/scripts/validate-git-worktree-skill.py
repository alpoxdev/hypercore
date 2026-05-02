#!/usr/bin/env python3
"""Validate git-worktree skill edge-case coverage.

This is a static regression harness for a documentation-first skill. It checks
that the operative skill guidance covers language localization, create→enter
handoff, and current-worktree removal safety without requiring destructive Git
worktree operations in the real repository.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "SKILL.md"
KO = ROOT / "SKILL.ko.md"
RULES = ROOT / "rules" / "worktree-lifecycle.md"
SURVEY = ROOT / "references" / "source-survey.md"

EXACT_ENGLISH_OPERATION_MENU = "What worktree " + "operation do you want"
KOREAN_INTENT_QUESTION = "이 worktree에서 어떤 작업을 할 예정인가요?"
KOREAN_OPERATION_QUESTION = "어떤 worktree 작업을 원하시나요?"
KOREAN_OPERATION_OPTIONS = ["생성", "목록", "열기/이동", "삭제", "정리", "복구", "잠금"]
DIRECT_ARGUMENT_INVOCATION = "git-worktree <ARGUMENT>"


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return ""


def has_frontmatter(text: str) -> bool:
    if not text.startswith("---\n"):
        return False
    end = text.find("\n---", 4)
    if end == -1:
        return False
    frontmatter = text[4:end]
    return "name:" in frontmatter and "description:" in frontmatter


def contains_all(text: str, needles: list[str]) -> bool:
    return all(needle in text for needle in needles)


def contains_korean_operation_menu(text: str) -> bool:
    return contains_all(text, [KOREAN_OPERATION_QUESTION, *KOREAN_OPERATION_OPTIONS])


def check(name: str, ok: bool, detail: str) -> dict[str, object]:
    return {"id": name, "pass": bool(ok), "detail": detail}


def main() -> int:
    core = read(CORE)
    ko = read(KO)
    rules = read(RULES)
    survey = read(SURVEY)
    combined = "\n".join([core, ko, rules])

    core_lines = len(core.splitlines())
    support_refs = re.findall(r"^@(rules|references)/[^\n]+$", core, flags=re.MULTILINE)
    source_count = sum(1 for line in survey.splitlines() if re.match(r"^\d+\. \*\*", line))

    checks = [
        check(
            "frontmatter_present",
            has_frontmatter(core) and has_frontmatter(ko),
            "SKILL.md and SKILL.ko.md must retain parseable metadata blocks.",
        ),
        check(
            "core_under_300_lines",
            core_lines < 300,
            f"SKILL.md has {core_lines} lines; keep core instructions lean.",
        ),
        check(
            "one_level_support_refs",
            support_refs == ["rules", "references"],
            "Core skill should link only the direct rules and references files.",
        ),
        check(
            "korean_intent_question_present",
            contains_all(core, [KOREAN_INTENT_QUESTION])
            and contains_all(ko, [KOREAN_INTENT_QUESTION])
            and contains_all(rules, [KOREAN_INTENT_QUESTION]),
            "Ambiguous create requests from Korean users need a Korean work-intent question.",
        ),
        check(
            "korean_operation_question_present",
            contains_korean_operation_menu(ko) and contains_korean_operation_menu(rules),
            "Only truly ambiguous operation selection should use a localized Korean menu.",
        ),
        check(
            "exact_english_operation_menu_absent",
            EXACT_ENGLISH_OPERATION_MENU not in combined,
            "The user-reported English operation menu must not appear in operative guidance.",
        ),
        check(
            "infer_before_asking",
            contains_all(combined, ["infer the operation", "문맥에서 추론"]),
            "Agents should infer create/open/remove/etc. before asking another question.",
        ),
        check(
            "direct_argument_create_fast_path",
            contains_all(core, [DIRECT_ARGUMENT_INVOCATION, "do not ask what worktree to create", "positional argument"])
            and contains_all(ko, [DIRECT_ARGUMENT_INVOCATION, "되묻지", "위치 인자"])
            and contains_all(rules, [DIRECT_ARGUMENT_INVOCATION, "Direct argument fast path", "do not ask what worktree to create"]),
            "Direct git-worktree <ARGUMENT> invocations should create from the argument without a work-intent question.",
        ),
        check(
            "create_not_done_until_context_moved",
            contains_all(core, ["creation is not complete until the active execution context has moved"])
            and contains_all(ko, ["생성은 새 worktree 컨텍스트로 전환된 뒤에 완료"]),
            "Creation must include moving the active context into the new worktree.",
        ),
        check(
            "create_enter_open_switch_single_operation",
            contains_all(core, ["create and enter/open/switch", "do not stop after `git worktree add`"])
            and contains_all(ko, ["생성하고 들어가/이동/전환/열어줘", "`git worktree add`만 하고 멈추지"])
            and contains_all(
                rules,
                [
                    "enter",
                    "open",
                    "switch",
                    "go into it",
                    "들어가",
                    "이동",
                    "전환",
                    "not complete until follow-up commands run from the new path",
                ],
            ),
            "Create+enter/open/switch requests should be treated as one completed operation.",
        ),
        check(
            "agent_workdir_and_parent_shell_cd",
            contains_all(core + rules, ["workdir=<path>", "cd <path>", "parent shell"])
            and contains_all(ko, ["부모 셸", "`cd <path>`"]),
            "Agent environments need workdir guidance and parent-shell cd reporting.",
        ),
        check(
            "post_create_status_verification",
            contains_all(core + rules, ["git -C <path> status --short --branch", "cd <path> && pwd"]),
            "Post-create examples should verify status and demonstrate entry.",
        ),
        check(
            "current_worktree_delete_safety",
            contains_all(core + rules, ["target_path", "main_path", "Refuse", "git worktree remove \"$target_path\""])
            or contains_all(core + rules, ["target_path", "main_path", "refuse", "git worktree remove \"$target_path\""]),
            "Deleting the current linked worktree must save target path, refuse main, move out, then remove saved target.",
        ),
        check(
            "dirty_remove_requires_explicit_force",
            contains_all(rules, ["Only use force when explicitly requested", "dirty current-worktree deletion"]),
            "Dirty worktree deletion must require explicit force/discard intent.",
        ),
        check(
            "nested_worktree_exclude_rule",
            contains_all(core + rules, [".hypercore/git-worktree/", "git rev-parse --git-path info/exclude", "local excludes"]),
            "Nested project-local worktrees need local exclude protection.",
        ),
        check(
            "validation_checklist_covers_new_edges",
            contains_all(core, [
                "validate-git-worktree-skill.py",
                "clarification questions match the user's language",
                "after creation, subsequent commands use the new worktree",
            ])
            and contains_all(ko, ["validate-git-worktree-skill.py", "영어 작업 메뉴", "새 worktree 경로를 작업 디렉터리"]),
            "Validation checklists should lock the language and post-create context edges.",
        ),
        check(
            "source_survey_still_available",
            source_count >= 10,
            f"Source survey should retain external rationale breadth; found {source_count} numbered sources.",
        ),
    ]

    passed = sum(1 for item in checks if item["pass"])
    result = {
        "score": passed,
        "total": len(checks),
        "percent": round(passed / len(checks) * 100, 2),
        "metrics": {"core_lines": core_lines, "source_count": source_count},
        "checks": checks,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if passed != len(checks):
        failed = ", ".join(item["id"] for item in checks if not item["pass"])
        print(f"FAILED: {failed}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
