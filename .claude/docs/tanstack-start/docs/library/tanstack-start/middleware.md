# TanStack Start - Middleware

> Server Functions 및 라우트에 공통 로직 적용 (v1.159.4)

---

<overview>

## Middleware란?

Middleware는 Server Function 또는 라우트 핸들러 실행 전에 공통 로직을 처리하는 함수입니다.

| 용도 | 예시 |
|------|------|
| **인증** | 세션/토큰 검증 |
| **권한** | 역할 기반 접근 제어 |
| **검증** | 입력값 Zod 검증 |
| **로깅** | 요청/응답 로깅 |
| **CORS** | 교차 출처 요청 처리 |
| **CSP** | Content Security Policy 설정 |
| **Observability** | 메트릭, 트레이스, 로그 |
| **Context 제공** | 요청 객체에 데이터 첨부 |
| **에러 처리** | 일관된 에러 핸들링 |

</overview>

---

<middleware_types>

## 미들웨어 타입

TanStack Start는 두 가지 미들웨어 타입을 제공합니다:

| 타입 | 범위 | 메서드 | 입력 검증 | 클라이언트 로직 |
|------|------|--------|----------|----------------|
| **Request Middleware** | 모든 서버 요청 (SSR, Server Routes, Server Functions) | `.server()` | 없음 | 없음 |
| **Server Function Middleware** | Server Functions만 | `.client()`, `.server()` | `.inputValidator()` | 있음 |

> **참고:** Request Middleware는 Server Function Middleware에 의존할 수 없지만, Server Function Middleware는 Request Middleware에 의존할 수 있습니다.

### Request Middleware

모든 서버 요청 (SSR, Server Routes, Server Functions)에 적용됩니다.

```typescript
import { createMiddleware } from '@tanstack/react-start'

// 기본 (type 생략 시 'request'가 기본값)
const loggingMiddleware = createMiddleware().server(({ next }) => {
  console.log('Processing request')
  return next()
})

// 명시적 type 지정
const explicitRequestMiddleware = createMiddleware({ type: 'request' }).server(
  ({ next, context, request }) => {
    return next()
  },
)
```

**사용 가능한 메서드:**
- `middleware`: 체인에 다른 미들웨어 추가
- `server`: 서버 사이드 로직 정의

### Server Function Middleware

Server Functions 전용으로, 클라이언트/서버 양쪽에서 로직 실행이 가능합니다.

```typescript
const functionMiddleware = createMiddleware({ type: 'function' })
  .client(async ({ next, context }) => {
    console.log('Client: before RPC')
    const result = await next()
    console.log('Client: after RPC')
    return result
  })
  .server(async ({ next }) => {
    console.log('Server: executing')
    return next()
  })
```

**사용 가능한 메서드 (순서 중요 - TypeScript가 강제):**
1. `middleware`: 체인에 다른 미들웨어 추가
2. `inputValidator`: 데이터 검증
3. `client`: 클라이언트 사이드 로직 (RPC 호출 전후)
4. `server`: 서버 사이드 로직

</middleware_types>

---

<execution_flow>

## 실행 흐름

### Request Middleware 흐름

```
HTTP Request
  -> Middleware.server (next() 호출)
    -> ServerFn (payload 처리)
    <- result 반환
  <- return
HTTP Response
```

### Server Function Middleware 흐름

```
ServerFn (client) -> Middleware.client (payload)
  -> Middleware.client: next()
    -> Middleware.server (Request)
      -> Middleware.server: next()
        -> ServerFn (payload 처리)
        <- result 반환
      <- return
    <- Response
  <- return
ServerFn (client) <- result
```

</execution_flow>

---

<basic_pattern>

## 기본 미들웨어 패턴

```typescript
import { createMiddleware, createServerFn } from '@tanstack/react-start'

// 미들웨어 정의
const loggingMiddleware = createMiddleware({ type: 'function' })
  .server(({ next }) => {
    console.log('Processing request')
    return next()
  })

// Server Function에 적용
export const sayHello = createServerFn({ method: 'GET' })
  .middleware([loggingMiddleware])
  .handler(async (): Promise<{ message: string }> => {
    return { message: 'Hello' }
  })
```

