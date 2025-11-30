# Review Checklists by Tech Stack

## Hono Checklist

### API Design
- [ ] RESTful conventions followed (proper HTTP methods, status codes)
- [ ] Consistent URL naming (kebab-case, plural nouns)
- [ ] Proper use of path vs query parameters
- [ ] Response format consistency (c.json, c.text, c.html)
- [ ] Appropriate use of c.notFound() and error responses

### Middleware
- [ ] Middleware order is correct (auth before route handlers)
- [ ] createMiddleware used for typed middleware
- [ ] Middleware properly passes control with next()
- [ ] Built-in middleware configured correctly (cors, logger, etc.)
- [ ] Custom middleware is reusable and testable

### Validation (zValidator)
- [ ] All POST/PUT/PATCH routes have zValidator
- [ ] Validation targets correct: json, query, param, header, form
- [ ] Zod v4 syntax used (z.email(), z.url())
- [ ] Custom error handling in zValidator callback
- [ ] Schema reuse across related endpoints

### Error Handling
- [ ] HTTPException used for HTTP errors
- [ ] Global onError handler configured
- [ ] Error responses have consistent format
- [ ] Sensitive information not leaked in errors
- [ ] Custom error classes for business logic errors

### Type Safety
- [ ] Bindings type defined for environment variables
- [ ] Variables type defined for request context
- [ ] c.env and c.var properly typed
- [ ] RPC types exported (AppType)
- [ ] InferRequestType/InferResponseType used in clients

### Security
- [ ] Authentication middleware on protected routes
- [ ] Bearer token or JWT validation implemented
- [ ] CORS configured appropriately
- [ ] Rate limiting considered
- [ ] Secrets accessed via c.env, not hardcoded

---

## Cloudflare Workers Checklist

### Bindings Configuration
- [ ] wrangler.toml properly configured
- [ ] All bindings declared (KV, D1, R2, etc.)
- [ ] Binding types match wrangler.toml
- [ ] Environment variables set for secrets
- [ ] compatibility_flags includes nodejs_compat if needed

### KV Namespace
- [ ] Keys are properly namespaced
- [ ] TTL (expirationTtl) set where appropriate
- [ ] Metadata used for additional key info
- [ ] List operations use prefix and cursor for pagination
- [ ] Error handling for KV operations

### D1 Database
- [ ] Prepared statements used (no string concatenation)
- [ ] Batch operations for multiple queries
- [ ] Error handling for database operations
- [ ] Schema migrations managed properly
- [ ] Indexes created for frequently queried columns

### R2 Bucket
- [ ] Content-Type set on uploads
- [ ] Proper error handling for missing objects
- [ ] Multipart uploads for large files
- [ ] Custom metadata used appropriately
- [ ] Access control configured

### Edge Runtime
- [ ] No Node.js-specific APIs used
- [ ] Web APIs used (fetch, Request, Response)
- [ ] Memory limits considered (<128MB)
- [ ] CPU time limits considered (<30s)
- [ ] Subrequests limit considered (<50)

### Deployment
- [ ] Environment-specific wrangler.toml sections
- [ ] Secrets set via wrangler secret put
- [ ] Preview deployments working
- [ ] Production deployment tested
- [ ] Rollback strategy in place

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
