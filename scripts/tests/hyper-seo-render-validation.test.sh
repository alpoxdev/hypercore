#!/usr/bin/env bash
# hyper-seo dashboard renderer structure gate — bash port of
# scripts/tests/hyper-seo-render-validation.test.mjs.
#
# render-dashboard.sh reads an untrusted results.json, so it must reject a
# structurally invalid payload through its fail() path (exit 1) before it writes
# anything, and leave a previously rendered output pair byte-identical when it
# does. Unknown extra keys stay allowed (K9).
#
# Every case builds its artifact directory with mktemp and runs the shipped
# renderer as a subprocess; the repository tree is never written to.
# HYPER_SEO_RENDER_DASHBOARD points the run at another renderer copy.
set -uo pipefail
# shellcheck disable=SC1090,SC1091  # path depends on the caller and the runner
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
RENDERER=${HYPER_SEO_RENDER_DASHBOARD:-$ROOT/skills/hyper-seo/scripts/render-dashboard.sh}
TEMPLATE="$ROOT/skills/hyper-seo/assets/dashboard-template.html"

PRIOR_DASHBOARD='prior dashboard'
PRIOR_RESULTS_JS='prior results'
PRIOR_DASHBOARD_MODE=640
PRIOR_RESULTS_JS_MODE=600
RESULTS_JS_PREFIX='window.__SEO_RESULTS__ = '

# ---- payloads ------------------------------------------------------------

# valid_payload — a structurally valid payload that exercises every gate field.
valid_payload() {
  cat <<'JSON'
{
  "project_name": "fixture-site",
  "date": "2026-09-21",
  "scope": "Full site audit",
  "status": "complete",
  "overall_grade": "C",
  "categories": [
    {"name": "Technical SEO", "status": "measured", "score": 85, "evidence": "Technical SEO evidence", "confidence": "high"},
    {"name": "On-Page SEO", "status": "measured", "score": 72, "evidence": "On-Page SEO evidence", "confidence": "high"},
    {"name": "Content SEO", "status": "measured", "score": 68, "evidence": "Content SEO evidence", "confidence": "high"},
    {"name": "Core Web Vitals", "status": "measured", "score": 90, "evidence": "Core Web Vitals evidence", "confidence": "high"},
    {"name": "Structured Data", "status": "measured", "score": 88, "evidence": "Structured Data evidence", "confidence": "high"},
    {"name": "AEO Readiness", "status": "measured", "score": 45, "evidence": "AEO Readiness evidence", "confidence": "high"},
    {"name": "GEO Readiness", "status": "unknown", "score": null, "evidence": "GEO Readiness evidence", "confidence": "high"}
  ],
  "findings": [
    {
      "id": "T1",
      "severity": "critical",
      "category": "Technical SEO",
      "finding": "robots.txt blocks /blog/ path",
      "location": "/robots.txt:3",
      "evidence_grade": "lab",
      "confidence": "high",
      "measurement_method": "static robots.txt scan",
      "source_tier": "observed-file",
      "recommendation": "Remove Disallow: /blog/"
    },
    {
      "id": "A1",
      "severity": "warning",
      "category": "AEO Readiness",
      "finding": "No direct answer in first paragraph",
      "location": "/blog/what-is-seo.html",
      "evidence_grade": "heuristic",
      "confidence": "medium",
      "measurement_method": "answer block detector",
      "source_tier": "research-backed-heuristic",
      "recommendation": "Add a concise visible answer block"
    }
  ],
  "score_history": [
    {
      "iteration": 0,
      "score": 66,
      "grade": "C",
      "critical_count": 1,
      "decision": "baseline",
      "evidence": "Initial audit before optimization changes",
      "evaluator_version": "hyper-seo-evaluator/1",
      "weights": [20, 20, 15, 15, 10, 10, 10]
    },
    {
      "iteration": 1,
      "score": 78,
      "grade": "B",
      "critical_count": 0,
      "decision": "kept",
      "changed": "Removed robots.txt block for /blog/",
      "evidence": "Re-audit confirmed indexability restored",
      "evaluator_version": "hyper-seo-evaluator/1",
      "weights": [20, 20, 15, 15, 10, 10, 10]
    }
  ],
  "best_run": {"iteration": 1, "score": 78, "grade": "B", "reason": "Highest kept score with zero critical findings"},
  "validator": {"status": "passed", "summary": "Target passed"}
}
JSON
}

# payload_with <jq-filter> — the valid payload with one mutation applied.
payload_with() {
  local work
  work=$(new_workdir)
  valid_payload >"$work/base.json"
  jq "$1" "$work/base.json"
}

