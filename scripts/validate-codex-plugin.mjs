#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const root = process.cwd();
const marketplacePath = path.join(root, ".agents", "plugins", "marketplace.json");
const pluginRoot = path.join(root, "plugins", "hypercore");
const pluginManifestPath = path.join(pluginRoot, ".codex-plugin", "plugin.json");

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`${path.relative(root, filePath)} must be valid JSON: ${error.message}`);
  }
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function assertFile(filePath) {
  assert(fs.existsSync(filePath), `${path.relative(root, filePath)} must exist`);
  assert(fs.statSync(filePath).isFile(), `${path.relative(root, filePath)} must be a file`);
}

assertFile(marketplacePath);
assertFile(pluginManifestPath);

const marketplace = readJson(marketplacePath);
assert(marketplace.name === "hypercore", ".agents/plugins/marketplace.json name must be hypercore");
assert(
  marketplace.interface?.displayName === "Hypercore",
  ".agents/plugins/marketplace.json interface.displayName must be Hypercore",
);
assert(Array.isArray(marketplace.plugins), ".agents/plugins/marketplace.json plugins must be an array");

const entry = marketplace.plugins.find((plugin) => plugin?.name === "hypercore");
assert(entry, ".agents/plugins/marketplace.json must include a hypercore plugin entry");
assert(entry.source === "./plugins/hypercore", "hypercore marketplace source must be ./plugins/hypercore");
assert(entry.category === "Productivity", "hypercore marketplace category must be Productivity");
assert(entry.policy?.installation === "AVAILABLE", "hypercore installation policy must be AVAILABLE");
assert(entry.policy?.authentication === "ON_USE", "hypercore authentication policy must be ON_USE");

const manifest = readJson(pluginManifestPath);
assert(manifest.name === "hypercore", "plugins/hypercore/.codex-plugin/plugin.json name must be hypercore");
assert(manifest.version === "1.0.2", "plugins/hypercore/.codex-plugin/plugin.json version must be 1.0.2");
assert(manifest.skills === "./skills/", "plugins/hypercore/.codex-plugin/plugin.json skills must be ./skills/");

const codexSkillPath = path.join(pluginRoot, "skills", "codex", "SKILL.md");
assertFile(codexSkillPath);

const rootSkillNames = fs
  .readdirSync(path.join(root, "skills"), { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .sort();
const pluginSkillNames = fs
  .readdirSync(path.join(pluginRoot, "skills"), { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .sort();

assert(
  JSON.stringify(pluginSkillNames) === JSON.stringify(rootSkillNames),
  "plugins/hypercore/skills must mirror root skills directories",
);

function listFiles(baseDir) {
  const files = [];

  function visit(currentDir) {
    for (const entry of fs.readdirSync(currentDir, { withFileTypes: true })) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        visit(fullPath);
        continue;
      }
      if (entry.isFile()) {
        files.push(path.relative(baseDir, fullPath));
      }
    }
  }

  visit(baseDir);
  return files.sort();
}

const rootSkillsPath = path.join(root, "skills");
const pluginSkillsPath = path.join(pluginRoot, "skills");
const rootSkillFiles = listFiles(rootSkillsPath);
const pluginSkillFiles = listFiles(pluginSkillsPath);

assert(
  JSON.stringify(pluginSkillFiles) === JSON.stringify(rootSkillFiles),
  "plugins/hypercore/skills must mirror root skills files",
);

for (const relativeFile of rootSkillFiles) {
  const rootContent = fs.readFileSync(path.join(rootSkillsPath, relativeFile), "utf8");
  const pluginContent = fs.readFileSync(path.join(pluginSkillsPath, relativeFile), "utf8");
  assert(
    pluginContent === rootContent,
    `plugins/hypercore/skills/${relativeFile} must match skills/${relativeFile}`,
  );
  assert(
    !pluginContent.includes(root),
    `plugins/hypercore/skills/${relativeFile} must not contain maintainer-local absolute paths`,
  );
}

console.log("Codex plugin manifest validation passed");
