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

## Connect Relations

```typescript
// connect - connect existing
author: { connect: { id: 1 } }

// connectOrCreate - connect if exists, create if not
categories: { connectOrCreate: { where: { name: 'Tech' }, create: { name: 'Tech' } } }

// disconnect - disconnect relation
author: { disconnect: true }
```

## Include Relations

```typescript
// include
const users = await prisma.user.findMany({ include: { posts: true, profile: true } })

// nested
include: { posts: { include: { categories: true } } }

// filter + sort
include: { posts: { where: { published: true }, orderBy: { createdAt: 'desc' }, take: 5 } }
```

## Filter by Relations

```typescript
// some - at least one matches
where: { posts: { some: { published: true } } }

// every - all match
where: { posts: { every: { published: true } } }

// none - none match
where: { posts: { none: { published: false } } }
```

## Count

```typescript
include: { _count: { select: { posts: true } } }
// result: { _count: { posts: 5 } }
```

## Nested Update/Delete

```typescript
// updateMany
posts: { updateMany: { where: { published: false }, data: { published: true } } }

// deleteMany
posts: { deleteMany: { where: { published: false } } }
```
