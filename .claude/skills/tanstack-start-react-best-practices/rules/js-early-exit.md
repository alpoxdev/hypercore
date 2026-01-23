---
title: Early Return from Functions
impact: LOW-MEDIUM
impactDescription: avoids unnecessary computation
tags: javascript, functions, optimization, early-return
---

## 함수에서 조기 반환

결과가 결정되면 불필요한 처리를 건너뛰기 위해 조기 반환하세요.

**잘못된 예 (답을 찾은 후에도 모든 항목 처리):**

```typescript
function validateUsers(users: User[]) {
  let hasError = false
  let errorMessage = ''

  for (const user of users) {
    if (!user.email) {
      hasError = true
      errorMessage = 'Email required'
    }
    if (!user.name) {
      hasError = true
      errorMessage = 'Name required'
    }
    // 오류를 찾은 후에도 모든 사용자를 계속 확인함
  }

  return hasError ? { valid: false, error: errorMessage } : { valid: true }
}
```

**올바른 예 (첫 번째 오류에서 즉시 반환):**

```typescript
function validateUsers(users: User[]) {
  for (const user of users) {
    if (!user.email) {
      return { valid: false, error: 'Email required' }
    }
    if (!user.name) {
      return { valid: false, error: 'Name required' }
    }
  }

  return { valid: true }
}
```
