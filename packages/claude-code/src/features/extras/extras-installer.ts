import { logger } from '../../shared/logger.js';
import { promptConfirm } from '../../shared/prompts/index.js';
import {
  copySkills,
  copyCommands,
  copyAgents,
  copyInstructions,
} from './extras-copier.js';
import { checkExistingExtrasFiles } from './extras-checker.js';
import type { AgentType, ScopeType } from '../agents/types.js';
import type { InstallResult, ExtrasFlags } from './types.js';

/**
 * 중복 파일 처리: 사용자에게 덮어쓰기 여부 확인
 */
async function handleDuplicateFiles(
  existingClaudeFiles: string[],
  force: boolean,
): Promise<boolean> {
  if (existingClaudeFiles.length === 0 || force) {
    return true;
  }

  logger.warn('The following extras files/folders already exist:');
  existingClaudeFiles.forEach((f) => logger.step(f));
  logger.blank();

  const response = await promptConfirm(
    'Overwrite existing extras files?',
    false,
  );

  return response.confirmed;
}

/**
 * Skills 설치
 */
async function installSkillsIfNeeded(
  templates: string[],
  targetDir: string,
  shouldInstall: boolean,
  hasSkills: boolean,
  agents: AgentType[],
  scope: ScopeType,
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
  const skillsResult = await copySkills(templates, targetDir, agents, scope);

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
  agents: AgentType[],
  scope: ScopeType,
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
  const commandsResult = await copyCommands(
    templates,
    targetDir,
    agents,
    scope,
  );
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
  agents: AgentType[],
  scope: ScopeType,
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
  const agentsResult = await copyAgents(templates, targetDir, agents, scope);
  logger.success(
    `Agents: ${agentsResult.files} files, ${agentsResult.directories} directories`,
  );
  return agentsResult;
}

/**
 * Instructions 설치
 */
async function installInstructionsIfNeeded(
  templates: string[],
  targetDir: string,
  shouldInstall: boolean,
  hasInstructions: boolean,
  agents: AgentType[],
  scope: ScopeType,
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
  const instructionsResult = await copyInstructions(
    templates,
    targetDir,
    agents,
    scope,
  );
  logger.success(
    `Instructions: ${instructionsResult.files} files, ${instructionsResult.directories} directories`,
  );
  return instructionsResult;
}

/**
 * Extras 설치 (Skills, Commands, Agents, Instructions)
 * 중복 파일 처리 및 사용자 프롬프트 포함
 * agents, scope 매개변수로 에이전트별 경로 해석
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
  },
  agents: AgentType[],
  scope: ScopeType,
  force: boolean,
): Promise<InstallResult> {
  const { installSkills, installCommands, installAgents, installInstructions } =
    flags;

  // 설치할 항목이 없으면 조기 종료
  if (
    !installSkills &&
    !installCommands &&
    !installAgents &&
    !installInstructions
  ) {
    return { files: 0, directories: 0 };
  }

  // 기존 파일 중복 처리
  const existingClaudeFiles = await checkExistingExtrasFiles(targetDir);
  const shouldProceed = await handleDuplicateFiles(existingClaudeFiles, force);

  if (!shouldProceed) {
    logger.info('Skipping extras installation.');
    return { files: 0, directories: 0 };
  }

  // 각 extras 설치 (agents, scope 전달)
  const skillsResult = await installSkillsIfNeeded(
    templates,
    targetDir,
    installSkills,
    availability.hasSkills,
    agents,
    scope,
  );

  const commandsResult = await installCommandsIfNeeded(
    templates,
    targetDir,
    installCommands,
    availability.hasCommands,
    agents,
    scope,
  );

  const agentsResult = await installAgentsIfNeeded(
    templates,
    targetDir,
    installAgents,
    availability.hasAgents,
    agents,
    scope,
  );

  const instructionsResult = await installInstructionsIfNeeded(
    templates,
    targetDir,
    installInstructions,
    availability.hasInstructions,
    agents,
    scope,
  );

  // 전체 결과 집계
  const totalFiles =
    skillsResult.files +
    commandsResult.files +
    agentsResult.files +
    instructionsResult.files;

  const totalDirectories =
    skillsResult.directories +
    commandsResult.directories +
    agentsResult.directories +
    instructionsResult.directories;

  return { files: totalFiles, directories: totalDirectories };
}
