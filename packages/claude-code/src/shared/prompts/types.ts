/**
 * Prompts 모듈 타입 정의
 */

// 프롬프트 선택지 인터페이스
export interface PromptChoice<T = string> {
  title: string;
  description?: string;
  value: T;
}

// 기본 프롬프트 결과 타입
export interface ConfirmResult {
  confirmed: boolean;
}

export interface SelectResult<T = string> {
  value: T | undefined;
}

export interface MultiselectResult<T = string> {
  values: T[];
}

// 템플릿 선택 관련 타입
export interface TemplateSelectionOptions {
  providedTemplates?: string[];
  availableTemplates: string[];
  templateDescriptions: Record<string, string>;
}

export interface TemplateSelectionResult {
  templates: string[];
}

// 덮어쓰기 확인 관련 타입
export interface OverwritePromptOptions {
  existingFiles: string[];
  force: boolean;
}

// Scope 선택 관련 타입
export interface ScopeSelectionOptions {
  providedScope?: string;
}

export interface ScopeSelectionResult {
  scope: 'project' | 'user';
}

// Codex sync 확인 관련 타입
export interface CodexSyncPromptOptions {
  providedSyncCodex?: boolean;
}

export interface CodexSyncPromptResult {
  syncCodex: boolean;
}

// Extras 선택 관련 타입
export interface ExtrasSelectionOptions {
  skills?: boolean;
  commands?: boolean;
  agents?: boolean;
  instructions?: boolean;
  scripts?: boolean;
  hasSkills: boolean;
  hasCommands: boolean;
  hasAgents: boolean;
  hasInstructions: boolean;
  hasScripts: boolean;
}

export interface ExtrasSelectionResult {
  installSkills: boolean;
  installCommands: boolean;
  installAgents: boolean;
  installInstructions: boolean;
  installScripts: boolean;
}
