#!/usr/bin/env node
// EN/KO contract parity for instructions/skill/**.
//
// What this checks, and why only this:
//   (a) the set of normative `SK-<letter>-<n>` ids is identical in both languages
//   (b) the `## ` section count is identical
//   (c) each file carries a Sources section with a checked-date line
//   (d) within each section, each letter's numbering runs 1..N with no gaps
//
// What it deliberately does NOT check: section heading TEXT (Korean headings vs English
// headings differ by design), and numerals inside prose (numerals are localized: `primary`
// vs `1차 출처`, `four-part` vs `4절`). Those are not contract-bearing.
//
// Usage: node check-skill-contract-parity.mjs [--root <dir>]
// Exit 0 when PARITY-FAILURES=0, non-zero otherwise.

import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";

const PAIRS = [
  ["SKILL_AUTHORING.md", "SKILL_AUTHORING.ko.md"],
  ["references/trigger-design.md", "references/trigger-design.ko.md"],
  ["references/skill-anatomy.md", "references/skill-anatomy.ko.md"],
  ["references/progressive-disclosure.md", "references/progressive-disclosure.ko.md"],
  ["references/resource-placement.md", "references/resource-placement.ko.md"],
  ["references/prompt-loop-eval.md", "references/prompt-loop-eval.ko.md"],
  ["references/validation.md", "references/validation.ko.md"],
];

const argv = process.argv.slice(2);
const rootIdx = argv.indexOf("--root");
const ROOT = rootIdx >= 0 && argv[rootIdx + 1]
  ? argv[rootIdx + 1]
  : join(import.meta.dirname, "..", "instructions", "skill");

const ID_RE = /^- (SK-[A-Z])-(\d+):/;
const SEC_RE = /^## /;
// Accept both the bare form and the numbered legacy form (prompt-loop-eval.md uses `## 10. Sources`).
const SOURCES_RE = /^## (?:\d+\. )?Sources\s*$/;
const CHECKED_RE = /^> .*(?:checked|확인)\s+\d{4}-\d{2}-\d{2}/i;

let failures = 0;
const fail = (msg) => { failures++; console.log(`FAIL ${msg}`); };

function read(p) {
  if (!existsSync(p)) return null;
  return readFileSync(p, "utf8");
}

function ids(text) {
  const out = [];
  for (const line of text.split("\n")) {
    const m = line.match(ID_RE);
    if (m) out.push(`${m[1]}-${m[2]}`);
  }
  return out;
}

function sections(text) {
  return text.split("\n").filter((l) => SEC_RE.test(l)).length;
}

function sourcesOk(text) {
  const lines = text.split("\n");
  const at = lines.findIndex((l) => SOURCES_RE.test(l));
  if (at < 0) return "no Sources section";
  // The checked-date line sits in the block right after the heading.
  const block = lines.slice(at, at + 6);
  if (!block.some((l) => CHECKED_RE.test(l))) return "Sources section has no checked-date line";
  return null;
}

// (d) within each section, each letter's numbering must be 1..N with no gaps
function numberingGaps(text) {
  const gaps = [];
  let section = "(preamble)";
  const perSection = new Map();
  for (const line of text.split("\n")) {
    if (SEC_RE.test(line)) {
      section = line.trim();
      if (!perSection.has(section)) perSection.set(section, []);
      continue;
    }
    const m = line.match(ID_RE);
    if (m) {
      if (!perSection.has(section)) perSection.set(section, []);
      perSection.get(section).push({ letter: m[1], n: Number(m[2]) });
    }
  }
  for (const [sec, list] of perSection) {
    const byLetter = new Map();
    for (const { letter, n } of list) {
      if (!byLetter.has(letter)) byLetter.set(letter, []);
      byLetter.get(letter).push(n);
    }
    for (const [letter, nums] of byLetter) {
      const sorted = [...nums].sort((a, b) => a - b);
      const expected = Array.from({ length: sorted.length }, (_, i) => i + 1);
      if (sorted.join(",") !== expected.join(",")) {
        gaps.push(`${sec} :: ${letter} has [${sorted.join(",")}], expected [${expected.join(",")}]`);
      }
    }
  }
  return gaps;
}

for (const [enRel, koRel] of PAIRS) {
  const enPath = join(ROOT, enRel);
  const koPath = join(ROOT, koRel);
  const en = read(enPath);
  const ko = read(koPath);
  if (en === null) { fail(`${enRel}: missing`); continue; }
  if (ko === null) { fail(`${koRel}: missing`); continue; }

  const enIds = new Set(ids(en));
  const koIds = new Set(ids(ko));
  for (const id of enIds) if (!koIds.has(id)) fail(`${koRel}: missing id ${id}`);
  for (const id of koIds) if (!enIds.has(id)) fail(`${enRel}: missing id ${id}`);

  const enSec = sections(en);
  const koSec = sections(ko);
  if (enSec !== koSec) fail(`${enRel} has ${enSec} sections, ${koRel} has ${koSec}`);

  for (const [label, text] of [[enRel, en], [koRel, ko]]) {
    const srcErr = sourcesOk(text);
    if (srcErr) fail(`${label}: ${srcErr}`);
    for (const g of numberingGaps(text)) fail(`${label}: ${g}`);
  }
}

console.log(`PARITY-FAILURES=${failures}`);
process.exit(failures === 0 ? 0 : 1);
