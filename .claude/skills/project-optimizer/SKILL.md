---
name: project-optimizer
description: 범용 프로젝트 최적화 스킬. 언어/프레임워크 무관하게 코드 품질, 성능, 빌드, DX를 분석하고 개선. 코드 리뷰, 리팩토링, 성능 개선, 빌드 최적화, 의존성 정리 작업에 트리거.
license: MIT
metadata:
  author: kood
  version: "1.0.0"
  adapted_for: universal
---

@../../instructions/agent-patterns/read-parallelization.md
@../../instructions/validation/forbidden-patterns.md
@../../instructions/validation/required-behaviors.md
@../../instructions/multi-agent/coordination-guide.md
@../../instructions/multi-agent/execution-patterns.md

# Project Optimizer

범용 프로젝트 최적화 가이드. 언어/프레임워크에 종속되지 않는 8개 카테고리, 38개 규칙. 영향도별 우선순위로 자동 분석/리팩토링/코드 생성 가이드 제공. 어떤 프로젝트든 적용 가능한 보편적 최적화 원칙 기반.

---

<when_to_use>

## 사용 시점

| 상황 | 설명 |
|------|------|
| **성능 개선** | 응답 시간, 처리량, 메모리 사용량 최적화 |
| **빌드 최적화** | 빌드 속도, 출력 크기, CI/CD 파이프라인 개선 |
| **코드 품질** | 데드 코드 제거, 복잡도 감소, 중복 제거 |
| **의존성 정리** | 미사용 패키지 제거, 보안 취약점, 버전 관리 |
| **DX 개선** | 타입 안전성, 린팅, 테스트, 컨벤션 강화 |
| **코드 리뷰** | 성능/품질 이슈 검토 |
| **리팩토링** | 기존 코드 구조 개선 |

</when_to_use>

---

<parallel_agent_execution>

## 병렬 에이전트 실행

### 기본 원칙

| 원칙 | 실행 방법 | 효과 |
|------|----------|------|
| **PARALLEL** | 독립 작업을 단일 메시지에서 동시 실행 | 5-15배 속도 향상 |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 | 품질 향상, 컨텍스트 격리 |
| **SMART MODEL** | 복잡도별 모델 선택 (haiku/sonnet/opus) | 비용 최적화 |

### Phase별 에이전트 활용

| Phase | 작업 | 에이전트 | 병렬 실행 |
|-------|------|---------|----------|
| **1. 프로젝트 분석** | 언어/프레임워크 감지, 구조 파악, 빌드 시스템 확인 | explore (haiku) | 여러 도메인 동시 탐색 |
| **2. 문제 진단** | 성능 병목, 코드 품질 이슈, 빌드 비효율 식별 | analyst (sonnet) | 카테고리별 동시 분석 |
| **3. 규칙 적용** | 최적화 규칙 적용, 리팩토링 실행 | implementation-executor (sonnet) | 독립 모듈/파일 동시 수정 |
| **4. 검증** | typecheck/lint/build/test 확인 | lint-fixer (sonnet), code-reviewer (opus) | lint 순차, review 병렬 |
| **5. 완료** | git commit | git-operator (sonnet) | 순차 |

### 실전 패턴

#### 패턴 1: 프로젝트 전체 분석 (Fan-Out)

```typescript
// 4개 도메인 동시 탐색 (60초)
Task(subagent_type="explore", model="haiku",
     prompt="프로젝트 언어/프레임워크/빌드 시스템 감지. package.json, Cargo.toml, go.mod, pyproject.toml, Makefile 등 확인")

Task(subagent_type="explore", model="haiku",
     prompt="코드 구조 분석: 디렉토리 구조, 진입점, 모듈 의존성 그래프 파악")

Task(subagent_type="explore", model="haiku",
     prompt="빌드/CI 설정 분석: 빌드 스크립트, CI 파이프라인, Docker 설정")

Task(subagent_type="explore", model="haiku",
     prompt="의존성 분석: 직접/간접 의존성 수, 보안 취약점, 미사용 패키지")
```

#### 패턴 2: 카테고리별 병렬 최적화

