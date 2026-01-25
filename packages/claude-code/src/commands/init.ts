import prompts from 'prompts';
import fs from 'fs-extra';
import path from 'path';
import { logger } from '../utils/logger.js';
import {
  copySingleTemplate,
  copyMultipleTemplates,
  checkExistingFiles,
  listAvailableTemplates,
  copySkills,
  copyCommands,
  copyAgents,
  copyInstructions,
  checkAllExtrasExist,
  checkExistingClaudeFiles,
} from '../utils/copy/index.js';

interface InitOptions {
  templates?: string[];
  force?: boolean;
  cwd?: string;
  skills?: boolean;
  commands?: boolean;
  agents?: boolean;
  instructions?: boolean;
}

const TEMPLATE_DESCRIPTIONS: Record<string, string> = {
  'tanstack-start': 'TanStack Start + React 풀스택 프로젝트',
  hono: 'Hono 서버 프레임워크 프로젝트',
  npx: 'NPX CLI 도구 프로젝트',
};

// skills/commands에서 생성하는 .claude/ 하위 폴더 목록
const CLAUDE_GENERATED_FOLDERS = [
  '.claude/plans/',
  '.claude/ralph/',
  '.claude/refactor/',
];

/**
 * .gitignore 파일에 Claude Code 생성 폴더를 추가
 * .gitignore가 없으면 생성, 있으면 기존 내용에 추가 (중복 방지)
 */
async function ensureGitignore(targetDir: string): Promise<void> {
  const gitignorePath = path.join(targetDir, '.gitignore');
  const sectionComment = '# Claude Code generated files';

  let content = '';
  let hasGitignore = false;

  // 기존 .gitignore 읽기
  try {
    content = await fs.readFile(gitignorePath, 'utf-8');
    hasGitignore = true;
  } catch (error) {
    // .gitignore 없음 → 새로 생성
    content = '';
  }

  // 이미 Claude Code 섹션이 있는지 확인
  if (content.includes(sectionComment)) {
    logger.info('.gitignore already contains Claude Code section');
    return;
  }

  // 추가할 패턴 목록 (중복 체크)
  const linesToAdd: string[] = [];
  const existingLines = content.split('\n').map((line) => line.trim());

  for (const folder of CLAUDE_GENERATED_FOLDERS) {
    if (!existingLines.includes(folder)) {
      linesToAdd.push(folder);
    }
  }

  if (linesToAdd.length === 0) {
    logger.info('.gitignore already contains all Claude Code patterns');
    return;
  }

  // 내용 추가
  let newContent = content;
  if (newContent && !newContent.endsWith('\n')) {
    newContent += '\n';
  }
  if (newContent) {
    newContent += '\n';
  }
  newContent += sectionComment + '\n';
  newContent += linesToAdd.join('\n') + '\n';

  // 파일 쓰기
  await fs.writeFile(gitignorePath, newContent, 'utf-8');

  if (hasGitignore) {
    logger.success(`.gitignore updated with ${linesToAdd.length} patterns`);
  } else {
    logger.success(`.gitignore created with ${linesToAdd.length} patterns`);
  }
}

