#!/usr/bin/env node

import { readFileSync, writeFileSync } from 'fs';
import { basename } from 'path';
import { convertColor } from './convert.js';
import { formatOutput, formatJson, formatCssResult } from './format.js';
import { replaceCssColors } from './css.js';

const args = process.argv.slice(2);

if (args.length === 0 || args.includes('--help')) {
  console.log(`Usage: color [--json] <color> [color2 ...]
       color css <file> --to <format> [--dry-run]

Examples:
  color "#ff0000"
  color "oklch(0.7 0.25 140)"
  color "rgb(255, 0, 0)"
  color "#e63946" "oklch(0.7 0.25 140)"
  color --json "#ff0000"
  color css style.css --to oklch         # Convert CSS file colors
  color css style.css --to oklch --dry-run  # Preview only`);
  process.exit(0);
}

if (args[0] === 'css') {
  const cssArgs = args.slice(1);
  const toIdx = cssArgs.indexOf('--to');
  const dryRun = cssArgs.includes('--dry-run');

  if (toIdx === -1 || !cssArgs[toIdx + 1]) {
    console.error('Error: --to <format> is required (hex|rgb|oklch)');
    process.exit(1);
  }

  const targetFormat = cssArgs[toIdx + 1] as 'hex' | 'rgb' | 'oklch';
  if (!['hex', 'rgb', 'oklch'].includes(targetFormat)) {
    console.error(`Error: invalid format "${targetFormat}" — must be hex, rgb, or oklch`);
    process.exit(1);
  }

  const filePath = cssArgs.find((a) => !a.startsWith('--') && a !== cssArgs[toIdx + 1]);
  if (!filePath) {
    console.error('Error: file path is required');
    process.exit(1);
  }

  let css: string;
  try {
    css = readFileSync(filePath, 'utf8');
  } catch {
    console.error(`Error: cannot read file "${filePath}"`);
    process.exit(1);
  }

  const { result, summary } = replaceCssColors(css, targetFormat);

  if (!dryRun) {
    writeFileSync(filePath, result, 'utf8');
  }

  console.log(formatCssResult(basename(filePath), summary, dryRun));
  process.exit(0);
}

const jsonMode = args.includes('--json');
const inputs = args.filter((a: string) => a !== '--json');

let exitCode = 0;

for (let i = 0; i < inputs.length; i++) {
  const input = inputs[i];
  if (inputs.length > 1) {
    if (i > 0) console.log();
    console.log(`Input: ${input}`);
  }
  try {
    const result = convertColor(input);
    console.log(jsonMode ? formatJson(result) : formatOutput(result));
  } catch (err) {
    console.error(`Error: ${err instanceof Error ? err.message : String(err)}`);
    exitCode = 1;
  }
}

process.exit(exitCode);
