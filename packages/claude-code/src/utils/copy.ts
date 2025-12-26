import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const getTemplatesDir = (): string => {
  // dist/index.js -> templates/ (tsup bundles everything into one file)
  return path.resolve(__dirname, '../templates');
};

export const getTemplatePath = (template: string): string => {
  return path.join(getTemplatesDir(), template);
};

const copyRecursive = async (
  src: string,
  dest: string,
  counter: { files: number; directories: number },
): Promise<void> => {
  const stat = await fs.stat(src);

  if (stat.isDirectory()) {
    await fs.ensureDir(dest);
    counter.directories++;

    const items = await fs.readdir(src);
    for (const item of items) {
      await copyRecursive(path.join(src, item), path.join(dest, item), counter);
    }
  } else {
    await fs.copy(src, dest);
    counter.files++;
  }
};

/**
 * 단일 템플릿 복사 (CLAUDE.md → 루트, docs/ → 루트/docs/)
 * 기존 docs 폴더는 삭제 후 새로 복사
 */
export const copySingleTemplate = async (
  template: string,
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const templatePath = getTemplatePath(template);

  if (!(await fs.pathExists(templatePath))) {
    throw new Error(`Template "${template}" not found at ${templatePath}`);
  }

  const counter = { files: 0, directories: 0 };

  // CLAUDE.md → 루트
  const claudeMdSrc = path.join(templatePath, 'CLAUDE.md');
  if (await fs.pathExists(claudeMdSrc)) {
    await fs.copy(claudeMdSrc, path.join(targetDir, 'CLAUDE.md'));
    counter.files++;
  }

  // docs/ → 루트/docs/ (기존 폴더 삭제 후 복사)
  const docsSrc = path.join(templatePath, 'docs');
  const docsDest = path.join(targetDir, 'docs');
  if (await fs.pathExists(docsSrc)) {
    // 기존 docs 폴더 삭제
    if (await fs.pathExists(docsDest)) {
      await fs.remove(docsDest);
    }
    await copyRecursive(docsSrc, docsDest, counter);
  }

  return counter;
};

/**
 * 다중 템플릿 복사 (각 템플릿 폴더 전체 → 루트/docs/템플릿명/)
 * 기존 docs 폴더는 삭제 후 새로 복사
 * 루트 CLAUDE.md는 각 템플릿의 CLAUDE.md를 인덱싱
 */
export const copyMultipleTemplates = async (
  templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };

  // 기존 docs 폴더 삭제
  const docsDir = path.join(targetDir, 'docs');
  if (await fs.pathExists(docsDir)) {
    await fs.remove(docsDir);
  }

  for (const template of templates) {
    const templatePath = getTemplatePath(template);

    if (!(await fs.pathExists(templatePath))) {
      throw new Error(`Template "${template}" not found at ${templatePath}`);
    }

    // 템플릿 폴더 전체 → docs/템플릿명/
    await copyRecursive(
      templatePath,
      path.join(targetDir, 'docs', template),
      counter,
    );
  }

  // 루트 CLAUDE.md 생성 (각 템플릿 CLAUDE.md 인덱싱)
  const indexContent = generateIndexClaudeMd(templates);
  await fs.writeFile(path.join(targetDir, 'CLAUDE.md'), indexContent);
  counter.files++;

  return counter;
};

/**
 * 다중 템플릿용 인덱스 CLAUDE.md 생성
 */
const generateIndexClaudeMd = (templates: string[]): string => {
  const templateLinks = templates
    .map((t) => `- [${t}](docs/${t}/CLAUDE.md)`)
    .join('\n');

  return `# CLAUDE.md

> 이 프로젝트는 여러 템플릿의 Claude Code 문서를 포함합니다.

## 템플릿 문서

${templateLinks}

## 사용법

각 템플릿의 \`CLAUDE.md\`를 참조하여 해당 기술 스택의 가이드라인을 확인하세요.
`;
};

export const checkExistingFiles = async (
  targetDir: string,
): Promise<string[]> => {
  const existingFiles: string[] = [];

  const claudeMd = path.join(targetDir, 'CLAUDE.md');
  const docsDir = path.join(targetDir, 'docs');

  if (await fs.pathExists(claudeMd)) {
    existingFiles.push('CLAUDE.md');
  }

  if (await fs.pathExists(docsDir)) {
    existingFiles.push('docs/');
  }

  return existingFiles;
};

export const listAvailableTemplates = async (): Promise<string[]> => {
  const templatesDir = getTemplatesDir();

  if (!(await fs.pathExists(templatesDir))) {
    return [];
  }

  const items = await fs.readdir(templatesDir);
  const templates: string[] = [];

  for (const item of items) {
    const itemPath = path.join(templatesDir, item);
    const stat = await fs.stat(itemPath);
    if (stat.isDirectory()) {
      templates.push(item);
    }
  }

  return templates;
};

/**
 * Skills 복사 (템플릿의 docs/skills/ → 타겟/.claude/skills/)
 * Skills는 폴더 기반 구조
 */
export const copySkills = async (
  templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };
  const targetSkillsDir = path.join(targetDir, '.claude', 'skills');

  for (const template of templates) {
    const templatePath = getTemplatePath(template);
    const skillsSrc = path.join(templatePath, 'docs', 'skills');

    if (await fs.pathExists(skillsSrc)) {
      await fs.ensureDir(targetSkillsDir);
      await copyRecursive(skillsSrc, targetSkillsDir, counter);
    }
  }

  return counter;
};

/**
 * Commands 복사 (템플릿의 docs/commands/ → 타겟/.claude/commands/)
 * Commands는 .md 파일 기반 구조
 */
export const copyCommands = async (
  templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };
  const targetCommandsDir = path.join(targetDir, '.claude', 'commands');

  for (const template of templates) {
    const templatePath = getTemplatePath(template);
    const commandsSrc = path.join(templatePath, 'docs', 'commands');

    if (await fs.pathExists(commandsSrc)) {
      await fs.ensureDir(targetCommandsDir);
      await copyRecursive(commandsSrc, targetCommandsDir, counter);
    }
  }

  return counter;
};

/**
 * Skills와 Commands가 존재하는지 확인
 */
export const checkSkillsAndCommandsExist = async (
  templates: string[],
): Promise<{ hasSkills: boolean; hasCommands: boolean }> => {
  let hasSkills = false;
  let hasCommands = false;

  for (const template of templates) {
    const templatePath = getTemplatePath(template);
    const skillsSrc = path.join(templatePath, 'docs', 'skills');
    const commandsSrc = path.join(templatePath, 'docs', 'commands');

    if (await fs.pathExists(skillsSrc)) {
      hasSkills = true;
    }
    if (await fs.pathExists(commandsSrc)) {
      hasCommands = true;
    }
  }

  return { hasSkills, hasCommands };
};

/**
 * 기존 .claude/skills, .claude/commands 파일 확인
 */
export const checkExistingClaudeFiles = async (
  targetDir: string,
): Promise<string[]> => {
  const existingFiles: string[] = [];

  const skillsDir = path.join(targetDir, '.claude', 'skills');
  const commandsDir = path.join(targetDir, '.claude', 'commands');

  if (await fs.pathExists(skillsDir)) {
    existingFiles.push('.claude/skills/');
  }

  if (await fs.pathExists(commandsDir)) {
    existingFiles.push('.claude/commands/');
  }

  return existingFiles;
};
