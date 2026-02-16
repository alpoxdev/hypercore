import fs from 'fs-extra';
import path from 'path';
import { copyRecursive } from '../../shared/filesystem/index.js';

export interface CodexSyncResult {
  codexHome: string;
  codexSkillsDir: string;
  codexCommandsDir: string;
  syncedSkills: number;
  syncedCommands: number;
}

const RESERVED_CODEX_SKILL_DIRS = new Set(['.system', 'claude-commands']);

function normalizeLineEndings(content: string): string {
  return content.replace(/\r\n/g, '\n');
}

function yamlQuote(value: string): string {
  return `"${value.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
}

function extractDescriptionFromFrontmatter(markdown: string): string | undefined {
  const frontmatterMatch = markdown.match(/^---\n([\s\S]*?)\n---\n?/);
  if (!frontmatterMatch) {
    return undefined;
  }

  const lines = frontmatterMatch[1].split('\n');
  for (const rawLine of lines) {
    const line = rawLine.trim();
    if (!line.startsWith('description:')) {
      continue;
    }

    const value = line.slice('description:'.length).trim();
    if (!value) {
      return undefined;
    }

    return value.replace(/^['"]|['"]$/g, '');
  }

  return undefined;
}

function buildCommandSkillContent(commandPath: string, commandRaw: string): string {
  const commandName = path.basename(commandPath, '.md');
  const normalizedCommand = normalizeLineEndings(commandRaw).trim();
  const sourcePath = path.resolve(commandPath);
  const description =
    extractDescriptionFromFrontmatter(normalizedCommand) ||
    `${commandName} command imported from .claude/commands`;

  return `---
name: ${yamlQuote(commandName)}
description: ${yamlQuote(description)}
---

Imported command source: ${sourcePath}

Use this as a command playbook. If scripts are referenced with .claude-relative paths,
resolve them from the current workspace first; if missing, ask for the intended repo root.

---

${normalizedCommand}
`;
}

async function syncSkills(
  claudeSkillsDir: string,
  codexSkillsDir: string,
): Promise<number> {
  await fs.ensureDir(codexSkillsDir);

  let sourceSkillNames: string[] = [];
  if (await fs.pathExists(claudeSkillsDir)) {
    const sourceEntries = await fs.readdir(claudeSkillsDir, { withFileTypes: true });
    sourceSkillNames = sourceEntries
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .filter((name) => name !== '.system');
  }

  const sourceSkillSet = new Set(sourceSkillNames);
  const codexEntries = await fs.readdir(codexSkillsDir, { withFileTypes: true });

  // Remove stale mirrored skills that are no longer present in source.
  for (const entry of codexEntries) {
    if (!entry.isDirectory()) {
      continue;
    }
    if (RESERVED_CODEX_SKILL_DIRS.has(entry.name)) {
      continue;
    }
    if (!sourceSkillSet.has(entry.name)) {
      await fs.remove(path.join(codexSkillsDir, entry.name));
    }
  }

  for (const skillName of sourceSkillNames) {
    const src = path.join(claudeSkillsDir, skillName);
    const dest = path.join(codexSkillsDir, skillName);

    if (await fs.pathExists(dest)) {
      await fs.remove(dest);
    }
    await copyRecursive(src, dest, { files: 0, directories: 0 });
  }

  return sourceSkillNames.length;
}

async function syncCommands(
  claudeCommandsDir: string,
  codexCommandsDir: string,
): Promise<number> {
  if (!(await fs.pathExists(claudeCommandsDir))) {
    await fs.remove(codexCommandsDir);
    return 0;
  }

  const entries = await fs.readdir(claudeCommandsDir, { withFileTypes: true });
  const commandFiles = entries
    .filter((entry) => entry.isFile() && entry.name.endsWith('.md'))
    .map((entry) => entry.name)
    .sort((a, b) => a.localeCompare(b));

  if (commandFiles.length === 0) {
    await fs.remove(codexCommandsDir);
    return 0;
  }

  await fs.remove(codexCommandsDir);
  await fs.ensureDir(codexCommandsDir);

  for (const commandFile of commandFiles) {
    const commandPath = path.join(claudeCommandsDir, commandFile);
    const commandRaw = await fs.readFile(commandPath, 'utf8');
    const commandName = path.basename(commandFile, '.md');
    const skillDir = path.join(codexCommandsDir, commandName);
    const skillPath = path.join(skillDir, 'SKILL.md');

    await fs.ensureDir(skillDir);
    await fs.writeFile(skillPath, buildCommandSkillContent(commandPath, commandRaw));
  }

  return commandFiles.length;
}

export async function syncWithCodex(targetDir: string): Promise<CodexSyncResult> {
  const codexHome = path.resolve(targetDir, '.codex');
  const codexSkillsDir = path.join(codexHome, 'skills');
  const codexCommandsDir = path.join(codexSkillsDir, 'claude-commands');

  await fs.ensureDir(codexSkillsDir);

  const claudeRootDir = path.join(targetDir, '.claude');
  const claudeSkillsDir = path.join(claudeRootDir, 'skills');
  const claudeCommandsDir = path.join(claudeRootDir, 'commands');

  const syncedSkills = await syncSkills(claudeSkillsDir, codexSkillsDir);
  const syncedCommands = await syncCommands(claudeCommandsDir, codexCommandsDir);

  return {
    codexHome,
    codexSkillsDir,
    codexCommandsDir,
    syncedSkills,
    syncedCommands,
  };
}
