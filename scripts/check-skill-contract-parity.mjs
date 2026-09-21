#!/usr/bin/env node
// EN/KO contract parity for the instruction and skill contract trees.
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
// Four pair sets, each with its OWN root. A single global root cannot address several trees, and
// silently moving the global root would check the wrong tree for one of them - so every pair carries
// its root explicitly. `--root` addresses the instruction set; `--root-skills` keeps its historical
// meaning as the skill-maker root, and additionally overrides the selected skill set when exactly one
// skill set is selected, so no previously supported invocation changes meaning.
//
// The docs-maker and prompt-maker sets are EXPLICIT single pairs (SKILL.md / SKILL.ko.md), declared
// the same way INSTRUCTION_PAIRS is, rather than discovered by walking the root. Discovering them
// would pull in rules/**, references/**, and assets/**, and requirement (c) would then demand a
// Sources section with a checked date in 42 files - a content-authoring project, not a contract fix.
// Extending those two sets to their full trees requires adding a Sources section to those files first.
//
// Usage:
//   node check-skill-contract-parity.mjs [--root <dir>] [--root-skills <dir>] [--set <name>] [--list]
//
//   --root <dir>        root of the instructions/skill pair set (default: ../instructions/skill)
//   --root-skills <dir> skill-set root override: the skill-maker root when no set is selected, and
//                       the selected set's own root when exactly one skill set is selected
//   --set <name>        restrict to one set: instructions-skill | skill-maker | docs-maker | prompt-maker
//                       (default: all)
//   --list              print one line per pair as set<TAB>root<TAB>en<TAB>ko, then exit 0
//
// Exit 0 when PARITY-FAILURES=0, non-zero otherwise.

import { readFileSync, existsSync, readdirSync, statSync, realpathSync } from "node:fs";
import { join, relative } from "node:path";

const REPO_ROOT = join(import.meta.dirname, "..");

/** The instruction set. Retained exactly as it was, so its behaviour does not change. */
const INSTRUCTION_PAIRS = [
  ["SKILL_AUTHORING.md", "SKILL_AUTHORING.ko.md"],
  ["references/trigger-design.md", "references/trigger-design.ko.md"],
  ["references/skill-anatomy.md", "references/skill-anatomy.ko.md"],
  ["references/progressive-disclosure.md", "references/progressive-disclosure.ko.md"],
  ["references/resource-placement.md", "references/resource-placement.ko.md"],
  ["references/prompt-loop-eval.md", "references/prompt-loop-eval.ko.md"],
  ["references/validation.md", "references/validation.ko.md"],
];

const argv = process.argv.slice(2);
/** @param {string} flag @returns {string | null} */
function flagValue(flag) {
  const at = argv.indexOf(flag);
  // Return the value whenever the position exists, even when it is the empty string. Treating "" as
  // absent let an explicitly empty value fall through to the default and look like a normal run.
  return at >= 0 && argv[at + 1] !== undefined ? argv[at + 1] : null;
}

// Argument validation. A verification command whose typo still reports success is worse than one that
// crashes: `--set skill-mkaer` used to select ZERO pairs and print PARITY-FAILURES=0, and a value-less
// `--root-skills` silently fell back to the default root. Both are false green.
/**
 * Every skill pair set, with its own default root. `discovered` sets derive their pairs from the
 * tree; the others use EXPLICIT_SKILL_PAIRS.
 * @type {Record<string, { root: string, discovered: boolean }>}
 */
const SKILL_SETS = {
  "skill-maker": { root: "skills/skill-maker", discovered: true },
  "docs-maker": { root: "skills/docs-maker", discovered: false },
  "prompt-maker": { root: "skills/prompt-maker", discovered: false },
};
/** Explicit single-pair skill sets, declared exactly as INSTRUCTION_PAIRS is. */
const EXPLICIT_SKILL_PAIRS = {
  "docs-maker": [["SKILL.md", "SKILL.ko.md"]],
  "prompt-maker": [["SKILL.md", "SKILL.ko.md"]],
};
const ALLOWED_SETS = ["instructions-skill", ...Object.keys(SKILL_SETS)];
const VALUE_FLAGS = ["--root", "--root-skills", "--set"];
const KNOWN_FLAGS = [...VALUE_FLAGS, "--list"];

