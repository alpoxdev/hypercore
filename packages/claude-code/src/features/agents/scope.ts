import os from 'os';
import path from 'path';
import type { AgentConfig, ScopeType, ExtrasType } from './types.js';

/**
 * 틸드(~) 경로를 절대 경로로 확장
 */
function expandTilde(filePath: string): string {
  if (filePath.startsWith('~/')) {
    return path.join(os.homedir(), filePath.slice(2));
  }
  return filePath;
}

/**
 * 에이전트 + 스코프 + extras 타입 -> 실제 절대 경로 해석
 *
 * @param agent 에이전트 설정
 * @param scope project | global
 * @param extrasType 설치할 extras 타입
 * @param cwd 프로젝트 루트 (project scope에서만 사용)
 * @returns 절대 경로 또는 null (해당 타입 미지원 시)
 */
export function resolveExtrasDir(
  agent: AgentConfig,
  scope: ScopeType,
  extrasType: ExtrasType,
  cwd?: string,
): string | null {
  const mapping =
    scope === 'project' ? agent.projectExtras : agent.globalExtras;
  const relativePath = mapping[extrasType];

  // 해당 extras 타입을 지원하지 않는 에이전트
  if (!relativePath) {
    return null;
  }

  // Project scope: cwd + 상대 경로
  if (scope === 'project') {
    if (!cwd) {
      throw new Error('cwd is required for project scope');
    }
    return path.resolve(cwd, relativePath);
  }

  // Global scope: 틸드 확장
  return expandTilde(relativePath);
}
