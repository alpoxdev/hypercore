# Prettier 설정

> 코드 포맷팅 표준화

---

## 🚀 Quick Reference

### .prettierrc (복사용)

```json
{
  "semi": true,
  "singleQuote": true,
  "jsxSingleQuote": true,
  "tabWidth": 2,
  "trailingComma": "all",
  "printWidth": 80,
  "arrowParens": "always",
  "endOfLine": "lf",
  "importOrder": [
    "^react$",
    "^react-dom$",
    "^@tanstack/(.*)$",
    "<THIRD_PARTY_MODULES>",
    "^@/(.*)$",
    "^[./]"
  ],
  "importOrderSeparation": true,
  "importOrderSortSpecifiers": true,
  "plugins": [
    "@trivago/prettier-plugin-sort-imports",
    "prettier-plugin-tailwindcss"
  ]
}
```

---

## 설치

```bash
yarn add -D prettier @trivago/prettier-plugin-sort-imports prettier-plugin-tailwindcss
```

---

## 설정 옵션 설명

### 기본 포맷팅

| 옵션 | 값 | 설명 |
|------|-----|------|
| `semi` | `true` | 세미콜론 사용 |
| `singleQuote` | `true` | 문자열에 작은따옴표 |
| `jsxSingleQuote` | `true` | JSX에서도 작은따옴표 |
| `tabWidth` | `2` | 들여쓰기 2칸 |
| `trailingComma` | `"all"` | 모든 곳에 trailing comma |
| `printWidth` | `80` | 줄 너비 80자 |
| `arrowParens` | `"always"` | 화살표 함수 괄호 항상 사용 |
| `endOfLine` | `"lf"` | Unix 줄바꿈 (LF) |

### Import 정렬

| 옵션 | 설명 |
|------|------|
| `importOrder` | import 순서 규칙 |
| `importOrderSeparation` | 그룹 간 빈 줄 추가 |
| `importOrderSortSpecifiers` | import 내 알파벳 정렬 |

### Import 순서 규칙

```
1. react, react-dom
2. @tanstack/* (TanStack 라이브러리)
3. <THIRD_PARTY_MODULES> (기타 외부 모듈)
4. @/* (내부 모듈)
5. ./* (상대 경로)
```

---

## 플러그인

### @trivago/prettier-plugin-sort-imports

import 문 자동 정렬

```typescript
// Before
import { useState } from 'react';
import { Button } from '@/components/ui';
import { useQuery } from '@tanstack/react-query';
import axios from 'axios';

// After
import { useState } from 'react';

import { useQuery } from '@tanstack/react-query';

import axios from 'axios';

import { Button } from '@/components/ui';
```

### prettier-plugin-tailwindcss

Tailwind 클래스 자동 정렬

```tsx
// Before
<div className="p-4 flex text-white bg-blue-500 items-center">

// After
<div className="flex items-center bg-blue-500 p-4 text-white">
```

---

## 스크립트

### package.json

```json
{
  "scripts": {
    "format": "prettier --write .",
    "format:check": "prettier --check ."
  }
}
```

### 사용

```bash
# 전체 포맷팅
yarn format

# 포맷팅 검사만
yarn format:check
```

---

## .prettierignore

```
node_modules/
.output/
dist/
build/
.next/
coverage/
*.min.js
*.min.css
*.md
pnpm-lock.yaml
yarn.lock
package-lock.json
generated/
```

**주의**: `*.md` 파일은 Prettier 포맷팅에서 제외 (테이블 등이 이상하게 변형됨)

---

## VSCode 설정

### .vscode/settings.json

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "never"
  }
}
```

**주의**: `source.organizeImports`는 `"never"`로 설정 (Prettier 플러그인과 충돌 방지)

---

## 참고

- [Prettier 공식 문서](https://prettier.io/docs/en/index.html)
- [@trivago/prettier-plugin-sort-imports](https://github.com/trivago/prettier-plugin-sort-imports)
- [prettier-plugin-tailwindcss](https://github.com/tailwindlabs/prettier-plugin-tailwindcss)
