/**
 * UI 관련 스킬 (비-UI 템플릿에서 제외)
 */
export const UI_SKILLS: string[] = [
  'global-uiux-design',
  'korea-uiux-design',
  'figma-to-code',
];

/**
 * 비-UI 템플릿 (UI 스킬 제외 대상)
 */
export const NON_UI_TEMPLATES: string[] = ['hono', 'npx'];

/**
 * 프레임워크 전용 스킬 (해당 템플릿에서만 설치)
 */
export const FRAMEWORK_SPECIFIC_SKILLS: Record<string, string[]> = {
  nextjs: ['nextjs-react-best-practices'],
  'tanstack-start': ['tanstack-start-react-best-practices'],
};
