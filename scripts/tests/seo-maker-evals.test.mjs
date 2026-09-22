#!/usr/bin/env bun
// @ts-check
/**
 * Behavioral eval runner for the seo-maker corpus.
 *
 * Every case carries a machine-readable `probe` that names a real seam in this
 * repository, and the runner computes an `actual` value by calling that seam and
 * asserts it equals the case's expected verdict. A format check is not an
 * evaluation, so the corpus checks below stay, but they never stand in for the
 * probe run.
 *
 * Three seams are used:
 *   1. `render-gate` — `skills/seo-maker/scripts/render-dashboard.mjs` run as a
 *      subprocess against a temp dir holding the case's payload. The actual value
 *      is the exit code plus the artifacts it wrote: `rendered:<category
 *      statuses>:<finding count>` read back out of the `results.js` it produced,
 *      or `rejected:<offending results.json path>` parsed out of its stderr.
 *   2. `render-page` — the shipped `assets/dashboard-template.html` rendered over
 *      `file://` in Bun.WebView, observed for external-string escaping and for
 *      the chart-absent guard.
 *   3. `doc-query` — the shared parser `scripts/tests/seo-maker-doc-contracts.mjs`
 *      run over the real rule documents, so a translated checklist that drops a
 *      target condition or admits a third-party ranking claim is reported.
 *
 * Cases with no seam any artifact in this repository can decide are marked
 * `probe.kind === "none"`, and the runner asserts that exact set rather than
 * letting an unevaluated case look evaluated.
 *
 * `SEO_MAKER_EVAL_DIR` points the corpus read at a directory holding both JSONL
 * files, which is how the negative control below and an external flip check
 * evaluate a `mkdtemp` copy instead of mutating the repository. Documents and
 * scripts always come from the repository itself.
 */
import { describe, expect, test } from "bun:test";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  conditionalItemsForTarget,
  heuristicItemIndices,
  rankingAlgorithmIds,
  readDoc,
} from "./seo-maker-doc-contracts.mjs";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const EVAL_DIR = "skills/seo-maker/assets/evals";
const EN_NAME = "seo-maker-cases.jsonl";
const KO_NAME = "seo-maker-cases.ko.jsonl";
const corpusDir = process.env.SEO_MAKER_EVAL_DIR ? resolve(process.env.SEO_MAKER_EVAL_DIR) : join(root, EVAL_DIR);
const RENDERER = join(root, "skills/seo-maker/scripts/render-dashboard.mjs");
const TEMPLATE = join(root, "skills/seo-maker/assets/dashboard-template.html");
const RESULTS_JS_PREFIX = "window.__SEO_RESULTS__ = ";

/** Literal markup carried by the escaping case's payload. */
const MARKUP_MARKER = "proof-marker";
/** Literal carried by every panel of the chart-absent case's payload. */
const PANEL_MARKER = "panel-marker";

/** Cases no artifact in this repository can decide; the runner asserts this exact set. */
const NO_SEAM_IDS = [
  "seo-guarantee-language-negative",
  "seo-non-seo-negative",
  "seo-policy-bulk-generation",
  "seo-policy-expired-domain",
];

const REQUIRED_CATEGORIES = ["positive", "negative", "boundary", "adversarial"];
const REQUIRED_METRICS = [
  "evidence-discipline",
  "unknown-handling",
  "no-guarantee-language",
  "policy-accuracy",
  "scope-fidelity",
  "target-conditionality",
  "output-escaping",
  "dashboard-resilience",
  "tool-fallback",
  "triggerability",
];

/** The axes the plan requires the corpus to cover, mapped to a case identifier prefix. */
const REQUIRED_AXES = {
  "normal audit": "seo-audit-positive",
  "missing evidence grade": "seo-missing-evidence-grade",
  "all channels unknown": "seo-all-unknown",
  "not-applicable mix": "seo-not-applicable-mix",
  "tool-absent fallback": "seo-tool-absent-fallback",
  "chart not loaded": "seo-chart-not-loaded",
  "external markup in a finding": "seo-finding-with-markup",
  "bulk generation policy": "seo-policy-bulk-generation",
  "expired domain policy": "seo-policy-expired-domain",
  "unverified policy not stated as fact": "seo-unverified-policy-negative",
  "no rich-result, index or citation guarantee": "seo-guarantee-language-negative",
  "commerce-only stays conditional": "seo-commerce-only-negative",
  "Naver and Bing stay conditional": "seo-platform-conditional-negative",
  "non-SEO request does not trigger": "seo-non-seo-negative",
};

