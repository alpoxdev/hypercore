# Project Optimizer

**Version 1.0.0**
범용 프로젝트 최적화 가이드 (언어/프레임워크 무관)
February 2026

> **참고:**
> 이 문서는 주로 에이전트와 LLM이 프로젝트 코드베이스를 분석, 최적화, 리팩토링할 때 따르기 위한 것입니다. 어떤 언어/프레임워크든 적용 가능한 보편적 최적화 원칙 기반.

---

## 요약

AI 에이전트를 위한 범용 프로젝트 최적화 가이드. 8개 카테고리에 걸쳐 38개 규칙을 포함하며, 영향도별로 우선순위 매김 (critical: 동시성, 빌드 최적화 → incremental: 아키텍처). 언어/프레임워크를 자동 감지하여 해당 언어의 관용적 패턴으로 규칙 적용. 프레임워크 특화 스킬(nextjs, tanstack-start, tauri)과 자동 체이닝 지원.

---

<instructions>

## 문서 사용 지침

@rules/concurrency-parallel.md
@rules/concurrency-defer-await.md
@rules/concurrency-pipeline.md
@rules/concurrency-pool.md
@rules/build-incremental.md
@rules/build-tree-shake.md
@rules/build-code-split.md
@rules/build-minify.md
@rules/build-cache.md
@rules/io-batch-queries.md
@rules/io-cache-layer.md
@rules/io-stream.md
@rules/io-connection-reuse.md
@rules/io-serialize-minimal.md
@rules/memory-leak-prevention.md
@rules/memory-pool-reuse.md
@rules/memory-lazy-init.md
@rules/memory-bounded-cache.md
@rules/memory-large-data.md
@rules/code-dead-elimination.md
@rules/code-duplication.md
@rules/code-complexity.md
@rules/code-naming.md
@rules/code-error-handling.md
@rules/deps-unused-removal.md
@rules/deps-security-audit.md
@rules/deps-version-pin.md
@rules/deps-lightweight-alt.md
@rules/deps-peer-align.md
@rules/dx-type-safety.md
@rules/dx-lint-config.md
@rules/dx-test-coverage.md
@rules/dx-ci-speed.md
@rules/dx-dev-server.md
@rules/arch-module-boundary.md
@rules/arch-interface-segregation.md
@rules/arch-config-centralize.md
@rules/arch-hot-path.md

</instructions>

---

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 설명 |
|---------|---------|--------|------|
| 1 | 동시성/병렬화 | **CRITICAL** | 순차 I/O를 병렬로 전환. 가장 큰 성능 향상 |
| 2 | 빌드/번들 최적화 | **CRITICAL** | 빌드 시간, 출력 크기 감소 |
| 3 | I/O 성능 | **HIGH** | DB/네트워크/파일 I/O 효율화 |
| 4 | 메모리/리소스 관리 | HIGH | 메모리 누수 방지, 리소스 효율 |
| 5 | 코드 품질 | MEDIUM-HIGH | 유지보수성, 가독성, 정확성 |
| 6 | 의존성 관리 | MEDIUM | 보안, 크기, 호환성 |
| 7 | DX (개발자 경험) | MEDIUM | 타입 안전성, 린팅, 테스트, CI |
| 8 | 아키텍처 | LOW-MEDIUM | 모듈 경계, 인터페이스, 설정 관리 |

</categories>

---

<critical_patterns>

## 1. 동시성/병렬화 (CRITICAL)

순차 I/O는 가장 큰 성능 저해 요소. 독립 작업은 항상 동시 실행.

### 병렬 실행 (다국어)

| 언어 | 순차 (❌) | 병렬 (✅) |
|------|----------|----------|
| **JS/TS** | `await a(); await b()` | `await Promise.all([a(), b()])` |
| **Python** | `await a(); await b()` | `await asyncio.gather(a(), b())` |
| **Go** | `a(); b()` | `errgroup.Go(a); errgroup.Go(b)` |
| **Rust** | `a.await; b.await` | `tokio::try_join!(a, b)` |
| **Java** | `a.get(); b.get()` | `CompletableFuture.allOf(a, b)` |
| **C#** | `await A(); await B()` | `await Task.WhenAll(A(), B())` |
| **Elixir** | sequential calls | `Task.async` + `Task.await_many` |
| **Ruby** | sequential calls | `Async { [task1, task2].map(&:wait) }` |

### 커넥션 풀링

| 언어 | 라이브러리 | 설정 |
|------|-----------|------|
| **JS/TS** | `generic-pool`, Prisma | `pool: { min: 2, max: 10 }` |
| **Python** | `sqlalchemy`, `asyncpg` | `pool_size=10, max_overflow=20` |
| **Go** | `database/sql` | `SetMaxOpenConns(25)` |
| **Rust** | `deadpool`, `bb8` | `Pool::builder().max_size(16)` |
| **Java** | HikariCP | `maximumPoolSize=10` |

