#!/usr/bin/env bun
// @ts-check
/**
 * seo-maker bilingual structural-tag parity (plan todo 13).
 *
 * `validate-skill.mjs` compares the structural tag sequence of `SKILL.md` and
 * `SKILL.ko.md` and reports `BILINGUAL_TAG_DRIFT` when they differ. Two empty tag
 * lists compare equal, so this test pins the contract from both sides: the shipped
 * skill must validate with `ok === true` and two identical, non-empty tag
 * sequences, and a copy with a single tag removed must fail with that code.
 *
 * The negative control copies the skill into `mkdtemp` and hands that path to the
 * validator, so no repository file is ever written to. The copy is validated once
 * before the mutation, which proves the drift - not the copy - is what fails.
 */
import { expect, test } from "bun:test";
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
const validatorPath = join(root, "skills/skill-tester/scripts/validate-skill.mjs");
const skillPath = join(root, "skills/seo-maker");

/**
 * Whole lines that are a single structural tag, lowercased - the same extraction
 * `validate-skill.mjs` performs for its core-parity check.
 * @param {string} text
 * @returns {string[]}
 */
function structuralTags(text) {
  return [...text.matchAll(/^<\/?([a-z][a-z0-9_]*)>\s*$/gim)].map((match) => match[0].toLowerCase());
}

/**
 * Run the shipped validator against one skill folder.
 * @param {string} target absolute path to a skill folder
 */
function validate(target) {
  const result = Bun.spawnSync({
    cmd: [process.execPath, validatorPath, target, "--json"],
    cwd: root,
    stdout: "pipe",
    stderr: "pipe",
  });
  return {
    exitCode: result.exitCode,
    stderr: new TextDecoder().decode(result.stderr),
    report: JSON.parse(new TextDecoder().decode(result.stdout)),
  };
}

test("seo-maker SKILL.md and SKILL.ko.md carry the same non-empty structural tags", () => {
  const { exitCode, report } = validate(skillPath);
  expect(report.ok).toBe(true);
  expect(report.failures).toEqual([]);
  expect(report.checks.coreParity).toBe(true);
  expect(exitCode).toBe(0);

  const english = structuralTags(readFileSync(join(skillPath, "SKILL.md"), "utf8"));
  const korean = structuralTags(readFileSync(join(skillPath, "SKILL.ko.md"), "utf8"));
  expect(english.length).toBeGreaterThan(0);
  expect(english).toEqual(korean);
});

test("removing one structural tag from a temp copy fails with BILINGUAL_TAG_DRIFT", () => {
  const copyRoot = mkdtempSync(join(tmpdir(), "seo-maker-parity-"));
  try {
    const copy = join(copyRoot, "seo-maker");
    cpSync(skillPath, copy, { recursive: true });
    expect(validate(copy).report.ok).toBe(true);

    const koreanPath = join(copy, "SKILL.ko.md");
    const source = readFileSync(koreanPath, "utf8");
    const mutated = source.replace(/^<\/?scoring>\s*$/m, "");
    expect(mutated).not.toBe(source);
    writeFileSync(koreanPath, mutated);

    const { exitCode, report } = validate(copy);
    expect(exitCode).toBe(1);
    expect(report.ok).toBe(false);
    expect(report.failures.map((failure) => failure.code)).toContain("BILINGUAL_TAG_DRIFT");
  } finally {
    rmSync(copyRoot, { recursive: true, force: true });
  }
});
