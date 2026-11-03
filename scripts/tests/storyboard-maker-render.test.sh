#!/usr/bin/env bash
# storyboard-maker renderer gate (bash port of storyboard-maker-render.test.mjs).
#
# The studio asset is a pure core script plus a thin DOM layer. Every check that
# does not need a browser extracts <script id="storyboard-core"> from the asset,
# evaluates it in node:vm from an inline node snippet, and prints one JSON
# object that the case asserts with jq. The two browser-only visual render
# cases are skipped: bash has no browser driver.
set -uo pipefail
# shellcheck disable=SC1090,SC1091
source "${HYPERCORE_TEST_LIB:-$(dirname "$0")/../lib/test-lib.sh}"
test_init

ROOT=${HYPERCORE_ROOT:-$(CDPATH='' cd -- "$(dirname "$0")/../.." && pwd)}
ASSET=$ROOT/skills/storyboard-maker/assets/storyboard-studio.html
SAMPLE=$ROOT/skills/storyboard-maker/assets/sample-storyboard.json

FIXTURES=$(new_workdir)
CORE_FILE=$FIXTURES/storyboard-core.txt

# extract_core <asset> <out> — print the storyboard-core script body.
extract_core() {
  awk '!inside && /<script[^>]*id="storyboard-core"[^>]*>/ {inside=1; next}
       inside && /<\/script>/ {exit}
       inside {print}' "$1" >"$2"
}

# The driver evaluates the extracted core in node:vm and runs the probe body
# read from stdin. argv: core file, sample file, asset file.
read -r -d '' SB_DRIVER <<'JS' || true
"use strict";
const fs = require("node:fs");
const vm = require("node:vm");
const corePath = process.argv[1];
const samplePath = process.argv[2];
const assetPath = process.argv[3];
const coreSource = fs.readFileSync(corePath, "utf8");
const assetSource = fs.readFileSync(assetPath, "utf8");
const core = vm.runInNewContext(coreSource + "\n;StoryboardCore;");
const sample = JSON.parse(fs.readFileSync(samplePath, "utf8"));
const probe = fs.readFileSync(0, "utf8");
const TINY_PNG = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==";
const clone = (value) => JSON.parse(JSON.stringify(value));
function baseShot(over) {
  return Object.assign({
    id: "10",
    size: "MS",
    focus: "a",
    camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, pitchDeg: 0 },
    move: null,
    subjectMoves: [],
    action: "Action.",
    durationSec: 2,
    transition: "CUT",
    crossing: null,
    intent: "Test shot."
  }, over || {});
}
function testDoc(shots, over) {
  return Object.assign({
    version: 1,
    title: "TEST",
    characters: [{ id: "a", name: "A", heightM: 1.7 }, { id: "b", name: "B", heightM: 1.75 }],
    scenes: [{
      id: "s1",
      number: 1,
      heading: "INT. TEST",
      props: [],
      blocking: [
        { character: "a", x: 0, z: -0.8, facingDeg: 0, pose: "stand" },
        { character: "b", x: 0, z: 0.8, facingDeg: 180, pose: "stand" }
      ],
      axis: ["a", "b"],
      shots: shots
    }]
  }, over || {});
}
const probeFn = new Function("core", "sample", "coreSource", "assetSource", "clone", "baseShot", "testDoc", "TINY_PNG", probe);
Promise.resolve(probeFn(core, sample, coreSource, assetSource, clone, baseShot, testDoc, TINY_PNG)).then(
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
  if ! node -e "$SB_DRIVER" "$CORE_FILE" "$SAMPLE" "$ASSET" >"$dir/probe.json" 2>"$dir/probe.err"; then
    printf '  probe failed: %s\n' "$(cat "$dir/probe.err")"
    exit 1
  fi
}

# run_case runs the case in a subshell that stands on the left of `|| rc=$?`,
# which turns errexit off for the whole case, so a plain assertion failure would
# be masked by the next passing assertion. Ending the case subshell on the first
# failure keeps the library's one-failure-per-case contract.
__tl_fail() {
  printf '  %s\n' "$*"
  exit 1
}

# sb_json_eq <file> <filter> <expected> [label] — compare the filter output as
# text, so false, null and empty strings compare like any other value (jq -e
# would exit non-zero for them). Arrays are asserted through `length` or
# `join("|")`.
sb_json_eq() {
  local file=$1 filter=$2 expected=$3 label=${4:-}
  local actual
  if ! actual=$(jq -r "$filter" "$file" 2>/dev/null); then
    printf '  %s: filter failed: %s\n' "${label:-json $filter}" "$filter"
    exit 1
  fi
  assert_eq "$expected" "$actual" "${label:-json $filter}"
}

if ! extract_core "$ASSET" "$CORE_FILE"; then
  printf 'storyboard-maker-render: cannot extract storyboard-core from %s\n' "$ASSET" >&2
fi

# ------------------------------------------------------------------ sample

case_shipped_sample() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const v = core.validate(sample);
const l = core.lint(sample);
const panels = sample.scenes.reduce((n, scene) => n + scene.shots.length, 0);
return {
  errors: v.errors.length,
  warnings: l.warnings.length,
  intentional: l.intentional.map((item) => ({ shot: item.shot, method: item.method, intentional: item.intentional, hasReason: !!item.reason })),
  panels: panels,
  scenes: sample.scenes.length
};
JS
  sb_json_eq "$out" '.errors' '0'
  sb_json_eq "$out" '.warnings' '0'
  sb_json_eq "$out" '.intentional | length' '1'
  sb_json_eq "$out" '.intentional[0].shot' '30'
  sb_json_eq "$out" '.intentional[0].method' 'neutral'
  sb_json_eq "$out" '.intentional[0].intentional' 'true'
  sb_json_eq "$out" '.intentional[0].hasReason' 'true'
  assert_jq "$out" '.panels >= 6'
  assert_jq "$out" '.scenes >= 2'
}

# ------------------------------------------------------------------ schema

case_schema_rejects() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const variants = [
  ["SCHEMA_REQUIRED", (doc) => { delete doc.scenes[0].shots[0].camera.focalMm; }],
  ["SCHEMA_ENUM", (doc) => { doc.scenes[0].shots[0].size = "GIANT"; }],
  ["SCHEMA_RANGE", (doc) => { doc.scenes[0].shots[0].camera.pitchDeg = 120; }],
  ["SCHEMA_DUPLICATE", (doc) => { doc.scenes[0].shots.push(baseShot({ id: "10" })); }],
  ["SCHEMA_REFERENCE", (doc) => { doc.scenes[0].shots[0].focus = "nobody"; }],
  ["SCHEMA_CONFLICT", (doc) => { doc.scenes[0].shots[0].camera.heightM = 1.2; }],
  ["SCHEMA_CONFLICT", (doc) => { doc.scenes[0].shots[0].camera.pov = "b"; }],
  ["SCHEMA_REQUIRED", (doc) => { doc.scenes[0].shots[0].size = "OTS"; }]
];
const missed = [];
for (const [code, mutate] of variants) {
  const doc = testDoc([baseShot()]);
  mutate(doc);
  const v = core.validate(doc);
  if (!v.errors.some((error) => error.code === code)) missed.push(code + " got " + v.errors.map((error) => error.code).join(","));
}
return { checked: variants.length, missed: missed };
JS
  sb_json_eq "$out" '.checked' '8'
  sb_json_eq "$out" '.missed | length' '0'
}

# ---------------------------------------------------------------- optics

