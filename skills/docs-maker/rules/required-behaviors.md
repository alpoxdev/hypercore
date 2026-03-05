# Required Behaviors

**Purpose**: Rules that must be followed in all work.

## Work Start

### Required 1: Sequential Thinking first

**For MEDIUM+ complexity, Sequential Thinking is mandatory.**

| Complexity | Minimum steps | Typical work |
|--------|----------|------|
| LOW | 1-2 | File read, quick search |
| MEDIUM | 3-5 | Feature implementation, bug fix |
| HIGH | 7-10+ | Architecture design, large refactor |

```typescript
// ✅ required: run before implementation
mcp__sequential-thinking__sequentialthinking({
  thought: "Plan for User API: requirements -> schema -> implementation -> validation",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})
```

### Required 2: Read before Edit

**Always read files before modifying code.**

```typescript
// ✅ required order
Read({ file_path: "src/functions/auth.ts" }) // 1) read
Edit({ ... }) // 2) edit

// ❌ forbidden
Edit({ ... }) // edit without reading
```

### Required 3: parallel reads for independent files

**When 3+ independent files are needed, read in parallel.**

```typescript
// ✅ required: parallel reads
Read({ file_path: "file1.ts" })
Read({ file_path: "file2.ts" })
Read({ file_path: "file3.ts" })
```

## Code Authoring

### Required 4: UTF-8 encoding

**Use UTF-8 encoding for all files.**

### Required 5: block-level explanatory comments when complexity justifies it

```typescript
// ✅ preferred: add concise comment above non-obvious logic
// Validate authenticated session before data access
const isAuthenticated = await checkAuth(session)
if (!isAuthenticated) throw new Error('Unauthorized')

// Fetch current user profile
const user = await prisma.user.findUnique({ where: { id: session.userId } })
```

### Required 6: strict TypeScript typing

```typescript
// ✅ required: explicit types
function createUser(data: CreateUserInput): Promise<User> {
  return prisma.user.create({ data })
}

// ❌ forbidden: any
function createUser(data: any): any {
  return prisma.user.create({ data })
}
```

## API Implementation

### Required 7: Server Function pattern

**POST/PUT/PATCH requires `inputValidator`.**

```typescript
// ✅ required
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(createUserSchema)
  .handler(async ({ data }) => {
    return prisma.user.create({ data })
  })
```

**If authentication is required, middleware is mandatory.**

```typescript
// ✅ required
export const getProfile = createServerFn({ method: 'GET' })
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    return prisma.user.findUnique({ where: { id: context.userId } })
  })
```

### Required 8: use TanStack Query for client-side server function calls

**Use `useQuery` / `useMutation` for client integration.**

```typescript
// ✅ required
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: getUsers
})

const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => queryClient.invalidateQueries({ queryKey: ['users'] })
})

// ❌ forbidden: direct call from UI flow
const users = await getUsers()
```

## Validation

### Required 9: sequential 4-phase completion

**Follow Phase 1 -> 2 -> 3 -> 4 in order.**

```markdown
✅ Phase 1: implementation complete
✅ Phase 2: automated validation (/pre-deploy + TODO)
✅ Phase 3: planner validation (approval required)
✅ Phase 4: completion output (<promise>)
```

### Required 10: full `/pre-deploy`

**`typecheck`, `lint`, and `build` must all pass.**

```typescript
// ✅ required
Skill("pre-deploy")

// ❌ forbidden: partial check only
Bash({ command: "tsc --noEmit" })
```

### Required 11: planner approval in phase 3

```typescript
// ✅ required
Task(
  subagent_type="planner",
  model="opus",
  prompt=`Request final verification

[Original task]
${PROMPT}

[Validation summary]
- /pre-deploy: ✅
- TODO: ✅ 0 items

Please determine completion status.`
)
```

## Documentation

### Required 12: maintain session documentation when workflow requires it

When operating under a sessionized workflow, keep required logs updated (tasks, process, verification, notes as applicable).

### Required 13: update timing discipline

| Timing | File | Required content |
|------|--------------|------|
| On phase transition | PROCESS log | "Phase N done -> Phase N+1 started" |
| On requirement completion | TASK list | checkbox updates |
| On validation run | VERIFICATION log | /pre-deploy result, TODO count |
| On major decision | PROCESS log | decision and rationale |

### Required 14: schema comments when project policy requires annotated schemas

```prisma
/// User
model User {
  /// Primary identifier
  id        Int      @id @default(autoincrement())
  /// Unique email
  email     String   @unique
  /// Display name
  name      String
  /// Creation timestamp
  createdAt DateTime @default(now())
}
```

## Git Operations

### Required 15: use delegated git operator workflow

**Use a dedicated git operator path for commit/push tasks.**

```typescript
// ✅ required
Task(subagent_type="git-operator", model="haiku",
     prompt="commit and push current changes")

// ❌ forbidden
Bash({ command: "git add . && git commit -m 'feat: ...' && git push" })
```

### Required 16: commit message format

**Use one-line format: `<prefix>: <description>`**

```bash
# ✅ required
feat: implement login API
fix: resolve type error
refactor: refactor auth module

# ❌ forbidden
implement login feature  # no prefix
feat: implement login API\n\nCo-Authored-By: ...  # multiline with co-author footer
🤖 feat: login  # emoji prefix
```

**Valid prefixes:**
- feat, fix, refactor, style, docs, test, chore, perf, ci
