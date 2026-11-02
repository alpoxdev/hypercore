#!/usr/bin/env bun
// @ts-check

/** Validate the approved bash skill-script inventory and safety boundaries. */
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { basename, dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const manifestPath = join(root, "scripts/fixtures/skill-script-parity/manifest.json");
const behaviorContractsPath = join(root, "scripts/fixtures/skill-script-parity/behavior/contracts.json");
const skillsPath = join(root, "skills");
const expectedForbiddenLiterals = ["git-commit-detect", ".agents/skills/git-commit", ".claude/skills/git-commit", ".codex/skills/git-commit", "installed|", "missing|"];
const expectedScanTargets = ["skills/version-update", "scripts/fixtures/skill-script-parity/behavior"];
const expectedEnforcementFiles = ["scripts/fixtures/skill-script-parity/manifest.json", "scripts/validate-skills.mjs", "scripts/tests/skill-scripts.test.mjs"];

/**
 * Approved in-shell `source` edges, keyed by script path. A bash script may source another skill
 * script only when this map names that exact pair; everything else must be a self-contained script.
 * @type {Map<string, string[]>}
 */
const approvedSourceEdges = new Map([
  ["skills/ai-design-slop-remover/scripts/analyze-structure.sh", ["rule-shared.sh"]],
  ["skills/ai-design-slop-remover/scripts/detect-slop.sh", ["engine-css.sh", "engine-markup.sh", "engine-text.sh", "resolve-context.sh", "rule-shared.sh"]],
  ["skills/ai-design-slop-remover/scripts/validate-waivers.sh", ["rule-registry.sh"]],
  ["skills/ai-design-slop-remover/scripts/engine-css.sh", ["engine-text.sh"]],
  ["skills/ai-design-slop-remover/scripts/engine-markup.sh", ["engine-text.sh"]],
  ["skills/ai-design-slop-remover/scripts/engine-text.sh", ["rule-shared.sh"]],
  ["skills/ai-design-slop-remover/scripts/resolve-context.sh", ["rule-shared.sh"]],
  ["skills/ai-design-slop-remover/scripts/rule-shared.sh", ["rule-registry.sh"]],
]);

/**
 * Approved child-script edges, keyed by script path. A ported script may execute a sibling script
 * from its own directory only when this map names that pair; the value is the set of basenames.
 * @type {Map<string, string[]>}
 */
const approvedChildScripts = new Map([
  ["skills/ai-design-slop-remover/scripts/run-contract-evals.sh", ["collect-rendered-evidence.sh", "validate-report.sh", "validate-waivers.sh"]],
  ["skills/ai-design-slop-remover/scripts/run-detector-evals.sh", ["detect-slop.sh"]],
  ["skills/pre-deploy/scripts/build-run.sh", ["pm-detect.sh", "stack-detect.sh"]],
  ["skills/pre-deploy/scripts/deploy-check.sh", ["build-run.sh", "lint-check.sh", "stack-detect.sh"]],
  ["skills/pre-deploy/scripts/lint-check.sh", ["pm-detect.sh", "stack-detect.sh"]],
  ["skills/version-update/scripts/version-apply.sh", ["version-find.sh"]],
  ["skills/version-update/scripts/version-current.sh", ["version-find.sh"]],
]);

/** @param {string} directory @returns {string[]} */
function filesBelow(directory) {
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const file = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...filesBelow(file));
    else if (entry.isFile()) files.push(file);
  }
  return files;
}

/** @param {boolean} condition @param {string} message @returns {asserts condition} */
function assert(condition, message) {
  if (!condition) throw new Error(message);
}

/** @param {string[]} values @returns {string[]} */
function sorted(values) { return [...values].sort((left, right) => left.localeCompare(right)); }
/** @param {string[]} left @param {string[]} right @returns {boolean} */
function sameList(left, right) { return JSON.stringify(sorted(left)) === JSON.stringify(sorted(right)); }
/** @param {unknown} value @returns {value is Record<string, unknown>} */
function isRecord(value) { return typeof value === "object" && value !== null && !Array.isArray(value); }
/** @param {unknown} value @returns {value is string} */
function nonEmpty(value) { return typeof value === "string" && value.trim() !== ""; }
/** @param {string} path @returns {boolean} */
function existsInBaseline(path) {
  try { execFileSync("git", ["cat-file", "-e", `990359457e2ccbf2bd4bb65065037d456c5940bc:${path}`], { cwd: root, stdio: "ignore" }); return true; } catch { return false; }
}

