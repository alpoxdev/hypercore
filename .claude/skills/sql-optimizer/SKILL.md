---
name: sql-optimizer
description: PostgreSQL SQL 쿼리 최적화. ORM/Raw SQL 안티패턴 감지, EXPLAIN ANALYZE 분석, 인덱스 제안, 쿼리 리라이팅.
user-invocable: true
metadata:
  author: kood
  version: "1.0.0"
---

@../../instructions/workflow-patterns/sequential-thinking.md
@../../instructions/agent-patterns/parallel-execution.md
@../../instructions/agent-patterns/model-routing.md
@../../instructions/agent-patterns/agent-teams-usage.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md

# SQL Optimizer Skill

> PostgreSQL 쿼리 최적화. ORM 코드 + Raw SQL 안티패턴 감지 → EXPLAIN 분석 → 최적화 제안 → 자동 수정.

---

<purpose>

ORM(Prisma, Drizzle, TypeORM, Sequelize) 또는 Raw SQL 쿼리의 성능 문제 감지 및 최적화.

**입력:** SQL 쿼리, ORM 코드, 파일 경로, 또는 "프로젝트 전체 분석"
**출력:** 안티패턴 리포트 + 최적화된 쿼리/코드 + 인덱스 제안

**ORM별 수정 코드:** @./orm-patterns.md

</purpose>

---

<trigger_conditions>

| 트리거 | 반응 |
|--------|------|
| `/sql-optimizer src/db/queries.ts` | 파일 내 SQL/ORM 코드 분석 |
| `/sql-optimizer SELECT * FROM users...` | 단일 쿼리 최적화 |
| `/sql-optimizer` (인자 없음) | 프로젝트 전체 DB 레이어 스캔 |
| "쿼리가 느려요" / "slow" | 슬로우 쿼리 분석 가이드 |
| "N+1 문제" / "인덱스 추천" | 특정 문제 집중 분석 |

</trigger_conditions>

---

<argument_validation>

```
$ARGUMENTS 없음 → 프로젝트 전체 DB 레이어 스캔:
"프로젝트에서 SQL/ORM 관련 파일을 탐색하여 최적화할 쿼리를 찾겠습니다."
→ Phase 1 전체 스캔 실행

$ARGUMENTS = 파일 경로 → 해당 파일 분석
$ARGUMENTS = SQL 쿼리 → 단일 쿼리 분석
$ARGUMENTS = "slow" → pg_stat_statements 기반 분석 가이드
```

</argument_validation>

---

<detection_rules>

## 안티패턴 감지 규칙

### CRITICAL (즉시 수정)

| ID | 패턴 | 감지 방법 | 영향 |
|----|------|----------|------|
| C1 | **N+1 쿼리** | for 루프 내 ORM 관계 접근 | 쿼리 수 N배 증가 |
| C2 | **Cartesian Product** | JOIN 조건 없는 다중 테이블 | 행 수 폭발 |
| C3 | **무제한 SELECT** | LIMIT 없이 대량 테이블 조회 | 메모리 폭발 |
| C4 | **SELECT \*** | 불필요한 컬럼 전체 로드 | 네트워크/메모리 낭비 |

### HIGH (성능 리스크)

| ID | 패턴 | 감지 방법 | 영향 |
|----|------|----------|------|
| H1 | **Seq Scan** | EXPLAIN에서 10만+ 행 Seq Scan | 풀 테이블 스캔 |
| H2 | **서브쿼리 in WHERE** | IN (SELECT ...) 패턴 | 반복 실행 |
| H3 | **과다 JOIN** | 5개+ 테이블 조인 | 플래너 부하 |
| H4 | **ORM include 남용** | Prisma include 3단계+ 중첩 | 메모리 폭발 |
| H5 | **Lazy Loading 루프** | TypeORM Promise 관계 루프 접근 | N+1 변형 |

### MEDIUM (최적화 기회)

| ID | 패턴 | 감지 방법 | 영향 |
|----|------|----------|------|
| M1 | **DISTINCT 마스킹** | DISTINCT + JOIN | 잘못된 JOIN 은폐 |
| M2 | **서브쿼리 → CTE** | 중첩 서브쿼리 2단계+ | 가독성/성능 |
| M3 | **Window Function 미사용** | 집계 서브쿼리 | 불필요한 스캔 |
| M4 | **Partial Index 미적용** | 상수 WHERE 조건 반복 | 인덱스 크기 낭비 |
| M5 | **Covering Index 부재** | SELECT 컬럼 ≠ 인덱스 | 테이블 룩업 |
| M6 | **Prepared Statement 미사용** | Drizzle에서 .prepare() 없음 | 파싱 반복 |

