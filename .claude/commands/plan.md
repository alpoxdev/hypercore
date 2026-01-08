---
description: 개발 진행 방법 검토 및 옵션 제시
allowed-tools: Read, Glob, Grep, Bash, Task, Write, mcp__sequential-thinking__sequentialthinking
argument-hint: <개발할 기능 또는 해결할 문제>
---

@../instructions/git-rules.md
@../instructions/sequential-thinking-guide.md
@../instructions/common-patterns.md

# Plan Command

개발 진행 방법을 검토하고 2-3개 옵션과 장단점을 제시하는 커맨드.

**지시사항**: $ARGUMENTS

<requirements>

| 분류 | 필수 | 금지 |
|------|------|------|
| **Input** | 계획 대상 명시 | 빈 인수로 실행 |
| **Thinking** | Sequential 3-7단계 (@sequential-thinking-guide.md) | 3단계 미만 |
| **Analysis** | Task (Explore) 코드 탐색 | 추측으로 옵션 제시 |
| **Options** | 최소 2개, 장단점 필수 | 1개만 제시 |
| **Action** | 분석과 계획만 | Edit 사용 (코드 수정) |

</requirements>

<workflow>

1. **입력 확인**
   - ARGUMENT 없음 → 질문

2. **복잡도 판단**
   - Sequential Thinking (최소 3단계, 복잡 시 7+)

3. **코드베이스 탐색**
   - Task (Explore): 관련 파일, 현재 구조
   - 병렬 탐색 가능 (@common-patterns.md)

4. **옵션 도출**
   - 가능한 접근 방식 4-5개 열거
   - 주요 옵션 2-3개 선정
   - 장단점, 영향 범위, 예상 작업량

5. **사용자 선택**
   - 옵션 제시
   - 선택 대기

6. **계획 문서 작성** (선택 시)
   - .claude/plans/[기능명].md 생성

</workflow>

<options_format>

```markdown
## 분석 결과

### 옵션 1: [이름] (추천)

**접근 방식:**
- 설명 1
- 설명 2

| 장점 | 단점 |
|------|------|
| 장점 1 | 단점 1 |
| 장점 2 | 단점 2 |

**영향 범위:**
- 파일: `src/auth/`, `src/api/`
- 예상 변경 규모: 중간

---

### 옵션 2: [이름]
(동일 형식)

---

## 추천 및 근거

옵션 1을 추천합니다.
- 근거 1
- 근거 2

어떤 옵션을 선택하시겠습니까? (1/2/3)
```

</options_format>

<plan_document>

**파일**: `.claude/plans/[기능명].md`

```markdown
# [기능명] 구현 계획

## 개요
**목표:** [무엇을 달성]
**선택된 접근 방식:** [옵션 N]
**예상 영향 범위:** [파일/모듈]

## 현재 상태
- 현재 구조
- 관련 코드 위치
- 기존 제약사항

## 구현 단계

### 1단계: [이름]
**작업:**
- [ ] 작업 1
- [ ] 작업 2

**변경 파일:**
- `src/file1.ts`
- `src/file2.ts`

### 2단계: [이름]
(동일 형식)

## 고려사항

### 리스크
| 리스크 | 완화 방안 |
|--------|----------|
| 리스크 1 | 방안 1 |

### 의존성
- 외부 라이브러리
- 다른 시스템

### 롤백 계획
문제 발생 시 롤백 방법

## 검증 방법
- 테스트 항목 1
- 테스트 항목 2
```

</plan_document>

<examples>

```bash
/plan JWT에서 세션 기반 인증으로 변경

→ Sequential 7단계
→ Task (Explore): 현재 JWT 구현 분석
→ 옵션 제시:
   1. 점진적 마이그레이션 (추천)
   2. 완전 대체
   3. 하이브리드 방식
→ 사용자 선택: 1
→ 계획 문서 작성? Y
→ .claude/plans/session-auth.md 생성
```

```bash
/plan 실시간 알림 기능 추가

→ Sequential 5단계
→ Task (Explore): 기존 통신 구조
→ 옵션:
   1. WebSocket (추천)
   2. Server-Sent Events
   3. Polling
→ 선택 후 계획 문서 생성
```

</examples>
