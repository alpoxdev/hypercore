/**
 * Extras 기능 관련 타입 정의
 */

// ExtrasType은 agents/types.ts에서 정의 (단일 정의 원칙)
import type { ExtrasType } from '../agents/types.js';
export type { ExtrasType } from '../agents/types.js';

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

/** Extras 복사 옵션 */
export interface ExtrasCopyOptions {
  type: ExtrasType;
  templates: string[];
  targetDir: string;
}
