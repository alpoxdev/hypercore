#!/usr/bin/env node
import { readFileSync, writeFileSync } from 'node:fs';
import { basename } from 'node:path';

const [, , inputPath, outputPath] = process.argv;
if (!inputPath || !outputPath) {
  console.error('Usage: node render-planning-map.mjs <diagram.data.json> <diagram.svg>');
  process.exit(1);
}

const data = JSON.parse(readFileSync(inputPath, 'utf8'));
const branches = Array.isArray(data.branches) ? data.branches : [];
const width = 1400;
const branchGap = 180;
const height = Math.max(760, 160 + branches.length * branchGap);
const root = { x: 130, y: height / 2, w: 250, h: 76 };
const cardW = 285;
const cardH = 86;
const childW = 235;
const childH = 54;
const branchX = 560;
const childX = 980;

function esc(value = '') {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function wrap(text, max = 34) {
  const words = String(text || '').split(/\s+/).filter(Boolean);
  const lines = [];
  let line = '';
  for (const word of words) {
    if ((line + ' ' + word).trim().length > max && line) {
      lines.push(line);
      line = word;
    } else {
      line = (line + ' ' + word).trim();
    }
  }
  if (line) lines.push(line);
  return lines.slice(0, 2);
}

function textLines(lines, x, y, opts = {}) {
  const size = opts.size || 16;
  const weight = opts.weight || 500;
  const fill = opts.fill || '#222';
  return lines.map((line, i) => `<text x="${x}" y="${y + i * (size + 5)}" font-size="${size}" font-weight="${weight}" fill="${fill}">${esc(line)}</text>`).join('\n');
}

function card(x, y, w, h, title, subtitle, accent = '#ff5b6e') {
  const titleLines = wrap(title, 26);
  const subtitleLines = wrap(subtitle, 42);
  return `
  <g filter="url(#shadow)">
    <rect x="${x}" y="${y}" width="${w}" height="${h}" rx="10" fill="#fff" stroke="#ececf1"/>
    <rect x="${x + 18}" y="${y + 18}" width="8" height="8" rx="2" fill="${accent}"/>
    ${textLines(titleLines, x + 34, y + 27, { size: 16, weight: 700, fill: '#24242b' })}
    ${textLines(subtitleLines, x + 22, y + 56, { size: 11, weight: 400, fill: '#737380' })}
  </g>`;
}

function connector(x1, y1, x2, y2) {
  const c1 = x1 + Math.max(80, (x2 - x1) * 0.45);
  const c2 = x2 - Math.max(80, (x2 - x1) * 0.45);
  return `<path d="M ${x1} ${y1} C ${c1} ${y1}, ${c2} ${y2}, ${x2} ${y2}" fill="none" stroke="#cfd0d7" stroke-width="2"/>`;
}

const palette = ['#ff5b6e', '#f59e0b', '#8b5cf6', '#06b6d4', '#22c55e', '#64748b'];
const top = (height - (branches.length - 1) * branchGap) / 2;
const branchYs = branches.map((_, i) => top + i * branchGap);

let svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
  <defs>
    <pattern id="dots" width="18" height="18" patternUnits="userSpaceOnUse">
      <circle cx="1" cy="1" r="1" fill="#e7e7ec"/>
    </pattern>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="150%">
      <feDropShadow dx="0" dy="8" stdDeviation="10" flood-color="#111827" flood-opacity="0.10"/>
    </filter>
  </defs>
  <rect width="100%" height="100%" fill="#fafafa"/>
  <rect width="100%" height="100%" fill="url(#dots)" opacity="0.75"/>
  <text x="40" y="52" font-size="18" font-weight="700" fill="#2a2a31">${esc(data.subtitle || 'Planning package map')}</text>
`;

for (let i = 0; i < branches.length; i++) {
  svg += `  ${connector(root.x + root.w, root.y + root.h / 2, branchX, branchYs[i] + cardH / 2)}\n`;
}

svg += card(root.x, root.y, root.w, root.h, data.title || basename(inputPath), 'Central product idea', '#ff5b6e');

for (let i = 0; i < branches.length; i++) {
  const b = branches[i];
  const y = branchYs[i];
  const accent = palette[i % palette.length];
  svg += card(branchX, y, cardW, cardH, b.label, b.summary, accent);
  const children = Array.isArray(b.children) ? b.children.slice(0, 4) : [];
  const childTop = y + cardH / 2 - ((children.length - 1) * 68) / 2 - childH / 2;
  for (let j = 0; j < children.length; j++) {
    const cy = childTop + j * 68;
    svg += `  ${connector(branchX + cardW, y + cardH / 2, childX, cy + childH / 2)}\n`;
    svg += card(childX, cy, childW, childH, children[j], '', accent);
  }
}

svg += '</svg>\n';
writeFileSync(outputPath, svg);
console.log(`Rendered ${outputPath}`);
