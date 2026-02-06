import fs from 'fs-extra';
import path from 'path';
import { logger } from '../../shared/logger.js';

/**
 * 심링크 생성 (OS별 처리)
 *
 * - macOS/Linux: 상대 경로 심링크
 * - Windows: junction (디렉토리 심링크)
 */
export async function createSymlink(
  source: string,
  target: string,
): Promise<{ success: boolean; error?: string }> {
  try {
    // 타겟 디렉토리가 이미 존재하면 제거
    if (await fs.pathExists(target)) {
      await fs.remove(target);
    }

    // 타겟의 부모 디렉토리 생성
    await fs.ensureDir(path.dirname(target));

    // 상대 경로 계산
    const relativePath = path.relative(path.dirname(target), source);

    // OS별 심링크 생성
    if (process.platform === 'win32') {
      // Windows: junction 사용 (관리자 권한 불필요)
      await fs.symlink(source, target, 'junction');
    } else {
      // macOS/Linux: 상대 경로 심링크
      await fs.symlink(relativePath, target, 'dir');
    }

    logger.step(`Symlink: ${target} -> ${source}`);
    return { success: true };
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    logger.warn(`Failed to create symlink: ${target} (${message})`);
    return { success: false, error: message };
  }
}

/**
 * 심링크 제거
 */
export async function removeSymlink(linkPath: string): Promise<void> {
  if (!(await fs.pathExists(linkPath))) {
    return;
  }

  const stats = await fs.lstat(linkPath);
  if (stats.isSymbolicLink()) {
    await fs.unlink(linkPath);
    logger.step(`Removed symlink: ${linkPath}`);
  } else {
    // 일반 디렉토리/파일인 경우
    await fs.remove(linkPath);
    logger.step(`Removed directory: ${linkPath}`);
  }
}

/**
 * 심링크 여부 확인
 */
export async function isSymlink(linkPath: string): Promise<boolean> {
  try {
    const stats = await fs.lstat(linkPath);
    return stats.isSymbolicLink();
  } catch {
    return false;
  }
}