```typescript
// 독립 모듈에 다른 규칙 동시 적용
Task(subagent_type="implementation-executor", model="sonnet",
     prompt="모듈 A 최적화: concurrency-parallel, io-batch-queries")

Task(subagent_type="implementation-executor", model="sonnet",
     prompt="모듈 B 최적화: memory-pool-reuse, code-dead-elimination")
```

#### 패턴 3: 대규모 리팩토링 (배치 처리)

```typescript
// 10개+ 파일에 동일 규칙 적용 (토큰 70-90% 절감)
Task(subagent_type="implementation-executor", model="sonnet",
     prompt=`다음 파일들에 concurrency-parallel 적용:
     파일 목록: [...]
     공통 규칙: 독립 I/O는 동시 실행`)
```

### Model Routing

| 복잡도 | 모델 | 작업 예시 | 비용 | 속도 |
|--------|------|----------|------|------|
| **LOW** | haiku | 파일 구조 파악, 의존성 목록 확인 | 1x | 3x |
| **MEDIUM** | sonnet | 규칙 적용, 리팩토링 실행 | 2x | 2x |
| **HIGH** | opus | 아키텍처 설계, 보안 검토, 성능 전략 | 3x | 1x |

</parallel_agent_execution>

---

<categories>

## 카테고리별 우선순위

| 우선순위 | 카테고리 | 영향도 | 접두사 | 적용 범위 |
|---------|---------|--------|--------|----------|
| 1 | 동시성/병렬화 | **CRITICAL** | `concurrency-` | 모든 언어 |
| 2 | 빌드/번들 최적화 | **CRITICAL** | `build-` | 빌드 시스템 보유 프로젝트 |
| 3 | I/O 성능 | **HIGH** | `io-` | DB/네트워크/파일 I/O 사용 |
| 4 | 메모리/리소스 관리 | HIGH | `memory-` | 모든 언어 |
| 5 | 코드 품질 | MEDIUM-HIGH | `code-` | 모든 프로젝트 |
| 6 | 의존성 관리 | MEDIUM | `deps-` | 패키지 매니저 사용 |
| 7 | DX (개발자 경험) | MEDIUM | `dx-` | 팀 프로젝트 |
| 8 | 아키텍처 | LOW-MEDIUM | `arch-` | 중대형 프로젝트 |

</categories>

---

<rules>

## 빠른 참조

### 1. 동시성/병렬화 (CRITICAL)

| 규칙 | 설명 |
|------|------|
| `concurrency-parallel` | 독립 작업은 동시 실행 (Promise.all, goroutine, asyncio.gather, rayon 등) |
| `concurrency-defer-await` | await/블로킹을 실제 사용 지점으로 이동 |
| `concurrency-pipeline` | 파이프라인 병렬화 (생산자-소비자, 스트리밍) |
| `concurrency-pool` | 동시 실행 수 제한 (connection pool, worker pool, semaphore) |

### 2. 빌드/번들 최적화 (CRITICAL)

| 규칙 | 설명 |
|------|------|
| `build-incremental` | 증분 빌드 활성화 (캐시, 변경 감지) |
| `build-tree-shake` | 미사용 코드 자동 제거 (dead code elimination) |
| `build-code-split` | 진입점/라우트별 코드 분할 (lazy loading) |
| `build-minify` | 프로덕션 출력 최소화 (minification, compression) |
| `build-cache` | 빌드 캐시 활용 (CI/로컬) |

### 3. I/O 성능 (HIGH)

| 규칙 | 설명 |
|------|------|
| `io-batch-queries` | N+1 쿼리 → 배치/조인으로 전환 |
| `io-cache-layer` | 반복 읽기에 캐시 레이어 추가 (TTL, LRU, 인메모리) |
| `io-stream` | 대용량 데이터는 스트리밍 처리 (청크, 이터레이터, 제너레이터) |
| `io-connection-reuse` | 커넥션 풀/keep-alive/재사용 |
| `io-serialize-minimal` | 필요한 필드만 직렬화/전송 |

### 4. 메모리/리소스 관리 (HIGH)

