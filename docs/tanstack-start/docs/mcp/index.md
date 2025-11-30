# MCP (Model Context Protocol)

> Claude Code 작업 효율성을 높이는 MCP 서버 활용 가이드

---

## ⛔ 프로젝트 시작 전 필수 확인

**작업 시작 전 반드시 아래 3가지 MCP가 활성화되어 있는지 확인하세요:**

```
1. Serena - 프로젝트 활성화 확인
   → mcp__serena__get_current_config 호출
   → 프로젝트 미활성화 시: mcp__serena__activate_project

2. Sequential Thinking - 복잡한 문제 분석용
   → 사용 가능 여부 확인

3. sgrep - 코드베이스 검색용
   → grep/rg 대신 반드시 sgrep 사용
```

---

## 🚨 필수 사용 규칙

```
✅ 프로젝트 시작 전 → Serena 활성화 확인 (필수!)
✅ 코드베이스 검색 → sgrep 사용 (grep/rg 금지)
✅ 복잡한 분석/디버깅 → Sequential Thinking 사용
✅ 라이브러리 문서 조회 → Context7 사용
✅ 세션 컨텍스트 유지 → Serena 메모리 활용
✅ 도구 조합: sgrep로 위치 파악 → Sequential로 분석 → Context7로 문서 확인
```

---

## 🚀 Quick Reference

### Serena - 프로젝트 컨텍스트 관리 (필수)

```
프로젝트 시작 시 (필수):
1. get_current_config → 현재 상태 확인
2. activate_project → 프로젝트 활성화
3. check_onboarding_performed → 온보딩 확인

사용 시점:
- 프로젝트 시작/재개 시 (필수)
- 심볼 탐색/수정
- 세션 간 컨텍스트 유지 (메모리)
```

### Sequential Thinking - 복잡한 문제 해결

```
사용 시점:
- 버그 분석 및 디버깅
- 아키텍처 설계
- 복잡한 로직 구현
- 코드 리팩토링 계획
- 성능 최적화 분석

사용법: 문제를 단계별로 분해하여 체계적으로 해결
```

### sgrep - 코드베이스 검색 (필수)

```
사용 시점:
- 코드 위치 파악
- 자연어 검색
- 심볼 참조 찾기

주의: grep/rg 대신 반드시 sgrep 사용!
```

### Context7 - 라이브러리 문서 조회

```
사용 시점:
- API 사용법 확인
- 라이브러리 최신 문법 확인
- 공식 문서 기반 구현
- 버전별 변경사항 확인

사용법:
1. resolve-library-id로 라이브러리 ID 조회
2. get-library-docs로 문서 가져오기
```

---

## 📁 문서 구조

```
docs/mcp/
├── index.md              # 이 문서 (개요)
├── serena.md             # Serena 프로젝트 관리 (필수)
├── sgrep.md              # 코드베이스 검색 (필수)
├── sequential-thinking.md # Sequential Thinking 상세 (필수)
└── context7.md           # Context7 상세
```

---

## 📋 도구 목록

| 도구 | 용도 | 필수 여부 |
|-----|------|----------|
| [Serena](./serena.md) | 프로젝트 컨텍스트 관리 | ⭐ 필수 |
| [sgrep](./sgrep.md) | 코드베이스 검색 | ⭐ 필수 |
| [Sequential Thinking](./sequential-thinking.md) | 체계적 문제 해결 | ⭐ 필수 |
| [Context7](./context7.md) | 라이브러리 문서 | 권장 |

---

## ⚡ 작업별 MCP 선택 가이드

### 프로젝트 시작 (필수)
```
1. Serena: get_current_config로 상태 확인
2. Serena: activate_project로 프로젝트 활성화
3. Serena: list_memories로 이전 컨텍스트 확인
```

### 버그 수정
```
1. sgrep로 관련 코드 위치 파악
2. Sequential Thinking으로 문제 분석
3. 원인 파악 후 Context7로 관련 API 확인
4. 수정 구현
```

### 새 기능 구현
```
1. sgrep로 기존 패턴 검색
2. Sequential Thinking으로 구현 계획 수립
3. Context7로 사용할 라이브러리 문서 확인
4. 단계별 구현
5. Serena: write_memory로 주요 결정 저장
```

### 라이브러리 사용
```
1. Context7로 공식 문서 조회
2. 필요시 Sequential Thinking으로 복잡한 통합 분석
```

### 성능 최적화
```
1. sgrep로 병목 의심 코드 검색
2. Sequential Thinking으로 병목 분석
3. Context7로 최적화 관련 API 확인
4. 개선 구현
```

### 코드베이스 탐색
```
1. sgrep로 자연어 쿼리 검색
2. 관련 코드 위치 파악
3. 필요시 Sequential Thinking으로 흐름 분석
```

### 세션 종료
```
1. Serena: write_memory로 진행 상황 저장
2. 다음 세션에서 read_memory로 복구
```

---

## 🔗 관련 문서

- [TanStack Start](../library/tanstack-start/index.md) - Server Functions
- [Prisma](../library/prisma/index.md) - ORM
- [Zod](../library/zod/index.md) - Validation