/**
 * @param {string} dir directory holding the corpus
 * @param {string} name corpus file name
 * @returns {any[]} parsed cases
 */
function readCorpus(dir, name) {
  const text = readFileSync(join(dir, name), "utf8").trim();
  return text.split("\n").map((line) => JSON.parse(line));
}

/** @param {string} id @returns {string} the identifier without its language suffix */
function stripLanguage(id) {
  return id.replace(/-en$/, "").replace(/-ko$/, "");
}

/** @param {any} value @returns {string} a stable rendering for a mismatch line (object keys canonicalized) */
function show(value) {
  return JSON.stringify(canonical(value) ?? null);
}

/**
 * Recursively sort object keys so a comparison never depends on key order.
 * @param {any} value
 * @returns {any}
 */
function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === "object") {
    /** @type {Record<string, any>} */
    const sorted = {};
    for (const key of Object.keys(value).sort()) sorted[key] = canonical(value[key]);
    return sorted;
  }
  return value;
}

// ------------------------------------------------------------------- seams

/**
 * The results.json path the renderer's failure message names.
 * @param {string} stderr
 * @returns {string}
 */
function rejectedField(stderr) {
  const line = stderr.split("\n").map((entry) => entry.trim()).find((entry) => entry.startsWith("results.json ")) ?? "";
  const required = /^results\.json 필수 키가 없습니다: (.+)$/.exec(line);
  if (required) return `required(${required[1]})`;
  const path = /^results\.json ([^\s]+)/.exec(line);
  return path ? path[1] : "unknown";
}

/**
 * Run the shipped renderer against a temp dir seeded with one payload.
 * @param {any} payload results.json contents
 * @returns {string} actual verdict
 */
