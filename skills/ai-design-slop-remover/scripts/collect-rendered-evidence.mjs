#!/usr/bin/env bun
// @ts-check
/** Validate a browser-evidence handoff document and emit only the observations it proves. */
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

/** @type {Set<unknown>} */
const STATES = new Set(['default', 'hover', 'focus', 'active', 'disabled', 'loading', 'empty', 'error']);

/**
 * @typedef {{ viewport: unknown, state: unknown, locator: unknown, rect: unknown, overflowX: unknown, focusVisible: unknown, reducedMotion: unknown, computed: unknown }} Observation
 */

/** @param {string[]} argv @returns {{ help: true, json: boolean } | { help: false, input: string, json: boolean }} @throws {Error} for unknown arguments or a missing input */
function parseArgs(argv) {
  /** @type {string | undefined} */
  let input; let json = false;
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--input') input = argv[++index];
    else if (arg === '--json') json = true;
    else if (arg === '--help' || arg === '-h') return { help: true, json };
    else throw new Error(`Unknown argument: ${arg}`);
  }
  if (!input) throw new Error('--input requires a path');
  return { help: false, input, json };
}
/** @param {unknown} value @returns {value is Record<string, unknown>} */
function isRecord(value) { return typeof value === 'object' && value !== null && !Array.isArray(value); }
/** @param {unknown} value @returns {boolean} */
function positiveNumber(value) { return typeof value === 'number' && Number.isFinite(value) && value > 0; }
/** @param {Record<string, unknown>} rect @returns {boolean} */
function hasRectShape(rect) { return ['x', 'y', 'width', 'height'].every((key) => typeof rect[key] === 'number'); }
/** @param {unknown} value @returns {{ ok: boolean, errors: string[], observations: Observation[] }} */
function validate(value) {
  /** @type {string[]} */
  const errors = [];
  /** @type {Observation[]} */
  const observations = [];
  if (!isRecord(value)) return { ok: false, errors: ['Evidence handoff must be an object.'], observations };
  if (value.version !== 1) errors.push('version must equal 1.');
  if (typeof value.surface !== 'string' || !value.surface.trim()) errors.push('surface must be a non-empty string.');
  if (!Array.isArray(value.captures) || value.captures.length === 0) errors.push('captures must be a non-empty array.');
  const captures = /** @type {unknown[]} */ (value.captures ?? []);
  for (const [captureIndex, capture] of captures.entries()) {
    const label = `captures[${captureIndex}]`;
    if (!isRecord(capture)) { errors.push(`${label} must be an object.`); continue; }
    if (!isRecord(capture.viewport) || !positiveNumber(capture.viewport.width) || !positiveNumber(capture.viewport.height)) errors.push(`${label}.viewport requires positive width and height.`);
    if (!STATES.has(capture.state)) errors.push(`${label}.state is invalid.`);
    if (typeof capture.capturedAt !== 'string' || Number.isNaN(Date.parse(capture.capturedAt))) errors.push(`${label}.capturedAt must be an ISO date-time.`);
    if (!Array.isArray(capture.observations) || capture.observations.length === 0) errors.push(`${label}.observations must be non-empty.`);
    const captureObservations = /** @type {unknown[]} */ (capture.observations ?? []);
    for (const [observationIndex, observation] of captureObservations.entries()) {
      const observationLabel = `${label}.observations[${observationIndex}]`;
      if (!isRecord(observation)) { errors.push(`${observationLabel} must be an object.`); continue; }
      if (typeof observation.locator !== 'string' || !observation.locator.trim()) errors.push(`${observationLabel}.locator must be non-empty.`);
      const hasRect = isRecord(observation.rect) && hasRectShape(observation.rect);
      const hasOverflow = typeof observation.overflowX === 'boolean';
      const hasFocus = typeof observation.focusVisible === 'boolean';
      const hasMotion = typeof observation.reducedMotion === 'boolean';
      const hasComputed = isRecord(observation.computed) && Object.values(observation.computed).every((entry) => typeof entry === 'string');
      if (!hasRect && !hasOverflow && !hasFocus && !hasMotion && !hasComputed) errors.push(`${observationLabel} needs a rect, overflowX, focusVisible, reducedMotion, or string computed value.`);
      observations.push({ viewport: capture.viewport, state: capture.state, locator: observation.locator, rect: observation.rect, overflowX: observation.overflowX, focusVisible: observation.focusVisible, reducedMotion: observation.reducedMotion, computed: observation.computed });
    }
  }
  return { ok: errors.length === 0, errors, observations };
}
/** @returns {Promise<void>} @throws {Error} when the evidence document cannot be read or parsed */
async function main() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) { console.log('Usage: node collect-rendered-evidence.mjs --input <capture.json> [--json]'); return; }
    let value; try { value = JSON.parse(await readFile(resolve(args.input), 'utf8')); } catch (error) { throw new Error(`Invalid evidence JSON: ${error instanceof Error ? error.message : String(error)}`); }
    const result = validate(value);
    if (args.json) console.log(JSON.stringify(result, null, 2)); else console.log(result.ok ? `Validated ${result.observations.length} rendered observations.` : result.errors.join('\n'));
    if (!result.ok) process.exitCode = 1;
  } catch (error) { console.error(JSON.stringify({ ok: false, error: error instanceof Error ? error.message : String(error) })); process.exitCode = 2; }
}
main();
