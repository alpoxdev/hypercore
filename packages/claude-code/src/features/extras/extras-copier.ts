import fs from 'fs-extra';
import path from 'path';
import { NON_UI_TEMPLATES } from '../../shared/constants.js';
import { getTemplatesDir } from '../templates/index.js';
import { loadAllSkillMetadata } from './skill-metadata.js';
import { installToAgents } from '../installer/index.js';
import type { AgentType, ScopeType, ExtrasType } from '../agents/types.js';
import type { CopyResult, SkillsCopyResult } from './types.js';

/**
 * Extras 복사를 위한 팩토리 함수 생성
 * Commands, Agents, Instructions는 동일한 구조를 공유하므로 팩토리 패턴 적용
 * 정규 위치(.agents/) + 에이전트별 심링크 방식 사용
 */
const createExtrasCopier = (extrasType: ExtrasType) => {
  return async (
    _templates: string[],
    targetDir: string,
    agents: AgentType[],
    scope: ScopeType,
  ): Promise<CopyResult> => {
    const counter = { files: 0, directories: 0 };
    const extrasSrc = path.join(getTemplatesDir(), '.claude', extrasType);

    if (!(await fs.pathExists(extrasSrc))) {
      return counter;
    }

    // extras 디렉토리 내 모든 항목 설치
    const items = await fs.readdir(extrasSrc);

    for (const item of items) {
      const itemPath = path.join(extrasSrc, item);
      const stat = await fs.stat(itemPath);

      // 디렉토리만 설치 (파일은 무시)
      if (!stat.isDirectory()) {
        continue;
      }

      // installToAgents 호출 (정규 위치 + 심링크)
      const result = await installToAgents(
        itemPath,
        agents,
        scope,
        extrasType,
        targetDir,
        item,
      );

      if (result.success) {
        counter.directories++;
      }
    }

    return counter;
  };
};

/**
 * Commands 복사
 */
export const copyCommands = createExtrasCopier('commands');

/**
 * Agents 복사
 */
export const copyAgents = createExtrasCopier('agents');

/**
 * Instructions 복사
 */
export const copyInstructions = createExtrasCopier('instructions');

/**
 * 템플릿 기반으로 설치할 스킬 목록 결정 (메타데이터 기반)
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
 * Skills 복사
 * 모든 스킬을 동적으로 탐색하고, 템플릿에 따라 필터링하여
 * 정규 위치(.agents/skills/) + 에이전트별 심링크 방식으로 설치
 */
export const copySkills = async (
  templates: string[],
  targetDir: string,
  agents: AgentType[],
  scope: ScopeType,
): Promise<SkillsCopyResult> => {
  const counter = { files: 0, directories: 0 };
  const skillsSrc = path.join(getTemplatesDir(), '.claude', 'skills');

  if (!(await fs.pathExists(skillsSrc))) {
    return counter;
  }

  // 1. 메타데이터 기반 스킬 필터링
  const skillsToInstall = await getSkillsToInstall(skillsSrc, templates);

  // 2. 스킬 설치 (정규 위치 + 심링크)
  for (const skill of skillsToInstall) {
    const skillPath = path.join(skillsSrc, skill);

    const result = await installToAgents(
      skillPath,
      agents,
      scope,
      'skills',
      targetDir,
      skill,
    );

    if (result.success) {
      counter.directories++;
    }
  }

  return counter;
};
