#!/usr/bin/env bash
# hyper-seo dashboard contract — bash port of scripts/tests/hyper-seo-dashboard.test.mjs.
#
# The dashboard renders an untrusted results payload, so it must treat every
# external string as text, keep its severity counters consistent with the total,
# and isolate chart failures from the rest of the page.
#
# Two layers:
#   1. A deterministic source gate over the inline script: every unwrapped
#      interpolation in an HTML or class sink must use only allow-listed
#      identifiers, and every innerHTML assignment must resolve to a literal or
#      to a verified fragment local.
#   2. Render observations that execute the template's own render functions with
#      node against an element stub, then read the markup they produced.
#
# Checks that need real layout or file:// script loading stay skipped: no bash
# and node combination can reproduce them, and a stub would misreport them.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "$(dirname "$0")/lib/hyper-seo-doc-contracts.sh"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
TEMPLATE=${HYPER_SEO_DASHBOARD_TEMPLATE:-$ROOT/skills/hyper-seo/assets/dashboard-template.html}

INJECTION='<b id=proof-marker>x</b>'
HOSTILE_STATUS='complete" onmouseover="window.__statusInjected=1'
HOSTILE_GRADE='B" onmouseover="window.__gradeInjected=1'
HOSTILE_SEVERITY='wat" onmouseover="window.__sevInjected=1'

# ---- payloads ------------------------------------------------------------

injection_payload() {
  jq -n --arg s "$INJECTION" --arg st "$HOSTILE_STATUS" --arg gr "$HOSTILE_GRADE" '
    {
      project_name: $s,
      scope: $s,
      date: $s,
      status: $st,
      overall_grade: $gr,
      categories: [{name: $s, score: 80, status: "measured"}],
      findings: [{
        id: 1,
        severity: "info",
        finding: $s,
        category: $s,
        location: $s,
        evidence_grade: $s,
        confidence: $s,
        measurement_method: $s,
        source_tier: $s,
        recommendation: $s
      }],
      measurement_methods: {($s): {status: $s, evidence_grade: $s, confidence: $s, reason: $s}},
      platform_policy: {($s): {status: $s, purpose: $s, evidence_grade: $s, confidence: $s}},
      query_fanout: {status: $s, queries: [$s], confidence: $s, missing_topics: [$s]},
      citation_probe: {status: $s, sample_size: 3, confidence: $s, engines: [$s]},
      score_history: [{iteration: 1, score: 70, grade: $s, decision: $s, evidence: $s}],
      best_run: {iteration: 1, score: 70, reason: $s},
      quick_wins: [{action: $s, impact: $s, effort: $s}],
      actions: [{priority: 1, category: $s, action: $s, impact: $s, effort: $s}]
    }'
}

severity_payload() {
  jq -n --arg sev "$HOSTILE_SEVERITY" '
    {
      project_name: "severity probe",
      status: "complete",
      overall_grade: "C",
      categories: [],
      findings: [
        {id: 1, severity: "critical", finding: "one"},
        {id: 2, severity: "critical", finding: "two"},
        {id: 3, severity: $sev, finding: "three"}
      ],
      measurement_methods: {}
    }'
}

chart_payload() {
  cat <<'JSON'
{
  "project_name": "chart probe",
  "status": "complete",
  "overall_grade": "A",
  "categories": [{"name": "RENDER-ME", "score": 90, "status": "measured"}],
  "findings": [{"id": 1, "severity": "info", "finding": "RENDER-ME"}],
  "measurement_methods": {"RENDER-ME": {"status": "completed"}}
}
JSON
}

# ---- cases ---------------------------------------------------------------

case_source_gate() {
  local work gate violations
  work=$(new_workdir)
  gate=$(hs_source_gate "$TEMPLATE")
  printf '%s' "$gate" >"$work/gate.json"
  assert_json_valid "$work/gate.json"
  # Non-vacuity: a scanner that stopped seeing sinks must not pass silently.
  [ "$(jq -r '.literals' "$work/gate.json")" -ge 10 ] || fail "too few template literals scanned"
  [ "$(jq -r '.sinks' "$work/gate.json")" -ge 10 ] || fail "too few sinks scanned"
  [ "$(jq -r '.checked' "$work/gate.json")" -ge 30 ] || fail "too few sink expressions checked"
  violations=$(jq -r '.violations | map(.rule + ": " + .sink + " => " + .expression) | join("\n")' "$work/gate.json")
  assert_empty "$violations" "sink violations"
}

