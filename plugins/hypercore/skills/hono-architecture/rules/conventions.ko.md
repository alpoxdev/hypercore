# 코드 컨벤션

> Hono 프로젝트 코딩 규칙

---

## 파일 이름

> camelCase 파일명은 금지. 모든 파일명은 kebab-case 유지.

| 타입 | 규칙 | 예시 |
|------|------|------|
| 일반 파일 | kebab-case | `create-app.ts`, `request-id.ts` |
| 라우트 폴더 | kebab-case | `routes/user-profile/` |
| 핸들러 파일 | kebab-case | `handlers.ts`, `list-users.ts` |
| 스키마 파일 | kebab-case | `schemas.ts`, `user-payload.ts` |
| 미들웨어 | kebab-case | `auth.ts`, `request-id.ts` |

---

## TypeScript 규칙

| 규칙 | 설명 | 예시 |
|------|------|------|
| 함수 스타일 | const 화살표 함수, 명시적 반환 타입 | `const handler = (c: Context): Response => {}` |
| no any | `unknown` 또는 구체 타입 사용 | `const payload: unknown = await c.req.json()` |
| type import | type import 분리 | `import type { Context } from 'hono'` |
| app generics | 쓰는 경우 `Bindings`, `Variables` 타입 명시 | `new Hono<AppEnv>()` |

---

## Import 순서

```ts
import { Hono } from 'hono'
import { createFactory } from 'hono/factory'
import { zValidator } from '@hono/zod-validator'

import { createApp } from '@/lib/create-app'
import { authMiddleware } from '@/middlewares/auth'
import { createUser } from '@/services/users/create-user'

import { userSchema } from './schemas'

import type { AppEnv } from '@/lib/types'
```

---

## 주석 스타일

- 코드 묶음에 방향 설명이 필요할 때만 짧은 블록 주석 사용
- line-by-line 설명 금지
- 주석은 아키텍처 의도 중심으로 유지

