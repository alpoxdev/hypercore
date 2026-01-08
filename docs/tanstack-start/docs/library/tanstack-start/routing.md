# TanStack Start - Routing

<patterns>

```tsx
// 기본
export const Route = createFileRoute('/about')({ component: AboutPage })

// Loader
export const Route = createFileRoute('/')({
  component: Page,
  loader: async () => fetch('/api/posts').then(r => r.json()),
})
const Page = () => {
  const posts = Route.useLoaderData()
  return <ul>{posts.map(p => <li key={p.id}>{p.title}</li>)}</ul>
}

// 동적 라우트
export const Route = createFileRoute('/users/$id')({
  loader: async ({ params }) => ({ user: await getUserById(params.id) }),
  component: () => {
    const { user } = Route.useLoaderData()
    return <h1>{user.name}</h1>
  },
})

// SSR 옵션
ssr: true       // 전체 SSR (기본값)
ssr: false      // 클라이언트만
ssr: 'data-only' // 데이터만 서버

// Server Routes (API)
export const Route = createFileRoute('/api/hello')({
  server: {
    handlers: {
      GET: async () => new Response('Hello'),
      POST: async ({ request }) => {
        const body = await request.json()
        return json({ name: body.name })
      },
    },
  },
})
```

</patterns>

<structure>

```
routes/
├── __root.tsx      # Root layout
├── index.tsx       # /
├── users/$id.tsx   # /users/:id
├── $.tsx           # Catch-all (404)
```

</structure>