### 미들웨어 조합 (Composition)

미들웨어는 다른 미들웨어에 의존할 수 있습니다.

```typescript
const loggingMiddleware = createMiddleware().server(() => {
  //...
})

const authMiddleware = createMiddleware()
  .middleware([loggingMiddleware])  // loggingMiddleware에 의존
  .server(() => {
    //...
  })
```

### next()로 체인 진행

모든 미들웨어는 `next()` 함수를 호출해야 다음 미들웨어가 실행됩니다:

```typescript
const loggingMiddleware = createMiddleware().server(async ({ next }) => {
  const result = await next()  // 다음 미들웨어 실행
  return result
})
```

</basic_pattern>

---

<context_management>

## Context 관리

### Context 전달 (next를 통해)

`next()` 호출 시 `context` 객체를 전달하면 하위 미들웨어에 데이터를 제공합니다.

```typescript
const awesomeMiddleware = createMiddleware({ type: 'function' }).server(
  ({ next }) => {
    return next({
      context: {
        isAwesome: Math.random() > 0.5,
      },
    })
  },
)

const loggingMiddleware = createMiddleware({ type: 'function' })
  .middleware([awesomeMiddleware])
  .server(async ({ next, context }) => {
    console.log('Is awesome?', context.isAwesome)  // 타입 안전
    return next()
  })
```

### Context 누적

미들웨어가 순차적으로 context를 누적합니다.

```typescript
const middleware1 = createMiddleware({ type: 'function' })
  .server(({ next }) => next({ context: { data1: 'value1' } }))

const middleware2 = createMiddleware({ type: 'function' })
  .server(({ next, context }) => next({
    context: { ...context, data2: 'value2' }
  }))

export const fn = createServerFn({ method: 'GET' })
  .middleware([middleware1, middleware2])
  .handler(async ({ context }): Promise<unknown> => {
    // context = { data1: 'value1', data2: 'value2' }
    return context
  })
```

</context_management>

---

<send_context>

## sendContext: 클라이언트-서버 간 컨텍스트 전송

### 클라이언트에서 서버로 (Client -> Server)

**클라이언트 컨텍스트는 기본적으로 서버로 전송되지 않습니다.** 대규모 페이로드가 의도치 않게 서버로 전송되는 것을 방지하기 위해서입니다. `sendContext`를 사용하면 명시적으로 데이터를 서버에 전송할 수 있습니다.

```typescript
import { createMiddleware } from '@tanstack/react-start'

const requestLogger = createMiddleware({ type: 'function' })
  .client(async ({ next, context }) => {
    return next({
      sendContext: {
        // 클라이언트의 workspaceId를 서버로 전송
        workspaceId: context.workspaceId,
      },
    })
  })
  .server(async ({ next, data, context }) => {
    // 서버에서 클라이언트가 보낸 workspaceId 접근 가능
    console.log('Workspace ID:', context.workspaceId)
    return next()
  })
```

#### sendContext 보안 주의사항

`sendContext`로 전달된 데이터는 타입 안전하지만, 런타임 검증이 자동으로 이루어지지 않습니다. **동적 사용자 데이터를 전송할 때는 반드시 서버에서 검증해야 합니다.**

```typescript
import { createMiddleware } from '@tanstack/react-start'
import { zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const requestLogger = createMiddleware({ type: 'function' })
  .client(async ({ next, context }) => {
    return next({
      sendContext: {
        workspaceId: context.workspaceId,
      },
    })
  })
  .server(async ({ next, data, context }) => {
    // 사용 전 반드시 검증
    const workspaceId = zodValidator(z.number()).parse(context.workspaceId)
    console.log('Workspace ID:', workspaceId)
    return next()
  })
```

### 서버에서 클라이언트로 (Server -> Client)

서버에서도 `sendContext`를 통해 클라이언트로 데이터를 전송할 수 있습니다. 전송된 데이터는 클라이언트 미들웨어의 `next()` 반환값의 `context`에서 접근 가능합니다.

