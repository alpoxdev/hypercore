# TanStack Router - Navigation

<patterns>

```tsx
// Link
<Link to="/about">About</Link>
<Link to="/posts/$postId" params={{ postId: '123' }}>Post 123</Link>
<Link to="/products" search={{ page: 1, sort: 'newest' }}>Products</Link>
<Link to="/products" search={prev => ({ ...prev, page: 2 })}>Next</Link>

// Active styles
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
<Link to="/posts" preload="intent">Posts</Link>       // On hover
<Link to="/dashboard" preload="render">Dash</Link>    // On render
<Link to="/products" preload="viewport">Prod</Link>   // On viewport entry

// Conditional navigation
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

| Link Props | Type | Description |
|------------|------|------|
| `to` | string | Destination path |
| `params` | object | Path parameters |
| `search` | object \| function | Search params |
| `hash` | string | Hash |
| `replace` | boolean | Use history replace |
| `preload` | 'intent' \| 'render' \| 'viewport' | Preload strategy |
| `activeProps` | object | Props when active |
| `inactiveProps` | object | Props when inactive |

| navigate Options | Type | Description |
|---------------|------|------|
| `to` | string | Destination path |
| `params` | object | Path parameters |
| `search` | object \| function | Search params |
| `hash` | string | Hash |
| `replace` | boolean | Use history.replace |
| `resetScroll` | boolean | Reset scroll |

</options>