case_external_strings_render_as_text() {
  local work observation panel
  work=$(new_workdir)
  injection_payload >"$work/payload.json"
  observation=$(hs_render_observe "$TEMPLATE" "$work/payload.json")
  printf '%s' "$observation" >"$work/observation.json"

  assert_json_eq "$work/observation.json" '.markerElement' "false" "no injected element"
  assert_json_eq "$work/observation.json" '.attributeLeaks' "0" "no attribute leak"
  assert_json_eq "$work/observation.json" '.visibleText' "true" "payload stays visible text"

  for panel in findings-wrap category-grid measurement-wrap platform-wrap ai-experiments-wrap history-wrap quickwins-wrap actions-wrap; do
    assert_contains "$(jq -r --arg id "$panel" '.panelText[$id]' "$work/observation.json")" "$INJECTION" "$panel carries the payload"
  done

  assert_eq "status idle" "$(jq -r '.pillClassName | split(" ") | map(select(. != "")) | join(" ")' "$work/observation.json")" "status pill allow-list"
  assert_eq "grade" "$(jq -r '.gradeClassName | split(" ") | map(select(. != "")) | join(" ")' "$work/observation.json")" "grade allow-list"
  assert_eq "sev info" "$(jq -r '.sevClassNames | join(",")' "$work/observation.json")" "severity allow-list"
  assert_json_eq "$work/observation.json" '.otherHidden' "true" "other bucket hidden"
  assert_eq "$(jq -r '.total' "$work/observation.json")" \
    "$(jq -r '[.critical, .warning, .info, .other] | map(tonumber) | add' "$work/observation.json")" "counters sum to the total"
}

case_severity_outside_enumeration() {
  local work observation
  work=$(new_workdir)
  severity_payload >"$work/payload.json"
  observation=$(hs_render_observe "$TEMPLATE" "$work/payload.json")
  printf '%s' "$observation" >"$work/observation.json"

  assert_json_eq "$work/observation.json" '.total' "3" "total findings"
  assert_json_eq "$work/observation.json" '.critical' "2" "critical counter"
  assert_json_eq "$work/observation.json" '.other' "1" "other counter"
  assert_json_eq "$work/observation.json" '.otherHidden' "false" "other bucket visible"
  assert_eq "3" "$(jq -r '[.critical, .warning, .info, .other] | map(tonumber) | add' "$work/observation.json")" "counters sum to the total"
  assert_eq "sev critical,sev critical,sev unknown" "$(jq -r '.sevClassNames | join(",")' "$work/observation.json")" "severity classes"
  assert_json_eq "$work/observation.json" '.markerElement' "false" "no injected element"
  assert_json_eq "$work/observation.json" '.attributeLeaks' "0" "no attribute leak"
}

case_non_chart_panels() {
  local work observation
  work=$(new_workdir)
  chart_payload >"$work/payload.json"
  observation=$(hs_render_observe "$TEMPLATE" "$work/payload.json")
  printf '%s' "$observation" >"$work/observation.json"

  assert_json_eq "$work/observation.json" '.chartGlobal' "undefined" "Chart stays unavailable"
  assert_contains "$(jq -r '.panelText["findings-wrap"]' "$work/observation.json")" "RENDER-ME" "findings panel"
  assert_contains "$(jq -r '.panelText["measurement-wrap"]' "$work/observation.json")" "RENDER-ME" "measurement panel"
  assert_contains "$(jq -r '.panelText["category-grid"]' "$work/observation.json")" "RENDER-ME" "category panel"
  assert_json_eq "$work/observation.json" '.actionsTextLength > 0' "true" "actions panel keeps its empty state"
}

case_file_protocol_missing_results() {
  skip "needs a browser engine: file:// script loading has no node equivalent"
}

case_narrow_viewport() {
  skip "needs a browser layout engine: measured widths are not reproducible outside one"
}

run_case "source gate: no unescaped interpolation reaches an HTML or class sink" case_source_gate
run_case "external strings render as text in every panel (requires Bun.WebView)" case_external_strings_render_as_text
run_case "severity outside the enumeration keeps counters consistent (requires Bun.WebView)" case_severity_outside_enumeration
run_case "renders the non-chart panels when Chart is unavailable (requires Bun.WebView)" case_non_chart_panels
run_case "file:// reports a missing results.js in the subtitle (requires Bun.WebView)" case_file_protocol_missing_results
run_case "a narrow viewport keeps the wide findings table inside its panel (requires Bun.WebView)" case_narrow_viewport
test_summary