### LOW (베스트 프랙티스)

| ID | 패턴 | 감지 방법 | 영향 |
|----|------|----------|------|
| L1 | **ANALYZE 미실행** | 대량 INSERT/UPDATE 후 | 통계 부정확 |
| L2 | **Connection Pool 미설정** | Serverless + 매번 new Client | 연결 소모 |
| L3 | **Expression Index 부재** | WHERE LOWER(col) 등 | 인덱스 미사용 |

</detection_rules>

---

<index_strategy>

## 인덱스 추천 전략

### 유형 선택

| 상황 | 인덱스 유형 | 예시 |
|------|-----------|------|
| WHERE = / ORDER BY | B-tree (기본) | `CREATE INDEX idx ON t(col)` |
| WHERE LOWER(col) | Expression | `CREATE INDEX idx ON t(LOWER(col))` |
| WHERE status = 'active' | Partial | `CREATE INDEX idx ON t(col) WHERE status = 'active'` |
| SELECT a,b WHERE a = ? | Covering | `CREATE INDEX idx ON t(a) INCLUDE (b)` |
| JSONB 필드 검색 | GIN | `CREATE INDEX idx ON t USING gin(data)` |
| 시계열 대량 (100만+) | BRIN | `CREATE INDEX idx ON t USING brin(created_at)` |

### 복합 인덱스 컬럼 순서

```sql
-- 규칙: 동등 조건 → 범위 조건 → 정렬
-- WHERE status = 'active' AND created_at > '2024-01-01' ORDER BY priority
CREATE INDEX idx_optimal ON tasks(status, created_at, priority);
```

### 인덱스 제안 전 필수 확인

```sql
-- 1. 기존 인덱스 중복 확인 (새 인덱스가 기존과 겹치는지)
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'target_table';

-- 2. 사용되지 않는 인덱스 찾기 (idx_scan = 0이면 삭제 후보)
SELECT indexname, idx_scan, pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes WHERE tablename = 'target_table'
ORDER BY idx_scan ASC;
```

</index_strategy>

---

<explain_analysis>

## EXPLAIN ANALYZE 분석 가이드

### 실행 패턴

```sql
-- 기본 분석 (FORMAT JSON → 프로그래밍 파싱 용이)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT ...;

-- 수정 쿼리 안전 분석 (롤백 필수)
BEGIN;
  EXPLAIN (ANALYZE, BUFFERS) UPDATE/DELETE ...;
ROLLBACK;

-- 상세 분석 (SETTINGS: PG 12+)
EXPLAIN (ANALYZE, VERBOSE, BUFFERS, SETTINGS) SELECT ...;
```

### 문제 식별 기준 (정량적)

| 신호 | 임계값 | 조치 |
|------|--------|------|
| **Seq Scan** | 행 10만+ 테이블 | 인덱스 추가 |
| **예상 rows / 실제 rows** | 비율 10x+ 차이 | `ANALYZE table_name` |
| **Nested Loop** | 내부 루프 1만+ rows | Hash Join 유도 또는 인덱스 |
| **Sort** | Cost 1000+ | ORDER BY 컬럼에 인덱스 |
| **Buffers shared read** | 1만+ 블록 | 인덱스 또는 shared_buffers 증가 |
| **Filter: Rows Removed** | 제거율 90%+ | WHERE 조건 최적화 |

### pg_stat_statements 슬로우 쿼리

```sql
-- TOP 10 느린 쿼리 (avg_ms 기준)
SELECT left(query, 80) as query, calls,
       (total_exec_time/calls)::numeric(10,2) as avg_ms, rows
FROM pg_stat_statements
WHERE calls > 10
ORDER BY total_exec_time DESC LIMIT 10;

-- 캐시 미스율 높은 쿼리
SELECT left(query, 80) as query, shared_blks_read,
       (100.0 * shared_blks_read / NULLIF(shared_blks_hit + shared_blks_read, 0))::numeric(5,2) as miss_pct
FROM pg_stat_statements
WHERE shared_blks_hit + shared_blks_read > 0
ORDER BY miss_pct DESC LIMIT 10;
```

</explain_analysis>

---

<workflow>

## 실행 흐름

