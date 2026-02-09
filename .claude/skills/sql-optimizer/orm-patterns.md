# ORM별 최적화 패턴

> SQL Optimizer 스킬에서 참조하는 ORM별 안티패턴 + 수정 코드

---

## Prisma (v5+, select/omit 지원)

```typescript
// ❌ C1: N+1 - include 없이 루프 접근
const users = await prisma.user.findMany()
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { authorId: user.id } })
}

// ✅ 수정: select로 필요 필드만 (v5+)
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    posts: {
      select: { id: true, title: true },
      take: 10,
      orderBy: { createdAt: 'desc' }
    }
  }
})

// ❌ H4: include 깊은 중첩 (3단계+)
await prisma.user.findMany({
  include: { posts: { include: { comments: { include: { author: true } } } } }
})

// ✅ 수정: select + 필요 깊이만 + _count
await prisma.user.findMany({
  select: {
    id: true,
    posts: {
      select: {
        id: true,
        title: true,
        _count: { select: { comments: true } }
      }
    }
  }
})

// ❌ C4: 배치 없이 대량 생성
for (const item of items) {
  await prisma.item.create({ data: item })
}

// ✅ 수정: createMany 배치
await prisma.item.createMany({ data: items })

// ❌ L2: Serverless 환경 매번 new PrismaClient
export async function handler() {
  const prisma = new PrismaClient()  // 연결 풀 소모
  return prisma.user.findMany()
}

// ✅ 수정: 전역 인스턴스 재사용
const prisma = new PrismaClient()
export async function handler() {
  return prisma.user.findMany()
}
```

### Prisma 버전별 차이

| 기능 | v5 | v6 | v7 |
|------|-----|-----|-----|
| `select` | ✅ | ✅ | ✅ |
| `omit` | ✅ (Preview) | ✅ | ✅ |
| `relationLoadStrategy: 'join'` | ✅ (v5.9+) | ✅ | ✅ |
| Pure TS Client (Rust 제거) | ❌ | ❌ | ✅ |

---

## Drizzle

```typescript
// ❌ M6: prepared statement 미사용 (반복 쿼리)
for (const id of userIds) {
  await db.select().from(users).where(eq(users.id, id))
}

// ✅ 수정: prepare + IN 조건 (PostgreSQL named prepared statement)
const getUsers = db
  .select({ id: users.id, name: users.name })
  .from(users)
  .where(inArray(users.id, sql.placeholder('ids')))
  .prepare('get_users_batch')

await getUsers.execute({ ids: userIds })

// ❌ C4: select() 전체 컬럼
const result = await db.select().from(users)

// ✅ 수정: partial select
const result = await db
  .select({ id: users.id, email: users.email })
  .from(users)

// ✅ JSON 집계 (N+1 방지, 단일 쿼리)
const usersWithPosts = await db
  .select({
    id: users.id,
    name: users.name,
    posts: sql`json_agg(${posts}) FILTER (WHERE ${posts.id} IS NOT NULL)`
  })
  .from(users)
  .leftJoin(posts, eq(users.id, posts.userId))
  .groupBy(users.id)
  .limit(20)
  .prepare('get_users_with_posts')
  .execute()
```

---

## TypeORM

```typescript
// ❌ H5: lazy loading 루프
const users = await User.find()
for (const user of users) {
  const posts = await user.posts  // Promise<Post[]> - 매번 쿼리
}

// ✅ 수정: leftJoinAndSelect + 필드 선택
const users = await createQueryBuilder('user')
  .leftJoinAndSelect('user.posts', 'post')
  .select(['user.id', 'user.name', 'post.id', 'post.title'])
  .getMany()

// ✅ 성능 극대화: getRawMany (3.5x 빠름, 엔티티 변환 생략)
const users = await createQueryBuilder('user')
  .leftJoin('user.posts', 'post')
  .select(['user.id', 'user.name', 'post.id', 'post.title'])
  .getRawMany()

// ✅ 배치 로드 (IN 쿼리, N+1 대안)
const users = await User.find()
const userIds = users.map(u => u.id)
const posts = await Post.find({ where: { userId: In(userIds) } })
```

---

## Raw SQL

```sql
-- ❌ H2: WHERE IN 서브쿼리
SELECT * FROM orders
WHERE customer_id IN (SELECT id FROM customers WHERE country = 'KR');

-- ✅ 수정: JOIN + 필요 컬럼만
SELECT o.id, o.total, o.created_at
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id
WHERE c.country = 'KR';

-- ❌ M3: 집계 서브쿼리 (Window Function 미사용)
SELECT *, (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.id) as order_count
FROM users u;

-- ✅ 수정: LEFT JOIN + GROUP BY
SELECT u.id, u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- ❌ M4: Partial Index 미적용
SELECT * FROM orders WHERE status = 'pending' AND created_at > NOW() - INTERVAL '7 days';
-- CREATE INDEX idx_orders_created ON orders(created_at);  -- 전체 인덱스

-- ✅ 수정: Partial Index (최대 275x 성능 향상)
CREATE INDEX idx_orders_pending ON orders(created_at)
  WHERE status = 'pending';

-- ❌ M1: DISTINCT 마스킹 (잘못된 JOIN 은폐)
SELECT DISTINCT u.* FROM users u
JOIN orders o ON u.id = o.user_id;

-- ✅ 수정: JOIN 로직 수정 또는 EXISTS
SELECT u.* FROM users u
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);
```

---

## 대량 데이터 로드 최적화

```sql
-- Step 1: 트랜잭션 시작
BEGIN;

-- Step 2: 인덱스 임시 제거 + 트리거 비활성화
DROP INDEX IF EXISTS idx_target;
ALTER TABLE target DISABLE TRIGGER ALL;

-- Step 3: 메모리 설정 증가
SET maintenance_work_mem = '1GB';

-- Step 4: COPY 사용 (INSERT 대비 10x 빠름)
COPY target FROM STDIN;

-- Step 5: 트리거 복구 + 인덱스 재생성
ALTER TABLE target ENABLE TRIGGER ALL;
CREATE INDEX idx_target ON target(col);

-- Step 6: 트랜잭션 완료
COMMIT;

-- Step 7: 통계 업데이트 (트랜잭션 외부에서 실행)
ANALYZE target;
```