export const init = async (options: InitOptions): Promise<void> => {
  const targetDir = options.cwd || process.cwd();

  // cwd 옵션 검증
  try {
    const stat = await fs.stat(targetDir);
    if (!stat.isDirectory()) {
      logger.error(`Target is not a directory: ${targetDir}`);
      process.exit(1);
    }
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
      logger.error(`Target directory does not exist: ${targetDir}`);
    } else {
      logger.error(`Cannot access target directory: ${targetDir}`);
    }
    process.exit(1);
  }

  // 쓰기 권한 확인
  try {
    await fs.access(targetDir, fs.constants.W_OK);
  } catch {
    logger.error(`No write permission for: ${targetDir}`);
    process.exit(1);
  }

  const availableTemplates = await listAvailableTemplates();

  if (availableTemplates.length === 0) {
    logger.error('No templates found. Package may be corrupted.');
    process.exit(1);
  }

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

  const invalidTemplates = templates.filter(
    (t) => !availableTemplates.includes(t),
  );
  if (invalidTemplates.length > 0) {
    logger.error(`Templates not found: ${invalidTemplates.join(', ')}`);
    logger.info(`Available templates: ${availableTemplates.join(', ')}`);
    process.exit(1);
  }

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

  const isSingleTemplate = templates.length === 1;
  let totalFiles = 0;
  let totalDirectories = 0;

  logger.blank();

  try {
    if (isSingleTemplate) {
      const template = templates[0];
      logger.info(`Installing ${template} template...`);
      logger.step(`Target: ${targetDir}`);
      logger.blank();

      const result = await copySingleTemplate(template, targetDir);
      totalFiles = result.files;
      totalDirectories = result.directories;

      logger.success(`${template}: ${result.files} files copied`);
    } else {
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

  const { hasSkills, hasCommands, hasAgents, hasInstructions } =
    await checkAllExtrasExist(templates);

  let installSkills = options.skills ?? false;
  let installCommands = options.commands ?? false;
  // agents와 instructions는 항상 필수 설치
  let installAgents = hasAgents;
  let installInstructions = hasInstructions;

  const noOptionsProvided =
    options.skills === undefined &&
    options.commands === undefined &&
    options.agents === undefined &&
    options.instructions === undefined;

  if (
    noOptionsProvided &&
    (hasSkills || hasCommands || hasAgents || hasInstructions)
  ) {
    logger.blank();

    if (hasSkills) {
      const skillsResponse = await prompts({
        type: 'confirm',
        name: 'install',
        message: 'Install skills to .claude/skills/?',
        initial: false,
      });
      installSkills = skillsResponse.install ?? false;
    }

    if (hasCommands) {
      const commandsResponse = await prompts({
        type: 'confirm',
        name: 'install',
        message: 'Install commands to .claude/commands/?',
        initial: false,
      });
      installCommands = commandsResponse.install ?? false;
    }
  }

  if (
    installSkills ||
    installCommands ||
    installAgents ||
    installInstructions
  ) {
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
        logger.info('Skipping extras installation.');
        installSkills = false;
        installCommands = false;
        installAgents = false;
        installInstructions = false;
      }
    }

    if (installSkills && hasSkills) {
      logger.blank();
      logger.info('Installing skills...');
      const skillsResult = await copySkills(templates, targetDir);

      // 중복 스킬이 있으면 사용자에게 선택 프롬프트 표시
      if (
        skillsResult.duplicateSkills &&
        skillsResult.duplicateSkills.length > 0
      ) {
        logger.blank();
        logger.warn('The following skills are included in multiple templates:');
        skillsResult.duplicateSkills.forEach(
          ({ skill, templates: skillTemplates }) => {
            logger.step(`${skill} (${skillTemplates.join(', ')})`);
          },
        );
        logger.blank();

        const response = await prompts({
          type: 'select',
          name: 'selectedTemplate',
          message: "Which template's version should be used?",
          choices: templates.map((t) => ({
            title: t,
            value: t,
          })),
        });

        if (response.selectedTemplate) {
          logger.info(
            `Reinstalling skills with ${response.selectedTemplate} template...`,
          );
          const reinstallResult = await copySkills(
            [response.selectedTemplate],
            targetDir,
          );
          totalFiles += reinstallResult.files;
          totalDirectories += reinstallResult.directories;
          logger.success(
            `Skills: ${reinstallResult.files} files, ${reinstallResult.directories} directories`,
          );
        } else {
          logger.warn('No template selected. Using all templates.');
          totalFiles += skillsResult.files;
          totalDirectories += skillsResult.directories;
          logger.success(
            `Skills: ${skillsResult.files} files, ${skillsResult.directories} directories`,
          );
        }
      } else {
        totalFiles += skillsResult.files;
        totalDirectories += skillsResult.directories;
        logger.success(
          `Skills: ${skillsResult.files} files, ${skillsResult.directories} directories`,
        );
      }
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

    if (installAgents && hasAgents) {
      logger.blank();
      logger.info('Installing agents...');
      const agentsResult = await copyAgents(templates, targetDir);
      totalFiles += agentsResult.files;
      totalDirectories += agentsResult.directories;
      logger.success(
        `Agents: ${agentsResult.files} files, ${agentsResult.directories} directories`,
      );
    } else if (installAgents && !hasAgents) {
      logger.warn('No agents found in selected templates.');
    }

    if (installInstructions && hasInstructions) {
      logger.blank();
      logger.info('Installing instructions...');
      const instructionsResult = await copyInstructions(templates, targetDir);
      totalFiles += instructionsResult.files;
      totalDirectories += instructionsResult.directories;
      logger.success(
        `Instructions: ${instructionsResult.files} files, ${instructionsResult.directories} directories`,
      );
    } else if (installInstructions && !hasInstructions) {
      logger.warn('No instructions found in selected templates.');
    }
  }

  logger.blank();
  logger.success('Claude Code documentation installed!');
  logger.blank();
  logger.info('Installed templates:');
  templates.forEach((t) => logger.step(t));

  if (
    (installSkills && hasSkills) ||
    (installCommands && hasCommands) ||
    (installAgents && hasAgents) ||
    (installInstructions && hasInstructions)
  ) {
    logger.blank();
    logger.info('Installed extras:');
    if (installSkills && hasSkills) {
      logger.step('Skills → .claude/skills/');
    }
    if (installCommands && hasCommands) {
      logger.step('Commands → .claude/commands/');
    }
    if (installAgents && hasAgents) {
      logger.step('Agents → .claude/agents/');
    }
    if (installInstructions && hasInstructions) {
      logger.step('Instructions → .claude/instructions/');
    }
  }

  logger.blank();
  logger.info('Next steps:');
  logger.step('Read CLAUDE.md for project guidelines');
  logger.step('Explore docs/ for detailed documentation');
  logger.blank();

  // .gitignore에 Claude Code 생성 폴더 추가
  try {
    await ensureGitignore(targetDir);
  } catch (error) {
    logger.warn(
      `Failed to update .gitignore: ${error instanceof Error ? error.message : 'Unknown error'}`,
    );
  }
};
