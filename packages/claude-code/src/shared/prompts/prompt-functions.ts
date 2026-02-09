/**
 * 고수준 프롬프트 비즈니스 로직 함수
 * init 명령어에서 사용하는 프롬프트 로직
 */

import { logger } from '../logger.js';
import {
  promptConfirm,
  promptMultiselect,
  promptSelect,
} from './prompt-helpers.js';
import type {
  TemplateSelectionOptions,
  TemplateSelectionResult,
  OverwritePromptOptions,
  ExtrasSelectionOptions,
  ExtrasSelectionResult,
  ScopeSelectionOptions,
  ScopeSelectionResult,
} from './types.js';

/**
 * 템플릿 선택 프롬프트
 * CLI 인자로 제공되지 않았을 때 사용자에게 선택 요청
 *
 * @param options 템플릿 선택 옵션
 * @returns 선택된 템플릿 목록
 * @throws process.exit(0) - 사용자가 선택을 취소한 경우
 * @throws process.exit(1) - 유효하지 않은 템플릿이 포함된 경우
 */
export async function promptTemplateSelection(
  options: TemplateSelectionOptions,
): Promise<TemplateSelectionResult> {
  const { providedTemplates, availableTemplates, templateDescriptions } =
    options;
  let templates = providedTemplates || [];

  // CLI 인자로 템플릿이 제공되지 않은 경우 프롬프트 표시
  if (templates.length === 0) {
    const response = await promptMultiselect(
      'Select templates (space to select, enter to confirm):',
      availableTemplates.map((t) => ({
        title: t,
        description: templateDescriptions[t] || '',
        value: t,
      })),
      {
        min: 0,
        hint: '- Space to select, Enter to confirm (or skip to install extras only)',
      },
    );

    templates = response.values;
  }

  // 제공된 템플릿의 유효성 검증
  const invalidTemplates = templates.filter(
    (t) => !availableTemplates.includes(t),
  );
  if (invalidTemplates.length > 0) {
    logger.error(`Templates not found: ${invalidTemplates.join(', ')}`);
    logger.info(`Available templates: ${availableTemplates.join(', ')}`);
    process.exit(1);
  }

  return { templates };
}

/**
 * 기존 파일 덮어쓰기 확인 프롬프트
 * force 옵션이 활성화되지 않았고 기존 파일이 있을 때 사용자에게 확인 요청
 *
 * @param options 덮어쓰기 확인 옵션
 * @throws process.exit(0) - 사용자가 덮어쓰기를 거부한 경우
 */
export async function promptOverwrite(
  options: OverwritePromptOptions,
): Promise<void> {
  const { existingFiles, force } = options;

  if (existingFiles.length > 0 && !force) {
    logger.warn('The following files/folders already exist:');
    existingFiles.forEach((f) => logger.step(f));
    logger.blank();

    const result = await promptConfirm('Overwrite existing files?', false);

    if (!result.confirmed) {
      logger.info('Operation cancelled.');
      process.exit(0);
    }
  }
}

/**
 * Extras (skills, commands, agents, instructions) 설치 여부 프롬프트
 * CLI 옵션으로 제공되지 않았을 때 사용자에게 선택 요청
 *
 * @param options Extras 선택 옵션
 * @returns 각 extras의 설치 여부 플래그
 */
export async function promptExtrasSelection(
  options: ExtrasSelectionOptions,
): Promise<ExtrasSelectionResult> {
  const {
    skills,
    commands,
    agents,
    instructions,
    hasSkills,
    hasCommands,
    hasAgents,
    hasInstructions,
  } = options;

  let installSkills = skills ?? false;
  let installCommands = commands ?? false;
  const installAgents = agents ?? hasAgents;
  const installInstructions = instructions ?? hasInstructions;

  // CLI 옵션이 하나도 제공되지 않은 경우 프롬프트 표시
  const noOptionsProvided =
    skills === undefined &&
    commands === undefined &&
    agents === undefined &&
    instructions === undefined;

  if (
    noOptionsProvided &&
    (hasSkills || hasCommands || hasAgents || hasInstructions)
  ) {
    logger.blank();

    // Skills 설치 여부 확인
    if (hasSkills) {
      const result = await promptConfirm(
        'Install skills to .claude/skills/?',
        false,
      );
      installSkills = result.confirmed;
    }

    // Commands 설치 여부 확인
    if (hasCommands) {
      const result = await promptConfirm(
        'Install commands to .claude/commands/?',
        false,
      );
      installCommands = result.confirmed;
    }
  }

  return {
    installSkills,
    installCommands,
    installAgents,
    installInstructions,
  };
}

/**
 * Scope 선택 프롬프트
 * CLI 인자로 제공되지 않았을 때 사용자에게 Project/User 선택 요청
 */
export async function promptScopeSelection(
  options: ScopeSelectionOptions,
): Promise<ScopeSelectionResult> {
  const { providedScope } = options;

  // CLI로 scope이 제공된 경우 검증 후 반환
  if (providedScope) {
    if (providedScope !== 'project' && providedScope !== 'user') {
      logger.error(
        `Invalid scope: "${providedScope}". Use "project" or "user".`,
      );
      process.exit(1);
    }
    return { scope: providedScope };
  }

  // 인터랙티브 프롬프트
  const response = await promptSelect<'project' | 'user'>(
    'Select installation scope:',
    [
      {
        title: 'Project',
        description: 'Install to current project (.claude/)',
        value: 'project',
      },
      {
        title: 'User',
        description: 'Install to user home (~/.claude/)',
        value: 'user',
      },
    ],
  );

  if (!response.value) {
    logger.info('Operation cancelled.');
    process.exit(0);
  }

  return { scope: response.value };
}
