#!/usr/bin/env bun
// @ts-check
/** Count repeated page-structure signals in supported source files and emit stable JSON. */
import { readFile, readdir, stat } from 'node:fs/promises';
import { extname, relative, resolve } from 'node:path';

const SUPPORTED = new Set(['.html', '.jsx', '.tsx', '.vue', '.svelte']);
const IGNORED = new Set(['.git', 'node_modules', 'dist', 'build', 'coverage', '.next', '.nuxt', '.svelte-kit']);

/** @param {string[]} argv @returns {{ target?: string, help: boolean }} @throws {Error} for unknown arguments or a missing target */
function parseArgs(argv) {
  /** @type {string | undefined} */
  let target;
  for (let index = 0; index < argv.length; index += 1) {
    if (argv[index] === '--target') target = argv[++index];
    else if (argv[index] === '--json') continue;
    else if (argv[index] === '--help' || argv[index] === '-h') return { help: true };
    else throw new Error(`Unknown argument: ${argv[index]}`);
  }
  if (!target) throw new Error('--target requires a path');
  return { target, help: false };
}

/** @param {string} target @returns {Promise<string[]>} @throws {Error} when the target is not a supported file or directory */
async function filesFor(target) {
  const info = await stat(target);
  if (info.isFile()) {
    if (!SUPPORTED.has(extname(target).toLowerCase())) throw new Error(`Unsupported file type: ${extname(target) || '(none)'}`);
    return [target];
  }
  if (!info.isDirectory()) throw new Error('Target must be a file or directory');
  /** @type {string[]} */
  const files = [];
  const stack = [target];
  while (stack.length) {
    const current = stack.pop();
    if (!current) continue;
    for (const entry of await readdir(current, { withFileTypes: true })) {
      const path = resolve(current, entry.name);
      if (entry.isDirectory() && !IGNORED.has(entry.name)) stack.push(path);
      else if (entry.isFile() && SUPPORTED.has(extname(entry.name).toLowerCase())) files.push(path);
    }
  }
  return files.sort();
}

/** @param {string} text @param {RegExp} pattern @returns {number} */
function count(text, pattern) {
  return [...text.matchAll(pattern)].length;
}

/** @returns {Promise<void>} @throws {Error} when the target cannot be scanned */
async function main() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      console.log('Usage: node analyze-structure.mjs --target <file-or-directory> --json');
      return;
    }
    if (!args.target) throw new Error('--target requires a path');
    const target = resolve(args.target);
    const root = (await stat(target)).isDirectory() ? target : resolve(target, '..');
    const files = await filesFor(target);
    const results = [];
    for (const file of files) {
      const text = await readFile(file, 'utf8');
      results.push({
        file: relative(root, file) || file,
        sections: count(text, /<section\b/gi),
        cards: count(text, /\bcard\b/gi),
        eyebrows: count(text, /\b(?:eyebrow|kicker)\b/gi),
        numberedSectionLabels: count(text, /\b(?:section-number|step-number)\b|>\s*0[1-9]\s*</gi),
        iconTiles: count(text, /\bicon-tile\b/gi),
        gridsOfThree: count(text, /\b(?:grid-cols-3|repeat\(\s*3\s*,)/gi),
        headings: count(text, /<h[1-6]\b/gi),
        ctas: count(text, /\b(?:cta|call-to-action)\b/gi),
        navs: count(text, /<nav\b/gi),
        footers: count(text, /<footer\b/gi),
      });
    }
    console.log(JSON.stringify({
      target: args.target,
      version: 2,
      files: results,
      limitations: ['Counts are structural source signals only; they do not determine whether a layout is generic, inappropriate, or safe to change.'],
    }, null, 2));
  } catch (error) {
    console.error(JSON.stringify({ error: error instanceof Error ? error.message : String(error), version: 2 }));
    process.exitCode = 2;
  }
}

main();
