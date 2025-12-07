# TanStack Query - Query 무효화

## 기본 무효화

```typescript
const queryClient = useQueryClient()

// 단일
queryClient.invalidateQueries({ queryKey: ['todos'] })

// 다중
await Promise.all([
  queryClient.invalidateQueries({ queryKey: ['todos'] }),
  queryClient.invalidateQueries({ queryKey: ['reminders'] }),
])

// 전체
queryClient.invalidateQueries()
```

## 옵션

```typescript
queryClient.invalidateQueries({
  queryKey: ['posts'],
  exact: true,  // 정확한 키 매칭만
  refetchType: 'active',  // 'active'(기본) | 'inactive' | 'all' | 'none'
})
```

| refetchType | 설명 |
|-------------|------|
| active | 렌더링 중인 쿼리만 재조회 (기본) |
| inactive | 비활성 쿼리만 |
| all | 모든 매칭 쿼리 |
| none | 무효화만, 재조회 안함 |

## Query Key 매칭

```typescript
// prefix 매칭 (todos로 시작하는 모든 쿼리)
queryClient.invalidateQueries({ queryKey: ['todos'] })

// 정확한 매칭
queryClient.invalidateQueries({ queryKey: ['todos', 'list'], exact: true })
```

## Mutation과 함께

```tsx
useMutation({
  mutationFn: addTodo,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  // 또는 onSettled (성공/실패 무관)
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})
```

## 캐시 직접 업데이트 vs 무효화

```tsx
// 직접 업데이트 (더 빠름)
queryClient.setQueryData(['todos'], (old) => [...old, newTodo])

// 무효화 (서버 데이터 보장)
queryClient.invalidateQueries({ queryKey: ['todos'] })
```
