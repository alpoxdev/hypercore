/**
 * Extras 기능 관련 타입 정의
 */

/** 설치 범위 (Project: CWD/.claude/, User: ~/.claude/) */
export type InstallScope = 'project' | 'user';

/** 복사 결과 */
export interface CopyResult {
  files: number;
  directories: number;
}

/** 설치 결과 */
export interface InstallResult {
  files: number;
  directories: number;
}

/** Extras 설치 플래그 */
export interface ExtrasFlags {
  installSkills: boolean;
  installCommands: boolean;
  installAgents: boolean;
  installInstructions: boolean;
  installScripts: boolean;
  installHooks: boolean;
}

/** Skills 복사 결과 */
export type SkillsCopyResult = CopyResult;

/** Extras 존재 여부 체크 결과 */
export interface ExtrasExistenceCheck {
  hasSkills: boolean;
  hasCommands: boolean;
  hasAgents: boolean;
  hasInstructions: boolean;
  hasScripts: boolean;
  hasHooks: boolean;
}

/** Extras 타입 */
export type ExtrasType =
  | 'skills'
  | 'commands'
  | 'agents'
  | 'instructions'
  | 'scripts'
  | 'hooks';

/** Extras 복사 옵션 */
export interface ExtrasCopyOptions {
  type: ExtrasType;
  templates: string[];
  targetDir: string;
}
