# TanStack Query - useMutation

## 기본 사용법

```tsx
const queryClient = useQueryClient()

const mutation = useMutation({
  mutationFn: postTodo,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})

mutation.mutate({ title: 'New Todo' })
```

## 반환값

| 속성 | 설명 |
|------|------|
| data | mutation 결과 |
| error | 에러 객체 |
| isPending | 실행 중 |
| isSuccess/isError | 상태 |
| mutate | 실행 (비동기) |
| mutateAsync | 실행 (Promise) |
| reset | 상태 초기화 |
| variables | 전달된 변수 |

## 콜백

```tsx
useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // mutation 시작 전 (optimistic update용)
    return { previousData }  // context로 전달
  },
  onSuccess: (data, variables, context) => {
    // 성공 시
  },
  onError: (error, variables, context) => {
    // 에러 시 (context로 롤백)
  },
  onSettled: (data, error, variables, context) => {
    // 완료 시 (성공/실패 무관)
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

## mutate vs mutateAsync

```tsx
// 콜백 기반
mutation.mutate(data, {
  onSuccess: (result) => console.log(result),
  onError: (error) => console.log(error),
})

// Promise 기반
try {
  const result = await mutation.mutateAsync(data)
} catch (error) { ... }
```

## 캐시 업데이트

```tsx
useMutation({
  mutationFn: patchTodo,
  onSuccess: (data) => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })  // 목록 무효화
    queryClient.setQueryData(['todo', { id: data.id }], data)  // 개별 캐시 업데이트
  },
})
```
