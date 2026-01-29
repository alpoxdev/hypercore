# Prisma - CRUD Operations

## Create

```typescript
// Single
const user = await prisma.user.create({
  data: { email: 'alice@prisma.io', name: 'Alice' },
})

// With relations
const user = await prisma.user.create({
  data: {
    email: 'bob@prisma.io',
    posts: { create: [{ title: 'Hello' }, { title: 'World' }] },
  },
  include: { posts: true },
})

// connectOrCreate
posts: { create: [{
  title: 'Post',
  categories: { connectOrCreate: [{ create: { name: 'Tech' }, where: { name: 'Tech' } }] },
}]}
```

## Read

```typescript
// Single
const user = await prisma.user.findUnique({ where: { email } })

// Multiple
const users = await prisma.user.findMany({ where: { name: 'Alice' } })

// With relations
const users = await prisma.user.findMany({ where: { role: 'ADMIN' }, include: { posts: true } })

// Select fields
const user = await prisma.user.findUnique({
  where: { email },
  select: { email: true, posts: { select: { title: true } } },
})

// Filter by relation
const users = await prisma.user.findMany({
  where: { posts: { some: { published: false } } },
})
```

## Update

```typescript
// Single
const user = await prisma.user.update({ where: { id }, data: { name: 'Updated' } })

// Multiple
await prisma.user.updateMany({ where: { role: 'USER' }, data: { role: 'ADMIN' } })

// Upsert
const user = await prisma.user.upsert({
  where: { email },
  update: { name: 'Updated' },
  create: { email, name: 'New' },
})
```

## Delete

```typescript
await prisma.user.delete({ where: { id } })
await prisma.user.deleteMany({})  // all
await prisma.post.deleteMany({ where: { published: false } })  // conditional
```

## Filter Operators

```typescript
// String
{ contains: 'prisma', startsWith: 'A', endsWith: 'io' }

// Number
{ gt: 18, gte: 18, lt: 65, lte: 65 }

// Array
{ in: [1, 2, 3], notIn: [4, 5] }

// Logical
{ OR: [...], AND: [...], NOT: {...} }
```