function renderGate(payload) {
  const dir = mkdtempSync(join(tmpdir(), "seo-maker-eval-render-"));
  try {
    writeFileSync(join(dir, "results.json"), `${JSON.stringify(payload, null, 2)}\n`);
    const run = Bun.spawnSync({
      cmd: [process.execPath, RENDERER, dir],
      env: { ...process.env, NO_COLOR: "1" },
      stdout: "pipe",
      stderr: "pipe",
    });
    const dashboard = existsSync(join(dir, "dashboard.html"));
    const resultsJs = existsSync(join(dir, "results.js"));
    if (run.exitCode !== 0) return `rejected:${rejectedField(new TextDecoder().decode(run.stderr))}`;
    if (!dashboard || !resultsJs) return `partial:exit0:dashboard=${dashboard}:resultsJs=${resultsJs}`;
    const written = JSON.parse(
      readFileSync(join(dir, "results.js"), "utf8").slice(RESULTS_JS_PREFIX.length).trim().replace(/;$/, ""),
    );
    const statuses = (written.categories ?? []).map((/** @type {any} */ category) => category.status).join(",");
    return `rendered:${statuses}:${(written.findings ?? []).length}`;
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

/** Readiness: the subtitle leaves its loading state only after the render pass settles. */
const READY = `(() => {
  const subtitle = document.getElementById("subtitle");
  return subtitle && !subtitle.textContent.includes("불러오는 중");
})()`;

/** Escaping observation: no element, no attribute leak, payload visible as text. */
const ESCAPING_OBSERVATION = `(() => {
  const leaks = [];
  for (const el of document.querySelectorAll("*")) {
    for (const attr of el.attributes) {
      if (attr.name.startsWith("on") || attr.value.includes("${MARKUP_MARKER}")) leaks.push(el.tagName + "[" + attr.name + "]");
    }
  }
  const text = document.getElementById("findings-wrap").textContent;
  return {
    markerElement: document.getElementById("${MARKUP_MARKER}") !== null,
    visibleText: text.includes("${MARKUP_MARKER}"),
    attributeLeaks: leaks.length
  };
})()`;

/** Chart-absent observation: the chart global is gone and every data panel still carries the payload. */
const CHART_OBSERVATION = `(() => {
  const carries = (id) => (document.getElementById(id).textContent.includes("${PANEL_MARKER}") ? "visible" : "missing");
  return {
    chartGlobal: typeof Chart,
    findings: carries("findings-wrap"),
    measurement: carries("measurement-wrap"),
    platform: carries("platform-wrap"),
    category: carries("category-grid")
  };
})()`;

/**
 * Render the shipped template over file:// with one payload and read an observation.
 * @param {any} probe probe descriptor
 * @returns {Promise<any>} actual verdict
 */
async function renderPage(probe) {
  if (typeof Bun.WebView !== "function") {
    // Fail loudly rather than skip: skipping would let the escaping and chart-absent
    // cases pass unevaluated, which is the exact defect this file was rewritten to
    // close. The message names the environment so the red suite is not misread as a
    // seo-maker defect.
    throw new Error("Bun.WebView is unavailable in this environment, so the render-page eval cases cannot be evaluated here. This is an environment limitation, not a seo-maker defect.");
  }
  const dir = mkdtempSync(join(tmpdir(), "seo-maker-eval-page-"));
  try {
    let html = readFileSync(TEMPLATE, "utf8");
    if (probe.dropChartScript) {
      const stripped = html.replace(/\s*<script src="[^"]*chart\.js"><\/script>/, "");
      if (stripped === html) throw new Error("chart.js <script src> not found; cannot simulate a missing Chart global");
      html = stripped;
    }
    writeFileSync(join(dir, "dashboard-template.html"), html);
    writeFileSync(join(dir, "results.js"), `${RESULTS_JS_PREFIX}${JSON.stringify(probe.payload)};\n`);

    const view = new Bun.WebView({ width: 1000, height: 800 });
    try {
      await view.navigate(`file://${join(dir, "dashboard-template.html")}`);
      await waitFor(view, READY, "the render pass to settle");
      return await view.evaluate(probe.observe === "escaping" ? ESCAPING_OBSERVATION : CHART_OBSERVATION);
    } finally {
      view.close();
    }
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

/**
 * Poll a page expression until it is truthy. Bounded, never a fixed sleep.
 * @param {any} view
 * @param {string} expression
 * @param {string} label
 */
async function waitFor(view, expression, label) {
  const deadline = Date.now() + 10_000;
  let last;
  while (Date.now() < deadline) {
    last = await view.evaluate(expression);
    if (last) return last;
  }
  throw new Error(`timed out waiting for ${label}; last value: ${JSON.stringify(last)}`);
}

/**
 * Compute the actual value of one probe by calling the real system.
 * @param {any} probe probe descriptor
 * @returns {Promise<any>} actual value
 */
async function computeActual(probe) {
  switch (probe.kind) {
    case "render-gate":
      return renderGate(probe.payload);
    case "render-page":
      return renderPage(probe);
    case "doc-query": {
      const doc = readDoc(probe.doc, root);
      switch (probe.query) {
        case "heuristicItemIndices":
          return heuristicItemIndices(doc);
        case "rankingAlgorithmIds":
          return rankingAlgorithmIds(doc);
        case "conditionalItemsForTarget": {
          /** @type {Record<string, (string | null)[]>} */
          const actual = {};
          for (const target of probe.targets) {
            actual[target] = conditionalItemsForTarget(doc, target).map((item) => item.id);
          }
          return actual;
        }
        default:
          throw new Error(`unknown doc-query: ${probe.query}`);
      }
    }
    default:
      throw new Error(`unknown probe kind: ${probe.kind}`);
  }
}

/**
 * Evaluate one case: compute the actual value and compare it with the expected verdict.
 * @param {any} entry corpus case
 * @returns {Promise<{id: string, kind: string, expected: any, actual: any, ok: boolean | null}>} result
 */
async function evaluateCase(entry) {
  const probe = entry.probe;
  if (probe.kind === "none") {
    return { id: entry.id, kind: "none", expected: null, actual: null, ok: null };
  }
  const actual = await computeActual(probe);
  return {
    id: entry.id,
    kind: probe.kind,
    expected: probe.expected,
    actual,
    ok: show(actual) === show(probe.expected),
  };
}

/**
 * Evaluate a whole corpus directory through the same logic the assertions use.
 * @param {string} dir directory holding both JSONL files
 * @returns {Promise<{results: any[], mismatches: any[], noneIds: string[], evaluatedIds: string[]}>} run
 */
async function evaluateCorpus(dir) {
  const entries = [...readCorpus(dir, EN_NAME), ...readCorpus(dir, KO_NAME)];
  /** @type {any[]} */
  const results = [];
  for (const entry of entries) results.push(await evaluateCase(entry));
  return {
    results,
    mismatches: results.filter((result) => result.ok === false),
    noneIds: results.filter((result) => result.kind === "none").map((result) => result.id),
    evaluatedIds: results.filter((result) => result.kind !== "none").map((result) => result.id),
  };
}

// ------------------------------------------------------- corpus structure

describe("seo-maker eval corpus", () => {
  const en = readCorpus(corpusDir, EN_NAME);
  const ko = readCorpus(corpusDir, KO_NAME);

  test("both language files parse and carry the same number of cases", () => {
    expect(en.length).toBeGreaterThanOrEqual(14);
    expect(ko.length).toBe(en.length);
  });

  test("every case has the required machine-readable fields", () => {
    for (const entry of [...en, ...ko]) {
      expect(typeof entry.id).toBe("string");
      expect(entry.id.length).toBeGreaterThan(0);
      expect(typeof entry.intent).toBe("string");
      expect(typeof entry.prompt).toBe("string");
      expect(typeof entry.shouldTrigger).toBe("boolean");
      expect(entry.context && typeof entry.context === "object").toBe(true);
      expect(Array.isArray(entry.expected.must)).toBe(true);
      expect(entry.expected.must.length).toBeGreaterThan(0);
      expect(Array.isArray(entry.expected.mustNot)).toBe(true);
      expect(entry.expected.mustNot.length).toBeGreaterThan(0);
      expect(Array.isArray(entry.metrics)).toBe(true);
      expect(entry.metrics.length).toBeGreaterThan(0);
      expect(REQUIRED_CATEGORIES).toContain(entry.category);
    }
  });

  test("every case names a probe the runner can execute", () => {
    const kinds = new Set(["render-gate", "render-page", "doc-query", "none"]);
    for (const entry of [...en, ...ko]) {
      const probe = entry.probe;
      expect(`${entry.id}: ${probe && typeof probe === "object"}`).toBe(`${entry.id}: true`);
      expect(kinds.has(probe.kind)).toBe(true);
      if (probe.kind === "none") {
        expect("expected" in probe).toBe(false);
        continue;
      }
      expect("expected" in probe).toBe(true);
      if (probe.kind === "render-gate" || probe.kind === "render-page") {
        expect(probe.payload && typeof probe.payload === "object").toBe(true);
        expect(probe.payload.findings).toBeDefined();
      }
      if (probe.kind === "render-page") {
        expect(["escaping", "chart-absent"]).toContain(probe.observe);
      }
      if (probe.kind === "doc-query") {
        expect(typeof probe.doc).toBe("string");
        expect(existsSync(join(root, probe.doc))).toBe(true);
        expect(["heuristicItemIndices", "rankingAlgorithmIds", "conditionalItemsForTarget"]).toContain(probe.query);
      }
    }
  });

  test("identifiers are unique inside each file", () => {
    for (const corpus of [en, ko]) {
      const ids = corpus.map((entry) => entry.id);
      expect(new Set(ids).size).toBe(ids.length);
    }
  });

  test("each file declares its own language", () => {
    expect(en.every((entry) => entry.language === "en")).toBe(true);
    expect(ko.every((entry) => entry.language === "ko")).toBe(true);
  });

  test("the English and Korean files cover the same axes in the same order", () => {
    expect(en.map((entry) => stripLanguage(entry.id))).toEqual(ko.map((entry) => stripLanguage(entry.id)));
  });

  test("every axis the plan names has a case in both languages", () => {
    const enIds = en.map((entry) => entry.id);
    const koIds = ko.map((entry) => entry.id);
    for (const [axis, prefix] of Object.entries(REQUIRED_AXES)) {
      expect(`${axis}: ${enIds.some((id) => id.startsWith(prefix))}`).toBe(`${axis}: true`);
      expect(`${axis}: ${koIds.some((id) => id.startsWith(prefix))}`).toBe(`${axis}: true`);
    }
  });

  test("every required metric appears somewhere in the corpus", () => {
    const metrics = new Set([...en, ...ko].flatMap((entry) => entry.metrics));
    for (const metric of REQUIRED_METRICS) expect(metrics.has(metric)).toBe(true);
  });

  test("each language has a case that triggers and a case that must not", () => {
    for (const corpus of [en, ko]) {
      expect(corpus.some((entry) => entry.shouldTrigger === true)).toBe(true);
      expect(corpus.some((entry) => entry.shouldTrigger === false)).toBe(true);
    }
  });

  test("the no-guarantee and target-conditional cases forbid the overclaim they guard", () => {
    const guarantees = [...en, ...ko].filter((entry) => entry.id.startsWith("seo-guarantee-language"));
    expect(guarantees.length).toBe(2);
    for (const entry of guarantees) {
      expect(entry.shouldTrigger).toBe(true);
      expect(entry.expected.mustNot.length).toBeGreaterThanOrEqual(2);
    }
    const conditional = [...en, ...ko].filter((entry) => entry.id.startsWith("seo-platform-conditional"));
    expect(conditional.length).toBe(2);
    for (const entry of conditional) {
      expect(entry.metrics).toContain("target-conditionality");
    }
  });

  test("the two languages carry the same expected-verdict distribution", () => {
    const verdictOf = (/** @type {any} */ entry) => show(entry.probe.expected);
    const enVerdicts = en.map(verdictOf);
    const koVerdicts = ko.map(verdictOf);
    // Same case order, so the distribution matches position by position ...
    expect(koVerdicts).toEqual(enVerdicts);
    // ... and as a multiset, which survives a reordering of either file.
    expect([...koVerdicts].sort()).toEqual([...enVerdicts].sort());
  });

  test("the corpus marks exactly the cases with no machine seam", () => {
    for (const corpus of [en, ko]) {
      const noneIds = corpus.filter((entry) => entry.probe.kind === "none").map((entry) => stripLanguage(entry.id));
      expect(noneIds.slice().sort()).toEqual(NO_SEAM_IDS.slice().sort());
    }
  });
});

// ------------------------------------------------------------ probe runner

describe("seo-maker eval runner", () => {
  test(
    "every machine-checked case matches an actual value computed from a real system call",
    async () => {
      const run = await evaluateCorpus(corpusDir);
      // Non-vacuity: 20 cases are machine-checked, 8 are marked seam-free, 28 total.
      expect(run.evaluatedIds.length).toBe(20);
      expect(run.noneIds.length).toBe(8);
      expect(run.results.length).toBe(28);
      expect(
        run.mismatches.map(
          (mismatch) => `${mismatch.id} (${mismatch.kind}): expected ${show(mismatch.expected)} actual ${show(mismatch.actual)}`,
        ),
      ).toEqual([]);
    },
    120_000,
  );

  test(
    "flipping one expected verdict in a temp corpus copy is reported as a mismatch",
    async () => {
      const flippedId = "seo-missing-evidence-grade-en";
      const dir = mkdtempSync(join(tmpdir(), "seo-maker-eval-flip-"));
      try {
        for (const name of [EN_NAME, KO_NAME]) writeFileSync(join(dir, name), readFileSync(join(corpusDir, name)));

        const lines = readCorpus(dir, EN_NAME);
        const target = lines.find((entry) => entry.id === flippedId);
        expect(target.probe.expected).toBe("rejected:findings[0].evidence_grade");
        target.probe.expected = "rendered:measured:1";
        writeFileSync(join(dir, EN_NAME), `${lines.map((entry) => JSON.stringify(entry)).join("\n")}\n`);

        const run = await evaluateCorpus(dir);
        expect(run.mismatches.length).toBeGreaterThanOrEqual(1);
        expect(run.mismatches.map((mismatch) => mismatch.id)).toContain(flippedId);
        const flipped = run.mismatches.find((mismatch) => mismatch.id === flippedId);
        expect(flipped.actual).toBe("rejected:findings[0].evidence_grade");
        expect(flipped.expected).toBe("rendered:measured:1");

        // The copy is the only thing that changed: the repository corpus is untouched.
        const repository = readCorpus(corpusDir, EN_NAME).find((entry) => entry.id === flippedId);
        expect(repository.probe.expected).toBe("rejected:findings[0].evidence_grade");
      } finally {
        rmSync(dir, { recursive: true, force: true });
      }
    },
    120_000,
  );
});
