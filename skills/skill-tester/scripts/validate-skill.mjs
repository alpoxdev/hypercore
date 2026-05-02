#!/usr/bin/env node
import { existsSync, readFileSync, statSync } from 'node:fs';
import { join, dirname, normalize } from 'node:path';

const target = process.argv[2];
if (!target) {
  console.error('Usage: node scripts/validate-skill.mjs <skill-folder>');
  process.exit(2);
}

const skillDir = normalize(target);
const skillPath = join(skillDir, 'SKILL.md');
const failures = [];
const warnings = [];

function fail(message) {
  failures.push(message);
}

function warn(message) {
  warnings.push(message);
}

function countMatches(text, pattern) {
  const matches = text.match(pattern);
  return matches ? matches.length : 0;
}

function countBulletsBetween(text, startPattern, endPattern) {
  const start = text.search(startPattern);
  if (start === -1) return null;
  const rest = text.slice(start);
  const end = rest.slice(1).search(endPattern);
  const section = end === -1 ? rest : rest.slice(0, end + 1);
  return section.split(/\r?\n/).filter((line) => /^\s*-\s+/.test(line)).length;
}

if (!existsSync(skillDir) || !statSync(skillDir).isDirectory()) {
  fail(`Target is not a directory: ${skillDir}`);
} else if (!existsSync(skillPath)) {
  fail(`Missing SKILL.md: ${skillPath}`);
}

let body = '';
if (existsSync(skillPath)) {
  body = readFileSync(skillPath, 'utf8');
  const lines = body.split(/\r?\n/).length;

  if (!body.startsWith('---\n')) fail('SKILL.md must start with YAML frontmatter.');
  if (!/^name:\s*\S+/m.test(body)) fail('Frontmatter is missing name.');
  if (!/^description:\s*['"].+['"]\s*$/m.test(body) && !/^description:\s*\S.+$/m.test(body)) {
    fail('Frontmatter is missing a non-empty description.');
  }
  if (lines > 300) warn(`SKILL.md is long (${lines} lines); consider moving detail to rules or references.`);

  const positiveCount = countMatches(body, /positive examples?|positive trigger|should trigger/gi);
  const negativeCount = countMatches(body, /negative examples?|should not trigger|out-of-scope/gi);
  const boundaryCount = countMatches(body, /boundary examples?|boundary case/gi);

  if (positiveCount < 1) warn('No obvious positive trigger examples section found.');
  if (negativeCount < 1) warn('No obvious negative/out-of-scope examples section found.');
  if (boundaryCount < 1) warn('No obvious boundary example section found.');

  const positiveBullets = countBulletsBetween(body, /positive examples?:/i, /negative examples?:|boundary examples?:|<\/trigger_conditions>/i);
  const negativeBullets = countBulletsBetween(body, /negative examples?:/i, /boundary examples?:|<\/trigger_conditions>/i);
  const boundaryBullets = countBulletsBetween(body, /boundary examples?:/i, /<\/trigger_conditions>/i);
  if (positiveBullets !== null && positiveBullets < 3) warn(`Only ${positiveBullets} positive example bullet(s); recommended minimum is 3.`);
  if (negativeBullets !== null && negativeBullets < 2) warn(`Only ${negativeBullets} negative example bullet(s); recommended minimum is 2.`);
  if (boundaryBullets !== null && boundaryBullets < 1) warn('No boundary example bullet found; recommended minimum is 1.');

  const links = [...body.matchAll(/^@(.+)$/gm)].map((match) => match[1].trim());
  for (const link of links) {
    const resolved = join(dirname(skillPath), link);
    if (!existsSync(resolved)) fail(`Linked support file is missing: ${link}`);
    const depth = link.split('/').filter(Boolean).length;
    if (depth > 2) warn(`Support link is deeper than one level from SKILL.md: ${link}`);
  }

  if (!/<validation[_-]?checklist>|<validation>/i.test(body)) {
    warn('No explicit validation checklist/section found.');
  }
}

const result = failures.length === 0 ? (warnings.length === 0 ? 'pass' : 'pass-with-warnings') : 'fail';
console.log(JSON.stringify({ result, target: skillDir, failures, warnings }, null, 2));
process.exit(failures.length === 0 ? 0 : 1);
