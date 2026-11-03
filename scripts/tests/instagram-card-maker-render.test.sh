#!/usr/bin/env bash
# instagram-card-maker composer render gate (bash port of
# instagram-card-maker-render.test.mjs).
#
# The production input contract is pure script: the case slices `validate` out
# of assets/card-studio.html, evaluates it in node:vm from an inline node
# snippet, and asserts the JSON verdict with jq. Every pixel-level case drives
# the shipped composer through a browser, which bash cannot host, so those
# visual render cases are skipped.
set -uo pipefail
# shellcheck disable=SC1090,SC1091
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
COMPOSER=$ROOT/skills/instagram-card-maker/assets/card-studio.html

FIXTURES=$(new_workdir)
VALIDATE_FILE=$FIXTURES/card-validate.txt

# The composer keeps the input validator between `const imagePattern` and
# `function loadImage`; the browser layer starts after that.
extract_validate() {
  awk '!inside && /^  const imagePattern =/ {inside=1}
       inside && /^  function loadImage\(/ {exit}
       inside {print}' "$1" >"$2"
}

# run_case's subshell stands on the left of `|| rc=$?`, which turns errexit off
# for the whole case, so a plain assertion failure would be masked by the next
# passing assertion. Ending the case subshell on the first failure keeps the
# library's one-failure-per-case contract.
__tl_fail() {
  printf '  %s\n' "$*"
  exit 1
}

# sb_json_eq <file> <filter> <expected> [label] — compare the filter output as
# text, so false and null compare like any other value (jq -e would exit
# non-zero for them).
sb_json_eq() {
  local file=$1 filter=$2 expected=$3 label=${4:-}
  local actual
  if ! actual=$(jq -r "$filter" "$file" 2>/dev/null); then
    printf '  %s: filter failed: %s\n' "${label:-json $filter}" "$filter"
    exit 1
  fi
  assert_eq "$expected" "$actual" "${label:-json $filter}"
}

if ! extract_validate "$COMPOSER" "$VALIDATE_FILE"; then
  printf 'instagram-card-maker-render: cannot extract validate from %s\n' "$COMPOSER" >&2
fi

# The driver evaluates the sliced validator in node:vm and runs the probe body
# read from stdin. argv[1] is the slice file.
read -r -d '' ICM_DRIVER <<'JS' || true
"use strict";
const fs = require("node:fs");
const vm = require("node:vm");
const validateSource = fs.readFileSync(process.argv[1], "utf8");
const probe = fs.readFileSync(0, "utf8");
const validate = vm.runInNewContext(validateSource + "\nvalidate");
const probeFn = new Function("validate", probe);
Promise.resolve(probeFn(validate)).then(
  (value) => { process.stdout.write(JSON.stringify(value === undefined ? null : value)); },
  (error) => {
    process.stderr.write("probe failed: " + (error && error.stack ? error.stack : String(error)) + "\n");
    process.exit(1);
  }
);
JS

# probe <dir> — run the probe body on stdin and write <dir>/probe.json.
probe() {
  local dir=$1
  if ! node -e "$ICM_DRIVER" "$VALIDATE_FILE" >"$dir/probe.json" 2>"$dir/probe.err"; then
    printf '  probe failed: %s\n' "$(cat "$dir/probe.err")"
    exit 1
  fi
}

case_input_contract() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const slides = [0, 1].map((i) => ({
  title: "Title",
  body: "Body",
  alt: "Card",
  photoSource: "Fixture",
  photo: "data:image/png;base64," + (i === 0 ? "AAAA" : "BBBB"),
  generated: false,
  layout: i === 0 ? "bottom-left" : "top-left",
  scene: "Scene " + i,
  layoutReason: "Keep the subject clear",
  visualType: "photo"
}));
const doc = { brand: "Test", caption: "Caption", width: 1080, height: 1350, sources: [], slides: slides };
const clone = (value) => JSON.parse(JSON.stringify(value));
const rejects = (candidate) => {
  try { validate(candidate); return false; } catch (error) { return true; }
};
const validAccepted = !rejects(doc);
const badReasons = [7, {}, [], null, "", " "].map((reuseReason) => {
  const bad = clone(doc);
  Object.assign(bad.slides[1], { reuseReason: reuseReason });
  return rejects(bad);
});
const missingFields = ["scene", "layoutReason", "layout", "visualType"].map((field) => {
  const bad = clone(doc);
  delete bad.slides[1][field];
  return rejects(bad);
});
const repeated = clone(doc);
repeated.slides[1].photo = repeated.slides[0].photo;
const repeatedRejected = rejects(repeated);
Object.assign(repeated.slides[1], { reuseReason: "Continue the same scene" });
const repeatedAllowed = !rejects(repeated);
return {
  validAccepted: validAccepted,
  badReasonsChecked: badReasons.length,
  badReasonsRejected: badReasons.filter(Boolean).length,
  missingChecked: missingFields.length,
  missingRejected: missingFields.filter(Boolean).length,
  repeatedRejected: repeatedRejected,
  repeatedAllowed: repeatedAllowed
};
JS
  sb_json_eq "$out" '.validAccepted' 'true'
  sb_json_eq "$out" '.badReasonsChecked' '6'
  sb_json_eq "$out" '.badReasonsRejected' '6'
  sb_json_eq "$out" '.missingChecked' '4'
  sb_json_eq "$out" '.missingRejected' '4'
  sb_json_eq "$out" '.repeatedRejected' 'true'
  sb_json_eq "$out" '.repeatedAllowed' 'true'
}

# ------------------------------------------------------------- composition

case_no_brand_label() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_body_layouts() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_distinct_photos() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_invalid_exports_blocked() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_photo_edge_to_edge() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_scrim_translucent() {
  skip "visual render needs a browser; outside the automated bash suite"
}

# ----------------------------------------------------------------- contrast

case_white_text_contrast() {
  skip "visual render needs a browser; outside the automated bash suite"
}

# ------------------------------------------------------ text over photo

case_text_layer_sharp() {
  skip "visual render needs a browser; outside the automated bash suite"
}

# ------------------------------------------- preserved behaviour and API

case_public_api_shape() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_supported_dimensions() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_overflow_fails() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_logo_top_right() {
  skip "visual render needs a browser; outside the automated bash suite"
}

# ------------------------------------------------------------------- runner

run_case "the production input contract rejects malformed fields without WebView" case_input_contract
run_case "cards do not draw a brand and page label over the photo" case_no_brand_label
run_case "body layouts move text and keep contrast while the cover stays bottom-left" case_body_layouts
run_case "different cards draw their own photo and saved HTML reopens with the same plan" case_distinct_photos
run_case "invalid layout, cover alignment and unexplained photo reuse block exports" case_invalid_exports_blocked
run_case "the photo fills every card edge to edge (requires Bun.WebView)" case_photo_edge_to_edge
run_case "the scrim is translucent so the photo stays visible under the text (requires Bun.WebView)" case_scrim_translucent
run_case "white text keeps provable contrast over a pure white photo (requires Bun.WebView)" case_white_text_contrast
run_case "the text layer stays sharp over the photo (requires Bun.WebView)" case_text_layer_sharp
run_case "the public API renders, exports, and reports the same shape (requires Bun.WebView)" case_public_api_shape
run_case "supported dimensions render and unsupported dimensions are rejected (requires Bun.WebView)" case_supported_dimensions
run_case "overflowing text fails instead of shrinking (requires Bun.WebView)" case_overflow_fails
run_case "a supplied logo is drawn unfiltered at the top-right (requires Bun.WebView)" case_logo_top_right

test_summary