const problems = [];

// A repeated value flag is ambiguous, so it is rejected outright. This also closes the class of bug
// where only the FIRST occurrence was ever validated: `--set instructions-skill --set skill-mkaer`
// selected a valid set and reported success while the malformed duplicate went unread.
for (const flag of VALUE_FLAGS) {
  const count = argv.filter((arg) => arg === flag).length;
  if (count > 1) problems.push(`${flag} was given ${count} times; it may appear at most once`);
}

// Validate EVERY occurrence by walking the arguments in order, rather than looking up the first match
// with indexOf. Any argument that is neither a known flag nor the value of one is rejected - including
// stray positionals, which the earlier version silently ignored.
const valuePositions = new Set();
for (let i = 0; i < argv.length; i++) {
  if (VALUE_FLAGS.includes(argv[i]) && argv[i + 1] !== undefined && !argv[i + 1].startsWith("-")) {
    valuePositions.add(i + 1);
  }
}
for (let i = 0; i < argv.length; i++) {
  const arg = argv[i];
  if (VALUE_FLAGS.includes(arg)) {
    const next = argv[i + 1];
    if (next === undefined || next.startsWith("-")) problems.push(`${arg} requires a value`);
    else if (next === "") problems.push(`${arg} requires a non-empty value`);
    continue;
  }
  if (valuePositions.has(i)) continue;
  if (!KNOWN_FLAGS.includes(arg)) {
    problems.push(arg.startsWith("-") ? `unknown option: ${arg}` : `unexpected argument: ${arg}`);
  }
}

const requestedSet = flagValue("--set");
if (requestedSet !== null && !ALLOWED_SETS.includes(requestedSet)) {
  problems.push(`--set must be one of ${ALLOWED_SETS.join(" | ")}, got "${requestedSet}"`);
}
if (problems.length > 0) {
  for (const problem of problems) console.error(`ARGUMENT-ERROR: ${problem}`);
  console.error(`Usage: node check-skill-contract-parity.mjs [--root <dir>] [--root-skills <dir>] [--set ${ALLOWED_SETS.join("|")}] [--list]`);
  process.exit(2);
}

// `??` rather than `||`: an empty value must never silently fall back to a default, and it is
// rejected below anyway. Defence in depth, so a future edit cannot reopen the false green.
const instructionRoot = flagValue("--root") ?? join(import.meta.dirname, "..", "instructions", "skill");
const onlySet = requestedSet;
const skillsRootOverride = flagValue("--root-skills");
/** Skill sets the current `--set` selects: the one named, or all of them when none is named. */
const selectedSkillSets = onlySet === null
  ? Object.keys(SKILL_SETS)
  : (onlySet in SKILL_SETS ? [onlySet] : []);
/**
 * `--root-skills` keeps its historical meaning in every previously supported invocation: with no
 * `--set` it overrides the skill-maker root only, and with `--set skill-maker` it overrides that set.
 * It additionally overrides the selected skill set when exactly one skill set is selected, which is
 * what makes `--set docs-maker --root-skills <temp-tree>` possible. It is never an error merely
 * because zero or several skill sets are selected.
 */
const skillSetRoots = {};
for (const [name, spec] of Object.entries(SKILL_SETS)) {
  const overrideApplies = skillsRootOverride !== null
    && (selectedSkillSets.length === 1 ? selectedSkillSets[0] === name : name === "skill-maker");
  skillSetRoots[name] = overrideApplies ? skillsRootOverride : join(REPO_ROOT, spec.root);
}

/** A sibling must be a regular file, not merely a path that exists. */
function isRegularFile(p) {
  try {
    return statSync(p).isFile();
  } catch {
    return false;
  }
}

/**
 * Discover the EN/KO markdown pairs under a skill root, so the pair count is derived from the tree
 * rather than written down. A file whose sibling is missing is returned as an orphan in EITHER
 * direction rather than skipped, and symlinks are followed rather than ignored: `readdirSync`'s
 * Dirent reports a symlink as neither a file nor a directory, so a symlinked .md or a symlinked
 * directory used to be skipped in silence. A visited-realpath set bounds symlink loops.
 * @param {string} root
 * @returns {{ pairs: Array<[string, string]>, orphans: Array<{ path: string, reason: string }> }}
 */
