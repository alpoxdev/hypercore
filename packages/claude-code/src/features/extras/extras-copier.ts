import fs from 'fs-extra';
import path from 'path';
import {
  UI_SKILLS,
  NON_UI_TEMPLATES,
  FRAMEWORK_SPECIFIC_SKILLS,
} from '../../shared/constants.js';
import { copyRecursive } from '../../shared/filesystem/index.js';
import { getTemplatesDir } from '../templates/index.js';
import type { CopyResult, SkillsCopyResult, ExtrasType } from './types.js';

/**
 * Extras 복사를 위한 팩토리 함수 생성
 * Commands, Agents, Instructions는 동일한 구조를 공유하므로 팩토리 패턴 적용
 */
const createExtrasCopier = (extrasType: ExtrasType) => {
  return async (
    _templates: string[],
    targetDir: string,
  ): Promise<CopyResult> => {
    const counter = { files: 0, directories: 0 };
    const targetExtrasDir = path.join(targetDir, '.claude', extrasType);
    const extrasSrc = path.join(getTemplatesDir(), '.claude', extrasType);

    if (await fs.pathExists(extrasSrc)) {
      await fs.ensureDir(targetExtrasDir);
      await copyRecursive(extrasSrc, targetExtrasDir, counter);
    }

    return counter;
  };
};

/**
 * Commands 복사 (templates/.claude/commands/ → 타겟/.claude/commands/)
 * Commands는 .md 파일 기반 구조
 */
export const copyCommands = createExtrasCopier('commands');

/**
 * Agents 복사 (templates/.claude/agents/ → 타겟/.claude/agents/)
 * Agents는 .md 파일 기반 구조
 */
export const copyAgents = createExtrasCopier('agents');

/**
 * Instructions 복사 (templates/.claude/instructions/ → 타겟/.claude/instructions/)
 * Instructions는 .md 파일 기반 구조
 */
export const copyInstructions = createExtrasCopier('instructions');

/**
 * templates/.claude/skills/ 폴더에서 모든 스킬 목록 동적 탐색
 */
const getAllSkills = async (skillsSrc: string): Promise<string[]> => {
  const entries = await fs.readdir(skillsSrc, { withFileTypes: true });
  return entries
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name);
};

/**
 * 템플릿 기반으로 설치할 스킬 목록 결정
 * - 기본: 모든 스킬 설치
 * - 비-UI 템플릿: UI 스킬 제외
 * - 프레임워크 전용 스킬: 해당 템플릿에서만 설치
 */
const getSkillsToInstall = (
  allSkills: string[],
  templates: string[],
): string[] => {
  const isNonUITemplate = templates.some((t) => NON_UI_TEMPLATES.includes(t));

  return allSkills.filter((skill) => {
    // 1. 비-UI 템플릿이면 UI 스킬 제외
    if (isNonUITemplate && UI_SKILLS.includes(skill)) {
      return false;
    }

    // 2. 프레임워크 전용 스킬 체크
    for (const [framework, skills] of Object.entries(
      FRAMEWORK_SPECIFIC_SKILLS,
    )) {
      if (skills.includes(skill) && !templates.includes(framework)) {
        return false;
      }
    }

    return true;
  });
};

/**
 * Skills 복사 (templates/.claude/skills/ → 타겟/.claude/skills/)
 * 모든 스킬을 동적으로 탐색하고, 템플릿에 따라 필터링하여 복사
 */
export const copySkills = async (
  templates: string[],
  targetDir: string,
): Promise<SkillsCopyResult> => {
  const counter = { files: 0, directories: 0 };
  const targetSkillsDir = path.join(targetDir, '.claude', 'skills');
  const skillsSrc = path.join(getTemplatesDir(), '.claude', 'skills');

  if (!(await fs.pathExists(skillsSrc))) {
    return counter;
  }

  await fs.ensureDir(targetSkillsDir);

  // 1. 모든 스킬 동적 탐색
  const allSkills = await getAllSkills(skillsSrc);

  // 2. 템플릿 기반 필터링
  const skillsToInstall = getSkillsToInstall(allSkills, templates);

  // 3. 스킬 복사
  for (const skill of skillsToInstall) {
    const skillSrc = path.join(skillsSrc, skill);
    const skillDest = path.join(targetSkillsDir, skill);

    if (await fs.pathExists(skillDest)) {
      await fs.remove(skillDest);
    }
    await copyRecursive(skillSrc, skillDest, counter);
  }

  return counter;
};