> **주의:** `next()` 반환값의 타입은 현재 미들웨어 체인에서 알려진 미들웨어에서만 추론됩니다. 따라서 체인 마지막 미들웨어에서 가장 정확한 타입을 얻을 수 있습니다.

```typescript
import { createMiddleware } from '@tanstack/react-start'

// 서버에서 시간 정보를 클라이언트로 전송
const serverTimer = createMiddleware({ type: 'function' }).server(
  async ({ next }) => {
    return next({
      sendContext: {
        timeFromServer: new Date(),
      },
    })
  },
)

const requestLogger = createMiddleware({ type: 'function' })
  .middleware([serverTimer])
  .client(async ({ next }) => {
    const result = await next()
    // 서버에서 보낸 시간 정보에 접근 가능
    console.log('Time from the server:', result.context.timeFromServer)
    return result
  })
```

</send_context>

---

<custom_headers>

## 커스텀 헤더 설정

### 클라이언트 미들웨어에서 헤더 추가

`.client()` 메서드에서 `next()`에 `headers` 객체를 전달하여 요청 헤더를 설정할 수 있습니다.

```typescript
import { createMiddleware } from '@tanstack/react-start'
import { getToken } from 'my-auth-library'

const authMiddleware = createMiddleware({ type: 'function' }).client(
  async ({ next }) => {
    return next({
      headers: {
        Authorization: `Bearer ${getToken()}`,
      },
    })
  },
)
```

### 헤더 머징 (다중 미들웨어)

여러 미들웨어가 헤더를 설정하면, 모두 **병합**됩니다. 후속 미들웨어가 동일 키의 헤더를 덮어씁니다.

```typescript
const firstMiddleware = createMiddleware({ type: 'function' }).client(
  async ({ next }) => {
    return next({
      headers: {
        'X-Request-ID': '12345',
        'X-Source': 'first-middleware',
      },
    })
  },
)

const secondMiddleware = createMiddleware({ type: 'function' }).client(
  async ({ next }) => {
    return next({
      headers: {
        'X-Timestamp': Date.now().toString(),
        'X-Source': 'second-middleware',  // first를 덮어씀
      },
    })
  },
)

// 최종 헤더:
// - X-Request-ID: '12345' (first에서)
// - X-Timestamp: '<timestamp>' (second에서)
// - X-Source: 'second-middleware' (second가 first를 덮어씀)
```

### 호출 시점에서 헤더 설정

```typescript
await myServerFn({
  data: { name: 'John' },
  headers: {
    'X-Custom-Header': 'call-site-value',
  },
})
```

**헤더 우선순위 (모두 병합, 후순위가 덮어씀):**

| 우선순위 | 출처 | 설명 |
|---------|------|------|
| 1 (낮음) | 앞쪽 미들웨어 | 먼저 설정된 헤더 |
| 2 | 뒤쪽 미들웨어 | 앞쪽 미들웨어를 덮어씀 |
| 3 (높음) | 호출 시점 | 모든 미들웨어 헤더를 덮어씀 |

</custom_headers>

---

<custom_fetch>

## 커스텀 fetch 구현

고급 사용 사례에서 커스텀 `fetch` 구현을 제공하여 서버 함수 요청 방식을 제어할 수 있습니다:

- 요청 인터셉터 또는 재시도 로직
- 커스텀 HTTP 클라이언트 사용
- 테스트 및 모킹
- 텔레메트리/모니터링 추가

### 클라이언트 미들웨어를 통한 커스텀 fetch

```typescript
import { createMiddleware } from '@tanstack/react-start'
import type { CustomFetch } from '@tanstack/react-start'

const customFetchMiddleware = createMiddleware({ type: 'function' }).client(
  async ({ next }) => {
    const customFetch: CustomFetch = async (url, init) => {
      console.log('Request starting:', url)
      const start = Date.now()

      const response = await fetch(url, init)

      console.log('Request completed in', Date.now() - start, 'ms')
      return response
    }

    return next({ fetch: customFetch })
  },
)
```

