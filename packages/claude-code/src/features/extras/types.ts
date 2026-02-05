/**
 * Extras 기능 관련 타입 정의
 */

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
}

/** Skills 복사 결과 */
export type SkillsCopyResult = CopyResult;

/** Extras 존재 여부 체크 결과 */
export interface ExtrasExistenceCheck {
  hasSkills: boolean;
  hasCommands: boolean;
  hasAgents: boolean;
  hasInstructions: boolean;
}

/** Extras 타입 */
export type ExtrasType = 'skills' | 'commands' | 'agents' | 'instructions';

/** Extras 복사 옵션 */
export interface ExtrasCopyOptions {
  type: ExtrasType;
  templates: string[];
  targetDir: string;
}