case_vfov_table() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const near = (actual, expected) => Math.abs(actual - expected) <= 0.01;
return {
  wide50: near(core.vfovDeg(50, "16:9", 35), 22.28),
  wide24: near(core.vfovDeg(24, "16:9", 35), 44.60),
  vertical50: near(core.vfovDeg(50, "9:16", 35), 38.58),
  scope50: near(core.vfovDeg(50, "2.39:1", 35), 16.66)
};
JS
  sb_json_eq "$out" '.wide50' 'true'
  sb_json_eq "$out" '.wide24' 'true'
  sb_json_eq "$out" '.vertical50' 'true'
  sb_json_eq "$out" '.scope50' 'true'
}

# -------------------------------------------------------------- geometry

case_floor_level_pitch() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const low = testDoc([baseShot({ size: "FS", camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, pitchDeg: -20 } })]);
const lowCodes = core.validate(low).errors.map((error) => error.code);
const fitted = testDoc([baseShot({ size: "FS", camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, heightM: 0.4 } })]);
const fittedErrors = core.validate(fitted).errors.map((error) => error.code);
const layout = core.layoutShot(fitted, "s1", "10");
return {
  lowGeometry: lowCodes.indexOf("CAMERA_GEOMETRY") !== -1,
  fittedErrors: fittedErrors,
  heightOk: Math.abs(layout.heightM - 0.4) <= 0.01,
  pitchNegative: layout.pitchDeg < 0
};
JS
  sb_json_eq "$out" '.lowGeometry' 'true'
  sb_json_eq "$out" '.fittedErrors | length' '0'
  sb_json_eq "$out" '.heightOk' 'true'
  sb_json_eq "$out" '.pitchNegative' 'true'
}

case_pov_too_close() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([baseShot({
  size: "CU",
  focus: "a",
  camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, pov: "a" }
})]);
const layout = core.layoutShot(doc, "s1", "10");
const codes = core.validate(doc).errors.map((error) => error.code);
return {
  layoutPresent: layout !== null,
  distanceBelow: layout !== null && layout.distanceM < 0.2,
  distance: layout === null ? null : layout.distanceM,
  hasGeometry: codes.indexOf("CAMERA_GEOMETRY") !== -1
};
JS
  sb_json_eq "$out" '.layoutPresent' 'true'
  sb_json_eq "$out" '.distanceBelow' 'true'
  sb_json_eq "$out" '.hasGeometry' 'true'
}

case_floor_plan_wedge() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const svg = core.renderFloorPlanSvg(testDoc([baseShot()]), "s1");
const wedge = svg.match(/<path d="M([-\d.]+) ([-\d.]+) L([-\d.]+) ([-\d.]+) L([-\d.]+) ([-\d.]+) Z" fill="#c0392b" opacity="0.08"/);
if (!wedge) return { found: false, halfDeg: null };
const ox = Number(wedge[1]);
const oy = Number(wedge[2]);
const ax = Number(wedge[3]) - ox;
const ay = Number(wedge[4]) - oy;
const bx = Number(wedge[5]) - ox;
const by = Number(wedge[6]) - oy;
const cos = Math.min(1, Math.max(-1, (ax * bx + ay * by) / (Math.hypot(ax, ay) * Math.hypot(bx, by))));
const halfDeg = (Math.acos(cos) * 180) / Math.PI / 2;
return { found: true, halfDeg: halfDeg };
JS
  sb_json_eq "$out" '.found' 'true'
  assert_jq "$out" '((.halfDeg - 19.29) | if . < 0 then -. else . end) <= 0.1'
}

case_floor_plan_labels() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const glyphWidth = (text) => {
  let total = 0;
  for (const ch of text) total += ch.charCodeAt(0) > 0x2e80 ? 17 : 9.4;
  return Math.max(20, total);
};
const labels = [];
const circles = [];
for (const scene of sample.scenes) {
  const svg = core.renderFloorPlanSvg(sample, scene.id);
  for (const m of svg.matchAll(/<text class="hint-text" x="([-\d.]+)" y="([-\d.]+)" text-anchor="middle">([^<]*)<\/text>/g)) {
    labels.push({ text: m[3], x: Number(m[1]), y: Number(m[2]), w: glyphWidth(m[3]), h: 19.1 });
  }
  for (const m of svg.matchAll(/<circle data-part="blocking" cx="([-\d.]+)" cy="([-\d.]+)" r="11"/g)) {
    circles.push({ x: Number(m[1]), y: Number(m[2]) });
  }
}
const overlaps = [];
for (let i = 0; i < labels.length; i++) {
  const a = labels[i];
  for (let j = i + 1; j < labels.length; j++) {
    const b = labels[j];
    if (Math.abs(a.x - b.x) < (a.w + b.w) / 2 && Math.abs(a.y - b.y) < (a.h + b.h) / 2) {
      overlaps.push(a.text + "/" + b.text);
    }
  }
  for (const c of circles) {
    if (Math.abs(a.x - c.x) < a.w / 2 + 11 && Math.abs(a.y - c.y) < a.h / 2 + 11) {
      overlaps.push(a.text + "@" + c.x + "," + c.y);
    }
  }
}
return { labels: labels.length, circles: circles.length, overlaps: overlaps };
JS
  assert_jq "$out" '.labels > 6'
  assert_jq "$out" '.circles > 0'
  sb_json_eq "$out" '.overlaps | length' '0'
}

case_horizon_bounds() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const eye = testDoc([baseShot()]);
const eyeHas = core.renderPanelSvg(eye, "s1", "10").indexOf('data-part="horizon"') !== -1;
const steep = testDoc([baseShot({ camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, pitchDeg: 20 } })]);
const steepNo = core.renderPanelSvg(steep, "s1", "10").indexOf('data-part="horizon"') === -1;
const steepInfo = core.lint(steep).info.map((item) => item.code).indexOf("HORIZON_OFFFRAME") !== -1;
const cu = testDoc([baseShot({ size: "CU" })]);
const cuSvg = core.renderPanelSvg(cu, "s1", "10");
return {
  eyeHas: eyeHas,
  steepNo: steepNo,
  steepInfo: steepInfo,
  cuNoGround: cuSvg.indexOf('data-part="ground"') === -1,
  cuHasHorizon: cuSvg.indexOf('data-part="horizon"') !== -1
};
JS
  sb_json_eq "$out" '.eyeHas' 'true'
  sb_json_eq "$out" '.steepNo' 'true'
  sb_json_eq "$out" '.steepInfo' 'true'
  sb_json_eq "$out" '.cuNoGround' 'true'
  sb_json_eq "$out" '.cuHasHorizon' 'true'
}

# ------------------------------------------------------------------- lint

case_axis_crossing() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const crossed = clone(sample);
crossed.scenes[0].shots[4].crossing = null;
const crossedLint = core.lint(crossed);
const declaredLint = core.lint(clone(sample));
return {
  crossedCodes: crossedLint.warnings.map((item) => item.code),
  crossedIntentional: crossedLint.intentional.length,
  declaredCodes: declaredLint.warnings.map((item) => item.code),
  declaredIntentional: declaredLint.intentional.length
};
JS
  assert_jq "$out" '(.crossedCodes | index("AXIS_CROSSED")) != null'
  sb_json_eq "$out" '.crossedIntentional' '0'
  assert_jq "$out" '(.declaredCodes | index("AXIS_CROSSED")) == null'
  sb_json_eq "$out" '.declaredIntentional' '1'
}

