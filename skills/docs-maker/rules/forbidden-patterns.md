# Forbidden Patterns (Anti-Patterns)

**Purpose**: Prevent repeated mistakes and keep quality stable.

## Language and Expression

### Avoid speculative wording

| Forbidden expression | Why | Better expression |
|----------|------|-------------|
| "should" without evidence | uncertain | "verified result: ~" |
| "probably" | speculation | "verification shows ~" |
| "seems to" | ambiguous | "analysis shows ~" |
| "maybe" | speculation | "needs verification" / direct fact |
| "looks like" | uncertain | direct fact |
| "should work" | speculative | "confirmed by tests" |
| "mostly" | vague | quantified statement (e.g., "in 90% of cases") |

**Rule**: Assert only validated facts. If uncertain, verify first.

## Code Authoring

### Forbidden 1: `any` type

```typescript
// ❌ forbidden
function process(data: any) {
  return data.value
}

// ✅ preferred
function process(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return (data as { value: string }).value
  }
  throw new Error('Invalid data')
}
```

### Forbidden 2: `@ts-ignore`

```typescript
// ❌ forbidden
// @ts-ignore
const result = getData()

// ✅ preferred
const result = getData() as ExpectedType
// or fix the type definitions
```

### Forbidden 3: deleting or muting failing tests

```typescript
// ❌ forbidden: disable failing test
// describe('login', () => { ... })

// ✅ preferred: fix implementation so tests pass
function login(email: string, password: string) {
  // bug fix
}
```

### Forbidden 4: swallowing errors

```typescript
// ❌ forbidden
try {
  await dangerousOperation()
} catch (e) {
  // ignore
}

// ✅ preferred
try {
  await dangerousOperation()
} catch (error) {
  logger.error('Operation failed', error)
  throw new Error('Failed to perform operation')
}
```

## Workflow

### Forbidden 5: skipping verification stages

```markdown
❌ Phase 1 -> Phase 4 (jump)
❌ Phase 1 -> Phase 3 (skip /pre-deploy)
❌ Partial validation only (lint only)

✅ Phase 1 -> 2 -> 3 -> 4 (sequential)
✅ Run full /pre-deploy (typecheck, lint, build)
```

### Forbidden 6: early "done" declaration

```typescript
// ❌ forbidden
// "Implementation is complete" (without verification)
<promise>DONE</promise>

// ✅ preferred
Skill("pre-deploy")
TaskList()
Task(subagent_type="planner", ...)
<promise>DONE</promise>
```

### Forbidden 7: sequential execution when parallel is possible

```typescript
// ❌ forbidden (sequential)
Read({ file_path: "file1.ts" })
// wait...
Read({ file_path: "file2.ts" })

// ✅ preferred (parallel)
Read({ file_path: "file1.ts" })
Read({ file_path: "file2.ts" })
Read({ file_path: "file3.ts" })
```

### Forbidden 8: not delegating to agents

```typescript
// ❌ forbidden: do everything alone
Glob(...)
Read(...)
Read(...)
Edit(...)
Edit(...)

// ✅ preferred: delegate specialized tasks
Task(subagent_type="explore", model="haiku", ...)
Task(subagent_type="implementation-executor", model="sonnet", ...)
```

## Git Operations

### Forbidden 9: AI signatures and noisy commit formatting

```bash
# ❌ forbidden
git commit -m "feat: implement login

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# ❌ forbidden
git commit -m "🤖 feat: implement login"

# ✅ preferred
git commit -m "feat: implement login"
```

### Forbidden 10: direct Git execution via generic Bash pipeline

```typescript
// ❌ forbidden
Bash({ command: "git add . && git commit -m 'fix' && git push" })

// ✅ preferred
Task(subagent_type="git-operator", model="haiku",
     prompt="commit and push the current changes")
```

## Database

### Forbidden 11: automatic Prisma execution without user intent

```bash
# ❌ forbidden (auto-execution)
prisma db push
prisma migrate dev
prisma generate

# ✅ preferred (request/confirm before execution)
echo "schema.prisma updated. Run 'prisma db push' when ready"
```

### Forbidden 12: unrequested schema changes

```prisma
// ❌ forbidden: modify schema without explicit request
model User {
  id Int @id @default(autoincrement())
  email String @unique
}

// ✅ preferred: implement only requested changes
```

## API Implementation

### Forbidden 13: manual validation/auth inside handler when platform pattern exists

```typescript
// ❌ forbidden
export const createUser = createServerFn({ method: 'POST' })
  .handler(async ({ data }) => {
    if (!data.email) throw new Error('Email required')
    if (!request.session) throw new Error('Unauthorized')
    return prisma.user.create({ data })
  })

// ✅ preferred
export const createUser = createServerFn({ method: 'POST' })
  .middleware([authMiddleware])
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

### Forbidden 14: calling server functions directly from client without query layer

```typescript
// ❌ forbidden
const handleSubmit = async () => {
  const result = await createUser({ data })
}

// ✅ preferred
const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] })
})

const handleSubmit = () => {
  mutation.mutate({ data })
}
```

## Documentation

### Forbidden 15: missing required updates in process docs

```markdown
❌ Move to next phase but do not update PROCESS.md
❌ Complete requirements but do not check TASKS.md
❌ Complete validation but do not record VERIFICATION.md

✅ Update docs immediately at each phase transition
✅ Record major decisions in PROCESS.md
✅ Record validation results in VERIFICATION.md
```

### Forbidden 16: creating unnecessary docs

```markdown
❌ Create README.md without explicit request
❌ Auto-generate CONTRIBUTING.md
❌ Add random .md files proactively

✅ Create new docs only when explicitly requested
✅ Prefer updating existing docs first
```
