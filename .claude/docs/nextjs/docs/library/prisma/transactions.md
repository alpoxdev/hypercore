# Prisma - 트랜잭션

## 배열 기반 트랜잭션

하나라도 실패하면 모두 롤백.

```typescript
const deletePosts = prisma.post.deleteMany({ where: { authorId: 7 } })
const deleteUser = prisma.user.delete({ where: { id: 7 } })
await prisma.$transaction([deletePosts, deleteUser])
```

## 인터랙티브 트랜잭션

복잡한 로직, 조건부 처리.

```typescript
const result = await prisma.$transaction(async (tx) => {
  const sender = await tx.account.findUnique({ where: { id: senderId } })
  if (!sender || sender.balance < amount) throw new Error('Insufficient balance')

  await tx.account.update({ where: { id: senderId }, data: { balance: { decrement: amount } } })
  await tx.account.update({ where: { id: recipientId }, data: { balance: { increment: amount } } })

  return { success: true }
})
```

## 옵션

```typescript
await prisma.$transaction(async (tx) => { ... }, {
  maxWait: 5000,              // 최대 대기 (ms)
  timeout: 10000,             // 타임아웃 (ms)
  isolationLevel: 'Serializable',  // ReadUncommitted | ReadCommitted | RepeatableRead | Serializable
})
```

## 에러 처리

```typescript
try {
  await prisma.$transaction(async (tx) => {
    await tx.user.create({ data: { email } })
    if (someCondition) throw new Error('Rollback')
  })
} catch (error) {
  // 전체 롤백됨
}
```
