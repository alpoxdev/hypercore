import fs from 'fs-extra';
import path from 'path';
import { hasFiles } from '../../shared/filesystem/index.js';
import { getTemplatesDir } from '../templates/index.js';
import type { ExtrasExistenceCheck } from './types.js';

/**
 * 기존 .claude/skills, .claude/commands, .claude/agents, .claude/instructions 파일 확인
 */
export const checkExistingClaudeFiles = async (
  targetDir: string,
): Promise<string[]> => {
  const existingFiles: string[] = [];

  const skillsDir = path.join(targetDir, '.claude', 'skills');
  const commandsDir = path.join(targetDir, '.claude', 'commands');
  const agentsDir = path.join(targetDir, '.claude', 'agents');
  const instructionsDir = path.join(targetDir, '.claude', 'instructions');
  const scriptsDir = path.join(targetDir, '.claude', 'scripts');

  if (await fs.pathExists(skillsDir)) {
    existingFiles.push('.claude/skills/');
  }

  if (await fs.pathExists(commandsDir)) {
    existingFiles.push('.claude/commands/');
  }

  if (await fs.pathExists(agentsDir)) {
    existingFiles.push('.claude/agents/');
  }

  if (await fs.pathExists(instructionsDir)) {
    existingFiles.push('.claude/instructions/');
  }

  if (await fs.pathExists(scriptsDir)) {
    existingFiles.push('.claude/scripts/');
  }

  return existingFiles;
};

/**
 * Skills와 Commands가 존재하는지 확인
 */
export const checkSkillsAndCommandsExist = async (
  _templates: string[],
): Promise<{ hasSkills: boolean; hasCommands: boolean }> => {
  const claudeDir = path.join(getTemplatesDir(), '.claude');
  const skillsSrc = path.join(claudeDir, 'skills');
  const commandsSrc = path.join(claudeDir, 'commands');

  const hasSkills = await fs.pathExists(skillsSrc);
  const hasCommands = await fs.pathExists(commandsSrc);

  return { hasSkills, hasCommands };
};

/**
 * Skills, Commands, Agents, Instructions가 존재하는지 확인
 * 스킬은 동적으로 탐색하므로 폴더 존재 여부로 판단
 */
export const checkAllExtrasExist = async (
  _templates: string[],
): Promise<ExtrasExistenceCheck> => {
  const claudeDir = path.join(getTemplatesDir(), '.claude');
  const skillsSrc = path.join(claudeDir, 'skills');
  const commandsSrc = path.join(claudeDir, 'commands');
  const agentsSrc = path.join(claudeDir, 'agents');
  const instructionsSrc = path.join(claudeDir, 'instructions');
  const scriptsSrc = path.join(claudeDir, 'scripts');

  // 스킬: skills 폴더에 파일이 있으면 true (동적 탐색)
  const hasSkills = await hasFiles(skillsSrc);
  const hasCommands = await hasFiles(commandsSrc);
  const hasAgents = await hasFiles(agentsSrc);
  const hasInstructions = await hasFiles(instructionsSrc);
  const hasScripts = await hasFiles(scriptsSrc);

  return { hasSkills, hasCommands, hasAgents, hasInstructions, hasScripts };
};
