#!/usr/bin/env bun
// @ts-check

/** Exercise the skill standard gate: baseline ratchet, integrity checks, and exception handling. */
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { expect, test } from "bun:test";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const gatePath = join(root, "scripts/check-skill-standards.mjs");

/**
 * @param {string[]} args
 * @returns {{ exitCode: number, stdout: string, stderr: string }}
 */
function runGate(args) {
  const result = Bun.spawnSync({ cmd: [process.execPath, gatePath, ...args], cwd: root, stdout: "pipe", stderr: "pipe" });
  return {
    exitCode: result.exitCode,
    stdout: new TextDecoder().decode(result.stdout),
    stderr: new TextDecoder().decode(result.stderr),
  };
}

/** @param {string} prefix */
function makeWorkspace(prefix) {
  const workspace = mkdtempSync(join(tmpdir(), prefix));
  const skillsDir = join(workspace, "skills");
  const baselinePath = join(workspace, "baseline.json");
  const exceptionsPath = join(workspace, "exceptions.json");
  mkdirSync(skillsDir, { recursive: true });
  writeFileSync(exceptionsPath, "{}\n");
  return { workspace, skillsDir, baselinePath, exceptionsPath };
}

/**
 * @param {string} skillsDir
 * @param {string} name
 * @param {string} [body]
 * @returns {string}
 */
function writeSkill(skillsDir, name, body = "# D\n") {
  const skillDir = join(skillsDir, name);
  mkdirSync(skillDir, { recursive: true });
  writeFileSync(join(skillDir, "SKILL.md"), `---\nname: ${name}\ndescription: "Use this skill when x"\n---\n\n${body}`);
  return skillDir;
}

/** @param {string} path @returns {Record<string, unknown>} */
function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

test("creates a baseline and reports zero regressions for a clean tree", () => {
  const { workspace, skillsDir, baselinePath, exceptionsPath } = makeWorkspace("hypercore-skill-standards-clean-");
  try {
    writeSkill(skillsDir, "demo");
    const created = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--update-baseline"]);
    expect(created.exitCode).toBe(0);
    const baseline = readJson(baselinePath);
    expect(Object.keys(/** @type {Record<string, unknown>} */ (baseline.skills))).toEqual(["demo"]);

    const checked = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]);
    expect(checked.exitCode).toBe(0);
    const report = JSON.parse(checked.stdout);
    expect(report.regressions).toBe(0);
    expect(Object.keys(report.counts)).toEqual(["demo"]);
  } finally {
    rmSync(workspace, { recursive: true, force: true });
  }
});

test("detects a regression above the baseline and exits 1", () => {
  const { workspace, skillsDir, baselinePath, exceptionsPath } = makeWorkspace("hypercore-skill-standards-regression-");
  try {
    const skillDir = writeSkill(skillsDir, "demo");
    expect(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--update-baseline"]).exitCode).toBe(0);
    writeFileSync(join(skillDir, "SKILL.md"), `${readFileSync(join(skillDir, "SKILL.md"), "utf8")}see skills/other/ for help\n`);

    const regressed = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]);
    expect(regressed.exitCode).toBe(1);
    const report = JSON.parse(regressed.stdout);
    expect(report.regressions).toBeGreaterThan(0);
    expect(report.counts.demo.CROSS_SKILL_REFERENCE).toBe(1);

    const human = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath]);
    expect(human.exitCode).toBe(1);
    expect(human.stdout).toContain("REGRESSION demo|CROSS_SKILL_REFERENCE count 1 > baseline 0");
  } finally {
    rmSync(workspace, { recursive: true, force: true });
  }
});

test("reports debt without changing the exit code", () => {
  const { workspace, skillsDir, baselinePath, exceptionsPath } = makeWorkspace("hypercore-skill-standards-debt-");
  try {
    writeSkill(skillsDir, "demo");
    expect(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--update-baseline"]).exitCode).toBe(0);

    const report = JSON.parse(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]).stdout);
    expect(report.regressions).toBe(0);
    expect(report.debt).toBeGreaterThan(0);
    expect(report.counts.demo.CONTRACT_FIELDS_MISSING).toBe(9);
    expect(report.counts.demo.EVAL_FIXTURE_MISSING).toBe(1);
  } finally {
    rmSync(workspace, { recursive: true, force: true });
  }
});

test("accepts an exception with a reason and rejects one without", () => {
  const { workspace, skillsDir, baselinePath, exceptionsPath } = makeWorkspace("hypercore-skill-standards-exception-");
  try {
    writeSkill(skillsDir, "demo");
    expect(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--update-baseline"]).exitCode).toBe(0);
    const baselined = JSON.parse(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]).stdout);

    writeFileSync(exceptionsPath, `${JSON.stringify({ "demo|CONTRACT_FIELDS_MISSING": "Accepted while the contract block is rewritten." })}\n`);
    const excepted = JSON.parse(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]).stdout);
    expect(excepted.debt).toBe(baselined.debt - 1);
    expect(Object.keys(excepted.exceptions)).toEqual(["demo|CONTRACT_FIELDS_MISSING"]);

    writeFileSync(exceptionsPath, `${JSON.stringify({ "demo|CONTRACT_FIELDS_MISSING": "" })}\n`);
    const reasonless = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]);
    expect(reasonless.exitCode).toBe(2);
    expect(reasonless.stderr).toContain("needs a reason");
  } finally {
    rmSync(workspace, { recursive: true, force: true });
  }
});