### 호출 시점에서 커스텀 fetch

```typescript
import type { CustomFetch } from '@tanstack/react-start'

const myFetch: CustomFetch = async (url, init) => {
  // 커스텀 로직 추가
  return fetch(url, init)
}

await myServerFn({
  data: { name: 'John' },
  fetch: myFetch,
})
```

### fetch 우선순위

| 우선순위 | 출처 | 설명 |
|---------|------|------|
| 1 (최고) | 호출 시점 | `serverFn({ fetch: customFetch })` |
| 2 | 뒤쪽 미들웨어 | 체인 마지막 미들웨어의 fetch |
| 3 | 앞쪽 미들웨어 | 체인 첫 미들웨어의 fetch |
| 4 | createStart | `createStart({ serverFns: { fetch: customFetch } })` |
| 5 (최저) | 기본값 | 전역 `fetch` 함수 |

**핵심 원칙:** 호출 시점이 항상 우선입니다. 특정 호출에서 미들웨어 동작을 재정의할 수 있습니다.

### 전역 fetch (createStart)

모든 서버 함수에 대한 기본 커스텀 fetch 설정:

```typescript
// src/start.ts
import { createStart } from '@tanstack/react-start'
import type { CustomFetch } from '@tanstack/react-start'

const globalFetch: CustomFetch = async (url, init) => {
  console.log('Global fetch:', url)
  return fetch(url, init)
}

export const startInstance = createStart(() => {
  return {
    serverFns: {
      fetch: globalFetch,
    },
  }
})
```

> **참고:** 커스텀 fetch는 클라이언트 사이드에서만 적용됩니다. SSR 중에는 서버 함수가 fetch 없이 직접 호출됩니다.

</custom_fetch>

---

<auth_middleware>

## 인증 미들웨어

### 세션 기반 인증

```typescript
import { createMiddleware } from '@tanstack/react-start'
import { redirect } from '@tanstack/react-router'

const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await getSession(request)

    if (!session?.user) {
      throw redirect({ to: '/login' })
    }

    return next({ context: { user: session.user } })
  })

// 사용
export const getMyProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }): Promise<User> => {
    return prisma.user.findUnique({
      where: { id: context.user.id },
    })
  })
```

### 선택적 인증

```typescript
const optionalAuthMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await getSession(request)
    return next({ context: { user: session?.user ?? null } })
  })

export const getPublicPosts = createServerFn({ method: 'GET' })
  .middleware([optionalAuthMiddleware])
  .handler(async ({ context }): Promise<Post[]> => {
    return prisma.post.findMany({
      where: {
        published: true,
        ...(context.user && { authorId: context.user.id }),
      },
    })
  })
```

</auth_middleware>

---

<role_middleware>

## 역할 기반 미들웨어

### 고정 역할 (Admin)

```typescript
const adminMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await getSession(request)

    if (!session?.user || session.user.role !== 'ADMIN') {
      throw new Error('Forbidden: Admin access only')
    }

    return next({ context: { user: session.user } })
  })

export const deleteAnyUser = createServerFn({ method: 'DELETE' })
  .middleware([adminMiddleware])
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }): Promise<{ success: true }> => {
    await prisma.user.delete({ where: { id: data.id } })
    return { success: true }
  })
```

### 동적 역할

```typescript
const roleMiddleware = (allowedRoles: string[]) =>
  createMiddleware({ type: 'function' })
    .server(async ({ next, request }) => {
      const session = await getSession(request)

      if (!session?.user) {
        throw redirect({ to: '/login' })
      }

      if (!allowedRoles.includes(session.user.role)) {
        throw new Error(`Forbidden: Required roles: ${allowedRoles.join(', ')}`)
      }

      return next({ context: { user: session.user } })
    })

export const approvePost = createServerFn({ method: 'POST' })
  .middleware([roleMiddleware(['ADMIN', 'MODERATOR'])])
  .inputValidator(z.object({ id: z.string() }))
  .handler(async ({ data }): Promise<Post> => {
    return prisma.post.update({
      where: { id: data.id },
      data: { published: true },
    })
  })
```

