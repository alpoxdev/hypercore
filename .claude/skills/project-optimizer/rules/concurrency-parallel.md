---
title: Parallelize Independent Operations
impact: CRITICAL
impactDescription: 2-10x improvement on I/O-bound workloads
tags: concurrency, parallelization, async, performance
languages: all
related: [concurrency-defer-await, concurrency-pool, io-batch-queries]
---

## 독립 작업 병렬 실행

서로 의존성이 없는 I/O 작업은 동시에 실행하여 총 대기 시간을 최장 작업 1개 수준으로 줄입니다.

**❌ 잘못된 예시 (순차 실행, 3번 왕복):**

```typescript
// JS/TS
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()
// 총 시간: T(user) + T(posts) + T(comments)
```

```python
# Python
user = await fetch_user()
posts = await fetch_posts()
comments = await fetch_comments()
```

```go
// Go
user, _ := fetchUser(ctx)
posts, _ := fetchPosts(ctx)
comments, _ := fetchComments(ctx)
```

**✅ 올바른 예시 (병렬 실행, 1번 왕복):**

```typescript
// JS/TS
const [user, posts, comments] = await Promise.all([
  fetchUser(), fetchPosts(), fetchComments()
])
// 총 시간: max(T(user), T(posts), T(comments))
```

```python
# Python
user, posts, comments = await asyncio.gather(
    fetch_user(), fetch_posts(), fetch_comments()
)
```

```go
// Go (errgroup)
g, ctx := errgroup.WithContext(ctx)
var user *User; var posts []Post; var comments []Comment
g.Go(func() error { var err error; user, err = fetchUser(ctx); return err })
g.Go(func() error { var err error; posts, err = fetchPosts(ctx); return err })
g.Go(func() error { var err error; comments, err = fetchComments(ctx); return err })
if err := g.Wait(); err != nil { return err }
```

```rust
// Rust (tokio)
let (user, posts, comments) = tokio::try_join!(
    fetch_user(), fetch_posts(), fetch_comments()
)?;
```

```java
// Java
var userFuture = CompletableFuture.supplyAsync(() -> fetchUser());
var postsFuture = CompletableFuture.supplyAsync(() -> fetchPosts());
CompletableFuture.allOf(userFuture, postsFuture).join();
var user = userFuture.get();
var posts = postsFuture.get();
```

```csharp
// C#
var userTask = FetchUserAsync();
var postsTask = FetchPostsAsync();
await Task.WhenAll(userTask, postsTask);
var user = userTask.Result;
var posts = postsTask.Result;
```

**적용 기준:** 두 작업이 서로의 결과를 필요로 하지 않으면 병렬화 대상.
