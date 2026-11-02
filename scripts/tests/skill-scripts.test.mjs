#!/usr/bin/env bun
// @ts-check

/** Exercise the immutable skill-script manifest and harmless Bun subprocess paths. */
import { createHash } from "node:crypto";
import { chmodSync, copyFileSync, cpSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, rmSync, statSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { expect, test } from "bun:test";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const manifestPath = join(root, "scripts/fixtures/skill-script-parity/manifest.json");
const contractsPath = join(root, "scripts/fixtures/skill-script-parity/behavior/contracts.json");
const validatorPath = join(root, "scripts/validate-skills.mjs");
const currentVersionPath = join(root, "skills/version-update/scripts/version-current.sh");
const versionApplyPath = join(root, "skills/version-update/scripts/version-apply.sh");
const versionGitCommitPath = join(root, "skills/version-update/scripts/git-commit.sh");
const versionGitPushPath = join(root, "skills/version-update/scripts/git-push.sh");
const deployCheckPath = join(root, "skills/pre-deploy/scripts/deploy-check.sh");
const gitMakerCommitPath = join(root, "skills/git-maker/scripts/git-commit.sh");
const repoDiscoverPath = join(root, "skills/git-maker/scripts/repo-discover.sh");
const repoStatusPath = join(root, "skills/git-maker/scripts/repo-status.sh");
const gitMakerFastPath = join(root, "skills/git-maker/scripts/git-maker-fast.sh");
const legacyPreimageBase = "990359457e2ccbf2bd4bb65065037d456c5940bc";
/** The migration ref holds the pre-rename `.js` blob of the one script this change moved to `.mjs`. */
const migrationPreimageRef = "d648cf6eeba28402f0b3c1265ca5d9f05995a131";
/**
 * Pre-migration preimages keyed by the renamed script's current path. Every rename in the
 * inventory must appear here and nowhere else, so a stale hash, a moved ref, or an
 * unrecorded rename fails the inventory test instead of passing silently.
 * @type {Record<string, { fromPath: string, fromSha256: string, fromMode: string, fromRef: string }>}
 */
const migrationPreimages = {
  "skills/ai-design-slop-remover/scripts/analyze-structure.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/analyze-structure.cjs",
    fromSha256: "9b379e486755ea09729d7b52097718868ef8817dbb4e9169e9bcab34152eb8d0",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/collect-rendered-evidence.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/collect-rendered-evidence.cjs",
    fromSha256: "562f561401694e9e8b0377a88e0a48884812929ca50c7c6e202896119ab1d7a3",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/detect-slop.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/detect-slop.cjs",
    fromSha256: "17e5c21a8eec75f0f4638196f67aca8de0bf5ff49b6bb6ff71c9d156e56e847a",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/engine-css.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/engines/css.cjs",
    fromSha256: "2cc502ed2086a4ff293a153e7981da7738dc019cbd3fd0d64ce1da1418d7a03c",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/engine-markup.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/engines/markup.cjs",
    fromSha256: "d283db47e8a7464a29a08ad2035e77e46a895a11693eb4b40842628caff06161",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/engine-text.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/engines/text.cjs",
    fromSha256: "d892fa19e78bc785631ec8ca0d472566a160898b035345a9c9136db49c91a7df",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/resolve-context.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/resolve-context.cjs",
    fromSha256: "4cd95ded813c423e0c3deba3e4af9240d38e4c88d5ca6e15e5be9fae5f8a27cc",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/rule-registry.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/rules/registry.cjs",
    fromSha256: "67492b55d8417e73ecdad9b32de902aca674cdd576f7cc9f920c595f8694db05",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/rule-shared.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/rules/shared.cjs",
    fromSha256: "0d4f0fec0192872ec25a459426ceae5707c45befa71a203de21a12f4088a40ce",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/run-contract-evals.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/run-contract-evals.cjs",
    fromSha256: "f9d5abe484d028aebcd7dad92e90dbc77ee6144f9ee96db98cb9393d5c7bca5b",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/run-detector-evals.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/run-detector-evals.cjs",
    fromSha256: "fddb35e5a47670733d2b85f657b88e6136d0bad7482d3e652bd3129466c4dbf4",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/validate-report.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/validate-report.cjs",
    fromSha256: "0876b9f0c9291cc590c406fb6552363de33303b9fdb244dfcd940d85798c7d1f",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/ai-design-slop-remover/scripts/validate-waivers.sh": {
    fromPath: "skills/ai-design-slop-remover/scripts/validate-waivers.cjs",
    fromSha256: "f288eaeca8342136488d50ba456dfc00acc2fa78177ce356cb9256691075f1f7",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
  "skills/skill-tester/scripts/validate-skill-tester.sh": {
    fromPath: "skills/skill-tester/scripts/validate-skill-tester.js",
    fromSha256: "978399934eee9ee856d07ae6703c6181ab4ec2c25e19ab420107682b0bebee56",
    fromMode: "100644",
    fromRef: migrationPreimageRef,
  },
};

/** @param {string} text @param {string} cwd */
function normalizeOutput(text, cwd) {
  return text
    .replaceAll(root, "<repo>")
    .replaceAll(`/private${cwd}`, "<cwd>")
    .replaceAll(cwd, "<cwd>")
    .replace(/\/(?:Users|home)\/[^/\n]+(?:\/[^:\n"' )]+)*/g, "<absolute-path>")
    .replace(/Bun v[\d.]+ \([^)]+\)/g, "Bun v<version> (<os> <arch>)")
    .replace(/:\d+:\d+/g, ":<line>:<column>");
}

/** @param {{ equals?: string, contains?: string[] }} expected @param {string} actual @param {string} cwd */
function expectOutput(expected, actual, cwd) {
  const normalized = normalizeOutput(actual, cwd);
  if (expected.equals !== undefined) expect(normalized).toBe(expected.equals);
  else for (const substring of expected.contains ?? []) expect(normalized).toContain(substring);
}

/** @param {string[]} command @param {string} cwd @param {Record<string, string | undefined>} [env] */
function run(command, cwd, env) {
  const result = Bun.spawnSync({ cmd: command, cwd, env, stdout: "pipe", stderr: "pipe" });
  return {
    exitCode: result.exitCode,
    stdout: new TextDecoder().decode(result.stdout),
    stderr: new TextDecoder().decode(result.stderr),
  };
}
/** @param {string} directory */
function filesBelow(directory) {
  /** @type {string[]} */
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const file = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...filesBelow(file));
    else if (entry.isFile() && file.endsWith(".sh")) files.push(file);
  }
  return files;
}

/**
 * Pins the pre-migration blob of a renamed script: the recorded object must match the migration
 * ref's bytes and tree mode exactly, so a stale hash or a moved ref cannot pass silently.
 *
 * @param {{ path: string, sourcePreimage: { migration?: { fromPath: string, fromSha256: string, fromMode: string, fromRef: string } } }} row
 */
function expectMigrationEvidence(row) {
  const migration = row.sourcePreimage.migration;
  expect(migration).toEqual(migrationPreimages[row.path]);
  const migrated = run(["git", "show", `${migration.fromRef}:${migration.fromPath}`], root);
  expect(migrated.exitCode).toBe(0);
  expect(createHash("sha256").update(migrated.stdout).digest("hex")).toBe(migration.fromSha256);
  const tree = run(["git", "ls-tree", migration.fromRef, "--", migration.fromPath], root).stdout.trim().split(/\s+/);
  expect(tree[0]).toBe(migration.fromMode);
  expect(tree[1]).toBe("blob");
  expect(tree[3]).toBe(migration.fromPath);
}

/** @param {string} fixture */
function initializeGit(fixture) {
  expect(run(["git", "init", "-q"], fixture).exitCode).toBe(0);
  expect(run(["git", "config", "user.name", "Test"], fixture).exitCode).toBe(0);
  expect(run(["git", "config", "user.email", "test@example.com"], fixture).exitCode).toBe(0);
}

/** @param {string} fixture @param {string} source */
function writeFakeGit(fixture, source) {
  const bin = join(fixture, "bin");
  mkdirSync(bin);
  const executable = join(bin, "git");
  writeFileSync(executable, source);
  chmodSync(executable, 0o755);
  return { ...process.env, PATH: `${bin}:${process.env.PATH ?? ""}` };
}

/** Kill a fixture child recorded in a PID file, ignoring processes that already exited. @param {string} pidFile */
function killRecordedPid(pidFile) {
  if (!existsSync(pidFile)) return;
  const pid = Number(readFileSync(pidFile, "utf8").trim());
  if (!Number.isInteger(pid) || pid <= 1) return;
  try { process.kill(pid, "SIGKILL"); } catch {}
}


test("manifest centrally inventories 44 scripts including fifteen authored baseline-absent MJS paths", () => {
  const manifest = /** @type {{ scripts: { path: string, family: string, legacyOrigin: string, usage: string, behavior: string }[], forbiddenDetectorReferences: { records: { literal: string, allowedLocations: { file: string, jsonPath: string }[] }[] }, versionUpdateDetectorAbsentCorrection: { detectorRestored: boolean, legacyFiles: { legacyPath: string, sha256: string, gitMode: string, finalPath: string }[], restoreOrder: string[] } }} */ (JSON.parse(readFileSync(manifestPath, "utf8")));
  expect(manifest.scripts).toHaveLength(44);
  expect(new Set(manifest.scripts.map((row) => row.path)).size).toBe(44);
  expect(manifest.scripts.every((row) => [row.path, row.family, row.legacyOrigin, row.usage, row.behavior].every(Boolean))).toBe(true);
  expect(Object.fromEntries(["former-sh", "former-py", "retained-mjs", "authored-mjs"].map((origin) => [
    origin,
    manifest.scripts.filter((row) => row.legacyOrigin === origin).length,
  ]))).toEqual({ "former-sh": 19, "former-py": 1, "retained-mjs": 9, "authored-mjs": 15 });
  const authored = [
    "skills/ai-design-slop-remover/scripts/analyze-structure.sh",
    "skills/ai-design-slop-remover/scripts/collect-rendered-evidence.sh",
    "skills/ai-design-slop-remover/scripts/detect-slop.sh",
    "skills/ai-design-slop-remover/scripts/engine-css.sh",
    "skills/ai-design-slop-remover/scripts/engine-markup.sh",
    "skills/ai-design-slop-remover/scripts/engine-text.sh",
    "skills/ai-design-slop-remover/scripts/resolve-context.sh",
    "skills/ai-design-slop-remover/scripts/rule-registry.sh",
    "skills/ai-design-slop-remover/scripts/rule-shared.sh",
    "skills/ai-design-slop-remover/scripts/run-contract-evals.sh",
    "skills/ai-design-slop-remover/scripts/run-detector-evals.sh",
    "skills/ai-design-slop-remover/scripts/validate-report.sh",
    "skills/ai-design-slop-remover/scripts/validate-waivers.sh",
    "skills/jev-maker/scripts/check-jev-request.sh",
    "skills/skill-tester/scripts/validate-skill-tester.sh",
  ];
  expect(manifest.scripts.map((row) => row.path).sort()).toEqual(filesBelow(join(root, "skills")).map((file) => relative(root, file)).sort());
  expect(manifest.scripts.filter((row) => row.legacyOrigin === "authored-mjs").map((row) => row.path).sort()).toEqual(authored);
  expect(manifest.scripts.filter((row) => row.sourcePreimage.migration).map((row) => row.path).sort()).toEqual(Object.keys(migrationPreimages).sort());
  for (const path of authored) {
    const row = manifest.scripts.find((candidate) => candidate.path === path);
    const historicalPath = path.replace(/\.sh$/, ".mjs");
    expect(row.sourcePreimage.baselineAbsence).toEqual({ baselineRef: legacyPreimageBase, path: historicalPath, absent: true });
    expect(run(["git", "cat-file", "-e", `${legacyPreimageBase}:${historicalPath}`], root).exitCode).not.toBe(0);
    if (row.sourcePreimage.migration) expectMigrationEvidence(row);
  }
  expect(manifest.forbiddenDetectorReferences.records).toHaveLength(6);
  expect(manifest.forbiddenDetectorReferences.records.every((row) => row.literal && row.allowedLocations.length === 1)).toBe(true);
  expect(manifest.versionUpdateDetectorAbsentCorrection.detectorRestored).toBe(false);
  expect(manifest.versionUpdateDetectorAbsentCorrection.legacyFiles).toHaveLength(7);
  expect(manifest.versionUpdateDetectorAbsentCorrection.legacyFiles.every((row) => /^[a-f0-9]{64}$/.test(row.sha256) && row.gitMode === "100755")).toBe(true);
  expect(manifest.versionUpdateDetectorAbsentCorrection.restoreOrder.length).toBeGreaterThanOrEqual(4);
});
/** @param {string} directory */
function observableFiles(directory) {
  /** @type {{ path: string, bytes: number, sha256: string }[]} */
  const files = [];
  /** @type {Record<string, string>} */
  const modes = {};
  for (const entry of readdirSync(directory, { withFileTypes: true, recursive: true })) {
    if (!entry.isFile()) continue;
    const path = relative(directory, join(entry.parentPath, entry.name));
    const bytes = readFileSync(join(directory, path));
    const normalized = Buffer.from(bytes.toString().replaceAll(directory, "<cwd>").replace(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/g, "<timestamp>"));
    files.push({ path, bytes: normalized.length, sha256: createHash("sha256").update(normalized).digest("hex") });
    modes[path] = (statSync(join(directory, path)).mode & 0o777).toString(8);
  }
  return { files: files.sort((left, right) => left.path < right.path ? -1 : left.path > right.path ? 1 : 0), modes };
}

/** @param {{ path: string, text: string, mode?: string }[]} files @param {string} cwd */
function materializeFixture(files, cwd) {
  for (const file of files) {
    const target = join(cwd, file.path);
    mkdirSync(dirname(target), { recursive: true });
    writeFileSync(target, file.text);
    if (file.mode) chmodSync(target, Number.parseInt(file.mode, 8));
  }
}

test("behavior contracts execute all 132 isolated semantic fixtures with exact observables", () => {
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  const contracts = JSON.parse(readFileSync(contractsPath, "utf8"));
  const dimensions = ["stdout", "stderr", "exit", "files", "modes", "cwd", "env", "argv"];
  expect(contracts.requiredBy).toBe(relative(root, manifestPath));
  expect(manifest.legacyPreimageBase).toBe(legacyPreimageBase);
  expect(contracts.legacyPreimageBase).toBe(legacyPreimageBase);
  expect(contracts.coverage.expectedRows).toBe(44);
  expect(contracts.coverage.expectedFixtures).toBe(132);
  expect(contracts.coverage.legacyOriginCounts).toEqual({ "former-sh": 19, "former-py": 1, "retained-mjs": 9, "authored-mjs": 15 });
  expect(contracts.rows).toHaveLength(44);
  expect(contracts.rows.filter((row) => row.sourcePreimage.migration).map((row) => row.path).sort()).toEqual(Object.keys(migrationPreimages).sort());
  let cases = 0;
  for (const row of contracts.rows) {
    const manifestRow = manifest.scripts.find((candidate) => candidate.path === row.path);
    expect(manifestRow).toBeDefined();
    expect(row.id).toBe(manifestRow.behaviorContractId);
    expect(Object.keys(row.fixtures).sort()).toEqual(["familyEdge", "happy", "malformed"]);
    expect(Object.keys(row.dimensions).sort()).toEqual(dimensions.slice().sort());
    /** @type {string[]} */
    const normalizedObservables = [];
    for (const [kind, fixture] of Object.entries(row.fixtures)) {
      cases += 1;
      expect(fixture.scenario).toBe(kind);
      expect(fixture.command).toEqual({ executable: "bash", arguments: [row.path] });
      expect(fixture.input.cwd).toBe("isolated-temp-tree");
      expect(fixture.input.env).toEqual({ NO_COLOR: "1" });
      expect(Array.isArray(fixture.input.files)).toBe(true);
      const cwd = mkdtempSync(join(tmpdir(), "hypercore-skill-script-contract-"));
      try {
        materializeFixture(fixture.input.files, cwd);
        const env = { ...process.env, ...fixture.input.env };
        if (fixture.input.fakeGit) env.PATH = writeFakeGit(cwd, "#!/bin/sh\ncase \"$1\" in rev-parse) pwd;; status) echo \"## fixture\";; diff) exit 0;; *) exit 0;; esac\n").PATH;
        const result = run([fixture.command.executable, join(root, ...fixture.command.arguments), ...fixture.input.argv], cwd, env);
        expect(result.exitCode).toBe(fixture.expected.exit);
        expectOutput(fixture.expected.stdout, result.stdout, cwd);
        expectOutput(fixture.expected.stderr, result.stderr, cwd);
        const observed = observableFiles(cwd);
        const byPath = (left, right) => left.path.localeCompare(right.path);
        expect(observed.files.sort(byPath)).toEqual([...fixture.expected.files].sort(byPath));
        expect(observed.modes).toEqual(fixture.expected.modes);
        normalizedObservables.push(JSON.stringify({
          exit: result.exitCode,
          stdout: normalizeOutput(result.stdout, cwd),
          stderr: normalizeOutput(result.stderr, cwd),
          files: observableFiles(cwd),
        }));
        expect(fixture.expected.cwd).toBe(fixture.input.cwd);
        expect(fixture.expected.env).toEqual(fixture.input.env);
        expect(fixture.expected.argv).toEqual(fixture.input.argv);
      } finally { rmSync(cwd, { recursive: true, force: true }); }
    }
    if (["nextjs-architecture", "prompt-maker", "skill-maker", "vite-architecture"].includes(row.family)) {
      expect(new Set(normalizedObservables).size).toBe(3);
    }
    if (manifestRow.legacyOrigin === "authored-mjs") {
      const historicalPath = row.path.replace(/\.sh$/, ".mjs");
      expect(row.sourcePreimage.baselineAbsence).toEqual({ baselineRef: legacyPreimageBase, path: historicalPath, absent: true });
      expect(run(["git", "cat-file", "-e", `${legacyPreimageBase}:${historicalPath}`], root).exitCode).not.toBe(0);
      if (row.sourcePreimage.migration) expectMigrationEvidence(row);
    } else {
      const source = run(["git", "show", `${manifest.legacyPreimageBase}:${row.sourcePreimage.path}`], root);
      expect(source.exitCode).toBe(0);
      expect(createHash("sha256").update(source.stdout).digest("hex")).toBe(row.sourcePreimage.sha256);
    }
  }
  expect(cases).toBe(132);
}, 300_000);

test("detector-absent correction restores legacy bytes and reapplies the exact final filesystem state", () => {
  const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  const contracts = JSON.parse(readFileSync(contractsPath, "utf8"));
  const correction = contracts.detectorAbsentCorrection;
  expect(correction.absenceEvidence).toContain("exact 30-entrypoint inventory");
  expect(correction.legacyFiles).toEqual(manifest.versionUpdateDetectorAbsentCorrection.legacyFiles);

  const fixture = mkdtempSync(join(tmpdir(), "hypercore-detector-absent-"));
  const restore = (path, content, mode) => {
    const target = join(fixture, path);
    mkdirSync(dirname(target), { recursive: true });
    writeFileSync(target, content);
    chmodSync(target, Number.parseInt(mode, 8) & 0o777);
    return target;
  };
  try {
    for (const baseline of correction.legacyFiles) {
      const restored = run(["git", "show", `${legacyPreimageBase}:${baseline.legacyPath}`], root);
      expect(restored.exitCode).toBe(0);
      const target = restore(baseline.legacyPath, restored.stdout, baseline.gitMode);
      expect(createHash("sha256").update(readFileSync(target)).digest("hex")).toBe(baseline.sha256);
      expect((statSync(target).mode & 0o777).toString(8)).toBe("755");
    }
    for (const baseline of correction.pairedDirectShDocuments) {
      const restored = run(["git", "show", `${legacyPreimageBase}:${baseline.path}`], root);
      expect(restored.exitCode).toBe(0);
      const target = restore(baseline.path, restored.stdout, baseline.gitMode);
      expect(createHash("sha256").update(readFileSync(target)).digest("hex")).toBe(baseline.sha256);
      expect((statSync(target).mode & 0o777).toString(8)).toBe("644");
      for (const command of baseline.commands) expect(readFileSync(target, "utf8")).toContain(command);
    }

    const caller = correction.callerRestoration;
    const restoredCaller = join(fixture, caller.legacyCaller);
    expect(createHash("sha256").update(readFileSync(restoredCaller)).digest("hex")).toBe(caller.legacyCallerSha256);
    expect(readFileSync(restoredCaller, "utf8")).toContain("version-find.sh");

    for (const baseline of correction.legacyFiles) {
      const final = join(root, baseline.finalPath);
      const target = restore(baseline.finalPath, readFileSync(final), `0${(statSync(final).mode & 0o777).toString(8)}`);
      expect(readFileSync(target)).toEqual(readFileSync(final));
      expect((statSync(target).mode & 0o777)).toBe(statSync(final).mode & 0o777);
      if (baseline.legacyPath !== baseline.finalPath) rmSync(join(fixture, baseline.legacyPath));
    }
    for (const baseline of correction.pairedDirectShDocuments) {
      const final = join(root, baseline.path);
      const target = restore(baseline.path, readFileSync(final), `0${(statSync(final).mode & 0o777).toString(8)}`);
      expect(readFileSync(target)).toEqual(readFileSync(final));
      for (const command of manifest.versionUpdateDetectorAbsentCorrection.documents.finalCommands) {
        expect(readFileSync(target, "utf8")).toContain(command);
      }
    }
    if (caller.legacyCaller !== caller.finalCaller) expect(existsSync(join(fixture, caller.legacyCaller))).toBe(false);
    expect(readFileSync(join(fixture, caller.finalCaller), "utf8")).toContain("version-find.sh");
    expect(correction.restoreReapplyFixture.restoreOrder).toEqual(manifest.versionUpdateDetectorAbsentCorrection.restoreOrder);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("validator accepts the approved inventory", () => {
  const result = run([process.execPath, validatorPath], root);
  expect(result.stderr).toBe("");
  expect(result.exitCode).toBe(0);
  expect(result.stdout).toContain("Validated 44 bash skill scripts (19 former-sh, 1 former-py, 9 retained-mjs, 15 authored-mjs historical origins).");
});
test("validator rejects bash policy mutations a real regression would introduce", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-validator-mutation-"));
  const scriptDirectory = join(fixture, "scripts");
  const target = join(fixture, "skills/version-update/scripts/version-current.sh");
  try {
    mkdirSync(scriptDirectory, { recursive: true });
    copyFileSync(validatorPath, join(scriptDirectory, "validate-skills.mjs"));
    cpSync(join(root, "scripts/fixtures"), join(scriptDirectory, "fixtures"), { recursive: true });
    cpSync(join(root, "skills"), join(fixture, "skills"), { recursive: true });
    const original = readFileSync(target, "utf8");
    const originalMode = statSync(target).mode & 0o777;
    const mutations = [
      ["eval", 'eval "printf ok >/dev/null"'],
      ["node invocation", "node -e 'true'"],
      ["bun script invocation", "bun ./helper.mjs"],
      ["python invocation", "python3 -c 'pass'"],
      ["interpreter module run", "node ./helper.mjs"],
      ["unapproved source edge", '. ./unapproved.sh'],
      ["unapproved child script", "bash ./unapproved.sh"],
      ["associative array", "declare -A table=()"],
      ["mapfile", "mapfile -t lines < /dev/null"],
      ["case conversion", 'printf "%s" "${PATH,,}"'],
      ["wait -n", "wait -n"],
      ["pipe stderr", "true |& true"],
      ["append redirect", "true &>> /dev/null"],
    ];
    for (const [name, mutation] of mutations) {
      writeFileSync(target, `${original}\n${mutation}\n`);
      chmodSync(target, originalMode);
      const result = run([process.execPath, join(scriptDirectory, "validate-skills.mjs")], fixture);
      expect(result.exitCode, name).not.toBe(0);
    }
    const replacements = [
      ["missing shebang", (source) => source.replace(/^#![^\n]*\n/u, "")],
      ["bun shebang", (source) => source.replace(/^#![^\n]*\n/u, "#!/usr/bin/env bun\n")],
      ["node shebang", (source) => source.replace(/^#![^\n]*\n/u, "#!/usr/bin/env node\n")],
    ];
    for (const [name, replace] of replacements) {
      writeFileSync(target, replace(original));
      chmodSync(target, originalMode);
      const result = run([process.execPath, join(scriptDirectory, "validate-skills.mjs")], fixture);
      expect(result.exitCode, name).not.toBe(0);
    }
    writeFileSync(target, original);
    chmodSync(target, 0o644);
    expect(run([process.execPath, join(scriptDirectory, "validate-skills.mjs")], fixture).exitCode).not.toBe(0);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
}, 30_000);

test("version-current reads an isolated package fixture without changing it", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-version-current-"));
  const packagePath = join(fixture, "package.json");
  const source = '{"name":"fixture","version":"1.2.3"}\n';
  writeFileSync(packagePath, source);
  try {
    const result = run(["bash", currentVersionPath, packagePath], fixture);
    expect(result.exitCode).toBe(0);
    expect(result.stdout.trim()).toBe(`${packagePath}|1.2.3`);
    expect(readFileSync(packagePath, "utf8")).toBe(source);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});
test("version scripts reject leading-zero semver and preserve paths with spaces", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore version fixture-"));
  const packagePath = join(fixture, "package.json");
  writeFileSync(packagePath, '{"name":"fixture","version":"1.2.3"}\n');
  try {
    const rejected = run(["bash", versionApplyPath, "01.2.3", packagePath], fixture);
    expect(rejected.exitCode).toBe(1);
    const applied = run(["bash", versionApplyPath, "2.0.0", packagePath], fixture);
    expect(applied.exitCode).toBe(0);
    expect(readFileSync(packagePath, "utf8")).toContain('"version":"2.0.0"');
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});
test("version-apply leaves every input untouched when a later write cannot proceed", async () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-version-rollback-"));
  const firstDirectory = join(fixture, "first");
  const secondDirectory = join(fixture, "second");
  const first = join(firstDirectory, "package.json");
  const second = join(secondDirectory, "package.json");
  const firstSource = `{"name":"first","version":"1.2.3","padding":"${"x".repeat(256 * 1024)}"}\n`;
  const secondSource = '{"name":"second","version":"1.2.3"}\n';
  mkdirSync(firstDirectory);
  mkdirSync(secondDirectory);
  writeFileSync(first, firstSource, { mode: 0o640 });
  writeFileSync(second, secondSource, { mode: 0o600 });
  chmodSync(secondDirectory, 0o500);
  try {
    const child = Bun.spawn({
      cmd: ["bash", versionApplyPath, "2.0.0", first, second],
      cwd: fixture,
      stdout: "pipe",
      stderr: "pipe",
    });
    const exitCode = await child.exited;
    const stderr = await new Response(child.stderr).text();
    expect(exitCode).toBe(1);
    expect(stderr.trim()).not.toBe("");
    expect(readFileSync(first, "utf8")).toBe(firstSource);
    expect(statSync(first).mode & 0o7777).toBe(0o640);
    expect(readFileSync(second, "utf8")).toBe(secondSource);
    expect(statSync(second).mode & 0o7777).toBe(0o600);
    expect(readdirSync(firstDirectory)).toEqual(["package.json"]);
    expect(readdirSync(secondDirectory)).toEqual(["package.json"]);
    expect(readdirSync(fixture).sort()).toEqual(["first", "second"]);
  } finally {
    chmodSync(secondDirectory, 0o755);
    rmSync(fixture, { recursive: true, force: true });
  }
});


test("autoresearch skill contract eval corpus is valid and covers fail-closed recovery", () => {
  const evalPath = join(root, "skills/autoresearch-skill/assets/evals/autoresearch-skill-cases.jsonl");
  const evals = readFileSync(evalPath, "utf8").trim().split("\n").map((line) => JSON.parse(line));
  const ids = new Set();
  const categories = new Set(evals.map((entry) => entry.category));
  for (const entry of evals) {
    expect(typeof entry.id).toBe("string");
    expect(ids.has(entry.id)).toBe(false);
    ids.add(entry.id);
    expect(typeof entry.prompt).toBe("string");
    expect(typeof entry.shouldTrigger).toBe("boolean");
    expect(entry.context && typeof entry.context === "object").toBe(true);
    expect(entry.expected.must.length).toBeGreaterThan(0);
    expect(entry.expected.mustNot.length).toBeGreaterThan(0);
    expect(entry.metrics.length).toBeGreaterThan(0);
  }
  for (const category of ["positive", "negative", "boundary", "adversarial", "regression"]) expect(categories.has(category)).toBe(true);
  expect(evals.some((entry) => entry.language === "ko" && entry.shouldTrigger === true)).toBe(true);
  expect(evals.some((entry) => entry.language === "ko" && entry.shouldTrigger === false)).toBe(true);

  const contract = [
    "skills/autoresearch-skill/SKILL.md",
    "skills/autoresearch-skill/SKILL.ko.md",
    "skills/autoresearch-skill/rules/experiment-loop.md",
    "skills/autoresearch-skill/rules/experiment-loop.ko.md",
    "skills/autoresearch-skill/rules/context-sourcing-and-trace.md",
    "skills/autoresearch-skill/rules/context-sourcing-and-trace.ko.md",
    "skills/autoresearch-skill/rules/validation-and-exit.md",
    "skills/autoresearch-skill/rules/validation-and-exit.ko.md",
    "skills/autoresearch-skill/references/artifact-spec.md",
    "skills/autoresearch-skill/references/artifact-spec.ko.md",
  ].map((path) => readFileSync(join(root, path), "utf8")).join("\n");
  for (const pattern of [
    /compare-before-restore/u,
    /guard-error/u,
    /cleanup-error/u,
    /rollback-error/u,
    /manual_recovery/u,
    /non_resumable/u,
    /last finalized iteration|last_finalized_iteration/u,
    /network destination\/data|destination\/data policy/u,
  ]) expect(pattern.test(contract)).toBe(true);
});

/** @param {"deploy-fix"} skill */
function readRepairSkillEvals(skill) {
  const evalPath = join(root, `skills/${skill}/assets/evals/${skill}-cases.jsonl`);
  const lines = readFileSync(evalPath, "utf8").trim().split("\n");
  const rows = lines.map((line, index) => {
    let row;
    try { row = JSON.parse(line); } catch { throw new Error(`${skill} eval line ${index + 1} is malformed JSON`); }
    if (!row || typeof row !== "object" || Array.isArray(row)) throw new Error(`${skill} eval line ${index + 1} must be an object`);
    return row;
  });
  const ids = new Set();
  for (const row of rows) {
    if (typeof row.id !== "string" || ids.has(row.id)) throw new Error(`${skill} eval id is missing or duplicated`);
    ids.add(row.id);
    if (typeof row.prompt !== "string" || row.prompt.length === 0) throw new Error(`${skill} eval prompt is missing`);
    if (!row.context || !Array.isArray(row.context.files) || !Array.isArray(row.context.sources)) throw new Error(`${skill} eval context is invalid`);
    if (!row.expected || !Array.isArray(row.expected.must) || row.expected.must.length === 0 || !Array.isArray(row.expected.mustNot) || row.expected.mustNot.length === 0) throw new Error(`${skill} eval expectations are invalid`);
    if (!Array.isArray(row.metrics) || row.metrics.length === 0) throw new Error(`${skill} eval metrics are missing`);
  }
  return rows;
}

test("deploy-fix eval corpus covers trigger, trajectory, safety, and recovery regressions", () => {
  const evals = readRepairSkillEvals("deploy-fix");
  const categories = new Set(evals.map((row) => row.category));
  const languages = new Set(evals.map((row) => row.language));
  const invocationModes = new Set(evals.map((row) => row.invocationMode));
  for (const category of ["positive", "negative", "boundary", "workflow", "source", "safety", "adversarial", "regression"]) expect(categories.has(category)).toBe(true);
  for (const language of ["en", "ko", "mixed"]) expect(languages.has(language)).toBe(true);
  for (const mode of ["explicit", "implicit", "contextual", "negative-control"]) expect(invocationModes.has(mode)).toBe(true);
  expect(evals.filter((row) => row.category === "positive")).toHaveLength(3);
  expect(evals.filter((row) => row.category === "negative")).toHaveLength(2);
  expect(evals.some((row) => row.expect === "trigger")).toBe(true);
  expect(evals.some((row) => row.expect === "no_trigger")).toBe(true);

  const deployContract = [
    "skills/deploy-fix/SKILL.md",
    "skills/deploy-fix/SKILL.ko.md",
    "skills/deploy-fix/rules/diagnosis-resume-and-safety.md",
    "skills/deploy-fix/rules/diagnosis-resume-and-safety.ko.md",
    "skills/deploy-fix/references/flow-schema.md",
    "skills/deploy-fix/references/flow-schema.ko.md",
  ].map((file) => readFileSync(join(root, file), "utf8")).join("\n");
  for (const pattern of [/evidence only|근거일 뿐/u, /non-resumable/u, /authorized_target/u, /rollback_or_stop/u, /three materially different|실질적으로 다른 실패 접근/u]) expect(pattern.test(deployContract)).toBe(true);
});

test("autoresearch dashboard accepts typed non-happy outcomes", () => {
  const statuses = ["tie", "inconclusive", "candidate-crash", "infra-flake", "timeout", "signaled", "guard-failed", "guard-error", "cleanup-error", "rollback-error"];
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-autoresearch-typed-status-"));
  writeFileSync(join(fixture, "results.json"), JSON.stringify({
    skill_name: "fixture",
    status: "running",
    current_experiment: statuses.length,
    baseline_score: 1,
    best_score: 1,
    metric_direction: "higher_is_better",
    last_statuses: statuses,
    best_experiment: 0,
    experiments: statuses.map((status, id) => ({ id, commit: "-", score: 1, max_score: 1, metric: 1, delta: 0, pass_rate: 100, guard: status === "guard-failed" ? "fail" : status === "guard-error" ? "error" : "pass", guard_metric: null, status, description: status })),
  }));
  try {
    const result = run(["bash", join(root, "skills/autoresearch-skill/scripts/render-dashboard.sh"), fixture], fixture);
    expect(result.exitCode).toBe(0);
    expect(readdirSync(fixture).sort()).toEqual(["dashboard.html", "results.js", "results.json"]);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});
/**
 * Messages the seo-maker structure gate prints when it rejects a payload. The atomic-write
 * fixtures must not contain any of them: an exit code of 1 produced by validation would
 * leave both prior outputs untouched for the wrong reason and read as a passing atomicity
 * check. Only the injected write or rename failure may end the run.
 */
const STRUCTURE_GATE_MARKERS = [
  "필수 키가 없습니다",
  "값이 유효하지 않습니다",
  "배열이어야 합니다",
  "객체여야 합니다",
  "0..100 또는 null이어야 합니다",
  "JSON 파싱에 실패했습니다",
];
for (const renderer of [
  {
    name: "autoresearch-skill",
    scriptPath: join(root, "skills/autoresearch-skill/scripts/render-dashboard.sh"),
    templatePath: join(root, "skills/autoresearch-skill/assets/dashboard-template.html"),
    results: { skill_name: "fixture", status: "running", current_experiment: 0, baseline_score: 1, best_score: 1, metric_direction: "higher_is_better", last_statuses: [], best_experiment: 0, experiments: [] },
  },
  {
    name: "seo-maker",
    scriptPath: join(root, "skills/seo-maker/scripts/render-dashboard.sh"),
    templatePath: join(root, "skills/seo-maker/assets/dashboard-template.html"),
    results: {
      project_name: "fixture",
      status: "running",
      categories: [{ name: "Technical SEO", status: "unknown", score: null }],
      findings: [{ id: "T1", severity: "info", finding: "fixture finding", evidence_grade: "heuristic", source_tier: "research-backed-heuristic" }],
    },
  },
]) {
  /** The renderer writes and renames two outputs; each failure injects a shell-level abort at one seam. */
  const failureSeams = (name) => [
    {
      failure: "second-write",
      source: name === "seo-maker"
        ? "  if ! printf 'window.__SEO_RESULTS__ = %s;\\n' \"$results_json\" | write_temp_stream \"$RESULTS_JS_TEMP\" \"$RESULTS_MODE\"; then"
        : "  if ! printf 'window.__AUTORESEARCH_RESULTS__ = %s;\\nwindow.__AUTORESEARCH_DETAILS__ = %s;\\n' \"$results_json\" \"$details_json\" | write_temp_stream \"$RESULTS_JS_TEMP\" \"$RESULTS_MODE\"; then",
      replacement: "  if ! (printf 'forced second write\\n' >&2; false); then",
    },
    {
      failure: "second-rename",
      source: '  if ! mv -f -- "$RESULTS_JS_TEMP" "$results_js_path"; then',
      replacement: "  if ! (printf 'forced second rename\\n' >&2; false); then",
    },
  ];
  for (const seam of failureSeams(renderer.name)) {
    test(`${renderer.name} preserves both prior outputs when its ${seam.failure} fails`, () => {
      const fixture = mkdtempSync(join(tmpdir(), `hypercore-${renderer.name}-dashboard-atomic-`));
      const scriptDirectory = join(fixture, "scripts");
      const assetsDirectory = join(fixture, "assets");
      mkdirSync(scriptDirectory);
      mkdirSync(assetsDirectory);
      const script = join(scriptDirectory, "render-dashboard.sh");
      writeFileSync(script, readFileSync(renderer.scriptPath, "utf8").replace(seam.source, seam.replacement));
      chmodSync(script, 0o755);
      copyFileSync(renderer.templatePath, join(assetsDirectory, "dashboard-template.html"));
      writeFileSync(join(fixture, "results.json"), JSON.stringify(renderer.results));
      writeFileSync(join(fixture, "dashboard.html"), "prior dashboard\n", { mode: 0o640 });
      writeFileSync(join(fixture, "results.js"), "prior results\n", { mode: 0o600 });
      try {
        expect(readFileSync(script, "utf8")).toContain(seam.replacement);
        const failure = run(["bash", script, fixture], fixture);
        expect(failure.exitCode).toBe(1);
        expect(failure.stderr).toContain(`forced ${seam.failure.replace("-", " ")}`);
        for (const marker of STRUCTURE_GATE_MARKERS) expect(failure.stderr).not.toContain(marker);
        expect(readFileSync(join(fixture, "dashboard.html"), "utf8")).toBe("prior dashboard\n");
        expect(readFileSync(join(fixture, "results.js"), "utf8")).toBe("prior results\n");
        expect(statSync(join(fixture, "dashboard.html")).mode & 0o7777).toBe(0o640);
        expect(statSync(join(fixture, "results.js")).mode & 0o7777).toBe(0o600);
        expect(readdirSync(fixture).filter((entry) => entry.endsWith(".tmp"))).toEqual([]);
      } finally {
        rmSync(fixture, { recursive: true, force: true });
      }
    });
  }
}

test("version Git helpers reject unrelated staged files without staging requested files", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-git-"));
  try {
    initializeGit(fixture);
    writeFileSync(join(fixture, "a.txt"), "initial\n");
    writeFileSync(join(fixture, "b.txt"), "initial\n");
    expect(run(["git", "add", "a.txt", "b.txt"], fixture).exitCode).toBe(0);
    expect(run(["git", "commit", "-qm", "initial"], fixture).exitCode).toBe(0);
    writeFileSync(join(fixture, "a.txt"), "changed\n");
    writeFileSync(join(fixture, "b.txt"), "changed\n");
    expect(run(["git", "add", "b.txt"], fixture).exitCode).toBe(0);

    const result = run(["bash", versionGitCommitPath, "test: scoped", "a.txt"], fixture);
    expect(result.exitCode).toBe(1);
    expect(run(["git", "diff", "--cached", "--name-only"], fixture).stdout.trim()).toBe("b.txt");
    expect(run(["git", "log", "-1", "--format=%s"], fixture).stdout.trim()).toBe("initial");
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("version git-commit treats --all as a literal path and cannot stage unrelated files", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-git-option-"));
  try {
    initializeGit(fixture);
    writeFileSync(join(fixture, "requested.txt"), "initial\n");
    writeFileSync(join(fixture, "unrelated.txt"), "initial\n");
    expect(run(["git", "add", "."], fixture).exitCode).toBe(0);
    expect(run(["git", "commit", "-qm", "initial"], fixture).exitCode).toBe(0);
    writeFileSync(join(fixture, "requested.txt"), "changed\n");
    writeFileSync(join(fixture, "unrelated.txt"), "changed\n");

    const result = run(["bash", versionGitCommitPath, "test: injection", "--all"], fixture);

    expect(result.exitCode).toBe(1);
    expect(run(["git", "diff", "--cached", "--name-only"], fixture).stdout.trim()).toBe("");
    expect(run(["git", "log", "-1", "--format=%s"], fixture).stdout.trim()).toBe("initial");
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("version git-commit stops at Git inspection failures and non-repository boundaries", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-git-boundary-"));
  const marker = join(fixture, "marker.txt");
  writeFileSync(marker, "unchanged\n");
  try {
    const nonRepository = run(["bash", versionGitCommitPath, "test: boundary", marker], fixture, { ...process.env, LC_ALL: "C", LANG: "C" });
    expect(nonRepository.exitCode).toBe(1);
    expect(nonRepository.stderr).toContain("Not a git repository");
    expect(readFileSync(marker, "utf8")).toBe("unchanged\n");

    const env = writeFakeGit(fixture, "#!/bin/sh\nprintf '%s\\n' \"$*\" >> git-calls.log\nprintf '%s\\n' 'fake rev-parse failure' >&2\nexit 97\n");
    const failedInspection = run(["bash", versionGitCommitPath, "test: inspection", marker], fixture, env);
    expect(failedInspection.exitCode).toBe(97);
    expect(failedInspection.stderr).toContain("fake rev-parse failure");
    expect(readFileSync(join(fixture, "git-calls.log"), "utf8").trim()).toBe("rev-parse --git-dir");
    expect(readFileSync(marker, "utf8")).toBe("unchanged\n");
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("version-current forwards SIGTERM and SIGINT and reaps its ready discovery child", async () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-version-current-signal-"));
  const currentFixture = join(fixture, "version-current.sh");
  const finderFixture = join(fixture, "version-find.sh");
  copyFileSync(currentVersionPath, currentFixture);
  writeFileSync(finderFixture, `#!/usr/bin/env bash
set -u
printf '%s' "$$" > "$READY_FILE"
trap 'printf %s SIGTERM > "$SIGNAL_FILE"; exit 143' TERM
trap 'printf %s SIGINT > "$SIGNAL_FILE"; exit 130' INT
deadline=$((SECONDS + 90))
while kill -0 "$PPID" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do sleep 0.02; done
exit 99
`);
  chmodSync(finderFixture, 0o755);
  /** @type {(() => void) | null} */
  let reapChildren = null;
  try {
    for (const [signal, exitCode] of /** @type {const} */ ([["SIGTERM", 143], ["SIGINT", 130]])) {
      const readyFile = join(fixture, `ready-${signal}`);
      const signalFile = join(fixture, `signal-${signal}`);
      const child = Bun.spawn({
        cmd: ["bash", currentFixture],
        cwd: fixture,
        env: { ...process.env, READY_FILE: readyFile, SIGNAL_FILE: signalFile },
        stdout: "pipe",
        stderr: "pipe",
      });
      reapChildren = () => {
        try { child.kill("SIGKILL"); } catch {}
        killRecordedPid(readyFile);
      };
      for (let attempt = 0; attempt < 200 && !existsSync(readyFile); attempt++) await Bun.sleep(10);
      expect(existsSync(readyFile)).toBe(true);
      const discoveryPid = Number(readFileSync(readyFile, "utf8"));
      child.kill(signal);
      expect(await child.exited).toBe(exitCode);
      expect(readFileSync(signalFile, "utf8")).toBe(signal);
      let discoveryAlive = true;
      try { process.kill(discoveryPid, 0); } catch { discoveryAlive = false; }
      expect(discoveryAlive).toBe(false);
    }
  } finally {
    reapChildren?.();
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("version git-push rejects unknown arguments before touching a remote", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-push-"));
  try {
    expect(run(["git", "init", "-q"], fixture).exitCode).toBe(0);
    const result = run(["bash", versionGitPushPath, "--unknown"], fixture);
    expect(result.exitCode).toBe(2);
    expect(result.stderr).toContain("Usage:");
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});
test("version git-push stops before network push when upstream inspection fails", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-push-upstream-"));
  try {
    const env = writeFakeGit(fixture, `#!/bin/sh
printf '%s\n' "$*" >> git-calls.log
case "$*" in
  "rev-parse --git-dir") printf '%s\n' .git ;;
  "branch --show-current") printf '%s\n' topic ;;
  "for-each-ref --format=%(upstream:short) refs/heads/topic") printf '%s\n' 'fake upstream failure' >&2; exit 97 ;;
  *) printf '%s\n' "unexpected git invocation: $*" >&2; exit 98 ;;
esac
`);
    const result = run(["bash", versionGitPushPath], fixture, env);
    expect(result.exitCode).toBe(97);
    expect(result.stderr).toContain("fake upstream failure");
    expect(readFileSync(join(fixture, "git-calls.log"), "utf8").trim().split("\n")).toEqual([
      "rev-parse --git-dir",
      "branch --show-current",
      "for-each-ref --format=%(upstream:short) refs/heads/topic",
    ]);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("git-maker commit rejects option-like paths without staging unrelated changes", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-git-maker-commit-"));
  try {
    initializeGit(fixture);
    writeFileSync(join(fixture, "requested.txt"), "initial\n");
    writeFileSync(join(fixture, "unrelated.txt"), "initial\n");
    expect(run(["git", "add", "."], fixture).exitCode).toBe(0);
    expect(run(["git", "commit", "-qm", "initial"], fixture).exitCode).toBe(0);
    writeFileSync(join(fixture, "requested.txt"), "changed\n");
    writeFileSync(join(fixture, "unrelated.txt"), "changed\n");

    const result = run(["bash", gitMakerCommitPath, "test: injection", "--all"], fixture);

    expect(result.exitCode).toBe(1);
    expect(result.stderr).toContain("Usage:");
    expect(run(["git", "diff", "--cached", "--name-only"], fixture).stdout.trim()).toBe("");
    expect(run(["git", "log", "-1", "--format=%s"], fixture).stdout.trim()).toBe("initial");
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("git-maker discover and status reject option-like paths before Git inspection", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-git-maker-boundary-"));
  try {
    const env = writeFakeGit(fixture, "#!/bin/sh\nprintf '%s\\n' \"$*\" >> git-calls.log\nexit 99\n");
    for (const script of [repoDiscoverPath, repoStatusPath]) {
      const result = run(["bash", script, "--not-a-path"], fixture, env);
      expect(result.exitCode).toBe(1);
      expect(result.stderr).toContain("Usage:");
    }
    expect(existsSync(join(fixture, "git-calls.log"))).toBe(false);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});
test("pre-deploy drains multi-MiB children and forwards termination without orphaning sequential or parallel work", async () => {
  for (const mode of ["--sequential", "--parallel"]) {
    const fixture = mkdtempSync(join(tmpdir(), "hypercore-predeploy-signal-"));
    const scripts = join(fixture, "scripts");
    mkdirSync(scripts);
    copyFileSync(deployCheckPath, join(scripts, "deploy-check.sh"));
    chmodSync(join(scripts, "deploy-check.sh"), 0o755);
    writeFileSync(join(scripts, "stack-detect.sh"), "#!/usr/bin/env bash\nexit 0\n");
    const childSource = (role) => `#!/usr/bin/env bash
set -u
root="$PROBE_ROOT"
printf '%s' "$$" > "$root/${role}.ready"
trap 'printf %s SIGTERM > "$root/${role}.signal"; exit 143' TERM
head -c 2097152 /dev/zero | tr '\\000' 'o'
head -c 2097152 /dev/zero | tr '\\000' 'e' >&2
printf '%s' done > "$root/${role}.emitted"
deadline=$((SECONDS + 90))
while kill -0 "$PPID" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do /bin/sleep 0.02; done
exit 99
`;
    writeFileSync(join(scripts, "lint-check.sh"), childSource("lint"));
    writeFileSync(join(scripts, "build-run.sh"), childSource("build"));
    chmodSync(join(scripts, "lint-check.sh"), 0o755);
    chmodSync(join(scripts, "build-run.sh"), 0o755);
    chmodSync(join(scripts, "stack-detect.sh"), 0o755);
    /** @type {(() => void) | null} */
    let reapChildren = null;
    try {
      const child = Bun.spawn({ cmd: ["bash", join(scripts, "deploy-check.sh"), mode], cwd: fixture, env: { ...process.env, PROBE_ROOT: fixture }, stdout: "pipe", stderr: "pipe" });
      reapChildren = () => {
        try { child.kill("SIGKILL"); } catch {}
        for (const role of ["lint", "build"]) killRecordedPid(join(fixture, `${role}.ready`));
      };
      const output = Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text()]).then(([stdout, stderr]) => `${stdout}${stderr}`);
      for (let attempt = 0; attempt < 1000 && !existsSync(join(fixture, "lint.ready")); attempt++) await Bun.sleep(10);
      if (!existsSync(join(fixture, "lint.ready"))) {
        child.kill("SIGTERM");
        throw new Error(await output);
      }
      for (let attempt = 0; attempt < 1000 && !existsSync(join(fixture, "lint.emitted")); attempt++) await Bun.sleep(10);
      expect(existsSync(join(fixture, "lint.emitted"))).toBe(true);
      if (mode === "--parallel") {
        for (let attempt = 0; attempt < 1000 && !existsSync(join(fixture, "build.emitted")); attempt++) await Bun.sleep(10);
        expect(existsSync(join(fixture, "build.emitted"))).toBe(true);
        expect(existsSync(join(fixture, "build.ready"))).toBe(true);
      } else {
        expect(existsSync(join(fixture, "build.ready"))).toBe(false);
      }
      child.kill("SIGTERM");
      expect(await child.exited).toBe(143);
      expect((await output).length).toBeGreaterThanOrEqual(512 * 1024);
      expect(readFileSync(join(fixture, "lint.signal"), "utf8")).toBe("SIGTERM");
      if (mode === "--parallel") expect(readFileSync(join(fixture, "build.signal"), "utf8")).toBe("SIGTERM");
      else expect(existsSync(join(fixture, "build.signal"))).toBe(false);
    } finally {
      reapChildren?.();
      rmSync(fixture, { recursive: true, force: true });
    }
  }
}, 30_000);

test("git-maker-fast drains concurrent fake Git children, stops queued work, and reaps children on failures and signals", async () => {
  for (const [mode, signal, expectedExit] of /** @type {const} */ ([["failure", null, 1], ["signal", "SIGTERM", 143], ["signal", "SIGINT", 130]])) {
    const fixture = mkdtempSync(join(tmpdir(), `hypercore-git-maker-fast-${mode}-`));
    const repositories = ["repo-a", "repo-b", "repo-c"];
    for (const repository of repositories) mkdirSync(join(fixture, repository, ".git"), { recursive: true });
    const fakeGit = `#!/usr/bin/env bash
set -u
root="$PROBE_ROOT"
repo="\${PWD##*/}"
args="$*"
emit() {
  head -c 2097152 /dev/zero | tr '\\000' 'x'
}
if [ "$args" = "rev-parse --show-toplevel" ]; then
  if [ -d "$PWD/.git" ]; then printf '%s\\n' "$PWD"; else printf '%s\\n' "not a git repository" >&2; exit 128; fi
elif [ "$args" = "rev-parse --is-inside-work-tree" ]; then
  printf '%s' "$$" > "$root/$repo.ready"
  trap 'printf %s SIGTERM > "$root/$repo.signal"; exit 143' TERM
  trap 'printf %s SIGINT > "$root/$repo.signal"; exit 130' INT
  emit
  emit >&2
  printf '%s' done > "$root/$repo.emitted"
  if [ "\${MODE:-}" = "failure" ] && [ "$repo" = "repo-a" ]; then
    deadline=$((SECONDS + 10))
    while [ ! -e "$root/repo-b.ready" ] && [ "$SECONDS" -lt "$deadline" ]; do /bin/sleep 0.01; done
    printf '%s\\n' "intentional worker failure" >&2
    exit 97
  fi
  deadline=$((SECONDS + 90))
  while kill -0 "$PPID" 2>/dev/null && [ "$SECONDS" -lt "$deadline" ]; do /bin/sleep 0.02; done
  exit 99
else
  printf '%s\\n' "unexpected git invocation: $args" >&2
  exit 98
fi
`;
    /** @type {(() => void) | null} */
    let reapChildren = null;
    try {
      const env = { ...writeFakeGit(fixture, fakeGit), PROBE_ROOT: fixture, MODE: mode };
      const child = Bun.spawn({
        cmd: ["bash", gitMakerFastPath, "inspect", fixture, "--jobs", "2"],
        cwd: fixture,
        env,
        stdout: "pipe",
        stderr: "pipe",
      });
      reapChildren = () => {
        try { child.kill("SIGKILL"); } catch {}
        for (const repository of repositories) killRecordedPid(join(fixture, `${repository}.ready`));
      };
      const output = Promise.all([new Response(child.stdout).text(), new Response(child.stderr).text()]);
      for (let attempt = 0; attempt < 1_000 && (!existsSync(join(fixture, "repo-a.ready")) || !existsSync(join(fixture, "repo-b.ready"))); attempt++) await Bun.sleep(10);
      expect(existsSync(join(fixture, "repo-a.ready"))).toBe(true);
      expect(existsSync(join(fixture, "repo-b.ready"))).toBe(true);
      expect(existsSync(join(fixture, "repo-c.ready"))).toBe(false);
      for (let attempt = 0; attempt < 1_000 && !existsSync(join(fixture, "repo-a.emitted")); attempt++) await Bun.sleep(10);
      expect(existsSync(join(fixture, "repo-a.emitted"))).toBe(true);
      if (signal) {
        for (let attempt = 0; attempt < 1_000 && !existsSync(join(fixture, "repo-b.emitted")); attempt++) await Bun.sleep(10);
        expect(existsSync(join(fixture, "repo-b.emitted"))).toBe(true);
      }

      if (signal) child.kill(signal);
      expect(await child.exited).toBe(expectedExit);
      const [, stderr] = await output;
      if (!signal) expect(stderr.length).toBeGreaterThanOrEqual(2 * 1024 * 1024);
      expect(existsSync(join(fixture, "repo-c.ready"))).toBe(false);

      if (signal) {
        for (const repository of ["repo-a", "repo-b"]) expect(readFileSync(join(fixture, `${repository}.signal`), "utf8")).toBe(signal);
      } else {
        expect(stderr).toContain("intentional worker failure");
        expect(readFileSync(join(fixture, "repo-b.signal"), "utf8")).toBe("SIGTERM");
      }
      for (const repository of ["repo-a", "repo-b"]) {
        const pid = Number(readFileSync(join(fixture, `${repository}.ready`), "utf8"));
        let alive = true;
        try { process.kill(pid, 0); } catch { alive = false; }
        expect(alive).toBe(false);
      }
    } finally {
      reapChildren?.();
      rmSync(fixture, { recursive: true, force: true });
    }
  }
}, 60_000);
test("git-maker-fast inspects a repository whose path contains spaces without remote access", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore git-maker fast-"));
  const repository = join(fixture, "repository with spaces");
  mkdirSync(repository);
  try {
    initializeGit(repository);
    writeFileSync(join(repository, "tracked.txt"), "initial\n");
    expect(run(["git", "add", "tracked.txt"], repository).exitCode).toBe(0);
    expect(run(["git", "commit", "-qm", "initial"], repository).exitCode).toBe(0);

    const result = run(["bash", gitMakerFastPath, "inspect", repository, "--jobs=1"], fixture);

    expect(result.exitCode).toBe(0);
    expect(result.stdout).toContain("repos|begin");
    expect(result.stdout).toContain("repository with spaces");
    expect(result.stdout).toContain("repo|");
    expect(result.stdout).toContain("status|begin\nstatus|end");
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("pre-deploy rejects malformed package metadata", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-predeploy-"));
  writeFileSync(join(fixture, "package.json"), "{broken");
  try {
    const result = run(["bash", deployCheckPath, "--sequential"], fixture);
    expect(result.exitCode).toBe(1);
    expect(`${result.stdout}\n${result.stderr}`).toContain("package.json");
    expect(result.stdout).not.toContain("Ready to deploy");
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});

test("self-containment check catches cross-skill references, including with no sibling present", () => {
  const fixture = mkdtempSync(join(tmpdir(), "hypercore-self-containment-"));
  const validator = join(root, "skills/skill-maker/scripts/validate-skill-maker.sh");
  const evals = join(root, "skills/skill-maker/assets/evals/skill-maker-cases.jsonl");
  /** @param {string} name */
  const frontmatter = (name) => `---\nname: ${name}\ndescription: fixture package\n---\n`;
  /** @param {string} stdout */
  const parse = (stdout) => JSON.parse(stdout);
  /** @param {string} stdout */
  const errorCodes = (stdout) => parse(stdout).errors.map((error) => error.code);
  /** @param {string} stdout */
  const warningCodes = (stdout) => parse(stdout).warnings.map((warning) => warning.code);
  try {
    mkdirSync(join(fixture, "skills/sibling-one"), { recursive: true });
    mkdirSync(join(fixture, "skills/sibling-two"), { recursive: true });
    mkdirSync(join(fixture, "skills/target-pkg"), { recursive: true });
    writeFileSync(join(fixture, "skills/sibling-one/SKILL.md"), frontmatter("sibling-one"));
    writeFileSync(join(fixture, "skills/sibling-two/SKILL.md"), frontmatter("sibling-two"));
    writeFileSync(join(fixture, "skills/target-pkg/SKILL.md"), `${frontmatter("target-pkg")}\nSee skills/sibling-one/ and $sibling-two.\n`);

    // A package that does not adopt the contract reports the finding as a warning.
    const warned = run(["bash", validator, "--root", join(fixture, "skills/target-pkg"), "--evals", evals, "--json"], fixture);
    expect(errorCodes(warned.stdout)).not.toContain("CROSS_SKILL_REFERENCE");
    expect(warningCodes(warned.stdout)).toContain("CROSS_SKILL_REFERENCE");

    // Strict mode promotes it to an error.
    const strict = run(["bash", validator, "--root", join(fixture, "skills/target-pkg"), "--evals", evals, "--require-self-containment", "--json"], fixture);
    expect(strict.exitCode).not.toBe(0);
    expect(errorCodes(strict.stdout)).toContain("CROSS_SKILL_REFERENCE");

    // A user-directed waiver stays visible without failing the package.
    const waived = run(["bash", validator, "--root", join(fixture, "skills/target-pkg"), "--evals", evals, "--require-self-containment", "--allow", "sibling-one", "--allow", "sibling-two", "--json"], fixture);
    expect(errorCodes(waived.stdout)).not.toContain("CROSS_SKILL_REFERENCE");
    expect(warningCodes(waived.stdout)).toContain("SELF_CONTAINMENT_WAIVER");

    // Standalone tree: the named sibling does not exist, and strict mode still catches the path.
    mkdirSync(join(fixture, "lonely/skills/lonely-pkg"), { recursive: true });
    writeFileSync(join(fixture, "lonely/skills/lonely-pkg/SKILL.md"), `${frontmatter("lonely-pkg")}\nA stale pointer: skills/ghost-skill/ is not here.\n`);
    const lonely = run(["bash", validator, "--root", join(fixture, "lonely/skills/lonely-pkg"), "--evals", evals, "--require-self-containment", "--json"], fixture);
    expect(lonely.exitCode).not.toBe(0);
    expect(errorCodes(lonely.stdout)).toContain("CROSS_SKILL_REFERENCE");
    expect(parse(lonely.stdout).selfContainment.siblings).toEqual([]);
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
}, 120_000);

test("script-runtime check rejects non-bash bundled scripts and non-bash shebangs", () => {
  const parent = mkdtempSync(join(tmpdir(), "hypercore-script-runtime-"));
  const validator = join(root, "skills/skill-maker/scripts/validate-skill-maker.sh");
  const evals = join(root, "skills/skill-maker/assets/evals/skill-maker-cases.jsonl");
  // The package directory basename is the expected `name`, and `mkdtemp`'s random suffix contains
  // uppercase letters, so the package must be a fixed lowercase kebab-case directory inside the parent.
  const packageName = "fixture-pkg";
  const pkg = join(parent, packageName);
  const requiredSections = ["output_language", "purpose", "routing_rule", "instruction_contract", "activation_examples", "trigger_conditions", "skill_architecture", "loop_policy", "language_and_translation_default", "reference_routing", "support_file_read_order", "workflow", "required", "forbidden", "validation"];
  // Tag form, in the same order on both sides: `checkRequiredSections` accepts an open tag, and
  // `checkCoreParity` requires the two files to carry identical structural tags.
  const tags = requiredSections.map((section) => `<${section}>`).join("\n");
  const english = `---\nname: ${packageName}\ndescription: Use this skill when a fixture package is needed.\n---\n${tags}\n`;
  const korean = `---\nname: ${packageName}\ndescription: 픽스처 패키지가 필요할 때 사용합니다.\n---\n${tags}\n`;
  /** @param {string} stdout */
  const parse = (stdout) => JSON.parse(stdout);
  /** @param {string} stdout */
  const codes = (stdout) => parse(stdout).errors.map((error) => error.code);
  /** @param {(packageDir: string) => void} [extra] */
  const writePackage = (extra) => {
    rmSync(pkg, { recursive: true, force: true });
    mkdirSync(join(pkg, "scripts"), { recursive: true });
    writeFileSync(join(pkg, "SKILL.md"), english);
    writeFileSync(join(pkg, "SKILL.ko.md"), korean);
    if (extra) extra(pkg);
  };
  const runValidator = () => run(["bash", validator, "--root", pkg, "--evals", evals, "--json"], root);
  try {
    // Control: a valid package with no scripts directory passes the whole validator and reports zero
    // inspected scripts. This is what makes the exit-0 assertions below meaningful.
    rmSync(pkg, { recursive: true, force: true });
    mkdirSync(pkg, { recursive: true });
    writeFileSync(join(pkg, "SKILL.md"), english);
    writeFileSync(join(pkg, "SKILL.ko.md"), korean);
    const control = runValidator();
    expect(codes(control.stdout)).toEqual([]);
    expect(control.exitCode).toBe(0);
    expect(parse(control.stdout).scriptRuntime).toEqual({ ok: true, checked: 0, findings: [] });

    // A linked entry must not smuggle a script past the rule: the shared file list skips symbolic links,
    // so these two targets live outside `scripts/` and are reached only through a link.
    const nodeTarget = join(parent, "outside-node.sh");
    const bashTarget = join(parent, "outside-bash");
    writeFileSync(nodeTarget, "#!/usr/bin/env node\n");
    writeFileSync(bashTarget, "#!/usr/bin/env bash\n");
    const bashBody = "#!/usr/bin/env bash\n";
    // A case-variant top-level directory is only a distinct directory on a case-sensitive filesystem.
    // macOS and Windows treat `Scripts` and `scripts` as the same directory, so the case is exercised
    // only where the filesystem can express it.
    const caseSensitiveFs = (() => {
      const probe = join(parent, "CaseProbe");
      try {
        mkdirSync(probe);
        const distinct = !existsSync(join(parent, "caseprobe"));
        rmSync(probe, { recursive: true, force: true });
        return distinct;
      } catch {
        return false;
      }
    })();
    // Directory permissions are only exercised where the filesystem actually enforces them; running as
    // root would make the probe succeed and the case meaningless.
    const permissionsEnforced = (() => {
      const probe = join(parent, "perm-probe");
      try {
        mkdirSync(probe);
        writeFileSync(join(probe, "child"), "x");
        chmodSync(probe, 0o000);
        let denied = false;
        try {
          readdirSync(probe);
        } catch {
          denied = true;
        }
        chmodSync(probe, 0o755);
        rmSync(probe, { recursive: true, force: true });
        return denied;
      } catch {
        return false;
      }
    })();
    /** @type {Array<{ label: string, code: string, path: string, setup: (packageDir: string) => void }>} */
    const violations = [
      { label: "cjs", code: "SCRIPT_RUNTIME_EXTENSION", path: "scripts/probe.cjs", setup: (p) => writeFileSync(join(p, "scripts", "probe.cjs"), bashBody) },
      { label: "mjs", code: "SCRIPT_RUNTIME_EXTENSION", path: "scripts/probe.mjs", setup: (p) => writeFileSync(join(p, "scripts", "probe.mjs"), bashBody) },
      { label: "ts", code: "SCRIPT_RUNTIME_EXTENSION", path: "scripts/probe.ts", setup: (p) => writeFileSync(join(p, "scripts", "probe.ts"), bashBody) },
      { label: "extensionless", code: "SCRIPT_RUNTIME_EXTENSION", path: "scripts/probe", setup: (p) => writeFileSync(join(p, "scripts", "probe"), bashBody) },
      { label: "uppercase", code: "SCRIPT_RUNTIME_EXTENSION", path: "scripts/probe.SH", setup: (p) => writeFileSync(join(p, "scripts", "probe.SH"), bashBody) },
      { label: "node-shebang", code: "SCRIPT_RUNTIME_SHEBANG", path: "scripts/probe.sh", setup: (p) => writeFileSync(join(p, "scripts", "probe.sh"), "#!/usr/bin/env node\n") },
      { label: "linked-file-bad-shebang", code: "SCRIPT_RUNTIME_SHEBANG", path: "scripts/probe.sh", setup: (p) => symlinkSync(nodeTarget, join(p, "scripts", "probe.sh")) },
      { label: "linked-file-wrong-name", code: "SCRIPT_RUNTIME_EXTENSION", path: "scripts/linked", setup: (p) => symlinkSync(bashTarget, join(p, "scripts", "linked")) },
      { label: "linked-scripts-dir", code: "SCRIPT_RUNTIME_EXTENSION", path: "scripts/probe.cjs", setup: (p) => { const real = join(p, "real-scripts"); mkdirSync(real); writeFileSync(join(real, "probe.cjs"), bashBody); rmSync(join(p, "scripts"), { recursive: true, force: true }); symlinkSync(real, join(p, "scripts"), "dir"); } },
    ];
    // A non-regular entry named *.sh must be reported, not read: reading blocks forever on a FIFO.
    // Only exercised where `mkfifo` exists.
    if (run(["mkfifo", join(parent, "fifo-probe")], parent).exitCode === 0) {
      rmSync(join(parent, "fifo-probe"), { force: true });
      violations.push({ label: "fifo-entry", code: "SCRIPT_RUNTIME_SHEBANG", path: "scripts/probe.sh", setup: (p) => { run(["mkfifo", join(p, "scripts", "probe.sh")], p); } });
    }
    if (caseSensitiveFs) {
      violations.push({ label: "case-variant-dir", code: "SCRIPT_RUNTIME_EXTENSION", path: "Scripts/probe.cjs", setup: (p) => { mkdirSync(join(p, "Scripts")); writeFileSync(join(p, "Scripts", "probe.cjs"), bashBody); } });
    }
    for (const violation of violations) {
      writePackage(violation.setup);
      const result = runValidator();
      expect(codes(result.stdout)).toContain(violation.code);
      expect(result.exitCode).not.toBe(0);
      const runtime = parse(result.stdout).scriptRuntime;
      expect(runtime.ok).toBe(false);
      expect(runtime.checked).toBe(1);
      expect(runtime.findings).toHaveLength(1);
      expect(runtime.findings[0].path).toBe(violation.path);
    }

    // A `scripts` entry that does not resolve must be reported, not silently dropped from the check.
    writePackage((p) => { rmSync(join(p, "scripts"), { recursive: true, force: true }); symlinkSync(join(parent, "missing-target"), join(p, "scripts"), "dir"); });
    const brokenLink = runValidator();
    expect(codes(brokenLink.stdout)).toContain("SCRIPT_RUNTIME_EXTENSION");
    expect(parse(brokenLink.stdout).scriptRuntime.checked).toBe(0);

    // An unreadable directory must not kill the validator, and it must not be a silent pass either: the
    // check fails closed and the JSON output contract has to survive. Probed only where the filesystem
    // actually enforces permissions.
    if (permissionsEnforced) {
      writePackage((p) => { mkdirSync(join(p, "scripts", "locked")); writeFileSync(join(p, "scripts", "locked", "probe.cjs"), bashBody); chmodSync(join(p, "scripts", "locked"), 0o000); });
      const locked = runValidator();
      chmodSync(join(pkg, "scripts", "locked"), 0o755);
      expect(codes(locked.stdout)).toContain("SCRIPT_RUNTIME_UNREADABLE");
      expect(parse(locked.stdout).scriptRuntime.ok).toBe(false);

      // The same failure behind a linked `scripts` directory: the shared file walk skips symbolic links,
      // so this report cannot be delegated to it.
      const realScripts = join(parent, "real-scripts-locked");
      writePackage((p) => {
        rmSync(join(p, "scripts"), { recursive: true, force: true });
        mkdirSync(join(realScripts, "locked"), { recursive: true });
        writeFileSync(join(realScripts, "locked", "probe.cjs"), bashBody);
        chmodSync(join(realScripts, "locked"), 0o000);
        symlinkSync(realScripts, join(p, "scripts"), "dir");
      });
      const linkedLocked = runValidator();
      chmodSync(join(realScripts, "locked"), 0o755);
      expect(codes(linkedLocked.stdout)).toContain("SCRIPT_RUNTIME_UNREADABLE");
      expect(parse(linkedLocked.stdout).scriptRuntime.ok).toBe(false);
    }

    // A bash shebang passes, and CRLF line endings must not be mistaken for a bad shebang.
    for (const body of ["#!/usr/bin/env bash\n", "#!/usr/bin/env bash\r\n"]) {
      writePackage((p) => writeFileSync(join(p, "scripts", "probe.sh"), body));
      const result = runValidator();
      expect(codes(result.stdout)).not.toContain("SCRIPT_RUNTIME_EXTENSION");
      expect(codes(result.stdout)).not.toContain("SCRIPT_RUNTIME_SHEBANG");
      expect(result.exitCode).toBe(0);
      const runtime = parse(result.stdout).scriptRuntime;
      expect(runtime.ok).toBe(true);
      expect(runtime.checked).toBe(1);
      expect(runtime.findings).toEqual([]);
    }
  } finally {
    rmSync(parent, { recursive: true, force: true });
  }
}, 180_000);