</role_middleware>

---

<validation_middleware>

## 검증 미들웨어

### Zod 검증 미들웨어

```typescript
import { zodValidator } from '@tanstack/zod-adapter'
import { z } from 'zod'

const mySchema = z.object({
  workspaceId: z.string(),
})

const workspaceMiddleware = createMiddleware({ type: 'function' })
  .inputValidator(zodValidator(mySchema))
  .server(async ({ next, data }) => {
    const workspace = await prisma.workspace.findUnique({
      where: { id: data.workspaceId },
    })

    if (!workspace) {
      throw new Error('Workspace not found')
    }

    return next({ context: { workspace } })
  })

export const getWorkspaceData = createServerFn({ method: 'GET' })
  .middleware([authMiddleware, workspaceMiddleware])
  .handler(async ({ context }): Promise<WorkspaceData> => {
    return {
      workspace: context.workspace,
      user: context.user,
      projects: await prisma.project.findMany({
        where: { workspaceId: context.workspace.id },
      }),
    }
  })
```

### 비즈니스 로직 검증

```typescript
const projectAccessMiddleware = createMiddleware({ type: 'function' })
  .inputValidator(z.object({ projectId: z.string() }))
  .server(async ({ next, data, request }) => {
    const session = await getSession(request)
    if (!session?.user) throw redirect({ to: '/login' })

    const project = await prisma.project.findUnique({
      where: { id: data.projectId },
      include: { members: true },
    })

    if (!project) {
      throw new Error('Project not found')
    }

    const isMember = project.members.some((m) => m.userId === session.user.id)
    const isOwner = project.ownerId === session.user.id

    if (!isMember && !isOwner) {
      throw new Error('Access denied')
    }

    return next({
      context: {
        user: session.user,
        project,
        isOwner,
      },
    })
  })
```

</validation_middleware>

---

<middleware_chaining>

## 미들웨어 체이닝

### 순서가 중요

```typescript
export const protectedWorkspaceFn = createServerFn({ method: 'POST' })
  .middleware([
    loggingMiddleware,      // 1. 로깅 (모든 요청)
    authMiddleware,         // 2. 인증 (세션 검증)
    roleMiddleware(['ADMIN']), // 3. 권한 (역할 확인)
    workspaceMiddleware,    // 4. 비즈니스 로직 (workspace 검증)
  ])
  .inputValidator(taskSchema)
  .handler(async ({ data, context }): Promise<Task> => {
    return prisma.task.create({
      data: {
        ...data,
        workspaceId: context.workspace.id,
        createdById: context.user.id,
      },
    })
  })
```

### 미들웨어 실행 순서

미들웨어는 의존성 우선으로 실행됩니다. 전역 미들웨어가 먼저, 그 다음 서버 함수 미들웨어가 실행됩니다.

```typescript
// 실행 순서: globalMiddleware1 -> globalMiddleware2 -> a -> b -> c -> d -> fn
const a = createMiddleware({ type: 'function' }).server(async ({ next }) => {
  console.log('a')
  return next()
})

const b = createMiddleware({ type: 'function' })
  .middleware([a])
  .server(async ({ next }) => {
    console.log('b')
    return next()
  })

const c = createMiddleware({ type: 'function' }).server(async ({ next }) => {
  console.log('c')
  return next()
})

const d = createMiddleware({ type: 'function' })
  .middleware([b, c])
  .server(async ({ next }) => {
    console.log('d')
    return next()
  })

const fn = createServerFn()
  .middleware([d])
  .handler(async () => {
    console.log('fn')
  })
```

</middleware_chaining>

---

<global_middleware>

## 전역 미들웨어

> **참고:** `src/start.ts` 파일은 기본 TanStack Start 템플릿에 포함되어 있지 않습니다. 전역 미들웨어를 구성하려면 이 파일을 직접 생성해야 합니다.

### 전역 Request Middleware

모든 요청 (Server Routes, SSR, Server Functions)에 적용:

