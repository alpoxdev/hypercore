#!/usr/bin/env bun
// @ts-check
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

/**
 * @typedef {{
 *   root: string,
 *   evals: string,
 *   json: boolean,
 *   requireSelfContainment: boolean,
 *   allow: string[],
 *   help?: boolean
 * }} CliArgs
 *
 * @typedef {{
 *   code: string,
 *   message: string,
 *   path?: string,
 *   detail?: string
 * }} ValidationIssue
 */
/**
 * @typedef {Record<string, unknown>} JsonRecord
 *
 * @typedef {{
 *   id: unknown,
 *   category: unknown,
 *   language: unknown,
 *   intent: unknown,
 *   prompt: unknown,
 *   context: unknown,
 *   metrics: unknown,
 *   expect: unknown,
 *   runs: unknown,
 *   threshold: unknown,
 *   note: unknown,
 *   expected: unknown
 * }} EvalRow
 *
 * @typedef {{
 *   message: string,
 *   extra: JsonRecord
 * }} EvalRowError
 */
const VALIDATION_DATE = process.env.SKILL_MAKER_VALIDATION_DATE || new Date().toISOString().slice(0, 10);
const REQUIRED_SECTIONS = [
  "output_language",
  "purpose",
  "routing_rule",
  "instruction_contract",
  "activation_examples",
  "trigger_conditions",
  "skill_architecture",
  "loop_policy",
  "language_and_translation_default",
  "reference_routing",
  "support_file_read_order",
  "workflow",
  "required",
  "forbidden",
  "validation",
];
/** @type {Record<string, number>} */
const CATEGORY_FLOORS = {
  positive: 3,
  negative: 2,
  boundary: 1,
  workflow: 1,
  source: 1,
  safety: 1,
  adversarial: 1,
  regression: 1,
  coexistence: 1,
};
/**
 * Categories whose cases are trigger judgements. Every case in one of these must state its own
 * `expect`, `runs`, and `threshold`. The base's SK-J rules forbid judging a trigger from a single run
 * and forbid a case inheriting a default, so the values are required at the point of use.
 * @type {string[]}
 */
const TRIGGER_CATEGORIES = ["positive", "negative", "boundary", "coexistence"];
/**
 * The base's last completed re-verification date, read from instructions/README.md. A snapshot older
 * than this was not rechecked alongside the base. This is deliberately NOT the next-sweep date: that
 * is in the future, so using it would flag every snapshot including freshly checked ones.
 */
const BASE_LAST_REVERIFIED = "2026-09-19";
/** The specification's SKILL.md line budget. */
const CORE_LINE_BUDGET = 500;
/** A package's bundled scripts directory ships Bun `.mjs` files only; this is the one allowed extension. */
const BUNDLED_SCRIPT_EXTENSION = ".mjs";
/** The shebang every bundled Bun script must start with. */
const BUNDLED_SCRIPT_SHEBANG = "#!/usr/bin/env bun";
/** Reference files longer than this must carry a table of contents. */
const REFERENCE_TOC_THRESHOLD = 100;
/** XML tags and the reserved words Claude forbids in `name`; XML tags are also forbidden in `description`. */
const XML_TAG_RE = /<[^>]+>/;
const RESERVED_NAME_WORDS = ["anthropic", "claude"];
/**
 * Whether an error is a permission denial rather than a missing or malformed target.
 *
 * @param {unknown} error
 * @returns {boolean}
 */
function isPermissionError(error) {
  const code = error && typeof error === "object" && "code" in error ? String(error.code) : "";
  return code === "EACCES" || code === "EPERM";
}
/** @type {Record<string, number>} */
const LANGUAGE_FLOORS = {
  en: 1,
  ko: 1,
  mixed: 1,
};
const STRAY_DOC_NAMES = new Set(["README.md", "CHANGELOG.md", "QUICK_REFERENCE.md"]);

/**
 * Parses the standalone validator command line.
 * @param {string[]} argv
 * @returns {CliArgs}
 * @throws {Error} When an option is unknown or missing its value.
 */
function parseArgs(argv) {
  /** @type {CliArgs} */
  const args = {
    root: "skills/skill-maker",
    evals: "skills/skill-maker/assets/evals/skill-maker-cases.jsonl",
    json: false,
    requireSelfContainment: false,
    allow: /** @type {string[]} */ ([]),
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--root") {
      args.root = requireValue(argv, (index += 1), arg);
    } else if (arg === "--evals") {
      args.evals = requireValue(argv, (index += 1), arg);
    } else if (arg === "--require-self-containment") {
      args.requireSelfContainment = true;
    } else if (arg === "--allow") {
      args.allow.push(requireValue(argv, (index += 1), arg));
    } else if (arg === "--json") {
      args.json = true;
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else {
      throw validationError("ARG_UNKNOWN", `Unknown argument: ${arg}`);
    }
  }

  return args;
}

/**
 * @param {string[]} argv
 * @param {number} index
 * @param {string} flag
 * @returns {string}
 */
function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw validationError("ARG_VALUE_MISSING", `${flag} requires a value`);
  }
  return value;
}

/**
 * @param {string} code
 * @param {string} message
 * @param {Record<string, unknown>} [extra]
 * @returns {Error & { code: string }}
 */
function validationError(code, message, extra = {}) {
  const error = /** @type {Error & { code: string }} */ (new Error(message));
  error.code = code;
  Object.assign(error, extra);
  return error;
}

/**
 * @param {string} root
 * @param {ValidationIssue[] | null} [errors]
 * @returns {string[]}
 */
function walkFiles(root, errors = null) {
  const files = [];
  const stack = [root];
  while (stack.length > 0) {
    const current = stack.pop();
    if (!current) continue;
    let entries = [];
    try {
      entries = fs.readdirSync(current, { withFileTypes: true });
    } catch (error) {
      const item = errorObject("DIR_READ_FAILED", `Cannot read directory: ${path.relative(process.cwd(), current)}`, {
        path: path.relative(process.cwd(), current),
        detail: error instanceof Error ? error.message : String(error),
      });
      if (!errors) {
        throw validationError(item.code, item.message, item);
      }
      errors.push(item);
      continue;
    }
    for (const entry of entries) {
      const fullPath = path.join(current, entry.name);
      if (entry.isDirectory()) {
        stack.push(fullPath);
      } else if (entry.isFile()) {
        files.push(fullPath);
      }
    }
  }
  return files.sort();
}

/**
 * @param {string} root
 * @param {string} filePath
 * @returns {string}
 */
