---
title: Use Loop for Min/Max Instead of Sort
impact: LOW
impactDescription: O(n) instead of O(n log n)
tags: javascript, arrays, performance, sorting, algorithms
---

## 최소/최대값은 정렬 대신 루프 사용

가장 작거나 큰 요소를 찾는 것은 배열을 한 번만 순회하면 됩니다. 정렬은 낭비적이고 느립니다.

**잘못된 예 (O(n log n) - 최신 항목을 찾기 위해 정렬):**

```typescript
interface Project {
  id: string
  name: string
  updatedAt: number
}

function getLatestProject(projects: Project[]) {
  const sorted = [...projects].sort((a, b) => b.updatedAt - a.updatedAt)
  return sorted[0]
}
```

최댓값을 찾기 위해 전체 배열을 정렬합니다.

**잘못된 예 (O(n log n) - 가장 오래된 것과 최신 것을 찾기 위해 정렬):**

```typescript
function getOldestAndNewest(projects: Project[]) {
  const sorted = [...projects].sort((a, b) => a.updatedAt - b.updatedAt)
  return { oldest: sorted[0], newest: sorted[sorted.length - 1] }
}
```

최소/최대값만 필요한데도 불필요하게 정렬합니다.

**올바른 예 (O(n) - 단일 루프):**

```typescript
function getLatestProject(projects: Project[]) {
  if (projects.length === 0) return null

  let latest = projects[0]

  for (let i = 1; i < projects.length; i++) {
    if (projects[i].updatedAt > latest.updatedAt) {
      latest = projects[i]
    }
  }

  return latest
}

function getOldestAndNewest(projects: Project[]) {
  if (projects.length === 0) return { oldest: null, newest: null }

  let oldest = projects[0]
  let newest = projects[0]

  for (let i = 1; i < projects.length; i++) {
    if (projects[i].updatedAt < oldest.updatedAt) oldest = projects[i]
    if (projects[i].updatedAt > newest.updatedAt) newest = projects[i]
  }

  return { oldest, newest }
}
```

배열을 한 번만 순회하며, 복사도 정렬도 없습니다.

**대안 (작은 배열에는 Math.min/Math.max):**

```typescript
const numbers = [5, 2, 8, 1, 9]
const min = Math.min(...numbers)
const max = Math.max(...numbers)
```

이는 작은 배열에서는 작동하지만 스프레드 연산자의 제한으로 인해 매우 큰 배열에서는 느릴 수 있습니다. 신뢰성을 위해 루프 방식을 사용하세요.