| 규칙 | 설명 |
|------|------|
| `memory-leak-prevention` | 리소스 해제 보장 (close, dispose, cleanup, finally) |
| `memory-pool-reuse` | 객체 풀링/재사용 (버퍼, 커넥션, 스레드) |
| `memory-lazy-init` | 비싼 초기화는 지연 실행 |
| `memory-bounded-cache` | 캐시에 크기 제한 설정 (LRU, TTL, maxSize) |
| `memory-large-data` | 대용량 데이터는 스트림/페이지네이션 처리 |

### 5. 코드 품질 (MEDIUM-HIGH)

| 규칙 | 설명 |
|------|------|
| `code-dead-elimination` | 미사용 코드/변수/import 제거 |
| `code-duplication` | 중복 코드 추출/통합 (DRY, 단 3회 이상부터) |
| `code-complexity` | 순환 복잡도 감소 (early return, guard clause, 분리) |
| `code-naming` | 의도를 드러내는 명확한 이름 |
| `code-error-handling` | 일관된 에러 처리 패턴 (Result, Either, 에러 타입 계층) |

### 6. 의존성 관리 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `deps-unused-removal` | 미사용 의존성 제거 |
| `deps-security-audit` | 보안 취약점 스캔 및 업데이트 |
| `deps-version-pin` | 프로덕션 의존성 버전 고정 |
| `deps-lightweight-alt` | 무거운 라이브러리 → 경량 대안 또는 자체 구현 |
| `deps-peer-align` | peer dependency 버전 충돌 해결 |

### 7. DX - 개발자 경험 (MEDIUM)

| 규칙 | 설명 |
|------|------|
| `dx-type-safety` | 타입 시스템 최대 활용 (strict mode, 제네릭, 유니온) |
| `dx-lint-config` | 린터/포매터 최적 설정 |
| `dx-test-coverage` | 핵심 로직 테스트 커버리지 확보 |
| `dx-ci-speed` | CI 파이프라인 속도 최적화 (캐시, 병렬, 불필요 단계 제거) |
| `dx-dev-server` | 로컬 개발 서버 시작 속도 개선 |

### 8. 아키텍처 (LOW-MEDIUM)

| 규칙 | 설명 |
|------|------|
| `arch-module-boundary` | 모듈 경계 명확화 (순환 의존 제거) |
| `arch-interface-segregation` | 인터페이스 분리 (큰 인터페이스 → 작은 단위) |
| `arch-config-centralize` | 설정/환경변수 중앙 관리 |
| `arch-hot-path` | 핫 패스 식별 및 집중 최적화 |

</rules>

---

<language_detection>

## 언어/프레임워크 자동 감지

### 감지 매트릭스

| 감지 파일 | 언어/도구 | 추가 확인 |
|-----------|----------|----------|
| `package.json` | Node.js/TypeScript | `tsconfig.json` → TS |
| `Cargo.toml` | Rust | `rust-toolchain.toml` |
| `go.mod` | Go | `go.sum` |
| `pyproject.toml` / `requirements.txt` | Python | `setup.py`, `poetry.lock` |
| `pom.xml` / `build.gradle` | Java/Kotlin | `settings.gradle` |
| `Gemfile` | Ruby | `Rakefile` |
| `composer.json` | PHP | |
| `mix.exs` | Elixir | |
| `CMakeLists.txt` | C/C++ | `Makefile` |
| `*.sln` / `*.csproj` | C#/.NET | |
| `pubspec.yaml` | Dart/Flutter | |
| `Package.swift` | Swift | `*.xcodeproj` |

### 감지 후 동작

1. **규칙 필터링**: 감지된 언어의 `languages` 태그가 `all` 또는 해당 언어를 포함하는 규칙만 적용
2. **예시 선택**: 규칙 내 코드 예시 중 감지된 언어의 관용적 패턴 우선 제시
3. **도구 매핑**: 감지된 언어에 맞는 빌드/린트/테스트 도구 자동 선택
4. **프레임워크 체이닝**: 프레임워크 감지 시 해당 best-practices 스킬 자동 참조

</language_detection>

---

<workflow>

## 실행 워크플로우

### Phase 1: 프로젝트 분석 (병렬)

