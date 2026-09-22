#!/usr/bin/env bun
// @ts-check
/** Validate an optional .ai-slop-remover.json waiver document against the rule registry. */
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { RULE_BY_ID } from './rule-registry.mjs';

const SOURCES = ['user-confirmed', 'documented-brand', 'fixture', 'generated-output'];
const WAIVER_KEYS = ['ruleId', 'value', 'file', 'reason', 'source', 'reviewAfter'];

/** @param {unknown} value @returns {value is Record<string, unknown>} */
function isRecord(value) { return typeof value === 'object' && value !== null && !Array.isArray(value); }
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
/** @param {unknown} value @returns {boolean} */
function validDate(value) { return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value) && !Number.isNaN(Date.parse(`${value}T00:00:00Z`)); }
/** @param {unknown} value @returns {{ ok: boolean, errors: string[] }} */
function validate(value) {
  /** @type {string[]} */
  const errors = [];
  if (!isRecord(value)) return { ok: false, errors: ['Waiver document must be an object.'] };
  if (value.version !== 1) errors.push('version must equal 1.');
  if (!Array.isArray(value.waivers)) errors.push('waivers must be an array.');
  const waivers = /** @type {unknown[]} */ (value.waivers ?? []);
  for (const [index, waiver] of waivers.entries()) {
    const label = `waivers[${index}]`;
    if (!isRecord(waiver)) { errors.push(`${label} must be an object.`); continue; }
    const ruleId = waiver.ruleId;
    if (typeof ruleId !== 'string' || !RULE_BY_ID.has(ruleId)) errors.push(`${label}.ruleId must name a known rule.`);
    if (typeof waiver.reason !== 'string' || !waiver.reason.trim()) errors.push(`${label}.reason must be non-empty.`);
    const source = waiver.source;
    if (typeof source !== 'string' || !SOURCES.includes(source)) errors.push(`${label}.source is invalid.`);
    const valueField = waiver.value;
    const fileField = waiver.file;
    const hasValue = typeof valueField === 'string' && valueField.trim();
    const hasFile = typeof fileField === 'string' && fileField.trim();
    if (Boolean(hasValue) === Boolean(hasFile)) errors.push(`${label} requires exactly one of value or file.`);
    if (typeof fileField === 'string' && fileField && (fileField === '*' || fileField.includes('**'))) errors.push(`${label}.file must be a narrow file path, not a broad glob.`);
    if (waiver.reviewAfter !== undefined && !validDate(waiver.reviewAfter)) errors.push(`${label}.reviewAfter must be an absolute valid YYYY-MM-DD date.`);
    for (const key of Object.keys(waiver)) if (!WAIVER_KEYS.includes(key)) errors.push(`${label}.${key} is not allowed.`);
  }
  return { ok: errors.length === 0, errors };
}
/** @returns {Promise<void>} @throws {Error} when the waiver document cannot be read or parsed */
async function main() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) { console.log('Usage: node validate-waivers.mjs --input <.ai-slop-remover.json> [--json]'); return; }
    let value; try { value = JSON.parse(await readFile(resolve(args.input), 'utf8')); } catch (error) { throw new Error(`Invalid waiver JSON: ${error instanceof Error ? error.message : String(error)}`); }
    const result = validate(value);
    if (args.json) console.log(JSON.stringify(result, null, 2)); else console.log(result.ok ? 'Waiver document is valid.' : result.errors.join('\n'));
    if (!result.ok) process.exitCode = 1;
  } catch (error) { console.error(JSON.stringify({ ok: false, error: error instanceof Error ? error.message : String(error) })); process.exitCode = 2; }
}
main();
