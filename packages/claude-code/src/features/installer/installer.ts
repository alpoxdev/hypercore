import fs from 'fs-extra';
import os from 'os';
import path from 'path';
import { logger } from '../../shared/logger.js';
import { CANONICAL_DIR } from '../../shared/constants.js';
import { copyRecursive } from '../../shared/filesystem/index.js';
import { getAgent, resolveExtrasDir } from '../agents/index.js';
import type { AgentType, ScopeType, ExtrasType } from '../agents/types.js';
import { createSymlink, removeSymlink } from './symlink.js';
import type { InstallMode, InstallerResult } from './types.js';

/**
 * 정규 위치 경로 계산
 */
function getCanonicalPath(
  targetDir: string,
  scope: ScopeType,
  extrasType: ExtrasType,
  name: string,
): string {
  if (scope === 'global') {
    // 글로벌: ~/.agents/skills/ 구조
    return path.join(os.homedir(), CANONICAL_DIR, extrasType, name);
  }
  // 프로젝트: .agents/skills/ 구조
  return path.join(targetDir, CANONICAL_DIR, extrasType, name);
}

/**
 * 정규 위치 + 에이전트별 심링크 설치
 *
 * 1. 정규 위치에 복사: .agents/{extrasType}/{name}/
 * 2. 각 에이전트별 심링크 생성: .{agent}/{extrasType}/{name} -> .agents/{extrasType}/{name}
 * 3. 심링크 실패 시 직접 복사 폴백
 */
export async function installToAgents(
  sourcePath: string,
  agents: AgentType[],
  scope: ScopeType,
  extrasType: ExtrasType,
  cwd: string,
  name: string,
): Promise<InstallerResult> {
  const paths: string[] = [];
  let mode: InstallMode = 'symlink';

  try {
    // 1. 정규 위치에 복사
    const canonicalPath = getCanonicalPath(cwd, scope, extrasType, name);
    await fs.ensureDir(path.dirname(canonicalPath));

    // 기존 정규 위치 제거 후 복사
    if (await fs.pathExists(canonicalPath)) {
      await fs.remove(canonicalPath);
    }

    const counter = { files: 0, directories: 0 };
    await copyRecursive(sourcePath, canonicalPath, counter);
    paths.push(canonicalPath);

    logger.step(`Canonical: ${canonicalPath} (${counter.files} files)`);

    // 2. 각 에이전트별 심링크 생성
    for (const agentName of agents) {
      const agent = getAgent(agentName);
      const agentExtrasDir = resolveExtrasDir(agent, scope, extrasType, cwd);

      // 해당 에이전트가 이 extras 타입을 지원하지 않으면 skip
      if (!agentExtrasDir) {
        logger.step(`Skipped: ${agentName} (does not support ${extrasType})`);
        continue;
      }

      const agentPath = path.join(agentExtrasDir, name);

      // 심링크 생성 시도
      const symlinkResult = await createSymlink(canonicalPath, agentPath);

      if (symlinkResult.success) {
        paths.push(agentPath);
      } else {
        // 심링크 실패 시 직접 복사 폴백
        logger.warn(`Falling back to copy for ${agentName}`);
        mode = 'copy';

        await fs.ensureDir(path.dirname(agentPath));
        if (await fs.pathExists(agentPath)) {
          await fs.remove(agentPath);
        }

        const copyCounter = { files: 0, directories: 0 };
        await copyRecursive(sourcePath, agentPath, copyCounter);
        paths.push(agentPath);

        logger.step(`Copy: ${agentPath}`);
      }
    }

    return { success: true, mode, paths };
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    logger.error(`Installation failed: ${message}`);
    return { success: false, mode, paths, error: message };
  }
}

/**
 * 에이전트별 심링크/복사본 + 정규 위치 제거
 */
export async function uninstallFromAgents(
  name: string,
  agents: AgentType[],
  scope: ScopeType,
  extrasType: ExtrasType,
  cwd: string,
): Promise<void> {
  // 1. 에이전트별 심링크/복사본 제거
  for (const agentName of agents) {
    const agent = getAgent(agentName);
    const agentExtrasDir = resolveExtrasDir(agent, scope, extrasType, cwd);

    if (!agentExtrasDir) {
      continue;
    }

    const agentPath = path.join(agentExtrasDir, name);
    await removeSymlink(agentPath);
  }

  // 2. 정규 위치에서 제거
  const canonicalPath = getCanonicalPath(cwd, scope, extrasType, name);
  if (await fs.pathExists(canonicalPath)) {
    await fs.remove(canonicalPath);
    logger.step(`Removed canonical: ${canonicalPath}`);
  }
}
