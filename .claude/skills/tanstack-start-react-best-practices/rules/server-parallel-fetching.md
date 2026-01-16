---
title: Restructure Components for Parallel Server Function Calls
impact: HIGH
impactDescription: eliminates component-level waterfalls
tags: server, parallelization, architecture, server-functions
---

## Restructure Components for Parallel Server Function Calls

Avoid nested component structures that force sequential server function calls. Move data fetching to parent loader when possible.

**Incorrect (sequential: User → Posts → Comments):**

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
  const posts = await getPosts(userId) // Blocks until loaded
  return posts.map(p => <PostComments postId={p.id} />)
}

function PostComments({ postId }) {
  const comments = await getComments(postId) // Sequential waterfall
  return <CommentList comments={comments} />
}
```

**Correct (parallel fetching in loader):**

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

Centralizing data fetching in the loader reduces waterfalls and enables parallel execution.
