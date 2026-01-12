---
description: Analyze project and configure ESLint flat config
allowed-tools: Read, Write, Edit, Glob, Bash, mcp__sequential-thinking__sequentialthinking
---

@../instructions/sequential-thinking-guide.md

# Lint Init Command

Analyze project → automatically generate ESLint flat config.

<requirements>

| Category | Required |
|----------|----------|
| **Thinking** | Sequential 5-7 steps (@sequential-thinking-guide.md) |
| **Config** | ESLint v9+ flat config (`eslint.config.js`) |
| **Detection** | Auto-detect language/framework/runtime |

</requirements>

---

<workflow>

<step number="1">
<action>Start Sequential Thinking</action>
<detail>Analyze project structure, dependencies, existing config (5-7 steps)</detail>
</step>

<step number="2">
<action>Collect core files</action>
<tools>Read (package.json, tsconfig.json, existing ESLint config)</tools>
</step>

<step number="3">
<action>Detect project characteristics</action>
<detail>Language (TS/JS), runtime (Node/Browser), framework (React/Vue/etc.)</detail>
</step>

<step number="4">
<action>Generate ESLint config</action>
<deliverable>eslint.config.js</deliverable>
</step>

<step number="5">
<action>Guide package installation</action>
<detail>Required packages list + npm/yarn/pnpm commands</detail>
</step>

</workflow>

---

<detection>

## Project Characteristic Detection

### Language

| Condition | Judgment |
|-----------|----------|
| `tsconfig.json` exists | TypeScript |
| `devDependencies.typescript` | TypeScript |
| `src/**/*.{ts,tsx}` files | TypeScript |
| Otherwise | JavaScript |

### Framework

| Dependency | Framework | Additional Plugins |
|------------|-----------|-------------------|
| `react` | React | `eslint-plugin-react`, `eslint-plugin-react-hooks` |
| `next` | Next.js | React + Next.js rules |
| `vue` | Vue | `eslint-plugin-vue`, `vue-eslint-parser` |
| `express`, `hono`, `fastify` | Node.js server | - |

### Runtime

| Condition | globals |
|-----------|---------|
| `express`, `fastify`, `hono` | `globals.node` |
| `react`, `vue`, `angular` | `globals.browser` |
| `next`, `nuxt` | `globals.node` + `globals.browser` |

</detection>

---

<templates>

## ESLint Flat Config Patterns

### Basic structure (TypeScript + Node.js)

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

### When adding React

```javascript
// Add to basic structure above:
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
      // ... above rules +
      ...reactPlugin.configs.recommended.rules,
      ...reactHooksPlugin.configs.recommended.rules,
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
    },
  },
]
```

### JavaScript only

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

## Required packages

| Condition | Packages |
|-----------|----------|
| **Base** | `eslint @eslint/js globals` |
| **TypeScript** | Above + `@typescript-eslint/parser @typescript-eslint/eslint-plugin` |
| **React** | Above + `eslint-plugin-react eslint-plugin-react-hooks` |
| **Vue** | Above + `eslint-plugin-vue vue-eslint-parser` |

### Installation commands

```bash
# Base (JavaScript)
npm install -D eslint @eslint/js globals

# TypeScript
npm install -D eslint @eslint/js globals @typescript-eslint/parser @typescript-eslint/eslint-plugin

# TypeScript + React
npm install -D eslint @eslint/js globals @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-plugin-react eslint-plugin-react-hooks
```

</packages>

---

<migration>

## Handle existing configuration

| File | Action |
|------|--------|
| `.eslintrc.{json,js,yml}` | Convert to flat config → backup and remove |
| `package.json` `eslintConfig` | Convert to flat config → remove from `package.json` |

**Conversion method:**
1. Extract existing `rules`, `extends`, `plugins`
2. Convert to flat config format
3. Backup original (`.eslintrc.backup`)
4. Create `eslint.config.js`

</migration>

---

<scripts>

## package.json scripts

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  }
}
```

Suggest automatic addition after configuration complete.

</scripts>

---

<validation>

## Validation steps

```bash
# 1. Verify config syntax
npx eslint --print-config src/index.ts

# 2. Run lint
npm run lint

# 3. Test auto fix
npm run lint:fix
```

</validation>
