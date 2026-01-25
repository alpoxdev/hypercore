---
title: Early Length Check for Array Comparisons
impact: MEDIUM-HIGH
impactDescription: avoids expensive operations when lengths differ
tags: javascript, arrays, performance, optimization, comparison
---

## 배열 비교 시 길이 우선 체크

정렬, 깊은 비교, 직렬화 등 비용이 큰 연산으로 배열을 비교할 때는 길이를 먼저 확인하세요. 길이가 다르면 배열이 같을 수 없습니다.

실제 애플리케이션에서 이 최적화는 비교가 핫 패스(이벤트 핸들러, 렌더 루프)에서 실행될 때 특히 유용합니다.

**❌ 잘못된 예 (항상 비싼 비교 실행):**

```typescript
function hasChanges(current: string[], original: string[]) {
  // 길이가 다른 경우에도 항상 정렬과 join 실행
  return current.sort().join() !== original.sort().join()
}
```

`current.length`가 5이고 `original.length`가 100인 경우에도 두 개의 O(n log n) 정렬이 실행됩니다. 배열을 join하고 문자열을 비교하는 오버헤드도 발생합니다.

**✅ 올바른 예 (O(1) 길이 체크 우선):**

```typescript
function hasChanges(current: string[], original: string[]) {
  // 길이가 다르면 조기 반환
  if (current.length !== original.length) {
    return true
  }
  // 길이가 같을 때만 정렬/join
  const currentSorted = current.toSorted()
  const originalSorted = original.toSorted()
  for (let i = 0; i < currentSorted.length; i++) {
    if (currentSorted[i] !== originalSorted[i]) {
      return true
    }
  }
  return false
}
```

이 새로운 접근 방식이 더 효율적인 이유:
- 길이가 다를 때 정렬과 join의 오버헤드를 피함
- join된 문자열을 위한 메모리 소비를 피함 (특히 큰 배열에 중요)
- 원본 배열 변형을 피함
- 차이를 발견하면 조기 반환
