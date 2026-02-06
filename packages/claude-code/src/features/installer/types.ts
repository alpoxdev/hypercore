import type { AgentType, ScopeType, ExtrasType } from '../agents/types.js';

/**
 * 설치 모드
 */
export type InstallMode = 'symlink' | 'copy';

/**
 * 설치 대상
 */
export interface InstallTarget {
  /** 에이전트 */
  agent: AgentType;

  /** 스코프 */
  scope: ScopeType;

  /** Extras 타입 */
  extrasType: ExtrasType;

  /** 소스 경로 (정규 위치) */
  sourcePath: string;

  /** 대상 경로 (에이전트별 경로) */
  targetPath: string;
}

/**
 * 설치 결과
 */
export interface InstallerResult {
  /** 성공 여부 */
  success: boolean;

  /** 사용된 모드 */
  mode: InstallMode;

  /** 생성된 경로들 */
  paths: string[];

  /** 에러 메시지 (실패 시) */
  error?: string;
}