# ---- helpers -------------------------------------------------------------

# file_mode <path> — permission bits as octal text.
file_mode() {
  local mode
  if mode=$(stat -c '%a' "$1" 2>/dev/null); then
    printf '%s' "$mode"
  else
    stat -f '%Lp' "$1"
  fi
}

# sha256_file <path>
sha256_file() {
  shasum -a 256 "$1" | awk '{ print $1 }'
}

# default_mode — mode a freshly created file receives under the current umask.
default_mode() {
  local mask
  mask=$(umask)
  printf '%o' "$((0666 & ~(0$mask)))"
}

# temp_root — TMPDIR without a trailing separator, so joined paths have no "//".
temp_root() {
  local root=${TMPDIR:-/tmp}
  printf '%s\n' "${root%/}"
}

# seed_dir <payload-file> [prior:1|0] — artifact directory, printed.
seed_dir() {
  local payload=$1 prior=${2:-1} dir
  dir=$(mktemp -d "$(temp_root)/hyper-seo-render-validation.XXXXXX")
  printf '%s\n' "$dir" >>"$TL_STATE_DIR/workdirs"
  cp "$payload" "$dir/results.json"
  if [ "$prior" = "1" ]; then
    printf '%s\n' "$PRIOR_DASHBOARD" >"$dir/dashboard.html"
    chmod "$PRIOR_DASHBOARD_MODE" "$dir/dashboard.html"
    printf '%s\n' "$PRIOR_RESULTS_JS" >"$dir/results.js"
    chmod "$PRIOR_RESULTS_JS_MODE" "$dir/results.js"
  fi
  printf '%s\n' "$dir"
}

# run_renderer <dir> <stdout-file> <stderr-file> — print the exit code.
run_renderer() {
  local dir=$1 out=$2 err=$3 rc=0
  NO_COLOR=1 bash "$RENDERER" "$dir" >"$out" 2>"$err" || rc=$?
  printf '%s\n' "$rc"
}

# output_state <dir> — name, mode and hash of the two outputs plus temporaries.
output_state() {
  local dir=$1 name
  for name in dashboard.html results.js; do
    if [ -f "$dir/$name" ]; then
      printf '%s %s %s\n' "$name" "$(file_mode "$dir/$name")" "$(sha256_file "$dir/$name")"
    else
      printf '%s missing\n' "$name"
    fi
  done
  printf 'temporaries %s\n' "$(find "$dir" -maxdepth 1 -type f -name '*.tmp' -exec basename {} \; | sort | tr '\n' ' ' | sed 's/ $//')"
}

# prior_state_expectation — the state a rejected payload must leave behind.
prior_state_expectation() {
  printf 'dashboard.html %s %s\n' "$PRIOR_DASHBOARD_MODE" \
    "$(printf '%s\n' "$PRIOR_DASHBOARD" | shasum -a 256 | awk '{ print $1 }')"
  printf 'results.js %s %s\n' "$PRIOR_RESULTS_JS_MODE" \
    "$(printf '%s\n' "$PRIOR_RESULTS_JS" | shasum -a 256 | awk '{ print $1 }')"
  printf 'temporaries \n'
}

# results_js_payload <results.js> — embedded payload, canonical JSON.
results_js_payload() {
  sed -e "s/^${RESULTS_JS_PREFIX}//" "$1" | sed 's/;$//' | jq -S -c .
}

# ---- happy path ----------------------------------------------------------

case_renders_valid_payload() {
  local work payload dir rc
  work=$(new_workdir)
  valid_payload >"$work/payload.json"
  payload="$work/payload.json"
  dir=$(seed_dir "$payload" 0)
  rc=$(run_renderer "$dir" "$work/stdout" "$work/stderr")
  assert_eq "0" "$rc" "renderer exit"
  assert_empty "$(cat "$work/stderr")" "renderer stderr"
  assert_eq "$(printf '렌더 완료: %s\n렌더 완료: %s\n' "$dir/dashboard.html" "$dir/results.js")" \
    "$(cat "$work/stdout")" "renderer stdout"

  assert_file "$dir/dashboard.html"
  assert_file "$dir/results.js"
  assert_eq "$(sha256_file "$TEMPLATE")" "$(sha256_file "$dir/dashboard.html")" "dashboard is the template copy"
  assert_eq "$(jq -S -c . "$payload")" "$(results_js_payload "$dir/results.js")" "results.js carries the payload"
  assert_eq "$(default_mode)" "$(file_mode "$dir/dashboard.html")" "dashboard mode"
  assert_eq "$(default_mode)" "$(file_mode "$dir/results.js")" "results.js mode"
}

