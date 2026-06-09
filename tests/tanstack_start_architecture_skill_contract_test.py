#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL_DIR = ROOT / "skills" / "tanstack-start-architecture"


def read(relative: str) -> str:
    return (SKILL_DIR / relative).read_text(encoding="utf-8")


def has_all(text: str, needles: list[str]) -> bool:
    return all(needle in text for needle in needles)


def direct_refs_exist() -> bool:
    text = read("SKILL.md")
    return all((SKILL_DIR / line[1:]).is_file() for line in text.splitlines() if line.startswith("@"))


def markdown_pairs_exist() -> bool:
    for path in SKILL_DIR.rglob("*.md"):
        if path.name.endswith(".ko.md"):
            source = path.with_name(path.name[:-6] + ".md")
            if not source.exists():
                return False
        else:
            ko = path.with_name(path.stem + ".ko.md")
            if not ko.exists():
                return False
    return True


def checks() -> list[tuple[str, bool, str]]:
    current = read("references/official/current-docs-2026-06-02.md")
    current_ko = read("references/official/current-docs-2026-06-02.ko.md")
    middleware = read("rules/middleware.md")
    middleware_ko = read("rules/middleware.ko.md")
    server_routes = read("rules/server-routes.md")
    server_routes_ko = read("rules/server-routes.ko.md")
    import_protection = read("rules/import-protection.md")
    drift = read("references/official/api-drift-notes.md")
    skill = read("SKILL.md")
    skill_ko = read("SKILL.ko.md")

    return [
        (
            "current_snapshot_date_and_sources",
            has_all(
                current,
                [
                    "checked_at: 2026-06-09",
                    "https://tanstack.com/start/latest/docs/framework/react/guide/middleware",
                    "https://tanstack.com/start/latest/docs/framework/react/guide/server-routes",
                    "https://tanstack.com/start/latest/docs/framework/react/guide/import-protection",
                    "https://tanstack.com/start/latest/docs/framework/react/getting-started",
                ],
            ),
            "current official snapshot must be refreshed to 2026-06-09 and cite current official pages",
        ),
        (
            "current_snapshot_api_facts",
            has_all(
                current,
                [
                    "`npx @tanstack/cli@latest create`",
                    "Request middleware uses `createMiddleware()`",
                    "Server function middleware uses `createMiddleware({ type: 'function' })`",
                    "Server function middleware input transformation/validation also uses `.inputValidator(...)`",
                    "Server functions use `.inputValidator(...)`",
                    "`server.handlers`",
                    "`createHandlers`",
                    "Type-only imports and re-exports are ignored by import protection",
                    "`behavior: 'error'`",
                ],
            ),
            "snapshot must distinguish current setup, middleware, server-route, import-protection APIs",
        ),
        (
            "middleware_rule_separates_types",
            has_all(
                middleware,
                [
                    "Request middleware uses `createMiddleware()`",
                    "Server function middleware uses `createMiddleware({ type: 'function' })`",
                    "Use `.inputValidator(...)` on server function middleware when the middleware owns data transformation or validation",
                    "Do not conflate middleware `.inputValidator(...)` with server-function `.inputValidator(...)`",
                ],
            )
            and "Use `.inputValidator()` on middleware" not in middleware,
            "middleware rule must separate request middleware, function middleware, and middleware `.inputValidator(...)`",
        ),
        (
            "server_routes_current_handlers",
            has_all(
                server_routes,
                [
                    "`server.handlers` object",
                    "`createHandlers` function",
                    "`server.middleware`",
                    "duplicate methods",
                    "wildcard/splat",
                ],
            ),
            "server route rule must include current handlers/createHandlers/middleware and collision behavior",
        ),
        (
            "import_protection_current_options",
            has_all(
                import_protection,
                [
                    "Type-only imports and re-exports are ignored",
                    "`behavior: 'error'`",
                    "`log`, `include`, `exclude`, `ignoreImporters`, `maxTraceDepth`, and `onViolation`",
                    "`excludeFiles: []`",
                ],
            ),
            "import protection rule must include current options and type-only import behavior",
        ),
        (
            "drift_notes_record_input_validator_api_split",
            has_all(
                drift,
                [
                    "`.inputValidator()` vs stale `.validator()` examples",
                    "Treat `.inputValidator(...)` as the current official Server Functions guide API for `createServerFn` input validation.",
                    "Server function `.inputValidator()` vs middleware `.inputValidator()`",
                    "They share a method name but belong to different chain objects",
                ],
            ),
            "drift notes must record current inputValidator API and prevent confusing server function and middleware validation APIs",
        ),
        (
            "korean_siblings_aligned",
            has_all(
                current_ko,
                [
                    "checked_at: 2026-06-09",
                    "`npx @tanstack/cli@latest create`",
                    "Request middleware는 `createMiddleware()`",
                    "Server function middleware는 `createMiddleware({ type: 'function' })`",
                    "middleware input transformation/validation도 `.inputValidator(...)`",
                ],
            )
            and "middleware가 데이터 검증을 책임질 때 `.inputValidator()`" not in middleware_ko
            and has_all(server_routes_ko, ["`createHandlers` function", "`server.middleware`"])
            and direct_refs_exist()
            and markdown_pairs_exist(),
            "Korean sibling files and direct references must stay aligned with English canonical files",
        ),
        (
            "core_skill_stays_lean_and_links_snapshot",
            "@references/official/current-docs-2026-06-02.md" in skill
            and "@references/official/current-docs-2026-06-02.ko.md" in skill_ko
            and len(skill.splitlines()) < 230
            and len(skill_ko.splitlines()) < 230,
            "core skill should remain lean and directly link the current snapshot",
        ),
    ]


