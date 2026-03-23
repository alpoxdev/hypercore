#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: scripts/render-dashboard.sh <artifact-dir>" >&2
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
  echo "missing dashboard template: ${template_path}" >&2
  exit 1
fi

if [[ ! -f "${results_json}" ]]; then
  echo "missing results.json: ${results_json}" >&2
  exit 1
fi

mkdir -p "${artifact_dir}"
cp "${template_path}" "${dashboard_html}"

json_payload="$(jq -c '.' "${results_json}")"
printf 'window.__AUTORESEARCH_CODE_RESULTS__ = %s;\n' "${json_payload}" > "${results_js}"

echo "rendered ${dashboard_html}"
echo "rendered ${results_js}"