| 단계 | 작업 | 도구 | 에이전트 |
|------|------|------|---------|
| **0** | ARGUMENT 파싱, 모드 결정 | - | - |
| **1** | DB 레이어 파일 탐색, ORM 종류+버전 감지 | Glob, Read | explore x2 (haiku) 병렬 |
| **2** | 복잡도 판단 | sequentialthinking (1단계) | - |
| **3** | detection_rules 기반 안티패턴 분석 | Read, Grep | architect + code-reviewer (sonnet) 병렬 |
| **4** | 최적화 방법 2-3개 선정 | sequentialthinking (2-5단계) | - |
| **5** | 옵션 제시 (장단점, 추천안) | - | - |
| **6** | 사용자 선택 후 코드 수정 | Edit | implementation-executor (sonnet) |
| **7** | typecheck + EXPLAIN 비교 검증 | Bash | - |

</workflow>

---

<thinking_strategy>

## Sequential Thinking 가이드

### 복잡도별 전략

| 복잡도 | 사고 횟수 | 기준 |
|--------|----------|------|
| **간단** | 3 | 단일 쿼리, 명확한 안티패턴 1-2개 |
| **보통** | 5 | 2-5개 쿼리, ORM 패턴 혼합 |
| **복잡** | 7+ | 다중 파일, 인덱스+쿼리+ORM 복합 |

### 보통 복잡도 (5단계)

```
thought 1: "user.service.ts 분석 - Prisma v7, findMany 3개, for 루프 2개
           → 보통 복잡도 (5개 쿼리, ORM 패턴)"

thought 2: "안티패턴 식별:
           C1 - line 45: findMany + for 루프 = N+1 (100명 조회 시 101쿼리)
           H4 - line 72: include 3단계 중첩 (user→posts→comments→author)
           M6 - line 90: 동일 쿼리 반복인데 prepare 미사용"

thought 3: "수정 방법:
           C1 → select + 관계 로딩 또는 findMany + in 배치
           H4 → select + _count 또는 별도 쿼리 분리
           M6 → prepare() 추가"

thought 4: "옵션 비교:
           A) ORM만: select 변환 (즉시, DB 변경 없음, 쿼리 80% 감소)
           B) ORM+인덱스: + Partial Index (마이그레이션 필요, 90% 감소)
           C) Raw SQL: 완전 제어 (유지보수 비용 증가)"

thought 5: "추천: 옵션 B - ORM 최적화 + Partial Index
           근거: 단계적 적용 가능, ORM 먼저 → 인덱스 추가
           인덱스: CREATE INDEX idx_posts_author ON posts(author_id) WHERE published = true"
```

</thinking_strategy>

---

<parallel_agent_execution>

### ⚠️ Agent Teams 우선 원칙

> **복잡한 병렬 작업 시 Agent Teams를 기본으로 사용**
> - Agent Teams 가용 → TeamCreate → 팀원 spawn → 병렬 협업
> - Agent Teams 미가용 → Task 병렬 호출 (폴백)

**Agent Teams 모드 (기본)**:
```typescript
TeamCreate({ team_name: "sql-team", description: "SQL 최적화" })
Task(subagent_type="architect", team_name="sql-team", name="architect", ...)
```

**수명주기 관리:**
- 팀원 태스크 완료 → 즉시 `shutdown_request` 전송
- 종료 후 `TaskList`로 다음 태스크 확인
- 모든 작업 완료 → `TeamDelete`로 팀 해산

---

## 병렬 에이전트 실행

```typescript
// Phase 1: DB 레이어 탐색 (병렬)
Task(subagent_type="explore", model="haiku",
     prompt="SQL/ORM 파일 탐색: prisma/, drizzle/, *.sql, migration, repository, service")

Task(subagent_type="explore", model="haiku",
     prompt="ORM 설정 분석: schema.prisma (버전 확인), drizzle.config.ts, 관계/인덱스 정의, 연결 풀")

// Phase 3: 안티패턴 분석 (병렬)
Task(subagent_type="architect", model="sonnet",
     prompt="쿼리 아키텍처 분석: N+1, JOIN 구조, 서브쿼리, 인덱스 전략 (기존 vs 필요)")

Task(subagent_type="code-reviewer", model="sonnet",
     prompt="ORM 안티패턴 리뷰: include/select, 배치 처리, Connection Pool, ORM 버전별 API 차이")
```

</parallel_agent_execution>

---

<option_presentation>

## 옵션 제시 형식

