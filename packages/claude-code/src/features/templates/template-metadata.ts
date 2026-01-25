/**
 * 템플릿별 메타데이터
 */
export const templateMetadata: Record<
  string,
  { name: string; description: string; stack: string }
> = {
  'tanstack-start': {
    name: 'TanStack Start',
    description: 'React + TanStack Router SSR 풀스택 프로젝트',
    stack: 'React, TanStack Router, Vite, TypeScript',
  },
  hono: {
    name: 'Hono',
    description: 'Edge Runtime 백엔드 API 프로젝트',
    stack: 'Hono, TypeScript, Cloudflare Workers',
  },
  npx: {
    name: 'NPX CLI',
    description: 'NPX로 실행 가능한 CLI 도구 프로젝트',
    stack: 'Node.js, TypeScript, Commander.js',
  },
};

/**
 * 다중 템플릿용 인덱스 CLAUDE.md 생성
 */
export const generateIndexClaudeMd = (templates: string[]): string => {
  const templateSections = templates
    .map((template) => {
      const meta = templateMetadata[template] || {
        name: template,
        description: `${template} 프로젝트`,
        stack: 'TypeScript',
      };

      return `### ${meta.name}
- **용도:** ${meta.description}
- **주요 스택:** ${meta.stack}
- **가이드:** [docs/${template}/CLAUDE.md](docs/${template}/CLAUDE.md)`;
    })
    .join('\n\n');

  return `# CLAUDE.md

> 이 프로젝트는 여러 프레임워크의 Claude Code 가이드를 포함합니다.

## 사용 방법

아래 템플릿 중 **현재 프로젝트에 사용 중인 프레임워크**를 선택하여 해당 가이드를 따르세요.

## 템플릿 목록

${templateSections}

---

**현재 프로젝트에 맞는 가이드를 CLAUDE.md의 \`@\` 인스트럭션에 추가하세요.**
`;
};
