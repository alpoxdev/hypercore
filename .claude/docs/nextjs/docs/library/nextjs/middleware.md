# Middleware

> Functions executed before request processing

---

## Basic Usage

```typescript
// middleware.ts (root)
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export function middleware(request: NextRequest) {
  // Execute logic...
  return NextResponse.next()
}

// Matcher configuration
export const config = {
  matcher: ["/dashboard/:path*", "/api/:path*"],
}
```

---

## Response Types

### NextResponse.next()

```typescript
// Pass request to next middleware or route
export function middleware(request: NextRequest) {
  return NextResponse.next()
}
```

### NextResponse.redirect()

```typescript
// Redirect to different URL
export function middleware(request: NextRequest) {
  return NextResponse.redirect(new URL("/login", request.url))
}
```

### NextResponse.rewrite()

```typescript
// Render different page while keeping URL
export function middleware(request: NextRequest) {
  return NextResponse.rewrite(new URL("/dashboard/home", request.url))
}
```

---

## Authentication

```typescript
import { NextResponse } from "next/server"
import type { NextRequest } from "next/server"

export function middleware(request: NextRequest) {
  const token = request.cookies.get("token")

  // Redirect to login if no token
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

## Cookie Handling

### Reading

```typescript
export function middleware(request: NextRequest) {
  const token = request.cookies.get("token")
  const userId = request.cookies.get("userId")

  console.log({ token, userId })

  return NextResponse.next()
}
```

### Setting

```typescript
export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  response.cookies.set("visited", "true", {
    httpOnly: true,
    secure: true,
    maxAge: 60 * 60 * 24 * 7, // 7 days
  })

  return response
}
```

---

## Headers Handling

### Reading

```typescript
export function middleware(request: NextRequest) {
  const userAgent = request.headers.get("user-agent")
  const authorization = request.headers.get("authorization")

  console.log({ userAgent, authorization })

  return NextResponse.next()
}
```

### Setting

```typescript
export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  response.headers.set("X-Custom-Header", "value")
  response.headers.set("X-Request-Id", crypto.randomUUID())

  return response
}
```

---

## Path-based Processing

```typescript
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // /api/* routes
  if (pathname.startsWith("/api/")) {
    const token = request.headers.get("authorization")

    if (!token) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }
  }

  // /admin/* routes
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

## Matcher Configuration

### Array

```typescript
export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
}
```

### Regex

```typescript
export const config = {
  matcher: [
    /*
     * Exclude paths:
     * - _next/static (static files)
     * - _next/image (image optimization)
     * - favicon.ico (favicon)
     */
    "/((?!_next/static|_next/image|favicon.ico).*)",
  ],
}
```

### Conditional

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

## Logging

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
const WINDOW = 60 * 1000 // 1 minute

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

## A/B Testing

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

## Best Practices

### ✅ DO

```typescript
// 1. Keep logic lightweight
export function middleware(request: NextRequest) {
  const token = request.cookies.get("token")

  if (!token) {
    return NextResponse.redirect(new URL("/login", request.url))
  }

  return NextResponse.next()
}

// 2. Configure matcher
export const config = {
  matcher: ["/dashboard/:path*"],
}
```

### ❌ DON'T

```typescript
// 1. Heavy database queries
export async function middleware(request: NextRequest) {
  // ❌ No DB queries in middleware
  const user = await prisma.user.findUnique({ where: { id: "..." } })
  return NextResponse.next()
}

// 2. Processing all requests without matcher
export function middleware(request: NextRequest) {
  // ❌ Performance degradation
  return NextResponse.next()
}
```

---

## Using with NextAuth.js

```typescript
// middleware.ts
export { default } from "next-auth/middleware"

export const config = {
  matcher: ["/dashboard/:path*", "/profile/:path*"],
}
```

---

## References

- [Next.js Middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)
