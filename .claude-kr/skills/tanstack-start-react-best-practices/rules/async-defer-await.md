---
title: Defer Await Until Needed
impact: HIGH
impactDescription: avoids blocking unused code paths
tags: async, await, conditional, optimization
---

## 필요할 때까지 Await 연기하기

실제로 사용되는 분기점에서만 `await` 작업을 수행하여 필요하지 않은 코드 경로가 블로킹되는 것을 방지합니다.

**❌ 잘못된 예시 (두 분기 모두 블로킹):**

```typescript
async function handleRequest(userId: string, skipProcessing: boolean) {
  const userData = await fetchUserData(userId)

  if (skipProcessing) {
    // 즉시 반환하지만 여전히 userData를 기다렸음
    return { skipped: true }
  }

  // 이 분기에서만 userData를 사용함
  return processUserData(userData)
}
```

**✅ 올바른 예시 (필요할 때만 블로킹):**

```typescript
async function handleRequest(userId: string, skipProcessing: boolean) {
  if (skipProcessing) {
    // 기다리지 않고 즉시 반환
    return { skipped: true }
  }

  // 필요할 때만 가져오기
  const userData = await fetchUserData(userId)
  return processUserData(userData)
}
```

**다른 예시 (조기 반환 최적화):**

```typescript
// ❌ 잘못된 예시: 항상 권한을 가져옴
async function updateResource(resourceId: string, userId: string) {
  const permissions = await fetchPermissions(userId)
  const resource = await getResource(resourceId)

  if (!resource) {
    return { error: 'Not found' }
  }

  if (!permissions.canEdit) {
    return { error: 'Forbidden' }
  }

  return await updateResourceData(resource, permissions)
}

// ✅ 올바른 예시: 필요할 때만 가져오기
async function updateResource(resourceId: string, userId: string) {
  const resource = await getResource(resourceId)

  if (!resource) {
    return { error: 'Not found' }
  }

  const permissions = await fetchPermissions(userId)

  if (!permissions.canEdit) {
    return { error: 'Forbidden' }
  }

  return await updateResourceData(resource, permissions)
}
```

이 최적화는 건너뛴 분기가 자주 실행되거나, 연기된 작업이 비용이 많이 드는 경우 특히 유용합니다.
