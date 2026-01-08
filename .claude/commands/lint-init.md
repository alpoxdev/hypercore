---
description: 프로젝트 분석 후 ESLint flat config 설정
allowed-tools: Bash, Read, Write, Glob, mcp__sequential-thinking__sequentialthinking
---

@../instructions/sequential-thinking-guide.md

# Lint Init Command

프로젝트를 분석하여 ESLint flat config 자동 설정.

<requirements>

| 분류 | 필수 |
|------|------|
| **Thinking** | Sequential 5-7단계 (@sequential-thinking-guide.md) |

</requirements>

<workflow>

1. **Sequential Thinking** (5-7단계)
   - 프로젝트 구조 파악
   - 사용 기술 스택 확인
   - 기존 설정 분석
   - 적합한 규칙 선정
   - Flat config 구조 설계

2. **package.json 분석**
   - 프레임워크 (React, Vue, etc)
   - 타입스크립트 여부
   - 기존 ESLint 버전

3. **eslint.config.js 생성** (flat config)
   - 적절한 플러그인 선택
   - 규칙 설정
   - ignores 패턴

4. **필요 패키지 설치 안내**

</workflow>

<template>

```javascript
// eslint.config.js
import js from '@eslint/js'
import tseslint from 'typescript-eslint'
import react from 'eslint-plugin-react'

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ['**/*.{js,jsx,ts,tsx}'],
    plugins: { react },
    rules: {
      '@typescript-eslint/no-unused-vars': 'warn',
      'react/react-in-jsx-scope': 'off',
    },
  },
  {
    ignores: ['dist/', 'build/', 'node_modules/'],
  },
]
```

</template>
