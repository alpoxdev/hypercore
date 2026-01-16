---
title: 병렬 서버 함수 호출을 위한 컴포넌트 구조 재조정
impact: HIGH
impactDescription: 컴포넌트 레벨 워터폴 제거
tags: server, parallelization, architecture, server-functions
---

## 병렬 서버 함수 호출을 위한 컴포넌트 구조 재조정

순차적 서버 함수 호출을 강제하는 중첩 컴포넌트 구조 방지. 가능하면 부모 loader로 데이터 페칭 이동.

**❌ 잘못된 예 (순차 실행: User → Posts → Comments):**

```tsx
// routes/dashboard.tsx
export const Route = createFileRoute('/dashboard')({
  loader: async () => ({ user: await getUser() }),
  component: Dashboard
})

function Dashboard() {
  const { user } = Route.useLoaderData()
  return <UserPosts userId={user.id} />
}

// components/UserPosts.tsx
function UserPosts({ userId }) {
  const posts = await getPosts(userId) // 로드될 때까지 차단
  return posts.map(p => <PostComments postId={p.id} />)
}

function PostComments({ postId }) {
  const comments = await getComments(postId) // 순차 워터폴
  return <CommentList comments={comments} />
}
```

**✅ 올바른 예 (loader에서 병렬 페칭):**

```tsx
// routes/dashboard.tsx
export const Route = createFileRoute('/dashboard')({
  loader: async () => {
    const user = await getUser()
    const [posts, comments] = await Promise.all([
      getPosts(user.id),
      getComments(user.id)
    ])
    return { user, posts, comments }
  },
  component: Dashboard
})

function Dashboard() {
  const { user, posts, comments } = Route.useLoaderData()
  return <PostList posts={posts} comments={comments} />
}
```

loader에서 데이터 페칭을 중앙화하면 워터폴을 줄이고 병렬 실행이 가능합니다.
