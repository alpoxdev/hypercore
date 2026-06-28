#!/usr/bin/env node
// allow: SIZE_OK - Standalone no-dependency CLI validator for one skill package.
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const REQUIRED_LAST_VERIFIED_AT = "2026-06-02";
const REQUIRED_SECTIONS = [
  "output_language",
  "purpose",
  "routing_rule",
  "instruction_contract",
  "activation_examples",
  "trigger_conditions",
  "skill_architecture",
  "language_and_translation_default",
  "reference_routing",
  "support_file_read_order",
  "workflow",
  "required",
  "forbidden",
  "validation",
];
const CATEGORY_FLOORS = {
  positive: 3,
  negative: 2,
  boundary: 1,
  source: 1,
  safety: 1,
};
const STRAY_DOC_NAMES = new Set(["README.md", "CHANGELOG.md", "QUICK_REFERENCE.md"]);

function parseArgs(argv) {
  const args = {
    root: "skills/skill-maker",
    evals: "skills/skill-maker/assets/evals/skill-maker-cases.jsonl",
    json: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--root") {
      args.root = requireValue(argv, (index += 1), arg);
    } else if (arg === "--evals") {
      args.evals = requireValue(argv, (index += 1), arg);
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

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw validationError("ARG_VALUE_MISSING", `${flag} requires a value`);
  }
  return value;
}

function validationError(code, message, extra = {}) {
  const error = new Error(message);
  error.code = code;
  Object.assign(error, extra);
  return error;
}

