import fs from 'fs-extra';
import os from 'os';
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
  type InstallScope,
} from '../features/extras/index.js';
import {
  promptTemplateSelection,
  promptOverwrite,
  promptExtrasSelection,
  promptScopeSelection,
} from '../shared/prompts/index.js';
import { updateGitignore } from '../shared/gitignore-manager.js';

interface InitOptions {
  templates?: string[];
  force?: boolean;
  cwd?: string;
  scope?: string;
  skills?: boolean;
  commands?: boolean;
  agents?: boolean;
  instructions?: boolean;
  scripts?: boolean;
}

const TEMPLATE_DESCRIPTIONS: Record<string, string> = {
  'tanstack-start': 'TanStack Start + React 풀스택 프로젝트',
  hono: 'Hono 서버 프레임워크 프로젝트',
  npx: 'NPX CLI 도구 프로젝트',
  tauri: 'Tauri 데스크톱/모바일 크로스플랫폼 앱',
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
  hasScripts: boolean,
): Promise<ExtrasFlags> {
  return await promptExtrasSelection({
    skills: options.skills,
    commands: options.commands,
    agents: options.agents,
    instructions: options.instructions,
    scripts: options.scripts,
    hasSkills,
    hasCommands,
    hasAgents,
    hasInstructions,
    hasScripts,
  });
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
  hasScripts: boolean,
  scope: InstallScope,
): void {
  const {
    installSkills,
    installCommands,
    installAgents,
    installInstructions,
    installScripts,
  } = flags;

  const hasExtrasInstalled =
    (installSkills && hasSkills) ||
    (installCommands && hasCommands) ||
    (installAgents && hasAgents) ||
    (installInstructions && hasInstructions) ||
    (installScripts && hasScripts);

  // 템플릿도 없고 extras도 설치하지 않은 경우
  if (templates.length === 0 && !hasExtrasInstalled) {
    logger.blank();
    logger.info('No templates or extras installed.');
    logger.blank();
    return;
  }

  const scopeLabel =
    scope === 'user' ? '(user scope → ~/.claude/)' : '(project scope)';

  logger.blank();
  logger.success(`Claude Code documentation installed! ${scopeLabel}`);

  // 템플릿이 있는 경우에만 표시
  if (templates.length > 0) {
    logger.blank();
    logger.info('Installed templates:');
    templates.forEach((t) => logger.step(t));
  }

  if (hasExtrasInstalled) {
    logger.blank();
    logger.info('Installed extras:');
    if (installSkills && hasSkills) {
      logger.step('Skills → .claude/skills/');
    }
    if (installCommands && hasCommands) {
      logger.step('Commands → .claude/commands/');
    }
    if (installAgents && hasAgents) {
      logger.step('Agents → .claude/agents/');
    }
    if (installInstructions && hasInstructions) {
      logger.step('Instructions → .claude/instructions/');
    }
    if (installScripts && hasScripts) {
      logger.step('Scripts → .claude/scripts/');
    }
  }

  logger.blank();
  logger.info('Next steps:');
  if (templates.length > 0) {
    logger.step('Read CLAUDE.md for project guidelines');
    logger.step('Explore docs/ for detailed documentation');
  } else {
    logger.step('Explore .claude/ for installed extras');
    logger.step('Run "npx @kood/claude-code init" again to install templates');
  }
  logger.blank();
}

export const init = async (options: InitOptions): Promise<void> => {
  const projectDir = options.cwd || process.cwd();

  // 1. 대상 디렉토리 검증 (프로젝트 디렉토리는 항상 검증)
  await validateTargetDirectory(projectDir);

  // 2. Scope 선택
  const { scope } = await promptScopeSelection({
    providedScope: options.scope,
  });

  // User scope: targetDir = 홈 디렉토리, Project scope: targetDir = CWD
  const targetDir = scope === 'user' ? os.homedir() : projectDir;
  const isUserScope = scope === 'user';

  if (isUserScope) {
    logger.blank();
    logger.info(`Installing to ~/.claude/ (user scope)`);
  }

  // 3. 사용 가능한 템플릿 목록 확인
  const availableTemplates = await listAvailableTemplates();
  if (availableTemplates.length === 0) {
    logger.error('No templates found. Package may be corrupted.');
    process.exit(1);
  }

  // 4. 템플릿 선택 및 설치 (Project scope에서만)
  let templates: string[] = [];
  if (!isUserScope) {
    templates = await selectTemplates(options, availableTemplates);

    if (templates.length > 0) {
      // 기존 파일 덮어쓰기 확인
      await confirmOverwriteIfNeeded(targetDir, options.force ?? false);

      // 템플릿 설치
      await installTemplates(templates, targetDir);
    }
  }

  // 5. 스킬/커맨드/에이전트/인스트럭션 존재 여부 확인
  const templatesToCheck =
    templates.length > 0 ? templates : availableTemplates;
  const { hasSkills, hasCommands, hasAgents, hasInstructions, hasScripts } =
    await checkAllExtrasExist(templatesToCheck);

  // 6. 스킬/커맨드 설치 여부 프롬프트
  const flags = await promptForExtrasInstallation(
    options,
    hasSkills,
    hasCommands,
    hasAgents,
    hasInstructions,
    hasScripts,
  );

  // 7. 스킬/커맨드/에이전트/인스트럭션/스크립트 설치 (자동 업데이트)
  await installExtras(templatesToCheck, targetDir, flags, {
    hasSkills,
    hasCommands,
    hasAgents,
    hasInstructions,
    hasScripts,
  });

  // 8. 설치 요약 출력
  showInstallationSummary(
    templates,
    flags,
    hasSkills,
    hasCommands,
    hasAgents,
    hasInstructions,
    hasScripts,
    scope,
  );

  // 9. .gitignore에 Claude Code 생성 폴더 추가 (Project scope에서만)
  if (!isUserScope) {
    try {
      await updateGitignore(targetDir);
    } catch (error) {
      logger.warn(
        `Failed to update .gitignore: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
    }
  }
};
