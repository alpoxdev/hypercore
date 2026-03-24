# 라우트 구조

> Hono route composition 규칙

---

## 권장 구조

```text
src/
├── app.ts
├── index.ts
├── routes/
│   ├── index.ts
│   ├── health.ts
│   └── users/
│       ├── index.ts
│       ├── handlers.ts
│       ├── schemas.ts
│       └── service.ts
```

## 규칙

- `app.ts`가 루트 app composition을 소유
- `routes/index.ts` 또는 `app.ts`가 mount table의 단일 진입점
- `app.route('/users', usersApp)` 같은 sub-app mount를 우선
- 기능이 두 파일 이상이면 route folder 사용
- health 같은 작은 운영 endpoint만 single-file route 허용

## 마운트 패턴

```ts
import { createApp } from '@/lib/create-app'
import { healthApp } from '@/routes/health'
import { usersApp } from '@/routes/users'

export const app = createApp()
  .route('/health', healthApp)
  .route('/users', usersApp)
```

## 리뷰 체크리스트

- composition 진입점이 하나로 명확함
- route mount 순서가 의도적임
- fallback route가 마지막에 위치
- 큰 기능은 flat giant file 대신 sub-app folder 사용

