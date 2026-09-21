#!/usr/bin/env bun
// @ts-check

import { closeSync, existsSync, fchmodSync, fsyncSync, openSync, readFileSync, renameSync, statSync, unlinkSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { randomUUID } from "node:crypto";

/**
 * @typedef {{ id: string, label: string, body: string }} Layer
 * @typedef {{ actor: string, action: string, effect: string }} Step
 * @typedef {{ text: string, limit: string }} Analogy
 * @typedef {{ term: string, plain: string }} Term
 * @typedef {{ title: string, summary: string, language: string, audience: string, layers: Layer[], mechanism: Step[], analogy: Analogy | null, terms: Term[], cautions: string[], sources: string[] }} Explanation
 */

/** The six layer ids owned by the skill's explanation shape. */
const LAYER_IDS = ["gist", "model", "mechanism", "why", "boundary", "check"];
/** Lowercase BCP-47 shape accepted for the language field. */
const LANGUAGE_PATTERN = /^[a-z]{2,3}(-[A-Za-z0-9]{2,8})*$/;
/** Every key the closed schema accepts at the top level. */
const TOP_LEVEL_KEYS = ["title", "summary", "language", "audience", "layers", "mechanism", "analogy", "terms", "cautions", "sources"];

/**
 * Writes one Korean message to stderr and stops the process.
 *
 * @param {string} message
 * @returns {never}
 */
function fail(message) {
  console.error(message);
  process.exit(1);
}

/**
 * Reports whether a value is a non-empty string after trimming.
 *
 * @param {unknown} value
 * @returns {boolean}
 */
function isFilledString(value) {
  return typeof value === "string" && value.trim() !== "";
}

/**
 * Reports whether a value is a plain object rather than an array or null.
 *
 * @param {unknown} value
 * @returns {boolean}
 */
function isPlainObject(value) {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Escapes text for HTML text and attribute positions.
 *
 * @param {string} value
 * @returns {string}
 */
function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

/**
 * Serializes a value for an inline JSON block without letting it close the block.
 *
 * @param {unknown} value
 * @returns {string}
 */
function serializeForScript(value) {
  return JSON.stringify(value).replaceAll("<", "\\u003c");
}

/**
 * Collects the field names that violate the closed schema, in a fixed order.
 *
 * @param {unknown} value
 * @returns {string[]}
 */
function collectViolations(value) {
  /** @type {string[]} */
  const violations = [];
  if (!isPlainObject(value)) return ["root"];
  const record = /** @type {Record<string, unknown>} */ (value);

  for (const key of Object.keys(record)) {
    if (!TOP_LEVEL_KEYS.includes(key)) violations.push(key);
  }

  if (!isFilledString(record.title) || String(record.title).length > 120) violations.push("title");
  if (!isFilledString(record.summary)) violations.push("summary");
  if (record.language !== undefined && !(typeof record.language === "string" && LANGUAGE_PATTERN.test(record.language))) violations.push("language");
  if (record.audience !== undefined && !isFilledString(record.audience)) violations.push("audience");

  if (!Array.isArray(record.layers) || record.layers.length === 0) {
    violations.push("layers");
  } else {
    const entries = /** @type {unknown[]} */ (record.layers);
    /** @type {Set<string>} */
    const seen = new Set();
    for (const entry of entries) {
      if (!isPlainObject(entry)) { violations.push("layers"); break; }
      const layer = /** @type {Record<string, unknown>} */ (entry);
      const id = String(layer.id);
      if (!isFilledString(layer.id) || !LAYER_IDS.includes(id) || seen.has(id) || !isFilledString(layer.label) || !isFilledString(layer.body)) {
        violations.push("layers");
        break;
      }
      seen.add(id);
    }
  }

  if (record.mechanism !== undefined) {
    if (!Array.isArray(record.mechanism)) {
      violations.push("mechanism");
    } else {
      for (const entry of /** @type {unknown[]} */ (record.mechanism)) {
        const step = isPlainObject(entry) ? /** @type {Record<string, unknown>} */ (entry) : null;
        if (step === null || !isFilledString(step.actor) || !isFilledString(step.action) || !isFilledString(step.effect)) {
          violations.push("mechanism");
          break;
        }
      }
    }
  }

  if (record.analogy !== undefined) {
    const analogy = isPlainObject(record.analogy) ? /** @type {Record<string, unknown>} */ (record.analogy) : null;
    if (analogy === null || !isFilledString(analogy.text) || !isFilledString(analogy.limit)) violations.push("analogy");
  }

  if (record.terms !== undefined) {
    if (!Array.isArray(record.terms)) {
      violations.push("terms");
    } else {
      for (const entry of /** @type {unknown[]} */ (record.terms)) {
        const term = isPlainObject(entry) ? /** @type {Record<string, unknown>} */ (entry) : null;
        if (term === null || !isFilledString(term.term) || !isFilledString(term.plain)) {
          violations.push("terms");
          break;
        }
      }
    }
  }

  for (const listKey of ["cautions", "sources"]) {
    const list = record[listKey];
    if (list === undefined) continue;
    if (!Array.isArray(list) || /** @type {unknown[]} */ (list).some((entry) => !isFilledString(entry))) {
      violations.push(listKey);
    }
  }

  return violations;
}

/**
 * Casts a validated document into the typed shape the renderer consumes.
 *
 * @param {Record<string, unknown>} record
 * @returns {Explanation}
 */
function normalize(record) {
  return {
    title: String(record.title),
    summary: String(record.summary),
    language: typeof record.language === "string" ? record.language : "ko",
    audience: typeof record.audience === "string" ? record.audience : "",
    layers: /** @type {Layer[]} */ (record.layers),
    mechanism: Array.isArray(record.mechanism) ? /** @type {Step[]} */ (record.mechanism) : [],
    analogy: isPlainObject(record.analogy) ? /** @type {Analogy} */ (record.analogy) : null,
    terms: Array.isArray(record.terms) ? /** @type {Term[]} */ (record.terms) : [],
    cautions: Array.isArray(record.cautions) ? /** @type {string[]} */ (record.cautions) : [],
    sources: Array.isArray(record.sources) ? /** @type {string[]} */ (record.sources) : [],
  };
}

/**
 * Renders the top-of-body heading and gist.
 *
 * @param {Explanation} explanation
 * @returns {string}
 */
function renderTop(explanation) {
  return `<h1 class="view-title">${escapeHtml(explanation.title)}</h1>` +
    `<p class="view-summary" data-term-search>${escapeHtml(explanation.summary)}</p>`;
}

/**
 * Renders the layer rail. Layers are required, so this block is always present.
 *
 * @param {Explanation} explanation
 * @returns {string}
 */
function renderLayers(explanation) {
  const items = explanation.layers.map((layer) =>
    `<li class="layer" data-layer-id="${escapeHtml(layer.id)}">` +
    `<div class="layer-head"><h3 class="layer-label">${escapeHtml(layer.label)}</h3>` +
    `<button class="layer-toggle" type="button" aria-expanded="true">접기</button></div>` +
    `<p class="layer-body" data-term-search>${escapeHtml(layer.body)}</p>` +
    `</li>`);
  return `<section aria-labelledby="layers-heading"><h2 id="layers-heading">계층</h2><ol class="layers">${items.join("")}</ol></section>`;
}

/**
 * Renders the mechanism step flow, or an empty string when there are no steps.
 *
 * @param {Explanation} explanation
 * @returns {string}
 */
function renderMechanism(explanation) {
  if (explanation.mechanism.length === 0) return "";
  const items = explanation.mechanism.map((step, index) =>
    `<li class="step" data-step-index="${index}" tabindex="0">` +
    `<span class="step-actor">${escapeHtml(step.actor)}</span>` +
    `<span class="step-action" data-term-search>${escapeHtml(step.action)}</span>` +
    `<span class="step-effect" data-term-search>${escapeHtml(step.effect)}</span>` +
    `</li>`);
  return `<section aria-labelledby="mechanism-heading"><h2 id="mechanism-heading">메커니즘</h2><ol class="steps">${items.join("")}</ol></section>`;
}

/**
 * Renders the analogy with its required limit, or an empty string when absent.
 *
 * @param {Explanation} explanation
 * @returns {string}
 */
function renderAnalogy(explanation) {
  if (explanation.analogy === null) return "";
  return `<section aria-labelledby="analogy-heading"><h2 id="analogy-heading">비유와 한계</h2>` +
    `<figure class="analogy"><p class="analogy-text" data-term-search>${escapeHtml(explanation.analogy.text)}</p>` +
    `<figcaption class="analogy-limit">${escapeHtml(explanation.analogy.limit)}</figcaption></figure></section>`;
}

/**
 * Renders the term list, or an empty string when there are no terms.
 *
 * @param {Explanation} explanation
 * @returns {string}
 */
function renderTerms(explanation) {
  if (explanation.terms.length === 0) return "";
  const items = explanation.terms.map((term) =>
    `<div class="term" data-term-id="${escapeHtml(term.term)}" tabindex="0">` +
    `<dt class="term-name">${escapeHtml(term.term)}</dt>` +
    `<dd class="term-plain">${escapeHtml(term.plain)}</dd></div>`);
  return `<section aria-labelledby="terms-heading"><h2 id="terms-heading">용어</h2><dl class="terms">${items.join("")}</dl></section>`;
}

/**
 * Renders the caution list, or an empty string when there are no cautions.
 *
 * @param {Explanation} explanation
 * @returns {string}
 */
function renderCautions(explanation) {
  if (explanation.cautions.length === 0) return "";
  const items = explanation.cautions.map((caution) => `<li class="caution">${escapeHtml(caution)}</li>`);
  return `<section aria-labelledby="cautions-heading"><h2 id="cautions-heading">주의점</h2><ul class="cautions">${items.join("")}</ul></section>`;
}

/**
 * Substitutes every template token exactly once.
 *
 * Uniqueness is checked against the ORIGINAL template, and substitution runs in a single pass over
 * that original. Both matter: checking the accumulated output would let a valid user string that
 * happens to contain a token literal change the count and fail closed, and replacing token by token
 * could match a literal that a previous replacement already inserted.
 *
 * @param {string} template
 * @param {Array<[string, string]>} replacements
 * @returns {string}
 */
function applyTokens(template, replacements) {
  /** @type {Map<string, string>} */
  const values = new Map(replacements);
  for (const token of values.keys()) {
    if (template.split(token).length - 1 !== 1) fail(`뷰 템플릿 토큰이 없습니다: ${token}`);
  }
  const pattern = new RegExp(replacements.map(([token]) => token.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|"), "g");
  return template.replace(pattern, (match) => values.get(match) ?? match);
}

/**
 * Reads the current output file's mode so a failed run can preserve it.
 *
 * A path that exists but is not a regular file returns null; the atomic rename
 * then fails on its own and reports the write failure.
 *
 * @param {string} outputPath
 * @returns {{ mode: number } | null}
 */
function snapshotOutput(outputPath) {
  if (!existsSync(outputPath)) return null;
  const stats = statSync(outputPath);
  if (!stats.isFile()) return null;
  return { mode: stats.mode & 0o7777 };
}

/**
 * Writes the artifact through a temporary file and an atomic rename.
 *
 * @param {string} outputPath
 * @param {string} content
 * @param {number} mode
 * @returns {void}
 */
function writeAtomically(outputPath, content, mode) {
  const temporaryPath = `${outputPath}.${process.pid}.${randomUUID()}.tmp`;
  try {
    const descriptor = openSync(temporaryPath, "w", mode);
    writeFileSync(descriptor, content);
    fchmodSync(descriptor, mode);
    fsyncSync(descriptor);
    closeSync(descriptor);
    renameSync(temporaryPath, outputPath);
  } catch (error) {
    try {
      unlinkSync(temporaryPath);
    } catch (cleanupError) {
      // The temporary file may never have been created; nothing to remove.
    }
    fail(`뷰 출력을 쓰지 못했습니다: ${outputPath}`);
  }
}

/**
 * Runs the renderer for one artifact directory.
 *
 * @returns {void}
 */
function main() {
  if (process.argv.length !== 3) fail("사용법: scripts/render-explanation.mjs <artifact-dir>");
  const artifactDirectory = process.argv[2];
  const skillDirectory = dirname(dirname(fileURLToPath(import.meta.url)));
  const templatePath = join(skillDirectory, "assets", "explanation-view.template.html");
  const inputPath = join(artifactDirectory, "explanation.json");
  const outputPath = join(artifactDirectory, "explanation.html");

  if (!existsSync(templatePath)) fail(`뷰 템플릿이 없습니다: ${templatePath}`);
  if (!existsSync(inputPath)) fail(`explanation.json이 없습니다: ${inputPath}`);

  let parsed;
  try {
    parsed = JSON.parse(readFileSync(inputPath, "utf8"));
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    fail(`explanation.json JSON 파싱에 실패했습니다: ${detail}`);
  }

  const violations = collectViolations(parsed);
  if (violations.length > 0) fail(`explanation.json 스키마 위반: ${violations.join(", ")}`);

  const explanation = normalize(/** @type {Record<string, unknown>} */ (parsed));
  const template = readFileSync(templatePath, "utf8");
  const payload = serializeForScript({
    title: explanation.title,
    language: explanation.language,
    terms: explanation.terms,
    layerCount: explanation.layers.length,
    stepCount: explanation.mechanism.length,
  });
  const rendered = applyTokens(template, [
    ["<!--{{LANG}}-->", escapeHtml(explanation.language)],
    ["<!--{{TITLE}}-->", escapeHtml(explanation.title)],
    ["<!--{{SUMMARY}}-->", renderTop(explanation)],
    ["<!--{{LAYERS}}-->", renderLayers(explanation)],
    ["<!--{{MECHANISM}}-->", renderMechanism(explanation)],
    ["<!--{{ANALOGY}}-->", renderAnalogy(explanation)],
    ["<!--{{TERMS}}-->", renderTerms(explanation)],
    ["<!--{{CAUTIONS}}-->", renderCautions(explanation)],
    ["/*{{DATA}}*/", payload],
  ]);

  const previous = snapshotOutput(outputPath);
  writeAtomically(outputPath, rendered, previous === null ? 0o644 : previous.mode);
  console.log(JSON.stringify({
    status: "ok",
    layers: explanation.layers.length,
    steps: explanation.mechanism.length,
    terms: explanation.terms.length,
    cautions: explanation.cautions.length,
  }));
}

main();
