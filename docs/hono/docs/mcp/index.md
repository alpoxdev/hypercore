# MCP 도구 가이드

> Claude Code에서 사용하는 MCP (Model Context Protocol) 도구

---

## 📋 MCP 도구 개요

| 도구 | 용도 | 사용 시점 |
|------|------|----------|
| **sgrep** | 코드 검색 | 코드베이스 검색 시 (grep/rg 대신) |
| **Sequential Thinking** | 복잡한 분석 | 디버깅, 아키텍처 분석 |
| **Context7** | 라이브러리 문서 | 공식 문서 참조 필요 시 |

---

## sgrep - 코드 검색

> ⚠️ **필수**: 코드베이스 검색 시 grep/rg 대신 sgrep 사용

### 사용 시점
- 코드베이스에서 패턴 검색
- 함수/클래스 사용처 찾기
- 특정 패턴의 코드 찾기

### 장점
- AST 기반 시맨틱 검색
- 언어별 최적화된 패턴 매칭
- 정확한 코드 구조 인식

---

## Sequential Thinking - 분석 도구

> 복잡한 문제를 단계별로 분석

### 사용 시점
- 복잡한 버그 디버깅
- 아키텍처 분석/설계
- 성능 병목 분석
- 리팩토링 계획 수립

### 특징
- 단계별 사고 과정 기록
- 가설 설정 및 검증
- 체계적인 문제 해결

---

## Context7 - 라이브러리 문서

> 공식 라이브러리 문서 조회

### 사용 시점
- 라이브러리 API 확인
- 공식 문서 패턴 참조
- 최신 버전 사용법 확인

### 지원 라이브러리
- Hono
- Zod
- Prisma
- 기타 주요 라이브러리

### 사용 예시
```
Context7로 Hono middleware 문서 조회
Context7로 Zod v4 validation 문서 조회
Context7로 Prisma transaction 문서 조회
```

---

## MCP 도구 선택 가이드

```
코드 검색이 필요한가?
├─ Yes → sgrep 사용
└─ No
   ├─ 복잡한 분석이 필요한가?
   │  ├─ Yes → Sequential Thinking 사용
   │  └─ No
   │     └─ 라이브러리 문서가 필요한가?
   │        ├─ Yes → Context7 사용
   │        └─ No → 일반 도구 사용
```

---

## 관련 문서

- [sgrep 상세](./sgrep.md)
- [Sequential Thinking 상세](./sequential-thinking.md)
- [Context7 상세](./context7.md)
