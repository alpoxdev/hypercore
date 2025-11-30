# Prisma - CRUD 작업

> **상위 문서**: [Prisma](./index.md)

## Create (생성)

### 단일 레코드 생성

```typescript
const user = await prisma.user.create({
  data: {
    email: 'alice@prisma.io',
    name: 'Alice',
  },
})
```

### 관계 포함 생성

```typescript
const userWithPosts = await prisma.user.create({
  data: {
    email: 'bob@prisma.io',
    name: 'Bob',
    posts: {
      create: [
        { title: 'Hello World' },
        { title: 'My Second Post' },
      ],
    },
  },
  include: {
    posts: true,
  },
})
```

### connectOrCreate로 깊은 중첩 생성

```typescript
const user = await prisma.user.create({
  include: {
    posts: {
      include: {
        categories: true,
      },
    },
  },
  data: {
    email: 'emma@prisma.io',
    posts: {
      create: [
        {
          title: 'My first post',
          categories: {
            connectOrCreate: [
              {
                create: { name: 'Introductions' },
                where: { name: 'Introductions' },
              },
              {
                create: { name: 'Social' },
                where: { name: 'Social' },
              },
            ],
          },
        },
      ],
    },
  },
})
```

## Read (조회)

### 단일 레코드 조회

```typescript
const user = await prisma.user.findUnique({
  where: { email: 'alice@prisma.io' },
})
```

### 필터링된 다중 레코드 조회

```typescript
const users = await prisma.user.findMany({
  where: { name: 'Alice' },
})
```

### 관계 포함 조회

```typescript
const users = await prisma.user.findMany({
  where: { role: 'ADMIN' },
  include: { posts: true },
})
```

### 특정 필드만 선택

```typescript
const user = await prisma.user.findUnique({
  where: { email: 'emma@prisma.io' },
  select: {
    email: true,
    posts: {
      select: { likes: true },
    },
  },
})
```

### 관계 필드로 필터링

```typescript
const users = await prisma.user.findMany({
  where: {
    email: { endsWith: 'prisma.io' },
    posts: {
      some: { published: false },
    },
  },
})
```

## Update (수정)

### 단일 레코드 수정

```typescript
const user = await prisma.user.update({
  where: { email: 'alice@prisma.io' },
  data: { name: 'Alice Updated' },
})
```

### 다중 레코드 수정

```typescript
const updatedUsers = await prisma.user.updateMany({
  where: { role: 'USER' },
  data: { role: 'ADMIN' },
})
```

### Upsert (있으면 수정, 없으면 생성)

```typescript
const user = await prisma.user.upsert({
  where: { email: 'alice@prisma.io' },
  update: { name: 'Alice Updated' },
  create: { email: 'alice@prisma.io', name: 'Alice' },
})
```

## Delete (삭제)

### 단일 레코드 삭제

```typescript
const deletedUser = await prisma.user.delete({
  where: { email: 'alice@prisma.io' },
})
```

### 모든 레코드 삭제

```typescript
const deleteUsers = await prisma.user.deleteMany({})
```

### 조건부 삭제

```typescript
const deletedPosts = await prisma.post.deleteMany({
  where: { published: false },
})
```

## 필터 연산자

```typescript
// 문자열 필터
where: {
  email: { contains: 'prisma' },
  name: { startsWith: 'A' },
  title: { endsWith: 'guide' },
}

// 숫자 필터
where: {
  age: { gt: 18 },       // greater than
  age: { gte: 18 },      // greater than or equal
  age: { lt: 65 },       // less than
  age: { lte: 65 },      // less than or equal
}

// 배열 필터
where: {
  id: { in: [1, 2, 3] },
  id: { notIn: [4, 5, 6] },
}

// 논리 연산자
where: {
  OR: [
    { email: { contains: 'prisma' } },
    { name: { contains: 'Prisma' } },
  ],
  AND: [
    { published: true },
    { authorId: 1 },
  ],
  NOT: { email: { contains: 'test' } },
}
```
