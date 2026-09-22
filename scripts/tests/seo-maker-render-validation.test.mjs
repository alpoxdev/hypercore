#!/usr/bin/env bun
// @ts-check
/**
 * seo-maker dashboard renderer structure gate (plan todo 6).
 *
 * `render-dashboard.mjs` reads an untrusted `results.json`, so it must reject a
 * structurally invalid payload through its existing `fail()` path (exit 1)
 * before it writes anything, and it must leave a previously rendered output
 * pair byte-identical when it does. Unknown extra keys stay allowed (K9).
 *
 * Every case builds its artifact directory with `mkdtemp`, seeds the payload,
 * and runs the shipped renderer as a subprocess; the repository tree is never
 * written to. `SEO_MAKER_RENDER_DASHBOARD` points the run at a mutated copy of
 * the renderer so a negative control can target it without touching the repo.
 */
import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const rendererPath = process.env.SEO_MAKER_RENDER_DASHBOARD
  ? resolve(process.env.SEO_MAKER_RENDER_DASHBOARD)
  : join(root, "skills/seo-maker/scripts/render-dashboard.mjs");
const templatePath = join(root, "skills/seo-maker/assets/dashboard-template.html");

const PRIOR_DASHBOARD = "prior dashboard\n";
const PRIOR_RESULTS_JS = "prior results\n";
const PRIOR_DASHBOARD_MODE = 0o640;
const PRIOR_RESULTS_JS_MODE = 0o600;
const RESULTS_JS_PREFIX = "window.__SEO_RESULTS__ = ";

const CATEGORY_NAMES = ["Technical SEO", "On-Page SEO", "Content SEO", "Core Web Vitals", "Structured Data", "AEO Readiness", "GEO Readiness"];
const CANONICAL_WEIGHTS = [20, 20, 15, 15, 10, 10, 10];

/** A structurally valid payload that exercises every field the gate reads. */
const VALID_RESULTS = {
  project_name: "fixture-site",
  date: "2026-09-21",
  scope: "Full site audit",
  status: "complete",
  overall_grade: "C",
  categories: CATEGORY_NAMES.map((name, index) => ({
    name,
    status: index === 6 ? "unknown" : "measured",
    score: index === 6 ? null : [85, 72, 68, 90, 88, 45, null][index],
    evidence: `${name} evidence`,
    confidence: "high",
  })),
  findings: [
    {
      id: "T1",
      severity: "critical",
      category: "Technical SEO",
      finding: "robots.txt blocks /blog/ path",
      location: "/robots.txt:3",
      evidence_grade: "lab",
      confidence: "high",
      measurement_method: "static robots.txt scan",
      source_tier: "observed-file",
      recommendation: "Remove Disallow: /blog/",
    },
    {
      id: "A1",
      severity: "warning",
      category: "AEO Readiness",
      finding: "No direct answer in first paragraph",
      location: "/blog/what-is-seo.html",
      evidence_grade: "heuristic",
      confidence: "medium",
      measurement_method: "answer block detector",
      source_tier: "research-backed-heuristic",
      recommendation: "Add a concise visible answer block",
    },
  ],
  score_history: [
    {
      iteration: 0,
      score: 66,
      grade: "C",
      critical_count: 1,
      decision: "baseline",
      evidence: "Initial audit before optimization changes",
      evaluator_version: "seo-maker-evaluator/1",
      weights: CANONICAL_WEIGHTS,
    },
    {
      iteration: 1,
      score: 78,
      grade: "B",
      critical_count: 0,
      decision: "kept",
      changed: "Removed robots.txt block for /blog/",
      evidence: "Re-audit confirmed indexability restored",
      evaluator_version: "seo-maker-evaluator/1",
      weights: CANONICAL_WEIGHTS,
    },
  ],
  best_run: { iteration: 1, score: 78, grade: "B", reason: "Highest kept score with zero critical findings" },
  validator: { status: "passed", summary: "Target passed" },
};

/** @param {any} value */
function clone(value) {
  return structuredClone(value);
}

/**
 * Deep clone of the valid payload with `mutate` applied.
 * @param {(value: any) => void} mutate
 */
