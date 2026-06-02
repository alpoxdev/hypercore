#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "사용법: scripts/render-dashboard.sh <artifact-dir>" >&2
  exit 1
fi

artifact_dir=$1
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "${script_dir}/.." && pwd)"
template_path="${skill_dir}/assets/dashboard-template.html"
results_json="${artifact_dir}/results.json"
dashboard_html="${artifact_dir}/dashboard.html"
results_js="${artifact_dir}/results.js"

if [[ ! -f "${template_path}" ]]; then
  echo "대시보드 템플릿이 없습니다: ${template_path}" >&2
  exit 1
fi

if [[ ! -f "${results_json}" ]]; then
  echo "results.json이 없습니다: ${results_json}" >&2
  exit 1
fi

mkdir -p "${artifact_dir}"
cp "${template_path}" "${dashboard_html}"

python3 - "${results_json}" "${results_js}" "${artifact_dir}" <<'PY_RENDER'
import json
import sys
from pathlib import Path

results_path = Path(sys.argv[1])
results_js_path = Path(sys.argv[2])
artifact_dir = Path(sys.argv[3])

with results_path.open(encoding="utf-8") as handle:
    results = json.load(handle)

required_top_level = {
    "status",
    "current_experiment",
    "baseline_score",
    "best_score",
    "experiments",
}
missing = sorted(required_top_level - results.keys())
if missing:
    raise SystemExit(f"results.json 필수 키가 없습니다: {', '.join(missing)}")

if not (results.get("codebase_name") or results.get("skill_name")):
    raise SystemExit("results.json에는 codebase_name 또는 skill_name이 필요합니다")

if results.get("status") not in {"running", "idle", "complete"}:
    raise SystemExit(f"results.json status 값이 유효하지 않습니다: {results.get('status')}")

if not isinstance(results["experiments"], list):
    raise SystemExit("results.json experiments는 배열이어야 합니다")

if results.get("status") == "complete":
    if not results.get("code_explanation") and not (artifact_dir / "code-explanation.md").is_file():
        raise SystemExit("완료 상태에는 results.json.code_explanation 또는 code-explanation.md가 필요합니다")
    if not (artifact_dir / "final-report.md").is_file():
        raise SystemExit("완료 상태에는 final-report.md가 필요합니다")

allowed_experiment_statuses = {
    "baseline",
    "keep",
    "keep-reworked",
    "discard",
    "crash",
    "no-op",
    "hook-blocked",
    "metric-error",
    "reset",
}
required_experiment_keys = {"id", "score", "max_score", "pass_rate", "status", "description"}
for index, experiment in enumerate(results["experiments"]):
    if not isinstance(experiment, dict):
        raise SystemExit(f"experiments[{index}]는 객체여야 합니다")
    missing_experiment = sorted(required_experiment_keys - experiment.keys())
    if missing_experiment:
        raise SystemExit(
            f"experiments[{index}] 필수 키가 없습니다: {', '.join(missing_experiment)}"
        )
    if experiment["status"] not in allowed_experiment_statuses:
        raise SystemExit(
            f"experiments[{index}].status 값이 유효하지 않습니다: {experiment['status']}"
        )

known_detail_files = [
    "changelog.md",
    "code-explanation.md",
    "final-report.md",
    "baseline.md",
    "run-contract.md",
    "source-ledger.md",
    "trace-summary.md",
]
allowed_detail_suffixes = {".md", ".txt", ".json", ".tsv", ".log"}
known_detail_titles = {
    "changelog.md": "변경 로그",
    "code-explanation.md": "코드 개선 설명",
    "final-report.md": "최종 보고",
    "baseline.md": "기준선",
    "run-contract.md": "실행 계약",
    "source-ledger.md": "출처 기록",
    "trace-summary.md": "추적 검증 요약",
}

def detail_title(relative_path):
    return known_detail_titles.get(relative_path, relative_path.replace("-", " ").replace("_", " "))

def read_detail(relative_path):
    path = artifact_dir / relative_path
    if not path.is_file():
        return None
    return {
        "path": relative_path,
        "title": detail_title(relative_path),
        "content": path.read_text(encoding="utf-8"),
    }

details = []
seen = set()
for relative_path in known_detail_files:
    item = read_detail(relative_path)
    if item:
        details.append(item)
        seen.add(relative_path)

details_dir = artifact_dir / "details"
if details_dir.is_dir():
    for path in sorted(details_dir.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in allowed_detail_suffixes:
            continue
        relative_path = path.relative_to(artifact_dir).as_posix()
        if relative_path in seen:
            continue
        details.append({
            "path": relative_path,
            "title": detail_title(relative_path),
            "content": path.read_text(encoding="utf-8"),
        })
        seen.add(relative_path)

payload = json.dumps(results, ensure_ascii=False, separators=(",", ":"))
detail_payload = json.dumps(details, ensure_ascii=False, separators=(",", ":"))
results_js_path.write_text(
    "window.__AUTORESEARCH_CODE_RESULTS__ = " + payload + ";\n"
    "window.__AUTORESEARCH_CODE_DETAILS__ = " + detail_payload + ";\n",
    encoding="utf-8",
)
PY_RENDER

echo "렌더 완료: ${dashboard_html}"
echo "렌더 완료: ${results_js}"
