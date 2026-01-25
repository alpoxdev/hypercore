import fs from 'fs-extra';
import path from 'path';
import { logger } from './logger.js';

// Claude Code가 생성하는 폴더 목록
const CLAUDE_GENERATED_FOLDERS = ['CLAUDE.md', 'docs/', '.claude/'];

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