function payload(mutate) {
  const value = clone(VALID_RESULTS);
  mutate(value);
  return value;
}

/** @param {string} text */
function sha256(text) {
  return createHash("sha256").update(text).digest("hex");
}

/**
 * Run the renderer against one artifact directory.
 * @param {string} dir
 */
function runRenderer(dir) {
  const result = Bun.spawnSync({
    cmd: [process.execPath, rendererPath, dir],
    env: { ...process.env, NO_COLOR: "1" },
    stdout: "pipe",
    stderr: "pipe",
  });
  return {
    exitCode: result.exitCode,
    stdout: new TextDecoder().decode(result.stdout),
    stderr: new TextDecoder().decode(result.stderr),
  };
}

/**
 * Artifact directory seeded with a payload and, optionally, a prior output pair.
 * @param {any} results
 * @param {{ withPriorOutputs?: boolean }} [options]
 */
function makeArtifactDir(results, options = {}) {
  const dir = mkdtempSync(join(tmpdir(), "seo-maker-render-validation-"));
  writeFileSync(join(dir, "results.json"), `${JSON.stringify(results, null, 2)}\n`);
  if (options.withPriorOutputs !== false) {
    writeFileSync(join(dir, "dashboard.html"), PRIOR_DASHBOARD, { mode: PRIOR_DASHBOARD_MODE });
    writeFileSync(join(dir, "results.js"), PRIOR_RESULTS_JS, { mode: PRIOR_RESULTS_JS_MODE });
  }
  return dir;
}

/**
 * File name to content and mode for the two rendered outputs.
 * @param {string} dir
 */
function snapshotOutputs(dir) {
  /** @type {Record<string, { content: string, mode: number } | null>} */
  const snapshot = {};
  for (const name of ["dashboard.html", "results.js"]) {
    const path = join(dir, name);
    snapshot[name] = statSync(path, { throwIfNoEntry: false })?.isFile()
      ? { content: readFileSync(path, "utf8"), mode: statSync(path).mode & 0o7777 }
      : null;
  }
  return snapshot;
}

/**
 * Prior output pair as a comparable value, plus leftover temp files.
 * @param {string} dir
 */
function priorState(dir) {
  return {
    outputs: snapshotOutputs(dir),
    temporaries: readdirSync(dir).filter((entry) => entry.endsWith(".tmp")).sort(),
  };
}

/**
 * Run one case in a fresh temp directory and clean up afterwards.
 * @param {any} results
 * @param {(dir: string, result: { exitCode: number, stdout: string, stderr: string }) => void} assertCase
 * @param {{ withPriorOutputs?: boolean }} [options]
 */