case_scene_opener_crossing() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([
  baseShot({ id: "10", crossing: { method: "none", intentional: true, reason: "opener stays on the far side" } })
]);
const linted = core.lint(doc);
return {
  warnings: linted.warnings.length,
  intentional: linted.intentional.map((item) => ({ shot: item.shot, method: item.method, intentional: item.intentional }))
};
JS
  sb_json_eq "$out" '.warnings' '0'
  sb_json_eq "$out" '.intentional | length' '1'
  sb_json_eq "$out" '.intentional[0].shot' '10'
  sb_json_eq "$out" '.intentional[0].method' 'none'
  sb_json_eq "$out" '.intentional[0].intentional' 'true'
}

case_eyeline_mismatch() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([
  baseShot({ id: "10", camera: { yawDeg: 45, rollDeg: 0, focalMm: 50, pitchDeg: 0 } }),
  baseShot({ id: "20", focus: "b", camera: { yawDeg: 45, rollDeg: 0, focalMm: 50, pitchDeg: 0 } })
]);
const codes = core.lint(doc).warnings.map((item) => item.code);
return { codes: codes };
JS
  assert_jq "$out" '(.codes | index("EYELINE_MISMATCH")) != null'
}

case_jump_cut() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([
  baseShot({ id: "10" }),
  baseShot({ id: "20", camera: { yawDeg: 20, rollDeg: 0, focalMm: 50, pitchDeg: 0 } })
]);
return { codes: core.lint(doc).warnings.map((item) => item.code) };
JS
  assert_jq "$out" '(.codes | index("JUMP_CUT")) != null'
}

case_screen_direction_flip() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([
  baseShot({ id: "10", subjectMoves: [{ character: "a", to: { x: 1.4, z: -0.8 }, label: "OUT", primary: false }] }),
  baseShot({ id: "20", size: "CU", subjectMoves: [{ character: "a", to: { x: -1.4, z: -0.8 }, label: "BACK", primary: false }] })
]);
return { codes: core.lint(doc).warnings.map((item) => item.code) };
JS
  assert_jq "$out" '(.codes | index("SCREEN_DIRECTION_FLIP")) != null'
}

case_wide_lens_face() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const wide = testDoc([baseShot({ size: "CU", camera: { yawDeg: 0, rollDeg: 0, focalMm: 18, pitchDeg: 0 } })]);
const normal = testDoc([baseShot({ size: "CU" })]);
return {
  wideCodes: core.lint(wide).warnings.map((item) => item.code),
  normalCodes: core.lint(normal).warnings.map((item) => item.code)
};
JS
  assert_jq "$out" '(.wideCodes | index("WIDE_LENS_FACE")) != null'
  assert_jq "$out" '(.normalCodes | index("WIDE_LENS_FACE")) == null'
}

case_primary_move_overload() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const overload = testDoc([baseShot({
  move: { type: "PUSH IN", endSize: "CU", primary: true },
  subjectMoves: [{ character: "a", to: { x: 1.4, z: -0.8 }, label: "CROSS", primary: true }]
})]);
const single = testDoc([baseShot({
  move: { type: "PUSH IN", endSize: "CU", primary: true },
  subjectMoves: [{ character: "a", to: { x: 1.4, z: -0.8 }, label: "CROSS", primary: false }]
})]);
return {
  overloadCodes: core.lint(overload).warnings.map((item) => item.code),
  singleCodes: core.lint(single).warnings.map((item) => item.code)
};
JS
  assert_jq "$out" '(.overloadCodes | index("PRIMARY_MOVE_OVERLOAD")) != null'
  assert_jq "$out" '(.singleCodes | index("PRIMARY_MOVE_OVERLOAD")) == null'
}

case_omitted_move_primary() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const cameraArrowWidth = (svg) => {
  const line = svg.match(/<line[^>]*stroke="#c0392b" stroke-width="([\d.]+)"/);
  return line ? Number(line[1]) : null;
};
const omitted = testDoc([baseShot({
  move: { type: "PAN L" },
  subjectMoves: [{ character: "a", to: { x: 1.4, z: -0.8 }, label: "CROSS", primary: true }]
})]);
const declared = clone(omitted);
declared.scenes[0].shots[0].move.primary = true;
return {
  omittedErrors: core.validate(omitted).errors.length,
  omittedCodes: core.lint(omitted).warnings.map((item) => item.code),
  omittedWidth: cameraArrowWidth(core.renderPanelSvg(omitted, "s1", "10")),
  declaredCodes: core.lint(declared).warnings.map((item) => item.code),
  declaredWidth: cameraArrowWidth(core.renderPanelSvg(declared, "s1", "10"))
};
JS
  sb_json_eq "$out" '.omittedErrors' '0'
  assert_jq "$out" '(.omittedCodes | index("PRIMARY_MOVE_OVERLOAD")) == null'
  sb_json_eq "$out" '.omittedWidth' '1.5'
  assert_jq "$out" '(.declaredCodes | index("PRIMARY_MOVE_OVERLOAD")) != null'
  sb_json_eq "$out" '.declaredWidth' '2.5'
}

case_subject_move_clipped() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
function drawnPoints(fragment) {
  const points = [];
  for (const line of fragment.matchAll(/<line[^>]*x1="(-?[\d.]+)" y1="(-?[\d.]+)" x2="(-?[\d.]+)" y2="(-?[\d.]+)"/g)) {
    points.push([Number(line[1]), Number(line[2])], [Number(line[3]), Number(line[4])]);
  }
  for (const path of fragment.matchAll(/<path[^>]*\sd="M([^"]+)"/g)) {
    const numbers = (path[1].match(/-?\d+(?:\.\d+)?/g) || []).map(Number);
    for (let i = 0; i + 1 < numbers.length; i += 2) points.push([numbers[i], numbers[i + 1]]);
  }
  return points;
}
const insidePanel = (points) => points.every(([x, y]) => x >= 0 && x <= 1600 && y >= 0 && y <= 900);
const svg = core.renderPanelSvg(sample, "sc2", "50");
const group = svg.match(/<g data-part="subject-move"[^>]*>([\s\S]*?)<\/g>/);
if (!group) return { found: false };
const points = drawnPoints(group[1]);
const line = group[1].match(/<line x1="([\d.]+)" y1="([\d.]+)" x2="([\d.]+)" y2="([\d.]+)"/);
return {
  found: true,
  points: points.length,
  inside: insidePanel(points),
  arrowLength: line === null ? null : Math.hypot(Number(line[3]) - Number(line[1]), Number(line[4]) - Number(line[2])),
  label: svg.indexOf("하늘, 문 쪽으로") !== -1
};
JS
  sb_json_eq "$out" '.found' 'true'
  assert_jq "$out" '.points > 0'
  sb_json_eq "$out" '.inside' 'true'
  assert_jq "$out" '.arrowLength > 80'
  sb_json_eq "$out" '.label' 'true'
}

