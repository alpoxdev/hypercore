# Tech Stack

기술 스택 사용 패턴

## 파일 목록

| 파일 | 설명 |
|------|------|
| [tanstack-patterns.md](./tanstack-patterns.md) | TanStack Start/Router/Query 패턴 |
| [prisma-patterns.md](./prisma-patterns.md) | Prisma 7.x 사용 패턴 |
| [design-standards.md](./design-standards.md) | UI/UX 및 접근성 표준 |

## 사용법

```markdown
@.claude/instructions/tech-stack/tanstack-patterns.md
@.claude/instructions/tech-stack/prisma-patterns.md
@.claude/instructions/tech-stack/design-standards.md
```

## 빠른 참고

### TanStack Patterns

서버 함수, 라우팅, 쿼리 상태 관리 패턴

**주요 내용:**
- Server Function 작성 (GET/POST/PUT)
- inputValidator + middleware 체인
- Route loader 패턴
- TanStack Query (useQuery, useMutation)
- Optimistic Updates

### Prisma Patterns

데이터베이스 스키마 및 쿼리 작성 패턴

**주요 내용:**
- Prisma 7.x 버전 (prisma-client, output)
- Single/Multi-File 스키마 구조
- CRUD Operations
- Relations (1:N, N:N)
- N+1 Problem 방지
- Index 최적화

### Design Standards

UI/UX 및 접근성 표준

**주요 내용:**
- WCAG 2.2 AA 준수 (색상 대비 4.5:1+)
- ARIA 속성 및 키보드 네비게이션
- 60-30-10 색상 규칙
- 8px 간격 시스템
- Safe Area (iOS/Android)
- 반응형 디자인 (mobile-first)

## 체크리스트

### 문서 선택

- TanStack 작업 → [tanstack-patterns.md](./tanstack-patterns.md)
- 데이터베이스 작업 → [prisma-patterns.md](./prisma-patterns.md)
- UI/UX 작업 → [design-standards.md](./design-standards.md)

### 작업 전

- [ ] 해당 패턴 문서 읽기
- [ ] 체크리스트 항목 확인
- [ ] 코드 예시 참고
