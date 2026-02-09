import fs from 'fs-extra';
import path from 'path';
import { NON_UI_TEMPLATES } from '../../shared/constants.js';
import { copyRecursive } from '../../shared/filesystem/index.js';
import { getTemplatesDir } from '../templates/index.js';
import { loadAllSkillMetadata } from './skill-metadata.js';
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
 * Scripts 복사 (templates/.claude/scripts/ → 타겟/.claude/scripts/)
 * Scripts는 셸 스크립트 기반 구조
 */
export const copyScripts = createExtrasCopier('scripts');

/**
 * 템플릿 기반으로 설치할 스킬 목록 결정 (메타데이터 기반)
 * - 기본: 모든 스킬 설치
 * - 비-UI 템플릿: ui-only 스킬 제외
 * - 프레임워크 전용 스킬: framework 필드가 있으면 해당 템플릿에서만 설치
 */
const getSkillsToInstall = async (
  skillsSrc: string,
  templates: string[],
): Promise<string[]> => {
  const metadataMap = await loadAllSkillMetadata(skillsSrc);
  const isNonUITemplate = templates.some((t) => NON_UI_TEMPLATES.includes(t));

  const skillsToInstall: string[] = [];

  for (const [skillName, metadata] of metadataMap) {
    // 1. 비-UI 템플릿이면 ui-only 스킬 제외
    if (isNonUITemplate && metadata.uiOnly) {
      continue;
    }

    // 2. 프레임워크 전용 스킬 체크
    if (metadata.framework && !templates.includes(metadata.framework)) {
      continue;
    }

    skillsToInstall.push(skillName);
  }

  return skillsToInstall;
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

  // 1. 메타데이터 기반 스킬 필터링
  const skillsToInstall = await getSkillsToInstall(skillsSrc, templates);

  // 2. 스킬 복사
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
