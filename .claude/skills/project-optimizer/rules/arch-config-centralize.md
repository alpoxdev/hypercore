---
title: Centralize Configuration and Environment Variables
impact: LOW-MEDIUM
impactDescription: Single source of truth, easier deployment management
tags: arch, config, env, centralize, validation
languages: all
related: [code-error-handling, dx-type-safety]
---

## 설정/환경변수 중앙 관리

코드 전체에 흩어진 `process.env`, `os.environ` 접근을 하나의 설정 모듈로 통합합니다.

**❌ 잘못된 예시 (분산된 환경변수 접근):**

```typescript
// file_a.ts
const dbUrl = process.env.DATABASE_URL!  // 누락 시 런타임 에러

// file_b.ts
const port = parseInt(process.env.PORT || '3000')  // 중복 파싱

// file_c.ts
if (process.env.NODE_ENV === 'production') { ... }
```

**✅ 올바른 예시 (중앙 관리):**

```typescript
// config.ts - 단일 설정 모듈
import { z } from 'zod'

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
})

export const config = envSchema.parse(process.env)
// 시작 시 검증, 누락/잘못된 값 즉시 감지
```

```python
# Python (pydantic-settings)
from pydantic_settings import BaseSettings

class Config(BaseSettings):
    database_url: str
    port: int = 3000
    debug: bool = False

config = Config()  # .env + 환경변수 자동 로드
```

```go
// Go (envconfig)
type Config struct {
    DatabaseURL string `envconfig:"DATABASE_URL" required:"true"`
    Port        int    `envconfig:"PORT" default:"3000"`
}

var cfg Config
envconfig.Process("", &cfg)
```

**원칙:** 환경변수는 애플리케이션 시작 시 한 번 파싱/검증하고, 이후 타입 안전한 config 객체로 접근.
