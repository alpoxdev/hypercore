# TanStack Query - Query 무효화

<patterns>

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

// 옵션
queryClient.invalidateQueries({
  queryKey: ['posts'],
  exact: true,  // 정확한 키 매칭만
  refetchType: 'active',  // 'active' | 'inactive' | 'all' | 'none'
})

// Query Key 매칭
queryClient.invalidateQueries({ queryKey: ['todos'] })  // prefix 매칭
queryClient.invalidateQueries({ queryKey: ['todos', 'list'], exact: true })  // 정확한 매칭

// Mutation과 함께
useMutation({
  mutationFn: addTodo,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),  // 성공/실패 무관
})

// 직접 업데이트 vs 무효화
queryClient.setQueryData(['todos'], (old) => [...old, newTodo])  // 더 빠름
queryClient.invalidateQueries({ queryKey: ['todos'] })  // 서버 데이터 보장
```

</patterns>

<options>

| refetchType | 설명 |
|-------------|------|
| active | 렌더링 중인 쿼리만 재조회 (기본) |
| inactive | 비활성 쿼리만 |
| all | 모든 매칭 쿼리 |
| none | 무효화만, 재조회 안함 |

</options>
