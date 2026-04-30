#!/usr/bin/env node
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const [, , packageDirArg, outputArg] = process.argv;
if (!packageDirArg) {
  console.error('Usage: node build-preview.mjs <package-dir> [preview.html]');
  process.exit(1);
}

const scriptDir = dirname(fileURLToPath(import.meta.url));
const skillDir = resolve(scriptDir, '..');
const packageDir = resolve(packageDirArg);
const outputPath = resolve(outputArg || join(packageDir, 'preview.html'));
const templatePath = join(skillDir, 'assets', 'preview.template.html');
const template = readFileSync(templatePath, 'utf8');

const docSpecs = [
  ['prd', 'PRD', 'prd.md'],
  ['diagram', 'Diagram Source', 'diagram.md'],
  ['featureSpec', 'Feature Spec', 'feature-spec.md'],
  ['userFlow', 'User Flow', 'user-flow.md'],
  ['wireframe', 'Wireframe', 'wireframe.md'],
  ['sources', 'Sources', 'sources.md']
];

function readMaybe(path) {
  return existsSync(path) ? readFileSync(path, 'utf8') : '';
}

const documents = docSpecs.map(([id, label, path]) => ({
  id,
  label,
  path,
  content: readMaybe(join(packageDir, path))
}));

const prd = documents.find((doc) => doc.id === 'prd')?.content || '';
const titleMatch = prd.match(/^#\s+(.+)$/m);
const diagramSvg = readMaybe(join(packageDir, 'diagram.svg'));
const hasFlow = existsSync(join(packageDir, 'flow.json'));
const openQuestionCount = documents.reduce((count, doc) => count + (doc.content.match(/^- \[ \]/gm) || []).length, 0);

const payload = {
  title: titleMatch ? titleMatch[1].replace(/\s+PRD$/i, '') : basename(packageDir),
  slug: basename(packageDir),
  generatedAt: new Date().toISOString(),
  hasFlow,
  openQuestionCount,
  diagramSvg,
  documents
};

const safeJson = JSON.stringify(payload).replace(/</g, '\\u003c');
const html = template
  .replaceAll('{{TITLE}}', escapeHtmlAttr(payload.title))
  .replace('{{PACKAGE_JSON}}', safeJson);

writeFileSync(outputPath, html);
console.log(`Built ${outputPath}`);

function escapeHtmlAttr(value) {
  return String(value).replace(/[&<>"]/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[ch]));
}
