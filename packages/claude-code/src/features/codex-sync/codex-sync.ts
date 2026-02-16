import fs from 'fs-extra';
import os from 'os';
import path from 'path';
import { copyRecursive } from '../../shared/filesystem/index.js';

export interface CodexSyncResult {
  codexHome: string;
  codexSkillsDir: string;
  codexCommandsDir: string;
  codexInstructionsDir: string;
  syncedSkills: number;
  syncedCommands: number;
  syncedInstructions: number;
  codexMcpConfigPath: string;
  syncedMcpServers: number;
  mcpScope: 'global' | 'local';
  referenceIssueCount: number;
  referenceIssueSamples: ReferenceIssue[];
}

const RESERVED_CODEX_SKILL_DIRS = new Set(['.system', 'claude-commands']);
const COMMAND_INSTRUCTION_PREFIX_REGEX = /^@\.\.\/instructions\//gm;
const COMMAND_INSTRUCTION_PREFIX_REPLACEMENT = '@../../../instructions/';
const MAX_REFERENCE_ISSUE_SAMPLES = 10;
const CLAUDE_STATE_FILE = '.claude.json';
const CLAUDE_LOCAL_MCP_FILE = '.mcp.json';
const CODEX_CONFIG_FILE = 'config.toml';

type JsonRecord = Record<string, unknown>;

interface ClaudeMcpServer {
  type?: string;
  command?: string;
  args?: string[];
  env?: Record<string, string>;
  cwd?: string;
  url?: string;
  headers?: Record<string, string>;
  bearerTokenEnvVar?: string;
  envHttpHeaders?: Record<string, string>;
}

interface CodexMcpServer {
  kind: 'stdio' | 'http';
  command?: string;
  args?: string[];
  env?: Record<string, string>;
  cwd?: string;
  url?: string;
  bearerTokenEnvVar?: string;
  httpHeaders?: Record<string, string>;
  envHttpHeaders?: Record<string, string>;
}

interface ReferenceIssue {
  skillPath: string;
  reference: string;
  resolvedPath: string;
}

function normalizeLineEndings(content: string): string {
  return content.replace(/\r\n/g, '\n');
}

function yamlQuote(value: string): string {
  return `"${value.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
}

function extractDescriptionFromFrontmatter(
  markdown: string,
): string | undefined {
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

function buildCommandSkillContent(
  commandPath: string,
  commandRaw: string,
): string {
  const commandName = path.basename(commandPath, '.md');
  const normalizedCommand = normalizeLineEndings(commandRaw).trim();
  const rewrittenCommand = normalizedCommand.replace(
    COMMAND_INSTRUCTION_PREFIX_REGEX,
    COMMAND_INSTRUCTION_PREFIX_REPLACEMENT,
  );
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

${rewrittenCommand}
`;
}

function isRecord(value: unknown): value is JsonRecord {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value);
}

function asStringArray(value: unknown): string[] | undefined {
  if (!Array.isArray(value)) {
    return undefined;
  }

  const items = value.filter(
    (item): item is string => typeof item === 'string',
  );
  return items.length > 0 ? items : undefined;
}

function asStringRecord(value: unknown): Record<string, string> | undefined {
  if (!isRecord(value)) {
    return undefined;
  }

  const entries = Object.entries(value).filter(
    (entry): entry is [string, string] => typeof entry[1] === 'string',
  );
  if (entries.length === 0) {
    return undefined;
  }

  return Object.fromEntries(entries);
}

function normalizeClaudeMcpServer(value: unknown): ClaudeMcpServer | undefined {
  if (!isRecord(value)) {
    return undefined;
  }

  const type = typeof value.type === 'string' ? value.type : undefined;
  const command = typeof value.command === 'string' ? value.command : undefined;
  const args = asStringArray(value.args);
  const env = asStringRecord(value.env);
  const cwd = typeof value.cwd === 'string' ? value.cwd : undefined;
  const url = typeof value.url === 'string' ? value.url : undefined;
  const headers = asStringRecord(value.headers);
  const bearerTokenEnvVar =
    typeof value.bearerTokenEnvVar === 'string'
      ? value.bearerTokenEnvVar
      : typeof value.bearer_token_env_var === 'string'
        ? value.bearer_token_env_var
        : undefined;
  const envHttpHeaders =
    asStringRecord(value.envHttpHeaders) ||
    asStringRecord(value.env_http_headers);

  return {
    type,
    command,
    args,
    env,
    cwd,
    url,
    headers,
    bearerTokenEnvVar,
    envHttpHeaders,
  };
}

