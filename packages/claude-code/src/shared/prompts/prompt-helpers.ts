/**
 * 저수준 프롬프트 헬퍼 함수
 * prompts 라이브러리의 기본 타입을 래핑
 */

import prompts from 'prompts';
import type {
  ConfirmResult,
  SelectResult,
  MultiselectResult,
  PromptChoice,
} from './types.js';

/**
 * Confirm 프롬프트 헬퍼
 * @param message 프롬프트 메시지
 * @param initial 기본값 (default: false)
 * @returns 사용자 선택 결과
 */
export async function promptConfirm(
  message: string,
  initial = false,
): Promise<ConfirmResult> {
  const response = await prompts({
    type: 'confirm',
    name: 'confirmed',
    message,
    initial,
  });

  return { confirmed: response.confirmed ?? false };
}

/**
 * Select 프롬프트 헬퍼
 * @param message 프롬프트 메시지
 * @param choices 선택지 목록
 * @returns 선택된 값 (취소 시 undefined)
 */
export async function promptSelect<T = string>(
  message: string,
  choices: PromptChoice<T>[],
): Promise<SelectResult<T>> {
  const response = await prompts({
    type: 'select',
    name: 'value',
    message,
    choices,
  });

  return { value: response.value };
}

/**
 * Multiselect 프롬프트 헬퍼
 * @param message 프롬프트 메시지
 * @param choices 선택지 목록
 * @param min 최소 선택 개수 (optional)
 * @param hint 힌트 메시지 (optional)
 * @returns 선택된 값 배열
 */
export async function promptMultiselect<T = string>(
  message: string,
  choices: PromptChoice<T>[],
  options?: { min?: number; hint?: string },
): Promise<MultiselectResult<T>> {
  const response = await prompts({
    type: 'multiselect',
    name: 'values',
    message,
    choices,
    min: options?.min,
    hint: options?.hint,
  });

  return { values: response.values || [] };
}