```markdown
## SQL 최적화 분석 결과

### 감지된 문제

| 심각도 | ID | 문제 | 위치 | 영향 |
|--------|-----|------|------|------|
| CRITICAL | C1 | N+1 쿼리 | src/users.ts:45 | 쿼리 100→2 |
| HIGH | H1 | Seq Scan (50만 행) | users 테이블 | 풀 스캔 |

---

### 옵션 1: ORM 코드 최적화 (추천)

| 장점 | 단점 |
|------|------|
| 코드만 수정, DB 변경 없음 | ORM 제약 내 최적화 |

**예상 효과:** 쿼리 수 80% 감소
**수정 파일:** src/users.ts:45, src/posts.ts:23

### 옵션 2: + 인덱스 추가

| 장점 | 단점 |
|------|------|
| 근본적 성능 개선 | DB 마이그레이션 필요 |

**예상 효과:** 쿼리 시간 90% 감소

---

추천: 옵션 [N]. [근거]
어떤 옵션을 선택하시겠습니까? (1/2/3)
```

</option_presentation>

---

<validation>

## 검증 체크리스트

### Phase 0-1 (탐색)

```text
✅ ARGUMENT 확인 (없으면 프로젝트 전체 스캔)
✅ ORM 종류 + 버전 감지 (package.json, schema 파일)
✅ Task (explore) x2 병렬로 DB 레이어 탐색
```

### Phase 2-5 (분석 + 옵션)

```text
✅ Sequential Thinking 최소 3단계 (보통 5단계)
✅ 안티패턴 CRITICAL → HIGH → MEDIUM → LOW 순서
✅ 옵션 최소 2개, 권장 3개 + 장단점 + 예상 효과
✅ 수정 파일 위치 (file:line 포함)
✅ 인덱스 제안 시 기존 인덱스 중복 확인 + CREATE INDEX 문
✅ ORM 수정 시 Before/After 코드 제공
```

### Phase 6-7 (수정 + 검증)

```text
✅ npx tsc --noEmit (typecheck 통과)
✅ 기존 테스트 통과 (npm test)
✅ 수정 전후 EXPLAIN ANALYZE 비교 권장
✅ 인덱스 추가 시 마이그레이션 파일 생성
```

### 절대 금지

```text
❌ EXPLAIN 없이 "이게 더 빠를 것" 추측
❌ 코드 탐색 없이 안티패턴 추측
❌ 옵션 1개만 제시
❌ 기존 인덱스 확인 없이 인덱스 제안 (중복 위험)
❌ ORM 버전 미확인 (Prisma v5 select vs v7 omit)
❌ 수정 후 typecheck 미실행
❌ 100만+ 행 테이블에 무조건 B-tree (BRIN 고려)
❌ Partial Index 추가 시 기존 전체 인덱스 중복 무시
```

</validation>

---

<examples>

## 실전 예시

### 예시 1: Prisma N+1 최적화

```
사용자: /sql-optimizer src/services/user.service.ts

Phase 0: 파일 경로 모드
Phase 1: ORM 감지 → Prisma v7 (package.json + schema.prisma)
Phase 2-4: Sequential Thinking (5단계)
  thought 1: "Prisma v7, findMany 3개, for 루프 2개 - 보통 복잡도"
  thought 2: "C1 line:45 N+1, H4 line:72 include 3단계"
  thought 3: "select 변환, _count, 배치 로딩"
  thought 4: "A) select만 vs B) +인덱스 vs C) Raw SQL"
  thought 5: "옵션 B 추천 - 단계적 적용"

Phase 5: 옵션 제시 (3개)
Phase 6: 선택 후 Edit 수정
Phase 7: 검증
  $ npx tsc --noEmit → ✅
  $ npm test → ✅
  EXPLAIN ANALYZE 비교 → 쿼리 시간 85% 감소
```

### 예시 2: 프로젝트 전체 스캔

```
사용자: /sql-optimizer

Phase 1 (병렬):
  explore: "prisma/, *.sql, service 파일 탐색" → 12 파일 발견
  explore: "schema.prisma, 인덱스 정의 분석" → 8 인덱스, 3 누락

Phase 3 (병렬):
  architect: 쿼리 아키텍처 → C1 x2, H1 x1, H2 x1
  code-reviewer: ORM 패턴 → H4 x1, M4 x2, M6 x3

결과: CRITICAL 2 / HIGH 3 / MEDIUM 5
→ 우선순위별 옵션 제시 → 선택 후 수정 + 검증
```

### 예시 3: 슬로우 쿼리

```
사용자: /sql-optimizer slow

1. pg_stat_statements 분석 쿼리 제공 (복사 가능)
2. 사용자가 결과 공유
3. EXPLAIN ANALYZE 실행 가이드
4. 결과 분석:
   - Seq Scan on orders (50만 행, H1) → Partial Index
   - Nested Loop 3만 rows (H3) → Hash Join 유도
5. 인덱스 CREATE 문 + 쿼리 리라이팅 제안
6. 마이그레이션 파일 생성
```

</examples>
