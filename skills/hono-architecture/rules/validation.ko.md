# Validation

> Hono 요청 검증 규칙

---

## Stable package 기준

2026-08-04 확인 기준으로 `@hono/zod-validator` 0.9.0은 Hono `>=4.11.2`와 Zod `^3.25.0 || ^4.0.0`을 지원하고, `@hono/standard-validator` 0.3.0은 Hono `>=4.11.2`와 Standard Schema `^1.0.0`을 지원합니다. API나 syntax를 적용하기 전에 installed lockfile을 조사합니다.

- Behavior에 영향을 주는 외부 제어 `param`, `query`, `header`, `cookie`, `json`, `form` 값을 모두 검증합니다.
- Validator output은 `c.req.valid(target)`으로만 소비하고 같은 body를 다시 parse하지 않습니다.
- Header schema key는 lowercase여야 합니다.
- JSON validation에는 적절한 `Content-Type`이 필요합니다. 누락/오류 content type과 malformed body를 test합니다.
- API surface마다 hook/error behavior를 하나로 정해 validation error가 안정적이고 민감정보 없는 envelope를 공유하게 합니다.
- Coercion/default는 의도적으로 사용합니다. Query/path input은 string에서 시작하며 예상하지 못한 domain semantics를 만들면 안 됩니다.
- 이 skill에 맞추기 위해 validation library를 새로 추가하거나 교체하지 않습니다.
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


## Sources

> 이 파일에는 외부 출처를 사용하지 않았습니다. 공식 Hono 동작은 `references/official/hono-docs.ko.md`에 위임합니다(last verified 2026-08-04). 저장소 로컬 링크 확인 2026-09-21.
