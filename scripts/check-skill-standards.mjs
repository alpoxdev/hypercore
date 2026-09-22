// @ts-check

/**
 * Repo-level skill standard gate with a baseline ratchet.
 *
 * Every directory directly under the skill root is validated by the skill-maker validator, the
 * watched finding codes are counted per skill, and the counts are compared with a frozen baseline.
 * A count above its baseline entry is a regression (exit 1); an accepted or pre-existing count is
 * debt, reported only, and never changes the exit code.
 */
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, rmSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const validatorPath = join(repoRoot, "skills/skill-maker/scripts/validate-skill-maker.mjs");
const nodeBinary = "node";
const MAX_BUFFER = 64 * 1024 * 1024;
const DEFAULT_ROOT = "skills";
const DEFAULT_BASELINE = "scripts/fixtures/skill-standards/baseline.json";
const DEFAULT_EXCEPTIONS = "scripts/fixtures/skill-standards/exceptions.json";

/**
 * Watched `errors` codes. `SECTION_MISSING` is deliberately absent: every package in this repository
 * reports it, so watching it would only duplicate the section work tracked elsewhere.
 * @type {string[]}
 */
const WATCHED_ERROR_CODES = [
  "CROSS_SKILL_REFERENCE",
  "LINK_MISSING",
  "CODE_FENCE_UNBALANCED",
  "BILINGUAL_MISSING",
  "BILINGUAL_LINK_DRIFT",
  "BILINGUAL_TAG_DRIFT",
  "BILINGUAL_ORPHAN",
  "SCRIPT_RUNTIME_EXTENSION",
  "SCRIPT_RUNTIME_SHEBANG",
  "SCRIPT_RUNTIME_UNREADABLE",
  "STRAY_DOC",
  "FRONTMATTER_NAME",
  "FRONTMATTER_DESCRIPTION",
  "FRONTMATTER_TRIGGER",
  "FRONTMATTER_XML_TAG",
  "CORE_LINE_BUDGET",
  "REFERENCE_TOC_MISSING",
  "OFFICIAL_LAST_VERIFIED_AT",
];

/** Watched `warnings` codes. The validator emits further code-less staleness warnings, which are ignored here. @type {string[]} */
const WATCHED_WARNING_CODES = ["SOURCES_MISSING", "SOURCES_CHECKED_DATE_MISSING", "SOURCES_CHECKED_DATE_INVALID"];

/** The canonical contract labels from `instructions/skill/SKILL_AUTHORING.md`. @type {string[]} */
const CONTRACT_LABELS = ["Intent", "Scope", "Authority", "Evidence", "Tools", "Loop", "Output", "Verification", "Stop condition"];

/** @typedef {Record<string, number>} Counts */
/** @typedef {{ skills: Record<string, Counts> }} BaselineFile */
/** @typedef {Record<string, string>} ExceptionFile */
/** @typedef {{ code?: unknown }} Finding */
/** @typedef {{ errors: Finding[], warnings: Finding[] }} ValidatorResult */
/** @typedef {{ root: string, baseline: string, exceptions: string, skill: string | null, json: boolean, updateBaseline: boolean, help: boolean }} CliArgs */
/** @typedef {{ skill: string, code: string, baseline: number, count: number }} Regression */
/** @typedef {{ skill: string, code: string, count: number }} DebtItem */

/** A configuration or integrity error: the gate could not be run against a trustworthy baseline. */
class ConfigError extends Error {}

