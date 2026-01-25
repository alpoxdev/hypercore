import fs from 'fs-extra';
import path from 'path';
import { validateTargetDir } from '../../shared/validators/index.js';
import { copyRecursive } from '../../shared/filesystem/index.js';
import { getTemplatePath } from './template-path-resolver.js';
import { generateIndexClaudeMd } from './template-metadata.js';

/**
 * 단일 템플릿 복사 (CLAUDE.md → 루트, docs/ → 루트/docs/)
 * 기존 docs 폴더는 삭제 후 새로 복사
 */
export const copySingleTemplate = async (
  template: string,
  targetDir: string,
): Promise<{ files: number; directories: number }> => {
  validateTargetDir(targetDir);
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
  validateTargetDir(targetDir);
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
