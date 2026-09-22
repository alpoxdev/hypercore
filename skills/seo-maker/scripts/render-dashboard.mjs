#!/usr/bin/env bun
// @ts-check

import { closeSync, existsSync, fchmodSync, fsyncSync, mkdirSync, openSync, readFileSync, renameSync, statSync, unlinkSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { randomUUID } from "node:crypto";

/** @param {string} message */
function fail(message) {
  console.error(message);
  process.exit(1);
}

/** @param {string} path */
function isFile(path) {
  return existsSync(path) && statSync(path).isFile();
}

if (process.argv.length !== 3) fail("사용법: scripts/render-dashboard.mjs <artifact-dir>");

const artifactDir = process.argv[2];
const skillDir = dirname(dirname(fileURLToPath(import.meta.url)));
const templatePath = join(skillDir, "assets", "dashboard-template.html");
const resultsPath = join(artifactDir, "results.json");
const dashboardPath = join(artifactDir, "dashboard.html");
const resultsJsPath = join(artifactDir, "results.js");

if (!isFile(templatePath)) fail(`대시보드 템플릿이 없습니다: ${templatePath}`);
if (!isFile(resultsPath)) fail(`results.json이 없습니다: ${resultsPath}`);

let results;
try {
  results = JSON.parse(readFileSync(resultsPath, "utf8"));
} catch (error) {
  if (error instanceof SyntaxError) fail(`results.json JSON 파싱에 실패했습니다: ${error.message}`);
  throw error;
}

// Structure gate. Unknown extra keys stay allowed (K9); every violation exits
// through fail() before anything is written, so prior outputs survive.
const topLevelStatuses = ["complete", "idle", "running"];
const categoryStatuses = ["measured", "unknown", "not-applicable"];
const severities = ["critical", "warning", "info"];
const evidenceGrades = ["official", "live", "field", "tool", "lab", "synthetic", "heuristic"];
const sourceTiers = ["official-doc", "observed-file", "live-observation", "field-data", "tool-output", "lab-result", "synthetic-probe", "research-backed-heuristic"];
const grades = ["A", "B", "C", "D", "F"];

/**
 * @param {unknown} value
 * @returns {boolean}
 */
function isObject(value) {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * @param {string} path
 * @param {unknown} value
 * @param {string[]} allowed
 */
function checkEnum(path, value, allowed) {
  if (typeof value !== "string" || !allowed.includes(value)) {
    fail(`results.json ${path} 값이 유효하지 않습니다: ${JSON.stringify(value)} (허용: ${allowed.join(", ")})`);
  }
}

if (!isObject(results)) fail(`results.json은 객체여야 합니다: ${Array.isArray(results) ? "array" : JSON.stringify(results)}`);

const requiredKeys = ["project_name", "status", "categories", "findings"];
const missingKeys = requiredKeys.filter((key) => !(key in results));
if (missingKeys.length > 0) fail(`results.json 필수 키가 없습니다: ${missingKeys.join(", ")}`);

checkEnum("status", results.status, topLevelStatuses);
if (results.overall_grade !== undefined && results.overall_grade !== null) checkEnum("overall_grade", results.overall_grade, grades);

const categories = results.categories;
if (!Array.isArray(categories)) fail("results.json categories는 배열이어야 합니다");
for (const [index, category] of categories.entries()) {
  if (!isObject(category)) fail(`results.json categories[${index}]는 객체여야 합니다`);
  checkEnum(`categories[${index}].status`, category.status, categoryStatuses);
  const score = category.score;
  if (score !== null && (typeof score !== "number" || !Number.isFinite(score) || score < 0 || score > 100)) {
    fail(`results.json categories[${index}].score는 0..100 또는 null이어야 합니다: ${JSON.stringify(score)}`);
  }
}

const findings = results.findings;
if (!Array.isArray(findings)) fail("results.json findings는 배열이어야 합니다");
for (const [index, finding] of findings.entries()) {
  if (!isObject(finding)) fail(`results.json findings[${index}]는 객체여야 합니다`);
  checkEnum(`findings[${index}].severity`, finding.severity, severities);
  if (finding.evidence_grade !== undefined) checkEnum(`findings[${index}].evidence_grade`, finding.evidence_grade, evidenceGrades);
  if (finding.source_tier !== undefined) checkEnum(`findings[${index}].source_tier`, finding.source_tier, sourceTiers);
}

// Nested blocks the dashboard dereferences per entry. A null or scalar entry
// passes the key checks above and then aborts the render, leaving every panel
// from measurement onward at its placeholder while the run reports success.
for (const key of ["measurement_methods", "platform_policy"]) {
  const block = results[key];
  if (block === undefined) continue;
  if (!isObject(block)) fail(`results.json ${key}는 객체여야 합니다: ${JSON.stringify(block)}`);
  for (const [name, entry] of Object.entries(block)) {
    if (!isObject(entry)) fail(`results.json ${key}.${name}은 객체여야 합니다: ${JSON.stringify(entry)}`);
    if (typeof entry.status !== "string" || entry.status.trim() === "") {
      fail(`results.json ${key}.${name}.status는 비어 있지 않은 문자열이어야 합니다: ${JSON.stringify(entry.status)}`);
    }
  }
}

/** @type {Array<[string, string[]]>} */
const nestedArrayFields = [["query_fanout", ["queries", "missing_topics"]], ["citation_probe", ["engines"]]];
for (const [key, fields] of nestedArrayFields) {
  const block = results[key];
  if (block === undefined) continue;
  if (!isObject(block)) fail(`results.json ${key}는 객체여야 합니다: ${JSON.stringify(block)}`);
  for (const field of fields) {
    if (block[field] !== undefined && !Array.isArray(block[field])) {
      fail(`results.json ${key}.${field}는 배열이어야 합니다: ${JSON.stringify(block[field])}`);
    }
  }
}

// Optimize-mode history, validated only when it is recorded: score_history
// entries carry the evaluator identity, and best_run must point at the highest
// kept iteration. A changed evaluator definition needs a reset event.
if (results.score_history !== undefined || results.best_run !== undefined) {
  const history = results.score_history;
  if (!Array.isArray(history) || history.length === 0) fail("results.json score_history는 비어 있지 않은 배열이어야 합니다");
  for (const [index, entry] of history.entries()) {
    if (!isObject(entry)) fail(`results.json score_history[${index}]는 객체여야 합니다`);
    if (typeof entry.evaluator_version !== "string" || entry.evaluator_version.trim() === "") {
      fail(`results.json score_history[${index}].evaluator_version이 없습니다: ${JSON.stringify(entry.evaluator_version)}`);
    }
    if (!Array.isArray(entry.weights)) {
      fail(`results.json score_history[${index}].weights가 없습니다 (정본 순서의 범주 가중치 배열이어야 합니다): ${JSON.stringify(entry.weights)}`);
    }
    const previous = history[index - 1];
    if (!isObject(previous)) continue;
    // Compare weights whenever either side records them, so omitting weights
    // from the previous entry cannot hide a definition change.
    const weightsChanged = JSON.stringify(entry.weights) !== JSON.stringify(previous.weights ?? null);
    const definitionChanged = entry.evaluator_version !== previous.evaluator_version || weightsChanged;
    if (definitionChanged && entry.decision !== "reset") {
      fail(`results.json score_history[${index}]은 evaluator_version 또는 weights가 바뀌었는데 reset 기록이 없습니다 (decision: ${JSON.stringify(entry.decision)})`);
    }
  }
  if (results.best_run !== undefined) {
    const bestRun = results.best_run;
    if (!isObject(bestRun)) fail("results.json best_run은 객체여야 합니다");
    if (typeof bestRun.iteration !== "number") fail(`results.json best_run.iteration은 숫자여야 합니다: ${JSON.stringify(bestRun.iteration)}`);
    let targetIndex = -1;
    for (const [index, entry] of history.entries()) {
      if (isObject(entry) && entry.iteration === bestRun.iteration) {
        targetIndex = index;
        break;
      }
    }
    if (targetIndex === -1) fail(`results.json best_run.iteration ${bestRun.iteration}에 해당하는 score_history 항목이 없습니다`);
    const target = history[targetIndex];
    if (target.decision === "discarded") fail(`results.json best_run이 discarded iteration을 가리킵니다: ${bestRun.iteration}`);
    if (target.decision !== "kept") fail(`results.json best_run.iteration ${bestRun.iteration}은 kept 항목이 아닙니다 (decision: ${JSON.stringify(target.decision)})`);
    if (typeof bestRun.score !== "number") fail(`results.json best_run.score는 숫자여야 합니다: ${JSON.stringify(bestRun.score)}`);
    if (bestRun.score !== target.score) fail(`results.json best_run.score ${bestRun.score}가 iteration ${bestRun.iteration}의 점수 ${target.score}와 다릅니다`);
    const keptScores = [];
    for (const entry of history) {
      if (isObject(entry) && entry.decision === "kept" && typeof entry.score === "number") keptScores.push(entry.score);
    }
    if (keptScores.length > 0 && bestRun.score < Math.max(...keptScores)) {
      fail(`results.json best_run.score ${bestRun.score}가 최고 kept 점수 ${Math.max(...keptScores)}보다 낮습니다`);
    }
  }
}
/**
 * @param {string} path
 * @returns {{ content: Buffer, mode: number } | null}
 */
function snapshotOutput(path) {
  if (!existsSync(path)) return null;
  const stats = statSync(path);
  if (!stats.isFile()) throw new Error(`출력 경로가 일반 파일이 아닙니다: ${path}`);
  return { content: readFileSync(path), mode: stats.mode & 0o7777 };
}

/** @param {string} path */
function temporaryPath(path) {
  return `${path}.${process.pid}.${randomUUID()}.tmp`;
}

/**
 * @param {string} path
 * @param {string | Buffer} content
 * @param {number | undefined} mode
 */
function writeSyncedTemp(path, content, mode) {
  const descriptor = openSync(path, "wx", 0o666);
  try {
    if (mode !== undefined) fchmodSync(descriptor, mode);
    writeFileSync(descriptor, content);
    fsyncSync(descriptor);
  } catch (error) {
    closeSync(descriptor);
    unlinkSync(path);
    throw error;
  }
  closeSync(descriptor);
}

/** @param {string} path */
function removeTemp(path) {
  if (existsSync(path)) unlinkSync(path);
}

/**
 * @param {string} path
 * @param {{ content: Buffer, mode: number } | null} snapshot
 */
function restoreOutput(path, snapshot) {
  if (snapshot === null) {
    if (existsSync(path)) unlinkSync(path);
    return;
  }

  const tempPath = temporaryPath(path);
  try {
    writeSyncedTemp(tempPath, snapshot.content, snapshot.mode);
    renameSync(tempPath, path);
  } finally {
    removeTemp(tempPath);
  }
}

/**
 * @param {string | Buffer} dashboard
 * @param {string} resultsJs
 */
function writeOutputPair(dashboard, resultsJs) {
  const dashboardSnapshot = snapshotOutput(dashboardPath);
  const resultsSnapshot = snapshotOutput(resultsJsPath);
  const dashboardTempPath = temporaryPath(dashboardPath);
  const resultsTempPath = temporaryPath(resultsJsPath);

  try {
    writeSyncedTemp(dashboardTempPath, dashboard, dashboardSnapshot?.mode);
    writeSyncedTemp(resultsTempPath, resultsJs, resultsSnapshot?.mode);
    renameSync(dashboardTempPath, dashboardPath);
    try {
      renameSync(resultsTempPath, resultsJsPath);
    } catch (error) {
      try {
        restoreOutput(dashboardPath, dashboardSnapshot);
      } catch (restoreError) {
        throw new AggregateError([error, restoreError], "results.js 커밋 실패 후 dashboard.html 복원에 실패했습니다");
      }
      throw error;
    }
  } finally {
    removeTemp(dashboardTempPath);
    removeTemp(resultsTempPath);
  }
}

mkdirSync(artifactDir, { recursive: true });
writeOutputPair(readFileSync(templatePath), `window.__SEO_RESULTS__ = ${JSON.stringify(results)};\n`);

console.log(`렌더 완료: ${dashboardPath}`);
console.log(`렌더 완료: ${resultsJsPath}`);
