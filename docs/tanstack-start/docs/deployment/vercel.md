# Vercel 배포

## Quick Reference

```typescript
// nitro.config.ts
import { defineNitroConfig } from 'nitro/config'

export default defineNitroConfig({
  preset: 'vercel',
  compatibilityDate: '2024-09-19',
})
```

```json
// vercel.json
{
  "buildCommand": "yarn build",
  "outputDirectory": ".vercel/output"
}
```

```bash
vercel login && vercel
```

---

## Nitro 설정

```typescript
// Edge Functions
preset: 'vercel-edge'

// Bun 런타임
vercel: { functions: { runtime: 'bun@1' } }
```

---

## vercel.json

```json
{
  "buildCommand": "yarn build",
  "outputDirectory": ".vercel/output",
  "framework": null,
  "functions": {
    "api/**/*.ts": { "memory": 1024, "maxDuration": 30 }
  }
}
```

---

## 배포 방법

### GitHub 연동
1. Vercel 대시보드 → GitHub 저장소 연결
2. Build: `yarn build`, Output: `.vercel/output`

### CLI
```bash
npm install -g vercel
vercel login
vercel        # 프리뷰
vercel --prod # 프로덕션
```

---

## ISR

```typescript
// nitro.config.ts
routeRules: {
  '/products/**': { isr: { expiration: 60 } },  // 60초 재검증
  '/api/user/**': { isr: false },                // 캐시 안함
}
```

---

## 환경변수

| 변수 | 설명 |
|------|------|
| `VERCEL` | Vercel 환경 ("1") |
| `VERCEL_ENV` | production/preview/development |
| `VERCEL_URL` | 배포 URL |

```bash
vercel env add DATABASE_URL
vercel env pull .env.local
```

---

## CI/CD

```yaml
# .github/workflows/vercel.yml
- uses: amondnet/vercel-action@v25
  with:
    vercel-token: ${{ secrets.VERCEL_TOKEN }}
    vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
    vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
    vercel-args: ${{ github.ref == 'refs/heads/main' && '--prod' || '' }}
```

---

## 최적화

```typescript
// Cold Start 최소화
minify: true
externals: ['sharp', 'prisma', '@prisma/client']
```

---

## 트러블슈팅

| 문제 | 해결 |
|------|------|
| Timeout | `maxDuration` 증가 |
| Edge 호환성 | Edge API로 변경 |
| 환경변수 누락 | 대시보드에서 설정 |

```bash
vercel dev      # 로컬 시뮬레이션
vercel logs     # 로그 확인
vercel inspect  # 함수 상태
```
