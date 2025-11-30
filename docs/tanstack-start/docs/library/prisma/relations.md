# Prisma - 관계 쿼리

> **상위 문서**: [Prisma](./index.md)

## 중첩 생성 (Nested Create)

```typescript
const result = await prisma.user.create({
  data: {
    email: 'elsa@prisma.io',
    name: 'Elsa Prisma',
    posts: {
      create: [
        { title: 'How to make an omelette' },
        { title: 'How to eat an omelette' },
      ],
    },
  },
  include: {
    posts: true,
  },
})
```

## 관계 연결

### connect - 기존 레코드 연결

```typescript
const post = await prisma.post.create({
  data: {
    title: 'New Post',
    author: {
      connect: { id: 1 },
    },
  },
})
```

### connectOrCreate - 있으면 연결, 없으면 생성

```typescript
const post = await prisma.post.create({
  data: {
    title: 'New Post',
    categories: {
      connectOrCreate: {
        where: { name: 'Technology' },
        create: { name: 'Technology' },
      },
    },
  },
})
```

### disconnect - 관계 해제

```typescript
const post = await prisma.post.update({
  where: { id: 1 },
  data: {
    author: {
      disconnect: true,
    },
  },
})
```

## 관계 포함 조회

### include 사용

```typescript
const users = await prisma.user.findMany({
  include: {
    posts: true,
    profile: true,
  },
})
```

### 중첩 include

```typescript
const users = await prisma.user.findMany({
  include: {
    posts: {
      include: {
        categories: true,
      },
    },
  },
})
```

### 관계 필터링

```typescript
const users = await prisma.user.findMany({
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5,
    },
  },
})
```

## 관계로 필터링

### some - 하나라도 조건 만족

```typescript
const users = await prisma.user.findMany({
  where: {
    posts: {
      some: { published: true },
    },
  },
})
```

### every - 모두 조건 만족

```typescript
const users = await prisma.user.findMany({
  where: {
    posts: {
      every: { published: true },
    },
  },
})
```

### none - 조건 만족 없음

```typescript
const users = await prisma.user.findMany({
  where: {
    posts: {
      none: { published: false },
    },
  },
})
```

## 관계 카운트

```typescript
const users = await prisma.user.findMany({
  include: {
    _count: {
      select: { posts: true },
    },
  },
})

// 결과: { id: 1, name: 'Alice', _count: { posts: 5 } }
```

## 중첩 업데이트

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    posts: {
      updateMany: {
        where: { published: false },
        data: { published: true },
      },
    },
  },
})
```

## 중첩 삭제

```typescript
const user = await prisma.user.update({
  where: { id: 1 },
  data: {
    posts: {
      deleteMany: {
        where: { published: false },
      },
    },
  },
})
```
