import fs from 'fs-extra';
import path from 'path';
import {
  FRAMEWORK_SPECIFIC_SKILLS_MAP,
  COMMON_SKILLS,
} from '../../shared/constants.js';
import { copyRecursive } from '../../shared/filesystem/index.js';
import { getTemplatesDir } from '../templates/index.js';
import type {
  CopyResult,
  SkillsCopyResult,
  DuplicateSkill,
  ExtrasType,
} from './types.js';

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
 * Skills 복사 (templates/.claude/skills/ → 타겟/.claude/skills/)
 * 공통 스킬 + 선택된 템플릿에 해당하는 프레임워크별 스킬 복사
 * 중복 스킬 추적 기능 포함
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
  const duplicateSkills: DuplicateSkill[] = [];
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
