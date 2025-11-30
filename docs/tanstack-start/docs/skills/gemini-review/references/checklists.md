# Review Checklists by Tech Stack

## FastAPI Checklist

### API Design
- [ ] RESTful conventions followed (proper HTTP methods, status codes)
- [ ] Consistent URL naming (kebab-case, plural nouns)
- [ ] Proper use of path vs query parameters
- [ ] API versioning strategy (if applicable)
- [ ] Response model consistency across endpoints

### Pydantic Models
- [ ] Field validation with appropriate constraints (min, max, regex)
- [ ] Optional vs required fields correctly defined
- [ ] Proper use of `Field()` for metadata and examples
- [ ] Config class settings (orm_mode, validate_assignment)
- [ ] Custom validators where needed

### Async Patterns
- [ ] Async/await used consistently
- [ ] No blocking I/O in async functions
- [ ] Proper use of `asyncio.gather()` for concurrent operations
- [ ] Background tasks for long-running operations
- [ ] Connection pooling for databases

### Security
- [ ] Authentication implemented (OAuth2, JWT, API keys)
- [ ] Authorization checks on protected endpoints
- [ ] Input sanitization and validation
- [ ] CORS configuration appropriate for use case
- [ ] Rate limiting consideration
- [ ] Secrets not hardcoded

### Error Handling
- [ ] Custom exception handlers defined
- [ ] Consistent error response format
- [ ] Proper HTTP status codes for errors
- [ ] Sensitive information not leaked in errors

### Performance
- [ ] Database queries optimized (N+1 problem avoided)
- [ ] Pagination for list endpoints
- [ ] Caching strategy where appropriate
- [ ] Response model excludes unnecessary fields

### Testing
- [ ] Test client setup with TestClient
- [ ] Dependency overrides for mocking
- [ ] Coverage of happy path and edge cases

---

## Next.js Checklist

### Rendering Strategy
- [ ] Appropriate use of SSR vs SSG vs ISR vs CSR
- [ ] `getStaticProps` for static content
- [ ] `getServerSideProps` only when necessary
- [ ] ISR with proper revalidation intervals
- [ ] Client-side fetching for user-specific data

### Routing
- [ ] File-based routing structure organized
- [ ] Dynamic routes properly parameterized
- [ ] Catch-all routes used appropriately
- [ ] Route groups for organization (App Router)
- [ ] Parallel routes if needed

### Data Fetching
- [ ] SWR or React Query for client-side
- [ ] Proper loading and error states
- [ ] Optimistic updates where appropriate
- [ ] Cache invalidation strategy

### State Management
- [ ] Server state vs client state separated
- [ ] Zustand/Jotai for simple state
- [ ] Context used sparingly
- [ ] State lifted appropriately

### Performance
- [ ] Image optimization with next/image
- [ ] Font optimization with next/font
- [ ] Code splitting and lazy loading
- [ ] Bundle size monitored
- [ ] Core Web Vitals considered

### SEO
- [ ] Metadata properly configured
- [ ] Open Graph tags present
- [ ] Structured data where appropriate
- [ ] Sitemap generation
- [ ] robots.txt configured

### Security
- [ ] API routes protected
- [ ] Environment variables properly used
- [ ] CSRF protection if needed
- [ ] Content Security Policy headers

### TypeScript
- [ ] Strict mode enabled
- [ ] Props interfaces defined
- [ ] API response types defined
- [ ] No `any` types without justification

---

## General Checklist

### Code Quality
- [ ] Single responsibility principle followed
- [ ] DRY - no unnecessary duplication
- [ ] Functions/methods are focused and small
- [ ] Clear naming conventions
- [ ] Comments explain "why", not "what"

### Logic & Correctness
- [ ] Edge cases handled (empty, null, boundary values)
- [ ] Error handling comprehensive
- [ ] Race conditions considered
- [ ] Input validation present
- [ ] Return values checked

### Security
- [ ] No hardcoded secrets
- [ ] User input sanitized
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevention measures
- [ ] Authentication/authorization proper

### Performance
- [ ] Time complexity acceptable for scale
- [ ] Space complexity reasonable
- [ ] No unnecessary loops or iterations
- [ ] Database queries optimized
- [ ] Caching considered where appropriate

### Maintainability
- [ ] Code is testable
- [ ] Dependencies minimal and justified
- [ ] Configuration externalized
- [ ] Logging present for debugging
- [ ] Error messages helpful

### Documentation
- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] Setup instructions clear
- [ ] Environment variables documented