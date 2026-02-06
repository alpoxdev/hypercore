import fs from 'fs-extra';
import { logger } from '../shared/logger.js';
import {
  copySingleTemplate,
  copyMultipleTemplates,
  checkExistingFiles,
  listAvailableTemplates,
} from '../features/templates/index.js';
import {
  checkAllExtrasExist,
  installExtras,
  type InstallResult,
  type ExtrasFlags,
} from '../features/extras/index.js';
import {
  promptTemplateSelection,
  promptOverwrite,
  promptExtrasSelection,
  promptAgentSelection,
  promptScopeSelection,
} from '../shared/prompts/index.js';
import { updateGitignore } from '../shared/gitignore-manager.js';
import {
  detectInstalledAgents,
  validateAgentNames,
  getValidAgentNames,
  type AgentType,
  type ScopeType,
} from '../features/agents/index.js';

interface InitOptions {
  templates?: string[];
  force?: boolean;
  cwd?: string;
  skills?: boolean;
  commands?: boolean;
  installAgents?: boolean;
  instructions?: boolean;
  targetAgents?: string[];
  global?: boolean;
}

const TEMPLATE_DESCRIPTIONS: Record<string, string> = {
  'tanstack-start': 'TanStack Start + React 풀스택 프로젝트',
  hono: 'Hono 서버 프레임워크 프로젝트',
  npx: 'NPX CLI 도구 프로젝트',
};

/**
 * 대상 디렉토리 검증 (존재 여부, 쓰기 권한)
 */
async function validateTargetDirectory(targetDir: string): Promise<void> {
  try {
    const stat = await fs.stat(targetDir);
    if (!stat.isDirectory()) {
      logger.error(`Target is not a directory: ${targetDir}`);
      process.exit(1);
    }
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
      logger.error(`Target directory does not exist: ${targetDir}`);
    } else {
      logger.error(`Cannot access target directory: ${targetDir}`);
    }
    process.exit(1);
  }

  try {
    await fs.access(targetDir, fs.constants.W_OK);
  } catch {
    logger.error(`No write permission for: ${targetDir}`);
    process.exit(1);
  }
}

/**
 * 템플릿 선택 (CLI 인자 또는 프롬프트)
 */
async function selectTemplates(
  options: InitOptions,
  availableTemplates: string[],
): Promise<string[]> {
  const result = await promptTemplateSelection({
    providedTemplates: options.templates,
    availableTemplates,
    templateDescriptions: TEMPLATE_DESCRIPTIONS,
  });

  return result.templates;
}

/**
 * 기존 파일 덮어쓰기 확인
 */
async function confirmOverwriteIfNeeded(
  targetDir: string,
  force: boolean,
): Promise<void> {
  const existingFiles = await checkExistingFiles(targetDir);

  await promptOverwrite({ existingFiles, force });
}

/**
 * 템플릿 설치 (단일 또는 다중)
 */
