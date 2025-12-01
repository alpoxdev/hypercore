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

  // docs/ → 루트/docs/
  const docsSrc = path.join(templatePath, 'docs');
  if (await fs.pathExists(docsSrc)) {
    await copyRecursive(docsSrc, path.join(targetDir, 'docs'), counter);
  }

  return counter;
};

/**
 * 다중 템플릿 복사 (각 템플릿 폴더 전체 → 루트/docs/템플릿명/)
 */
export const copyMultipleTemplates = async (
  templates: string[],
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const counter = { files: 0, directories: 0 };

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

  return counter;
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

export const getSkillsPath = (template: string): string => {
  return path.join(getTemplatePath(template), 'docs', 'skills');
};

export const listAvailableSkills = async (
  template: string,
): Promise<string[]> => {
  const skillsPath = getSkillsPath(template);

  if (!(await fs.pathExists(skillsPath))) {
    return [];
  }

  const items = await fs.readdir(skillsPath);
  const skills: string[] = [];

  for (const item of items) {
    const itemPath = path.join(skillsPath, item);
    const stat = await fs.stat(itemPath);
    if (stat.isDirectory()) {
      skills.push(item);
    }
  }

  return skills;
};

export const copySkills = async (
  template: string,
  targetDir: string,
): Promise<{ files: number; directories: number; skills: string[] }> => {
  const skillsPath = getSkillsPath(template);
  const targetSkillsDir = path.join(targetDir, '.claude', 'skills');

  if (!(await fs.pathExists(skillsPath))) {
    return { files: 0, directories: 0, skills: [] };
  }

  let files = 0;
  let directories = 0;
  const installedSkills: string[] = [];

  const copyRecursive = async (src: string, dest: string): Promise<void> => {
    const stat = await fs.stat(src);

    if (stat.isDirectory()) {
      await fs.ensureDir(dest);
      directories++;

      const items = await fs.readdir(src);
      for (const item of items) {
        await copyRecursive(path.join(src, item), path.join(dest, item));
      }
    } else {
      await fs.copy(src, dest);
      files++;
    }
  };

  const skillItems = await fs.readdir(skillsPath);
  for (const skill of skillItems) {
    const skillSrcPath = path.join(skillsPath, skill);
    const skillDestPath = path.join(targetSkillsDir, skill);
    const stat = await fs.stat(skillSrcPath);

    if (stat.isDirectory()) {
      await copyRecursive(skillSrcPath, skillDestPath);
      installedSkills.push(skill);
    }
  }

  return { files, directories, skills: installedSkills };
};

export const checkExistingSkills = async (
  targetDir: string,
  skills: string[],
): Promise<string[]> => {
  const existingSkills: string[] = [];
  const targetSkillsDir = path.join(targetDir, '.claude', 'skills');

  for (const skill of skills) {
    const skillPath = path.join(targetSkillsDir, skill);
    if (await fs.pathExists(skillPath)) {
      existingSkills.push(skill);
    }
  }

  return existingSkills;
};
