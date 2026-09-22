#!/usr/bin/env bun
// @ts-check

/**
 * Score, status, flow, and optimization-history contract assertions for the
 * seo-maker artifact spec.
 *
 * The score contract is recomputed from the documents instead of trusted: the
 * weights are parsed out of the `<scoring>` block in `SKILL.md`, the category
 * example is parsed out of `artifact-spec.md`, and the weighted score and grade
 * are recalculated and compared with the grade the document prints.
 *
 * `SEO_MAKER_DOC_ROOT` points every contract read at a copied tree, which is how
 * the QA negative control reverts the documented grade without mutating the
 * repository. The mutation-based negative cases below copy one file into a
 * `mkdtemp` root through the shared parser and never touch the working tree.
 */
import { readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { expect, test } from "bun:test";

import { REPO_ROOT, parseDoc, readDoc, tempCopy } from "./seo-maker-doc-contracts.mjs";

export const ARTIFACT_SPEC_EN = "skills/seo-maker/references/artifact-spec.md";
export const ARTIFACT_SPEC_KO = "skills/seo-maker/references/artifact-spec.ko.md";
export const SKILL_EN = "skills/seo-maker/SKILL.md";

const RESULTS_SECTION = "`results.json`";
const FLOW_SECTION = "`flow.json`";

/** Document root for every contract read; the QA negative control overrides it. */
export const DOC_ROOT = process.env.SEO_MAKER_DOC_ROOT ?? REPO_ROOT;

const CATEGORY_STATUSES = ["measured", "unknown", "not-applicable"];
const CONFIDENCES = ["high", "medium", "low"];
const FLOW_STATUSES = ["pending", "running", "complete", "skipped"];
const CANONICAL_WEIGHTS = [20, 20, 15, 15, 10, 10, 10];

/**
 * @typedef {{ min: number, max?: number, grade: string }} GradeThreshold
 * @typedef {{ iteration: number, score: number, grade: string, decision: string, evaluator_version?: string, weights?: number[] }} HistoryEntry
 * @typedef {{ categories: { name: string, status: string, score: number | null, evidence: string, confidence: string }[], overall_grade: string, score_history: HistoryEntry[], best_run: { iteration: number, score: number, grade: string } }} ResultsExample
 */

/**
 * Body of one section, up to the next heading of any level.
 *
 * @param {string} markdown document text
 * @param {string} title exact heading text
 * @returns {string} section body
 */
function sectionText(markdown, title) {
  const lines = markdown.split(/\r?\n/);
  let start = -1;
  for (let i = 0; i < lines.length; i += 1) {
    const heading = /^(#{1,6})\s+(.*)$/.exec(lines[i]);
    if (!heading) continue;
    if (start >= 0) return lines.slice(start, i).join("\n");
    if (heading[2].trim() === title) start = i + 1;
  }
  if (start < 0) throw new Error(`section not found: ${title}`);
  return lines.slice(start).join("\n");
}

/**
 * Parsed first ```json fence of one section.
 *
 * @param {string} markdown document text
 * @param {string} title exact heading text
 * @returns {any} parsed JSON
 */
function jsonExample(markdown, title) {
  const fence = /```json\r?\n([\s\S]*?)\r?\n```/.exec(sectionText(markdown, title));
  if (!fence) throw new Error(`no json fence in section: ${title}`);
  return JSON.parse(fence[1]);
}

/**
 * Absolute range of the first ```json fence content inside one section.
 *
 * @param {string} markdown document text
 * @param {string} title exact heading text
 * @returns {{ contentStart: number, contentEnd: number }} offsets into `markdown`
 */
function jsonFenceRange(markdown, title) {
  const lines = markdown.split(/\r?\n/);
  let offset = 0;
  let start = -1;
  let end = markdown.length;
  for (const line of lines) {
    const heading = /^(#{1,6})\s+(.*)$/.exec(line);
    if (heading) {
      if (start >= 0) {
        end = offset;
        break;
      }
      if (heading[2].trim() === title) start = offset + line.length + 1;
    }
    offset += line.length + 1;
  }
  if (start < 0) throw new Error(`section not found: ${title}`);
  const fence = /```json\r?\n([\s\S]*?)\r?\n```/.exec(markdown.slice(start, end));
  if (!fence) throw new Error(`no json fence in section: ${title}`);
  const contentStart = start + fence.index + fence[0].indexOf("\n") + 1;
  return { contentStart, contentEnd: contentStart + fence[1].length };
}

/**
 * Rewrite the JSON example of one section in a copied file.
 *
 * @param {string} filePath absolute path of the copy
 * @param {string} title exact heading text
 * @param {(value: any) => void} mutate in-place mutation
 */
function editJsonExample(filePath, title, mutate) {
  const text = readFileSync(filePath, "utf8");
  const { contentStart, contentEnd } = jsonFenceRange(text, title);
  const value = JSON.parse(text.slice(contentStart, contentEnd));
  mutate(value);
  writeFileSync(filePath, `${text.slice(0, contentStart)}${JSON.stringify(value, null, 2)}${text.slice(contentEnd)}`);
}

/**
 * Weights in canonical category order, parsed from the `<scoring>` block.
 *
 * @param {string} skillMarkdown SKILL.md text
 * @returns {number[]} weights
 */
function scoringWeights(skillMarkdown) {
  const block = /<scoring>([\s\S]*?)<\/scoring>/.exec(skillMarkdown);
  if (!block) throw new Error("<scoring> block not found");
  /** @type {number[]} */
  const weights = [];
  for (const line of block[1].split(/\r?\n/)) {
    const item = /^\s*-\s+[^:]+:\s+(\d+)\s*$/.exec(line);
    if (item) weights.push(Number(item[1]));
  }
  return weights;
}

/**
 * Grade threshold rows, parsed from the `Average | Grade` table.
 *
 * @param {string} markdown artifact-spec text
 * @returns {GradeThreshold[]} thresholds in document order
 */
function gradeThresholds(markdown) {
  const table = parseDoc(markdown).tables.find((entry) => entry.header[0] === "Average" && entry.header[1] === "Grade");
  if (!table) throw new Error("grade threshold table not found");
  return table.rows.map((row) => {
    const floor = /^>=\s*(\d+)$/.exec(row[0]);
    const ceiling = /^<\s*(\d+)$/.exec(row[0]);
    if (floor) return { min: Number(floor[1]), grade: row[1] };
    if (ceiling) return { min: -Infinity, max: Number(ceiling[1]), grade: row[1] };
    throw new Error(`unparsed grade threshold row: ${row.join(" | ")}`);
  });
}

/**
 * @param {number} score numeric score
 * @param {GradeThreshold[]} thresholds parsed thresholds
 * @returns {string} grade
 */
function gradeFor(score, thresholds) {
  for (const row of thresholds) {
    if (score >= row.min && (row.max === undefined || score < row.max)) return row.grade;
  }
  throw new Error(`no grade threshold matches score ${score}`);
}

/**
 * @param {number[]} scores category scores
 * @param {number[]} weights category weights in the same order
 * @returns {number} weighted score rounded to two decimals
 */
function weightedScore(scores, weights) {
  const totalWeight = weights.reduce((sum, weight) => sum + weight, 0);
  const total = scores.reduce((sum, score, index) => sum + score * weights[index], 0);
  return Math.round((total / totalWeight) * 100) / 100;
}

/**
 * Canonical phase list, parsed from the `flow.json` sentence in SKILL.md.
 *
 * @param {string} skillMarkdown SKILL.md text
 * @returns {string[]} phase names in order
 */
function skillFlowPhases(skillMarkdown) {
  const line = skillMarkdown
    .split(/\r?\n/)
    .find((entry) => /`flow\.json` tracks phases in order:/.test(entry));
  if (!line) throw new Error("flow.json phase sentence not found in SKILL.md");
  const order = /in order:\s*([^.]*)\./.exec(line);
  if (!order) throw new Error("flow.json phase order not parsed from SKILL.md");
  return [...order[1].matchAll(/`([^`]+)`/g)].map((match) => match[1]);
}

/**
 * Rows of one table inside one section, keyed by first cell.
 *
 * @param {string} markdown document text
 * @param {string} sectionTitle exact heading text
 * @param {string[]} header expected header cells
 * @returns {Map<string, string>} first cell to second cell
 */
function tableRows(markdown, sectionTitle, header) {
  const table = parseDoc(markdown).tables.find(
    (entry) => entry.section.endsWith(sectionTitle) && entry.header.join("|") === header.join("|"),
  );
  if (!table) throw new Error(`table not found in ${sectionTitle}: ${header.join(" | ")}`);
  return new Map(table.rows.map((row) => [row[0], row[1]]));
}

/**
 * Failures of the optimization-history contract for one results payload.
 *
 * @param {ResultsExample} results parsed results example
 * @param {{ thresholds: GradeThreshold[] }} options parsed grade thresholds
 * @returns {string[]} contract failures, empty when the history holds
 */
function optimizationHistoryFailures(results, options) {
  /** @type {string[]} */
  const failures = [];
  const history = results.score_history;
  if (!Array.isArray(history) || history.length === 0) return ["score_history is missing"];

  history.forEach((entry, index) => {
    const label = `score_history[${index}] (iteration ${entry.iteration})`;
    if (typeof entry.evaluator_version !== "string" || entry.evaluator_version.trim() === "") {
      failures.push(`${label}: evaluator_version is required`);
    }
    if (!Array.isArray(entry.weights) || entry.weights.length === 0 || entry.weights.some((weight) => typeof weight !== "number")) {
      failures.push(`${label}: weights are required`);
    }
    if (entry.grade !== gradeFor(entry.score, options.thresholds)) {
      failures.push(`${label}: grade ${entry.grade} does not match score ${entry.score}`);
    }
    const previous = history[index - 1];
    if (!previous) return;
    const definitionChanged =
      entry.evaluator_version !== previous.evaluator_version || JSON.stringify(entry.weights) !== JSON.stringify(previous.weights);
    if (definitionChanged && entry.decision !== "reset") {
      failures.push(`${label}: evaluator_version or weights changed without a reset event`);
    }
  });

  const best = results.best_run;
  if (!best || typeof best.iteration !== "number") {
    failures.push("best_run is missing");
    return failures;
  }
  const target = history.find((entry) => entry.iteration === best.iteration);
  if (!target) {
    failures.push(`best_run.iteration ${best.iteration}: no matching iteration`);
    return failures;
  }
  if (target.decision === "discarded") failures.push(`best_run points at a discarded iteration (${best.iteration})`);
  if (target.decision !== "kept") failures.push(`best_run iteration ${best.iteration} is not a kept iteration`);
  if (best.score !== target.score) failures.push(`best_run.score ${best.score} does not match iteration score ${target.score}`);
  if (best.grade !== gradeFor(best.score, options.thresholds)) {
    failures.push(`best_run.grade ${best.grade} does not match score ${best.score}`);
  }
  const keptScores = history.filter((entry) => entry.decision === "kept").map((entry) => entry.score);
  if (keptScores.length > 0) {
    const highest = Math.max(...keptScores);
    if (best.score < highest) failures.push(`best_run.score ${best.score} is below the highest kept score ${highest}`);
  }
  return failures;
}

/**
 * Run the grade and history contract against a mutated copy of the English spec.
 *
 * @param {(value: any) => void} mutate in-place mutation of the results example
 * @returns {{ results: ResultsExample, gradeMatches: boolean, history: string[] }} parsed copy and its contract outcomes
 */
function contractOfMutatedSpec(mutate) {
  const copy = tempCopy(ARTIFACT_SPEC_EN);
  try {
    editJsonExample(join(copy.root, ARTIFACT_SPEC_EN), RESULTS_SECTION, mutate);
    const markdown = readDoc(ARTIFACT_SPEC_EN, copy.root);
    const results = jsonExample(markdown, RESULTS_SECTION);
    const categories = /** @type {any[]} */ (results.categories);
    const thresholds = gradeThresholds(markdown);
    const computed = gradeFor(weightedScore(categories.map((category) => category.score ?? 0), scoringWeights(readDoc(SKILL_EN))), thresholds);
    return { results, gradeMatches: computed === results.overall_grade, history: optimizationHistoryFailures(results, { thresholds }) };
  } finally {
    copy.cleanup();
  }
}

test("the documented example grades with the SKILL.md weights", () => {
  const weights = scoringWeights(readDoc(SKILL_EN, DOC_ROOT));
  expect(weights).toEqual(CANONICAL_WEIGHTS);

  const markdown = readDoc(ARTIFACT_SPEC_EN, DOC_ROOT);
  const results = jsonExample(markdown, RESULTS_SECTION);
  const categories = /** @type {any[]} */ (results.categories);
  const scores = categories.map((category) => category.score);
  expect(scores.length).toBe(weights.length);

  const thresholds = gradeThresholds(markdown);
  const computed = weightedScore(scores, weights);
  expect(computed).toBe(72.2);
  expect(gradeFor(computed, thresholds)).toBe("C");
  expect(results.overall_grade).toBe("C");
});

test("grade thresholds stay unchanged", () => {
  expect(gradeThresholds(readDoc(ARTIFACT_SPEC_EN, DOC_ROOT))).toEqual([
    { min: 90, grade: "A" },
    { min: 75, grade: "B" },
    { min: 60, grade: "C" },
    { min: 40, grade: "D" },
    { min: -Infinity, max: 40, grade: "F" },
  ]);
});

test("category examples record status, evidence, and confidence", () => {
  const results = jsonExample(readDoc(ARTIFACT_SPEC_EN, DOC_ROOT), RESULTS_SECTION);
  expect(results.categories.length).toBe(CANONICAL_WEIGHTS.length);
  for (const category of results.categories) {
    expect(Object.keys(category)).toEqual(expect.arrayContaining(["name", "status", "score", "evidence", "confidence"]));
    expect(CATEGORY_STATUSES).toContain(category.status);
    expect(CONFIDENCES).toContain(category.confidence);
    expect(typeof category.evidence).toBe("string");
    expect(category.evidence.length).toBeGreaterThan(0);
    if (category.score !== null) {
      expect(category.score).toBeGreaterThanOrEqual(0);
      expect(category.score).toBeLessThanOrEqual(100);
    }
  }
});

test("the Korean spec mirrors the English score and flow example", () => {
  const en = readDoc(ARTIFACT_SPEC_EN, DOC_ROOT);
  const ko = readDoc(ARTIFACT_SPEC_KO, DOC_ROOT);
  const enResults = jsonExample(en, RESULTS_SECTION);
  const koResults = jsonExample(ko, RESULTS_SECTION);

  const enCategories = /** @type {any[]} */ (enResults.categories);
  const koCategories = /** @type {any[]} */ (koResults.categories);
  expect(koResults.overall_grade).toBe(enResults.overall_grade);
  expect(koCategories.map((category) => [category.name, category.status, category.score])).toEqual(
    enCategories.map((category) => [category.name, category.status, category.score]),
  );
  for (const category of koResults.categories) {
    expect(Object.keys(category)).toEqual(expect.arrayContaining(["status", "evidence", "confidence"]));
  }
  const enPhases = /** @type {any[]} */ (jsonExample(en, FLOW_SECTION).phases);
  const koPhases = /** @type {any[]} */ (jsonExample(ko, FLOW_SECTION).phases);
  expect(koPhases.map((phase) => phase.name)).toEqual(enPhases.map((phase) => phase.name));
});

test("the flow.json contract matches the SKILL.md phase list", () => {
  const markdown = readDoc(ARTIFACT_SPEC_EN, DOC_ROOT);
  const flow = jsonExample(markdown, FLOW_SECTION);
  const flowPhases = /** @type {any[]} */ (flow.phases);
  const phases = flowPhases.map((phase) => phase.name);
  expect(phases).toEqual(skillFlowPhases(readDoc(SKILL_EN, DOC_ROOT)));
  for (const phase of flowPhases) expect(FLOW_STATUSES).toContain(phase.status);
  expect(flow.resume_at).toBe(phases[flowPhases.findIndex((phase) => phase.status !== "complete")]);

  const rows = tableRows(markdown, FLOW_SECTION, ["Field", "Contract"]);
  expect([...rows.keys()]).toEqual(expect.arrayContaining(["`phases[].name`", "`phases[].status`", "`resume_at`"]));
  const statusCell = rows.get("`phases[].status`") ?? "";
  expect([...statusCell.matchAll(/`([^`]+)`/g)].map((match) => match[1])).toEqual(FLOW_STATUSES);
});

test("the documented optimization history satisfies the history contract", () => {
  const markdown = readDoc(ARTIFACT_SPEC_EN, DOC_ROOT);
  const results = jsonExample(markdown, RESULTS_SECTION);
  const weights = scoringWeights(readDoc(SKILL_EN, DOC_ROOT));
  for (const entry of results.score_history) expect(entry.weights).toEqual(weights);
  expect(optimizationHistoryFailures(results, { thresholds: gradeThresholds(markdown) })).toEqual([]);
});

test("rejects a documented grade that the weights do not produce", () => {
  const outcome = contractOfMutatedSpec((value) => {
    value.overall_grade = "B";
  });
  expect(outcome.results.overall_grade).toBe("B");
  expect(outcome.gradeMatches).toBe(false);
});

test("rejects a history entry without evaluator_version", () => {
  const outcome = contractOfMutatedSpec((value) => {
    delete value.score_history[1].evaluator_version;
  });
  expect(outcome.results.score_history[1].evaluator_version).toBeUndefined();
  expect(outcome.history.join("\n")).toMatch(/evaluator_version/);
});

test("rejects a weight change without a reset event", () => {
  const outcome = contractOfMutatedSpec((value) => {
    value.score_history[1].weights = [25, 20, 15, 10, 10, 10, 10];
  });
  expect(outcome.results.score_history[1].weights).toEqual([25, 20, 15, 10, 10, 10, 10]);
  expect(outcome.history.join("\n")).toMatch(/reset/);
});

test("rejects best_run pointing at a discarded iteration", () => {
  const outcome = contractOfMutatedSpec((value) => {
    value.score_history[1].decision = "discarded";
  });
  expect(outcome.results.score_history[1].decision).toBe("discarded");
  expect(outcome.history.join("\n")).toMatch(/discarded/);
});

test("rejects best_run that is not the highest kept score", () => {
  const outcome = contractOfMutatedSpec((value) => {
    value.score_history.push({
      iteration: 2,
      score: 85,
      grade: "B",
      critical_count: 0,
      decision: "kept",
      changed: "Cleaned up remaining on-page issues",
      evidence: "Later re-audit",
      evaluator_version: value.score_history[1].evaluator_version,
      weights: value.score_history[1].weights,
    });
  });
  expect(outcome.results.score_history.length).toBe(3);
  expect(outcome.history.join("\n")).toMatch(/highest kept score/);
});