```typescript
// src/start.ts
import { createStart, createMiddleware } from '@tanstack/react-start'

const myGlobalMiddleware = createMiddleware().server(({ next }) => {
  console.log('모든 요청에 실행')
  return next()
})

export const startInstance = createStart(() => ({
  requestMiddleware: [myGlobalMiddleware],
}))
```

### 전역 Server Function Middleware

모든 Server Function에 적용:

```typescript
// src/start.ts
import { createStart, createMiddleware } from '@tanstack/react-start'

const loggingMiddleware = createMiddleware({ type: 'function' })
  .server(({ next, request }) => {
    console.log(`[${new Date().toISOString()}] ${request.method}`)
    return next()
  })

export const startInstance = createStart(() => ({
  functionMiddleware: [loggingMiddleware],
}))
```

### 전역 에러 처리

```typescript
const errorHandlingMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    try {
      return await next()
    } catch (error) {
      if (error instanceof Error) {
        console.error('Error:', error.message)
      }
      throw error
    }
  })

export const startInstance = createStart(() => ({
  functionMiddleware: [errorHandlingMiddleware],
}))
```

</global_middleware>

---

<route_middleware>

## 라우트 레벨 미들웨어

### 모든 Server Route 메서드에 적용

```typescript
export const Route = createFileRoute('/api/protected')({
  server: {
    middleware: [authMiddleware, adminMiddleware],
    handlers: {
      GET: async ({ request }): Promise<Response> => {
        return new Response('Admin data')
      },
      POST: async ({ request }): Promise<Response> => {
        const body = await request.json()
        return Response.json({ created: true })
      },
    },
  },
})
```

### 특정 메서드에만 미들웨어 적용

`createHandlers` 유틸리티를 사용하여 개별 메서드에 미들웨어를 적용합니다.

```typescript
export const Route = createFileRoute('/foo')({
  server: {
    handlers: ({ createHandlers }) =>
      createHandlers({
        GET: {
          middleware: [loggingMiddleware],
          handler: () => {
            //...
          },
        },
      }),
  },
})
```

### beforeLoad와 미들웨어

```typescript
export const Route = createFileRoute('/dashboard')({
  // 라우트 진입 전 검증
  beforeLoad: async () => {
    const user = await getCurrentUser()
    if (!user) {
      throw redirect({ to: '/login' })
    }
    return { user }
  },

  server: {
    middleware: [loggingMiddleware],
    handlers: {
      GET: async (): Promise<Response> => {
        return new Response('Dashboard data')
      },
    },
  },

  component: DashboardPage,
})
```

</route_middleware>

---

<request_response>

## 요청/응답 수정

### 서버 사이드: 요청/응답 유틸리티

`.server()` 메서드 내에서 Server Function Context 유틸리티를 사용할 수 있습니다:

```typescript
import {
  getRequest,
  getRequestHeader,
  setResponseHeaders,
  setResponseStatus,
} from '@tanstack/react-start/server'

const cachingMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const request = getRequest()
    const authHeader = getRequestHeader('Authorization')

    setResponseHeaders(
      new Headers({
        'Cache-Control': 'public, max-age=300',
      }),
    )

    setResponseStatus(200)

    return next()
  })
```

**사용 가능한 유틸리티:**
- `getRequest()` - 전체 Request 객체 접근
- `getRequestHeader(name)` - 특정 요청 헤더 읽기
- `setResponseHeader(name, value)` - 단일 응답 헤더 설정
- `setResponseHeaders(headers)` - Headers 객체로 다중 응답 헤더 설정
- `setResponseStatus(code)` - HTTP 상태 코드 설정

</request_response>

---

<error_handling>

## 미들웨어 에러 처리

### 리다이렉트

```typescript
const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await getSession(request)

    if (!session?.user) {
      throw redirect({
        to: '/login',
        search: { returnUrl: '/dashboard' },
      })
    }

    return next({ context: { user: session.user } })
  })
```

### 커스텀 에러

