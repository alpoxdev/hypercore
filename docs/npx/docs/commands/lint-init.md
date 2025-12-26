---
description: 프로젝트 분석 후 ESLint flat config 설정. Sequential Thinking 필수.
allowed-tools: Read, Write, Edit, Glob, Bash(npm:*, yarn:*, pnpm:*, npx:*, node:*), mcp__sequential-thinking__sequentialthinking
---

# Lint Init Command

프로젝트 구조를 분석하고 ESLint flat config를 설정하는 커맨드.

## CRITICAL: 필수 요구사항

| 요구사항 | 설명 |
|----------|------|
| **Sequential Thinking** | `mcp__sequential-thinking__sequentialthinking` 도구로 프로젝트 분석 |
| **Flat Config** | ESLint v9+ flat config (`eslint.config.js`) 사용 |
| **기존 설정 확인** | 기존 ESLint 설정 존재 시 사용자 확인 |

## 실행 흐름

```
1. Sequential Thinking으로 프로젝트 분석 시작 (최소 5단계)
2. 핵심 파일 수집:
   - package.json (의존성, 스크립트)
   - tsconfig.json (TypeScript 설정)
   - 기존 ESLint 설정 (.eslintrc.*, eslint.config.*)
3. 프로젝트 특성 파악:
   - 언어: TypeScript / JavaScript
   - 런타임: Node.js / Browser / 둘 다
   - 프레임워크: React, Vue, Next.js, Express 등
4. 적절한 ESLint 설정 생성
5. 필요 패키지 목록 제공
6. 설치 명령어 안내
```

## Sequential Thinking 단계

```
thought 1: package.json 분석 - 의존성에서 프레임워크/라이브러리 파악
thought 2: tsconfig.json 분석 - TypeScript 설정 확인
thought 3: 디렉토리 구조 분석 - src/, app/, pages/ 등 패턴 파악
thought 4: 기존 ESLint 설정 확인 - 마이그레이션 필요 여부 판단
thought 5: 최적 ESLint 설정 결정 - 감지된 특성에 맞는 규칙 선택
```

## 프로젝트 특성 감지

### 언어 감지

| 파일/설정 | 판단 |
|-----------|------|
| `tsconfig.json` 존재 | TypeScript |
| `devDependencies.typescript` | TypeScript |
| `*.ts`, `*.tsx` 파일 | TypeScript |
| 그 외 | JavaScript |

### 프레임워크 감지

| 의존성 | 프레임워크 |
|--------|-----------|
| `react`, `react-dom` | React |
| `next` | Next.js |
| `vue` | Vue |
| `@angular/core` | Angular |
| `express` | Express |
| `hono` | Hono |
| `fastify` | Fastify |

### 런타임 감지

| 조건 | 런타임 |
|------|--------|
| `express`, `fastify`, `hono` | Node.js |
| `react`, `vue`, `angular` | Browser |
| `next`, `nuxt` | 둘 다 |
| `package.json` type: "module" | ESM |

## ESLint Flat Config 템플릿

### TypeScript + Node.js

```javascript
import eslint from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';
import globals from 'globals';

export default [
  {
    ignores: ['dist/**', 'node_modules/**'],
  },
  eslint.configs.recommended,
  {
    files: ['src/**/*.ts'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.json',
      },
      globals: {
        ...globals.node,
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      '@typescript-eslint/explicit-function-return-type': 'warn',
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/consistent-type-imports': [
        'error',
        { prefer: 'type-imports' },
      ],
      'no-unused-vars': 'off',
      'no-undef': 'off',
      'prefer-const': 'error',
      'no-var': 'error',
      eqeqeq: ['error', 'always'],
    },
  },
];
```

### TypeScript + React

```javascript
import eslint from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';
import reactPlugin from 'eslint-plugin-react';
import reactHooksPlugin from 'eslint-plugin-react-hooks';
import globals from 'globals';

export default [
  {
    ignores: ['dist/**', 'node_modules/**', 'build/**'],
  },
  eslint.configs.recommended,
  {
    files: ['src/**/*.{ts,tsx}'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.json',
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        ...globals.browser,
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin,
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      ...reactPlugin.configs.recommended.rules,
      ...reactHooksPlugin.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      '@typescript-eslint/no-explicit-any': 'error',
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      'no-unused-vars': 'off',
      'no-undef': 'off',
    },
  },
];
```

### JavaScript + Node.js

```javascript
import eslint from '@eslint/js';
import globals from 'globals';

export default [
  {
    ignores: ['dist/**', 'node_modules/**'],
  },
  eslint.configs.recommended,
  {
    files: ['src/**/*.js'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node,
      },
    },
    rules: {
      'no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      'prefer-const': 'error',
      'no-var': 'error',
      eqeqeq: ['error', 'always'],
    },
  },
];
```

## 필요 패키지

### 기본 (모든 프로젝트)

```bash
npm install -D eslint @eslint/js globals
```

### TypeScript 추가

```bash
npm install -D @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

### React 추가

```bash
npm install -D eslint-plugin-react eslint-plugin-react-hooks
```

### Vue 추가

```bash
npm install -D eslint-plugin-vue vue-eslint-parser
```

## 기존 설정 처리

### .eslintrc.* 마이그레이션

기존 `.eslintrc.json`, `.eslintrc.js` 등 발견 시:
1. 사용자에게 마이그레이션 제안
2. 기존 규칙을 flat config 형식으로 변환
3. 기존 파일 백업 후 삭제

### package.json eslintConfig

`package.json` 내 `eslintConfig` 발견 시:
1. 해당 설정을 flat config로 변환
2. `package.json`에서 `eslintConfig` 제거

## package.json 스크립트

설정 완료 후 추가할 스크립트:

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  }
}
```

## 체크리스트

### 분석 단계

- [ ] package.json 읽기
- [ ] tsconfig.json 확인
- [ ] 기존 ESLint 설정 확인
- [ ] 디렉토리 구조 파악
- [ ] 소스 파일 패턴 확인

### 설정 단계

- [ ] 적절한 템플릿 선택
- [ ] ignores 패턴 설정
- [ ] 파일 패턴 (files) 설정
- [ ] globals 설정
- [ ] 규칙 커스터마이징

### 완료 단계

- [ ] eslint.config.js 생성
- [ ] 필요 패키지 목록 제공
- [ ] 설치 명령어 안내
- [ ] package.json 스크립트 추가 제안
- [ ] 테스트 실행 안내
