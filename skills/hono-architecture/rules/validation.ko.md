# Validation

> Hono 요청 검증 규칙

---

## 핵심 규칙

서비스 로직이 요청 데이터를 소비하기 전에 먼저 검증합니다.

## 허용 옵션

- 좁은 범위 검증에는 `validator()`
- 저장소가 Zod를 쓰면 `@hono/zod-validator`
- 저장소가 Standard Schema 계열을 표준화했다면 `@hono/standard-validator`

## 예시

```ts
import { z } from 'zod'
import { zValidator } from '@hono/zod-validator'

const createUserSchema = z.object({
  email: z.email(),
  name: z.string().min(1),
})

const app = new Hono().post(
  '/',
  zValidator('json', createUserSchema),
  async (c) => {
    const payload = c.req.valid('json')
    return c.json({ payload }, 201)
  }
)
```

## 리뷰 체크리스트

- params/query/json/form이 의미 있는 경우 validator middleware 사용
- validation이 domain logic보다 먼저 실행
- 한 기능 안에서 이유 없이 validation 스타일을 섞지 않음
- 필요 없는 새 dependency 추가 금지