function relative(root, filePath) {
  return path.relative(root, filePath).split(path.sep).join("/");
}

/**
 * @param {string} filePath
 * @returns {string}
 */
function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

/**
 * @param {string} root
 * @param {ValidationIssue[]} errors
 */
function checkDiscoveryMetadata(root, errors) {
  const skillPath = path.join(root, "SKILL.md");
  const koreanPath = path.join(root, "SKILL.ko.md");
  const expectedName = path.basename(root);
  /** @type {{ ok: boolean, expectedName: string, files: Array<{ path: string, name: string, descriptionLength: number }> }} */
  const result = { ok: true, expectedName, files: [] };
  for (const filePath of [skillPath, koreanPath]) {
    if (!fs.existsSync(filePath)) {
      result.ok = false;
      continue;
    }
    const text = readText(filePath);
    const name = frontmatterValue(text, "name");
    const description = frontmatterValue(text, "description");
    const item = { path: relative(root, filePath), name, descriptionLength: description.length };
    result.files.push(item);
    if (name !== expectedName || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(name) || name.length > 64) {
      result.ok = false;
      errors.push(errorObject("FRONTMATTER_NAME", `Skill name must be lowercase kebab-case and match folder: ${expectedName}`, item));
    }
    if (description.length < 1 || description.length > 1024) {
      result.ok = false;
      errors.push(errorObject("FRONTMATTER_DESCRIPTION", "Skill description must contain 1–1024 characters", item));
    }
    if (filePath === skillPath && !/^Use this skill when\b/.test(description)) {
      result.ok = false;
      errors.push(errorObject("FRONTMATTER_TRIGGER", "Canonical description must start with 'Use this skill when'", item));
    }
  }
  return result;
}

/**
 * @param {string} text
 * @param {string} key
 * @returns {string}
 */
