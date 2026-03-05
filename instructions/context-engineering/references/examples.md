# Examples - 실전 패턴

## Agentic Coding

```xml
<coding_guidelines>

<investigation>
ALWAYS read files before proposing edits.
Use Explore agent for codebase discovery.
Do not speculate about code structure.
</investigation>

<implementation>
Avoid over-engineering.
Only make directly requested changes.
Don't add features unless asked.
Keep solutions simple and focused.
</implementation>

<testing>
Run tests after changes.
Verify no regressions.
Add new tests for new features.
</testing>

</coding_guidelines>
```

---

## Frontend Design

```xml
<frontend_aesthetics>

Avoid generic "AI slop" aesthetic.
Make creative, distinctive frontends that stand out.

<focus>

**Typography**
- Unique font combinations
- Avoid overused fonts (Inter, Roboto)
- Consider: Geist, Cal Sans, Untitled Sans

**Color**
- Cohesive theme with sharp accents
- Use color psychology
- Dark mode by default (better aesthetics)

**Motion**
- High-impact animations (Framer Motion, GSAP)
- Smooth transitions
- Micro-interactions

**Backgrounds**
- Depth and atmosphere
- Gradients, meshes, noise
- Avoid flat single colors

</focus>

<frameworks>
- TailwindCSS for utility-first
- shadcn/ui for components
- Framer Motion for animations
</frameworks>

</frontend_aesthetics>
```

---

## API Design

```xml
<api_guidelines>

<rest_patterns>

**Naming**
- Resource-oriented: `/users/:id/posts`
- Kebab-case: `/user-profiles`
- Versioning: `/api/v1/...`

**Methods**
- GET: Read (safe, idempotent)
- POST: Create
- PUT: Full update (idempotent)
- PATCH: Partial update
- DELETE: Remove (idempotent)

**Responses**
200 OK: Success
201 Created: Resource created
400 Bad Request: Invalid input
401 Unauthorized: Auth required
404 Not Found: Resource missing
500 Internal Error: Server error

</rest_patterns>

<validation>
- Validate at boundary (input validators)
- Use Zod/Yup schemas
- Return detailed error messages
- Never trust client input
</validation>

</api_guidelines>
```

---

## Database Schema

```xml
<schema_design>

<naming>
- Tables: plural (`users`, `posts`)
- Columns: snake_case (`created_at`)
- Foreign keys: `{table}_id` (`user_id`)
- Indexes: `idx_{table}_{column}`
</naming>

<relationships>
- One-to-Many: Foreign key on "many" side
- Many-to-Many: Junction table
- Cascade deletes: Be explicit
</relationships>

<best_practices>
- Always use timestamps (`created_at`, `updated_at`)
- Soft deletes: `deleted_at` (optional)
- UUID vs Auto-increment: Consider scale
- Index frequently queried columns
</best_practices>

</schema_design>
```

---

## Error Handling

```xml
<error_patterns>

**Client-Side (React)**
```typescript
try {
  const data = await api.fetch()
  return data
} catch (error) {
  if (error.status === 401) {
    redirect('/login')
  }
  toast.error(error.message)
  throw error // Re-throw for React Query
}
```

**Server-Side (API)**
```typescript
try {
  const result = await db.query()
  return result
} catch (error) {
  logger.error(error)
  if (error instanceof ValidationError) {
    throw new HttpError(400, error.message)
  }
  throw new HttpError(500, 'Internal error')
}
```

**User-Facing Messages**
- Technical: "DatabaseConnectionError"
- User: "서비스 일시 중단. 잠시 후 다시 시도해주세요."

</error_patterns>
```

---

## Testing Patterns

```xml
<test_guidelines>

**Unit Tests**
```typescript
describe('calculateTotal', () => {
  it('sums item prices', () => {
    expect(calculateTotal([10, 20])).toBe(30)
  })

  it('handles empty array', () => {
    expect(calculateTotal([])).toBe(0)
  })
})
```

**Integration Tests**
```typescript
describe('POST /api/users', () => {
  it('creates user', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ name: 'John' })

    expect(res.status).toBe(201)
    expect(res.body.name).toBe('John')
  })
})
```

**Component Tests**
```typescript
test('renders user profile', () => {
  render(<Profile user={mockUser} />)
  expect(screen.getByText('John')).toBeInTheDocument()
})
```

</test_guidelines>
```

---

## Git Commit Messages

```xml
<commit_style>

**Format**
```
<type>: <subject>

[optional body]
```

**Types**
- feat: New feature
- fix: Bug fix
- refactor: Code restructure
- style: Formatting
- docs: Documentation
- test: Tests
- chore: Maintenance

**Examples**
```
feat: add user authentication
fix: resolve login redirect loop
refactor: extract auth logic to hook
docs: update API documentation
```

**Rules**
- Subject: 50 chars max
- Imperative mood ("add" not "added")
- No period at end
- One logical change per commit

</commit_style>
```

---

## Security Patterns

```xml
<security>

**Input Validation**
- Sanitize all user input
- Use parameterized queries (prevent SQL injection)
- Validate file uploads (type, size)
- Escape HTML output (prevent XSS)

**Authentication**
- Hash passwords (bcrypt, argon2)
- Use secure session tokens
- Implement rate limiting
- Add CSRF protection

**API Security**
- API keys in env vars
- HTTPS only
- CORS configuration
- Input size limits

**Never**
- Store passwords in plain text
- Trust client-side validation
- Expose sensitive data in errors
- Use deprecated crypto

</security>
```

---

## Performance Optimization

```xml
<performance>

**React**
```typescript
// Memoization
const expensiveValue = useMemo(() =>
  heavyCalculation(data), [data]
)

// Callback stability
const handleClick = useCallback(() => {
  doSomething(id)
}, [id])

// Component memoization
export default React.memo(ExpensiveComponent)
```

**Code Splitting**
```typescript
const Heavy = lazy(() => import('./Heavy'))

<Suspense fallback={<Spinner />}>
  <Heavy />
</Suspense>
```

**API**
- Pagination: Limit results
- Caching: Redis, CDN
- N+1 queries: Use JOIN or DataLoader
- Compression: gzip, brotli

</performance>
```

---

## 요약

모든 예시는 **복사 가능**하도록 작성.
패턴을 그대로 적용하고, 프로젝트에 맞게 조정.
