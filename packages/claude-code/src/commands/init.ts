import prompts from 'prompts';
import path from 'path';
import { logger } from '../utils/logger.js';
import {
  copyTemplate,
  checkExistingFiles,
  listAvailableTemplates,
} from '../utils/copy.js';

interface InitOptions {
  template?: string;
  force?: boolean;
  cwd?: string;
}

const TEMPLATE_DESCRIPTIONS: Record<string, string> = {
  'tanstack-start': 'TanStack Start + React 풀스택 프로젝트',
  hono: 'Hono 서버 프레임워크 프로젝트',
};

export const init = async (options: InitOptions): Promise<void> => {
  const targetDir = options.cwd || process.cwd();

  // 사용 가능한 템플릿 확인
  const availableTemplates = await listAvailableTemplates();

  if (availableTemplates.length === 0) {
    logger.error('No templates found. Package may be corrupted.');
    process.exit(1);
  }

  // 템플릿 선택
  let template = options.template;

  if (!template) {
    const response = await prompts({
      type: 'select',
      name: 'template',
      message: 'Select a template:',
      choices: availableTemplates.map((t) => ({
        title: t,
        description: TEMPLATE_DESCRIPTIONS[t] || '',
        value: t,
      })),
    });

    if (!response.template) {
      logger.warn('Operation cancelled.');
      process.exit(0);
    }

    template = response.template;
  }

  // 템플릿 존재 확인
  if (!availableTemplates.includes(template)) {
    logger.error(`Template "${template}" not found.`);
    logger.info(`Available templates: ${availableTemplates.join(', ')}`);
    process.exit(1);
  }

  // 기존 파일 확인
  const existingFiles = await checkExistingFiles(targetDir);

  if (existingFiles.length > 0 && !options.force) {
    logger.warn('The following files/folders already exist:');
    existingFiles.forEach((f) => logger.step(f));
    logger.blank();

    const response = await prompts({
      type: 'confirm',
      name: 'overwrite',
      message: 'Overwrite existing files?',
      initial: false,
    });

    if (!response.overwrite) {
      logger.info('Operation cancelled.');
      process.exit(0);
    }
  }

  // 템플릿 복사
  logger.blank();
  logger.info(`Installing ${template} template...`);
  logger.step(`Target: ${targetDir}`);
  logger.blank();

  try {
    const result = await copyTemplate(template, targetDir);

    logger.success(`${result.files} files copied`);
    logger.success(`${result.directories} directories created`);
    logger.blank();

    // 완료 메시지
    logger.success('Claude Code documentation installed!');
    logger.blank();
    logger.info('Next steps:');
    logger.step('Read CLAUDE.md for project guidelines');
    logger.step('Explore docs/ for detailed documentation');
    logger.blank();
  } catch (error) {
    logger.error(
      `Failed to install template: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );
    process.exit(1);
  }
};