function normalizeClaudeMcpServers(
  value: unknown,
): Record<string, ClaudeMcpServer> {
  if (!isRecord(value)) {
    return {};
  }

  const normalizedEntries = Object.entries(value)
    .map(([name, server]) => [name, normalizeClaudeMcpServer(server)] as const)
    .filter((entry): entry is [string, ClaudeMcpServer] => Boolean(entry[1]));

  return Object.fromEntries(normalizedEntries);
}

function getProjectState(
  claudeState: JsonRecord,
  targetDir: string,
): JsonRecord | undefined {
  const projects = claudeState.projects;
  if (!isRecord(projects)) {
    return undefined;
  }

  const normalizedTarget = path.resolve(targetDir);
  for (const [projectPath, projectState] of Object.entries(projects)) {
    if (path.resolve(projectPath) !== normalizedTarget) {
      continue;
    }

    if (isRecord(projectState)) {
      return projectState;
    }
  }

  return undefined;
}

function filterMcpJsonServersByProjectState(
  servers: Record<string, ClaudeMcpServer>,
  projectState: JsonRecord | undefined,
): Record<string, ClaudeMcpServer> {
  if (!projectState) {
    return servers;
  }

  const enabled = asStringArray(projectState.enabledMcpjsonServers) || [];
  const disabled = new Set(
    asStringArray(projectState.disabledMcpjsonServers) || [],
  );
  const enabledSet = new Set(enabled);
  const hasEnabledFilter = enabledSet.size > 0;

  const filteredEntries = Object.entries(servers).filter(([name]) => {
    if (hasEnabledFilter && !enabledSet.has(name)) {
      return false;
    }
    if (disabled.has(name)) {
      return false;
    }
    return true;
  });

  return Object.fromEntries(filteredEntries);
}

async function readJsonFile(filePath: string): Promise<JsonRecord | undefined> {
  if (!(await fs.pathExists(filePath))) {
    return undefined;
  }

  try {
    const raw = await fs.readFile(filePath, 'utf8');
    const parsed = JSON.parse(raw) as unknown;
    if (!isRecord(parsed)) {
      return undefined;
    }

    return parsed;
  } catch {
    return undefined;
  }
}

function toCodexMcpServer(server: ClaudeMcpServer): CodexMcpServer | undefined {
  const serverType = server.type?.toLowerCase();
  const isHttp = serverType === 'http' || Boolean(server.url);

  if (isHttp) {
    if (!server.url) {
      return undefined;
    }

    return {
      kind: 'http',
      url: server.url,
      bearerTokenEnvVar: server.bearerTokenEnvVar,
      httpHeaders: server.headers,
      envHttpHeaders: server.envHttpHeaders,
    };
  }

  if (!server.command) {
    return undefined;
  }

  return {
    kind: 'stdio',
    command: server.command,
    args: server.args,
    env: server.env,
    cwd: server.cwd,
  };
}

function tomlQuote(value: string): string {
  return `"${value.replace(/\\/g, '\\\\').replace(/"/g, '\\"')}"`;
}

function tomlKey(value: string): string {
  return /^[A-Za-z0-9_-]+$/.test(value) ? value : tomlQuote(value);
}

