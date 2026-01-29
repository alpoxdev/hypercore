# Middleware

> 요청 처리 전 실행되는 함수

---

## 기본 사용법

```typescript
// middleware.ts (루트)
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export function middleware(request: NextRequest) {
  // 로직 실행...
  return NextResponse.next()
}

// 매처 설정
export const config = {
  matcher: ["/dashboard/:path*", "/api/:path*"],
}
```

---

## Response 타입

### NextResponse.next()

```typescript
// 요청을 다음 미들웨어 또는 라우트로 전달
export function middleware(request: NextRequest) {
  return NextResponse.next()
}
```

### NextResponse.redirect()

```typescript
// 다른 URL로 리다이렉트
export function middleware(request: NextRequest) {
  return NextResponse.redirect(new URL("/login", request.url))
}
```

### NextResponse.rewrite()

```typescript
// URL은 유지하되 다른 페이지 렌더링
export function middleware(request: NextRequest) {
  return NextResponse.rewrite(new URL("/dashboard/home", request.url))
}
```

---

## 인증

```typescript
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export function middleware(request: NextRequest) {
  const token = request.cookies.get("token")

  // 토큰 없으면 로그인 페이지로
  if (!token) {
    return NextResponse.redirect(new URL("/login", request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
}
```

---

## 쿠키 처리

### 읽기

```typescript
export function middleware(request: NextRequest) {
  const token = request.cookies.get("token")
  const userId = request.cookies.get("userId")

  console.log({ token, userId })

  return NextResponse.next()
}
```

### 설정

```typescript
export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  response.cookies.set("visited", "true", {
    httpOnly: true,
    secure: true,
    maxAge: 60 * 60 * 24 * 7, // 7일
  })

  return response
}
```

---

## Headers 처리

### 읽기

```typescript
export function middleware(request: NextRequest) {
  const userAgent = request.headers.get("user-agent")
  const authorization = request.headers.get("authorization")

  console.log({ userAgent, authorization })

  return NextResponse.next()
}
```

### 설정

```typescript
export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  response.headers.set("X-Custom-Header", "value")
  response.headers.set("X-Request-Id", crypto.randomUUID())

  return response
}
```

---

## 경로별 처리

```typescript
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // /api/* 경로
  if (pathname.startsWith("/api/")) {
    const token = request.headers.get("authorization")

    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }
  }

  // /admin/* 경로
  if (pathname.startsWith("/admin/")) {
    const role = request.cookies.get("role")?.value

    if (role !== "admin") {
      return NextResponse.redirect(new URL("/", request.url))
    }
  }

  return NextResponse.next()
}
```

---

## Matcher 설정

### 배열

```typescript
export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
}
```

### 정규식

```typescript
export const config = {
  matcher: [
    /*
     * 다음 경로 제외:
     * - _next/static (정적 파일)
     * - _next/image (이미지 최적화)
     * - favicon.ico (파비콘)
     */
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
}
```

### 조건부

```typescript
export const config = {
  matcher: [
    "/dashboard/:path*",
    {
      source: "/api/:path*",
      has: [
        { type: "header", key: "authorization" },
      ],
    },
  ],
}
```

---

## 로깅

```typescript
export function middleware(request: NextRequest) {
  const start = Date.now()

  const response = NextResponse.next()

  const duration = Date.now() - start

  console.log({
    method: request.method,
    url: request.url,
    duration: `${duration}ms`,
    status: response.status,
  })

  return response
}
```

---

## Rate Limiting

```typescript
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

const rateLimit = new Map<string, { count: number; resetAt: number }>()

const LIMIT = 10 // 10 requests
const WINDOW = 60 * 1000 // 1분

export function middleware(request: NextRequest) {
  const ip = request.ip || "unknown"
  const now = Date.now()

  const record = rateLimit.get(ip)

  if (!record || now > record.resetAt) {
    rateLimit.set(ip, { count: 1, resetAt: now + WINDOW })
    return NextResponse.next()
  }

  if (record.count >= LIMIT) {
    return NextResponse.json(
      { error: "Too many requests" },
      { status: 429 }
    )
  }

  record.count++
  return NextResponse.next()
}

export const config = {
  matcher: "/api/:path*",
}
```

---

## Geolocation

```typescript
export function middleware(request: NextRequest) {
  const country = request.geo?.country || "US"
  const city = request.geo?.city || "Unknown"

  const response = NextResponse.next()
  response.headers.set("X-Country", country)
  response.headers.set("X-City", city)

  return response
}
```

---

## A/B 테스팅

```typescript
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export function middleware(request: NextRequest) {
  const bucket = request.cookies.get("bucket")

  if (!bucket) {
    const newBucket = Math.random() > 0.5 ? "A" : "B"
    const response = NextResponse.next()

    response.cookies.set("bucket", newBucket)

    if (newBucket === "B") {
      return NextResponse.rewrite(new URL("/variant-b", request.url))
    }

    return response
  }

  if (bucket.value === "B") {
    return NextResponse.rewrite(new URL("/variant-b", request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: "/",
}
```

---

## 베스트 프랙티스

### ✅ DO

```typescript
// 1. 가벼운 로직만
export function middleware(request: NextRequest) {
  const token = request.cookies.get("token")

  if (!token) {
    return NextResponse.redirect(new URL("/login", request.url))
  }

  return NextResponse.next()
}

// 2. matcher 설정
export const config = {
  matcher: ["/dashboard/:path*"],
}
```

### ❌ DON'T

```typescript
// 1. 무거운 DB 쿼리
export async function middleware(request: NextRequest) {
  // ❌ 미들웨어에서 DB 쿼리 금지
  const user = await prisma.user.findUnique({ where: { id: "..." } })
  return NextResponse.next()
}

// 2. matcher 없이 모든 요청 처리
export function middleware(request: NextRequest) {
  // ❌ 성능 저하
  return NextResponse.next()
}
```

---

## NextAuth.js와 함께 사용

```typescript
// middleware.ts
export { default } from "next-auth/middleware"

export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
}
```

---

## 참조

- [Next.js Middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)