</critical_patterns>

---

<build_optimization>

## 2. 빌드/번들 최적화 (CRITICAL)

### 증분 빌드 설정

| 도구 | 설정 |
|------|------|
| **TypeScript** | `"incremental": true` in tsconfig.json |
| **Rust** | `incremental = true` in Cargo.toml `[profile.dev]` |
| **Go** | 기본 활성화 (`go build` 캐시) |
| **Python** | Ruff `cache-dir`, mypy `incremental` |
| **Gradle** | `org.gradle.caching=true` |
| **CMake** | ccache / sccache 연동 |

### CI 캐시 전략

| 패키지 매니저 | 캐시 대상 |
|-------------|----------|
| npm/yarn/pnpm | `node_modules`, `.yarn/cache` |
| pip | `~/.cache/pip` |
| cargo | `~/.cargo/registry`, `target/` |
| go | `~/go/pkg/mod`, `~/.cache/go-build` |
| gradle | `~/.gradle/caches` |

</build_optimization>

---

<io_performance>

## 3. I/O 성능 (HIGH)

### N+1 쿼리 패턴 제거

```
❌ N+1: 목록 1쿼리 + 각 항목 N쿼리 = N+1 쿼리
✅ 배치: 목록 1쿼리 + IN절 1쿼리 = 2쿼리
✅ 조인: 1쿼리로 전체 해결
```

| ORM | N+1 해결 방법 |
|-----|-------------|
| **Prisma** | `include: { relation: true }` |
| **SQLAlchemy** | `joinedload()`, `selectinload()` |
| **GORM** | `Preload("Relation")` |
| **ActiveRecord** | `includes(:relation)` |
| **Hibernate** | `@EntityGraph`, `JOIN FETCH` |
| **Diesel** | `belonging_to().load()` |

### 캐시 레이어

```
요청 → L1 (인메모리, <1ms) → L2 (Redis, <5ms) → L3 (DB, ~50ms)
         ↑ 캐시 히트          ↑ 캐시 히트        ↑ 캐시 미스
```

</io_performance>

---

<memory_management>

## 4. 메모리/리소스 관리 (HIGH)

### 리소스 해제 패턴

| 언어 | 패턴 |
|------|------|
| **Python** | `with` (context manager) |
| **Go** | `defer resource.Close()` |
| **Rust** | RAII (Drop trait, 자동 해제) |
| **Java** | try-with-resources |
| **C#** | `using` statement |
| **JS/TS** | `try/finally`, `using` (TC39 Stage 3) |
| **C++** | RAII, `std::unique_ptr` |

### 대용량 데이터 처리

```
❌ 전체 로드: loadAll() → 메모리 폭발
✅ 스트리밍: stream/iterator/generator → 일정 메모리
✅ 페이지네이션: page(offset, limit) → 제한된 메모리
```

</memory_management>

---

<code_quality>

## 5. 코드 품질 (MEDIUM-HIGH)

### 복잡도 감소 패턴

| 패턴 | 효과 |
|------|------|
| **Early return** | 중첩 깊이 -2~3단계 |
| **Guard clause** | 예외 조건 상단 배치 |
| **Extract method** | 단일 책임 분리 |
| **Replace conditional with polymorphism** | if-else 체인 제거 |
| **Table-driven** | switch/case → 맵/딕셔너리 |

### 에러 처리 일관성

| 언어 | 권장 패턴 |
|------|----------|
| **Go** | `(value, error)` 튜플, sentinel errors |
| **Rust** | `Result<T, E>`, `?` 연산자 |
| **Python** | 커스텀 Exception 계층, `raise from` |
| **JS/TS** | 커스텀 Error 클래스, Result 패턴 |
| **Java** | checked exception 최소화, unchecked 선호 |

</code_quality>

---

<dependency_management>

## 6. 의존성 관리 (MEDIUM)

### 미사용 의존성 감지 도구

| 언어 | 도구 |
|------|------|
| **JS/TS** | `depcheck`, `knip` |
| **Python** | `pip-autoremove`, `deptry` |
| **Go** | `go mod tidy` (내장) |
| **Rust** | `cargo-udeps` |
| **Java** | `gradle-dependency-analysis` |

### 보안 취약점 스캔

| 언어 | 도구 |
|------|------|
| **JS/TS** | `npm audit`, `yarn audit`, `snyk` |
| **Python** | `pip-audit`, `safety` |
| **Go** | `govulncheck` |
| **Rust** | `cargo-audit` |
| **범용** | `trivy`, `grype`, Dependabot |

</dependency_management>

---

<references>

## 참고 자료

### 범용
1. [Google Engineering Practices](https://google.github.io/eng-practices/)
2. [The Twelve-Factor App](https://12factor.net/)

### 언어별
3. [Effective Go](https://go.dev/doc/effective_go)
4. [Rust Performance Book](https://nnethercote.github.io/perf-book/)
5. [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

</references>
