import fs from 'fs-extra';
import path from 'path';
import { getTemplatesDir } from './template-path-resolver.js';

/**
 * 설치 가능한 템플릿 목록 조회
 */
export const listAvailableTemplates = async (): Promise<string[]> => {
  const templatesDir = getTemplatesDir();

  if (!(await fs.pathExists(templatesDir))) {
    return [];
  }

  const items = await fs.readdir(templatesDir);
  const templates: string[] = [];

  for (const item of items) {
    // .으로 시작하는 폴더는 제외 (.claude 등)
    if (item.startsWith('.')) {
      continue;
    }
    const itemPath = path.join(templatesDir, item);
    const stat = await fs.stat(itemPath);
    if (stat.isDirectory()) {
      templates.push(item);
    }
  }

  return templates;
};

/**
 * 기존 CLAUDE.md, docs/ 폴더 확인
 */
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