function withCase(results, assertCase, options) {
  const dir = makeArtifactDir(results, options);
  try {
    assertCase(dir, runRenderer(dir));
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

/** @param {string} text */
function parseResultsJs(text) {
  expect(text.startsWith(RESULTS_JS_PREFIX)).toBe(true);
  expect(text.endsWith(";\n")).toBe(true);
  return JSON.parse(text.slice(RESULTS_JS_PREFIX.length, -2));
}

// ------------------------------------------------------------------- happy

test("renders a structurally valid payload and records the artifact hashes", () => {
  withCase(VALID_RESULTS, (dir, result) => {
    expect(result.stderr).toBe("");
    expect(result.exitCode).toBe(0);
    expect(result.stdout).toBe(`렌더 완료: ${join(dir, "dashboard.html")}\n렌더 완료: ${join(dir, "results.js")}\n`);

    const outputs = snapshotOutputs(dir);
    expect(Object.keys(outputs).sort()).toEqual(["dashboard.html", "results.js"]);
    expect(outputs["dashboard.html"]).not.toBeNull();
    expect(outputs["results.js"]).not.toBeNull();

    // dashboard.html is the template copy; results.js carries the payload.
    const template = readFileSync(templatePath, "utf8");
    expect(sha256(/** @type {any} */ (outputs["dashboard.html"]).content)).toBe(sha256(template));
    expect(parseResultsJs(/** @type {any} */ (outputs["results.js"]).content)).toEqual(VALID_RESULTS);

    // A fresh pair is created with the process default mode.
    const defaultMode = 0o666 & ~process.umask();
    expect(/** @type {any} */ (outputs["dashboard.html"]).mode).toBe(defaultMode);
    expect(/** @type {any} */ (outputs["results.js"]).mode).toBe(defaultMode);

    console.log(`happy dashboard.html sha256=${sha256(/** @type {any} */ (outputs["dashboard.html"]).content)} mode=${/** @type {any} */ (outputs["dashboard.html"]).mode.toString(8)}`);
    console.log(`happy results.js    sha256=${sha256(/** @type {any} */ (outputs["results.js"]).content)} mode=${/** @type {any} */ (outputs["results.js"]).mode.toString(8)}`);
  }, { withPriorOutputs: false });
});

test("replaces a prior output pair for a valid payload and keeps its modes", () => {
  withCase(VALID_RESULTS, (dir, result) => {
    expect(result.exitCode).toBe(0);
    const outputs = snapshotOutputs(dir);
    expect(/** @type {any} */ (outputs["dashboard.html"]).content).not.toBe(PRIOR_DASHBOARD);
    expect(/** @type {any} */ (outputs["results.js"]).content).not.toBe(PRIOR_RESULTS_JS);
    expect(/** @type {any} */ (outputs["dashboard.html"]).mode).toBe(PRIOR_DASHBOARD_MODE);
    expect(/** @type {any} */ (outputs["results.js"]).mode).toBe(PRIOR_RESULTS_JS_MODE);
    expect(readdirSync(dir).filter((entry) => entry.endsWith(".tmp"))).toEqual([]);
  });
});

test("passes unknown extra keys through without a warning (K9)", () => {
  const extended = payload((value) => {
    value.custom_dimension = { nested: [1, 2, 3] };
    value.categories[0].extra_note = "vendor extension";
    value.findings[0].extra_tag = "triage-later";
  });
  withCase(extended, (dir, result) => {
    expect(result.stderr).toBe("");
    expect(result.exitCode).toBe(0);
    const rendered = parseResultsJs(/** @type {any} */ (snapshotOutputs(dir)["results.js"]).content);
    expect(rendered.custom_dimension).toEqual({ nested: [1, 2, 3] });
    expect(rendered.categories[0].extra_note).toBe("vendor extension");
    expect(rendered.findings[0].extra_tag).toBe("triage-later");
  });
});

// ---------------------------------------------------------------- failures

/**
 * Rejected payloads: each entry mutates the valid payload into one violation.
 * `reason` is the identifier the rejection must name, so a case cannot pass by
 * crashing for an unrelated reason.
 * @type {{ name: string, mutate: (value: any) => void, reason: string, payloadOverride?: any }[]}
 */
const REJECTED = [
  { name: "a null payload", mutate: (value) => value, reason: "객체", payloadOverride: null },
  { name: "an array payload", mutate: (value) => value, reason: "객체", payloadOverride: [] },
  { name: "a missing project_name", mutate: (value) => { delete value.project_name; }, reason: "project_name" },
  { name: "a missing status", mutate: (value) => { delete value.status; }, reason: "status" },
  { name: "a missing categories", mutate: (value) => { delete value.categories; }, reason: "categories" },
  { name: "a missing findings", mutate: (value) => { delete value.findings; }, reason: "findings" },
  { name: "a status outside the enumeration", mutate: (value) => { value.status = "wat"; }, reason: "status" },
  { name: "a category status outside the enumeration", mutate: (value) => { value.categories[0].status = "wat"; }, reason: "categories[0].status" },
  { name: "a category score above 100", mutate: (value) => { value.categories[0].score = 120; }, reason: "categories[0].score" },
  { name: "a category score below 0", mutate: (value) => { value.categories[1].score = -1; }, reason: "categories[1].score" },
  { name: "a category score that is neither a number nor null", mutate: (value) => { value.categories[2].score = "68"; }, reason: "categories[2].score" },
  { name: "a non-array categories", mutate: (value) => { value.categories = {}; }, reason: "categories" },
  { name: "a severity outside the enumeration", mutate: (value) => { value.findings[0].severity = "wat"; }, reason: "findings[0].severity" },
  { name: "a missing severity", mutate: (value) => { delete value.findings[1].severity; }, reason: "findings[1].severity" },
  { name: "an evidence_grade outside the enumeration", mutate: (value) => { value.findings[0].evidence_grade = "vibes"; }, reason: "findings[0].evidence_grade" },
  { name: "a source_tier outside the enumeration", mutate: (value) => { value.findings[1].source_tier = "blog-post"; }, reason: "findings[1].source_tier" },
  { name: "an overall_grade outside the grade table", mutate: (value) => { value.overall_grade = "B+"; }, reason: "overall_grade" },
  { name: "a score_history entry without evaluator_version", mutate: (value) => { delete value.score_history[1].evaluator_version; }, reason: "score_history[1].evaluator_version" },
  { name: "an empty evaluator_version", mutate: (value) => { value.score_history[1].evaluator_version = "  "; }, reason: "score_history[1].evaluator_version" },
  { name: "a weight change without a reset event", mutate: (value) => { value.score_history[1].weights = [25, 20, 15, 10, 10, 10, 10]; }, reason: "score_history[1]" },
  { name: "an evaluator change without a reset event", mutate: (value) => { value.score_history[1].evaluator_version = "seo-maker-evaluator/2"; }, reason: "score_history[1]" },
  { name: "a best_run pointing at a discarded iteration", mutate: (value) => { value.score_history[1].decision = "discarded"; }, reason: "best_run" },
  { name: "a best_run below the highest kept score", mutate: (value) => { value.score_history.push({ iteration: 2, score: 85, grade: "B", decision: "kept", evidence: "Later re-audit", evaluator_version: "seo-maker-evaluator/1", weights: CANONICAL_WEIGHTS }); }, reason: "best_run" },
  { name: "a best_run iteration missing from score_history", mutate: (value) => { value.best_run.iteration = 9; }, reason: "best_run.iteration" },
  { name: "a best_run without score_history", mutate: (value) => { delete value.score_history; }, reason: "score_history" },
];

for (const testCase of REJECTED) {
  test(`rejects ${testCase.name} and preserves the prior outputs`, () => {
    const results = "payloadOverride" in testCase ? testCase.payloadOverride : payload(testCase.mutate);
    withCase(results, (dir, result) => {
      expect(result.exitCode).toBe(1);
      expect(result.stdout).toBe("");
      expect(result.stderr).not.toBe("");
      // Rejected for the named reason, not by an unrelated crash.
      expect(result.stderr).toContain(testCase.reason);
      expect(result.stderr).not.toContain("    at ");

      expect(priorState(dir)).toEqual({
        outputs: {
          "dashboard.html": { content: PRIOR_DASHBOARD, mode: PRIOR_DASHBOARD_MODE },
          "results.js": { content: PRIOR_RESULTS_JS, mode: PRIOR_RESULTS_JS_MODE },
        },
        temporaries: [],
      });
      expect(JSON.parse(readFileSync(join(dir, "results.json"), "utf8"))).toEqual(results);
    });
  });
}

test("rejects a malformed payload without creating outputs", () => {
  const dir = mkdtempSync(join(tmpdir(), "seo-maker-render-validation-"));
  try {
    writeFileSync(join(dir, "results.json"), "{broken");
    const result = runRenderer(dir);
    expect(result.exitCode).toBe(1);
    expect(result.stderr).toContain("JSON");
    expect(readdirSync(dir).sort()).toEqual(["results.json"]);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
});

test("a reset event makes a changed evaluator definition acceptable", () => {
  const results = payload((value) => {
    value.score_history.push({
      iteration: 2,
      score: 80,
      grade: "B",
      decision: "reset",
      evidence: "Weights changed, new baseline started",
      evaluator_version: "seo-maker-evaluator/2",
      weights: [25, 20, 15, 10, 10, 10, 10],
    });
  });
  withCase(results, (_dir, result) => {
    expect(result.stderr).toBe("");
    expect(result.exitCode).toBe(0);
  });
});

test("a null category score stays valid", () => {
  const results = payload((value) => {
    value.categories[0].score = null;
  });
  withCase(results, (_dir, result) => {
    expect(result.stderr).toBe("");
    expect(result.exitCode).toBe(0);
  });
});
