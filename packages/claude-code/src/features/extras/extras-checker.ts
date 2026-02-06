import fs from 'fs-extra';
import path from 'path';
import { hasFiles } from '../../shared/filesystem/index.js';
import { getTemplatesDir } from '../templates/index.js';
import { getAllAgents, resolveExtrasDir } from '../agents/index.js';
import { CANONICAL_DIR } from '../../shared/constants.js';
import type { ExtrasExistenceCheck, ExtrasType } from './types.js';

// 체크 대상 extras 타입 목록
const EXTRAS_TYPES: ExtrasType[] = [
  'skills',
  'commands',
  'agents',
  'instructions',
];

/**
 * 기존 extras 파일 확인 (모든 에이전트 경로 + canonical 경로)
 */
export const checkExistingExtrasFiles = async (
  targetDir: string,
): Promise<string[]> => {
  const existingFiles: string[] = [];
  const agents = getAllAgents();

  // canonical 경로 (.agents/) 체크
  const canonicalDir = path.join(targetDir, CANONICAL_DIR);
  if (await fs.pathExists(canonicalDir)) {
    existingFiles.push(`${CANONICAL_DIR}/`);
  }

  // 모든 에이전트 × 모든 extras 타입 체크
  for (const agent of agents) {
    for (const extrasType of EXTRAS_TYPES) {
      const dir = resolveExtrasDir(agent, 'project', extrasType, targetDir);
      if (!dir) continue;

      if (await fs.pathExists(dir)) {
        const relativePath = path.relative(targetDir, dir);
        const entry = `${relativePath}/`;
        if (!existingFiles.includes(entry)) {
          existingFiles.push(entry);
        }
      }
    }
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

  // 스킬: skills 폴더에 파일이 있으면 true (동적 탐색)
  const hasSkills = await hasFiles(skillsSrc);
  const hasCommands = await hasFiles(commandsSrc);
  const hasAgents = await hasFiles(agentsSrc);
  const hasInstructions = await hasFiles(instructionsSrc);

  return { hasSkills, hasCommands, hasAgents, hasInstructions };
};
