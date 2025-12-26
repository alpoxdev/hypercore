import prompts from 'prompts';
import { logger } from '../utils/logger.js';
import {
  copySingleTemplate,
  copyMultipleTemplates,
  checkExistingFiles,
  listAvailableTemplates,
  copySkills,
  copyCommands,
  checkSkillsAndCommandsExist,
  checkExistingClaudeFiles,
} from '../utils/copy.js';

interface InitOptions {
  templates?: string[];
  force?: boolean;
  cwd?: string;
  skills?: boolean;
  commands?: boolean;
}

const TEMPLATE_DESCRIPTIONS: Record<string, string> = {
  'tanstack-start': 'TanStack Start + React 풀스택 프로젝트',
  hono: 'Hono 서버 프레임워크 프로젝트',
  npx: 'NPX CLI 도구 프로젝트',
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

  // 템플릿 설치 (단일 vs 다중 분기)
  const isSingleTemplate = templates.length === 1;
  let totalFiles = 0;
  let totalDirectories = 0;

  logger.blank();

  try {
    if (isSingleTemplate) {
      // 단일 템플릿: CLAUDE.md → 루트, docs/ → 루트/docs/
      const template = templates[0];
      logger.info(`Installing ${template} template...`);
      logger.step(`Target: ${targetDir}`);
      logger.blank();

      const result = await copySingleTemplate(template, targetDir);
      totalFiles = result.files;
      totalDirectories = result.directories;

      logger.success(`${template}: ${result.files} files copied`);
    } else {
      // 다중 템플릿: 각 템플릿 폴더 → docs/템플릿명/ + 인덱스 CLAUDE.md
      logger.info(`Installing ${templates.length} templates...`);
      logger.step(`Target: ${targetDir}/docs/`);
      logger.blank();

      const result = await copyMultipleTemplates(templates, targetDir);
      totalFiles = result.files;
      totalDirectories = result.directories;

      for (const template of templates) {
        logger.success(`${template}: installed to docs/${template}/`);
      }
    }
  } catch (error) {
    logger.error(
      `Failed to install templates: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );
    process.exit(1);
  }

  logger.blank();
  logger.success(`Total: ${totalFiles} files, ${totalDirectories} directories`);

  // Skills/Commands 설치
  const { hasSkills, hasCommands } =
    await checkSkillsAndCommandsExist(templates);

  // CLI 옵션이 없으면 대화형으로 물어보기
  let installSkills = options.skills ?? false;
  let installCommands = options.commands ?? false;

  if (!options.skills && !options.commands && (hasSkills || hasCommands)) {
    logger.blank();

    if (hasSkills) {
      const skillsResponse = await prompts({
        type: 'confirm',
        name: 'install',
        message: 'Install skills to .claude/skills/?',
        initial: true,
      });
      installSkills = skillsResponse.install ?? false;
    }

    if (hasCommands) {
      const commandsResponse = await prompts({
        type: 'confirm',
        name: 'install',
        message: 'Install commands to .claude/commands/?',
        initial: true,
      });
      installCommands = commandsResponse.install ?? false;
    }
  }

  if (installSkills || installCommands) {
    // 기존 .claude 파일 확인
    const existingClaudeFiles = await checkExistingClaudeFiles(targetDir);
    if (existingClaudeFiles.length > 0 && !options.force) {
      logger.warn('The following .claude files/folders already exist:');
      existingClaudeFiles.forEach((f) => logger.step(f));
      logger.blank();

      const response = await prompts({
        type: 'confirm',
        name: 'overwrite',
        message: 'Overwrite existing .claude files?',
        initial: false,
      });

      if (!response.overwrite) {
        logger.info('Skipping skills/commands installation.');
        installSkills = false;
        installCommands = false;
      }
    }

    if (installSkills && hasSkills) {
      logger.blank();
      logger.info('Installing skills...');
      const skillsResult = await copySkills(templates, targetDir);
      totalFiles += skillsResult.files;
      totalDirectories += skillsResult.directories;
      logger.success(
        `Skills: ${skillsResult.files} files, ${skillsResult.directories} directories`,
      );
    } else if (installSkills && !hasSkills) {
      logger.warn('No skills found in selected templates.');
    }

    if (installCommands && hasCommands) {
      logger.blank();
      logger.info('Installing commands...');
      const commandsResult = await copyCommands(templates, targetDir);
      totalFiles += commandsResult.files;
      totalDirectories += commandsResult.directories;
      logger.success(
        `Commands: ${commandsResult.files} files, ${commandsResult.directories} directories`,
      );
    } else if (installCommands && !hasCommands) {
      logger.warn('No commands found in selected templates.');
    }
  }

  // 완료 메시지
  logger.blank();
  logger.success('Claude Code documentation installed!');
  logger.blank();
  logger.info('Installed templates:');
  templates.forEach((t) => logger.step(t));

  if (installSkills || installCommands) {
    logger.blank();
    logger.info('Installed extras:');
    if (installSkills) {
      logger.step('Skills → .claude/skills/');
    }
    if (installCommands) {
      logger.step('Commands → .claude/commands/');
    }
  }

  logger.blank();
  logger.info('Next steps:');
  logger.step('Read CLAUDE.md for project guidelines');
  logger.step('Explore docs/ for detailed documentation');
  logger.blank();
};