function discoverPairs(root) {
  /** @type {Array<[string, string]>} */
  const pairs = [];
  /** @type {Array<{ path: string, reason: string }>} */
  const orphans = [];
  /** @type {Set<string>} */
  const seenDirs = new Set();
  /** @param {string} p @returns {string} */
  const relOf = (p) => relative(root, p).split("\\").join("/");
  /** @param {string} dir */
  const walk = (dir) => {
    if (!existsSync(dir)) return;
    let real = dir;
    try {
      real = realpathSync(dir);
    } catch {
      // fall through with the literal path
    }
    if (seenDirs.has(real)) return; // symlink loop or a directory reachable twice
    seenDirs.add(real);
    /** @type {import("node:fs").Dirent[]} */
    let entries;
    try {
      entries = readdirSync(dir, { withFileTypes: true });
    } catch (error) {
      orphans.push({ path: relOf(dir) || ".", reason: `unreadable directory (${error instanceof Error ? error.message : String(error)})` });
      return;
    }
    for (const entry of entries) {
      const full = join(dir, entry.name);
      let isDir = entry.isDirectory();
      let isFile = entry.isFile();
      if (entry.isSymbolicLink()) {
        try {
          const target = statSync(full); // follows the link
          isDir = target.isDirectory();
          isFile = target.isFile();
        } catch {
          orphans.push({ path: relOf(full), reason: "broken symlink" });
          continue;
        }
      }
      if (isDir) {
        walk(full);
        continue;
      }
      if (!isFile || !entry.name.endsWith(".md")) continue;
      const rel = relOf(full);
      // The sibling must be a REGULAR FILE, not merely a path that exists: a directory or a
      // directory symlink named `x.md` would otherwise satisfy the check while providing no mirror.
      if (entry.name.endsWith(".ko.md")) {
        const enRel = rel.slice(0, -6) + ".md";
        if (!isRegularFile(join(root, enRel))) orphans.push({ path: rel, reason: "no EN sibling" });
        continue;
      }
      const koRel = rel.slice(0, -3) + ".ko.md";
      if (isRegularFile(join(root, koRel))) pairs.push([rel, koRel]);
      else orphans.push({ path: rel, reason: "no KO mirror" });
    }
  };
  walk(root);
  return {
    pairs: pairs.sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0)),
    orphans: orphans.sort((a, b) => (a.path < b.path ? -1 : a.path > b.path ? 1 : 0)),
  };
}

/** @type {Array<{ set: string, root: string, en: string, ko: string }>} */
const pairs = [];
// Validate the roots directly, before anything is checked or listed. Counting pairs is not enough:
// the instruction set is static, so it appears to exist even when its root does not, and `--list`
// would then print seven pairs under a nonexistent root and exit 0. A root is validated when it will
// be USED or when it was EXPLICITLY given: `--set skill-maker --root /nonexistent` still names a bad
// path, so selecting a set must not exempt the other root from validation.
const explicitRoot = flagValue("--root") !== null;
const explicitSkillsRoot = skillsRootOverride !== null;
for (const [name, root, explicit] of [
  ["instructions-skill", instructionRoot, explicitRoot],
  ...Object.keys(SKILL_SETS).map((name) => [name, skillSetRoots[name], explicitSkillsRoot]),
]) {
  if (!explicit && onlySet && onlySet !== name) continue;
  if (!existsSync(root) || !statSync(root).isDirectory()) {
    console.error(`ARGUMENT-ERROR: the ${name} root is not an existing directory: ${root}`);
    process.exit(2);
  }
  // A root that exists but cannot be listed would crash mid-check instead of reporting a clear cause.
  try {
    readdirSync(root);
  } catch (error) {
    console.error(`ARGUMENT-ERROR: the ${name} root is not readable: ${root} (${error instanceof Error ? error.message : String(error)})`);
    process.exit(2);
  }
}

for (const [en, ko] of INSTRUCTION_PAIRS) {
  pairs.push({ set: "instructions-skill", root: instructionRoot, en, ko });
}
const discovered = discoverPairs(skillSetRoots["skill-maker"]);
for (const [en, ko] of discovered.pairs) {
  pairs.push({ set: "skill-maker", root: skillSetRoots["skill-maker"], en, ko });
}
for (const [name, list] of Object.entries(EXPLICIT_SKILL_PAIRS)) {
  for (const [en, ko] of list) {
    pairs.push({ set: name, root: skillSetRoots[name], en, ko });
  }
}

