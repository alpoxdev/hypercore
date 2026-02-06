/**
 * Prompts 모듈 타입 정의
 */

import type { AgentType, ScopeType } from '../../features/agents/types.js';

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

// Extras 선택 관련 타입
export interface ExtrasSelectionOptions {
  skills?: boolean;
  commands?: boolean;
  agents?: boolean;
  instructions?: boolean;
  hasSkills: boolean;
  hasCommands: boolean;
  hasAgents: boolean;
  hasInstructions: boolean;
}

export interface ExtrasSelectionResult {
  installSkills: boolean;
  installCommands: boolean;
  installAgents: boolean;
  installInstructions: boolean;
}

// 에이전트 선택 관련 타입
export interface AgentSelectionOptions {
  installedAgents: AgentType[];
}

export interface AgentSelectionResult {
  agents: AgentType[];
}

// Scope 선택 관련 타입
// eslint-disable-next-line @typescript-eslint/no-empty-object-type
export interface ScopeSelectionOptions {
  // 향후 확장 가능
}

export interface ScopeSelectionResult {
  scope: ScopeType;
}
