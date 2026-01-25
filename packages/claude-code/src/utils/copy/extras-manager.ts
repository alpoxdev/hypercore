import fs from 'fs-extra';
import path from 'path';
import { FRAMEWORK_SPECIFIC_SKILLS_MAP, COMMON_SKILLS } from './constants.js';
import { copyRecursive, hasFiles } from './copy-utils.js';
import { getTemplatesDir } from './template-manager.js';

/**
 * Skills 복사 (templates/.claude/skills/ → 타겟/.claude/skills/)
 * 공통 스킬 + 선택된 템플릿에 해당하는 프레임워크별 스킬 복사
 */
export const copySkills = async (
  templates: string[],
  targetDir: string,
): Promise<{
  files: number;
  directories: number;
  duplicateSkills?: { skill: string; templates: string[] }[];
}> => {
  const counter = { files: 0, directories: 0 };
  const targetSkillsDir = path.join(targetDir, '.claude', 'skills');
  const skillsSrc = path.join(getTemplatesDir(), '.claude', 'skills');

  if (!(await fs.pathExists(skillsSrc))) {
    return counter;
  }

  await fs.ensureDir(targetSkillsDir);

  // 복사할 스킬 수집 및 중복 추적
  const skillsToCopy = new Set<string>();
  const skillTemplateMap = new Map<string, Set<string>>(); // 스킬명 → 템플릿 Set

  // 1. 공통 스킬 추가 (항상 설치, 중복 추적 제외)
  COMMON_SKILLS.forEach((skill) => skillsToCopy.add(skill));

  // 2. 선택된 템플릿에 해당하는 프레임워크별 스킬 추가 및 중복 추적
  for (const template of templates) {
    const skills = FRAMEWORK_SPECIFIC_SKILLS_MAP[template] || [];
    skills.forEach((skill) => {
      skillsToCopy.add(skill);

      // 중복 추적: 스킬이 어느 템플릿에서 왔는지 기록
      if (!skillTemplateMap.has(skill)) {
        skillTemplateMap.set(skill, new Set());
      }
      skillTemplateMap.get(skill)!.add(template);
    });
  }

  // 수집된 스킬 복사 (기존 스킬 폴더는 삭제 후 복사)
  for (const skill of skillsToCopy) {
    const skillSrc = path.join(skillsSrc, skill);
    const skillDest = path.join(targetSkillsDir, skill);

    if (await fs.pathExists(skillSrc)) {
      // 기존 스킬 폴더 삭제
      if (await fs.pathExists(skillDest)) {
        await fs.remove(skillDest);
      }
      await copyRecursive(skillSrc, skillDest, counter);
    }
  }

  // 중복 스킬 목록 생성 (2개 이상의 템플릿에서 사용되는 스킬만)
  const duplicateSkills: { skill: string; templates: string[] }[] = [];
  for (const [skill, templateSet] of skillTemplateMap.entries()) {
    if (templateSet.size > 1) {
      duplicateSkills.push({
        skill,
        templates: Array.from(templateSet).sort(),
      });
    }
  }

  return {
    ...counter,
    ...(duplicateSkills.length > 0 && { duplicateSkills }),
  };
};

/**
 * Commands 복사 (templates/.claude/commands/ → 타겟/.claude/commands/)
 * Commands는 .md 파일 기반 구조
 */
export const copyCommands = async (
  _templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };
  const targetCommandsDir = path.join(targetDir, '.claude', 'commands');
  const commandsSrc = path.join(getTemplatesDir(), '.claude', 'commands');

  if (await fs.pathExists(commandsSrc)) {
    await fs.ensureDir(targetCommandsDir);
    await copyRecursive(commandsSrc, targetCommandsDir, counter);
  }

  return counter;
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
 * Agents 복사 (templates/.claude/agents/ → 타겟/.claude/agents/)
 * Agents는 .md 파일 기반 구조
 */
export const copyAgents = async (
  _templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };
  const targetAgentsDir = path.join(targetDir, '.claude', 'agents');
  const agentsSrc = path.join(getTemplatesDir(), '.claude', 'agents');

  if (await fs.pathExists(agentsSrc)) {
    await fs.ensureDir(targetAgentsDir);
    await copyRecursive(agentsSrc, targetAgentsDir, counter);
  }

  return counter;
};

/**
 * Instructions 복사 (templates/.claude/instructions/ → 타겟/.claude/instructions/)
 * Instructions는 .md 파일 기반 구조
 */
export const copyInstructions = async (
  _templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };
  const targetInstructionsDir = path.join(targetDir, '.claude', 'instructions');
  const instructionsSrc = path.join(
    getTemplatesDir(),
    '.claude',
    'instructions',
  );

  if (await fs.pathExists(instructionsSrc)) {
    await fs.ensureDir(targetInstructionsDir);
    await copyRecursive(instructionsSrc, targetInstructionsDir, counter);
  }

  return counter;
};

/**
 * Skills, Commands, Agents, Instructions가 존재하는지 확인
 */
export const checkAllExtrasExist = async (
  templates: string[],
): Promise<{
  hasSkills: boolean;
  hasCommands: boolean;
  hasAgents: boolean;
  hasInstructions: boolean;
}> => {
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
