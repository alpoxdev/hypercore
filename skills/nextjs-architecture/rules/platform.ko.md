# Platform and Environment

> `next.config.*`, env handling, route segment config, Proxy, deployment-sensitive setup.

---

## Environment Variables

- `.env*` files는 `src/` 내부가 아니라 project root에 둡니다.
- Non-`NEXT_PUBLIC_` env vars는 server-only입니다.
- `NEXT_PUBLIC_` values는 build time에 browser bundles로 inline됩니다.
- client에 runtime values가 필요하면 runtime-public env var처럼 가장하지 말고 server path를 통해 노출합니다.
- Next runtime 밖 code가 env loading이 필요하면 `@next/env`를 사용합니다.

## Runtime Env Rule

Server code는 dynamic rendering 중 runtime env values를 읽을 수 있습니다. runtime server env와 build-time inlined client env를 혼동하지 않습니다.

## Cache Components and Route Segment Config

- `cacheComponents: true`는 Next.js 16+ Cache Components, PPR, `useCache`, `dynamicIO` behavior용 unified switch입니다.
- `cacheComponents`가 활성화되면 v16에서 `dynamic`, `revalidate`, `fetchCache` route segment options가 제거됩니다. 대신 Cache Components model을 사용합니다.
- 현재 route segment options에는 `dynamicParams`, `runtime`, `preferredRegion`, `maxDuration`이 포함되며 Server Component pages, layouts, Route Handlers에 영향을 줍니다.
- `runtime` 기본값은 `'nodejs'`입니다. `runtime: 'edge'`는 사용하는 libraries와 APIs에 대해 검증해야 하는 deployment/platform decision입니다.
- Deployment platforms는 `maxDuration`을 사용할 수 있으므로 execution limits를 바꾸는 변경은 문서화합니다.

## Proxy

- `proxy.ts`는 `app` 또는 `pages`와 같은 level인 project root 또는 `src/` root에 둡니다.
- Proxy는 routes render 전에 실행되며 app render code 앞의 network boundary입니다.
- Proxy보다 먼저 `redirects`, `rewrites`, headers, cookies, render-time logic을 검토합니다.
- Proxy에는 explicit matcher와 narrow scope가 있어야 합니다. matcher가 없으면 `_next/static`, `_next/image`, public assets를 포함한 모든 request에서 실행됩니다.
- Matcher values는 Next.js가 build time에 분석할 수 있도록 static constants여야 합니다.
- Proxy 안에서 shared modules 또는 globals에 의존하지 않습니다.
- broad matcher에서는 API routes, metadata, static surfaces, image optimization, public assets가 Proxy를 우회해야 하는지 확인합니다.
- Server Functions는 사용된 route로 가는 POST requests입니다. matcher 변경은 Proxy coverage를 조용히 제거할 수 있으므로 auth/authz는 Server Function 또는 DAL 안에도 있어야 합니다.

## Important Proxy Note

기존 `middleware` file convention은 deprecated이며 `proxy`로 renamed되었습니다. 새 작업에서 `middleware.ts`를 추가하지 않습니다. migration이 필요하면 official `npx @next/codemod@canary middleware-to-proxy .` codemod를 사용합니다. Proxy는 Node.js runtime이 기본이고 `runtime` config option을 받지 않습니다.

## `next.config.*`

Config changes는 명시적이고 의도적이어야 합니다. 다음 변경은 특히 검토합니다:

- `typedRoutes`
- `serverActions.allowedOrigins`
- `cacheComponents`, `cacheLife`, `cacheHandlers`, experimental `authInterrupts`
- route segment config strategy, 특히 `cacheComponents` 하위의 v16 removed options
- redirect and rewrite rules
- output and deployment settings

## Recommended Platform Checks

- route-safety가 중요한 TypeScript App Router projects에서는 `typedRoutes: true`를 고려합니다.
- multi-proxy 또는 reverse-proxy deployments에서는 Server Action origin configuration 필요성을 확인합니다.
- deployment-sensitive settings는 PR 또는 final report에 문서화합니다.

## Review Checklist

- `.env*` handling이 Next.js behavior와 일치
- Client code가 `NEXT_PUBLIC_` env vars만 봄
- Cache Components와 removed v16 route segment config options가 우발적으로 섞이지 않음
- Proxy가 진짜 필요하고 statically matched이며 scope가 좁음
- `next.config.*` changes가 의도적이고 설명됨
