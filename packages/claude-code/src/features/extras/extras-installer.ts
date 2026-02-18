import fs from 'fs-extra';
import path from 'path';
import { logger } from '../../shared/logger.js';
import {
  copySkills,
  copyCommands,
  copyAgents,
  copyInstructions,
  copyScripts,
  copyHooks,
} from './extras-copier.js';
import { checkExistingClaudeFiles } from './extras-checker.js';
import type { InstallResult, ExtrasFlags } from './types.js';

/**
 * SessionStart 훅 정의
 * CLAUDE_SCRIPTS_ROOT 환경변수를 설정하는 훅
 */
interface HookConfig {
  hooks?: {
    SessionStart?: Array<{
      type: 'command';
      command: string;
    }>;
  };
}

/**
 * settings.local.json에 SessionStart 훅 등록
 * hooks 설치 후 자동으로 훅을 settings.local.json에 등록
 */
async function registerSessionStartHook(targetDir: string): Promise<void> {
  const settingsPath = path.join(targetDir, '.claude', 'settings.local.json');
  const hookCommand = '.claude/hooks/session-env-setup.sh';

  let config: HookConfig = {};

  // 기존 설정 읽기
  if (await fs.pathExists(settingsPath)) {
    try {
      config = await fs.readJson(settingsPath);
    } catch {
      // 파일이 손상된 경우 빈 객체로 시작
      config = {};
    }
  }

  // hooks.SessionStart 배열 확보
  if (!config.hooks) {
    config.hooks = {};
  }
  if (!config.hooks.SessionStart) {
    config.hooks.SessionStart = [];
  }

  // 이미 등록되어 있는지 확인
  const alreadyRegistered = config.hooks.SessionStart.some(
    (hook) => hook.type === 'command' && hook.command === hookCommand,
  );

  if (!alreadyRegistered) {
    config.hooks.SessionStart.push({
      type: 'command',
      command: hookCommand,
    });

    // 설정 저장
    await fs.ensureDir(path.dirname(settingsPath));
    await fs.writeJson(settingsPath, config, { spaces: 2 });
    logger.step('Registered SessionStart hook for CLAUDE_SCRIPTS_ROOT');
  }
}

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
 * Hooks 설치
 */
async function installHooksIfNeeded(
  templates: string[],
  targetDir: string,
  shouldInstall: boolean,
  hasHooks: boolean,
): Promise<InstallResult> {
  if (!shouldInstall) {
    return { files: 0, directories: 0 };
  }

  if (!hasHooks) {
    logger.warn('No hooks found in selected templates.');
    return { files: 0, directories: 0 };
  }

  logger.blank();
  logger.info('Installing hooks...');
  const hooksResult = await copyHooks(templates, targetDir);
  logger.success(
    `Hooks: ${hooksResult.files} files, ${hooksResult.directories} directories`,
  );
  return hooksResult;
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
 * Extras 설치 (Skills, Commands, Agents, Instructions, Scripts, Hooks)
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
    hasHooks: boolean;
  },
): Promise<InstallResult> {
  const {
    installSkills,
    installCommands,
    installAgents,
    installInstructions,
    installScripts,
    installHooks,
  } = flags;

  // 설치할 항목이 없으면 조기 종료
  if (
    !installSkills &&
    !installCommands &&
    !installAgents &&
    !installInstructions &&
    !installScripts &&
    !installHooks
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

  const hooksResult = await installHooksIfNeeded(
    templates,
    targetDir,
    installHooks,
    availability.hasHooks,
  );

  // hooks 설치 시 SessionStart 훅 자동 등록
  if (installHooks && hooksResult.files > 0) {
    await registerSessionStartHook(targetDir);
  }

  // 전체 결과 집계
  const totalFiles =
    skillsResult.files +
    commandsResult.files +
    agentsResult.files +
    instructionsResult.files +
    scriptsResult.files +
    hooksResult.files;

  const totalDirectories =
    skillsResult.directories +
    commandsResult.directories +
    agentsResult.directories +
    instructionsResult.directories +
    scriptsResult.directories +
    hooksResult.directories;

  return { files: totalFiles, directories: totalDirectories };
}
