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
  AgentSelectionOptions,
  AgentSelectionResult,
  ScopeSelectionOptions,
  ScopeSelectionResult,
} from './types.js';

/**
 * 템플릿 선택 프롬프트
 * CLI 인자로 제공되지 않았을 때 사용자에게 선택 요청
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
        min: 1,
        hint: '- Space to select. Return to submit',
      },
    );

    if (response.values.length === 0) {
      logger.warn('Operation cancelled.');
      process.exit(0);
    }

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
      const result = await promptConfirm('Install skills?', false);
      installSkills = result.confirmed;
    }

    // Commands 설치 여부 확인
    if (hasCommands) {
      const result = await promptConfirm('Install commands?', false);
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
 * 에이전트 선택 프롬프트
 * 자동 감지된 에이전트 목록에서 멀티셀렉트
 */
export async function promptAgentSelection(
  options: AgentSelectionOptions,
): Promise<AgentSelectionResult> {
  const { installedAgents } = options;

  // 설치된 에이전트가 없으면 기본값으로 claude-code 선택
  if (installedAgents.length === 0) {
    logger.warn('No agents detected. Defaulting to claude-code.');
    return { agents: ['claude-code'] };
  }

  // 설치된 에이전트가 1개면 자동 선택
  if (installedAgents.length === 1) {
    logger.info(`Auto-selected agent: ${installedAgents[0]}`);
    return { agents: installedAgents };
  }

  // 멀티셀렉트 프롬프트
  const response = await promptMultiselect(
    'Select target agents (space to select, enter to confirm):',
    installedAgents.map((agent) => ({
      title: agent,
      value: agent,
    })),
    {
      min: 1,
      hint: '- Space to select. Return to submit',
    },
  );

  if (response.values.length === 0) {
    logger.warn('No agents selected. Defaulting to claude-code.');
    return { agents: ['claude-code'] };
  }

  return { agents: response.values };
}

/**
 * Scope 선택 프롬프트
 * Project 또는 Global 선택
 */
export async function promptScopeSelection(
  _options?: ScopeSelectionOptions,
): Promise<ScopeSelectionResult> {
  const response = await promptSelect('Select installation scope:', [
    {
      title: 'Project (current directory)',
      description: 'Install to current project directory',
      value: 'project' as const,
    },
    {
      title: 'Global (home directory)',
      description: 'Install to user home directory',
      value: 'global' as const,
    },
  ]);

  return { scope: response.value || 'project' };
}
