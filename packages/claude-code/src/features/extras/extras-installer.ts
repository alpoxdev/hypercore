import { logger } from '../../shared/logger.js';
import {
  copySkills,
  copyCommands,
  copyAgents,
  copyInstructions,
  copyScripts,
} from './extras-copier.js';
import { checkExistingClaudeFiles } from './extras-checker.js';
import type { InstallResult, ExtrasFlags } from './types.js';

/**
 * 기존 파일 존재 시 업데이트 안내 로그 출력
 */
function logExistingFilesUpdate(existingClaudeFiles: string[]): void {
  if (existingClaudeFiles.length > 0) {
    logger.info('Updating existing extras:');
    existingClaudeFiles.forEach((f) => logger.step(f));
  }
}

/**
 * Skills 설치
 */
async function installSkillsIfNeeded(
  templates: string[],
  targetDir: string,
  shouldInstall: boolean,
  hasSkills: boolean,
): Promise<InstallResult> {
  if (!shouldInstall) {
    return { files: 0, directories: 0 };
  }

  if (!hasSkills) {
    logger.warn('No skills found in selected templates.');
    return { files: 0, directories: 0 };
  }

  logger.blank();
  logger.info('Installing skills...');
  const skillsResult = await copySkills(templates, targetDir);

  logger.success(
    `Skills: ${skillsResult.files} files, ${skillsResult.directories} directories`,
  );
  return skillsResult;
}

/**
 * Commands 설치
 */
async function installCommandsIfNeeded(
  templates: string[],
  targetDir: string,
  shouldInstall: boolean,
  hasCommands: boolean,
): Promise<InstallResult> {
  if (!shouldInstall) {
    return { files: 0, directories: 0 };
  }

  if (!hasCommands) {
    logger.warn('No commands found in selected templates.');
    return { files: 0, directories: 0 };
  }

  logger.blank();
  logger.info('Installing commands...');
  const commandsResult = await copyCommands(templates, targetDir);
  logger.success(
    `Commands: ${commandsResult.files} files, ${commandsResult.directories} directories`,
  );
  return commandsResult;
}

/**
 * Agents 설치
 */
async function installAgentsIfNeeded(
  templates: string[],
  targetDir: string,
  shouldInstall: boolean,
  hasAgents: boolean,
): Promise<InstallResult> {
  if (!shouldInstall) {
    return { files: 0, directories: 0 };
  }

  if (!hasAgents) {
    logger.warn('No agents found in selected templates.');
    return { files: 0, directories: 0 };
  }

  logger.blank();
  logger.info('Installing agents...');
  const agentsResult = await copyAgents(templates, targetDir);
  logger.success(
    `Agents: ${agentsResult.files} files, ${agentsResult.directories} directories`,
  );
  return agentsResult;
}

/**
 * Scripts 설치
 */
async function installScriptsIfNeeded(
  templates: string[],
  targetDir: string,
  shouldInstall: boolean,
  hasScripts: boolean,
): Promise<InstallResult> {
  if (!shouldInstall) {
    return { files: 0, directories: 0 };
  }

  if (!hasScripts) {
    logger.warn('No scripts found in selected templates.');
    return { files: 0, directories: 0 };
  }

  logger.blank();
  logger.info('Installing scripts...');
  const scriptsResult = await copyScripts(templates, targetDir);
  logger.success(
    `Scripts: ${scriptsResult.files} files, ${scriptsResult.directories} directories`,
  );
  return scriptsResult;
}

/**
 * Instructions 설치
 */
async function installInstructionsIfNeeded(
  templates: string[],
  targetDir: string,
  shouldInstall: boolean,
  hasInstructions: boolean,
): Promise<InstallResult> {
  if (!shouldInstall) {
    return { files: 0, directories: 0 };
  }

  if (!hasInstructions) {
    logger.warn('No instructions found in selected templates.');
    return { files: 0, directories: 0 };
  }

  logger.blank();
  logger.info('Installing instructions...');
  const instructionsResult = await copyInstructions(templates, targetDir);
  logger.success(
    `Instructions: ${instructionsResult.files} files, ${instructionsResult.directories} directories`,
  );
  return instructionsResult;
}

/**
 * Extras 설치 (Skills, Commands, Agents, Instructions)
 * 기존 파일이 있으면 자동으로 업데이트 (덮어쓰기)
 */
export async function installExtras(
  templates: string[],
  targetDir: string,
  flags: ExtrasFlags,
  availability: {
    hasSkills: boolean;
    hasCommands: boolean;
    hasAgents: boolean;
    hasInstructions: boolean;
    hasScripts: boolean;
  },
): Promise<InstallResult> {
  const {
    installSkills,
    installCommands,
    installAgents,
    installInstructions,
    installScripts,
  } = flags;

  // 설치할 항목이 없으면 조기 종료
  if (
    !installSkills &&
    !installCommands &&
    !installAgents &&
    !installInstructions &&
    !installScripts
  ) {
    return { files: 0, directories: 0 };
  }

  // 기존 파일 안내 (프롬프트 없이 자동 업데이트)
  const existingClaudeFiles = await checkExistingClaudeFiles(targetDir);
  logExistingFilesUpdate(existingClaudeFiles);

  // 각 extras 설치
  const skillsResult = await installSkillsIfNeeded(
    templates,
    targetDir,
    installSkills,
    availability.hasSkills,
  );

  const commandsResult = await installCommandsIfNeeded(
    templates,
    targetDir,
    installCommands,
    availability.hasCommands,
  );

  const agentsResult = await installAgentsIfNeeded(
    templates,
    targetDir,
    installAgents,
    availability.hasAgents,
  );

  const instructionsResult = await installInstructionsIfNeeded(
    templates,
    targetDir,
    installInstructions,
    availability.hasInstructions,
  );

  const scriptsResult = await installScriptsIfNeeded(
    templates,
    targetDir,
    installScripts,
    availability.hasScripts,
  );

  // 전체 결과 집계
  const totalFiles =
    skillsResult.files +
    commandsResult.files +
    agentsResult.files +
    instructionsResult.files +
    scriptsResult.files;

  const totalDirectories =
    skillsResult.directories +
    commandsResult.directories +
    agentsResult.directories +
    instructionsResult.directories +
    scriptsResult.directories;

  return { files: totalFiles, directories: totalDirectories };
}
