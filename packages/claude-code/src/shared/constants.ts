/**
 * 프레임워크별 스킬 매핑 (React 프레임워크 전용)
 */
export const FRAMEWORK_SPECIFIC_SKILLS_MAP: Record<string, string[]> = {
  nextjs: ['nextjs-react-best-practices', 'korea-uiux-design', 'figma-to-code'],
  'tanstack-start': [
    'tanstack-start-react-best-practices',
    'korea-uiux-design',
    'figma-to-code',
  ],
  // hono와 npx는 프레임워크별 스킬 없음
};

/**
 * 공통 스킬 (프레임워크 무관하게 항상 설치)
 */
export const COMMON_SKILLS: string[] = [
  'global-uiux-design',
  'docs-creator',
  'docs-refactor',
  'plan',
  'prd',
  'ralph',
  'execute',
];
