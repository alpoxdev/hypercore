# Prisma - 트랜잭션

> **상위 문서**: [Prisma](./index.md)

## 배열 기반 트랜잭션

여러 쿼리를 순차적으로 실행하고, 하나라도 실패하면 모두 롤백됩니다.

```typescript
// 관계 데이터 삭제
const deletePosts = prisma.post.deleteMany({
  where: { authorId: 7 },
})

const deleteUser = prisma.user.delete({
  where: { id: 7 },
})

const transaction = await prisma.$transaction([deletePosts, deleteUser])
```

## GDPR 데이터 삭제 예시

```typescript
const id = 9 // 삭제할 사용자

const deletePosts = prisma.post.deleteMany({
  where: { userId: id },
})

const deleteMessages = prisma.privateMessage.deleteMany({
  where: { userId: id },
})

const deleteUser = prisma.user.delete({
  where: { id: id },
})

// 모든 작업이 성공하거나 모두 실패
await prisma.$transaction([deletePosts, deleteMessages, deleteUser])
```

## 모든 데이터 삭제

```typescript
const deletePosts = prisma.post.deleteMany()
const deleteProfile = prisma.profile.deleteMany()
const deleteUsers = prisma.user.deleteMany()

// 순서대로 실행 (deleteUsers가 마지막)
await prisma.$transaction([deleteProfile, deletePosts, deleteUsers])
```

## 인터랙티브 트랜잭션

더 복잡한 트랜잭션 로직이 필요할 때 사용합니다.

```typescript
const result = await prisma.$transaction(async (tx) => {
  // 1. 잔액 확인
  const sender = await tx.account.findUnique({
    where: { id: senderId },
  })

  if (!sender || sender.balance < amount) {
    throw new Error('Insufficient balance')
  }

  // 2. 보내는 계좌에서 차감
  const updatedSender = await tx.account.update({
    where: { id: senderId },
    data: { balance: { decrement: amount } },
  })

  // 3. 받는 계좌에 입금
  const updatedRecipient = await tx.account.update({
    where: { id: recipientId },
    data: { balance: { increment: amount } },
  })

  return { sender: updatedSender, recipient: updatedRecipient }
})
```

## 트랜잭션 옵션

```typescript
await prisma.$transaction(
  async (tx) => {
    // 트랜잭션 로직
  },
  {
    maxWait: 5000, // 최대 대기 시간 (ms)
    timeout: 10000, // 트랜잭션 타임아웃 (ms)
    isolationLevel: 'Serializable', // 격리 수준
  }
)
```

## 격리 수준

```typescript
// 가능한 격리 수준
type IsolationLevel =
  | 'ReadUncommitted'
  | 'ReadCommitted'
  | 'RepeatableRead'
  | 'Serializable'
```

## 타입 안전 Raw Query

```typescript
import { selectUserTitles, updateUserName } from '@prisma/client/sql'

const [userList, updateUser] = await prisma.$transaction([
  prisma.$queryRawTyped(selectUserTitles()),
  prisma.$queryRawTyped(updateUserName(2)),
])
```

## 트랜잭션 내 에러 처리

```typescript
try {
  await prisma.$transaction(async (tx) => {
    await tx.user.create({ data: { email: 'alice@prisma.io' } })

    // 의도적 에러 발생 시 전체 롤백
    if (someCondition) {
      throw new Error('Rollback transaction')
    }

    await tx.post.create({ data: { title: 'Hello', authorId: 1 } })
  })
} catch (error) {
  console.error('Transaction failed:', error)
  // 트랜잭션 내 모든 변경사항이 롤백됨
}
```