function parseTomlPath(input: string): string[] | undefined {
  const pathInput = input.trim();
  if (!pathInput) {
    return undefined;
  }

  const segments: string[] = [];
  let current = '';
  let inQuotes = false;
  let escaped = false;

  for (const char of pathInput) {
    if (inQuotes) {
      if (escaped) {
        current += char;
        escaped = false;
        continue;
      }

      if (char === '\\') {
        escaped = true;
        continue;
      }

      if (char === '"') {
        inQuotes = false;
        continue;
      }

      current += char;
      continue;
    }

    if (char === '"') {
      inQuotes = true;
      continue;
    }

    if (char === '.') {
      const value = current.trim();
      if (!value) {
        return undefined;
      }
      segments.push(value);
      current = '';
      continue;
    }

    current += char;
  }

  if (inQuotes || escaped) {
    return undefined;
  }

  const tail = current.trim();
  if (!tail) {
    return undefined;
  }

  segments.push(tail);
  return segments;
}

function stripCodexMcpSections(configToml: string): string {
  const lines = normalizeLineEndings(configToml).split('\n');
  const kept: string[] = [];
  let droppingMcpSection = false;

  for (const line of lines) {
    const headerMatch = line.match(/^\s*\[([^\]]+)\]\s*$/);
    if (headerMatch) {
      const headerPath = parseTomlPath(headerMatch[1]);
      droppingMcpSection = Boolean(
        headerPath && headerPath.length > 0 && headerPath[0] === 'mcp_servers',
      );
    }

    if (!droppingMcpSection) {
      kept.push(line);
    }
  }

  return kept
    .join('\n')
    .replace(/\n{3,}/g, '\n\n')
    .trimEnd();
}

function renderTomlStringArray(
  values: string[] | undefined,
): string | undefined {
  if (!values || values.length === 0) {
    return undefined;
  }

  return `[${values.map((value) => tomlQuote(value)).join(', ')}]`;
}

function renderTomlStringTable(
  header: string,
  values: Record<string, string> | undefined,
): string | undefined {
  if (!values || Object.keys(values).length === 0) {
    return undefined;
  }

  const lines = Object.entries(values)
    .sort((a, b) => a[0].localeCompare(b[0]))
    .map(([key, value]) => `${tomlKey(key)} = ${tomlQuote(value)}`);

  return `${header}\n${lines.join('\n')}`;
}

function renderCodexMcpServer(name: string, server: CodexMcpServer): string {
  const sectionRoot = `[mcp_servers.${tomlKey(name)}]`;
  const lines: string[] = [sectionRoot];

  if (server.kind === 'http') {
    lines.push(`url = ${tomlQuote(server.url ?? '')}`);
    if (server.bearerTokenEnvVar) {
      lines.push(
        `bearer_token_env_var = ${tomlQuote(server.bearerTokenEnvVar)}`,
      );
    }
  } else {
    lines.push(`command = ${tomlQuote(server.command ?? '')}`);
    const args = renderTomlStringArray(server.args);
    if (args) {
      lines.push(`args = ${args}`);
    }
    if (server.cwd) {
      lines.push(`cwd = ${tomlQuote(server.cwd)}`);
    }
  }

  const envSection =
    server.kind === 'stdio'
      ? renderTomlStringTable(`[mcp_servers.${tomlKey(name)}.env]`, server.env)
      : undefined;
  const httpHeadersSection =
    server.kind === 'http'
      ? renderTomlStringTable(
          `[mcp_servers.${tomlKey(name)}.http_headers]`,
          server.httpHeaders,
        )
      : undefined;
  const envHttpHeadersSection =
    server.kind === 'http'
      ? renderTomlStringTable(
          `[mcp_servers.${tomlKey(name)}.env_http_headers]`,
          server.envHttpHeaders,
        )
      : undefined;

  const sections = [
    lines.join('\n'),
    envSection,
    httpHeadersSection,
    envHttpHeadersSection,
  ].filter((section): section is string => Boolean(section));

  return sections.join('\n\n');
}

function mergeCodexConfigToml(
  existingToml: string,
  renderedMcpBlocks: string,
): string {
  const base = stripCodexMcpSections(existingToml);
  const mcp = renderedMcpBlocks.trim();

  if (!base) {
    return mcp;
  }
  if (!mcp) {
    return base;
  }

  return `${base}\n\n${mcp}`;
}