function frontmatterValue(text, key) {
  const block = /^---\r?\n([\s\S]*?)\r?\n---/.exec(text)?.[1] || "";
  const value = new RegExp(`^${escapeRegExp(key)}:\\s*(.+)$`, "m").exec(block)?.[1]?.trim() || "";
  return value.replace(/^["']|["']$/g, "");
}

/**
 * @param {string} root
 * @param {ValidationIssue[]} errors
 */
function checkCoreParity(root, errors) {
  const englishPath = path.join(root, "SKILL.md");
  const koreanPath = path.join(root, "SKILL.ko.md");
  if (!fs.existsSync(englishPath) || !fs.existsSync(koreanPath)) {
    return { ok: false, tags: false, supportLinks: false };
  }
  const english = readText(englishPath);
  const korean = readText(koreanPath);
  const tagsEn = extractStructuralTags(english);
  const tagsKo = extractStructuralTags(korean);
  const linksEn = extractAtLinks(english).map(normalizeLocalizedPath);
  const linksKo = extractAtLinks(korean).map(normalizeLocalizedPath);
  const tags = JSON.stringify(tagsEn) === JSON.stringify(tagsKo);
  const supportLinks = JSON.stringify(linksEn) === JSON.stringify(linksKo);
  if (!tags) errors.push(errorObject("BILINGUAL_TAG_DRIFT", "SKILL.md and SKILL.ko.md structural tags differ", { tagsEn, tagsKo }));
  if (!supportLinks) errors.push(errorObject("BILINGUAL_LINK_DRIFT", "SKILL.md and SKILL.ko.md support links differ", { linksEn, linksKo }));
  return { ok: tags && supportLinks, tags, supportLinks };
}

/**
 * @param {string} text
 * @returns {string[]}
 */
function extractStructuralTags(text) {
  return [...text.matchAll(/^<\/?([a-z][a-z0-9_]*)>\s*$/gim)].map((match) => match[0].toLowerCase());
}

/**
 * @param {string} value
 * @returns {string}
 */
function normalizeLocalizedPath(value) {
  return value.replace(/\.ko\.md$/, ".md");
}

/**
 * @param {string} root
 * @param {ValidationIssue[]} errors
 */
function checkRequiredSections(root, errors) {
  const skillPath = path.join(root, "SKILL.md");
  /** @type {Record<string, boolean>} */
  const found = {};
  for (const section of REQUIRED_SECTIONS) {
    found[section] = false;
  }

  if (!fs.existsSync(skillPath)) {
    errors.push(errorObject("SKILL_MISSING", "SKILL.md is missing", { path: skillPath }));
    return { ok: false, required: REQUIRED_SECTIONS, found, missing: REQUIRED_SECTIONS };
  }

  const body = readText(skillPath);
  for (const section of REQUIRED_SECTIONS) {
    const openTag = new RegExp(`<${escapeRegExp(section)}\\b`, "i");
    const heading = new RegExp(`^#{1,6}\\s+${escapeRegExp(section).replaceAll("_", "[ _-]")}`, "im");
    found[section] = openTag.test(body) || heading.test(body);
  }

  const missing = REQUIRED_SECTIONS.filter((section) => !found[section]);
  for (const section of missing) {
    errors.push(errorObject("SECTION_MISSING", `Required SKILL.md section is missing: ${section}`, { section }));
  }

  return { ok: missing.length === 0, required: REQUIRED_SECTIONS, found, missing };
}

/**
 * @param {string} root
 * @param {string[]} markdownFiles
 * @param {ValidationIssue[]} errors
 */
function checkLinks(root, markdownFiles, errors) {
  /** @type {Array<{ from: string, href: string }>} */
  const checked = [];
  /** @type {Array<{ from: string, href: string, resolved: string }>} */
  const missing = [];
  for (const filePath of markdownFiles) {
    const text = readText(filePath);
    const baseDir = path.dirname(filePath);
    const refs = [
      ...extractAtLinks(text),
      ...extractMarkdownLinks(text),
    ];
    for (const ref of refs) {
      const target = ref.startsWith("/")
        ? path.join(root, ref)
        : path.resolve(baseDir, stripAnchor(ref));
      const display = relative(root, filePath);
      checked.push({ from: display, href: ref });
      if (!isInside(root, target) || !fs.existsSync(target)) {
        const item = { from: display, href: ref, resolved: path.relative(process.cwd(), target) };
        missing.push(item);
        errors.push(errorObject("LINK_MISSING", `Local markdown link does not resolve: ${display} -> ${ref}`, item));
      }
    }
  }
  return { ok: missing.length === 0, checked: checked.length, missing };
}

/**
 * @param {string} text
 * @returns {string[]}
 */
function extractAtLinks(text) {
  /** @type {string[]} */
  const refs = [];
  const pattern = /^@([^\s]+\.md)\s*$/gm;
  let match;
  while ((match = pattern.exec(text)) !== null) {
    const ref = match[1];
    if (ref) refs.push(ref);
  }
  return refs;
}

/**
 * @param {string} text
 * @returns {string[]}
 */
function extractMarkdownLinks(text) {
  /** @type {string[]} */
  const refs = [];
  const pattern = /!?\[[^\]\n]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g;
  let match;
  while ((match = pattern.exec(text)) !== null) {
    const href = match[1];
    if (!href) continue;
    if (
      href.startsWith("http://") ||
      href.startsWith("https://") ||
      href.startsWith("mailto:") ||
      href.startsWith("#")
    ) {
      continue;
    }
    refs.push(href);
  }
  return refs;
}

/**
 * @param {string} ref
 * @returns {string}
 */
function stripAnchor(ref) {
  return decodeURIComponent(ref.split("#")[0]);
}

/**
 * @param {string} root
 * @param {string} target
 * @returns {boolean}
 */
function isInside(root, target) {
  const relativePath = path.relative(root, target);
  return relativePath === "" || (!relativePath.startsWith("..") && !path.isAbsolute(relativePath));
}

/**
 * @param {string} root
 * @param {string[]} markdownFiles
 * @param {ValidationIssue[]} errors
 */
function checkCodeFences(root, markdownFiles, errors) {
  /** @type {Array<{ path: string, balanced: boolean, unclosed?: Array<{ fence: string, line: number }> }>} */
  const files = [];
  for (const filePath of markdownFiles) {
    const text = readText(filePath);
    /** @type {Array<{ fence: string, line: number }>} */
    const stack = [];
    const lines = text.split(/\r?\n/);
    for (let index = 0; index < lines.length; index += 1) {
      const match = /^(\s*)(`{3,}|~{3,})/.exec(lines[index]);
      if (!match) continue;
      const fence = match[2]?.[0];
      if (!fence) continue;
      if (stack.length > 0 && stack[stack.length - 1].fence === fence) {
        stack.pop();
      } else {
        stack.push({ fence, line: index + 1 });
      }
    }
    const balanced = stack.length === 0;
    /** @type {{ path: string, balanced: boolean, unclosed?: Array<{ fence: string, line: number }> }} */
    const item = { path: relative(root, filePath), balanced };
    files.push(item);
    if (!balanced) {
      item.unclosed = stack;
      errors.push(errorObject("CODE_FENCE_UNBALANCED", `Unbalanced code fence in ${item.path}`, item));
    }
  }
  return { ok: files.every((file) => file.balanced), files };
}

/**
 * @param {string} root
 * @param {string[]} markdownFiles
 * @param {ValidationIssue[]} errors
 */
function checkBilingualPairs(root, markdownFiles, errors) {
  const markdownSet = new Set(markdownFiles.map((filePath) => relative(root, filePath)));
  /** @type {string[]} */
  const missing = [];
  /** @type {string[]} */
  const orphan = [];
  for (const file of markdownSet) {
    if (file.endsWith(".ko.md")) {
      const source = file.slice(0, -6) + ".md";
      if (!markdownSet.has(source)) {
        orphan.push(file);
        errors.push(errorObject("BILINGUAL_ORPHAN", `Korean markdown pair has no English source: ${file}`, { path: file }));
      }
    } else {
      const parsed = path.posix.parse(file);
      const korean = path.posix.join(parsed.dir, `${parsed.name}.ko.md`);
      if (!markdownSet.has(korean)) {
        missing.push(korean);
        errors.push(errorObject("BILINGUAL_MISSING", `Missing Korean markdown pair: ${korean}`, { path: korean }));
      }
    }
  }
  return { ok: missing.length === 0 && orphan.length === 0, missing, orphan };
}

/**
 * @param {string} root
 * @param {ValidationIssue[]} errors
 */
function checkStrayDocs(root, errors) {
  /** @type {string[]} */
  const found = [];
  /** @type {Array<{ dir: string, depth: number }>} */
  const stack = [{ dir: root, depth: 0 }];
  while (stack.length > 0) {
    const current = stack.pop();
    if (!current) continue;
    const { dir, depth } = current;
    if (depth > 2) continue;
    let entries = [];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch (error) {
      errors.push(errorObject("DIR_READ_FAILED", `Cannot read directory while checking stray docs: ${relative(root, dir)}`, {
        path: relative(root, dir),
        detail: error instanceof Error ? error.message : String(error),
      }));
      continue;
    }
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        stack.push({ dir: fullPath, depth: depth + 1 });
      } else if (entry.isFile() && STRAY_DOC_NAMES.has(entry.name)) {
        const item = relative(root, fullPath);
        found.push(item);
        errors.push(errorObject("STRAY_DOC", `Stray broad documentation file is not allowed under maxdepth 2: ${item}`, { path: item }));
      }
    }
  }
  return { ok: found.length === 0, found };
}

/**
 * @param {string} evalsPath
 * @param {ValidationIssue[]} errors
 * @param {ValidationIssue[]} contractSink
 * @param {boolean} strict
 */
function checkEvalCases(evalsPath, errors, contractSink, strict) {
  /** @type {EvalRow[]} */
  const rows = [];
  /** @type {Record<string, number>} */
  const counts = {};
  /** @type {Record<string, number>} */
  const languageCounts = {};
  /** @type {Set<string>} */
  const ids = new Set();
  if (!fs.existsSync(evalsPath)) {
    errors.push(errorObject("EVAL_FILE_MISSING", `Eval JSONL file is missing: ${evalsPath}`, { path: evalsPath }));
    return {
      ok: false,
      path: evalsPath,
      total: 0,
      counts,
      languageCounts,
      required: CATEGORY_FLOORS,
      requiredLanguages: LANGUAGE_FLOORS,
    };
  }

  const lines = readText(evalsPath).split(/\r?\n/);
  lines.forEach((line, index) => {
    const lineNumber = index + 1;
    if (line.trim() === "") return;
    /** @type {unknown} */
    let row;
    try {
      row = JSON.parse(line);
    } catch (error) {
      pushEvalError(errors, `Eval case line ${lineNumber} is not valid JSON: ${error instanceof Error ? error.message : String(error)}`, { line: lineNumber });
      return;
    }
    const rowErrors = validateEvalRow(row, lineNumber);
    for (const error of rowErrors) {
      const isContract = Boolean(error.extra && error.extra.contract);
      if (isContract) {
        contractSink.push(errorObject(
          "EVAL_CASE_INVALID",
          error.message.includes("EVAL_CASE_INVALID") ? error.message : `EVAL_CASE_INVALID: ${error.message}`,
          error.extra,
        ));
      } else {
        pushEvalError(errors, error.message, error.extra);
      }
    }
    if (isEvalRow(row)) {
      if (nonEmptyString(row.id)) {
        if (ids.has(row.id)) {
          pushEvalError(errors, `Duplicate eval case id: ${row.id}`, { line: lineNumber, id: row.id });
        }
        ids.add(row.id);
      }
      rows.push(row);
      if (typeof row.category === "string") counts[row.category] = (counts[row.category] || 0) + 1;
      if (typeof row.language === "string") languageCounts[row.language] = (languageCounts[row.language] || 0) + 1;
    }
  });

  // The coexistence floor is part of the strengthened contract, so it applies to the package that
  // adopted it rather than to every package this validator is pointed at.
  const categoryFloors = strict
    ? CATEGORY_FLOORS
    : Object.fromEntries(Object.entries(CATEGORY_FLOORS).filter(([name]) => name !== "coexistence"));
  checkFloors(categoryFloors, counts, "category", errors);
  checkFloors(LANGUAGE_FLOORS, languageCounts, "language", errors);

  return {
    ok: !errors.some((error) => error.code.startsWith("EVAL_")),
    path: evalsPath,
    total: rows.length,
    counts,
    languageCounts,
    required: categoryFloors,
    requiredLanguages: LANGUAGE_FLOORS,
  };
}

/**
 * @param {Record<string, number>} floors
 * @param {Record<string, number>} counts
 * @param {string} dimension
 * @param {ValidationIssue[]} errors
 */
function checkFloors(floors, counts, dimension, errors) {
  for (const [name, floor] of Object.entries(floors)) {
    if ((counts[name] || 0) < floor) {
      errors.push(errorObject("EVAL_DIMENSION_COUNT", `Expected at least ${floor} ${dimension} case(s) for ${name}`, {
        dimension,
        name,
        expected: floor,
        actual: counts[name] || 0,
      }));
    }
  }
}

/**
 * @param {unknown} value
 * @returns {value is JsonRecord}
 */
function isRecord(value) {
  return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}

/**
 * @param {unknown} row
 * @returns {row is EvalRow}
 */
function isEvalRow(row) {
  return isRecord(row);
}

/**
 * @param {unknown} row
 * @param {number} lineNumber
 * @returns {EvalRowError[]}
 */
function validateEvalRow(row, lineNumber) {
  /** @type {EvalRowError[]} */
  const errors = [];
  /** @param {string} message @param {JsonRecord} [extra] */
  const fail = (message, extra = {}) => errors.push({ message, extra: { line: lineNumber, ...extra } });
  if (!isEvalRow(row)) {
    fail("Eval case must be a JSON object");
    return errors;
  }
  if (!nonEmptyString(row.id)) fail("Eval case requires non-empty id", { id: row.id });
  if (typeof row.category !== "string" || !Object.hasOwn(CATEGORY_FLOORS, row.category)) fail("Eval case requires a supported category", { id: row.id, category: row.category });
  if (typeof row.language !== "string" || !Object.hasOwn(LANGUAGE_FLOORS, row.language)) fail("Eval case requires language en, ko, or mixed", { id: row.id, language: row.language });
  if (!nonEmptyString(row.intent)) fail("Eval case requires non-empty intent", { id: row.id });
  if (!nonEmptyString(row.prompt)) fail("Eval case requires non-empty prompt", { id: row.id });
  const context = isRecord(row.context) ? row.context : null;
  if (!context || !Array.isArray(context.files) || !Array.isArray(context.sources)) {
    fail("EVAL_CASE_INVALID: eval case context requires files and sources arrays", { id: row.id });
  }
  if (!Array.isArray(row.metrics) || row.metrics.length === 0 || row.metrics.some((metric) => !nonEmptyString(metric))) {
    fail("EVAL_CASE_INVALID: eval case requires non-empty metrics", { id: row.id });
  }
  const isTriggerCategory = typeof row.category === "string" && TRIGGER_CATEGORIES.includes(row.category);
  if (isTriggerCategory) {
    // expect / runs / threshold are required on the case itself - never inherited from a default.
    // Tagged `contract: true` so the caller can route them as errors or warnings by package.
    if (row.expect !== "trigger" && row.expect !== "no_trigger") {
      fail("EVAL_CASE_INVALID: trigger eval requires expect to be trigger or no_trigger", { id: row.id, expect: row.expect, contract: true });
    }
    if (typeof row.runs !== "number" || !Number.isInteger(row.runs) || row.runs < 1) {
      fail("EVAL_CASE_INVALID: trigger eval requires a positive integer runs value stated on the case", { id: row.id, runs: row.runs, contract: true });
    }
    if (typeof row.threshold !== "number" || row.threshold <= 0 || row.threshold >= 1) {
      fail("EVAL_CASE_INVALID: trigger eval requires a threshold between 0 and 1 stated on the case", { id: row.id, threshold: row.threshold, contract: true });
    }
  }
  const expected = isRecord(row.expected) ? row.expected : null;
  if (!expected) {
    fail("EVAL_CASE_INVALID: eval case requires expected object", { id: row.id });
    return errors;
  }
  if (!Array.isArray(expected.must) || expected.must.length === 0) {
    fail("EVAL_CASE_INVALID: expected.must must be a non-empty array", { id: row.id });
  }
  if (!Array.isArray(expected.mustNot) || expected.mustNot.length === 0) {
    fail("EVAL_CASE_INVALID: expected.mustNot must be a non-empty array", { id: row.id });
  }
  return errors;
}

/**
 * @param {ValidationIssue[]} errors
 * @param {string} message
 * @param {JsonRecord} extra
 */
function pushEvalError(errors, message, extra) {
  errors.push(errorObject("EVAL_CASE_INVALID", message.includes("EVAL_CASE_INVALID") ? message : `EVAL_CASE_INVALID: ${message}`, extra));
}

/**
 * @param {string} root
 * @param {ValidationIssue[]} errors
 */
function checkOfficialLastVerified(root, errors) {
  const officialRoot = path.join(root, "references", "official");
  const files = fs.existsSync(officialRoot)
    ? walkFiles(officialRoot, errors).filter((filePath) => filePath.endsWith(".md"))
    : [];
  /** @type {Array<{ path: string, dates: string[], invalidDates: string[] }>} */
  const invalid = [];
  for (const filePath of files) {
    const text = readText(filePath);
    const matches = [...text.matchAll(/last_verified_at:\s*([0-9]{4}-[0-9]{2}-[0-9]{2})/g)].map((match) => match[1]);
    const invalidDates = matches.filter((date) => !isValidDate(date) || date > VALIDATION_DATE);
    const item = { path: relative(root, filePath), dates: matches, invalidDates };
    if (matches.length === 0 || invalidDates.length > 0) {
      invalid.push(item);
      errors.push(errorObject(
        "OFFICIAL_LAST_VERIFIED_AT",
        `Official reference dates must be valid and not later than ${VALIDATION_DATE}`,
        item,
      ));
    }
  }
  return { ok: invalid.length === 0, validationDate: VALIDATION_DATE, checked: files.length, invalid };
}

/**
 * The strengthened contract - the trigger-case shape, the coexistence floor, and the Sources
 * convention - is this repository's skill-authoring contract, adopted by the skill-maker package.
 * The plan that introduced it scoped it to `skills/skill-maker/**` and forbade editing any other
 * package, while an existing behavioural test uses this validator as a generic evaluator for
 * another package. So contract findings are **errors** for the package that adopted the contract
 * and **warnings** for any other package: advisory, never silently dropped.
 * @param {string} root
 * @returns {boolean}
 */
function isContractAdoptingPackage(root) {
  const skillPath = path.join(root, "SKILL.md");
  if (!fs.existsSync(skillPath)) return false;
  return frontmatterValue(readText(skillPath), "name") === "skill-maker";
}

/**
 * Every markdown file under `rules/**` and `references/**` carries a Sources heading with a
 * checked-date line in the block right after it. The regex mirrors SOURCES_RE in
 * scripts/check-skill-contract-parity.mjs, which also accepts the numbered legacy form.
 * @param {string} root
 * @param {string[]} markdownFiles
 * @param {ValidationIssue[]} sink
 */
function checkSourcesSections(root, markdownFiles, sink) {
  const sourcesRe = /^## (?:\d+\. )?Sources\s*$/;
  // Capture the date so it can be calendar-validated. The official-snapshot guard already rejects
  // impossible dates; without this the same date could pass here and fail there.
  const checkedRe = /^> .*(?:checked|확인)\s+(\d{4}-\d{2}-\d{2})/i;
  /** @type {Array<{ path: string, reason: string }>} */
  const invalid = [];
  const targets = markdownFiles.filter((filePath) => {
    const rel = relative(root, filePath).split(path.sep).join("/");
    return rel.startsWith("rules/") || rel.startsWith("references/");
  });
  for (const filePath of targets) {
    const lines = readText(filePath).split("\n");
    const rel = relative(root, filePath);
    const at = lines.findIndex((line) => sourcesRe.test(line));
    if (at < 0) {
      invalid.push({ path: rel, reason: "no Sources section" });
      sink.push(errorObject("SOURCES_MISSING", `Rules and reference files must carry a Sources section: ${rel}`, { path: rel }));
      continue;
    }
    const window = lines.slice(at, at + 6);
    const checked = window.map((line) => line.match(checkedRe)).find(Boolean);
    if (!checked) {
      invalid.push({ path: rel, reason: "no checked-date line" });
      sink.push(errorObject("SOURCES_CHECKED_DATE_MISSING", `Sources section must carry a checked-date line: ${rel}`, { path: rel }));
    } else if (!isValidDate(checked[1])) {
      invalid.push({ path: rel, reason: `impossible checked date ${checked[1]}` });
      sink.push(errorObject("SOURCES_CHECKED_DATE_INVALID", `Sources section checked date is not a real calendar date: ${rel} (${checked[1]})`, { path: rel, date: checked[1] }));
    }
  }
  return { ok: invalid.length === 0, checked: targets.length, invalid };
}

/** Text-bearing files a shipped skill can carry; every other extension is treated as a binary asset. */
const SELF_CONTAINMENT_EXTENSIONS = new Set([
  ".md", ".jsonl", ".json", ".mjs", ".js", ".sh", ".py", ".html", ".css", ".yml", ".yaml", ".toml", ".txt",
]);

/**
 * Sibling skill packages beside the package root, excluding the package itself. A directory counts
 * only when it carries a `SKILL.md`, so `scripts/` and `fixtures/` are never read as skills.
 * @param {string} root
 * @returns {string[]}
 */
function siblingSkillNames(root) {
  const resolved = path.resolve(root);
  const parent = path.dirname(resolved);
  const self = path.basename(resolved);
  /** @type {string[]} */
  const names = [];
  /** @type {import("node:fs").Dirent[]} */
  let entries = [];
  try {
    entries = fs.readdirSync(parent, { withFileTypes: true });
  } catch {
    return names;
  }
  for (const entry of entries) {
    if (!entry.isDirectory() || entry.name === self) continue;
    if (!fs.existsSync(path.join(parent, entry.name, "SKILL.md"))) continue;
    names.push(entry.name);
  }
  return names.sort();
}

/**
 * A hyphenated sibling name matched as a bare token. `-` counts as a word character here, so an
 * extended name such as `alpha-maker-fast` is not read as its prefix `alpha-maker`.
 * @param {string} name
 * @returns {RegExp}
 */
function bareSiblingNameRe(name) {
  return new RegExp(`(^|[^A-Za-z0-9-])${escapeRegExp(name)}([^A-Za-z0-9-]|$)`, "u");
}

/**
 * A `skills/<name>/` path always points into a skills tree, so in strict mode any name other than the
 * package's own is a cross-skill path even when that skill is not installed beside this package. A
 * `$<name>` token gets no such generic treatment: vendor runtime built-ins use the same syntax, so that
 * form stays sibling-based.
 */
const SKILLS_PATH_RE = /skills\/([A-Za-z0-9][A-Za-z0-9._-]*)\//gu;

/**
 * Cross-skill references a package must not carry. Detection covers (a) a hyphenated sibling name as
 * a bare or backticked token, (b) any sibling name in `$<name>` invocation form, and (c) any sibling
 * name as a `skills/<name>/` path segment. A single-word sibling name is not detected as prose or in
 * backticks, because it is indistinguishable from an ordinary word that also names a capability; its
 * `$<name>` and `skills/<name>/` forms are still detected. In strict mode, rule (c) widens to any
 * `skills/<name>/` path other than the package's own, so a standalone package whose siblings are absent
 * is still caught.
 * @param {string} root
 * @param {string[]} files
 * @param {ValidationIssue[]} sink
 * @param {{ allow?: string[], strict?: boolean, warningSink?: ValidationIssue[] }} [options]
 * @returns {{ ok: boolean, strict: boolean, siblings: string[], checkedFiles: number, findings: Array<{ path: string, line: number, name: string, form: string }>, waivers: Array<{ path: string, line: number, name: string, form: string }> }}
 */
function checkSelfContainment(root, files, sink, options = {}) {
  const allow = options.allow ?? [];
  const strict = options.strict === true;
  const warningSink = options.warningSink ?? sink;
  const self = path.basename(path.resolve(root));
  const siblings = siblingSkillNames(root);
  /** @type {Array<{ path: string, line: number, name: string, form: string }>} */
  const findings = [];
  /** @type {Array<{ path: string, line: number, name: string, form: string }>} */
  const waivers = [];
  const textFiles = files.filter((filePath) => SELF_CONTAINMENT_EXTENSIONS.has(path.extname(filePath).toLowerCase()));

  for (const filePath of textFiles) {
    const rel = relative(root, filePath);
    const lines = readText(filePath).split("\n");
    for (const [index, line] of lines.entries()) {
      /** @type {Map<string, string>} */
      const hits = new Map();
      for (const name of siblings) {
        if (line.includes(`$${name}`)) hits.set(`${name}|$${name}`, name);
        else if (line.includes(`skills/${name}/`)) hits.set(`${name}|skills/${name}/`, name);
        else if (name.includes("-") && bareSiblingNameRe(name).test(line)) hits.set(`${name}|${name}`, name);
      }
      if (strict) {
        for (const match of line.matchAll(SKILLS_PATH_RE)) {
          const name = match[1];
          if (name === self) continue;
          hits.set(`${name}|skills/${name}/`, name);
        }
      }
      for (const [key, name] of hits) {
        const form = key.slice(key.indexOf("|") + 1);
        const finding = { path: rel, line: index + 1, name, form };
        if (allow.includes(name)) {
          waivers.push(finding);
          // A user-directed waiver never fails the package; it stays visible in the warning channel
          // even when strict mode routes ordinary findings to the error channel.
          warningSink.push(errorObject("SELF_CONTAINMENT_WAIVER", `User-directed cross-skill reference waiver for ${name}: ${rel}:${index + 1}`, { path: rel, name, form }));
        } else {
          findings.push(finding);
          sink.push(errorObject("CROSS_SKILL_REFERENCE", `Cross-skill reference to ${name} (${form}): ${rel}:${index + 1}`, { path: rel, name, form, line: index + 1 }));
        }
      }
    }
  }

  return { ok: findings.length === 0, strict, siblings, checkedFiles: textFiles.length, findings, waivers };
}

/**
 * A package's bundled scripts are Bun `.mjs` files only. Every entry under `scripts/` whose extension is
 * not exactly lowercase `.mjs` is a violation, and so is a `.mjs` entry that does not start with the Bun
 * shebang.
 *
 * The directory is walked here instead of filtering the shared file list, because that list skips symbolic
 * links and a symlinked entry would otherwise escape the rule; a symlinked `scripts` directory and a
 * top-level directory whose name differs only by case are both treated as the scripts directory.
 *
 * The first line is compared after CRLF normalization, because a Windows checkout can turn the shebang
 * line into `#!/usr/bin/env bun\r` and a raw `split("\n")` would then flag a valid script.
 *
 * This check is always on: it is a hard authoring rule, not a mode.
 *
 * `checked` counts the entries under `scripts/` that received a per-entry verdict. A directory-level
 * failure is reported as a finding instead and is therefore not counted, so `checked` is never the
 * number of things that passed.
 *
 * @param {string} root
 * @param {ValidationIssue[]} sink
 * @returns {{ ok: boolean, checked: number, findings: ValidationIssue[] }}
 */
function checkScriptRuntime(root, sink) {
  /** @type {import('node:fs').Dirent[]} */
  let rootEntries = [];
  try {
    rootEntries = fs.readdirSync(root, { withFileTypes: true });
  } catch {
    return { ok: true, checked: 0, findings: [] };
  }
  const candidates = rootEntries
    .filter((entry) => entry.name.toLowerCase() === "scripts")
    .map((entry) => path.join(root, entry.name));
  if (candidates.length === 0) return { ok: true, checked: 0, findings: [] };
  /** @type {ValidationIssue[]} */
  const findings = [];
  // One issue object goes to both channels, so `ok` below can never disagree with the error sink.
  /** @param {ValidationIssue} issue */
  const report = (issue) => {
    findings.push(issue);
    sink.push(issue);
  };
  /** @type {string[]} */
  const scriptEntries = [];
  for (const candidate of candidates) {
    const relCandidate = relative(root, candidate);
    /** @type {import('node:fs').Stats | null} */
    let stats = null;
    try {
      stats = fs.statSync(candidate);
    } catch (error) {
      // A `scripts` entry that does not resolve is reported rather than skipped: a broken link would
      // otherwise remove the whole directory from the check. A permission error is a different failure,
      // so it gets the unreadable code: the rule is unverified there rather than definitely violated.
      const denied = isPermissionError(error);
      report(errorObject(
        denied ? "SCRIPT_RUNTIME_UNREADABLE" : "SCRIPT_RUNTIME_EXTENSION",
        denied
          ? `${relCandidate} could not be read, so the bundled-script rule cannot be verified there`
          : `${relCandidate} must resolve to a directory of Bun .mjs scripts`,
        { path: relCandidate },
      ));
      continue;
    }
    if (!stats.isDirectory()) {
      scriptEntries.push(candidate);
      continue;
    }
    const stack = [candidate];
    while (stack.length > 0) {
      const current = stack.pop();
      if (!current) continue;
      /** @type {import('node:fs').Dirent[]} */
      let entries = [];
      try {
        entries = fs.readdirSync(current, { withFileTypes: true });
      } catch {
        // The directory cannot be read, so the rule cannot be verified there. Report it here instead of
        // relying on the shared file walk: that walk skips symbolic links, so a linked `scripts/`
        // directory would otherwise turn this into a silent pass. Reporting also keeps the JSON output
        // contract, which an exception escaping this check would destroy.
        report(errorObject("SCRIPT_RUNTIME_UNREADABLE", `${relative(root, current)} could not be read, so the bundled-script rule cannot be verified there`, { path: relative(root, current) }));
        continue;
      }
      for (const entry of entries) {
        const fullPath = path.join(current, entry.name);
        // A symbolic link is reported as an entry rather than followed as a directory, so a linked
        // directory inside `scripts/` cannot smuggle a whole subtree past the extension rule.
        if (entry.isDirectory()) stack.push(fullPath);
        else scriptEntries.push(fullPath);
      }
    }
  }
  for (const entryPath of scriptEntries.sort()) {
    const rel = relative(root, entryPath);
    if (path.extname(entryPath) !== BUNDLED_SCRIPT_EXTENSION) {
      report(errorObject("SCRIPT_RUNTIME_EXTENSION", `${rel} must be a Bun .mjs script; a bundled scripts directory ships no other extension`, { path: rel }));
      continue;
    }
    /** @type {string} */
    let firstLine = "";
    try {
      // Only a regular file is read: `readFileSync` blocks forever on a FIFO, and a directory or
      // socket target throws. Both fall through to the shebang violation instead of hanging or crashing.
      if (fs.statSync(entryPath).isFile()) firstLine = readText(entryPath).split(/\r?\n/, 1)[0];
    } catch {
      firstLine = "";
    }
    if (firstLine !== BUNDLED_SCRIPT_SHEBANG) {
      report(errorObject("SCRIPT_RUNTIME_SHEBANG", `${rel} must start with ${BUNDLED_SCRIPT_SHEBANG}`, { path: rel, firstLine }));
    }
  }
  return { ok: findings.length === 0, checked: scriptEntries.length, findings };
}

/**
 * EN/KO siblings must carry the same set of normative SK-* ids. Zero on both sides is parity.
 * @param {string} root
 * @param {string[]} markdownFiles
 * @param {ValidationIssue[]} errors
 */
function checkIdParity(root, markdownFiles, errors) {
  const idRe = /^- (SK-[A-Z])-(\d+):/;
  const byRel = new Set(markdownFiles.map((filePath) => relative(root, filePath).split(path.sep).join("/")));
  /** @param {string} filePath @returns {Set<string>} */
  const idsOf = (filePath) => {
    const out = new Set();
    for (const line of readText(filePath).split("\n")) {
      const match = line.match(idRe);
      if (match) out.add(`${match[1]}-${match[2]}`);
    }
    return out;
  };
  /** @type {Array<{ path: string, missingIn: string, id: string }>} */
  const drift = [];
  for (const rel of byRel) {
    if (rel.endsWith(".ko.md")) continue;
    const koRel = rel.slice(0, -3) + ".ko.md";
    if (!byRel.has(koRel)) continue;
    const en = idsOf(path.join(root, rel));
    const ko = idsOf(path.join(root, koRel));
    for (const id of en) {
      if (!ko.has(id)) {
        drift.push({ path: rel, missingIn: koRel, id });
        errors.push(errorObject("ID_PARITY_DRIFT", `Normative id ${id} is in ${rel} but not in ${koRel}`, { path: rel, missingIn: koRel, id }));
      }
    }
    for (const id of ko) {
      if (!en.has(id)) {
        drift.push({ path: koRel, missingIn: rel, id });
        errors.push(errorObject("ID_PARITY_DRIFT", `Normative id ${id} is in ${koRel} but not in ${rel}`, { path: koRel, missingIn: rel, id }));
      }
    }
  }
  return { ok: drift.length === 0, drift };
}

/**
 * Claude-specific frontmatter constraints: `name` and `description` free of XML tags, and `name`
 * free of the reserved words "anthropic" and "claude".
 * @param {string} root
 * @param {ValidationIssue[]} errors
 */
function checkFrontmatterConstraints(root, errors) {
  const skillPath = path.join(root, "SKILL.md");
  if (!fs.existsSync(skillPath)) return { ok: false, violations: [] };
  const text = readText(skillPath);
  const name = frontmatterValue(text, "name");
  const description = frontmatterValue(text, "description");
  /** @type {Array<{ field: string, reason: string }>} */
  const violations = [];
  /** @param {string} field @param {string} reason @param {string} code */
  const note = (field, reason, code) => {
    violations.push({ field, reason });
    errors.push(errorObject(code, `${field} ${reason}`, { field, reason }));
  };
  if (name && XML_TAG_RE.test(name)) note("name", "must not contain XML tags", "FRONTMATTER_XML_TAG");
  if (description && XML_TAG_RE.test(description)) note("description", "must not contain XML tags", "FRONTMATTER_XML_TAG");
  if (name) {
    for (const word of RESERVED_NAME_WORDS) {
      if (name.toLowerCase().includes(word)) note("name", `must not contain the reserved word "${word}"`, "FRONTMATTER_RESERVED_WORD");
    }
  }
  return { ok: violations.length === 0, violations };
}

/**
 * The specification's 500-line budget for the SKILL.md body.
 * @param {string} root
 * @param {ValidationIssue[]} errors
 */
function checkCoreLineBudget(root, errors) {
  const skillPath = path.join(root, "SKILL.md");
  if (!fs.existsSync(skillPath)) return { ok: false, lines: 0, budget: CORE_LINE_BUDGET };
  const lines = readText(skillPath).split("\n").length;
  if (lines > CORE_LINE_BUDGET) {
    errors.push(errorObject("CORE_LINE_BUDGET", `SKILL.md has ${lines} lines, over the ${CORE_LINE_BUDGET}-line budget`, { lines, budget: CORE_LINE_BUDGET }));
    return { ok: false, lines, budget: CORE_LINE_BUDGET };
  }
  return { ok: true, lines, budget: CORE_LINE_BUDGET };
}

/**
 * Reference files longer than 100 lines must carry a table of contents, because a reader may see
 * only the opening lines.
 * @param {string} root
 * @param {string[]} markdownFiles
 * @param {ValidationIssue[]} errors
 */
function checkReferenceToc(root, markdownFiles, errors) {
  const tocRe = /^## (?:\d+\. )?(?:Contents|Table of Contents|목차)\s*$/im;
  /** @type {Array<{ path: string, lines: number }>} */
  const invalid = [];
  for (const filePath of markdownFiles) {
    const rel = relative(root, filePath).split(path.sep).join("/");
    if (!rel.startsWith("references/")) continue;
    const text = readText(filePath);
    const lines = text.split("\n").length;
    if (lines > REFERENCE_TOC_THRESHOLD && !tocRe.test(text)) {
      invalid.push({ path: rel, lines });
      errors.push(errorObject("REFERENCE_TOC_MISSING", `Reference file over ${REFERENCE_TOC_THRESHOLD} lines must carry a table of contents: ${rel} (${lines} lines)`, { path: rel, lines }));
    }
  }
  return { ok: invalid.length === 0, invalid };
}

/**
 * A NON-FATAL warning: a snapshot whose last_verified_at predates the base's last completed
 * re-verification was not rechecked alongside the base. This never enters `errors`, so it cannot
 * change `ok` or the exit code - references/local/skill-creator.md deliberately keeps an older date,
 * and a fatal version would fail a correct tree.
 * @param {string} root
 * @returns {Array<{ path: string, date: string }>}
 */
function stalenessWarnings(root) {
  const officialRoot = path.join(root, "references", "official");
  if (!fs.existsSync(officialRoot)) return [];
  /** @type {Array<{ path: string, date: string }>} */
  const out = [];
  for (const filePath of walkFiles(officialRoot).filter((filePath) => filePath.endsWith(".md"))) {
    const text = readText(filePath);
    for (const match of text.matchAll(/last_verified_at:\s*([0-9]{4}-[0-9]{2}-[0-9]{2})/g)) {
      if (match[1] < BASE_LAST_REVERIFIED) out.push({ path: relative(root, filePath), date: match[1] });
    }
  }
  return out;
}

/**
 * @param {string} value
 * @returns {boolean}
 */
function isValidDate(value) {
  const parsed = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(parsed.valueOf()) && parsed.toISOString().slice(0, 10) === value;
}

/**
 * @param {unknown} value
 * @returns {value is string}
 */
function nonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

/**
 * @param {string} code
 * @param {string} message
 * @param {JsonRecord} [extra]
 * @returns {ValidationIssue}
 */
function errorObject(code, message, extra = {}) {
  return { code, message, ...extra };
}

/**
 * @param {string} value
 * @returns {string}
 */
function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function printHelp() {
  console.log(`Usage: bun skills/skill-maker/scripts/validate-skill-maker.mjs --root <dir> --evals <jsonl> [--json]

Validates the repository-local skill-maker package with Bun and Node built-ins only.

Options:
  --root <dir>     Skill root directory. Defaults to skills/skill-maker.
  --evals <file>   JSONL eval cases. Defaults to assets/evals/skill-maker-cases.jsonl.
  --json           Emit structured JSON.
  --require-self-containment
                   Report cross-skill references as errors for any package, not only for the
                   contract-adopting package. Use it on a skill this authoring skill produced.
  --allow <name>   Record a user-directed exception for one sibling skill name. Repeatable;
                   the finding is reported as a waiver warning.
  --help           Show this help.
`);
}

/**
 * @returns {number}
 */
function run() {
  /** @type {CliArgs} */
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    const result = emptyResult();
    result.errors.push(errorObject(
      error instanceof Error && "code" in error && typeof error.code === "string" ? error.code : "ARG_ERROR",
      error instanceof Error ? error.message : String(error),
    ));
    writeResult(result, true);
    return 2;
  }

  if (args.help) {
    printHelp();
    return 0;
  }

  const root = path.resolve(args.root);
  const evalsPath = path.resolve(args.evals);
  /** @type {ValidationIssue[]} */
  const errors = [];

  if (!fs.existsSync(root) || !fs.statSync(root).isDirectory()) {
    errors.push(errorObject("ROOT_MISSING", `Root directory is missing: ${args.root}`, { path: args.root }));
  }

  const files = fs.existsSync(root) ? walkFiles(root, errors) : [];
  const markdownFiles = files.filter((filePath) => filePath.endsWith(".md"));
  // Contract findings are errors for the package that adopted the strengthened contract and warnings
  // for any other package this validator is pointed at. They are never dropped.
  const strict = isContractAdoptingPackage(root);
  /** @type {ValidationIssue[]} */
  const contractFindings = [];
  const contractSink = strict ? errors : contractFindings;
  const result = {
    ok: false,
    contractPackage: strict,
    discoveryMetadata: checkDiscoveryMetadata(root, errors),
    requiredSections: checkRequiredSections(root, errors),
    links: checkLinks(root, markdownFiles, errors),
    codeFences: checkCodeFences(root, markdownFiles, errors),
    bilingualPairs: checkBilingualPairs(root, markdownFiles, errors),
    bilingualCoreParity: checkCoreParity(root, errors),
    triggerCases: checkEvalCases(evalsPath, errors, contractSink, strict),
    officialLastVerifiedGuard: checkOfficialLastVerified(root, errors),
    sourcesSections: checkSourcesSections(root, markdownFiles, contractSink),
    idParity: checkIdParity(root, markdownFiles, errors),
    selfContainment: checkSelfContainment(root, files, args.requireSelfContainment ? errors : contractSink, { allow: args.allow, strict: args.requireSelfContainment, warningSink: contractFindings }),
    scriptRuntime: checkScriptRuntime(root, errors),
    frontmatterConstraints: checkFrontmatterConstraints(root, errors),
    coreLineBudget: checkCoreLineBudget(root, errors),
    referenceToc: checkReferenceToc(root, markdownFiles, errors),
    strayDocs: checkStrayDocs(root, errors),
    warnings: [...stalenessWarnings(root), ...contractFindings],
    errors,
  };
  result.ok = errors.length === 0;

  writeResult(result, args.json);
  return result.ok ? 0 : 1;
}

/**
 * @returns {{ ok: boolean, contractPackage: boolean, discoveryMetadata: null, requiredSections: null, links: null, codeFences: null, bilingualPairs: null, bilingualCoreParity: null, triggerCases: null, officialLastVerifiedGuard: null, sourcesSections: null, idParity: null, selfContainment: null, scriptRuntime: null, frontmatterConstraints: null, coreLineBudget: null, referenceToc: null, strayDocs: null, warnings: never[], errors: ValidationIssue[] }}
 */
function emptyResult() {
  return {
    ok: false,
    contractPackage: false,
    discoveryMetadata: null,
    requiredSections: null,
    links: null,
    codeFences: null,
    bilingualPairs: null,
    bilingualCoreParity: null,
    triggerCases: null,
    officialLastVerifiedGuard: null,
    sourcesSections: null,
    idParity: null,
    selfContainment: null,
    scriptRuntime: null,
    frontmatterConstraints: null,
    coreLineBudget: null,
    referenceToc: null,
    strayDocs: null,
    warnings: [],
    errors: [],
  };
}

/**
 * @param {{ ok: boolean, errors: ValidationIssue[] }} result
 * @param {boolean} json
 */
function writeResult(result, json) {
  if (json) {
    console.log(JSON.stringify(result, null, 2));
    return;
  }
  if (result.ok) {
    console.log("skill-maker validation passed");
  } else {
    console.error("skill-maker validation failed");
    for (const error of result.errors) {
      console.error(`${error.code}: ${error.message}`);
    }
  }
}

process.exit(run());