// Every configured set must yield at least one pair. A wrong root makes a whole set vanish silently,
// and without this check `--root-skills /nonexistent` would check only the instruction set and still
// report PARITY-FAILURES=0 - the same false green in a new place.
for (const name of onlySet ? [onlySet] : ["instructions-skill", ...Object.keys(SKILL_SETS)]) {
  if (!pairs.some((pair) => pair.set === name)) {
    const root = name === "instructions-skill" ? instructionRoot : skillSetRoots[name];
    console.error(`ARGUMENT-ERROR: the ${name} set has no pairs; its root looks wrong (${root})`);
    process.exit(2);
  }
}

const selected = onlySet ? pairs.filter((pair) => pair.set === onlySet) : pairs;

// A valid set is never empty; an empty selection would report success while checking nothing.
if (selected.length === 0) {
  console.error(`ARGUMENT-ERROR: the selection matched no pairs (set=${onlySet ?? "all"})`);
  process.exit(2);
}

let failures = 0;
const fail = (msg) => { failures++; console.log(`FAIL ${msg}`); };

// A file whose sibling is missing is a parity failure, not something to skip. Checked BEFORE the
// --list early exit, so listing a broken tree cannot report success either.
for (const orphan of discovered.orphans) {
  fail(`skill-maker:${orphan.path}: ${orphan.reason}`);
}

// Every selected pair must resolve to real files before anything is listed or checked. The instruction
// set is a hardcoded list, so a deleted sibling there was only noticed in the main loop - which runs
// after the --list early exit, letting `--list` print a pair whose KO file did not exist and exit 0.
// Broken pairs are recorded so the main loop does not report them twice.
/** @type {Set<object>} */
const brokenPairs = new Set();
for (const pair of selected) {
  for (const rel of [pair.en, pair.ko]) {
    if (!isRegularFile(join(pair.root, rel))) {
      fail(`${pair.set}:${pair.en}: ${rel} is missing or not a regular file`);
      brokenPairs.add(pair);
    }
  }
}

if (argv.includes("--list")) {
  for (const pair of selected) {
    console.log([pair.set, pair.root, pair.en, pair.ko].join("\t"));
  }
  process.exit(failures === 0 ? 0 : 1);
}

const ID_RE = /^- (SK-[A-Z])-(\d+):/;
const SEC_RE = /^## /;
// Accept both the bare form and the numbered legacy form (prompt-loop-eval.md uses `## 10. Sources`).
const SOURCES_RE = /^## (?:\d+\. )?Sources\s*$/;
const CHECKED_RE = /^> .*(?:checked|확인)\s+\d{4}-\d{2}-\d{2}/i;

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

for (const pair of selected) {
  if (brokenPairs.has(pair)) continue; // already reported before the --list early exit
  const label = `${pair.set}:${pair.en}`;
  const en = read(join(pair.root, pair.en));
  const ko = read(join(pair.root, pair.ko));
  if (en === null) { fail(`${label}: missing`); continue; }
  if (ko === null) { fail(`${label}: ${pair.ko} missing`); continue; }

  const enIds = new Set(ids(en));
  const koIds = new Set(ids(ko));
  for (const id of enIds) if (!koIds.has(id)) fail(`${label}: ${pair.ko} missing id ${id}`);
  for (const id of koIds) if (!enIds.has(id)) fail(`${label}: ${pair.en} missing id ${id}`);

  const enSec = sections(en);
  const koSec = sections(ko);
  if (enSec !== koSec) fail(`${label}: ${pair.en} has ${enSec} sections, ${pair.ko} has ${koSec}`);

  for (const [name, text] of [[pair.en, en], [pair.ko, ko]]) {
    const srcErr = sourcesOk(text);
    if (srcErr) fail(`${label}: ${name}: ${srcErr}`);
    for (const g of numberingGaps(text)) fail(`${label}: ${name}: ${g}`);
  }
}

console.log(`PARITY-FAILURES=${failures}`);
process.exit(failures === 0 ? 0 : 1);
