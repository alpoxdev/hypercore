import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { validateTemplateName, validateTargetDir } from './validators.js';
import { copyRecursive } from './copy-utils.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const getTemplatesDir = (): string => {
  // dist/index.js -> templates/ (tsup bundles everything into one file)
  return path.resolve(__dirname, '../templates');
};

export const getTemplatePath = (template: string): string => {
  validateTemplateName(template);
  return path.join(getTemplatesDir(), template);
};

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

/**
 * 다중 템플릿용 인덱스 CLAUDE.md 생성
 */
const generateIndexClaudeMd = (templates: string[]): string => {
  // 템플릿별 메타데이터 정의
  const templateMetadata: Record<
    string,
    { name: string; description: string; stack: string }
  > = {
    'tanstack-start': {
      name: 'TanStack Start',
      description: 'React + TanStack Router SSR 풀스택 프로젝트',
      stack: 'React, TanStack Router, Vite, TypeScript',
    },
    hono: {
      name: 'Hono',
      description: 'Edge Runtime 백엔드 API 프로젝트',
      stack: 'Hono, TypeScript, Cloudflare Workers',
    },
    npx: {
      name: 'NPX CLI',
      description: 'NPX로 실행 가능한 CLI 도구 프로젝트',
      stack: 'Node.js, TypeScript, Commander.js',
    },
  };

  const templateSections = templates
    .map((template) => {
      const meta = templateMetadata[template] || {
        name: template,
        description: `${template} 프로젝트`,
        stack: 'TypeScript',
      };

      return `### ${meta.name}
- **용도:** ${meta.description}
- **주요 스택:** ${meta.stack}
- **가이드:** [docs/${template}/CLAUDE.md](docs/${template}/CLAUDE.md)`;
    })
    .join('\n\n');

  return `# CLAUDE.md

> 이 프로젝트는 여러 프레임워크의 Claude Code 가이드를 포함합니다.

## 사용 방법

아래 템플릿 중 **현재 프로젝트에 사용 중인 프레임워크**를 선택하여 해당 가이드를 따르세요.

## 템플릿 목록

${templateSections}

---

**현재 프로젝트에 맞는 가이드를 CLAUDE.md의 \`@\` 인스트럭션에 추가하세요.**
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
