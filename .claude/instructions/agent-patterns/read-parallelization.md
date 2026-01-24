# Read Tool Parallelization

**목적**: 여러 파일을 동시에 읽어 분석 시간 단축

## 핵심 원칙

**독립적인 파일 읽기는 항상 병렬로 실행**

## 언제 병렬화하는가

| 상황 | 병렬화 |
|------|--------|
| 3개 이상 파일 읽기 | ✅ 필수 |
| 서로 다른 디렉토리 파일 | ✅ 권장 |
| 같은 패턴의 파일들 | ✅ 권장 |
| 순차 의존성 없음 | ✅ 가능 |

## 코드 패턴

### ❌ 잘못된 패턴 (순차)

```typescript
Read({ file_path: "src/routes/index.tsx" })
// 결과 대기...
Read({ file_path: "src/components/Header.tsx" })
// 결과 대기...
Read({ file_path: "src/lib/utils.ts" })
```

**문제점:**
- 총 시간 = T1 + T2 + T3
- 불필요한 대기 시간
- 컨텍스트 전환 비용

### ✅ 올바른 패턴 (병렬)

```typescript
// 단일 메시지에서 모든 Read 동시 호출
Read({ file_path: "src/routes/index.tsx" })
Read({ file_path: "src/components/Header.tsx" })
Read({ file_path: "src/lib/utils.ts" })
```

**장점:**
- 총 시간 = max(T1, T2, T3)
- 67-80% 시간 단축
- 효율적인 리소스 활용

## 실전 시나리오

### 시나리오 1: 프로젝트 구조 분석

```typescript
// ✅ 여러 설정 파일 동시 읽기
Read({ file_path: "package.json" })
Read({ file_path: "tsconfig.json" })
Read({ file_path: "vite.config.ts" })
Read({ file_path: ".claude/CLAUDE.md" })
```

### 시나리오 2: 관련 파일 분석

```typescript
// ✅ API 구현 + 타입 + 테스트 동시 읽기
Read({ file_path: "src/functions/user.ts" })
Read({ file_path: "src/types/user.ts" })
Read({ file_path: "src/functions/user.test.ts" })
```

### 시나리오 3: 컴포넌트 패밀리 분석

```typescript
// ✅ 부모 + 자식 컴포넌트들 동시 읽기
Read({ file_path: "src/routes/users/index.tsx" })
Read({ file_path: "src/routes/users/-components/UserList.tsx" })
Read({ file_path: "src/routes/users/-components/UserCard.tsx" })
Read({ file_path: "src/routes/users/-hooks/useUsers.ts" })
```

## 성능 비교

| 파일 수 | 순차 (초) | 병렬 (초) | 개선율 |
|---------|----------|----------|--------|
| 3개 | 6 | 2 | 67% |
| 5개 | 10 | 2 | 80% |
| 10개 | 20 | 2 | 90% |

**가정**: 각 파일 읽기 2초

## 체크리스트

Read 사용 전 확인:

- [ ] 읽을 파일이 2개 이상인가?
- [ ] 각 파일이 독립적인가?
- [ ] 순차적으로 읽어야 할 의존성이 있는가?

**2개 이상 독립 파일 → 무조건 병렬 실행**

## 주의사항

다음 경우는 순차 실행:

- 이전 파일의 내용에 따라 다음 파일 경로가 결정되는 경우
- 파일 A의 분석 결과가 파일 B 읽기 여부를 결정하는 경우
- 같은 파일을 여러 번 읽는 경우 (불필요)
