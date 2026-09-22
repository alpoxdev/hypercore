#!/usr/bin/env bun
// @ts-check
/**
 * seo-maker dashboard contract (plan todo 5).
 *
 * The dashboard renders an untrusted results payload, so it must treat every
 * external string as text, keep its severity counters consistent with the total,
 * and isolate chart failures from the rest of the page.
 *
 * Two layers:
 *   1. A deterministic source gate that needs no browser: every unwrapped
 *      interpolation in an HTML or class sink must use only allow-listed
 *      identifiers, and every innerHTML assignment must resolve to a literal or
 *      to a fragment local whose own declarations are literals.
 *   2. Bun.WebView scenarios that drive the real template over file://, including
 *      a rendered-attribute scan that an element-only check would miss.
 *
 * The template under test is the shipped asset unless SEO_MAKER_DASHBOARD_TEMPLATE
 * names another path (the negative control uses that to point at a mutated temp
 * copy). Every scenario copies the template into a fresh temp dir first, so no
 * repository file is ever written to.
 */
import { expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const templatePath = process.env.SEO_MAKER_DASHBOARD_TEMPLATE
  ? resolve(process.env.SEO_MAKER_DASHBOARD_TEMPLATE)
  : join(root, "skills/seo-maker/assets/dashboard-template.html");
const templateSource = readFileSync(templatePath, "utf8");
const hasWebView = typeof Bun.WebView === "function";

const INJECTION = "<b id=proof-marker>x</b>";
const HOSTILE_STATUS = 'complete" onmouseover="window.__statusInjected=1';
const HOSTILE_GRADE = 'B" onmouseover="window.__gradeInjected=1';
const HOSTILE_SEVERITY = 'wat" onmouseover="window.__sevInjected=1';

// --------------------------------------------------------------- source gate

/** Sanitizers whose call may appear unwrapped inside an HTML or class sink. */
const SANITIZERS = ["escapeHtml", "sevClass", "statusClass", "gradeClass"];
/** Locals allowed to carry a pre-built HTML fragment into a sink. */
const FRAGMENT_LOCALS = ["rows", "best"];
/**
 * The only identifiers that may appear unwrapped in a sink expression. This is an
 * allow-list on purpose: a deny-list of payload names is defeated by aliasing
 * (`const alias = bestRun.reason` then `${alias}` in a title attribute).
 */
const SAFE_IDENTIFIERS = new Set([
  ...SANITIZERS, ...FRAGMENT_LOCALS,
  "i", "Number", "String", "Object", "Array", "Date", "Math", "JSON",
]);

/**
 * Skip a quoted string literal starting at `i`.
 * @param {string} body
 * @param {number} i index of the opening quote
 */
function skipString(body, i) {
  const quote = body[i];
  i += 1;
  while (i < body.length) {
    if (body[i] === "\\") { i += 2; continue; }
    if (body[i] === quote) return i + 1;
    i += 1;
  }
  throw new Error("unterminated string literal in the inline script");
}

/**
 * Skip a balanced `{...}` run, collecting template literals it contains.
 * @param {string} body
 * @param {number} i index of "{"
 * @param {any[]} found
 */
function matchBrace(body, i, found) {
  let depth = 0;
  while (i < body.length) {
    const ch = body[i];
    if (ch === '"' || ch === "'") { i = skipString(body, i); continue; }
    if (ch === "`") { i = readTemplate(body, i, found); continue; }
    if (ch === "{") depth += 1;
    else if (ch === "}") { depth -= 1; if (depth === 0) return i + 1; }
    i += 1;
  }
  throw new Error("unbalanced ${...} in the inline script");
}

/**
 * Read one template literal, pushing it and its nested literals into `found`.
 * @param {string} body
 * @param {number} i index of the opening backtick
 * @param {any[]} found
 */
function readTemplate(body, i, found) {
  const start = i;
  i += 1;
  let text = "";
  /** @type {string[]} */
  const expressions = [];
  while (i < body.length) {
    const ch = body[i];
    if (ch === "\\") { text += body.slice(i, i + 2); i += 2; continue; }
    if (ch === "`") {
      found.push({ start, text, expressions });
      return i + 1;
    }
    if (ch === "$" && body[i + 1] === "{") {
      const close = matchBrace(body, i + 1, found);
      expressions.push(body.slice(i + 2, close - 1));
      i = close;
      continue;
    }
    text += ch;
    i += 1;
  }
  throw new Error("unterminated template literal in the inline script");
}

/**
 * Collect every template literal in the script, nested ones included.
 * Regex literals containing a quote or backtick would defeat this scanner; the
 * template has none, and the gate's own non-vacuity assertion fails loudly if
 * the scan stops seeing sinks.
 * @param {string} body
 * @returns {any[]}
 */
function collectTemplates(body) {
  /** @type {any[]} */
  const found = [];
  let i = 0;
  while (i < body.length) {
    const ch = body[i];
    if (ch === '"' || ch === "'") { i = skipString(body, i); continue; }
    if (ch === "`") { i = readTemplate(body, i, found); continue; }
    if (ch === "/" && body[i + 1] === "/") {
      const newline = body.indexOf("\n", i);
      i = newline < 0 ? body.length : newline + 1;
      continue;
    }
    if (ch === "/" && body[i + 1] === "*") {
      const close = body.indexOf("*/", i);
      i = close < 0 ? body.length : close + 2;
      continue;
    }
    i += 1;
  }
  return found;
}

/**
 * The single inline <script> body, plus its offset inside the document.
 * @param {string} html
 */
function inlineScript(html) {
  const matches = [...html.matchAll(/<script(?![^>]*\bsrc=)[^>]*>([\s\S]*?)<\/script>/g)];
  if (matches.length !== 1) {
    throw new Error(`expected exactly one inline <script>, found ${matches.length}`);
  }
  const match = matches[0];
  const offset = (match.index ?? 0) + match[0].indexOf(">") + 1;
  return { body: match[1], offset };
}

/**
 * A literal is a sink when it builds markup or is assigned to .className.
 * @param {string} body
 * @param {any} literal
 */
function isSink(body, literal) {
  if (literal.text.includes("<")) return true;
  return /\.className\s*=\s*$/.test(body.slice(Math.max(0, literal.start - 40), literal.start));
}

/**
 * Text of the statement starting at `i`, up to its terminating ";" at depth 0.
 * @param {string} body
 * @param {number} i
 */
function statementText(body, i) {
  const start = i;
  let depth = 0;
  while (i < body.length) {
    const ch = body[i];
    if (ch === '"' || ch === "'") { i = skipString(body, i); continue; }
    if (ch === "`") { i = readTemplate(body, i, []); continue; }
    if (ch === "(" || ch === "[" || ch === "{") depth += 1;
    else if (ch === ")" || ch === "]" || ch === "}") {
      if (depth === 0) return body.slice(start, i);
      depth -= 1;
    } else if (ch === ";" && depth === 0) return body.slice(start, i);
    i += 1;
  }
  return body.slice(start);
}

/**
 * A fragment local is trusted only when EVERY declaration of that name is built
 * from a template literal or a .join("") chain — never assigned a bare value.
 * @param {string} body
 */
function verifiedFragments(body) {
  const verified = new Set();
  for (const name of FRAGMENT_LOCALS) {
    const declarations = [...body.matchAll(new RegExp(`(?:const|let|var)\\s+${name}\\s*=\\s*`, "g"))];
    if (!declarations.length) continue;
    const allSafe = declarations.every((match) => {
      const text = statementText(body, (match.index ?? 0) + match[0].length).trim();
      return text.includes("`") || /\.join\(""\)$/.test(text);
    });
    if (allSafe) verified.add(name);
  }
  return verified;
}

/**
 * Every innerHTML assignment must resolve to a literal or a verified fragment.
 * @param {string} body
 * @param {Set<string>} fragments
 */
function innerHtmlViolations(body, fragments) {
  /** @type {any[]} */
  const violations = [];
  /** @param {string} rule @param {string} expression */
  const record = (rule, expression) => violations.push({
    rule,
    sink: "innerHTML",
    expression: expression.trim().replace(/\s+/g, " ").slice(0, 80),
  });
  for (const match of body.matchAll(/\.innerHTML\s*(\+=|=)\s*/g)) {
    const start = (match.index ?? 0) + match[0].length;
    const ch = body[start];
    if (ch === "`" || ch === '"' || ch === "'") {
      const end = ch === "`" ? readTemplate(body, start, []) : skipString(body, start);
      const next = (body.slice(end).match(/^\s*(.)/) ?? [])[1];
      if (next !== ";") record("innerHTML-concatenation", body.slice(start, Math.min(end + 60, body.length)));
      continue;
    }
    const statement = statementText(body, start).trim();
    if (fragments.has(statement)) continue;
    record("innerHTML-unverified", statement);
  }
  return violations;
}

/**
 * Unescaped or aliased external-data interpolations reaching an HTML or class sink.
 * @param {string} body
 */
function sinkViolations(body) {
  const fragments = verifiedFragments(body);
  /** @type {any[]} */
  const violations = [];
  for (const literal of collectTemplates(body)) {
    if (!isSink(body, literal)) continue;
    for (const expression of literal.expressions) {
      const code = expression.replace(/"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'/g, '""').trim();
      if (SANITIZERS.some((name) => code.startsWith(`${name}(`))) continue;
      const unknown = [...code.matchAll(/(?<![.\w$])([A-Za-z_$][\w$]*)/g)]
        .map((match) => match[1])
        .filter((name) => !SAFE_IDENTIFIERS.has(name))
        .filter((name) => !(FRAGMENT_LOCALS.includes(name) && fragments.has(name)));
      if (unknown.length) {
        violations.push({
          rule: "unescaped-interpolation",
          sink: literal.text.trim().replace(/\s+/g, " ").slice(0, 60),
          expression: `${expression.trim().replace(/\s+/g, " ").slice(0, 70)} [unknown: ${[...new Set(unknown)].join(", ")}]`,
        });
      }
    }
  }
  return [...violations, ...innerHtmlViolations(body, fragments)];
}

test("source gate: no unescaped interpolation reaches an HTML or class sink", () => {
  const { body } = inlineScript(templateSource);
  const literals = collectTemplates(body);
  const sinks = literals.filter((literal) => isSink(body, literal));
  const checked = sinks.flatMap((literal) => literal.expressions);

  // Non-vacuity: a scanner that stopped seeing sinks must not pass silently.
  expect(literals.length).toBeGreaterThanOrEqual(10);
  expect(sinks.length).toBeGreaterThanOrEqual(10);
  expect(checked.length).toBeGreaterThanOrEqual(30);

  expect(sinkViolations(body)).toEqual([]);
});

// ------------------------------------------------------------------ fixtures

/**
 * Copy the template into a fresh temp dir, plus a results.js fixture.
 * @param {{ results?: any, withResults?: boolean, dropChartScript?: boolean }} options
 */
function makeFixture(options) {
  const dir = mkdtempSync(join(tmpdir(), "seo-maker-dashboard-"));
  let html = templateSource;
  if (options.dropChartScript) {
    const stripped = html.replace(/\s*<script src="[^"]*chart\.js"><\/script>/, "");
    if (stripped === html) {
      throw new Error("chart.js <script src> not found; cannot simulate a missing Chart global");
    }
    html = stripped;
  }
  writeFileSync(join(dir, "dashboard-template.html"), html);
  if (options.withResults !== false) {
    writeFileSync(join(dir, "results.js"), `window.__SEO_RESULTS__ = ${JSON.stringify(options.results)};\n`);
  }
  return dir;
}

/**
 * @param {any} options
 * @param {(dir: string) => Promise<any>} run
 */
async function withFixture(options, run) {
  const dir = makeFixture(options);
  try {
    return await run(dir);
  } finally {
    rmSync(dir, { recursive: true, force: true });
  }
}

/**
 * @param {string} dir
 * @param {(view: any) => Promise<any>} run
 */
async function withPage(dir, run) {
  const view = new Bun.WebView({ width: 1000, height: 800 });
  try {
    await view.navigate(`file://${join(dir, "dashboard-template.html")}`);
    return await run(view);
  } finally {
    view.close();
  }
}

/**
 * Poll a page expression until it is truthy. Bounded, never a fixed sleep.
 * @param {any} view
 * @param {string} expression
 * @param {string} [label]
 */
async function waitFor(view, expression, label = expression) {
  const deadline = Date.now() + 10_000;
  let last;
  while (Date.now() < deadline) {
    last = await view.evaluate(expression);
    if (last) return last;
  }
  throw new Error(`timed out waiting for ${label}; last value: ${JSON.stringify(last)}`);
}

// Readiness: the subtitle is replaced on the first line of applyData, which runs
// synchronously, so a non-loading subtitle means the whole render pass settled.
// A rendered page must not carry the payload in any attribute, and must not have
// grown an event-handler attribute the template never declares.
const attributeLeaks = `(() => {
  const leaks = [];
  for (const el of document.querySelectorAll("*")) {
    for (const attr of el.attributes) {
      if (attr.name.startsWith("on")) leaks.push(el.tagName + "[" + attr.name + "]");
      else if (attr.value.includes("<b id=proof-marker>")) leaks.push(el.tagName + "[" + attr.name + "]=payload");
    }
  }
  return leaks;
})()`;

const readCounters = `(() => {
  const read = (id) => document.getElementById(id);
  if (read("subtitle").textContent.includes("불러오는 중")) return null;
  return {
    total: read("cnt-total").textContent,
    critical: read("cnt-critical").textContent,
    warning: read("cnt-warning").textContent,
    info: read("cnt-info").textContent,
    other: read("cnt-other") ? read("cnt-other").textContent : null,
    otherHidden: read("cnt-other-wrap") ? read("cnt-other-wrap").hidden : null,
    findingsText: read("findings-wrap").textContent,
    categoryText: read("category-grid").textContent,
    measurementText: read("measurement-wrap").textContent,
    platformText: read("platform-wrap").textContent,
    aiText: read("ai-experiments-wrap").textContent,
    historyText: read("history-wrap").textContent,
    quickWinsText: read("quickwins-wrap").textContent,
    actionsText: read("actions-wrap").textContent,
    pillClassName: read("status-pill").className,
    gradeClassName: read("overall-grade").className,
    sevClassNames: [...document.querySelectorAll("#findings-wrap .sev")].map((el) => el.className),
    marker: document.getElementById("proof-marker") !== null,
    attributeLeaks: ${attributeLeaks},
    injectedGlobals: [window.__statusInjected, window.__gradeInjected, window.__sevInjected].filter(Boolean).length,
    bodyText: document.body.textContent
  };
})()`;

const INJECTION_RESULTS = {
  project_name: INJECTION,
  scope: INJECTION,
  date: INJECTION,
  status: HOSTILE_STATUS,
  overall_grade: HOSTILE_GRADE,
  categories: [{ name: INJECTION, score: 80, status: "measured" }],
  findings: [{
    id: 1,
    severity: "info",
    finding: INJECTION,
    category: INJECTION,
    location: INJECTION,
    evidence_grade: INJECTION,
    confidence: INJECTION,
    measurement_method: INJECTION,
    source_tier: INJECTION,
    recommendation: INJECTION,
  }],
  measurement_methods: { [INJECTION]: { status: INJECTION, evidence_grade: INJECTION, confidence: INJECTION, reason: INJECTION } },
  platform_policy: { [INJECTION]: { status: INJECTION, purpose: INJECTION, evidence_grade: INJECTION, confidence: INJECTION } },
  query_fanout: { status: INJECTION, queries: [INJECTION], confidence: INJECTION, missing_topics: [INJECTION] },
  citation_probe: { status: INJECTION, sample_size: 3, confidence: INJECTION, engines: [INJECTION] },
  score_history: [{ iteration: 1, score: 70, grade: INJECTION, decision: INJECTION, evidence: INJECTION }],
  best_run: { iteration: 1, score: 70, reason: INJECTION },
  quick_wins: [{ action: INJECTION, impact: INJECTION, effort: INJECTION }],
  actions: [{ priority: 1, category: INJECTION, action: INJECTION, impact: INJECTION, effort: INJECTION }],
};

test.skipIf(!hasWebView)("external strings render as text in every panel (requires Bun.WebView)", async () => {
  await withFixture({ results: INJECTION_RESULTS }, (dir) => withPage(dir, async (view) => {
    const page = await waitFor(view, readCounters, "the render pass to settle");

    // No injected element may exist anywhere in the document, and no attribute
    // may carry the payload (an element-only check misses attribute vectors).
    expect(page.marker).toBe(false);
    expect(page.attributeLeaks).toEqual([]);
    expect(page.injectedGlobals).toBe(0);

    // The payload survives as visible text in every data panel.
    for (const key of ["findingsText", "categoryText", "measurementText", "platformText", "aiText", "historyText", "quickWinsText", "actionsText", "bodyText"]) {
      expect(page[key]).toContain(INJECTION);
    }

    // class sinks stay inside their allow-lists.
    expect(page.pillClassName.split(/\s+/).filter(Boolean)).toEqual(["status", "idle"]);
    expect(page.gradeClassName.split(/\s+/).filter(Boolean)).toEqual(["grade"]);
    expect(page.sevClassNames).toEqual(["sev info"]);

    // valid severities keep the other bucket hidden and the parts summing to the total.
    expect(page.otherHidden).toBe(true);
    const parts = [page.critical, page.warning, page.info, page.other].map(Number);
    expect(parts.reduce((sum, value) => sum + value, 0)).toBe(Number(page.total));
  }));
});

test.skipIf(!hasWebView)("severity outside the enumeration keeps counters consistent (requires Bun.WebView)", async () => {
  const results = {
    project_name: "severity probe",
    status: "complete",
    overall_grade: "C",
    categories: [],
    findings: [
      { id: 1, severity: "critical", finding: "one" },
      { id: 2, severity: "critical", finding: "two" },
      { id: 3, severity: HOSTILE_SEVERITY, finding: "three" },
    ],
    measurement_methods: {},
  };
  await withFixture({ results }, (dir) => withPage(dir, async (view) => {
    const page = await waitFor(view, readCounters, "the render pass to settle");

    expect(page.total).toBe("3");
    expect(page.critical).toBe("2");
    expect(page.other).toBe("1");
    expect(page.otherHidden).toBe(false);
    const parts = [page.critical, page.warning, page.info, page.other].map(Number);
    expect(parts.reduce((sum, value) => sum + value, 0)).toBe(Number(page.total));
    expect(page.sevClassNames).toEqual(["sev critical", "sev critical", "sev unknown"]);
    expect(page.marker).toBe(false);
    expect(page.attributeLeaks).toEqual([]);
  }));
});

test.skipIf(!hasWebView)("renders the non-chart panels when Chart is unavailable (requires Bun.WebView)", async () => {
  const results = {
    project_name: "chart probe",
    status: "complete",
    overall_grade: "A",
    categories: [{ name: "RENDER-ME", score: 90, status: "measured" }],
    findings: [{ id: 1, severity: "info", finding: "RENDER-ME" }],
    measurement_methods: { "RENDER-ME": { status: "completed" } },
  };
  await withFixture({ results, dropChartScript: true }, (dir) => withPage(dir, async (view) => {
    const page = await waitFor(view, readCounters, "the render pass to settle");

    expect(await view.evaluate("typeof Chart")).toBe("undefined");
    expect(page.findingsText).toContain("RENDER-ME");
    expect(page.measurementText).toContain("RENDER-ME");
    expect(page.categoryText).toContain("RENDER-ME");
    expect(page.actionsText.length).toBeGreaterThan(0);
  }));
});

test.skipIf(!hasWebView)("file:// reports a missing results.js in the subtitle (requires Bun.WebView)", async () => {
  await withFixture({ withResults: false }, (dir) => withPage(dir, async (view) => {
    const subtitle = await waitFor(
      view,
      `(() => { const t = document.getElementById("subtitle").textContent; return t.includes("결과를 불러오지 못했습니다") ? t : null; })()`,
      "the subtitle to report the load failure",
    );
    expect(subtitle).toContain("결과를 불러오지 못했습니다");
    // The page survives the failure and keeps its empty state.
    expect(await view.evaluate('document.getElementById("findings-wrap").textContent')).toContain("아직 기록된 발견사항이 없습니다");
  }));
});

// ------------------------------------------------- narrow viewport (plan todo 15)

/** A payload whose 10 findings columns are wide enough to overflow a phone. */
const NARROW_FINDINGS = {
  project_name: "narrow viewport probe",
  scope: "https://example.test 전체 사이트",
  date: "2026-09-21",
  status: "complete",
  overall_grade: "C",
  categories: [{ name: "Technical SEO", score: 88, status: "measured" }],
  findings: Array.from({ length: 6 }, (_, index) => ({
    id: index + 1,
    severity: "warning",
    category: "Technical SEO",
    finding: `canonical 불일치 ${index + 1}`,
    location: "/blog/2026/seo-audit-guide",
    evidence_grade: "observed",
    confidence: "high",
    measurement_method: "headless fetch + DOM parse",
    source_tier: "official-doc",
    recommendation: "canonical과 og:url이 서로 다른 값을 가리켜 검색엔진이 중복 URL로 해석할 여지가 있다",
  })),
  measurement_methods: {},
  quick_wins: [],
  actions: [],
};

// The findings wrapper must scroll horizontally rather than widen the page, and
// its last column must stay reachable instead of being clipped away.
const NARROW_PROBE = `(() => {
  const de = document.documentElement;
  const wrap = document.getElementById("findings-wrap");
  const table = wrap.querySelector("table");
  const lastHeader = table.querySelector("thead th:last-child");
  const wrapBox = wrap.getBoundingClientRect();
  wrap.scrollLeft = wrap.scrollWidth;
  const lastHeaderRight = Math.round(lastHeader.getBoundingClientRect().right);
  return {
    clientWidth: de.clientWidth,
    documentScrollWidth: de.scrollWidth,
    findingsRows: wrap.querySelectorAll("tbody tr").length,
    findingsColumns: wrap.querySelectorAll("thead th").length,
    findingsCells: wrap.querySelectorAll("tbody td").length,
    wrapScrollWidth: wrap.scrollWidth,
    wrapClientWidth: wrap.clientWidth,
    lastHeaderRight,
    wrapRight: Math.round(wrapBox.right),
    lastColumnReachable: lastHeaderRight <= wrapBox.right + 1 && lastHeaderRight > wrapBox.left
  };
})()`;

/**
 * Render the fixture at one viewport width and read the overflow probe.
 * @param {string} dir
 * @param {number} width
 */
async function readPageAt(dir, width) {
  const view = new Bun.WebView({ width, height: 1000 });
  try {
    await view.navigate(`file://${join(dir, "dashboard-template.html")}`);
    await waitFor(view, readCounters, "the render pass to settle");
    return await view.evaluate(NARROW_PROBE);
  } finally {
    view.close();
  }
}

test.skipIf(!hasWebView)("a narrow viewport keeps the wide findings table inside its panel (requires Bun.WebView)", async () => {
  await withFixture({ results: NARROW_FINDINGS }, async (dir) => {
    const narrow = await readPageAt(dir, 420);
    // The document must not scroll sideways, and no column or row may vanish.
    expect(narrow.clientWidth).toBe(420);
    expect(narrow.documentScrollWidth).toBeLessThanOrEqual(421);
    expect(narrow.findingsRows).toBe(6);
    expect(narrow.findingsColumns).toBe(10);
    expect(narrow.findingsCells).toBe(60);
    expect(narrow.wrapScrollWidth).toBeGreaterThan(narrow.wrapClientWidth);
    expect(narrow.lastColumnReachable).toBe(true);

    const desktop = await readPageAt(dir, 1280);
    expect(desktop.documentScrollWidth).toBe(desktop.clientWidth);
    expect(desktop.findingsRows).toBe(6);
    expect(desktop.findingsColumns).toBe(10);
  });
});