case_ots_foreground_shoulder() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
function drawnPoints(fragment) {
  const points = [];
  for (const line of fragment.matchAll(/<line[^>]*x1="(-?[\d.]+)" y1="(-?[\d.]+)" x2="(-?[\d.]+)" y2="(-?[\d.]+)"/g)) {
    points.push([Number(line[1]), Number(line[2])], [Number(line[3]), Number(line[4])]);
  }
  for (const path of fragment.matchAll(/<path[^>]*\sd="M([^"]+)"/g)) {
    const numbers = (path[1].match(/-?\d+(?:\.\d+)?/g) || []).map(Number);
    for (let i = 0; i + 1 < numbers.length; i += 2) points.push([numbers[i], numbers[i + 1]]);
  }
  return points;
}
const svg = core.renderPanelSvg(sample, "sc1", "25");
const group = svg.match(/<g data-character="haneul"[^>]*>([\s\S]*?)<\/g>/);
if (!group) return { found: false };
const points = drawnPoints(group[1]);
return {
  found: true,
  foreground: group[0].indexOf('data-part="foreground"') !== -1,
  fill: group[0].indexOf('fill="#e2e2e2"') !== -1,
  paths: (group[1].match(/<path/g) || []).length,
  points: points.length,
  inside: points.every(([x, y]) => x >= 0 && x <= 1600 && y >= 0 && y <= 900),
  minX: points.length === 0 ? null : Math.min(...points.map((point) => point[0]))
};
JS
  sb_json_eq "$out" '.found' 'true'
  sb_json_eq "$out" '.foreground' 'true'
  sb_json_eq "$out" '.fill' 'true'
  assert_jq "$out" '.paths >= 1'
  assert_jq "$out" '.points > 0'
  sb_json_eq "$out" '.inside' 'true'
  assert_jq "$out" '.minX < 1500'
}

case_recorded_crossing_keeps_jump_cut() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([
  baseShot({ id: "10" }),
  baseShot({
    id: "20",
    camera: { yawDeg: 20, rollDeg: 0, focalMm: 50, pitchDeg: 0 },
    crossing: { method: "camera-move", intentional: true, reason: "의도한 점프컷" }
  })
]);
const linted = core.lint(doc);
return {
  codes: linted.warnings.map((item) => item.code),
  intentional: linted.intentional.length
};
JS
  assert_jq "$out" '(.codes | index("JUMP_CUT")) != null'
  sb_json_eq "$out" '.intentional' '1'
}

# ------------------------------------------------------------- mannequin

case_face_markers_from_behind() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const front = core.renderPanelSvg(testDoc([baseShot()]), "s1", "10");
const back = core.renderPanelSvg(testDoc([baseShot({
  camera: { yawDeg: 180, rollDeg: 0, focalMm: 50, pitchDeg: 0 }
})]), "s1", "10");
return {
  frontFace: front.indexOf('data-part="face"') !== -1,
  frontChest: front.indexOf('data-part="chest"') !== -1,
  backFace: back.indexOf('data-part="face"') !== -1,
  backChest: back.indexOf('data-part="chest"') !== -1,
  backHair: back.indexOf('data-part="hair"') !== -1
};
JS
  sb_json_eq "$out" '.frontFace' 'true'
  sb_json_eq "$out" '.frontChest' 'true'
  sb_json_eq "$out" '.backFace' 'false'
  sb_json_eq "$out" '.backChest' 'false'
  sb_json_eq "$out" '.backHair' 'true'
}

case_nose_wedge() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const failures = [];
for (const [sceneId, shotId] of [["sc1", "20"], ["sc2", "50"]]) {
  const where = sceneId + "/" + shotId;
  const svg = core.renderPanelSvg(sample, sceneId, shotId);
  const head = svg.match(/<circle data-part="head" cx="(-?[\d.]+)" cy="(-?[\d.]+)" r="(-?[\d.]+)"/);
  if (!head) { failures.push(where + ": no head"); continue; }
  const cx = Number(head[1]);
  const cy = Number(head[2]);
  const radius = Number(head[3]);
  const face = svg.match(/<g data-part="face">([\s\S]*?)<\/g>/);
  if (!face) { failures.push(where + ": no face"); continue; }
  const nose = face[1].match(/<path[^>]*\sd="M([^"]+)"/);
  if (!nose) { failures.push(where + ": no nose"); continue; }
  const numbers = (nose[1].match(/-?\d+(?:\.\d+)?/g) || []).map(Number);
  if (numbers.length !== 6) { failures.push(where + ": nose has " + numbers.length + " numbers"); continue; }
  for (let i = 0; i < numbers.length; i += 2) {
    const x = numbers[i];
    const y = numbers[i + 1];
    if (Math.hypot(x - cx, y - cy) > 1.6 * radius) failures.push(where + ": nose off head");
    if (x < 0 || x > 1600) failures.push(where + ": nose x out of frame");
    if (y < 0 || y > 900) failures.push(where + ": nose y out of frame");
  }
}
return { failures: failures };
JS
  sb_json_eq "$out" '.failures | length' '0'
}

case_azimuth_sign() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const left = core.layoutShot(testDoc([baseShot({ camera: { yawDeg: 45, rollDeg: 0, focalMm: 50, pitchDeg: 0 } })]), "s1", "10");
const right = core.layoutShot(testDoc([baseShot({ camera: { yawDeg: -45, rollDeg: 0, focalMm: 50, pitchDeg: 0 } })]), "s1", "10");
return {
  leftFacing: left.facingScreen,
  rightFacing: right.facingScreen,
  leftYaw: left.yawName,
  rightYaw: right.yawName
};
JS
  sb_json_eq "$out" '.leftFacing' 'left'
  sb_json_eq "$out" '.rightFacing' 'right'
  sb_json_eq "$out" '.leftYaw' '3/4 L'
  sb_json_eq "$out" '.rightYaw' '3/4 R'
}

# -------------------------------------------------------------- rendering

case_render_deterministic() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
return { same: core.render(sample) === core.render(clone(sample)) };
JS
  sb_json_eq "$out" '.same' 'true'
}

case_user_text_escaped() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = clone(sample);
doc.characters[0].name = '<img src=x onerror=alert(1)>';
const html = core.render(doc);
return {
  escaped: html.indexOf("&lt;img") !== -1,
  rawTag: html.indexOf("<img") !== -1
};
JS
  sb_json_eq "$out" '.escaped' 'true'
  sb_json_eq "$out" '.rawTag' 'false'
}

case_asset_print_rules() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const labelSize = assetSource.match(/\.panel-svg \.move-label\{font-size:(\d+)px/);
return {
  remote: /(?:src|href)\s*=\s*["']?https?:/i.test(assetSource),
  fetch: assetSource.indexOf("fetch(") !== -1,
  xhr: assetSource.indexOf("XMLHttpRequest") !== -1,
  page: assetSource.indexOf("@page { size: A4 landscape") !== -1,
  breakInside: assetSource.indexOf("break-inside: avoid") !== -1,
  labelSize: labelSize === null ? null : Number(labelSize[1])
};
JS
  sb_json_eq "$out" '.remote' 'false'
  sb_json_eq "$out" '.fetch' 'false'
  sb_json_eq "$out" '.xhr' 'false'
  sb_json_eq "$out" '.page' 'true'
  sb_json_eq "$out" '.breakInside' 'true'
  assert_jq "$out" '.labelSize >= 26'
}

case_core_has_no_dead_tables() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
return {
  yawKo: /\bYAW_KO\b/.test(coreSource),
  totalPanels: /\btotalPanels\b/.test(coreSource)
};
JS
  sb_json_eq "$out" '.yawKo' 'false'
  sb_json_eq "$out" '.totalPanels' 'false'
}

case_push_in_end_frame() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([baseShot({ move: { type: "PUSH IN", endSize: "CU", primary: true } })]);
const svg = core.renderPanelSvg(doc, "s1", "10");
return {
  endFrame: svg.indexOf('data-part="end-frame"') !== -1,
  label: svg.indexOf("PUSH IN") !== -1
};
JS
  sb_json_eq "$out" '.endFrame' 'true'
  sb_json_eq "$out" '.label' 'true'
}

