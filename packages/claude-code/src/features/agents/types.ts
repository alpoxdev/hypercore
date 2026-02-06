/**
 * Agent 타입 정의
 * 지원하는 AI 에이전트 목록
 */
export type AgentType = 'claude-code' | 'codex' | 'antigravity' | 'cursor';

/**
 * Extras 타입별 경로 매핑
 * 에이전트가 지원하지 않는 extras는 undefined
 */
export interface ExtrasMapping {
  skills?: string;
  commands?: string;
  agents?: string;
  instructions?: string;
}

/**
 * Agent 설정
 */
export interface AgentConfig {
  /** 에이전트 식별자 */
  name: AgentType;

  /** 표시 이름 */
  displayName: string;

  /** 프로젝트 레벨 extras 경로 (상대 경로) */
  projectExtras: ExtrasMapping;

  /** 글로벌 레벨 extras 경로 (절대 경로, ~/ 포함) */
  globalExtras: ExtrasMapping;

  /** 설치 감지 함수 (해당 에이전트 설치 여부 확인) */
  detectInstalled: () => Promise<boolean>;
}

/**
 * Scope 타입
 */
export type ScopeType = 'project' | 'global';

/**
 * Extras 타입
 */
export type ExtrasType = 'skills' | 'commands' | 'agents' | 'instructions';
