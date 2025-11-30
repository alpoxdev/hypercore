# TanStack Query - useMutation

> **상위 문서**: [TanStack Query](./index.md)

## 기본 사용법

```tsx
import { useMutation, useQueryClient } from '@tanstack/react-query'

function AddTodo() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: postTodo,
    onSuccess: () => {
      // 성공 시 todos 쿼리 무효화하여 재조회
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },
  })

  return (
    <button
      onClick={() => {
        mutation.mutate({
          id: Date.now(),
          title: 'Do Laundry',
        })
      }}
    >
      Add Todo
    </button>
  )
}
```

## useMutation 반환 값

```typescript
const {
  data,           // mutation 결과 데이터
  error,          // 에러 객체
  isError,        // 에러 상태
  isIdle,         // 아직 실행 안 됨
  isPending,      // 실행 중
  isPaused,       // 일시 정지됨
  isSuccess,      // 성공 상태
  failureCount,   // 실패 횟수
  failureReason,  // 실패 이유
  mutate,         // mutation 실행 (비동기)
  mutateAsync,    // mutation 실행 (Promise 반환)
  reset,          // 상태 초기화
  status,         // 'idle' | 'pending' | 'success' | 'error'
  submittedAt,    // 제출 시간
  variables,      // 전달된 변수
} = useMutation({ mutationFn })
```

## useMutation 옵션

```tsx
const mutation = useMutation({
  mutationFn,
  gcTime,             // 가비지 컬렉션 시간
  meta,               // 메타데이터
  mutationKey,        // mutation 키
  networkMode,        // 네트워크 모드
  onError,            // 에러 콜백
  onMutate,           // mutation 시작 전 콜백
  onSettled,          // 완료 후 콜백 (성공/실패 무관)
  onSuccess,          // 성공 콜백
  retry,              // 재시도 횟수
  retryDelay,         // 재시도 딜레이
  scope,              // 범위
  throwOnError,       // 에러 throw 여부
})
```

## 콜백 함수들

```tsx
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // mutation 시작 전 실행
    console.log('Starting mutation with:', newTodo)
    return { previousData: 'something' } // context로 전달
  },
  onSuccess: (data, variables, context) => {
    // 성공 시 실행
    console.log('Success:', data)
    console.log('Variables:', variables)
    console.log('Context:', context)
  },
  onError: (error, variables, context) => {
    // 에러 시 실행
    console.log('Error:', error)
    // context로 롤백 가능
  },
  onSettled: (data, error, variables, context) => {
    // 성공/실패 무관하게 완료 시 실행
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

## mutate vs mutateAsync

```tsx
// mutate - 콜백 기반
mutation.mutate(data, {
  onSuccess: (result) => {
    console.log('Success:', result)
  },
  onError: (error) => {
    console.log('Error:', error)
  },
})

// mutateAsync - Promise 기반
try {
  const result = await mutation.mutateAsync(data)
  console.log('Success:', result)
} catch (error) {
  console.log('Error:', error)
}
```

## Error 상태 Reset

```tsx
const CreateTodo = () => {
  const [title, setTitle] = useState('')
  const mutation = useMutation({ mutationFn: createTodo })

  const onCreateTodo = (e) => {
    e.preventDefault()
    mutation.mutate({ title })
  }

  return (
    <form onSubmit={onCreateTodo}>
      {mutation.error && (
        <h5 onClick={() => mutation.reset()}>{mutation.error}</h5>
      )}
      <input
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />
      <br />
      <button type="submit">Create Todo</button>
    </form>
  )
}
```

## 캐시 직접 업데이트

```tsx
const saveMutation = useMutation({
  mutationFn: patchTodo,
  onSuccess: (data) => {
    // 목록 쿼리 무효화
    queryClient.invalidateQueries({ queryKey: ['todos'] })

    // 개별 항목 캐시 직접 업데이트
    queryClient.setQueryData(['todo', { id: data.id }], data)
  },
})
```