case_prop_focus_framing() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = {
  version: 1,
  title: "PROP",
  characters: [{ id: "a", name: "A" }],
  scenes: [{
    id: "s1",
    number: 1,
    heading: "INT. TEST",
    props: [{ id: "cup", label: "컵", x: 0, z: 0, w: 0.1, d: 0.1, h: 0.3 }],
    blocking: [{ character: "a", x: 3, z: 0, facingDeg: 0, pose: "stand" }],
    axis: null,
    shots: [baseShot({ size: "CU", focus: "cup" })]
  }]
};
const layout = core.layoutShot(doc, "s1", "10");
const expected = 0.48 / (2 * Math.tan(11.14 * Math.PI / 180));
return {
  errors: core.validate(doc).errors.length,
  distanceOk: Math.abs(layout.distanceM - expected) <= 0.02,
  distance: layout.distanceM
};
JS
  sb_json_eq "$out" '.errors' '0'
  sb_json_eq "$out" '.distanceOk' 'true'
}

case_prop_rests_on_floor() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = {
  version: 1,
  title: "PROP",
  characters: [{ id: "a", name: "A" }],
  scenes: [{
    id: "s1",
    number: 1,
    heading: "INT. TEST",
    props: [{ id: "cup", label: "컵", x: 0, z: 0, w: 0.1, d: 0.1, h: 0.2 }],
    blocking: [{ character: "a", x: 3, z: 0, facingDeg: 0, pose: "stand" }],
    axis: null,
    shots: [baseShot({ size: "CU", focus: "cup" })]
  }]
};
const layout = core.layoutShot(doc, "s1", "10");
const negative = clone(doc);
negative.scenes[0].props[0].y = -1;
const text = clone(doc);
text.scenes[0].props[0].y = "0.75";
return {
  errors: core.validate(doc).errors.length,
  targetOk: Math.abs(layout.target.y - 0.1) <= 0.01,
  target: layout.target.y,
  negativeCodes: core.validate(negative).errors.map((error) => error.code),
  textCodes: core.validate(text).errors.map((error) => error.code)
};
JS
  sb_json_eq "$out" '.errors' '0'
  sb_json_eq "$out" '.targetOk' 'true'
  sb_json_eq "$out" '.negativeCodes | join("|")' 'SCHEMA_RANGE'
  sb_json_eq "$out" '.textCodes | join("|")' 'SCHEMA_TYPE'
}

case_cup_on_table() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
function drawnPoints(fragment) {
  const points = [];
  for (const line of fragment.matchAll(/<line[^>]*x1="(-?[\d.]+)" y1="(-?[\d.]+)" x2="(-?[\d.]+)" y2="(-?[\d.]+)"/g)) {
    points.push([Number(line[1]), Number(line[2])], [Number(line[3]), Number(line[4])]);
  }
  for (const path of fragment.matchAll(/<path[^>]*\sd="M([^"]+)"/g)) {
    const numbers = (path[1].match(/-?\d+(?:\.\d+)?/g) || []).map(Number);
    for (let i = 0; i + 1 < numbers.length; i += 2) points.push([numbers[i], numbers[i + 1]]);
  }
  return points;
}
const doc = {
  version: 1,
  title: "CUP",
  characters: [{ id: "a", name: "A" }],
  scenes: [{
    id: "s1",
    number: 1,
    heading: "INT. KITCHEN",
    props: [
      { id: "table", label: "식탁", x: 0, z: 0, w: 1, d: 0.6, h: 0.75 },
      { id: "cup", label: "찻잔", x: 0.1, z: -0.05, w: 0.09, d: 0.09, h: 0.1, y: 0.75 }
    ],
    blocking: [{ character: "a", x: 3, z: 0, facingDeg: 0, pose: "stand" }],
    axis: null,
    shots: [baseShot({ size: "CU", focus: "cup", camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, heightM: 0.8 } })]
  }]
};
const layout = core.layoutShot(doc, "s1", "10");
const svg = core.renderPanelSvg(doc, "s1", "10");
const fragments = [...svg.matchAll(/<path[^>]*data-prop="cup"[^>]*>/g)].map((match) => match[0]);
const points = drawnPoints(fragments.join(""));
const xs = points.map((point) => point[0]);
const ys = points.map((point) => point[1]);
return {
  errors: core.validate(doc).errors.length,
  targetOk: Math.abs(layout.target.y - 0.8) <= 0.01,
  angle: layout.angleName,
  fragments: fragments.length,
  points: points.length,
  inside: points.every(([x, y]) => x >= 0 && x <= 1600 && y >= 0 && y <= 900),
  spreadX: points.length === 0 ? 0 : Math.max(...xs) - Math.min(...xs),
  spreadY: points.length === 0 ? 0 : Math.max(...ys) - Math.min(...ys),
  minY: points.length === 0 ? null : Math.min(...ys),
  maxY: points.length === 0 ? null : Math.max(...ys)
};
JS
  sb_json_eq "$out" '.errors' '0'
  sb_json_eq "$out" '.targetOk' 'true'
  sb_json_eq "$out" '.angle' 'EYE LEVEL'
  assert_jq "$out" '.fragments >= 1'
  assert_jq "$out" '.points > 0'
  sb_json_eq "$out" '.inside' 'true'
  assert_jq "$out" '.spreadX > 100'
  assert_jq "$out" '.spreadY > 300'
  assert_jq "$out" '.minY > 60'
  assert_jq "$out" '.maxY < 840'
}

case_picture_style_optional() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([baseShot({ image: { src: TINY_PNG, provenance: "generated", prompt: "kept" } })], {
  style: "inked noir panels"
});
doc.characters[0].look = "tall woman in a raincoat";
const validErrors = core.validate(doc).errors.length;
const variants = [
  ["SCHEMA_TYPE", (d) => { d.scenes[0].shots[0].image.src = "https://example.com/a.png"; }],
  ["SCHEMA_TYPE", (d) => { d.scenes[0].shots[0].image.src = "data:image/gif;base64,QUJD"; }],
  ["SCHEMA_REQUIRED", (d) => { delete d.scenes[0].shots[0].image.provenance; }],
  ["SCHEMA_ENUM", (d) => { d.scenes[0].shots[0].image.provenance = "borrowed"; }],
  ["SCHEMA_TYPE", (d) => { d.style = 5; }],
  ["SCHEMA_TYPE", (d) => { d.characters[0].look = 5; }]
];
const missed = [];
for (const [code, mutate] of variants) {
  const copy = clone(doc);
  mutate(copy);
  if (!core.validate(copy).errors.some((error) => error.code === code)) {
    missed.push(code + " got " + core.validate(copy).errors.map((error) => error.code).join(","));
  }
}
return { validErrors: validErrors, checked: variants.length, missed: missed };
JS
  sb_json_eq "$out" '.validErrors' '0'
  sb_json_eq "$out" '.checked' '6'
  sb_json_eq "$out" '.missed | length' '0'
}

case_panel_no_remote_image() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([baseShot({ image: { src: "https://example.com/a.png", provenance: "supplied", prompt: "kept" } })]);
const svg = core.renderPanelSvg(doc, "s1", "10");
return {
  remote: svg.indexOf("https://example.com") !== -1,
  panelImage: svg.indexOf('data-part="panel-image"') !== -1,
  head: svg.indexOf('data-part="head"') !== -1
};
JS
  sb_json_eq "$out" '.remote' 'false'
  sb_json_eq "$out" '.panelImage' 'false'
  sb_json_eq "$out" '.head' 'true'
}

