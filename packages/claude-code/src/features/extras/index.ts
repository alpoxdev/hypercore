/**
 * Extras 기능 모듈
 * Skills, Commands, Agents, Instructions 복사 및 설치 관리
 */

// Copier
export {
  copySkills,
  copyCommands,
  copyAgents,
  copyInstructions,
} from './extras-copier.js';

// Checker
export {
  checkExistingClaudeFiles,
  checkSkillsAndCommandsExist,
  checkAllExtrasExist,
} from './extras-checker.js';

// Installer
export { installExtras } from './extras-installer.js';

// Types
export type {
  CopyResult,
  InstallResult,
  ExtrasFlags,
  SkillsCopyResult,
  DuplicateSkill,
  ExtrasExistenceCheck,
  ExtrasType,
  ExtrasCopyOptions,
} from './types.js';