def run_score() -> int:
    rows = checks()
    failed = False
    for name, ok, message in rows:
        status = "PASS" if ok else "FAIL"
        print(f"{status}\t{name}\t{message}")
        failed = failed or not ok
    return 1 if failed else 0


def run_scenario(name: str) -> int:
    scenario_checks = {
        "happy": ["current_snapshot_date_and_sources", "current_snapshot_api_facts"],
        "drift": ["middleware_rule_separates_types", "drift_notes_record_input_validator_api_split"],
        "regression": ["server_routes_current_handlers", "import_protection_current_options", "korean_siblings_aligned"],
    }
    if name not in scenario_checks:
        print(f"unknown scenario: {name}", file=sys.stderr)
        return 2
    rows = {check_name: (ok, message) for check_name, ok, message in checks()}
    missing = [check_name for check_name in scenario_checks[name] if not rows[check_name][0]]
    if missing:
        details = "; ".join(f"{item}: {rows[item][1]}" for item in missing)
        print(f"SCENARIO {name} FAIL {details}")
        return 1
    print(f"SCENARIO {name} PASS")
    return 0


def test_current_official_snapshot_has_2026_06_09_api_facts() -> None:
    rows = {name: (ok, message) for name, ok, message in checks()}
    for name in ["current_snapshot_date_and_sources", "current_snapshot_api_facts"]:
        ok, message = rows[name]
        assert ok, f"{name}: {message}"


def test_middleware_rule_separates_request_and_function_middleware() -> None:
    rows = {name: (ok, message) for name, ok, message in checks()}
    for name in ["middleware_rule_separates_types", "drift_notes_record_input_validator_api_split"]:
        ok, message = rows[name]
        assert ok, f"{name}: {message}"


def test_skill_anatomy_and_korean_sibling_alignment() -> None:
    rows = {name: (ok, message) for name, ok, message in checks()}
    for name in [
        "server_routes_current_handlers",
        "import_protection_current_options",
        "korean_siblings_aligned",
        "core_skill_stays_lean_and_links_snapshot",
    ]:
        ok, message = rows[name]
        assert ok, f"{name}: {message}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("scenario", nargs="?")
    args = parser.parse_args()
    if args.scenario:
        return run_scenario(args.scenario)
    return run_score()


if __name__ == "__main__":
    raise SystemExit(main())