async function loadClaudeMcpServers(
  targetDir: string,
): Promise<{
  scope: 'global' | 'local';
  servers: Record<string, ClaudeMcpServer>;
}> {
  const homeDir = path.resolve(os.homedir());
  const normalizedTarget = path.resolve(targetDir);
  const isUserScope = normalizedTarget === homeDir;
  const claudeStatePath = path.join(homeDir, CLAUDE_STATE_FILE);
  const claudeState = await readJsonFile(claudeStatePath);

  if (isUserScope) {
    return {
      scope: 'global',
      servers: normalizeClaudeMcpServers(claudeState?.mcpServers),
    };
  }

  const projectState = claudeState
    ? getProjectState(claudeState, normalizedTarget)
    : undefined;
  const projectServers = normalizeClaudeMcpServers(projectState?.mcpServers);

  const localMcpPath = path.join(normalizedTarget, CLAUDE_LOCAL_MCP_FILE);
  const localMcpState = await readJsonFile(localMcpPath);
  const localMcpServers = filterMcpJsonServersByProjectState(
    normalizeClaudeMcpServers(localMcpState?.mcpServers),
    projectState,
  );

  return {
    scope: 'local',
    servers: {
      ...localMcpServers,
      ...projectServers,
    },
  };
}

async function syncMcpServers(
  targetDir: string,
): Promise<{
  codexMcpConfigPath: string;
  syncedMcpServers: number;
  scope: 'global' | 'local';
}> {
  const homeDir = path.resolve(os.homedir());
  const normalizedTarget = path.resolve(targetDir);
  const isUserScope = normalizedTarget === homeDir;
  const codexBaseDir = isUserScope
    ? path.join(homeDir, '.codex')
    : path.join(normalizedTarget, '.codex');
  const codexMcpConfigPath = path.join(codexBaseDir, CODEX_CONFIG_FILE);

  const { scope, servers } = await loadClaudeMcpServers(normalizedTarget);
  const codexServers = Object.entries(servers)
    .map(([name, server]) => [name, toCodexMcpServer(server)] as const)
    .filter((entry): entry is [string, CodexMcpServer] => Boolean(entry[1]))
    .sort((a, b) => a[0].localeCompare(b[0]));

  const renderedMcpBlocks = codexServers
    .map(([name, server]) => renderCodexMcpServer(name, server))
    .join('\n\n');

  const existingConfig = (await fs.pathExists(codexMcpConfigPath))
    ? await fs.readFile(codexMcpConfigPath, 'utf8')
    : '';
  const nextConfig = mergeCodexConfigToml(existingConfig, renderedMcpBlocks);

  await fs.ensureDir(codexBaseDir);
  await fs.writeFile(codexMcpConfigPath, `${nextConfig.trimEnd()}\n`);

  return {
    codexMcpConfigPath,
    syncedMcpServers: codexServers.length,
    scope,
  };
}

async function syncSkills(
  claudeSkillsDir: string,
  codexSkillsDir: string,
): Promise<number> {
  await fs.ensureDir(codexSkillsDir);

  let sourceSkillNames: string[] = [];
  if (await fs.pathExists(claudeSkillsDir)) {
    const sourceEntries = await fs.readdir(claudeSkillsDir, {
      withFileTypes: true,
    });
    sourceSkillNames = sourceEntries
      .filter((entry) => entry.isDirectory())
      .map((entry) => entry.name)
      .filter((name) => name !== '.system');
  }

  const sourceSkillSet = new Set(sourceSkillNames);
  const codexEntries = await fs.readdir(codexSkillsDir, {
    withFileTypes: true,
  });

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
    await fs.writeFile(
      skillPath,
      buildCommandSkillContent(commandPath, commandRaw),
    );
  }

  return commandFiles.length;
}

async function syncInstructions(
  claudeInstructionsDir: string,
  codexInstructionsDir: string,
): Promise<number> {
  if (!(await fs.pathExists(claudeInstructionsDir))) {
    await fs.remove(codexInstructionsDir);
    return 0;
  }

  await fs.remove(codexInstructionsDir);
  await fs.ensureDir(codexInstructionsDir);

  const counter = { files: 0, directories: 0 };
  await copyRecursive(claudeInstructionsDir, codexInstructionsDir, counter);

  return counter.files;
}