test("treats a missing, corrupt, or incomplete baseline as a configuration error", () => {
  const { workspace, skillsDir, baselinePath, exceptionsPath } = makeWorkspace("hypercore-skill-standards-integrity-");
  try {
    writeSkill(skillsDir, "demo");
    const missing = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]);
    expect(missing.exitCode).toBe(2);
    expect(missing.stderr).toContain("Baseline is missing");

    writeFileSync(baselinePath, "not json\n");
    const corrupt = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]);
    expect(corrupt.exitCode).toBe(2);
    expect(corrupt.stderr).toContain("not valid JSON");

    expect(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--update-baseline"]).exitCode).toBe(0);
    const baseline = readJson(baselinePath);
    writeFileSync(baselinePath, `${JSON.stringify({ skills: {} }, null, 2)}\n`);
    expect(Object.keys(/** @type {Record<string, unknown>} */ (baseline.skills))).toEqual(["demo"]);
    const incomplete = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--json"]);
    expect(incomplete.exitCode).toBe(2);
    expect(incomplete.stderr).toContain("Baseline has no entry for skill: demo");
  } finally {
    rmSync(workspace, { recursive: true, force: true });
  }
});

test("never writes the exceptions file when updating the baseline", () => {
  const { workspace, skillsDir, baselinePath, exceptionsPath } = makeWorkspace("hypercore-skill-standards-exceptions-readonly-");
  try {
    writeSkill(skillsDir, "demo");
    const declared = `${JSON.stringify({ "demo|CONTRACT_FIELDS_MISSING": "Kept by user decision." }, null, 2)}\n`;
    writeFileSync(exceptionsPath, declared);
    expect(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--update-baseline"]).exitCode).toBe(0);
    expect(readFileSync(exceptionsPath, "utf8")).toBe(declared);
  } finally {
    rmSync(workspace, { recursive: true, force: true });
  }
});

test("scans directories only and restricts the report with --skill", () => {
  const { workspace, skillsDir, baselinePath, exceptionsPath } = makeWorkspace("hypercore-skill-standards-scope-");
  try {
    writeSkill(skillsDir, "demo");
    writeSkill(skillsDir, "other");
    writeFileSync(join(skillsDir, "loose.md"), "# not a skill\n");
    writeFileSync(join(skillsDir, ".DS_Store"), "");
    symlinkSync(join(skillsDir, "demo"), join(skillsDir, "linked"));

    expect(runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--update-baseline"]).exitCode).toBe(0);
    const baseline = readJson(baselinePath);
    expect(Object.keys(/** @type {Record<string, unknown>} */ (baseline.skills))).toEqual(["demo", "other"]);

    const scoped = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--skill", "demo", "--json"]);
    expect(scoped.exitCode).toBe(0);
    expect(Object.keys(JSON.parse(scoped.stdout).counts)).toEqual(["demo"]);

    const unknown = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--skill", "absent", "--json"]);
    expect(unknown.exitCode).toBe(2);
    expect(unknown.stderr).toContain("Unknown skill: absent");

    const badFlag = runGate(["--root", skillsDir, "--baseline", baselinePath, "--exceptions", exceptionsPath, "--nope"]);
    expect(badFlag.exitCode).toBe(2);
    expect(badFlag.stderr).toContain("Unknown argument: --nope");
  } finally {
    rmSync(workspace, { recursive: true, force: true });
  }
});

test("resolves the default paths from the repository root, not the working directory", () => {
  const { workspace, skillsDir, baselinePath, exceptionsPath } = makeWorkspace("hypercore-skill-standards-cwd-");
  try {
    writeSkill(skillsDir, "demo");
    const result = Bun.spawnSync({ cmd: [process.execPath, gatePath, "--json"], cwd: tmpdir(), stdout: "pipe", stderr: "pipe" });
    // A cwd-relative resolution would fail with a configuration error instead of scanning the repository.
    expect([0, 1].includes(result.exitCode)).toBe(true);
    const report = JSON.parse(new TextDecoder().decode(result.stdout));
    expect(Object.keys(report.counts)).toContain("skill-maker");
    expect(existsSync(join(workspace, "scripts"))).toBe(false);
    expect(existsSync(baselinePath)).toBe(false);
    expect(readFileSync(exceptionsPath, "utf8")).toBe("{}\n");
  } finally {
    rmSync(workspace, { recursive: true, force: true });
  }
}, 30000);
