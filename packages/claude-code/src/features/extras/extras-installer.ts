import { logger } from '../../shared/logger.js';
import { promptConfirm, promptSelect } from '../../shared/prompts/index.js';
import {
  copySkills,
  copyCommands,
  copyAgents,
  copyInstructions,
} from './extras-copier.js';
import { checkExistingClaudeFiles } from './extras-checker.js';
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

  logger.warn('The following .claude files/folders already exist:');
  existingClaudeFiles.forEach((f) => logger.step(f));
  logger.blank();

  const response = await promptConfirm(
    'Overwrite existing .claude files?',
    false,
  );

  return response.confirmed;
}

/**
 * Skills 중복 처리: 여러 템플릿에 동일 스킬이 있을 때 사용자 선택
 */
async function handleDuplicateSkills(
  duplicateSkills: { skill: string; templates: string[] }[],
  templates: string[],
  targetDir: string,
): Promise<InstallResult> {
  logger.blank();
  logger.warn('The following skills are included in multiple templates:');
  duplicateSkills.forEach(({ skill, templates: skillTemplates }) => {
    logger.step(`${skill} (${skillTemplates.join(', ')})`);
  });
  logger.blank();

  const response = await promptSelect(
    "Which template's version should be used?",
    templates.map((t) => ({
      title: t,
      value: t,
    })),
  );

  if (response.value) {
    logger.info(`Reinstalling skills with ${response.value} template...`);
    const reinstallResult = await copySkills([response.value], targetDir);
    logger.success(
      `Skills: ${reinstallResult.files} files, ${reinstallResult.directories} directories`,
    );
    return reinstallResult;
  } else {
    logger.warn('No template selected. Using all templates.');
    return { files: 0, directories: 0 };
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

  // 중복 스킬이 있으면 사용자에게 선택 프롬프트 표시
  if (skillsResult.duplicateSkills && skillsResult.duplicateSkills.length > 0) {
    return await handleDuplicateSkills(
      skillsResult.duplicateSkills,
      templates,
      targetDir,
    );
  }

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
 * 중복 파일 처리 및 사용자 프롬프트 포함
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
  const existingClaudeFiles = await checkExistingClaudeFiles(targetDir);
  const shouldProceed = await handleDuplicateFiles(existingClaudeFiles, force);

  if (!shouldProceed) {
    logger.info('Skipping extras installation.');
    return { files: 0, directories: 0 };
  }

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
