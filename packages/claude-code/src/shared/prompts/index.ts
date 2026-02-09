/**
 * Prompts 모듈
 * 프롬프트 관련 유틸리티 함수 및 타입 재내보내기
 */

// 타입 내보내기
export type {
  PromptChoice,
  ConfirmResult,
  SelectResult,
  MultiselectResult,
  TemplateSelectionOptions,
  TemplateSelectionResult,
  OverwritePromptOptions,
  ExtrasSelectionOptions,
  ExtrasSelectionResult,
  ScopeSelectionOptions,
  ScopeSelectionResult,
} from './types.js';

// 저수준 헬퍼 내보내기
export {
  promptConfirm,
  promptSelect,
  promptMultiselect,
} from './prompt-helpers.js';

// 고수준 비즈니스 로직 내보내기
export {
  promptTemplateSelection,
  promptOverwrite,
  promptExtrasSelection,
  promptScopeSelection,
} from './prompt-functions.js';
