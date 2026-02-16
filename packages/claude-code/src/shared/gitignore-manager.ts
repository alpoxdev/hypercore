import fs from 'fs-extra';
import path from 'path';
import { logger } from './logger.js';

// Claude Code가 생성하는 폴더 목록
const CLAUDE_GENERATED_FOLDERS = [
  '.claude/plan/',
  '.claude/ralph/',
  '.claude/refactor/',
  '.claude/prd/',
];

function normalizeIgnorePattern(pattern: string): string {
  return pattern
    .replace(/\\/g, '/')
    .replace(/^\.?\//, '')
    .replace(/\/+$/, '')
    .trim();
}

function parseIgnoreLine(line: string): string | null {
  const trimmed = line.trim();

  if (!trimmed || trimmed.startsWith('#') || trimmed.startsWith('!')) {
    return null;
  }

  const [rawPattern] = trimmed.split(/\s+#/u, 1);
  const normalized = normalizeIgnorePattern(rawPattern);
  return normalized || null;
}

/**
 * .gitignore 파일에 Claude Code 생성 폴더를 추가
 * .gitignore가 없으면 생성, 있으면 기존 내용에 추가 (중복 방지)
 */
export async function updateGitignore(targetDir: string): Promise<void> {
  const gitignorePath = path.join(targetDir, '.gitignore');
  const sectionComment = '# Claude Code generated files';

  let content = '';
  let hasGitignore = false;

  // 기존 .gitignore 읽기
  try {
    content = await fs.readFile(gitignorePath, 'utf-8');
    hasGitignore = true;
  } catch {
    // .gitignore 없음 → 새로 생성
    content = '';
  }

  const eol = content.includes('\r\n') ? '\r\n' : '\n';
  const lines = content ? content.split(/\r?\n/u) : [];
  const existingPatterns = new Set(
    lines
      .map((line) => parseIgnoreLine(line))
      .filter((pattern): pattern is string => Boolean(pattern)),
  );
  const linesToAdd = CLAUDE_GENERATED_FOLDERS.filter(
    (folder) => !existingPatterns.has(normalizeIgnorePattern(folder)),
  );

  if (linesToAdd.length === 0) {
    logger.info('.gitignore already contains all Claude Code patterns');
    return;
  }

  // 섹션 주석이 없으면 추가
  const sectionIndex = lines.findIndex(
    (line) => line.trim() === sectionComment,
  );
  const needsSection = sectionIndex === -1;

  if (needsSection) {
    // 섹션 주석이 없으면 파일 끝에 새로 추가
    if (lines.length > 0 && lines[lines.length - 1] !== '') {
      lines.push('');
    }
    lines.push(sectionComment, ...linesToAdd);
  } else {
    // 섹션 주석이 이미 있으면 해당 섹션 끝에 패턴만 추가
    // 섹션 다음 줄에 패턴 추가
    lines.splice(sectionIndex + 1, 0, ...linesToAdd);
  }

  let newContent = lines.join(eol);
  if (!newContent.endsWith(eol)) {
    newContent += eol;
  }

  // 파일 쓰기
  await fs.writeFile(gitignorePath, newContent, 'utf-8');

  if (hasGitignore) {
    logger.success(`.gitignore updated with ${linesToAdd.length} patterns`);
  } else {
    logger.success(`.gitignore created with ${linesToAdd.length} patterns`);
  }
}