case_replaces_prior_pair() {
  local work dir rc
  work=$(new_workdir)
  valid_payload >"$work/payload.json"
  dir=$(seed_dir "$work/payload.json" 1)
  rc=$(run_renderer "$dir" "$work/stdout" "$work/stderr")
  assert_eq "0" "$rc" "renderer exit"
  assert_ne "$(printf '%s\n' "$PRIOR_DASHBOARD" | shasum -a 256 | awk '{ print $1 }')" "$(sha256_file "$dir/dashboard.html")" "dashboard replaced"
  assert_ne "$(printf '%s\n' "$PRIOR_RESULTS_JS" | shasum -a 256 | awk '{ print $1 }')" "$(sha256_file "$dir/results.js")" "results.js replaced"
  assert_eq "$PRIOR_DASHBOARD_MODE" "$(file_mode "$dir/dashboard.html")" "dashboard mode kept"
  assert_eq "$PRIOR_RESULTS_JS_MODE" "$(file_mode "$dir/results.js")" "results.js mode kept"
  assert_empty "$(find "$dir" -maxdepth 1 -type f -name '*.tmp' -exec basename {} \;)" "no temporaries left"
}

case_unknown_keys_pass_through() {
  local work dir rc rendered
  work=$(new_workdir)
  payload_with '.custom_dimension = {nested: [1, 2, 3]} | .categories[0].extra_note = "vendor extension" | .findings[0].extra_tag = "triage-later"' >"$work/payload.json"
  dir=$(seed_dir "$work/payload.json" 1)
  rc=$(run_renderer "$dir" "$work/stdout" "$work/stderr")
  assert_eq "0" "$rc" "renderer exit"
  assert_empty "$(cat "$work/stderr")" "renderer stderr"
  rendered=$(results_js_payload "$dir/results.js")
  assert_eq '{"nested":[1,2,3]}' "$(printf '%s' "$rendered" | jq -c '.custom_dimension')" "custom dimension kept"
  assert_eq "vendor extension" "$(printf '%s' "$rendered" | jq -r '.categories[0].extra_note')" "category extension kept"
  assert_eq "triage-later" "$(printf '%s' "$rendered" | jq -r '.findings[0].extra_tag')" "finding extension kept"
}

case_malformed_payload() {
  local work dir rc before after
  work=$(new_workdir)
  dir=$(mktemp -d "$(temp_root)/hyper-seo-render-validation.XXXXXX")
  printf '%s\n' "$dir" >>"$TL_STATE_DIR/workdirs"
  printf '{broken\n' >"$dir/results.json"
  before=$(shasum -a 256 "$dir/results.json")
  rc=$(run_renderer "$dir" "$work/stdout" "$work/stderr")
  assert_eq "1" "$rc" "renderer exit"
  assert_contains "$(cat "$work/stderr")" "JSON" "stderr names the JSON failure"
  assert_eq "results.json" "$(find "$dir" -maxdepth 1 -type f -exec basename {} \; | sort | tr '\n' ' ' | sed 's/ $//')" "no outputs created"
  after=$(shasum -a 256 "$dir/results.json")
  assert_eq "$before" "$after" "results.json untouched"
}

case_reset_event_accepted() {
  local work dir rc
  work=$(new_workdir)
  payload_with '.score_history += [{iteration: 2, score: 80, grade: "B", decision: "reset", evidence: "Weights changed, new baseline started", evaluator_version: "hyper-seo-evaluator/2", weights: [25, 20, 15, 10, 10, 10, 10]}]' >"$work/payload.json"
  dir=$(seed_dir "$work/payload.json" 1)
  rc=$(run_renderer "$dir" "$work/stdout" "$work/stderr")
  assert_eq "0" "$rc" "renderer exit"
  assert_empty "$(cat "$work/stderr")" "renderer stderr"
}

case_null_category_score() {
  local work dir rc
  work=$(new_workdir)
  payload_with '.categories[0].score = null' >"$work/payload.json"
  dir=$(seed_dir "$work/payload.json" 1)
  rc=$(run_renderer "$dir" "$work/stdout" "$work/stderr")
  assert_eq "0" "$rc" "renderer exit"
  assert_empty "$(cat "$work/stderr")" "renderer stderr"
}

# ---- rejected payloads ---------------------------------------------------