case_panel_prompt() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([baseShot({
  size: "MCU",
  camera: { yawDeg: 30, rollDeg: 0, focalMm: 50, pitchDeg: -12 },
  action: "She turns toward the door.",
  dialogue: [{ speaker: "A", line: "Do not open it." }]
})], { style: "grey ink manga panels" });
doc.characters[0].look = "short dark hair, navy coat";
const prompt = core.compilePanelPrompt(doc, "s1", "10");
return {
  stable: prompt === core.compilePanelPrompt(clone(doc), "s1", "10"),
  size: prompt.indexOf("medium close-up") !== -1,
  angle: prompt.indexOf("low angle 12°") !== -1,
  facing: prompt.indexOf("screen-left") !== -1,
  lens: prompt.indexOf("50mm") !== -1,
  height: prompt.indexOf("shoulder height 1.17 m") !== -1,
  look: prompt.indexOf("short dark hair, navy coat") !== -1,
  action: prompt.indexOf("She turns toward the door.") !== -1,
  style: prompt.indexOf("grey ink manga panels") !== -1,
  bubbles: prompt.indexOf("speech bubbles") !== -1,
  dialogue: prompt.indexOf("Do not open it.") !== -1,
  unknown: core.compilePanelPrompt(doc, "s1", "nope")
};
JS
  sb_json_eq "$out" '.stable' 'true'
  sb_json_eq "$out" '.size' 'true'
  sb_json_eq "$out" '.angle' 'true'
  sb_json_eq "$out" '.facing' 'true'
  sb_json_eq "$out" '.lens' 'true'
  sb_json_eq "$out" '.height' 'true'
  sb_json_eq "$out" '.look' 'true'
  sb_json_eq "$out" '.action' 'true'
  sb_json_eq "$out" '.style' 'true'
  sb_json_eq "$out" '.bubbles' 'true'
  sb_json_eq "$out" '.dialogue' 'false'
  sb_json_eq "$out" '.unknown' ''
}

case_picture_clipped() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([baseShot({
  image: { src: TINY_PNG, provenance: "supplied", prompt: "kept" },
  move: { type: "PUSH IN", endSize: "CU", primary: true },
  subjectMoves: [{ character: "a", to: { x: 1.2, z: -0.8 }, label: "OUT", primary: false }],
  dialogue: [{ speaker: "A", line: "Listen." }],
  transition: "DISSOLVE"
})]);
const svg = core.renderPanelSvg(doc, "s1", "10");
const image = svg.match(/<image[^>]*>/);
const html = core.render(doc);
return {
  errors: core.validate(doc).errors.length,
  panelImage: svg.indexOf('data-part="panel-image"') !== -1,
  slice: svg.indexOf('preserveAspectRatio="xMidYMid slice"') !== -1,
  clip: svg.indexOf('clip-path="url(#sb-panel-clip-') !== -1,
  imageHref: image !== null && image[0].indexOf('href="' + TINY_PNG + '"') !== -1,
  imageWidth: image !== null && image[0].indexOf('width="1600"') !== -1,
  imageHeight: image !== null && image[0].indexOf('height="900"') !== -1,
  endFrame: svg.indexOf('data-part="end-frame"') !== -1,
  subjectMove: svg.indexOf('data-part="subject-move"') !== -1,
  head: svg.indexOf('data-part="head"') !== -1,
  htmlPanelImage: html.indexOf('data-part="panel-image"') !== -1,
  htmlDialogue: html.indexOf("Listen.") !== -1,
  htmlTransition: html.indexOf("DISSOLVE") !== -1,
  htmlMove: html.indexOf("PUSH IN") !== -1
};
JS
  sb_json_eq "$out" '.errors' '0'
  sb_json_eq "$out" '.panelImage' 'true'
  sb_json_eq "$out" '.slice' 'true'
  sb_json_eq "$out" '.clip' 'true'
  sb_json_eq "$out" '.imageHref' 'true'
  sb_json_eq "$out" '.imageWidth' 'true'
  sb_json_eq "$out" '.imageHeight' 'true'
  sb_json_eq "$out" '.endFrame' 'true'
  sb_json_eq "$out" '.subjectMove' 'true'
  sb_json_eq "$out" '.head' 'false'
  sb_json_eq "$out" '.htmlPanelImage' 'true'
  sb_json_eq "$out" '.htmlDialogue' 'true'
  sb_json_eq "$out" '.htmlTransition' 'true'
  sb_json_eq "$out" '.htmlMove' 'true'
}

case_guide_plain_composition() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const svg = core.renderPanelSvg(sample, "sc1", "10");
const guide = core.renderGuideSvg(sample, "sc1", "10");
const absent = ['<text', 'data-part="end-frame"', 'data-part="subject-move"', 'data-part="panel-image"', 'data-part="frame"', "#c0392b", "<image"];
const present = absent.filter((fragment) => guide.indexOf(fragment) !== -1);
return {
  panelImage: svg.indexOf('data-part="panel-image"') !== -1,
  panelHead: svg.indexOf('data-part="head"') !== -1,
  panelGround: svg.indexOf('data-part="ground"') !== -1,
  stable: guide === core.renderGuideSvg(sample, "sc1", "10"),
  viewBox: guide.indexOf('viewBox="0 0 1600 900"') !== -1,
  head: guide.indexOf('data-part="head"') !== -1,
  ground: guide.indexOf('data-part="ground"') !== -1,
  horizon: guide.indexOf('data-part="horizon"') !== -1,
  present: present,
  unknown: core.renderGuideSvg(sample, "nope", "10")
};
JS
  sb_json_eq "$out" '.panelImage' 'false'
  sb_json_eq "$out" '.panelHead' 'true'
  sb_json_eq "$out" '.panelGround' 'true'
  sb_json_eq "$out" '.stable' 'true'
  sb_json_eq "$out" '.viewBox' 'true'
  sb_json_eq "$out" '.head' 'true'
  sb_json_eq "$out" '.ground' 'true'
  sb_json_eq "$out" '.horizon' 'true'
  sb_json_eq "$out" '.present | length' '0'
  sb_json_eq "$out" '.unknown' ''
}

case_prompt_view_names() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const profile = core.compilePanelPrompt(sample, "sc1", "10");
const back = core.compilePanelPrompt(sample, "sc1", "30");
const dutch = core.compilePanelPrompt(sample, "sc2", "60");
const prop = core.compilePanelPrompt(sample, "sc1", "15");
const rolled = testDoc([baseShot({ camera: { yawDeg: 0, rollDeg: -8, focalMm: 50, pitchDeg: 0 } })]);
return {
  profile: profile.indexOf("profile view (side view)") !== -1,
  count: profile.indexOf("2 characters in frame") !== -1,
  back: back.indexOf("back view") !== -1,
  backNoFacing: back.indexOf("facing screen-") === -1,
  dutch: dutch.indexOf("dutch angle") !== -1,
  tilt: dutch.indexOf("horizon tilted 8° to the right") !== -1,
  propNoFacing: prop.indexOf("facing") === -1,
  propNoView: prop.indexOf("view") === -1,
  rolled: core.compilePanelPrompt(rolled, "s1", "10").indexOf("horizon tilted 8° to the left") !== -1
};
JS
  sb_json_eq "$out" '.profile' 'true'
  sb_json_eq "$out" '.count' 'true'
  sb_json_eq "$out" '.back' 'true'
  sb_json_eq "$out" '.backNoFacing' 'true'
  sb_json_eq "$out" '.dutch' 'true'
  sb_json_eq "$out" '.tilt' 'true'
  sb_json_eq "$out" '.propNoFacing' 'true'
  sb_json_eq "$out" '.propNoView' 'true'
  sb_json_eq "$out" '.rolled' 'true'
}

