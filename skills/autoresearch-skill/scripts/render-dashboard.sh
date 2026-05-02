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

known_detail_files = [
    "changelog.md",
    "run-contract.md",
    "source-ledger.md",
    "trace-summary.md",
]
allowed_detail_suffixes = {".md", ".txt", ".json", ".tsv", ".log"}

def read_detail(relative_path):
    path = artifact_dir / relative_path
    if not path.is_file():
        return None
    return {
        "path": relative_path,
        "title": relative_path.replace("-", " ").replace("_", " "),
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
            "title": path.stem.replace("-", " ").replace("_", " "),
            "content": path.read_text(encoding="utf-8"),
        })
        seen.add(relative_path)

payload = json.dumps(results, ensure_ascii=False, separators=(",", ":"))
detail_payload = json.dumps(details, ensure_ascii=False, separators=(",", ":"))
results_js_path.write_text(
    "window.__AUTORESEARCH_RESULTS__ = " + payload + ";\n"
    "window.__AUTORESEARCH_DETAILS__ = " + detail_payload + ";\n",
    encoding="utf-8",
)
PY_RENDER

echo "렌더 완료: ${dashboard_html}"
echo "렌더 완료: ${results_js}"
