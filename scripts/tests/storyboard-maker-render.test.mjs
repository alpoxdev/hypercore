#!/usr/bin/env bun
/// <reference types="bun" />
// @ts-check
/**
 * storyboard-maker renderer gate.
 *
 * The studio asset is a pure core script plus a thin DOM layer. Everything that
 * decides what a panel looks like - the vertical field of view, the camera
 * orbit, the horizon and ground rules, the mannequin markers and the continuity
 * lint - lives in `<script id="storyboard-core">` and is evaluated here in a VM,
 * with no browser. The final case loads the asset in `Bun.WebView`, injects the
 * shipped sample into `#storyboard-doc`, and reads the report back from
 * `window.storyboardStudio`.
 *
 * Assertions are on computed numbers, drawn `data-part` markers, and string
 * equality of two renders. Prose is never asserted.
 */
import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { runInNewContext } from "node:vm";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const assetPath = join(root, "skills/storyboard-maker/assets/storyboard-studio.html");
const samplePath = join(root, "skills/storyboard-maker/assets/sample-storyboard.json");
const assetSource = readFileSync(assetPath, "utf8");
const sampleDoc = JSON.parse(readFileSync(samplePath, "utf8"));

const coreMatch = assetSource.match(/<script[^>]*id="storyboard-core"[^>]*>([\s\S]*?)<\/script>/);
if (!coreMatch) throw new Error("storyboard-core script not found in " + assetPath);
const core = runInNewContext(coreMatch[1] + "\n;StoryboardCore;");
const WebView = Reflect.get(Bun, "WebView");
const hasWebView = typeof WebView === "function";
const samplePanels = sampleDoc.scenes.reduce((n, scene) => n + scene.shots.length, 0);

// ---------------------------------------------------------------- fixtures

/** @param {any} value */
const clone = (value) => JSON.parse(JSON.stringify(value));

/** @param {Record<string, any>} [over] */
function baseShot(over = {}) {
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
  }, over);
}

/**
 * Two characters a metre apart, facing each other on the z axis.
 * @param {any[]} shots
 * @param {any} [over]
 */
function testDoc(shots, over = {}) {
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
  }, over);
}

/** @param {string[]} codes */
const codeList = (report) => report.warnings.map((item) => item.code);
const near = (actual, expected, tolerance = 0.01) => expect(Math.abs(actual - expected)).toBeLessThanOrEqual(tolerance);

