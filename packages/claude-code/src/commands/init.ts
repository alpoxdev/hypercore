import prompts from 'prompts';
import { logger } from '../utils/logger.js';
import {
  copyTemplate,
  checkExistingFiles,
  listAvailableTemplates,
  listAvailableSkills,
  copySkills,
  checkExistingSkills,
} from '../utils/copy.js';

interface InitOptions {
  templates?: string[];
  force?: boolean;
  cwd?: string;
  skills?: boolean;
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

  // 템플릿 선택 (다중 선택 지원)
  let templates = options.templates || [];

  if (templates.length === 0) {
    const response = await prompts({
      type: 'multiselect',
      name: 'templates',
      message: 'Select templates (space to select, enter to confirm):',
      choices: availableTemplates.map((t) => ({
        title: t,
        description: TEMPLATE_DESCRIPTIONS[t] || '',
        value: t,
      })),
      min: 1,
      hint: '- Space to select. Return to submit',
    });

    if (!response.templates || response.templates.length === 0) {
      logger.warn('Operation cancelled.');
      process.exit(0);
    }

    templates = response.templates;
  }

  // 템플릿 존재 확인
  const invalidTemplates = templates.filter(
    (t) => !availableTemplates.includes(t),
  );
  if (invalidTemplates.length > 0) {
    logger.error(`Templates not found: ${invalidTemplates.join(', ')}`);
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

  // 각 템플릿 설치
  let totalFiles = 0;
  let totalDirectories = 0;
  const allSkills: string[] = [];

  for (const template of templates) {
    logger.blank();
    logger.info(`Installing ${template} template...`);
    logger.step(`Target: ${targetDir}`);
    logger.blank();

    try {
      const result = await copyTemplate(template, targetDir);
      totalFiles += result.files;
      totalDirectories += result.directories;

      logger.success(`${template}: ${result.files} files copied`);

      // Skills 수집
      const availableSkills = await listAvailableSkills(template);
      if (availableSkills.length > 0) {
        for (const skill of availableSkills) {
          if (!allSkills.includes(skill)) {
            allSkills.push(skill);
          }
        }
      }
    } catch (error) {
      logger.error(
        `Failed to install ${template}: ${error instanceof Error ? error.message : 'Unknown error'}`,
      );
      process.exit(1);
    }
  }

  logger.blank();
  logger.success(`Total: ${totalFiles} files, ${totalDirectories} directories`);

  // Skills 설치 (모든 템플릿의 skills 통합)
  if (allSkills.length > 0) {
    let installSkills = options.skills;

    if (installSkills === undefined) {
      logger.blank();
      const response = await prompts({
        type: 'confirm',
        name: 'installSkills',
        message: `Install Claude Code skills? (${allSkills.join(', ')})`,
        initial: true,
      });

      installSkills = response.installSkills;
    }

    if (installSkills) {
      // 기존 skills 확인
      const existingSkills = await checkExistingSkills(targetDir, allSkills);

      if (existingSkills.length > 0 && !options.force) {
        logger.warn('The following skills already exist:');
        existingSkills.forEach((s) => logger.step(s));
        logger.blank();

        const response = await prompts({
          type: 'confirm',
          name: 'overwrite',
          message: 'Overwrite existing skills?',
          initial: false,
        });

        if (!response.overwrite) {
          logger.info('Skipping skills installation.');
        } else {
          await installAllSkills(templates, targetDir);
        }
      } else {
        await installAllSkills(templates, targetDir);
      }
      logger.blank();
    }
  }

  // 완료 메시지
  logger.success('Claude Code documentation installed!');
  logger.blank();
  logger.info('Installed templates:');
  templates.forEach((t) => logger.step(t));
  logger.blank();
  logger.info('Next steps:');
  logger.step('Read CLAUDE.md for project guidelines');
  logger.step('Explore docs/ for detailed documentation');
  logger.blank();
};

const installAllSkills = async (
  templates: string[],
  targetDir: string,
): Promise<void> => {
  const installedSkills: string[] = [];

  for (const template of templates) {
    const skillsResult = await copySkills(template, targetDir);
    for (const skill of skillsResult.skills) {
      if (!installedSkills.includes(skill)) {
        installedSkills.push(skill);
      }
    }
  }

  if (installedSkills.length > 0) {
    logger.success(`Skills installed: ${installedSkills.join(', ')}`);
    logger.step(`Location: .claude/skills/`);
  }
};
