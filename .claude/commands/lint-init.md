---
description: 프로젝트 분석 후 ESLint flat config 설정
allowed-tools: Read, Write, Edit, Glob, Bash, mcp__sequential-thinking__sequentialthinking
---

@../instructions/sequential-thinking-guide.md

# Lint Init Command

프로젝트 분석 → ESLint flat config 자동 생성.

<requirements>

| 분류 | 필수 |
|------|------|
| **Thinking** | Sequential 5-7단계 (@sequential-thinking-guide.md) |
| **Config** | ESLint v9+ flat config (`eslint.config.js`) |
| **Detection** | 언어/프레임워크/런타임 자동 감지 |

</requirements>

---

<workflow>

<step number="1">
<action>Sequential Thinking 시작</action>
<detail>프로젝트 구조, 의존성, 기존 설정 분석 (5-7단계)</detail>
</step>

<step number="2">
<action>핵심 파일 수집</action>
<tools>Read (package.json, tsconfig.json, 기존 ESLint 설정)</tools>
</step>

<step number="3">
<action>프로젝트 특성 감지</action>
<detail>언어(TS/JS), 런타임(Node/Browser), 프레임워크(React/Vue/등)</detail>
</step>

<step number="4">
<action>ESLint 설정 생성</action>
<deliverable>eslint.config.js</deliverable>
</step>

<step number="5">
<action>패키지 설치 안내</action>
<detail>필요 패키지 목록 + npm/yarn/pnpm 명령어</detail>
</step>

</workflow>

---

<detection>

## 프로젝트 특성 감지

### 언어

| 조건 | 판단 |
|------|------|
| `tsconfig.json` 존재 | TypeScript |
| `devDependencies.typescript` | TypeScript |
| `src/**/*.{ts,tsx}` 파일 | TypeScript |
| 그 외 | JavaScript |

### 프레임워크

| 의존성 | 프레임워크 | 추가 플러그인 |
|--------|-----------|-------------|
| `react` | React | `eslint-plugin-react`, `eslint-plugin-react-hooks` |
| `next` | Next.js | React + Next.js 규칙 |
| `vue` | Vue | `eslint-plugin-vue`, `vue-eslint-parser` |
| `express`, `hono`, `fastify` | Node.js 서버 | - |

### 런타임

| 조건 | globals |
|------|---------|
| `express`, `fastify`, `hono` | `globals.node` |
| `react`, `vue`, `angular` | `globals.browser` |
| `next`, `nuxt` | `globals.node` + `globals.browser` |

</detection>

---

<templates>

## ESLint Flat Config 패턴

### 기본 구조 (TypeScript + Node.js)

```javascript
import eslint from '@eslint/js'
import tseslint from '@typescript-eslint/eslint-plugin'
import tsparser from '@typescript-eslint/parser'
import globals from 'globals'

export default [
  {
    ignores: ['dist/**', 'node_modules/**', 'build/**'],
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
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
    },
  },
]
```

### React 추가 시

```javascript
// 위 기본 구조에 추가:
import reactPlugin from 'eslint-plugin-react'
import reactHooksPlugin from 'eslint-plugin-react-hooks'

export default [
  // ...
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: {
      '@typescript-eslint': tseslint,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin,
    },
    settings: {
      react: { version: 'detect' },
    },
    rules: {
      // ... 위 rules +
      ...reactPlugin.configs.recommended.rules,
      ...reactHooksPlugin.configs.recommended.rules,
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
    },
  },
]
```

### JavaScript Only

```javascript
import eslint from '@eslint/js'
import globals from 'globals'

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
      globals: { ...globals.node },
    },
    rules: {
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'prefer-const': 'error',
      'no-var': 'error',
    },
  },
]
```

</templates>

---

<packages>

## 필요 패키지

| 조건 | 패키지 |
|------|--------|
| **기본** | `eslint @eslint/js globals` |
| **TypeScript** | 위 + `@typescript-eslint/parser @typescript-eslint/eslint-plugin` |
| **React** | 위 + `eslint-plugin-react eslint-plugin-react-hooks` |
| **Vue** | 위 + `eslint-plugin-vue vue-eslint-parser` |

### 설치 명령어

```bash
# 기본 (JavaScript)
npm install -D eslint @eslint/js globals

# TypeScript
npm install -D eslint @eslint/js globals @typescript-eslint/parser @typescript-eslint/eslint-plugin

# TypeScript + React
npm install -D eslint @eslint/js globals @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-plugin-react eslint-plugin-react-hooks
```

</packages>

---

<migration>

## 기존 설정 처리

| 파일 | 처리 |
|------|------|
| `.eslintrc.{json,js,yml}` | flat config 변환 → 백업 후 제거 |
| `package.json` `eslintConfig` | flat config 변환 → `package.json`에서 제거 |

**변환 방법:**
1. 기존 `rules`, `extends`, `plugins` 추출
2. flat config 형식으로 변환
3. 원본 백업 (`.eslintrc.backup`)
4. `eslint.config.js` 생성

</migration>

---

<scripts>

## package.json 스크립트

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  }
}
```

설정 완료 후 자동 추가 제안.

</scripts>

---

<parallel_agent_execution>

## 병렬 Agent 실행

### Recommended Agents

| Agent | Model | 역할 |
|-------|-------|------|
| **@implementation-executor** | sonnet | ESLint 설정 구현 |
| **@explore** | haiku | 프로젝트 구조 탐색 |
| **@analyst** | sonnet | 프로젝트 패턴 분석 |

### Parallel Execution Patterns

| 패턴 | 병렬 작업 | 효과 |
|------|-----------|------|
| **탐색 + 분석** | explore (haiku) + analyst (sonnet) | 프로젝트 이해 속도 향상 |
| **설정 + 문서** | implementation-executor + document-writer | 구현과 문서화 동시 진행 |

### Model Routing

| 복잡도 | 모델 | 조건 |
|--------|------|------|
| **LOW** | haiku / sonnet | 기본 JS/TS 프로젝트, 단일 프레임워크 |
| **MEDIUM** | sonnet | 커스텀 룰 설정, 여러 프레임워크 혼재 |
| **HIGH** | opus | 복잡한 모노레포, 레거시 마이그레이션 |

### Practical Examples

```typescript
// ✅ 탐색 + 분석 병렬
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 파일 구조 파악 (package.json, tsconfig.json, src/)")

Task(subagent_type="analyst", model="sonnet",
     prompt="코드 패턴 및 스타일 분석 (import 방식, 파일명 컨벤션)")

// ✅ 설정 + 문서 병렬
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="ESLint flat config 생성 (TypeScript + React)")

Task(subagent_type="document-writer", model="haiku",
     prompt="린트 설정 가이드 작성 (패키지 설치 명령어, 사용법)")

// ✅ 복잡한 마이그레이션
Task(subagent_type="implementation-executor", model="opus",
     prompt=".eslintrc.json → flat config 변환 (커스텀 룰 200+ 보존)")
```

</parallel_agent_execution>

---

<validation>

## 검증 단계

```bash
# 1. 설정 문법 확인
npx eslint --print-config src/index.ts

# 2. Lint 실행
npm run lint

# 3. 자동 수정 테스트
npm run lint:fix
```

</validation>
