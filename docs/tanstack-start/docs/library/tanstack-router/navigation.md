# TanStack Router - Navigation

Link 컴포넌트와 프로그래밍 네비게이션.

## Link 컴포넌트

```tsx
import { Link } from '@tanstack/react-router'

// 기본
<Link to="/about">About</Link>

// 동적 파라미터
<Link to="/posts/$postId" params={{ postId: '123' }}>
  Post 123
</Link>

// Search params
<Link to="/products" search={{ page: 1, sort: 'newest' }}>
  Products
</Link>

// Search params 병합
<Link to="/products" search={prev => ({ ...prev, page: 2 })}>
  Next Page
</Link>

// Active 스타일
<Link
  to="/about"
  activeProps={{ className: 'text-blue-500 font-bold' }}
  inactiveProps={{ className: 'text-gray-500' }}
>
  About
</Link>

// 정확히 일치할 때만 active
<Link to="/" activeOptions={{ exact: true }}>
  Home
</Link>
```

## Link Props

| Prop | 타입 | 설명 |
|------|------|------|
| `to` | string | 목적지 경로 |
| `params` | object | Path 파라미터 |
| `search` | object \| function | Search params |
| `hash` | string | Hash |
| `replace` | boolean | history replace |
| `preload` | 'intent' \| 'render' \| 'viewport' | Preload 전략 |
| `activeProps` | object | Active 시 props |
| `inactiveProps` | object | Inactive 시 props |

## useNavigate

```tsx
import { useNavigate } from '@tanstack/react-router'

function Component() {
  const navigate = useNavigate()

  // 기본
  const goToAbout = () => {
    navigate({ to: '/about' })
  }

  // 동적 파라미터
  const goToPost = (postId: string) => {
    navigate({ to: '/posts/$postId', params: { postId } })
  }

  // Search params
  const updateSearch = () => {
    navigate({
      to: '/products',
      search: prev => ({ ...prev, page: 2 }),
    })
  }

  // Replace (뒤로가기 안 됨)
  const replaceRoute = () => {
    navigate({ to: '/login', replace: true })
  }

  // 상대 경로
  const goUp = () => {
    navigate({ to: '..' })
  }

  return (
    <button onClick={goToAbout}>Go to About</button>
  )
}
```

## navigate 옵션

| 옵션 | 타입 | 설명 |
|------|------|------|
| `to` | string | 목적지 경로 |
| `params` | object | Path 파라미터 |
| `search` | object \| function | Search params |
| `hash` | string | Hash |
| `replace` | boolean | history.replace 사용 |
| `resetScroll` | boolean | 스크롤 리셋 |

## Preloading

```tsx
// hover 시 preload
<Link to="/posts" preload="intent">
  Posts
</Link>

// 렌더링 시 preload
<Link to="/dashboard" preload="render">
  Dashboard
</Link>

// viewport 진입 시 preload
<Link to="/products" preload="viewport">
  Products
</Link>
```

## 조건부 네비게이션

```tsx
function SubmitButton() {
  const navigate = useNavigate()
  const [isPending, startTransition] = useTransition()

  const handleSubmit = async () => {
    const result = await submitForm()
    if (result.success) {
      startTransition(() => {
        navigate({ to: '/success' })
      })
    }
  }

  return (
    <button onClick={handleSubmit} disabled={isPending}>
      Submit
    </button>
  )
}
```