/** @param {any} doc */
function pageWith(doc) {
  const embedded = JSON.stringify(doc).replace(/<\//g, "<\\/");
  return assetSource.replace(
    '<script type="application/json" id="storyboard-doc"></script>',
    '<script type="application/json" id="storyboard-doc">' + embedded + "</script>"
  );
}

/**
 * Copy a page into a fresh temp dir and run one probe in Bun.WebView.
 * @param {string} source
 * @param {string} body async in-page body; its resolved value is returned
 * @returns {Promise<any>}
 */
async function observe(source, body) {
  const dir = mkdtempSync(join(tmpdir(), "sbm-render-"));
  try {
    writeFileSync(join(dir, "index.html"), source);
    const view = new WebView({ width: 1400, height: 1000 });
    try {
      await view.navigate(`file://${join(dir, "index.html")}`);
      const value = await view.evaluate(`(() => { return (async () => { ${body} })(); })()`);
      if (value && typeof value === "object" && "error" in value) throw new Error(value.error);
      return value;
    } finally {
      view.close();
    }
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

// ------------------------------------------------------------------ sample

test("the shipped sample validates clean, lints clean, and records one intentional crossing", () => {
  const v = core.validate(sampleDoc);
  expect(v.errors).toEqual([]);
  const l = core.lint(sampleDoc);
  expect(l.warnings).toEqual([]);
  expect(l.intentional).toHaveLength(1);
  expect(l.intentional[0]).toMatchObject({ shot: "30", method: "neutral", intentional: true });
  expect(l.intentional[0].reason).toBeTruthy();
  expect(samplePanels).toBeGreaterThanOrEqual(6);
  expect(sampleDoc.scenes.length).toBeGreaterThanOrEqual(2);
});

// ------------------------------------------------------------------ schema

test("the schema rejects malformed shots with the documented error codes", () => {
  /** @type {Array<[string, (doc: any) => void]>} */
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
  for (const [code, mutate] of variants) {
    const doc = testDoc([baseShot()]);
    mutate(doc);
    const v = core.validate(doc);
    expect({ code, codes: v.errors.map((e) => e.code) }).toMatchObject({ code });
    expect(v.errors.some((e) => e.code === code)).toBe(true);
  }
});

// ---------------------------------------------------------------- optics

test("the vertical field of view matches the 35 mm sensor table", () => {
  near(core.vfovDeg(50, "16:9", 35), 22.28);
  near(core.vfovDeg(24, "16:9", 35), 44.60);
  near(core.vfovDeg(50, "9:16", 35), 38.58);
  near(core.vfovDeg(50, "2.39:1", 35), 16.66);
});

// -------------------------------------------------------------- geometry

test("a floor-level pitch fails while the same height fits and derives a negative pitch", () => {
  const low = testDoc([baseShot({ size: "FS", camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, pitchDeg: -20 } })]);
  expect(core.validate(low).errors.map((e) => e.code)).toContain("CAMERA_GEOMETRY");

  const fitted = testDoc([baseShot({ size: "FS", camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, heightM: 0.4 } })]);
  expect(core.validate(fitted).errors).toEqual([]);
  const layout = core.layoutShot(fitted, "s1", "10");
  near(layout.heightM, 0.4);
  expect(layout.pitchDeg).toBeLessThan(0);
});

test("the horizon is drawn only inside the vertical field of view and the ground disappears for a close-up", () => {
  const eye = testDoc([baseShot()]);
  expect(core.renderPanelSvg(eye, "s1", "10")).toContain('data-part="horizon"');

  const steep = testDoc([baseShot({ camera: { yawDeg: 0, rollDeg: 0, focalMm: 50, pitchDeg: 20 } })]);
  expect(core.renderPanelSvg(steep, "s1", "10")).not.toContain('data-part="horizon"');
  expect(core.lint(steep).info.map((item) => item.code)).toContain("HORIZON_OFFFRAME");

  const closeUp = testDoc([baseShot({ size: "CU" })]);
  const svg = core.renderPanelSvg(closeUp, "s1", "10");
  expect(svg).not.toContain('data-part="ground"');
  expect(svg).toContain('data-part="horizon"');
});

// ------------------------------------------------------------------- lint

test("crossing the axis warns, and a recorded crossing suppresses it into intentional", () => {
  const crossed = clone(sampleDoc);
  crossed.scenes[0].shots[4].crossing = null;
  expect(codeList(core.lint(crossed))).toContain("AXIS_CROSSED");
  expect(core.lint(crossed).intentional).toHaveLength(0);

  const declared = clone(sampleDoc);
  const linted = core.lint(declared);
  expect(codeList(linted)).not.toContain("AXIS_CROSSED");
  expect(linted.intentional).toHaveLength(1);
});

test("eyeline mismatch fires when two solo shots of the axis pair look the same way", () => {
  const doc = testDoc([
    baseShot({ id: "10", camera: { yawDeg: 45, rollDeg: 0, focalMm: 50, pitchDeg: 0 } }),
    baseShot({ id: "20", focus: "b", camera: { yawDeg: 45, rollDeg: 0, focalMm: 50, pitchDeg: 0 } })
  ]);
  expect(codeList(core.lint(doc))).toContain("EYELINE_MISMATCH");
});

test("a jump cut fires below thirty degrees of azimuth change on the same focus and size", () => {
  const doc = testDoc([
    baseShot({ id: "10" }),
    baseShot({ id: "20", camera: { yawDeg: 20, rollDeg: 0, focalMm: 50, pitchDeg: 0 } })
  ]);
  expect(codeList(core.lint(doc))).toContain("JUMP_CUT");
});

test("a reversed subject move between cuts warns about screen direction", () => {
  const doc = testDoc([
    baseShot({ id: "10", subjectMoves: [{ character: "a", to: { x: 1.4, z: -0.8 }, label: "OUT", primary: false }] }),
    baseShot({ id: "20", size: "CU", subjectMoves: [{ character: "a", to: { x: -1.4, z: -0.8 }, label: "BACK", primary: false }] })
  ]);
  expect(codeList(core.lint(doc))).toContain("SCREEN_DIRECTION_FLIP");
});

test("a wide lens on a close-up warns about face distortion", () => {
  const doc = testDoc([baseShot({ size: "CU", camera: { yawDeg: 0, rollDeg: 0, focalMm: 18, pitchDeg: 0 } })]);
  expect(codeList(core.lint(doc))).toContain("WIDE_LENS_FACE");

  const normal = testDoc([baseShot({ size: "CU" })]);
  expect(codeList(core.lint(normal))).not.toContain("WIDE_LENS_FACE");
});

test("more than one primary move in a shot warns", () => {
  const doc = testDoc([baseShot({
    move: { type: "PUSH IN", endSize: "CU", primary: true },
    subjectMoves: [{ character: "a", to: { x: 1.4, z: -0.8 }, label: "CROSS", primary: true }]
  })]);
  expect(codeList(core.lint(doc))).toContain("PRIMARY_MOVE_OVERLOAD");

  const single = testDoc([baseShot({
    move: { type: "PUSH IN", endSize: "CU", primary: true },
    subjectMoves: [{ character: "a", to: { x: 1.4, z: -0.8 }, label: "CROSS", primary: false }]
  })]);
  expect(codeList(core.lint(single))).not.toContain("PRIMARY_MOVE_OVERLOAD");
});

test("a subject move is clipped into the frame and keeps its label", () => {
  const svg = core.renderPanelSvg(sampleDoc, "sc2", "50");
  const group = svg.match(/<g data-part="subject-move"[^>]*>([\s\S]*?)<\/g>/);
  expect(group).not.toBeNull();
  expectInsidePanel(drawnPoints(group[1]), 1600, 900);
  const line = group[1].match(/<line x1="([\d.]+)" y1="([\d.]+)" x2="([\d.]+)" y2="([\d.]+)"/);
  expect(line).not.toBeNull();
  const arrowLength = Math.hypot(Number(line[3]) - Number(line[1]), Number(line[4]) - Number(line[2]));
  expect(arrowLength).toBeGreaterThan(80);
  expect(svg).toContain("하늘, 문 쪽으로");
});

test("the over character draws an on-frame foreground shoulder for an OTS shot", () => {
  const svg = core.renderPanelSvg(sampleDoc, "sc1", "25");
  const group = svg.match(/<g data-character="haneul"[^>]*>([\s\S]*?)<\/g>/);
  expect(group).not.toBeNull();
  expect(group[0]).toContain('data-part="foreground"');
  expect((group[1].match(/<path/g) || []).length).toBeGreaterThanOrEqual(1);
  const points = drawnPoints(group[1]);
  expectInsidePanel(points, 1600, 900);
  expect(Math.min(...points.map((point) => point[0]))).toBeLessThan(1500);
});

test("a recorded crossing never hides a jump cut", () => {
  const doc = testDoc([
    baseShot({ id: "10" }),
    baseShot({
      id: "20",
      camera: { yawDeg: 20, rollDeg: 0, focalMm: 50, pitchDeg: 0 },
      crossing: { method: "camera-move", intentional: true, reason: "의도한 점프컷" }
    })
  ]);
  expect(codeList(core.lint(doc))).toContain("JUMP_CUT");
  expect(core.lint(doc).intentional).toHaveLength(1);
});

/** @param {string} fragment */
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

/** @param {Array<[number, number]>} points */
function expectInsidePanel(points, width, height) {
  expect(points.length).toBeGreaterThan(0);
  for (const [x, y] of points) {
    expect(x).toBeGreaterThanOrEqual(0);
    expect(x).toBeLessThanOrEqual(width);
    expect(y).toBeGreaterThanOrEqual(0);
    expect(y).toBeLessThanOrEqual(height);
  }
}

// ------------------------------------------------------------- mannequin

test("face and chest markers vanish from behind while the hair mass appears", () => {
  const front = core.renderPanelSvg(testDoc([baseShot()]), "s1", "10");
  expect(front).toContain('data-part="face"');
  expect(front).toContain('data-part="chest"');

  const back = core.renderPanelSvg(testDoc([baseShot({
    camera: { yawDeg: 180, rollDeg: 0, focalMm: 50, pitchDeg: 0 }
  })]), "s1", "10");
  expect(back).not.toContain('data-part="face"');
  expect(back).not.toContain('data-part="chest"');
  expect(back).toContain('data-part="hair"');
});

test("the nose wedge sits on the head and stays inside the frame", () => {
  for (const [sceneId, shotId] of [["sc1", "20"], ["sc2", "50"]]) {
    const svg = core.renderPanelSvg(sampleDoc, sceneId, shotId);
    const head = svg.match(/<circle data-part="head" cx="(-?[\d.]+)" cy="(-?[\d.]+)" r="(-?[\d.]+)"/);
    expect(head).not.toBeNull();
    const cx = Number(head[1]), cy = Number(head[2]), radius = Number(head[3]);
    const face = svg.match(/<g data-part="face">([\s\S]*?)<\/g>/);
    expect(face).not.toBeNull();
    const nose = face[1].match(/<path[^>]*\sd="M([^"]+)"/);
    expect(nose).not.toBeNull();
    const numbers = (nose[1].match(/-?\d+(?:\.\d+)?/g) || []).map(Number);
    expect(numbers.length).toBe(6);
    for (let i = 0; i < numbers.length; i += 2) {
      const x = numbers[i], y = numbers[i + 1];
      expect(Math.hypot(x - cx, y - cy)).toBeLessThanOrEqual(1.6 * radius);
      expect(x).toBeGreaterThanOrEqual(0);
      expect(x).toBeLessThanOrEqual(1600);
      expect(y).toBeGreaterThanOrEqual(0);
      expect(y).toBeLessThanOrEqual(900);
    }
  }
});

