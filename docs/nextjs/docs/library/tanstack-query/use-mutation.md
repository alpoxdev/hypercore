# TanStack Query - useMutation

<patterns>

```tsx
// 기본
const queryClient = useQueryClient()
const mutation = useMutation({
  mutationFn: postTodo,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})
mutation.mutate({ title: 'New Todo' })

// 콜백
useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // mutation 시작 전 (optimistic update용)
    return { previousData }  // context로 전달
  },
  onSuccess: (data, variables, context) => {},
  onError: (error, variables, context) => {},
  onSettled: (data, error, variables, context) => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})

// mutate vs mutateAsync
mutation.mutate(data, {
  onSuccess: (result) => console.log(result),
  onError: (error) => console.log(error),
})

try {
  const result = await mutation.mutateAsync(data)
} catch (error) { ... }

// 캐시 업데이트
useMutation({
  mutationFn: patchTodo,
  onSuccess: (data) => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
    queryClient.setQueryData(['todo', { id: data.id }], data)
  },
})
```

</patterns>

<returns>

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

</returns>
