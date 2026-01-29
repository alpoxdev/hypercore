# Zod v4 - Schema Validation

> TypeScript-first schema validation

---

## Version Notice

```typescript
// ✅ v4 syntax
z.email()
z.url()
z.uuid()

// ❌ v3 syntax (prohibited)
z.string().email()
z.string().url()
```

---

## Installation

```bash
npm install zod
```

---

## Basic Types

```typescript
import { z } from 'zod'

z.string()
z.number()
z.boolean()
z.date()
z.undefined()
z.null()
```

### Strings (v4)

```typescript
z.email()                    // Email
z.url()                      // URL
z.uuid()                     // UUID
z.string().min(1).max(100)   // Length
z.string().trim()            // Trim whitespace
z.string().regex(/^[a-z]+$/) // Regex
```

### Numbers

```typescript
z.number().int()        // Integer
z.number().positive()   // Positive
z.number().min(1).max(100)
```

---

## Objects

```typescript
const userSchema = z.object({
  id: z.string(),
  email: z.email(),
  name: z.string().min(1).trim(),
  age: z.number().int().positive(),
})

type User = z.infer<typeof userSchema>
```

### Optional / Nullable

```typescript
z.string().optional()   // string | undefined
z.string().nullable()   // string | null
z.string().nullish()    // string | null | undefined
```

### Defaults

```typescript
z.string().default('Anonymous')
z.enum(['user', 'admin']).default('user')
```

### Partial / Pick / Omit

```typescript
userSchema.partial()              // All fields optional
userSchema.partial({ email: true }) // Specific fields only
userSchema.pick({ id: true, name: true })
userSchema.omit({ password: true })
```

---

## Enum / Union

```typescript
// Enum
z.enum(['pending', 'active', 'completed'])

// Union
z.union([z.string(), z.number()])

// Discriminated Union
z.discriminatedUnion('type', [
  z.object({ type: z.literal('success'), data: z.unknown() }),
  z.object({ type: z.literal('error'), message: z.string() }),
])
```

---

## Coerce (Type Conversion)

```typescript
z.coerce.number()   // string → number
z.coerce.boolean()  // 'true' → boolean
z.coerce.date()     // string → Date
```

---

## Transform

```typescript
z.email().transform((e) => e.toLowerCase())
z.string().transform((s) => s.split(','))
```

---

## Refine (Custom Validation)

```typescript
// Single field
z.string().refine((val) => val.length >= 8, {
  message: 'Must be at least 8 characters',
})

// Entire object
z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
})
```

---

## Error Handling

```typescript
const result = schema.safeParse(input)

if (result.success) {
  console.log(result.data)
} else {
  console.log(result.error.flatten())
  // { fieldErrors: { email: ['Invalid email'] } }
}
```

### Custom Errors

```typescript
z.email({ message: 'Please enter a valid email' })
z.string().min(1, { message: 'Required field' })
```

---

## Usage with Hono

```typescript
import { zValidator } from '@hono/zod-validator'

const schema = z.object({
  email: z.email(),
  name: z.string().min(1).trim(),
})

app.post('/users',
  zValidator('json', schema, (result, c) => {
    if (!result.success) {
      return c.json({ errors: result.error.flatten().fieldErrors }, 400)
    }
  }),
  (c) => {
    const data = c.req.valid('json')
    return c.json({ user: data }, 201)
  }
)
```

---

## Related Documentation

- [Hono Validation](../hono/validation.md)
