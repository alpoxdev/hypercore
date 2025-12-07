# Prisma - 관계 쿼리

## 중첩 생성

```typescript
const user = await prisma.user.create({
  data: {
    email: 'user@prisma.io',
    posts: { create: [{ title: 'Post 1' }, { title: 'Post 2' }] },
  },
  include: { posts: true },
})
```

## 관계 연결

```typescript
// connect - 기존 연결
author: { connect: { id: 1 } }

// connectOrCreate - 있으면 연결, 없으면 생성
categories: { connectOrCreate: { where: { name: 'Tech' }, create: { name: 'Tech' } } }

// disconnect - 관계 해제
author: { disconnect: true }
```

## 관계 포함 조회

```typescript
// include
const users = await prisma.user.findMany({ include: { posts: true, profile: true } })

// 중첩
include: { posts: { include: { categories: true } } }

// 필터 + 정렬
include: { posts: { where: { published: true }, orderBy: { createdAt: 'desc' }, take: 5 } }
```

## 관계로 필터링

```typescript
// some - 하나라도 만족
where: { posts: { some: { published: true } } }

// every - 모두 만족
where: { posts: { every: { published: true } } }

// none - 만족 없음
where: { posts: { none: { published: false } } }
```

## 카운트

```typescript
include: { _count: { select: { posts: true } } }
// 결과: { _count: { posts: 5 } }
```

## 중첩 수정/삭제

```typescript
// updateMany
posts: { updateMany: { where: { published: false }, data: { published: true } } }

// deleteMany
posts: { deleteMany: { where: { published: false } } }
```
