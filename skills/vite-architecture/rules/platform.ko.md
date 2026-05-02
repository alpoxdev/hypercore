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
    // tanstackRouter()는 반드시 react() 보다 앞에 위치합니다
    tanstackRouter({
      target: 'react',
      autoCodeSplitting: true,
    }),
    react(),
  ],
})
```

- `tanstackRouter()`는 명시적으로 유지하고 `target: 'react'`를 전달합니다
- `autoCodeSplitting: true`를 켜야 plugin이 route component를 자동 코드 스플릿합니다
- `tanstackRouter()`는 `react()`보다 먼저 등록합니다 (순서가 잘못되면 조용히 실패)
- router plugin을 중복 추가하지 않습니다
- file-convention 옵션 중 hypercore 폴더와 직결되는 것: `routeFileIgnorePrefix` 기본값이 `'-'`이라서 `-components/`, `-hooks/`가 route tree에서 제외됨; `routeToken`/`indexToken`을 커스텀하려면 `tsr.config.json`에 명시

---

## Generated File

- `routeTree.gen.ts`는 generated output입니다
- 수동 편집하지 않습니다
- 라우팅 결과가 이상하면 source route 또는 router config를 수정한 뒤 재생성합니다

`tsr.config.json`을 두는 저장소는 다음 키를 명시해서 plugin과 CLI가 같은 위치를 보도록 유지합니다:

```json
{
  "routesDirectory": "./src/routes",
  "generatedRouteTree": "./src/routeTree.gen.ts"
}
```

`routeToken`, `indexToken`, `routeFilePrefix`, `routeFileIgnorePrefix`는 저장소가 실제로 커스텀할 때만 추가하고 그렇지 않으면 문서화된 기본값에 의존합니다.

---

## Router 설정

- router wiring은 `src/router.tsx`에서 명시적으로 유지합니다
- root context 설정은 router/root-route 파일에서 쉽게 찾을 수 있어야 합니다
- 저장소가 SSR 또는 manual rendering을 추가하면 process-global singleton보다 per-request fresh router factory를 선호합니다 (module-level QueryClient는 SSR 요청 간 데이터 leak)
- 표준 `createRouter` 옵션: `defaultPreload: 'intent'`, `defaultPreloadStaleTime: 0`, `scrollRestoration: true`를 명시하고, `Wrap`으로 `QueryClientProvider`를 마운트합니다

```tsx
// src/router.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

export const createAppRouter = () => {
  // 요청마다 새 QueryClient — SSR 데이터 leak 방지
  const queryClient = new QueryClient()

  return createRouter({
    routeTree,
    context: { queryClient },
    defaultPreload: 'intent',
    defaultPreloadStaleTime: 0,
    scrollRestoration: true,
    Wrap: ({ children }) => (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    ),
  })
}

declare module '@tanstack/react-router' {
  interface Register {
    router: ReturnType<typeof createAppRouter>
  }
}
```

- root route는 `createRootRouteWithContext<{ queryClient: QueryClient }>()` 팩토리 패턴을 써서 nested route까지 context 타입을 유지합니다
- SSR 스트리밍 + TanStack Query를 쓸 때는 같은 factory 안에서 `@tanstack/react-router-ssr-query`의 `setupRouterSsrQueryIntegration({ router, queryClient })`를 연결합니다

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
