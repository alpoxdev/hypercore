#!/usr/bin/env node
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join, normalize, relative, resolve, sep } from 'node:path';

const DEFAULT_ROOT = 'skills';

function parseArgs(argv) {
  const args = {
    root: DEFAULT_ROOT,
    only: null,
    json: false,
    help: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === '--root') {
      args.root = requireValue(argv, (index += 1), arg);
    } else if (arg === '--only') {
      args.only = requireValue(argv, (index += 1), arg)
        .split(',')
        .map((name) => name.trim())
        .filter(Boolean);
    } else if (arg === '--json') {
      args.json = true;
    } else if (arg === '--help' || arg === '-h') {
      args.help = true;
    } else {
      throw makeError('ARG_UNKNOWN', `Unknown argument: ${arg}`);
    }
  }

  return args;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith('--')) {
    throw makeError('ARG_VALUE_MISSING', `${flag} requires a value`);
  }
  return value;
}

function printHelp() {
  console.log(`Usage: node skills/skill-tester/scripts/validate-skills-corpus.mjs --root <skills-dir> [--only a,b,c] [--json]

Validates a repository-local skills corpus with Node built-ins only.

Options:
  --root <dir>     Directory containing top-level skill folders. Defaults to skills.
  --only <names>   Comma-separated folder names to validate as a subset.
  --json           Emit structured JSON.
  --help           Show this help.
`);
}

function makeError(code, message, extra = {}) {
  const error = new Error(message);
  error.code = code;
  Object.assign(error, extra);
  return error;
}

function errorObject(code, message, extra = {}) {
  return { code, message, ...extra };
}

function normalizePath(filePath) {
  return filePath.split(sep).join('/');
}

function displayPath(filePath) {
  const rel = relative(process.cwd(), filePath);
  return normalizePath(rel || filePath);
}

