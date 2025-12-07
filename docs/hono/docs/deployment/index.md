# Nitro v3 배포 가이드

> **Version**: Nitro 3.x | Hono 프레임워크 배포

@docker.md
@railway.md
@vercel.md
@cloudflare.md

---

## 🚀 Quick Reference (복사용)

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  // 플랫폼별 preset 선택
  preset: "node" | "cloudflare_module" | "cloudflare_pages" | "vercel",

  // 기본 설정
  compatibilityDate: "2024-09-19",

  // Hono 앱 엔트리포인트
  renderer: "hono",
});
```

### CLI 명령어

```bash
# 빌드
npx nitro build

# 개발 서버
npx nitro dev

# 프리뷰 (빌드 후 로컬 실행)
npx nitro preview
```

---

## 문서 구조

| 플랫폼 | 문서 | 특징 |
|--------|------|------|
| [Docker](./docker.md) | 컨테이너 배포 | 유연한 인프라, CI/CD 통합 |
| [Railway](./railway.md) | PaaS 배포 | 간편한 배포, 자동 스케일링 |
| [Vercel](./vercel.md) | 서버리스 배포 | Edge Functions, ISR 지원 |
| [Cloudflare](./cloudflare.md) | Edge 배포 | 글로벌 분산, D1/KV 통합 |

---

## Nitro 설치 및 설정

### 1. 의존성 설치

```bash
# npm
npm install nitro@3

# yarn
yarn add nitro@3
```

### 2. 기본 설정 파일

```typescript
// nitro.config.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Nitro v3 기본 설정
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  // 호환성 날짜 (필수)
  compatibilityDate: "2024-09-19",

  // 소스 디렉토리
  srcDir: "src",

  // 빌드 출력 디렉토리
  output: {
    dir: ".output",
  },
});
```

### 3. Hono 앱 엔트리포인트

```typescript
// src/server.ts
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Hono 앱 메인 엔트리포인트
// Nitro에서 이 파일을 서버로 사용합니다
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import { Hono } from "hono";
import { logger } from "hono/logger";
import { cors } from "hono/cors";

// Hono 앱 생성
const app = new Hono();

// 미들웨어
app.use("*", logger());
app.use("*", cors());

// 라우트
app.get("/", (c) => {
  return c.json({ message: "Hello from Hono + Nitro!" });
});

app.get("/health", (c) => {
  return c.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Nitro export
export default app;
```

---

## 프로젝트 구조

```
프로젝트/
├── nitro.config.ts          # Nitro 설정
├── src/
│   ├── server.ts            # Hono 앱 엔트리포인트
│   ├── routes/              # API 라우트
│   │   ├── users.ts
│   │   └── posts.ts
│   ├── middleware/          # 커스텀 미들웨어
│   └── lib/                 # 유틸리티
├── .output/                 # 빌드 결과물 (자동 생성)
├── package.json
└── tsconfig.json
```

---

## 환경 변수 설정

### .env 파일

```env
# .env
DATABASE_URL=postgresql://localhost:5432/mydb
API_SECRET=your-secret-key
NODE_ENV=development
```

### Nitro에서 환경 변수 접근

```typescript
// src/server.ts
import { Hono } from "hono";

const app = new Hono();

app.get("/config", (c) => {
  // process.env로 접근
  const dbUrl = process.env.DATABASE_URL;
  const nodeEnv = process.env.NODE_ENV;

  return c.json({
    environment: nodeEnv,
    hasDbConnection: !!dbUrl
  });
});

export default app;
```

### 런타임 설정 (nitro.config.ts)

```typescript
// nitro.config.ts
import { defineNitroConfig } from "nitro/config";

export default defineNitroConfig({
  compatibilityDate: "2024-09-19",

  // 런타임 환경 변수
  runtimeConfig: {
    // 서버 전용 (노출 안됨)
    apiSecret: process.env.API_SECRET,

    // 공개 설정
    public: {
      apiBase: process.env.API_BASE_URL || "/api",
    },
  },
});
```

---

## 빌드 및 실행

### 개발 모드

```bash
# 개발 서버 실행 (Hot Reload)
npx nitro dev

# 포트 지정
npx nitro dev --port 3001
```

### 프로덕션 빌드

```bash
# 빌드
npx nitro build

# 빌드 결과물 실행
node .output/server/index.mjs
```

### 로컬 프리뷰

```bash
# 빌드 후 프로덕션 모드로 로컬 실행
npx nitro preview
```

---

## Preset 선택 가이드

| Preset | 용도 | 장점 |
|--------|------|------|
| `node` | Node.js 서버 | 범용, Docker 호환 |
| `cloudflare_module` | Cloudflare Workers | Edge 배포, 낮은 지연시간 |
| `cloudflare_pages` | Cloudflare Pages | 정적 + 서버리스 |
| `vercel` | Vercel Functions | 간편한 배포, ISR |
| `netlify` | Netlify Functions | JAMstack 친화적 |
| `deno` | Deno Deploy | Deno 런타임 |
| `bun` | Bun 런타임 | 빠른 실행 속도 |

---

## 다음 단계

플랫폼별 상세 배포 가이드:

1. **[Docker 배포](./docker.md)** - 컨테이너 기반 배포
2. **[Railway 배포](./railway.md)** - PaaS 간편 배포
3. **[Vercel 배포](./vercel.md)** - 서버리스 배포
4. **[Cloudflare 배포](./cloudflare.md)** - Edge 배포

---

## 참고 자료

- [Nitro 공식 문서](https://nitro.build)
- [Hono 공식 문서](https://hono.dev)
- [Nitro GitHub](https://github.com/nitrojs/nitro)