# reject_case — runs the payload prepared in REJECT_* and checks the contract.
reject_case() {
  local work dir rc before after
  work=$(new_workdir)
  dir=$(seed_dir "$REJECT_PAYLOAD" 1)
  before=$(jq -S -c . "$REJECT_PAYLOAD")
  rc=$(run_renderer "$dir" "$work/stdout" "$work/stderr")
  assert_eq "1" "$rc" "renderer exit"
  assert_empty "$(cat "$work/stdout")" "renderer stdout"
  assert_nonempty "$(cat "$work/stderr")" "renderer stderr"
  assert_contains "$(cat "$work/stderr")" "$REJECT_REASON" "rejection names $REJECT_REASON"
  assert_not_contains "$(cat "$work/stderr")" "    at " "no stack trace"
  assert_eq "$(prior_state_expectation)" "$(output_state "$dir")" "prior outputs preserved"
  after=$(jq -S -c . "$dir/results.json")
  assert_eq "$before" "$after" "results.json untouched"
}

REJECTED_NAMES=(
  "a null payload"
  "an array payload"
  "a missing project_name"
  "a missing status"
  "a missing categories"
  "a missing findings"
  "a status outside the enumeration"
  "a category status outside the enumeration"
  "a category score above 100"
  "a category score below 0"
  "a category score that is neither a number nor null"
  "a non-array categories"
  "a severity outside the enumeration"
  "a missing severity"
  "an evidence_grade outside the enumeration"
  "a source_tier outside the enumeration"
  "an overall_grade outside the grade table"
  "a score_history entry without evaluator_version"
  "an empty evaluator_version"
  "a weight change without a reset event"
  "an evaluator change without a reset event"
  "a best_run pointing at a discarded iteration"
  "a best_run below the highest kept score"
  "a best_run iteration missing from score_history"
  "a best_run without score_history"
)
# Each entry is `<jq filter>|<reason>`; `!literal` means the payload itself.
REJECTED_FILTERS=(
  '!null|객체'
  '![]|객체'
  'del(.project_name)|project_name'
  'del(.status)|status'
  'del(.categories)|categories'
  'del(.findings)|findings'
  '.status = "wat"|status'
  '.categories[0].status = "wat"|categories[0].status'
  '.categories[0].score = 120|categories[0].score'
  '.categories[1].score = -1|categories[1].score'
  '.categories[2].score = "68"|categories[2].score'
  '.categories = {}|categories'
  '.findings[0].severity = "wat"|findings[0].severity'
  'del(.findings[1].severity)|findings[1].severity'
  '.findings[0].evidence_grade = "vibes"|findings[0].evidence_grade'
  '.findings[1].source_tier = "blog-post"|findings[1].source_tier'
  '.overall_grade = "B+"|overall_grade'
  'del(.score_history[1].evaluator_version)|score_history[1].evaluator_version'
  '.score_history[1].evaluator_version = "  "|score_history[1].evaluator_version'
  '.score_history[1].weights = [25, 20, 15, 10, 10, 10, 10]|score_history[1]'
  '.score_history[1].evaluator_version = "hyper-seo-evaluator/2"|score_history[1]'
  '.score_history[1].decision = "discarded"|best_run'
  '.score_history += [{iteration: 2, score: 85, grade: "B", decision: "kept", evidence: "Later re-audit", evaluator_version: "hyper-seo-evaluator/1", weights: [20, 20, 15, 15, 10, 10, 10]}]|best_run'
  '.best_run.iteration = 9|best_run.iteration'
  'del(.score_history)|score_history'
)

# reject_all — runs every rejection case through run_case.
reject_all() {
  local work i name spec filter reason payload
  work=$(new_workdir)
  i=0
  while [ "$i" -lt "${#REJECTED_NAMES[@]}" ]; do
    name=${REJECTED_NAMES[$i]}
    spec=${REJECTED_FILTERS[$i]}
    filter=${spec%|*}
    reason=${spec##*|}
    payload="$work/payload.$i.json"
    case $filter in
      '!null') printf 'null\n' >"$payload" ;;
      '![]') printf '[]\n' >"$payload" ;;
      *) payload_with "$filter" >"$payload" ;;
    esac
    REJECT_PAYLOAD=$payload
    REJECT_REASON=$reason
    run_case "rejects $name and preserves the prior outputs" reject_case
    i=$((i + 1))
  done
}

run_case "renders a structurally valid payload and records the artifact hashes" case_renders_valid_payload
run_case "replaces a prior output pair for a valid payload and keeps its modes" case_replaces_prior_pair
run_case "passes unknown extra keys through without a warning (K9)" case_unknown_keys_pass_through
reject_all
run_case "rejects a malformed payload without creating outputs" case_malformed_payload
run_case "a reset event makes a changed evaluator definition acceptable" case_reset_event_accepted
run_case "a null category score stays valid" case_null_category_score
test_summary