function listTopLevelDirectories(rootAbs, errors) {
  try {
    return readdirSync(rootAbs, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .sort();
  } catch (error) {
    errors.push(errorObject('ROOT_READ_FAILED', `Cannot read skills root: ${displayPath(rootAbs)}`, {
      path: displayPath(rootAbs),
      detail: error.message,
    }));
    return [];
  }
}

function walkMarkdownFiles(dirAbs, errors) {
  const files = [];
  const stack = [dirAbs];
  while (stack.length > 0) {
    const current = stack.pop();
    let entries = [];
    try {
      entries = readdirSync(current, { withFileTypes: true });
    } catch (error) {
      errors.push(errorObject('DIR_READ_FAILED', `Cannot read directory: ${displayPath(current)}`, {
        path: displayPath(current),
        detail: error.message,
      }));
      continue;
    }

    for (const entry of entries) {
      const fullPath = join(current, entry.name);
      if (entry.isDirectory()) {
        stack.push(fullPath);
      } else if (entry.isFile() && entry.name.endsWith('.md')) {
        files.push(fullPath);
      }
    }
  }
  return files.sort();
}

function readText(filePath) {
  return readFileSync(filePath, 'utf8');
}

function validateSkill(rootAbs, skillName) {
  const skillDir = join(rootAbs, skillName);
  const skillRel = normalizePath(relative(rootAbs, skillDir));
  const skillPath = join(skillDir, 'SKILL.md');
  const failures = [];
  const warnings = [];
  const checks = {
    skillFile: false,
    frontmatter: false,
    name: false,
    description: false,
    supportLinks: false,
    bilingualPairs: false,
    codeFences: false,
  };

  if (!existsSync(skillPath)) {
    failures.push(errorObject('SKILL_MISSING', `Missing SKILL.md for skill: ${skillName}`, {
      skill: skillName,
      path: normalizePath(join(skillRel, 'SKILL.md')),
    }));
  } else {
    checks.skillFile = true;
    validateSkillFile(skillDir, skillPath, skillName, failures, warnings, checks);
  }

  const markdownFiles = existsSync(skillDir) ? walkMarkdownFiles(skillDir, failures) : [];
  validateBilingualPairs(skillDir, markdownFiles, failures, checks);
  validateCodeFences(skillDir, markdownFiles, failures, checks);

  return {
    name: skillName,
    path: normalizePath(relative(process.cwd(), skillDir)),
    ok: failures.length === 0,
    failures,
    warnings,
    checks,
  };
}

function validateSkillFile(skillDir, skillPath, skillName, failures, warnings, checks) {
  const body = readText(skillPath);
  if (body.startsWith('---\n')) {
    const end = body.indexOf('\n---', 4);
    checks.frontmatter = end !== -1;
    if (!checks.frontmatter) {
      failures.push(errorObject('FRONTMATTER_UNCLOSED', `SKILL.md frontmatter is not closed: ${skillName}`, {
        skill: skillName,
        path: normalizePath(relative(skillDir, skillPath)),
      }));
    }
  } else {
    failures.push(errorObject('FRONTMATTER_MISSING', `SKILL.md must start with YAML frontmatter: ${skillName}`, {
      skill: skillName,
      path: normalizePath(relative(skillDir, skillPath)),
    }));
  }

  const nameMatch = /^name:\s*(\S+)\s*$/m.exec(body);
  if (!nameMatch) {
    failures.push(errorObject('NAME_MISSING', `Frontmatter is missing name: ${skillName}`, {
      skill: skillName,
      path: 'SKILL.md',
    }));
  } else if (nameMatch[1] !== skillName) {
    failures.push(errorObject('NAME_MISMATCH', `Frontmatter name must match folder name: ${skillName}`, {
      skill: skillName,
      expected: skillName,
      actual: nameMatch[1],
      path: 'SKILL.md',
    }));
  } else {
    checks.name = true;
  }

  if (/^description:\s*(?:"[^"]+"|'[^']+'|\S.+)\s*$/m.test(body)) {
    checks.description = true;
  } else {
    failures.push(errorObject('DESCRIPTION_MISSING', `Frontmatter is missing a non-empty description: ${skillName}`, {
      skill: skillName,
      path: 'SKILL.md',
    }));
  }

  const supportLinks = [...body.matchAll(/^@([^\r\n]+)$/gm)].map((match) => match[1].trim());
  const missingLinks = [];
  for (const link of supportLinks) {
    const target = resolve(dirname(skillPath), link);
    if (!isInside(skillDir, target) || !existsSync(target)) {
      missingLinks.push(link);
      failures.push(errorObject('SUPPORT_LINK_MISSING', `Direct support link does not resolve: ${skillName} -> ${link}`, {
        skill: skillName,
        path: 'SKILL.md',
        href: link,
      }));
    }
  }
  checks.supportLinks = missingLinks.length === 0;

  const lines = body.split(/\r?\n/).length;
  if (lines > 300) {
    warnings.push(errorObject('SKILL_LONG', `SKILL.md is long (${lines} lines); consider moving detail to rules or references.`, {
      skill: skillName,
      path: 'SKILL.md',
      lines,
    }));
  }
}

function validateBilingualPairs(skillDir, markdownFiles, failures, checks) {
  const markdownSet = new Set(markdownFiles.map((filePath) => normalizePath(relative(skillDir, filePath))));
  const missing = [];
  const orphan = [];

  for (const relPath of markdownSet) {
    if (relPath.endsWith('.ko.md')) {
      const source = `${relPath.slice(0, -6)}.md`;
      if (!markdownSet.has(source)) {
        orphan.push(relPath);
      }
    } else {
      const korean = relPath.replace(/\.md$/, '.ko.md');
      if (!markdownSet.has(korean)) {
        missing.push(korean);
      }
    }
  }

  for (const relPath of missing) {
    failures.push(errorObject('BILINGUAL_PAIR_MISSING', `Missing Korean markdown sibling: ${relPath}`, {
      path: relPath,
    }));
  }
  for (const relPath of orphan) {
    failures.push(errorObject('BILINGUAL_PAIR_ORPHAN', `Korean markdown sibling has no English source: ${relPath}`, {
      path: relPath,
    }));
  }
  checks.bilingualPairs = missing.length === 0 && orphan.length === 0;
}

function validateCodeFences(skillDir, markdownFiles, failures, checks) {
  let ok = true;
  for (const filePath of markdownFiles) {
    const relPath = normalizePath(relative(skillDir, filePath));
    const lines = readText(filePath).split(/\r?\n/);
    const stack = [];
    for (let index = 0; index < lines.length; index += 1) {
      const match = /^(\s*)(`{3,}|~{3,})/.exec(lines[index]);
      if (!match) continue;
      const marker = match[2][0];
      if (stack.length > 0 && stack[stack.length - 1].marker === marker) {
        stack.pop();
      } else {
        stack.push({ marker, line: index + 1 });
      }
    }
    if (stack.length > 0) {
      ok = false;
      failures.push(errorObject('CODE_FENCE_UNBALANCED', `Unbalanced code fence in ${relPath}`, {
        path: relPath,
        unclosed: stack,
      }));
    }
  }
  checks.codeFences = ok;
}

function isInside(root, target) {
  const rel = relative(root, target);
  return rel === '' || (!rel.startsWith('..') && !rel.startsWith('/') && !rel.match(/^[A-Za-z]:/));
}

function buildResult(args) {
  const rootAbs = resolve(normalize(args.root));
  const errors = [];

  if (!existsSync(rootAbs) || !statSync(rootAbs).isDirectory()) {
    return {
      ok: false,
      root: normalizePath(args.root),
      totalTopLevelSkills: 0,
      selectedSkills: args.only || [],
      selectedCount: 0,
      checkedCount: 0,
      summary: { passed: 0, failed: 0, warnings: 0 },
      skills: [],
      errors: [
        errorObject('ROOT_MISSING', `Skills root is not a directory: ${args.root}`, {
          path: args.root,
        }),
      ],
    };
  }

  const topLevelSkills = listTopLevelDirectories(rootAbs, errors);
  const selectedNames = args.only || topLevelSkills;
  const unknown = selectedNames.filter((name) => !topLevelSkills.includes(name));
  for (const name of unknown) {
    errors.push(errorObject('SKILL_NOT_FOUND', `Requested skill is not present under root: ${name}`, {
      skill: name,
    }));
  }

  const skills = selectedNames
    .filter((name) => topLevelSkills.includes(name))
    .map((name) => validateSkill(rootAbs, name));

  const failed = skills.filter((skill) => !skill.ok).length;
  const warnings = skills.reduce((count, skill) => count + skill.warnings.length, 0);
  const validationErrors = skills.flatMap((skill) => skill.failures.map((failure) => ({
    ...failure,
    skill: failure.skill || skill.name,
  })));
  const allErrors = [...errors, ...validationErrors];

  return {
    ok: allErrors.length === 0,
    root: normalizePath(relative(process.cwd(), rootAbs) || args.root),
    totalTopLevelSkills: topLevelSkills.length,
    selectedSkills: selectedNames,
    selectedCount: selectedNames.length,
    checkedCount: skills.length,
    summary: {
      passed: skills.length - failed,
      failed,
      warnings,
    },
    skills,
    errors: allErrors,
  };
}

function writeResult(result, json) {
  if (json) {
    console.log(JSON.stringify(result, null, 2));
    return;
  }

  if (result.ok) {
    console.log(`skills corpus validation passed: ${result.checkedCount}/${result.selectedCount} selected skill(s) checked`);
    return;
  }

  console.error('skills corpus validation failed');
  for (const error of result.errors) {
    console.error(`${error.code}: ${error.message}`);
  }
}

function run() {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    const result = {
      ok: false,
      root: DEFAULT_ROOT,
      totalTopLevelSkills: 0,
      selectedSkills: [],
      selectedCount: 0,
      checkedCount: 0,
      summary: { passed: 0, failed: 0, warnings: 0 },
      skills: [],
      errors: [errorObject(error.code || 'ARG_ERROR', error.message)],
    };
    writeResult(result, true);
    return 2;
  }

  if (args.help) {
    printHelp();
    return 0;
  }

  const result = buildResult(args);
  writeResult(result, args.json);
  return result.ok ? 0 : 1;
}

process.exit(run());
