# 배포 (Deployment)

> **Framework**: TanStack Start + Nitro
> **Source**: [Nitro Deployment](https://nitro.build/deploy), [TanStack Start Hosting](https://tanstack.com/start/latest/docs/framework/react/hosting)

TanStack Start는 Nitro를 배포 레이어로 사용하여 다양한 플랫폼에 배포할 수 있습니다.

## 문서 구조

- [Nitro 설정](./nitro.md) - Nitro 배포 레이어 기본 설정
- [Vercel](./vercel.md) - Vercel 배포 가이드
- [Cloudflare](./cloudflare.md) - Cloudflare Workers/Pages 배포
- [Railway](./railway.md) - Railway 배포 가이드

## 배포 옵션 비교

| 플랫폼 | Preset | Edge 지원 | 특징 |
|--------|--------|-----------|------|
| Vercel | `vercel` | ✅ | ISR, 자동 배포, Bun 런타임 |
| Cloudflare Pages | `cloudflare_pages` | ✅ | 글로벌 CDN, Workers 통합 |
| Cloudflare Workers | `cloudflare_module` | ✅ | 서버리스 컴퓨팅, KV 스토리지 |
| Railway | `node-server` | ❌ | Docker 지원, 간편한 설정 |

## 빠른 시작

### 1. Nitro 플러그인 설치

```bash
yarn add nitro
```

### 2. Vite 설정

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import { nitro } from 'nitro/vite'

export default defineConfig({
  plugins: [
    tanstackStart(),
    nitro(),
    react(),
  ],
})
```

### 3. Nitro 설정

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel', // 또는 cloudflare_pages, node-server 등
  // Nitro v3 필수: Cloudflare Static Assets 지원을 위해 2024-09-19 이상 필요
  compatibilityDate: '2024-09-19',
})
```

### 4. 빌드 및 배포

```bash
# 빌드
yarn build

# 또는 환경변수로 preset 지정
NITRO_PRESET=vercel yarn build
```

## Preset 선택 가이드

### Edge 런타임이 필요한 경우
- **Vercel**: `vercel` (Edge Functions 자동 지원)
- **Cloudflare**: `cloudflare_pages` 또는 `cloudflare_module`

### Node.js 서버가 필요한 경우
- **Railway**: `node-server`
- **기타 Node.js 호스팅**: `node-server`

### 정적 사이트 생성 (SSG)
- **정적 호스팅**: `static`

## 환경변수

모든 플랫폼에서 공통으로 사용하는 환경변수:

```bash
# 빌드 시 preset 지정
NITRO_PRESET=vercel

# 런타임 환경변수
DATABASE_URL=postgresql://...
API_SECRET=your-secret-key
```

## 참고 자료

- [Nitro 공식 문서](https://nitro.build)
- [TanStack Start Hosting](https://tanstack.com/start/latest/docs/framework/react/hosting)
