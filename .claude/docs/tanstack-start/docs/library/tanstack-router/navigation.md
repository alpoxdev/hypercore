# TanStack Router - Navigation

<patterns>

```tsx
// Link
<Link to="/about">About</Link>
<Link to="/posts/$postId" params={{ postId: '123' }}>Post 123</Link>
<Link to="/products" search={{ page: 1, sort: 'newest' }}>Products</Link>
<Link to="/products" search={prev => ({ ...prev, page: 2 })}>Next</Link>

// Active 스타일
<Link
  to="/about"
  activeProps={{ className: 'text-blue-500 font-bold' }}
  inactiveProps={{ className: 'text-gray-500' }}
>
  About
</Link>
<Link to="/" activeOptions={{ exact: true }}>Home</Link>

// useNavigate
const Component = () => {
  const navigate = useNavigate()

  const goToAbout = () => navigate({ to: '/about' })
  const goToPost = (id: string) => navigate({ to: '/posts/$postId', params: { postId: id } })
  const updateSearch = () => navigate({ to: '/products', search: prev => ({ ...prev, page: 2 }) })
  const replaceRoute = () => navigate({ to: '/login', replace: true })
  const goUp = () => navigate({ to: '..' })

  return <button onClick={goToAbout}>Go</button>
}

// Preloading
<Link to="/posts" preload="intent">Posts</Link>       // hover 시
<Link to="/dashboard" preload="render">Dash</Link>    // 렌더링 시
<Link to="/products" preload="viewport">Prod</Link>   // viewport 진입 시

// 조건부 네비게이션
const SubmitButton = () => {
  const navigate = useNavigate()
  const [isPending, startTransition] = useTransition()

  const handleSubmit = async () => {
    const result = await submitForm()
    if (result.success) {
      startTransition(() => navigate({ to: '/success' }))
    }
  }

  return <button onClick={handleSubmit} disabled={isPending}>Submit</button>
}
```

</patterns>

<options>

| Link Props | 타입 | 설명 |
|------------|------|------|
| `to` | string | 목적지 경로 |
| `params` | object | Path 파라미터 |
| `search` | object \| function | Search params |
| `hash` | string | Hash |
| `replace` | boolean | history replace |
| `preload` | 'intent' \| 'render' \| 'viewport' | Preload 전략 |
| `activeProps` | object | Active 시 props |
| `inactiveProps` | object | Inactive 시 props |

| navigate 옵션 | 타입 | 설명 |
|---------------|------|------|
| `to` | string | 목적지 경로 |
| `params` | object | Path 파라미터 |
| `search` | object \| function | Search params |
| `hash` | string | Hash |
| `replace` | boolean | history.replace 사용 |
| `resetScroll` | boolean | 스크롤 리셋 |

</options>
