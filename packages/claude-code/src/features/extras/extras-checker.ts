import fs from 'fs-extra';
import path from 'path';
import {
  FRAMEWORK_SPECIFIC_SKILLS_MAP,
  COMMON_SKILLS,
} from '../../shared/constants.js';
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
 */
export const checkAllExtrasExist = async (
  templates: string[],
): Promise<ExtrasExistenceCheck> => {
  const claudeDir = path.join(getTemplatesDir(), '.claude');
  const commandsSrc = path.join(claudeDir, 'commands');
  const agentsSrc = path.join(claudeDir, 'agents');
  const instructionsSrc = path.join(claudeDir, 'instructions');

  // 스킬: 공통 스킬이 있거나 선택된 템플릿에 프레임워크별 스킬이 있으면 true
  const hasFrameworkSkills = templates.some((template) => {
    const skills = FRAMEWORK_SPECIFIC_SKILLS_MAP[template];
    return skills && skills.length > 0;
  });
  const hasSkills = COMMON_SKILLS.length > 0 || hasFrameworkSkills;

  const hasCommands = await hasFiles(commandsSrc);
  const hasAgents = await hasFiles(agentsSrc);
  const hasInstructions = await hasFiles(instructionsSrc);

  return { hasSkills, hasCommands, hasAgents, hasInstructions };
};
