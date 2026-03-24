# 플랫폼 설정

> Vite + TanStack Router 프로젝트에서 아키텍처 리뷰가 강제해야 하는 설정 규칙

---

## Vite Plugin 규칙

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackRouter } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [
    tanstackRouter(),
    react(),
  ],
})
```

- `tanstackRouter()`는 명시적으로 유지합니다
- `tanstackRouter()`는 `react()`보다 먼저 등록합니다
- router plugin을 중복 추가하지 않습니다

---

## Generated File

- `routeTree.gen.ts`는 generated output입니다
- 수동 편집하지 않습니다
- 라우팅 결과가 이상하면 source route 또는 router config를 수정한 뒤 재생성합니다

---

## Router 설정

- router wiring은 `src/router.tsx`에서 명시적으로 유지합니다
- root context 설정은 router/root-route 파일에서 쉽게 찾을 수 있어야 합니다
- 저장소가 SSR 또는 manual rendering을 추가하면 process-global singleton보다 fresh router factory를 선호합니다

---

## Route Token 과 Layout 규칙

- TanStack Router는 `route.tsx`, `posts.route.tsx` 등 `routeToken` 기반 레이아웃을 지원합니다
- hypercore는 shared layout, `beforeLoad`, shared loader 동작에 대해 folder route + `route.tsx`를 선호합니다
- 저장소가 `routeToken` 또는 `indexToken`을 커스텀했다면 `tsr.config.json`에 명시적으로 기록합니다

---

## Env 와 Alias 규칙

- 공개 가능한 클라이언트 설정은 `import.meta.env.VITE_*`를 사용합니다
- secret 값은 클라이언트에서 도달 가능한 route 코드에 두지 않습니다
- path alias는 Vite config와 TypeScript config 양쪽에서 명시적으로 유지합니다
- 중간 이상 규모 앱이면 env typing/runtime validation을 명시적으로 둡니다

---

## 리뷰 체크리스트

- `vite.config.ts`가 `tanstackRouter()`를 `react()`보다 앞에 유지함
- `routeTree.gen.ts`가 수동 편집되지 않음
- router 설정이 ad-hoc global 뒤에 숨어 있지 않음
- `tsr.config.json`이 있다면 `routeToken`/`indexToken` 커스터마이징이 문서화되어 있음
- env와 alias 설정이 명시적임
