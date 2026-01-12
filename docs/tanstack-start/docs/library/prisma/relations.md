# Prisma - Relation Queries

## Nested Create

```typescript
const user = await prisma.user.create({
  data: {
    email: 'user@prisma.io',
    posts: { create: [{ title: 'Post 1' }, { title: 'Post 2' }] },
  },
  include: { posts: true },
})
```

## Relation Operations

```typescript
// connect - Link existing record
author: { connect: { id: 1 } }

// connectOrCreate - Connect if exists, create otherwise
categories: { connectOrCreate: { where: { name: 'Tech' }, create: { name: 'Tech' } } }

// disconnect - Remove relation
author: { disconnect: true }
```

## Include Relations

```typescript
// include
const users = await prisma.user.findMany({ include: { posts: true, profile: true } })

// Nested
include: { posts: { include: { categories: true } } }

// Filter + Sort
include: { posts: { where: { published: true }, orderBy: { createdAt: 'desc' }, take: 5 } }
```

## Filter by Relations

```typescript
// some - At least one matches
where: { posts: { some: { published: true } } }

// every - All match
where: { posts: { every: { published: true } } }

// none - None match
where: { posts: { none: { published: false } } }
```

## Count

```typescript
include: { _count: { select: { posts: true } } }
// Result: { _count: { posts: 5 } }
```

## Nested Update/Delete

```typescript
// updateMany
posts: { updateMany: { where: { published: false }, data: { published: true } } }

// deleteMany
posts: { deleteMany: { where: { published: false } } }
```