/** @param {unknown} value @returns {value is Record<string, unknown>} */
function isRecord(value) {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * @param {string[]} argv
 * @param {number} index
 * @param {string} flag
 * @returns {string}
 */
function requireValue(argv, index, flag) {
  const value = argv[index];
  if (value === undefined || value.startsWith("--")) throw new ConfigError(`Missing value for ${flag}`);
  return value;
}

/**
 * @param {string[]} argv
 * @returns {CliArgs}
 */
function parseArgs(argv) {
  /** @type {CliArgs} */
  const args = {
    root: DEFAULT_ROOT,
    baseline: DEFAULT_BASELINE,
    exceptions: DEFAULT_EXCEPTIONS,
    skill: null,
    json: false,
    updateBaseline: false,
    help: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--root") args.root = requireValue(argv, (index += 1), arg);
    else if (arg === "--baseline") args.baseline = requireValue(argv, (index += 1), arg);
    else if (arg === "--exceptions") args.exceptions = requireValue(argv, (index += 1), arg);
    else if (arg === "--skill") args.skill = requireValue(argv, (index += 1), arg);
    else if (arg === "--json") args.json = true;
    else if (arg === "--update-baseline") args.updateBaseline = true;
    else if (arg === "--help" || arg === "-h") args.help = true;
    else throw new ConfigError(`Unknown argument: ${arg}`);
  }
  return args;
}

/** Skill roots are directories only: files, symlinks, and dotfiles such as `.DS_Store` are skipped. @param {string} root @returns {string[]} */
function listSkills(root) {
  return readdirSync(root, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && !entry.isSymbolicLink() && !entry.name.startsWith("."))
    .map((entry) => entry.name)
    .sort((left, right) => left.localeCompare(right));
}

/**
 * Runs the skill-maker validator on one skill root. Child exit codes 0 and 1 are both normal results
 * and their stdout JSON is parsed; only a spawn failure or unparseable stdout is a configuration error.
 *
 * @param {string} skillDir
 * @returns {ValidatorResult}
 */
function runValidator(skillDir) {
  let stdout = "";
  try {
    stdout = execFileSync(nodeBinary, [validatorPath, "--root", skillDir, "--require-self-containment", "--json"], {
      cwd: repoRoot,
      encoding: "utf8",
      maxBuffer: MAX_BUFFER,
      stdio: ["ignore", "pipe", "pipe"],
    });
  } catch (error) {
    const failure = /** @type {{ status?: number | null, stdout?: string, message?: string }} */ (error);
    const status = typeof failure.status === "number" ? failure.status : -1;
    if (status !== 0 && status !== 1) {
      throw new ConfigError(`Validator failed for ${skillDir} (exit ${status}): ${failure.message ?? "spawn failure"}`);
    }
    stdout = typeof failure.stdout === "string" ? failure.stdout : "";
  }
  let parsed;
  try {
    parsed = JSON.parse(stdout);
  } catch {
    throw new ConfigError(`Validator output for ${skillDir} is not JSON`);
  }
  if (!isRecord(parsed) || !Array.isArray(parsed.errors) || !Array.isArray(parsed.warnings)) {
    throw new ConfigError(`Validator output for ${skillDir} has no errors/warnings arrays`);
  }
  return /** @type {ValidatorResult} */ (parsed);
}

/**
 * @param {ValidatorResult} result
 * @returns {Counts}
 */
function countWatchedFindings(result) {
  /** @type {Counts} */
  const counts = {};
  for (const [watched, findings] of /** @type {Array<[string[], Finding[]]>} */ ([[WATCHED_ERROR_CODES, result.errors], [WATCHED_WARNING_CODES, result.warnings]])) {
    for (const finding of findings) {
      const code = typeof finding.code === "string" ? finding.code : "";
      if (!watched.includes(code)) continue;
      counts[code] = (counts[code] ?? 0) + 1;
    }
  }
  return counts;
}

/** @param {string} value @returns {string} */
function normalizeLabel(value) {
  return value.trim().toLowerCase().replace(/\s+/g, " ").replace(/[.:;,]+$/, "");
}

/**
 * First cells of a markdown table, skipping the header and separator rows.
 *
 * @param {string} table
 * @returns {Set<string>}
 */
function tableLabels(table) {
  /** @type {Set<string>} */
  const labels = new Set();
  for (const line of table.split(/\r?\n/)) {
    const cells = line.split("|");
    if (cells.length < 4) continue;
    const first = cells[1].trim();
    if (first === "" || /^-+$/.test(first)) continue;
    labels.add(normalizeLabel(first));
  }
  return labels;
}

/**
 * Labels of the contract block, recognized as `<instruction_contract>...</instruction_contract>` or a
 * `## Contract` table. Returns null when the skill carries no contract block.
 *
 * @param {string} text
 * @returns {Set<string> | null}
 */
function contractLabels(text) {
  const xml = text.match(/<instruction_contract>([\s\S]*?)<\/instruction_contract>/);
  if (xml) return tableLabels(xml[1]);
  const heading = text.match(/^##\s+Contract\s*$/m);
  if (!heading || heading.index === undefined) return null;
  /** @type {string[]} */
  const rows = [];
  for (const line of text.slice(heading.index).split(/\r?\n/).slice(1)) {
    if (line.trim() === "") continue;
    if (!line.trimStart().startsWith("|")) break;
    rows.push(line);
  }
  return tableLabels(rows.join("\n"));
}

/**
 * Gate-owned checks the child validator cannot make: an absent eval fixture and contract labels
 * missing from the skill's own contract block.
 *
 * @param {string} skillDir
 * @returns {Counts}
 */
function selfChecks(skillDir) {
  /** @type {Counts} */
  const counts = {};
  const evalsDir = join(skillDir, "assets", "evals");
  const hasFixture = existsSync(evalsDir)
    && readdirSync(evalsDir, { withFileTypes: true }).some((entry) => entry.isFile() && entry.name.endsWith(".jsonl"));
  if (!hasFixture) counts.EVAL_FIXTURE_MISSING = 1;
  const skillMd = join(skillDir, "SKILL.md");
  const labels = existsSync(skillMd) ? contractLabels(readFileSync(skillMd, "utf8")) : null;
  const missing = labels === null ? CONTRACT_LABELS.length : CONTRACT_LABELS.filter((label) => !labels.has(normalizeLabel(label))).length;
  if (missing > 0) counts.CONTRACT_FIELDS_MISSING = missing;
  return counts;
}

/**
 * @param {string} root
 * @param {string[]} names
 * @returns {Record<string, Counts>}
 */
function collectCounts(root, names) {
  /** @type {Record<string, Counts>} */
  const counts = {};
  for (const name of names) {
    const skillDir = join(root, name);
    /** @type {Counts} */
    const found = countWatchedFindings(runValidator(skillDir));
    for (const [code, count] of Object.entries(selfChecks(skillDir))) {
      if (count > 0) found[code] = (found[code] ?? 0) + count;
    }
    counts[name] = found;
  }
  return counts;
}

/**
 * @param {string} path
 * @returns {BaselineFile}
 */
function loadBaseline(path) {
  if (!existsSync(path)) throw new ConfigError(`Baseline is missing: ${path} (run --update-baseline to create it)`);
  let parsed;
  try {
    parsed = JSON.parse(readFileSync(path, "utf8"));
  } catch {
    throw new ConfigError(`Baseline is not valid JSON: ${path}`);
  }
  if (!isRecord(parsed) || !isRecord(parsed.skills)) throw new ConfigError(`Baseline must be {"skills": {"<name>": {"<CODE>": <count>}}}: ${path}`);
  for (const [name, entry] of Object.entries(parsed.skills)) {
    if (!isRecord(entry)) throw new ConfigError(`Baseline entry for ${name} must be an object of code counts: ${path}`);
    for (const [code, count] of Object.entries(entry)) {
      if (typeof count !== "number" || !Number.isInteger(count) || count < 0) {
        throw new ConfigError(`Baseline count for ${name}|${code} must be a non-negative integer: ${path}`);
      }
    }
  }
  return /** @type {BaselineFile} */ (parsed);
}

/**
 * @param {string} path
 * @returns {ExceptionFile}
 */
function loadExceptions(path) {
  if (!existsSync(path)) throw new ConfigError(`Exceptions file is missing: ${path}`);
  let parsed;
  try {
    parsed = JSON.parse(readFileSync(path, "utf8"));
  } catch {
    throw new ConfigError(`Exceptions file is not valid JSON: ${path}`);
  }
  if (!isRecord(parsed)) throw new ConfigError(`Exceptions file must be {"<name>|<CODE>": "<reason>"}: ${path}`);
  for (const [key, reason] of Object.entries(parsed)) {
    if (!key.includes("|")) throw new ConfigError(`Exception key must be "<name>|<CODE>": ${key}`);
    if (typeof reason !== "string" || reason.trim() === "") throw new ConfigError(`Exception entry needs a reason: ${key}`);
  }
  return /** @type {ExceptionFile} */ (parsed);
}

/**
 * @param {string} path
 * @param {BaselineFile} baseline
 * @returns {void}
 */
function writeBaseline(path, baseline) {
  mkdirSync(dirname(path), { recursive: true });
  const temporary = `${path}.tmp-${process.pid}`;
  try {
    writeFileSync(temporary, `${JSON.stringify(baseline, null, 2)}\n`);
    renameSync(temporary, path);
  } catch (error) {
    rmSync(temporary, { force: true });
    throw error;
  }
}

function printHelp() {
  console.log(`Usage: node scripts/check-skill-standards.mjs [options]

Runs the skill-maker validator over every skill directory under the root, counts the watched
finding codes per skill, and compares them with the frozen baseline.

  --root <dir>        skill root (default ${DEFAULT_ROOT}, resolved from the repository root)
  --baseline <path>   baseline file (default ${DEFAULT_BASELINE})
  --exceptions <path> permanent exception file (default ${DEFAULT_EXCEPTIONS})
  --skill <name>      restrict the report to one skill directory
  --json              print the machine-readable report
  --update-baseline   rewrite the baseline from the current counts (never writes exceptions)
  -h, --help          print this help

Exit codes: 0 no regressions, 1 one or more regressions, 2 configuration or integrity error.
Counts above 0 that are not exceptions are reported as debt and never change the exit code.`);
}

/**
 * @param {string[]} argv
 * @returns {number}
 */
function main(argv) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return 0;
  }

  const root = resolve(repoRoot, args.root);
  if (!existsSync(root) || !statSync(root).isDirectory()) throw new ConfigError(`Skill root is missing: ${args.root}`);
  const allSkills = listSkills(root);
  const scope = args.skill === null ? allSkills : allSkills.filter((name) => name === args.skill);
  if (args.skill !== null && scope.length === 0) throw new ConfigError(`Unknown skill: ${args.skill}`);

  const baselinePath = resolve(repoRoot, args.baseline);
  const exceptions = loadExceptions(resolve(repoRoot, args.exceptions));
  const scanned = args.updateBaseline ? allSkills : scope;
  const counts = collectCounts(root, scanned);

  /** @type {BaselineFile} */
  let baseline;
  if (args.updateBaseline) {
    baseline = { skills: counts };
    writeBaseline(baselinePath, baseline);
  } else {
    baseline = loadBaseline(baselinePath);
    for (const name of scanned) {
      if (!Object.hasOwn(baseline.skills, name)) throw new ConfigError(`Baseline has no entry for skill: ${name} (run --update-baseline)`);
    }
  }

  /** @type {Regression[]} */
  const regressions = [];
  /** @type {DebtItem[]} */
  const debt = [];
  /** @type {Record<string, Counts>} */
  const reportCounts = {};
  /** @type {Record<string, Counts>} */
  const reportBaseline = {};
  /** @type {ExceptionFile} */
  const reportExceptions = {};
  for (const name of scanned) {
    const current = counts[name] ?? {};
    const reference = baseline.skills[name] ?? {};
    reportCounts[name] = current;
    reportBaseline[name] = reference;
    for (const [code, count] of Object.entries(current)) {
      const recorded = reference[code] ?? 0;
      if (count > recorded) regressions.push({ skill: name, code, baseline: recorded, count });
      const key = `${name}|${code}`;
      if (Object.hasOwn(exceptions, key)) reportExceptions[key] = exceptions[key];
      else debt.push({ skill: name, code, count });
    }
  }

  const report = {
    counts: reportCounts,
    baseline: reportBaseline,
    regressions: regressions.length,
    debt: debt.length,
    exceptions: reportExceptions,
  };

  if (args.json) {
    console.log(JSON.stringify(report, null, 2));
  } else {
    console.log(`skill standard gate: ${scanned.length} skill(s), ${regressions.length} regression(s), ${debt.length} debt item(s), ${Object.keys(reportExceptions).length} exception(s)`);
    if (args.updateBaseline) console.log(`baseline written: ${baselinePath}`);
    for (const regression of regressions) console.log(`REGRESSION ${regression.skill}|${regression.code} count ${regression.count} > baseline ${regression.baseline}`);
    for (const item of debt) console.log(`DEBT ${item.skill}|${item.code} count ${item.count}`);
  }

  return regressions.length > 0 ? 1 : 0;
}

try {
  process.exit(main(process.argv.slice(2)));
} catch (error) {
  if (error instanceof ConfigError) {
    console.error(`check-skill-standards: ${error.message}`);
  } else {
    console.error(`check-skill-standards: unexpected failure: ${error instanceof Error ? error.stack : String(error)}`);
  }
  process.exit(2);
}
