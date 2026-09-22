#!/usr/bin/env bun
// @ts-check
/** Run the report/waiver/rendered-evidence contract cases and report per-case exit-code agreement. */
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const DEFAULT_CASES = 'skills/ai-design-slop-remover/assets/evals/contract-cases.jsonl';
/** @type {Record<string, string>} */
const COMMANDS = {
  report: 'skills/ai-design-slop-remover/scripts/validate-report.mjs',
  waiver: 'skills/ai-design-slop-remover/scripts/validate-waivers.mjs',
  rendered: 'skills/ai-design-slop-remover/scripts/collect-rendered-evidence.mjs',
};

/** @typedef {{ id: string, command: string, input: string, expectedExit: number, expectedError?: string }} ContractCase */

/** @param {string[]} argv @returns {{ help: true } | { help: false, cases: string, json: boolean }} @throws {Error} for unknown arguments or a missing case path */
function parseArgs(argv) {
  let cases = DEFAULT_CASES; let json = false;
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--cases') { cases = argv[++index]; if (!cases || cases.startsWith('--')) throw new Error('--cases requires a path'); }
    else if (arg === '--json') json = true;
    else if (arg === '--help' || arg === '-h') return { help: true };
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return { help: false, cases, json };
}
/** @param {string} text @returns {ContractCase[]} @throws {Error} when a line is not a complete contract case */
function parseCases(text) {
  return text.split(/\r?\n/).filter(Boolean).map((line, index) => {
    let value; try { value = JSON.parse(line); } catch (error) { throw new Error(`Invalid JSONL at line ${index + 1}: ${error instanceof Error ? error.message : String(error)}`); }
    if (!value || typeof value !== 'object' || typeof value.id !== 'string' || !COMMANDS[value.command] || typeof value.input !== 'string' || !Number.isInteger(value.expectedExit)) throw new Error(`Invalid case at line ${index + 1}`);
    return value;
  });
}
/** @param {string} command @param {string} script @param {string} input @returns {Promise<{ code: number, stdout: string, stderr: string }>} */
async function run(command, script, input) {
  const flag = command === 'report' ? '--report' : '--input';
  const child = Bun.spawn({ cmd: [process.execPath, script, flag, input, '--json'], cwd: process.cwd(), env: process.env, stdout: 'pipe', stderr: 'pipe' });
  const [code, stdout, stderr] = await Promise.all([child.exited, new Response(child.stdout).text(), new Response(child.stderr).text()]);
  return { code: code ?? 2, stdout, stderr };
}
/** @returns {Promise<void>} */
async function main() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) { console.log('Usage: node run-contract-evals.mjs [--cases <cases.jsonl>] [--json]'); return; }
    const cases = parseCases(await readFile(resolve(args.cases), 'utf8'));
    /** @type {{ id: string, ok: boolean, failures: string[] }[]} */
    const results = [];
    for (const testCase of cases) {
      const script = COMMANDS[testCase.command];
      const result = await run(testCase.command, script, testCase.input);
      const output = `${result.stdout}\n${result.stderr}`;
      /** @type {string[]} */
      const failures = [];
      if (result.code !== testCase.expectedExit) failures.push(`Expected exit ${testCase.expectedExit}, received ${result.code}`);
      if (testCase.expectedError && !output.includes(testCase.expectedError)) failures.push(`Missing expected error: ${testCase.expectedError}`);
      results.push({ id: testCase.id, ok: failures.length === 0, failures });
    }
    const output = { ok: results.every((result) => result.ok), cases: results };
    if (args.json) console.log(JSON.stringify(output, null, 2)); else for (const result of results) console.log(`${result.ok ? 'PASS' : 'FAIL'} ${result.id}${result.failures.length ? `: ${result.failures.join('; ')}` : ''}`);
    if (!output.ok) process.exitCode = 1;
  } catch (error) { console.error(JSON.stringify({ ok: false, error: error instanceof Error ? error.message : String(error) })); process.exitCode = 2; }
}
main();