function extractReferenceCandidate(line: string): string | undefined {
  const trimmed = line.trim();
  if (!trimmed.startsWith('@')) {
    return undefined;
  }

  const [candidate] = trimmed.slice(1).split(/\s+/);
  if (!candidate || candidate.startsWith('#') || candidate.includes('://')) {
    return undefined;
  }

  const looksLikePath =
    candidate.startsWith('./') ||
    candidate.startsWith('../') ||
    candidate.startsWith('/') ||
    candidate.includes('/') ||
    /\.[a-z0-9]+$/i.test(candidate);

  if (!looksLikePath) {
    return undefined;
  }

  return candidate;
}

async function collectSkillMarkdownFiles(
  rootDir: string,
  collector: string[] = [],
): Promise<string[]> {
  if (!(await fs.pathExists(rootDir))) {
    return collector;
  }

  const entries = await fs.readdir(rootDir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(rootDir, entry.name);
    if (entry.isDirectory()) {
      await collectSkillMarkdownFiles(fullPath, collector);
      continue;
    }
    if (entry.isFile() && entry.name === 'SKILL.md') {
      collector.push(fullPath);
    }
  }

  return collector;
}

async function validateSkillReferences(
  codexSkillsDir: string,
): Promise<{ count: number; samples: ReferenceIssue[] }> {
  const skillFiles = await collectSkillMarkdownFiles(codexSkillsDir);
  let count = 0;
  const samples: ReferenceIssue[] = [];

  for (const skillFile of skillFiles) {
    const content = await fs.readFile(skillFile, 'utf8');
    const lines = normalizeLineEndings(content).split('\n');

    for (const line of lines) {
      const candidate = extractReferenceCandidate(line);
      if (!candidate) {
        continue;
      }

      const referencePath = candidate.split(/[?#]/, 1)[0];
      if (!referencePath) {
        continue;
      }

      const resolvedPath = path.resolve(path.dirname(skillFile), referencePath);
      if (await fs.pathExists(resolvedPath)) {
        continue;
      }

      count += 1;
      if (samples.length < MAX_REFERENCE_ISSUE_SAMPLES) {
        samples.push({
          skillPath: skillFile,
          reference: candidate,
          resolvedPath,
        });
      }
    }
  }

  return { count, samples };
}

export async function syncWithCodex(
  targetDir: string,
): Promise<CodexSyncResult> {
  const codexHome = path.resolve(targetDir, '.codex');
  const codexSkillsDir = path.join(codexHome, 'skills');
  const codexCommandsDir = path.join(codexSkillsDir, 'claude-commands');
  const codexInstructionsDir = path.join(codexHome, 'instructions');

  await fs.ensureDir(codexSkillsDir);

  const claudeRootDir = path.join(targetDir, '.claude');
  const claudeSkillsDir = path.join(claudeRootDir, 'skills');
  const claudeCommandsDir = path.join(claudeRootDir, 'commands');
  const claudeInstructionsDir = path.join(claudeRootDir, 'instructions');

  const syncedSkills = await syncSkills(claudeSkillsDir, codexSkillsDir);
  const syncedInstructions = await syncInstructions(
    claudeInstructionsDir,
    codexInstructionsDir,
  );
  const syncedCommands = await syncCommands(
    claudeCommandsDir,
    codexCommandsDir,
  );
  const {
    codexMcpConfigPath,
    syncedMcpServers,
    scope: mcpScope,
  } = await syncMcpServers(targetDir);
  const { count: referenceIssueCount, samples: referenceIssueSamples } =
    await validateSkillReferences(codexSkillsDir);

  return {
    codexHome,
    codexSkillsDir,
    codexCommandsDir,
    codexInstructionsDir,
    syncedSkills,
    syncedCommands,
    syncedInstructions,
    codexMcpConfigPath,
    syncedMcpServers,
    mcpScope,
    referenceIssueCount,
    referenceIssueSamples,
  };
}