```
1. 언어/프레임워크/빌드 시스템 감지 (explore x haiku)
2. 코드 구조/모듈 의존성 파악 (explore x haiku)
3. 빌드/CI 설정 분석 (explore x haiku)
4. 의존성 상태 분석 (explore x haiku)
```

### Phase 2: 문제 진단 (병렬)

```
1. 카테고리별 이슈 스캔 (analyst x sonnet)
   - 우선순위 1-4 (CRITICAL/HIGH) 집중
   - 각 이슈에 영향도/규칙 매핑
2. 기존 best-practices 스킬과 교차 참조
   - nextjs-react-best-practices (Next.js 프로젝트)
   - tanstack-start-react-best-practices (TanStack 프로젝트)
   - tauri-react-best-practices (Tauri 프로젝트)
```

### Phase 3: 최적화 실행 (병렬)

```
1. CRITICAL 이슈 먼저 (concurrency, build)
2. HIGH 이슈 (io, memory)
3. MEDIUM+ 이슈 (code, deps, dx)
4. 독립 모듈은 병렬 실행
```

### Phase 4: 검증

```
1. 빌드 성공 확인
2. 테스트 통과 확인
3. 린트/타입체크 확인
4. 성능 벤치마크 (있으면)
```

</workflow>

---

<skill_chaining>

## 다른 스킬과 병행

### 자동 감지 및 체이닝

| 감지 조건 | 추천 스킬 | 역할 |
|-----------|----------|------|
| Next.js 프로젝트 | `nextjs-react-best-practices` | 프레임워크 특화 규칙 병행 |
| TanStack Start 프로젝트 | `tanstack-start-react-best-practices` | 프레임워크 특화 규칙 병행 |
| Tauri 프로젝트 | `tauri-react-best-practices` | IPC/보안/번들 특화 규칙 병행 |
| 코드 구조 문제 | `refactor` | 구조적 리팩토링 계획 |
| 버그 발견 | `bug-fix` | 버그 수정 워크플로우 |
| 의존성 문서 필요 | `docs-fetch` | 라이브러리 문서 수집 |
| 배포 전 검증 | `pre-deploy` | typecheck/lint/build 전체 검증 |

### 우선순위 규칙

| 우선순위 | 규칙 |
|---------|------|
| 1 | **프레임워크 특화 스킬 우선**: 프레임워크 스킬의 규칙이 project-optimizer 범용 규칙보다 우선 |
| 2 | **충돌 시 특화 우선**: 동일 주제에서 범용 규칙과 프레임워크 규칙이 충돌하면 프레임워크 규칙 적용 |
| 3 | **보완 병행**: 프레임워크 스킬에 없는 카테고리 (concurrency, memory, deps 등)는 project-optimizer 규칙 적용 |
| 4 | **단계적 적용**: Phase 1-2에서 project-optimizer 분석 → Phase 3에서 프레임워크 스킬과 병합 실행 |

</skill_chaining>

---

<usage>

## 사용법

**상세 규칙 및 예시:**

```
rules/concurrency-parallel.md
rules/build-incremental.md
rules/io-batch-queries.md
rules/memory-leak-prevention.md
rules/code-dead-elimination.md
rules/deps-unused-removal.md
rules/dx-type-safety.md
rules/arch-module-boundary.md
```

각 규칙 파일 포함 내용:
- 중요한 이유 설명
- 여러 언어의 ❌ 잘못된 코드 예시
- 여러 언어의 ✅ 올바른 코드 예시
- 추가 컨텍스트 및 참조

</usage>

---

<references>

## 참고 자료

### 범용
1. [Google Engineering Practices](https://google.github.io/eng-practices/)
2. [The Twelve-Factor App](https://12factor.net/)

### 언어별
3. [Effective Go](https://go.dev/doc/effective_go)
4. [Rust Performance Book](https://nnethercote.github.io/perf-book/)
5. [Python Performance Tips](https://docs.python.org/3/howto/perf_profiling.html)
6. [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

### 빌드/번들
7. [Vite Performance](https://vite.dev/guide/performance)
8. [webpack Tree Shaking](https://webpack.js.org/guides/tree-shaking/)
9. [Turborepo](https://turbo.build/repo/docs)

</references>