async function installTemplates(
  templates: string[],
  targetDir: string,
): Promise<InstallResult> {
  const isSingleTemplate = templates.length === 1;
  let totalFiles = 0;
  let totalDirectories = 0;

  logger.blank();

  try {
    if (isSingleTemplate) {
      const template = templates[0];
      logger.info(`Installing ${template} template...`);
      logger.step(`Target: ${targetDir}`);
      logger.blank();

      const result = await copySingleTemplate(template, targetDir);
      totalFiles = result.files;
      totalDirectories = result.directories;

      logger.success(`${template}: ${result.files} files copied`);
    } else {
      logger.info(`Installing ${templates.length} templates...`);
      logger.step(`Target: ${targetDir}/docs/`);
      logger.blank();

      const result = await copyMultipleTemplates(templates, targetDir);
      totalFiles = result.files;
      totalDirectories = result.directories;

      for (const template of templates) {
        logger.success(`${template}: installed to docs/${template}/`);
      }
    }
  } catch (error) {
    logger.error(
      `Failed to install templates: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );
    process.exit(1);
  }

  logger.blank();
  logger.success(`Total: ${totalFiles} files, ${totalDirectories} directories`);

  return { files: totalFiles, directories: totalDirectories };
}

/**
 * 스킬/커맨드 설치 여부 프롬프트
 */
async function promptForExtrasInstallation(
  options: InitOptions,
  hasSkills: boolean,
  hasCommands: boolean,
  hasAgents: boolean,
  hasInstructions: boolean,
): Promise<ExtrasFlags> {
  return await promptExtrasSelection({
    skills: options.skills,
    commands: options.commands,
    agents: options.installAgents,
    instructions: options.instructions,
    hasSkills,
    hasCommands,
    hasAgents,
    hasInstructions,
  });
}

/**
 * 에이전트 선택 (CLI 인자 또는 프롬프트)
 */
async function selectAgents(options: InitOptions): Promise<AgentType[]> {
  // CLI 인자로 제공된 경우 (유효성 검증 포함)
  if (options.targetAgents && options.targetAgents.length > 0) {
    const { valid, invalid } = validateAgentNames(options.targetAgents);
    if (invalid.length > 0) {
      logger.error(`Unknown agents: ${invalid.join(', ')}`);
      logger.info(`Available agents: ${getValidAgentNames().join(', ')}`);
      process.exit(1);
    }
    return valid;
  }

  // 자동 감지
  const installedAgents = await detectInstalledAgents();

  // 프롬프트로 선택
  const result = await promptAgentSelection({ installedAgents });
  return result.agents;
}

/**
 * Scope 선택
 */
async function selectScope(options: InitOptions): Promise<ScopeType> {
  // CLI 플래그로 제공된 경우
  if (options.global) {
    return 'global';
  }

  // 프롬프트로 선택
  const result = await promptScopeSelection();
  return result.scope;
}

/**
 * 설치 요약 출력
 */
function showInstallationSummary(
  templates: string[],
  flags: ExtrasFlags,
  hasSkills: boolean,
  hasCommands: boolean,
  hasAgents: boolean,
  hasInstructions: boolean,
  agents: AgentType[],
  scope: ScopeType,
): void {
  logger.blank();
  logger.success('Claude Code documentation installed!');
  logger.blank();
  logger.info('Installed templates:');
  templates.forEach((t) => logger.step(t));

  logger.blank();
  logger.info(`Agents: ${agents.join(', ')}`);
  logger.info(`Scope: ${scope}`);

  const { installSkills, installCommands, installAgents, installInstructions } =
    flags;

  if (
    (installSkills && hasSkills) ||
    (installCommands && hasCommands) ||
    (installAgents && hasAgents) ||
    (installInstructions && hasInstructions)
  ) {
    logger.blank();
    logger.info('Installed extras:');
    if (installSkills && hasSkills) {
      logger.step('Skills');
    }
    if (installCommands && hasCommands) {
      logger.step('Commands');
    }
    if (installAgents && hasAgents) {
      logger.step('Agents');
    }
    if (installInstructions && hasInstructions) {
      logger.step('Instructions');
    }
  }

  logger.blank();
  logger.info('Next steps:');
  logger.step('Read CLAUDE.md for project guidelines');
  logger.step('Explore docs/ for detailed documentation');
  logger.blank();
}

export const init = async (options: InitOptions): Promise<void> => {
  const targetDir = options.cwd || process.cwd();

  // 1. 대상 디렉토리 검증
  await validateTargetDirectory(targetDir);

  // 2. 사용 가능한 템플릿 목록 확인
  const availableTemplates = await listAvailableTemplates();
  if (availableTemplates.length === 0) {
    logger.error('No templates found. Package may be corrupted.');
    process.exit(1);
  }

  // 3. 템플릿 선택
  const templates = await selectTemplates(options, availableTemplates);

  // 4. 기존 파일 덮어쓰기 확인
  await confirmOverwriteIfNeeded(targetDir, options.force ?? false);

  // 5. 템플릿 설치
  await installTemplates(templates, targetDir);

  // 6. 에이전트 선택
  const agents = await selectAgents(options);

  // 7. Scope 선택
  const scope = await selectScope(options);

  // 8. 스킬/커맨드/에이전트/인스트럭션 존재 여부 확인
  const { hasSkills, hasCommands, hasAgents, hasInstructions } =
    await checkAllExtrasExist(templates);

  // 9. 스킬/커맨드 설치 여부 프롬프트
  const flags = await promptForExtrasInstallation(
    options,
    hasSkills,
    hasCommands,
    hasAgents,
    hasInstructions,
  );

  // 10. 스킬/커맨드/에이전트/인스트럭션 설치 (에이전트 + 스코프 전달)
  await installExtras(
    templates,
    targetDir,
    flags,
    { hasSkills, hasCommands, hasAgents, hasInstructions },
    agents,
    scope,
    options.force ?? false,
  );

  // 11. 설치 요약 출력
  showInstallationSummary(
    templates,
    flags,
    hasSkills,
    hasCommands,
    hasAgents,
    hasInstructions,
    agents,
    scope,
  );

  // 12. .gitignore에 Claude Code 생성 폴더 추가
  try {
    await updateGitignore(targetDir);
  } catch (error) {
    logger.warn(
      `Failed to update .gitignore: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );
  }
};