/**
 * Full-line comments are ignored so policy words inside documentation cannot trip or hide a check.
 *
 * @param {string} content
 * @returns {string[]}
 */
function codeLines(content) {
  return content.split("\n").filter((line) => !line.trimStart().startsWith("#"));
}

/**
 * Skill scripts are bash files that run on macOS 3.2 and Linux 4/5, and never delegate to another
 * interpreter. The checks below are the policy a regression would actually break: shebang, mode,
 * `eval`, foreign interpreter invocation, and escaped `.mjs`/`.cjs` leftovers.
 *
 * @param {string} content
 * @param {string} file
 * @param {number} mode
 * @returns {void}
 */
function validateBashPolicy(content, file, mode) {
  assert(content.startsWith("#!/usr/bin/env bash\n") || content.startsWith("#!/usr/bin/env bash\r\n"), `${file} must use the bash shebang`);
  assert((mode & 0o111) !== 0, `${file} must be executable`);
  const code = codeLines(content).join("\n");
  assert(!/(?:^|[;&|(`]|\$\()\s*eval(?=[\s"'$])/mu.test(code), `${file} must not use eval`);
  assert(!/(?:^|[;&|(`]|\$\()\s*(?:bun|node|nodejs|deno|python[0-9.]*|perl|ruby)\s+(?:[^\n;&|]*\.(?:mjs|cjs|js|mts|cts|ts|py|rb|pl)\b|(?:-e|-c|--eval)\b)/mu.test(code), `${file} must not run JavaScript or Python interpreters on a script`);
  assert(!/^[ \t]*declare[ \t]+-A\b/mu.test(code), `${file} must not use bash 4 associative arrays`);
  assert(!/\b(?:mapfile|readarray)\b/u.test(code), `${file} must not use bash 4 array readers`);
  assert(!/\$\{[A-Za-z_][A-Za-z0-9_]*\^\^?[^}]*\}/u.test(code) && !/\$\{[A-Za-z_][A-Za-z0-9_]*,,?[^}]*\}/u.test(code), `${file} must not use bash 4 case conversion`);
  assert(!/^\s*declare[ \t]+-n\b/mu.test(code) && !/\bwait[ \t]+-n\b/u.test(code) && !/\|&/u.test(code) && !/&>>/u.test(code), `${file} must not use bash 4-only constructs`);
}

/** @param {string} line @returns {string[]} */
function shellWords(line) {
  return line.trim().split(/\s+/u).filter((word) => word !== "");
}

/**
 * Collects `source`/`.` targets and sibling script references. Comment lines and printed usage text
 * are prose, not edges, so they are skipped; every other `.sh` reference in a script is an edge and
 * must be approved for that file.
 *
 * @param {string} content
 * @returns {{ sourced: string[], invoked: string[] }}
 */
