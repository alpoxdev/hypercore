---
title: Cache Storage API Calls
impact: LOW-MEDIUM
impactDescription: reduces expensive I/O
tags: javascript, localStorage, storage, caching, performance
---

## Storage API 호출 캐싱

`localStorage`, `sessionStorage`, `document.cookie`는 동기적이고 비용이 많이 듭니다. 읽기를 메모리에 캐시하세요.

**❌ 잘못된 예시 (호출할 때마다 스토리지 읽기):**

```typescript
function getTheme() {
  return localStorage.getItem('theme') ?? 'light'
}
// 10번 호출 = 10번 스토리지 읽기
```

**✅ 올바른 예시 (Map 캐시):**

```typescript
const storageCache = new Map<string, string | null>()

function getLocalStorage(key: string) {
  if (!storageCache.has(key)) {
    storageCache.set(key, localStorage.getItem(key))
  }
  return storageCache.get(key)
}

function setLocalStorage(key: string, value: string) {
  localStorage.setItem(key, value)
  storageCache.set(key, value)  // 캐시를 동기화된 상태로 유지
}
```

Map을 사용하세요 (훅이 아님). 그래야 유틸리티, 이벤트 핸들러 등 어디서든 작동합니다 (React 컴포넌트뿐만 아니라).

**쿠키 캐싱:**

```typescript
let cookieCache: Record<string, string> | null = null

function getCookie(name: string) {
  if (!cookieCache) {
    cookieCache = Object.fromEntries(
      document.cookie.split('; ').map(c => c.split('='))
    )
  }
  return cookieCache[name]
}
```

**중요 (외부 변경 시 무효화):**

스토리지가 외부에서 변경될 수 있는 경우 (다른 탭, 서버 설정 쿠키), 캐시를 무효화하세요:

```typescript
window.addEventListener('storage', (e) => {
  if (e.key) storageCache.delete(e.key)
})

document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible') {
    storageCache.clear()
  }
})
```