test("the azimuth sign decides which way the nose points on screen", () => {
  const left = core.layoutShot(testDoc([baseShot({ camera: { yawDeg: 45, rollDeg: 0, focalMm: 50, pitchDeg: 0 } })]), "s1", "10");
  const right = core.layoutShot(testDoc([baseShot({ camera: { yawDeg: -45, rollDeg: 0, focalMm: 50, pitchDeg: 0 } })]), "s1", "10");
  expect(left.facingScreen).toBe("left");
  expect(right.facingScreen).toBe("right");
  expect(left.yawName).toBe("3/4 L");
  expect(right.yawName).toBe("3/4 R");
});

// -------------------------------------------------------------- rendering

test("rendering the same document twice returns the same string", () => {
  expect(core.render(sampleDoc)).toBe(core.render(clone(sampleDoc)));
});

test("user text is XML-escaped before it reaches the board", () => {
  const doc = clone(sampleDoc);
  doc.characters[0].name = '<img src=x onerror=alert(1)>';
  const html = core.render(doc);
  expect(html).toContain("&lt;img");
  expect(html).not.toContain("<img");
});

test("the asset carries no remote resources and ships A4 landscape print rules", () => {
  expect(/(?:src|href)\s*=\s*["']?https?:/i.test(assetSource)).toBe(false);
  expect(assetSource).not.toContain("fetch(");
  expect(assetSource).not.toContain("XMLHttpRequest");
  expect(assetSource).toContain("@page { size: A4 landscape");
  expect(assetSource).toContain("break-inside: avoid");
  const labelSize = assetSource.match(/\.panel-svg \.move-label\{font-size:(\d+)px/);
  expect(labelSize).not.toBeNull();
  expect(Number(labelSize[1])).toBeGreaterThanOrEqual(26);
});

test("a push in draws the end frame and prints its label", () => {
  const doc = testDoc([baseShot({ move: { type: "PUSH IN", endSize: "CU", primary: true } })]);
  const svg = core.renderPanelSvg(doc, "s1", "10");
  expect(svg).toContain('data-part="end-frame"');
  expect(svg).toContain("PUSH IN");
});

test("a prop focus without subjects frames at 1.6x its height", () => {
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
  expect(core.validate(doc).errors).toEqual([]);
  const layout = core.layoutShot(doc, "s1", "10");
  const expected = 0.48 / (2 * Math.tan(11.14 * Math.PI / 180));
  near(layout.distanceM, expected, 0.02);
});

test("unknown ids return null or an empty string instead of throwing", () => {
  expect(core.layoutShot(sampleDoc, "nope", "10")).toBeNull();
  expect(core.layoutShot(sampleDoc, "sc1", "nope")).toBeNull();
  expect(core.renderPanelSvg(sampleDoc, "sc1", "nope")).toBe("");
  expect(core.renderFloorPlanSvg(sampleDoc, "nope")).toBe("");
});

// ----------------------------------------------------------------- browser

test.skipIf(!hasWebView)("the injected sample renders every panel and no browser error (requires Bun.WebView)", async () => {
  const value = await observe(pageWith(sampleDoc), `
    const report = window.storyboardStudio.getReport();
    return {
      errors: report.errors.length,
      warnings: report.warnings.length,
      intentional: report.intentional.length,
      panels: report.panels,
      scenes: report.scenes,
      domPanels: document.querySelectorAll("article.panel").length,
      statusError: document.querySelector("#status").dataset.error === "true"
    };
  `);
  expect(value.errors).toBe(0);
  expect(value.warnings).toBe(0);
  expect(value.intentional).toBe(1);
  expect(value.panels).toBe(samplePanels);
  expect(value.domPanels).toBe(samplePanels);
  expect(value.scenes).toBe(sampleDoc.scenes.length);
  expect(value.statusError).toBe(false);
});

test.skipIf(!hasWebView)("a document without a lens reports the error and draws nothing (requires Bun.WebView)", async () => {
  const broken = clone(sampleDoc);
  delete broken.scenes[0].shots[0].camera.focalMm;
  const value = await observe(pageWith(broken), `
    const report = window.storyboardStudio.getReport();
    return {
      firstCode: report.errors.length ? report.errors[0].code : "",
      panels: report.panels,
      domPanels: document.querySelectorAll("article.panel").length,
      statusError: document.querySelector("#status").dataset.error === "true"
    };
  `);
  expect(value.firstCode).toBe("SCHEMA_REQUIRED");
  expect(value.panels).toBe(0);
  expect(value.domPanels).toBe(0);
  expect(value.statusError).toBe(true);
});
