# Prisma - Transactions

## Array-based Transactions

All operations rollback if any one fails.

```typescript
const deletePosts = prisma.post.deleteMany({ where: { authorId: 7 } })
const deleteUser = prisma.user.delete({ where: { id: 7 } })
await prisma.$transaction([deletePosts, deleteUser])
```

## Interactive Transactions

For complex logic and conditional processing.

```typescript
const result = await prisma.$transaction(async (tx) => {
  const sender = await tx.account.findUnique({ where: { id: senderId } })
  if (!sender || sender.balance < amount) throw new Error('Insufficient balance')

  await tx.account.update({ where: { id: senderId }, data: { balance: { decrement: amount } } })
  await tx.account.update({ where: { id: recipientId }, data: { balance: { increment: amount } } })

  return { success: true }
})
```

## Options

```typescript
await prisma.$transaction(async (tx) => { ... }, {
  maxWait: 5000,              // Max wait time (ms)
  timeout: 10000,             // Timeout (ms)
  isolationLevel: 'Serializable',  // ReadUncommitted | ReadCommitted | RepeatableRead | Serializable
})
```

## Error Handling

```typescript
try {
  await prisma.$transaction(async (tx) => {
    await tx.user.create({ data: { email } })
    if (someCondition) throw new Error('Rollback')
  })
} catch (error) {
  // Entire transaction rolled back
}
```