```typescript
class ForbiddenError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'ForbiddenError'
  }
}

const permissionMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await getSession(request)

    if (!session?.user) {
      throw new ForbiddenError('Unauthorized')
    }

    return next({ context: { user: session.user } })
  })
```

### 에러 변환

```typescript
const errorTransformMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    try {
      return await next()
    } catch (error) {
      if (error instanceof ForbiddenError) {
        throw new Error(`Access Denied: ${error.message}`)
      }
      throw error
    }
  })
```

</error_handling>

---

<context_typing>

## Context 타입 정의

```typescript
// lib/middleware-context.ts

export interface MiddlewareContext {
  user?: {
    id: string
    email: string
    role: 'USER' | 'ADMIN' | 'MODERATOR'
  }
  workspace?: {
    id: string
    name: string
  }
  permissions?: string[]
}

// middleware/auth.ts
const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, request }) => {
    const session = await getSession(request)

    return next({
      context: {
        user: session?.user ? {
          id: session.user.id,
          email: session.user.email,
          role: session.user.role as 'USER' | 'ADMIN',
        } : undefined,
      },
    })
  })

// Server Function
export const fn = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }): Promise<unknown> => {
    // context.user는 타입 안전
    return context.user?.id
  })
```

</context_typing>

---

<environment_tree_shaking>

## 환경별 트리 셰이킹

미들웨어 기능은 각 번들의 환경에 따라 트리 셰이킹됩니다:

| 환경 | 동작 |
|------|------|
| **서버** | 모든 코드 포함 (트리 셰이킹 없음) |
| **클라이언트** | `.server()` 코드 제거, `data` 검증 코드도 제거 |

</environment_tree_shaking>

---

<best_practices>

## 모범 사례

| 원칙 | 설명 |
|------|------|
| **단일 책임** | 각 미들웨어는 하나의 기능만 담당 |
| **재사용성** | 공통 미들웨어는 `@/middleware/`에 |
| **순서 명시** | 미들웨어 순서를 주석으로 표기 |
| **에러 처리** | 미들웨어에서 throw로 명확하게 에러 처리 |
| **Context 명확성** | context 구조를 타입으로 정의 |
| **이름** | 미들웨어는 `*Middleware` 이름으로 통일 |
| **sendContext 검증** | 클라이언트에서 보낸 동적 데이터는 서버에서 반드시 검증 |
| **메서드 순서** | TypeScript 강제 순서 준수: middleware -> inputValidator -> client -> server |

### 나쁜 예

```typescript
// 여러 책임을 가진 미들웨어
const megaMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    console.log('Request')           // 로깅
    const session = await getSession() // 인증
    if (session?.user.role !== 'ADMIN') throw new Error('Forbidden') // 권한
    return next()
  })
```

### 좋은 예

```typescript
// 책임 분리
const loggingMiddleware = createMiddleware({ type: 'function' })
  .server(({ next }) => {
    console.log('Request')
    return next()
  })

const authMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next }) => {
    const session = await getSession()
    if (!session) throw redirect({ to: '/login' })
    return next({ context: { user: session.user } })
  })

const adminMiddleware = createMiddleware({ type: 'function' })
  .server(async ({ next, context }) => {
    if (context.user.role !== 'ADMIN') {
      throw new Error('Forbidden')
    }
    return next()
  })

// 조합 사용
export const adminFn = createServerFn({ method: 'POST' })
  .middleware([loggingMiddleware, authMiddleware, adminMiddleware])
  .handler(async () => ({ success: true }))
```

</best_practices>

---

<version_info>

**Version:** TanStack Start/Router v1.159.4

**Key Features:**
- Type-safe context passing (sendContext 포함)
- Client-Server 양방향 컨텍스트 전송
- 커스텀 헤더 설정 및 머징
- 커스텀 fetch 구현 (미들웨어/호출 시점/전역)
- Request/Server Function 두 가지 미들웨어 타입
- 환경별 트리 셰이킹
- 전역 및 라우트 레벨 미들웨어 지원
- 특정 Server Route 메서드별 미들웨어 적용

</version_info>