case_prompt_blocking_sides() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
function guideCharacterX(svg) {
  const totals = new Map();
  for (const tag of svg.match(/<path\b[^>]*>/g) || []) {
    const character = tag.match(/data-character="([^"]+)"/);
    const part = tag.match(/data-part="([^"]+)"/);
    if (!character || (part && part[1] === "foreground")) continue;
    const d = tag.match(/\bd="([^"]+)"/);
    if (!d) continue;
    const numbers = d[1].match(/-?\d+(?:\.\d+)?/g).map(Number);
    const xs = numbers.filter((_, i) => i % 2 === 0);
    totals.set(character[1], (totals.get(character[1]) || []).concat(xs));
  }
  return new Map([...totals].map(([id, xs]) => [id, xs.reduce((sum, x) => sum + x, 0) / xs.length]));
}
const nameOf = (id) => sample.characters.find((character) => character.id === id).name;
const entriesOf = (prompt) => {
  const block = prompt.match(/Blocking: (.+?)\. (?:Action|Props|Style):/);
  if (!block) throw new Error("no blocking clause in: " + prompt);
  return block[1].split("; ");
};
const entryOf = (entries, name) => entries.find((entry) => entry.startsWith(name + " ")) || "";
const prompt = core.compilePanelPrompt(sample, "sc1", "10");
const drawn = [...guideCharacterX(core.renderGuideSvg(sample, "sc1", "10")).entries()].sort((a, b) => a[1] - b[1]);
const entries = entriesOf(prompt);
const ots = core.compilePanelPrompt(sample, "sc1", "25");
const otsEntries = entriesOf(ots);
return {
  drawn: drawn.length,
  entries: entries.length,
  leftSide: entryOf(entries, nameOf(drawn[0][0])).indexOf("on screen-left") !== -1,
  rightSide: entryOf(entries, nameOf(drawn[1][0])).indexOf("on screen-right") !== -1,
  jiwooStanding: entryOf(entries, nameOf("jiwoo")).indexOf("standing") !== -1,
  haneulStanding: entryOf(entries, nameOf("haneul")).indexOf("standing") !== -1,
  jiwooFacing: entryOf(entries, nameOf("jiwoo")).indexOf("facing screen-left") !== -1,
  haneulFacing: entryOf(entries, nameOf("haneul")).indexOf("facing screen-right") !== -1,
  profileClause: prompt.indexOf("profile view (side view), subject facing screen-left") !== -1,
  otsKeys: [...guideCharacterX(core.renderGuideSvg(sample, "sc1", "25")).keys()],
  otsJiwoo: entryOf(otsEntries, nameOf("jiwoo")),
  otsHaneul: entryOf(otsEntries, nameOf("haneul")),
  otsFraming: ots.indexOf("framed from mid-chest to just above the head with small headroom") !== -1
};
JS
  sb_json_eq "$out" '.drawn' '2'
  sb_json_eq "$out" '.entries' '2'
  sb_json_eq "$out" '.leftSide' 'true'
  sb_json_eq "$out" '.rightSide' 'true'
  sb_json_eq "$out" '.jiwooStanding' 'true'
  sb_json_eq "$out" '.haneulStanding' 'true'
  sb_json_eq "$out" '.jiwooFacing' 'true'
  sb_json_eq "$out" '.haneulFacing' 'true'
  sb_json_eq "$out" '.profileClause' 'true'
  sb_json_eq "$out" '.otsKeys | join("|")' 'jiwoo'
  sb_json_eq "$out" '.otsJiwoo' '지우 at the centre of frame, standing, facing the camera'
  sb_json_eq "$out" '.otsHaneul' '하늘 in the foreground, near shoulder only'
  sb_json_eq "$out" '.otsFraming' 'true'
}

case_framing_clause() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const framing = (size, over) => {
  const prompt = core.compilePanelPrompt(testDoc([baseShot(Object.assign({ size: size }, over || {}))]), "s1", "10");
  const match = prompt.match(/Framing: (.+?)\. Camera/);
  if (!match) throw new Error("no framing clause in: " + prompt);
  return match[1];
};
return {
  ecu: framing("ECU"),
  cu: framing("CU"),
  mcu: framing("MCU"),
  ms: framing("MS"),
  cowboy: framing("COWBOY"),
  mws: framing("MWS"),
  fs: framing("FS"),
  ws: framing("WS"),
  ots: framing("OTS", { camera: { yawDeg: 0, rollDeg: 0, focalMm: 85, over: "b" } }),
  propFraming: core.compilePanelPrompt(sample, "sc1", "15").indexOf("Framing:") !== -1
};
JS
  sb_json_eq "$out" '.ecu' 'framed from the chin to just above the head, tight on the face, small headroom, top of the head inside the frame'
  sb_json_eq "$out" '.cu' 'framed from the shoulders to just above the head, small headroom, the whole head inside the frame'
  sb_json_eq "$out" '.mcu' 'framed from mid-chest to just above the head, small headroom, top of the head fully inside the frame'
  sb_json_eq "$out" '.ms' 'framed from the waist to just above the head, headroom above the head'
  sb_json_eq "$out" '.cowboy' 'framed from mid-thigh to just above the head, headroom above the head'
  sb_json_eq "$out" '.mws' 'framed from the knees to just above the head, headroom above the head'
  sb_json_eq "$out" '.fs' 'full figures head to feet with floor visible'
  sb_json_eq "$out" '.ws' 'full figures head to feet with floor visible'
  sb_json_eq "$out" '.ots' "over the near character's shoulder, near shoulder in the foreground, framed from mid-chest to just above the head with small headroom"
  sb_json_eq "$out" '.propFraming' 'false'
}

case_blocking_pose_last_clause() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = testDoc([baseShot({ size: "MS", subjects: ["a", "b"] })]);
doc.scenes[0].blocking[0].pose = "sit";
doc.scenes[0].blocking[1].pose = "walk";
const prompt = core.compilePanelPrompt(doc, "s1", "10");
return {
  sitting: prompt.indexOf("A at the centre of frame, sitting, facing the camera") !== -1,
  walking: prompt.indexOf("B at the centre of frame, walking, facing away from the camera") !== -1,
  endsWithTextClause: prompt.endsWith("Do not draw any text, letters, numbers, captions, or speech bubbles in the image."),
  modelNames: /gpt|dall-?e|stable diffusion|midjourney|nano banana/i.test(prompt)
};
JS
  sb_json_eq "$out" '.sitting' 'true'
  sb_json_eq "$out" '.walking' 'true'
  sb_json_eq "$out" '.endsWithTextClause' 'true'
  sb_json_eq "$out" '.modelNames' 'false'
}

case_unknown_ids() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
return {
  layoutByScene: core.layoutShot(sample, "nope", "10"),
  layoutByShot: core.layoutShot(sample, "sc1", "nope"),
  panel: core.renderPanelSvg(sample, "sc1", "nope"),
  floorPlan: core.renderFloorPlanSvg(sample, "nope")
};
JS
  sb_json_eq "$out" '.layoutByScene' 'null'
  sb_json_eq "$out" '.layoutByShot' 'null'
  sb_json_eq "$out" '.panel' ''
  sb_json_eq "$out" '.floorPlan' ''
}

# ----------------------------------------------------------------- browser