function scriptEdges(content) {
  /** @type {Set<string>} */
  const sourced = new Set();
  /** @type {Set<string>} */
  const referenced = new Set();
  const commandStarts = new Set(["if", "then", "else", "elif", "do", "while", "until", "!", "&&", "||", ";", "{", "("]);
  for (const line of codeLines(content)) {
    const trimmed = line.trim();
    if (/^(?:echo|printf)\b/u.test(trimmed) || trimmed.includes("Usage:")) continue;
    const words = shellWords(line);
    for (let index = 0; index < words.length; index += 1) {
      const word = words[index].replace(/^["'(]+|["')]+$/gu, "");
      const atCommandStart = index === 0 || commandStarts.has(words[index - 1]);
      if ((word === "source" || word === ".") && atCommandStart) {
        const target = words[index + 1]?.replace(/^["']|["']$/gu, "");
        if (target && target.endsWith(".sh")) sourced.add(basename(target));
      }
    }
    for (const match of line.matchAll(/(?:^|[\s"'`(=:/])([A-Za-z0-9_.-]+\.sh)\b/gu)) referenced.add(match[1]);
  }
  const invoked = [...referenced].filter((target) => !sourced.has(target));
  return { sourced: [...sourced], invoked };
}

/** @param {string} file @param {string} filePath */
function validateScriptEdges(file, filePath) {
  const content = readFileSync(filePath, "utf8");
  const { sourced, invoked } = scriptEdges(content);
  const ownName = basename(file);
  const approvedSources = approvedSourceEdges.get(file) ?? [];
  assert(sameList(sourced.filter((target) => target.endsWith(".sh")), approvedSources), `${file} must not source unapproved local scripts`);
  const approvedChildren = approvedChildScripts.get(file) ?? [];
  const childInvocations = invoked.filter((target) => target.endsWith(".sh") && target !== ownName);
  assert(sameList(childInvocations, approvedChildren), `${file} must not invoke unapproved sibling scripts`);
}

const manifest = /** @type {Record<string, unknown>} */ (JSON.parse(readFileSync(manifestPath, "utf8")));
assert(Array.isArray(manifest.scripts), "manifest scripts must be an array");
assert(manifest.scripts.length === 44, "manifest must contain exactly 44 scripts");
assert(manifest.scripts.every(isRecord), "manifest rows must be objects");
const requiredRowFields = ["path", "family", "legacyOrigin", "usage", "behavior"];
const legacyOrigins = new Set(["former-sh", "former-py", "retained-mjs", "authored-mjs"]);
const usages = new Set(["analyze-structure", "apply-version", "build-preview", "calculate-version", "check-deployment", "check-jev-request", "check-lint", "collect-rendered-evidence", "commit-files", "detect-package-manager", "detect-slop", "detect-stack", "discover-version", "inspect-repository", "push-commit", "read-version", "render-dashboard", "render-planning-map", "resolve-context", "run-build", "run-contract-evals", "run-detector-evals", "slop-engine-css", "slop-engine-markup", "slop-engine-text", "slop-rule-registry", "slop-rule-shared", "validate-report", "validate-skill", "validate-skill-corpus", "validate-waivers"]);
const behaviors = new Set(["context-resolution", "contract-eval-run", "deployment-readiness-check", "detector-eval-run", "fast-git-commit", "git-push", "jev-request-validation", "lint-readiness-check", "package-manager-detection", "planning-map-render", "preview-build", "project-build", "render-dashboard", "rendered-evidence-collection", "report-validation", "repository-discovery", "repository-status", "scoped-git-commit", "skill-validation", "skills-corpus-validation", "slop-detection", "slop-engine-css", "slop-engine-markup", "slop-engine-text", "slop-rule-registry", "slop-rule-shared", "stack-detection", "structure-analysis", "version-application", "version-calculation", "version-discovery", "version-reading", "waiver-validation"]);
const expectedMetadata = new Map([
  ["skills/ai-design-slop-remover/scripts/analyze-structure.sh", ["analyze-structure", "structure-analysis"]],
  ["skills/ai-design-slop-remover/scripts/collect-rendered-evidence.sh", ["collect-rendered-evidence", "rendered-evidence-collection"]],
  ["skills/ai-design-slop-remover/scripts/detect-slop.sh", ["detect-slop", "slop-detection"]],
  ["skills/ai-design-slop-remover/scripts/engine-css.sh", ["slop-engine-css", "slop-engine-css"]],
  ["skills/ai-design-slop-remover/scripts/engine-markup.sh", ["slop-engine-markup", "slop-engine-markup"]],
  ["skills/ai-design-slop-remover/scripts/engine-text.sh", ["slop-engine-text", "slop-engine-text"]],
  ["skills/ai-design-slop-remover/scripts/resolve-context.sh", ["resolve-context", "context-resolution"]],
  ["skills/ai-design-slop-remover/scripts/rule-registry.sh", ["slop-rule-registry", "slop-rule-registry"]],
  ["skills/ai-design-slop-remover/scripts/rule-shared.sh", ["slop-rule-shared", "slop-rule-shared"]],
  ["skills/ai-design-slop-remover/scripts/run-contract-evals.sh", ["run-contract-evals", "contract-eval-run"]],
  ["skills/ai-design-slop-remover/scripts/run-detector-evals.sh", ["run-detector-evals", "detector-eval-run"]],
  ["skills/ai-design-slop-remover/scripts/validate-report.sh", ["validate-report", "report-validation"]],
  ["skills/ai-design-slop-remover/scripts/validate-waivers.sh", ["validate-waivers", "waiver-validation"]],
  ["skills/autoresearch-skill/scripts/render-dashboard.sh", ["render-dashboard", "render-dashboard"]],
  ["skills/git-maker/scripts/git-commit.sh", ["commit-files", "scoped-git-commit"]],
  ["skills/git-maker/scripts/git-maker-fast.sh", ["commit-files", "fast-git-commit"]],
  ["skills/git-maker/scripts/git-push.sh", ["push-commit", "git-push"]],
  ["skills/git-maker/scripts/repo-discover.sh", ["inspect-repository", "repository-discovery"]],
  ["skills/git-maker/scripts/repo-status.sh", ["inspect-repository", "repository-status"]],
  ["skills/git-worktree/scripts/validate-git-worktree-skill.sh", ["validate-skill", "skill-validation"]],
  ["skills/image-maker/scripts/validate-image-maker.sh", ["validate-skill", "skill-validation"]],
  ["skills/nextjs-architecture/scripts/validate-nextjs-architecture-skill.sh", ["validate-skill", "skill-validation"]],
  ["skills/prd-maker/scripts/build-preview.sh", ["build-preview", "preview-build"]],
  ["skills/prd-maker/scripts/render-planning-map.sh", ["render-planning-map", "planning-map-render"]],
  ["skills/pre-deploy/scripts/build-run.sh", ["run-build", "project-build"]],
  ["skills/pre-deploy/scripts/deploy-check.sh", ["check-deployment", "deployment-readiness-check"]],
  ["skills/pre-deploy/scripts/lint-check.sh", ["check-lint", "lint-readiness-check"]],
  ["skills/pre-deploy/scripts/pm-detect.sh", ["detect-package-manager", "package-manager-detection"]],
  ["skills/pre-deploy/scripts/stack-detect.sh", ["detect-stack", "stack-detection"]],
  ["skills/prompt-maker/scripts/validate-prompt-maker.sh", ["validate-skill", "skill-validation"]],
  ["skills/seo-maker/scripts/render-dashboard.sh", ["render-dashboard", "render-dashboard"]],
  ["skills/skill-maker/scripts/validate-skill-maker.sh", ["validate-skill", "skill-validation"]],
  ["skills/skill-tester/scripts/validate-skill.sh", ["validate-skill", "skill-validation"]],
  ["skills/skill-tester/scripts/validate-skills-corpus.sh", ["validate-skill-corpus", "skills-corpus-validation"]],
  ["skills/skill-tester/scripts/validate-skill-tester.sh", ["validate-skill", "skill-validation"]],
  ["skills/version-update/scripts/git-commit.sh", ["commit-files", "scoped-git-commit"]],
  ["skills/version-update/scripts/git-push.sh", ["push-commit", "git-push"]],
  ["skills/version-update/scripts/stack-detect.sh", ["detect-stack", "stack-detection"]],
  ["skills/version-update/scripts/version-apply.sh", ["apply-version", "version-application"]],
  ["skills/version-update/scripts/version-bump.sh", ["calculate-version", "version-calculation"]],
  ["skills/version-update/scripts/version-current.sh", ["read-version", "version-reading"]],
  ["skills/version-update/scripts/version-find.sh", ["discover-version", "version-discovery"]],
  ["skills/vite-architecture/scripts/validate-vite-architecture-skill.sh", ["validate-skill", "skill-validation"]],
  ["skills/jev-maker/scripts/check-jev-request.sh", ["check-jev-request", "jev-request-validation"]],
]);
assert(expectedMetadata.size === 44, "concrete metadata mapping must cover exactly 44 scripts");
const originCounts = { "former-sh": 0, "former-py": 0, "retained-mjs": 0, "authored-mjs": 0 };
for (const [index, row] of manifest.scripts.entries()) {
  for (const field of requiredRowFields) assert(nonEmpty(row[field]), `manifest scripts[${index}].${field} must be a non-empty string`);
  assert(legacyOrigins.has(row.legacyOrigin), `manifest scripts[${index}].legacyOrigin must be an approved enum value`);
  assert(usages.has(row.usage), `manifest scripts[${index}].usage must be an approved enum value`);
  assert(behaviors.has(row.behavior), `manifest scripts[${index}].behavior must be an approved enum value`);
  assert(row.path === `skills/${row.family}/scripts/${String(row.path).split("/").at(-1)}`, `manifest scripts[${index}] path/family must agree`);
  assert(String(row.path).endsWith(".sh"), `manifest scripts[${index}] path must be a bash script`);
  const expected = expectedMetadata.get(row.path);
  assert(expected !== undefined && row.usage === expected[0] && row.behavior === expected[1], `manifest scripts[${index}] metadata must match its concrete path mapping`);
  originCounts[row.legacyOrigin] += 1;
  assert(isRecord(row.sourcePreimage), `manifest scripts[${index}] requires source provenance evidence`);
  if (row.legacyOrigin === "authored-mjs") {
    const absence = row.sourcePreimage.baselineAbsence;
    assert(isRecord(absence)
      && absence.baselineRef === manifest.legacyPreimageBase
      && absence.path === String(row.path).replace(/\.sh$/u, ".mjs")
      && absence.absent === true,
    `manifest scripts[${index}] requires baseline-absence proof for its historical MJS path`);
  } else {
    assert(nonEmpty(row.sourcePreimage.path)
      && /^[a-f0-9]{64}$/u.test(String(row.sourcePreimage.sha256))
      && (row.sourcePreimage.gitMode === "100755" || row.sourcePreimage.gitMode === "100644"),
    `manifest scripts[${index}] requires concrete historical source preimage evidence`);
  }
  assert(nonEmpty(row.behaviorContractId), `manifest scripts[${index}] requires a behavior contract id`);
}
assert(originCounts["former-sh"] === 19 && originCounts["former-py"] === 1 && originCounts["retained-mjs"] === 9 && originCounts["authored-mjs"] === 15, "manifest historical origin counts must be exactly 19/1/9/15");
const portPreimage = manifest.portPreimage;
assert(isRecord(portPreimage)
  && /^[a-f0-9]{40}$/u.test(String(portPreimage.baselineRef))
  && nonEmpty(portPreimage.model)
  && nonEmpty(portPreimage.note)
  && Array.isArray(portPreimage.workingTreeEdited)
  && portPreimage.workingTreeEdited.length === 4,
"manifest portPreimage must record the port baseline and the uncommitted pre-port edits");
const approved = manifest.scripts.map((row) => /** @type {string} */ (row.path));
assert(new Set(approved).size === approved.length, "manifest script paths must be unique");
const behaviorContracts = /** @type {Record<string, unknown>} */ (JSON.parse(readFileSync(behaviorContractsPath, "utf8")));
assert(behaviorContracts.requiredBy === relative(root, manifestPath), "behavior contracts must name the manifest as their central owner");
assert(isRecord(behaviorContracts.coverage)
  && behaviorContracts.coverage.expectedRows === 44
  && behaviorContracts.coverage.expectedFixtures === 132,
"behavior contract coverage must be exactly 44 rows and 132 fixtures");
assert(Array.isArray(behaviorContracts.rows) && behaviorContracts.rows.length === 44, "behavior contracts must contain exactly 44 rows");
for (const [index, contract] of behaviorContracts.rows.entries()) {
  assert(isRecord(contract) && nonEmpty(contract.path) && nonEmpty(contract.id) && isRecord(contract.fixtures),
    `behavior contracts.rows[${index}] must be a complete row`);
  const row = manifest.scripts.find((candidate) => candidate.path === contract.path);
  assert(row !== undefined && contract.id === row.behaviorContractId, `behavior contracts.rows[${index}] must match its manifest row`);
  assert(sameList(Object.keys(contract.fixtures), ["happy", "malformed", "familyEdge"]),
    `behavior contracts.rows[${index}] must contain exactly three fixture kinds`);
  for (const kind of ["happy", "malformed", "familyEdge"]) {
    const fixture = /** @type {Record<string, unknown>} */ (contract.fixtures)[kind];
    assert(isRecord(fixture) && isRecord(fixture.command), `behavior contracts.rows[${index}].${kind} requires a command`);
    const command = /** @type {{ executable?: unknown, arguments?: unknown }} */ (fixture.command);
    assert(command.executable === "bash"
      && Array.isArray(command.arguments)
      && command.arguments.length === 1
      && command.arguments[0] === contract.path,
    `behavior contracts.rows[${index}].${kind} must execute the bash script with bash`);
  }
}

const references = manifest.forbiddenDetectorReferences;
assert(isRecord(references) && Array.isArray(references.records), "manifest forbiddenDetectorReferences.records must be an array");
assert(references.records.length === 6 && references.records.every(isRecord), "forbidden detector records must contain the exact six policy literals");
const forbiddenLiterals = references.records.map((record) => record.literal);
assert(forbiddenLiterals.every(nonEmpty), "every forbidden detector record requires a literal");
assert(new Set(forbiddenLiterals).size === forbiddenLiterals.length, "forbidden detector literals must be unique");
assert(sameList(forbiddenLiterals, expectedForbiddenLiterals), "forbidden detector literal set must match the validator-owned contract");
assert(Array.isArray(references.scanTargets) && sameList(references.scanTargets, expectedScanTargets), "forbidden detector scan targets must be exact");
assert(Array.isArray(references.enforcementFiles) && sameList(references.enforcementFiles, expectedEnforcementFiles), "forbidden detector enforcement files must be exact");
for (const record of references.records) {
  assert(Array.isArray(record.allowedLocations) && record.allowedLocations.length === 1, `forbidden literal ${record.literal} requires one enforcement location`);
  const location = record.allowedLocations[0];
  assert(isRecord(location)
    && location.file === "scripts/fixtures/skill-script-parity/manifest.json"
    && location.jsonPath === "$.forbiddenDetectorReferences.records[*].literal",
  `forbidden literal ${record.literal} enforcement location must be exact`);
  const manifestOccurrences = JSON.stringify(manifest).split(String(record.literal)).length - 1;
  assert(manifestOccurrences === 1, `forbidden literal ${record.literal} must occur only in its declared manifest data location`);
}
const correction = manifest.versionUpdateDetectorAbsentCorrection;
assert(isRecord(correction) && correction.detectorRestored === false, "detector must never be restored");
assert(Array.isArray(correction.legacyFiles) && correction.legacyFiles.length === 7, "correction baseline requires exactly seven legacy files");
for (const row of correction.legacyFiles) {
  assert(isRecord(row)
    && nonEmpty(row.legacyPath)
    && /^[a-f0-9]{64}$/u.test(String(row.sha256))
    && row.gitMode === "100755"
    && nonEmpty(row.finalPath)
    && String(row.finalPath).endsWith(".sh"),
  "every correction legacy file requires path, SHA-256, executable mode, and a bash final path");
}
assert(isRecord(correction.documents)
  && Array.isArray(correction.documents.paths)
  && correction.documents.paths.length === 2
  && Array.isArray(correction.documents.legacyCommands)
  && Array.isArray(correction.documents.finalCommands)
  && correction.documents.finalCommands.every((command) => typeof command === "string" && command.startsWith("bash scripts/")),
"correction baseline requires paired document paths and bash final commands");
assert(isRecord(correction.callerEdge) && nonEmpty(correction.callerEdge.legacy) && nonEmpty(correction.callerEdge.final) && String(correction.callerEdge.final).endsWith("version-apply.sh -> version-find.sh"), "correction baseline requires legacy and bash final caller edges");
assert(Array.isArray(correction.restoreOrder) && correction.restoreOrder.length >= 4, "correction baseline requires an executable restoration order");

const scriptFiles = filesBelow(skillsPath).map((file) => relative(root, file));
const shFiles = scriptFiles.filter((file) => file.endsWith(".sh"));
const retiredFiles = scriptFiles.filter((file) => /\/scripts\/.*\.(?:mjs|cjs|js|py|rb)$/u.test(file));
assert(retiredFiles.length === 0, `skill script directories must contain only bash scripts: ${retiredFiles.join(", ")}`);
assert(sameList(shFiles, approved), "bash inventory must exactly match the manifest");

for (const target of expectedScanTargets) assert(existsSync(join(root, target)), `required forbidden-reference scan target is missing: ${target}`);
const auditFiles = expectedScanTargets.flatMap((target) => {
  const absolute = join(root, target);
  return existsSync(absolute) ? filesBelow(absolute) : [];
});
for (const absolute of auditFiles) {
  if (!statSync(absolute).isFile()) continue;
  const content = readFileSync(absolute, "utf8");
  for (const literal of expectedForbiddenLiterals) assert(!content.includes(literal), `forbidden detector reference outside enforcement data: ${relative(root, absolute)}: ${literal}`);
}

for (const file of approved) {
  const absolute = join(root, file);
  const content = readFileSync(absolute, "utf8");
  const mode = statSync(absolute).mode;
  validateBashPolicy(content, file, mode);
  validateScriptEdges(file, absolute);
  const row = manifest.scripts.find((candidate) => candidate.path === file);
  if (row.legacyOrigin === "authored-mjs") assert(!existsInBaseline(String(file).replace(/\.sh$/u, ".mjs")), `${file} historical MJS path must be absent from immutable baseline`);
}

console.log(`Validated ${approved.length} bash skill scripts (19 former-sh, 1 former-py, 9 retained-mjs, 15 authored-mjs historical origins).`);
