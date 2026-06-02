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

json_payload="$(python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1])), ensure_ascii=False, separators=(",",":")))' "${results_json}")"
printf 'window.__AUTORESEARCH_CODE_RESULTS__ = %s;\n' "${json_payload}" > "${results_js}"

echo "렌더 완료: ${dashboard_html}"
echo "렌더 완료: ${results_js}"