case_webview_sample() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_webview_without_lens() {
  skip "visual render needs a browser; outside the automated bash suite"
}

case_scene_plan_image() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const doc = clone(sample);
const before = core.render(doc).indexOf('data-part="plan-image"') !== -1;
doc.scenes[0].planImage = { src: "https://example.com/plan.png", provenance: "generated" };
const badSrc = core.validate(doc).errors.map((error) => error.code + " " + error.path);
doc.scenes[0].planImage = { src: TINY_PNG, provenance: "drawn" };
const badProvenance = core.validate(doc).errors.map((error) => error.code + " " + error.path);
doc.scenes[0].planImage = { src: TINY_PNG, provenance: "generated", prompt: "plan" };
const errors = core.validate(doc).errors.length;
const html = core.render(doc);
return {
  before: before,
  badSrc: badSrc,
  badProvenance: badProvenance,
  errors: errors,
  count: (html.match(/data-part="plan-image"/g) || []).length,
  planFirst: html.indexOf('class="floorplan"') < html.indexOf('data-part="plan-image"'),
  remote: html.indexOf("https://example.com") !== -1
};
JS
  sb_json_eq "$out" '.before' 'false'
  sb_json_eq "$out" '.badSrc | join("|")' 'SCHEMA_TYPE scenes[0].planImage.src'
  sb_json_eq "$out" '.badProvenance | join("|")' 'SCHEMA_ENUM scenes[0].planImage.provenance'
  sb_json_eq "$out" '.errors' '0'
  sb_json_eq "$out" '.count' '1'
  sb_json_eq "$out" '.planFirst' 'true'
  sb_json_eq "$out" '.remote' 'false'
}

case_floor_plan_prompt() {
  local dir out
  dir=$(new_workdir)
  out=$dir/probe.json
  probe "$dir" <<'JS'
const prompt = core.compileFloorPlanPrompt(sample, "sc1");
const propsPresent = sample.scenes[0].props.map((prop) => prompt.indexOf(prop.label) !== -1);
const namesPresent = sample.scenes[0].blocking.map((block) =>
  prompt.indexOf(sample.characters.find((character) => character.id === block.character).name) !== -1
);
return {
  stable: prompt === core.compileFloorPlanPrompt(sample, "sc1"),
  topDown: prompt.indexOf("top-down") !== -1,
  propsMissing: propsPresent.filter((ok) => !ok).length,
  namesMissing: namesPresent.filter((ok) => !ok).length,
  jiwoo: /지우[^;]*lower[^;]*facing up/.test(prompt),
  haneul: /하늘[^;]*upper[^;]*facing down/.test(prompt),
  endsWithTextClause: prompt.endsWith("Do not draw any text, letters, numbers, labels, arrows, or captions in the image."),
  siting: /siting/.test(prompt),
  unknown: core.compileFloorPlanPrompt(sample, "nope")
};
JS
  sb_json_eq "$out" '.stable' 'true'
  sb_json_eq "$out" '.topDown' 'true'
  sb_json_eq "$out" '.propsMissing' '0'
  sb_json_eq "$out" '.namesMissing' '0'
  sb_json_eq "$out" '.jiwoo' 'true'
  sb_json_eq "$out" '.haneul' 'true'
  sb_json_eq "$out" '.endsWithTextClause' 'true'
  sb_json_eq "$out" '.siting' 'false'
  sb_json_eq "$out" '.unknown' ''
}

# ------------------------------------------------------------------- runner

run_case "the shipped sample validates clean, lints clean, and records one intentional crossing" case_shipped_sample
run_case "the schema rejects malformed shots with the documented error codes" case_schema_rejects
run_case "the vertical field of view matches the 35 mm sensor table" case_vfov_table
run_case "a floor-level pitch fails while the same height fits and derives a negative pitch" case_floor_level_pitch
run_case "a POV camera closer than a lens can focus fails camera geometry" case_pov_too_close
run_case "the floor-plan wedge spans the true half angle of the horizontal field of view" case_floor_plan_wedge
run_case "floor-plan labels clear each other and the character circles in the sample" case_floor_plan_labels
run_case "the horizon is drawn only inside the vertical field of view and the ground disappears for a close-up" case_horizon_bounds
run_case "crossing the axis warns, and a recorded crossing suppresses it into intentional" case_axis_crossing
run_case "a scene opener records its crossing even without a previous cut" case_scene_opener_crossing
run_case "eyeline mismatch fires when two solo shots of the axis pair look the same way" case_eyeline_mismatch
run_case "a jump cut fires below thirty degrees of azimuth change on the same focus and size" case_jump_cut
run_case "a reversed subject move between cuts warns about screen direction" case_screen_direction_flip
run_case "a wide lens on a close-up warns about face distortion" case_wide_lens_face
run_case "more than one primary move in a shot warns" case_primary_move_overload
run_case "an omitted move primary draws the secondary arrow weight and never counts as primary" case_omitted_move_primary
run_case "a subject move is clipped into the frame and keeps its label" case_subject_move_clipped
run_case "the over character draws an on-frame foreground shoulder for an OTS shot" case_ots_foreground_shoulder
run_case "a recorded crossing never hides a jump cut" case_recorded_crossing_keeps_jump_cut
run_case "face and chest markers vanish from behind while the hair mass appears" case_face_markers_from_behind
run_case "the nose wedge sits on the head and stays inside the frame" case_nose_wedge
run_case "the azimuth sign decides which way the nose points on screen" case_azimuth_sign
run_case "rendering the same document twice returns the same string" case_render_deterministic
run_case "user text is XML-escaped before it reaches the board" case_user_text_escaped
run_case "the asset carries no remote resources and ships A4 landscape print rules" case_asset_print_rules
run_case "the core carries no dead panel counter and no unused yaw translation table" case_core_has_no_dead_tables
run_case "a push in draws the end frame and prints its label" case_push_in_end_frame
run_case "a prop focus without subjects frames at 1.6x its height" case_prop_focus_framing
run_case "a prop rests on the floor by default and rejects a bad base elevation" case_prop_rests_on_floor
run_case "a cup set on a table is framed at its resting height and drawn inside the panel" case_cup_on_table
run_case "a panel picture, a style and a character look are optional and the picture must be a data URI" case_picture_style_optional
run_case "the panel renderer never emits a non-data image source on the direct path" case_panel_no_remote_image
run_case "the panel prompt repeats deterministically and carries the computed framing without dialogue" case_panel_prompt
run_case "a shot with a picture clips it to the frame and keeps the movement notation and notes" case_picture_clipped
run_case "a shot without a picture keeps the line art and the guide is a plain deterministic composition" case_guide_plain_composition
run_case "the prompt names the yaw view, the dutch tilt and the character count" case_prompt_view_names
run_case "the prompt blocks each figure on the side the guide draws, with pose and facing" case_prompt_blocking_sides
run_case "the framing clause states the crop and the headroom for each shot size" case_framing_clause
run_case "the blocking pose comes from the blocking entry and the text clause stays last" case_blocking_pose_last_clause
run_case "unknown ids return null or an empty string instead of throwing" case_unknown_ids
run_case "the injected sample renders every panel and no browser error (requires Bun.WebView)" case_webview_sample
run_case "a document without a lens reports the error and draws nothing (requires Bun.WebView)" case_webview_without_lens
run_case "a scene floor-plan picture is validated like a panel picture and drawn beside the technical plan" case_scene_plan_image
run_case "the floor-plan prompt names every prop and character with plan positions and ends with the no-text clause" case_floor_plan_prompt

test_summary