function walkFiles(root, errors = null) {
  const files = [];
  const stack = [root];
  while (stack.length > 0) {
    const current = stack.pop();
    let entries = [];
    try {
      entries = fs.readdirSync(current, { withFileTypes: true });
    } catch (error) {
      const item = errorObject("DIR_READ_FAILED", `Cannot read directory: ${path.relative(process.cwd(), current)}`, {
        path: path.relative(process.cwd(), current),
        detail: error.message,
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

function relative(root, filePath) {
  return path.relative(root, filePath).split(path.sep).join("/");
}

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function checkRequiredSections(root, errors) {
  const skillPath = path.join(root, "SKILL.md");
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

function checkLinks(root, markdownFiles, errors) {
  const checked = [];
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

function extractAtLinks(text) {
  const refs = [];
  const pattern = /^@([^\s]+\.md)\s*$/gm;
  let match;
  while ((match = pattern.exec(text)) !== null) {
    refs.push(match[1]);
  }
  return refs;
}

function extractMarkdownLinks(text) {
  const refs = [];
  const pattern = /!?\[[^\]\n]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g;
  let match;
  while ((match = pattern.exec(text)) !== null) {
    const href = match[1];
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

function stripAnchor(ref) {
  return decodeURIComponent(ref.split("#")[0]);
}

function isInside(root, target) {
  const relativePath = path.relative(root, target);
  return relativePath === "" || (!relativePath.startsWith("..") && !path.isAbsolute(relativePath));
}

function checkCodeFences(root, markdownFiles, errors) {
  const files = [];
  for (const filePath of markdownFiles) {
    const text = readText(filePath);
    const stack = [];
    const lines = text.split(/\r?\n/);
    for (let index = 0; index < lines.length; index += 1) {
      const match = /^(\s*)(`{3,}|~{3,})/.exec(lines[index]);
      if (!match) continue;
      const fence = match[2][0];
      if (stack.length > 0 && stack[stack.length - 1].fence === fence) {
        stack.pop();
      } else {
        stack.push({ fence, line: index + 1 });
      }
    }
    const balanced = stack.length === 0;
    const item = { path: relative(root, filePath), balanced };
    files.push(item);
    if (!balanced) {
      item.unclosed = stack;
      errors.push(errorObject("CODE_FENCE_UNBALANCED", `Unbalanced code fence in ${item.path}`, item));
    }
  }
  return { ok: files.every((file) => file.balanced), files };
}

function checkBilingualPairs(root, markdownFiles, errors) {
  const markdownSet = new Set(markdownFiles.map((filePath) => relative(root, filePath)));
  const missing = [];
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

function checkStrayDocs(root, errors) {
  const found = [];
  const stack = [{ dir: root, depth: 0 }];
  while (stack.length > 0) {
    const { dir, depth } = stack.pop();
    if (depth > 2) continue;
    let entries = [];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch (error) {
      errors.push(errorObject("DIR_READ_FAILED", `Cannot read directory while checking stray docs: ${relative(root, dir)}`, {
        path: relative(root, dir),
        detail: error.message,
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

function checkEvalCases(evalsPath, errors) {
  const rows = [];
  const counts = {};
  if (!fs.existsSync(evalsPath)) {
    errors.push(errorObject("EVAL_FILE_MISSING", `Eval JSONL file is missing: ${evalsPath}`, { path: evalsPath }));
    return { ok: false, path: evalsPath, total: 0, counts, required: CATEGORY_FLOORS };
  }

  const lines = readText(evalsPath).split(/\r?\n/);
  lines.forEach((line, index) => {
    const lineNumber = index + 1;
    if (line.trim() === "") return;
    let row;
    try {
      row = JSON.parse(line);
    } catch (error) {
      pushEvalError(errors, `Eval case line ${lineNumber} is not valid JSON: ${error.message}`, { line: lineNumber });
      return;
    }
    const rowErrors = validateEvalRow(row, lineNumber);
    for (const error of rowErrors) {
      pushEvalError(errors, error.message, error.extra);
    }
    if (row && typeof row === "object") {
      rows.push(row);
      counts[row.category] = (counts[row.category] || 0) + 1;
    }
  });

  for (const [category, floor] of Object.entries(CATEGORY_FLOORS)) {
    if ((counts[category] || 0) < floor) {
      errors.push(errorObject("EVAL_CATEGORY_COUNT", `Expected at least ${floor} ${category} eval case(s)`, {
        category,
        expected: floor,
        actual: counts[category] || 0,
      }));
    }
  }

  return {
    ok: !errors.some((error) => error.code.startsWith("EVAL_")),
    path: evalsPath,
    total: rows.length,
    counts,
    required: CATEGORY_FLOORS,
  };
}

function validateEvalRow(row, lineNumber) {
  const errors = [];
  const fail = (message, extra = {}) => errors.push({ message, extra: { line: lineNumber, ...extra } });
  if (!row || typeof row !== "object" || Array.isArray(row)) {
    fail("Eval case must be a JSON object");
    return errors;
  }
  if (!nonEmptyString(row.id)) fail("Eval case requires non-empty id", { id: row.id });
  if (!nonEmptyString(row.category)) fail("Eval case requires non-empty category", { id: row.id });
  if (!nonEmptyString(row.prompt)) fail("Eval case requires non-empty prompt", { id: row.id });
  if (!row.expected || typeof row.expected !== "object" || Array.isArray(row.expected)) {
    fail("EVAL_CASE_INVALID: eval case requires expected object", { id: row.id });
    return errors;
  }
  if (!Array.isArray(row.expected.must)) {
    fail("EVAL_CASE_INVALID: expected.must must be an array", { id: row.id });
  }
  if (!Array.isArray(row.expected.mustNot)) {
    fail("EVAL_CASE_INVALID: expected.mustNot must be an array", { id: row.id });
  }
  return errors;
}

function pushEvalError(errors, message, extra) {
  errors.push(errorObject("EVAL_CASE_INVALID", message.includes("EVAL_CASE_INVALID") ? message : `EVAL_CASE_INVALID: ${message}`, extra));
}

function checkOfficialLastVerified(root, errors) {
  const officialRoot = path.join(root, "references", "official");
  const files = fs.existsSync(officialRoot)
    ? walkFiles(officialRoot, errors).filter((filePath) => filePath.endsWith(".md"))
    : [];
  const invalid = [];
  for (const filePath of files) {
    const text = readText(filePath);
    const matches = [...text.matchAll(/last_verified_at:\s*([0-9]{4}-[0-9]{2}-[0-9]{2})/g)].map((match) => match[1]);
    const item = { path: relative(root, filePath), dates: matches };
    if (matches.length === 0 || matches.some((date) => date !== REQUIRED_LAST_VERIFIED_AT)) {
      invalid.push(item);
      errors.push(errorObject("OFFICIAL_LAST_VERIFIED_AT", `Official reference must keep last_verified_at: ${REQUIRED_LAST_VERIFIED_AT}`, item));
    }
  }
  return { ok: invalid.length === 0, required: REQUIRED_LAST_VERIFIED_AT, checked: files.length, invalid };
}

function nonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function errorObject(code, message, extra = {}) {
  return { code, message, ...extra };
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function printHelp() {
  console.log(`Usage: node skills/skill-maker/scripts/validate-skill-maker.mjs --root <dir> --evals <jsonl> [--json]

Validates the repository-local skill-maker package with Node built-ins only.

Options:
  --root <dir>     Skill root directory. Defaults to skills/skill-maker.
  --evals <file>   JSONL eval cases. Defaults to assets/evals/skill-maker-cases.jsonl.
  --json           Emit structured JSON.
  --help           Show this help.
`);
}

function run() {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    const result = emptyResult();
    result.errors.push(errorObject(error.code || "ARG_ERROR", error.message));
    writeResult(result, true);
    return 2;
  }

  if (args.help) {
    printHelp();
    return 0;
  }

  const root = path.resolve(args.root);
  const evalsPath = path.resolve(args.evals);
  const errors = [];

  if (!fs.existsSync(root) || !fs.statSync(root).isDirectory()) {
    errors.push(errorObject("ROOT_MISSING", `Root directory is missing: ${args.root}`, { path: args.root }));
  }

  const files = fs.existsSync(root) ? walkFiles(root, errors) : [];
  const markdownFiles = files.filter((filePath) => filePath.endsWith(".md"));
  const result = {
    ok: false,
    requiredSections: checkRequiredSections(root, errors),
    links: checkLinks(root, markdownFiles, errors),
    codeFences: checkCodeFences(root, markdownFiles, errors),
    bilingualPairs: checkBilingualPairs(root, markdownFiles, errors),
    triggerCases: checkEvalCases(evalsPath, errors),
    officialLastVerifiedGuard: checkOfficialLastVerified(root, errors),
    strayDocs: checkStrayDocs(root, errors),
    errors,
  };
  result.ok = errors.length === 0;

  writeResult(result, args.json);
  return result.ok ? 0 : 1;
}

function emptyResult() {
  return {
    ok: false,
    requiredSections: null,
    links: null,
    codeFences: null,
    bilingualPairs: null,
    triggerCases: null,
    officialLastVerifiedGuard: null,
    strayDocs: null,
    errors: [],
  };
}

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
