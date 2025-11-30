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

export const copyTemplate = async (
  template: string,
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  const templatePath = getTemplatePath(template);

  if (!(await fs.pathExists(templatePath))) {
    throw new Error(`Template "${template}" not found at ${templatePath}`);
  }

  let files = 0;
  let directories = 0;

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

  await copyRecursive(templatePath, targetDir);

  return { files, directories };
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
