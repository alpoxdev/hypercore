---
description: Task 도구로 subagent 생성. 복잡한 작업 위임.
allowed-tools: Task, mcp__sequential-thinking__sequentialthinking
argument-hint: <생성할 subagent 작업 설명>
---

# Subagent Creator

> Task 도구를 사용하여 전문 subagent를 생성하고 복잡한 작업을 위임하는 커맨드.

---

<agent_types>

## 주요 Agent Types

| Type | 용도 | 예시 |
|------|------|------|
| **Explore** | 코드베이스 구조 탐색, 파일 검색 | "React 컴포넌트 구조 분석" |
| **Plan** | 구현 전략 수립, 설계 계획 | "마이그레이션 단계별 계획" |
| **Bash** | Git 작업, 터미널 명령 실행 | "브랜치 생성 및 커밋" |
| **general-purpose** | 복합 작업, 다단계 조사 | "여러 모듈 의존성 분석" |

</agent_types>

---

<usage_patterns>

## 사용 패턴

### 단일 Subagent

```typescript
Task({
  subagent_type: 'Explore',
  description: '인증 구조 분석',
  prompt: `
    현재 인증 관련 코드 분석:
    - 사용 중인 라이브러리
    - 세션 관리 방식
    - 관련 파일 위치
  `
})
```

### 병렬 Subagent (독립 작업)

```typescript
// 단일 메시지에 여러 Task 호출
Task({
  subagent_type: 'Explore',
  description: '프론트엔드 구조',
  prompt: '프론트엔드 인증 흐름 분석'
})

Task({
  subagent_type: 'Explore',
  description: '백엔드 API',
  prompt: '백엔드 인증 엔드포인트 분석'
})

Task({
  subagent_type: 'Bash',
  description: 'Git 이력 확인',
  prompt: 'git log --grep="auth" 최근 커밋 조사'
})
```

### Model 선택 (선택적)

```typescript
Task({
  subagent_type: 'Explore',
  description: '간단한 파일 탐색',
  prompt: 'config 파일 위치 찾기',
  model: 'haiku'  // 빠르고 저렴한 작업
})
```

</usage_patterns>

---

<quick_tips>

## Quick Tips

| 팁 | 설명 |
|----|------|
| **description** | 3-5단어로 작업 요약 (사용자에게 표시) |
| **prompt** | 구체적 작업 내용, 명확한 목표 |
| **병렬 실행** | 독립적 작업은 단일 메시지에 여러 Task 호출 |
| **model** | 간단한 작업 → `haiku`, 복잡한 작업 → 생략(sonnet) |
| **Sequential Thinking** | agent 생성 전 복잡도 판단 권장 (3-5단계) |

</quick_tips>

---

<validation>

## 체크리스트

```text
✅ 작업이 복잡하여 subagent 필요
✅ description 3-5단어 (사용자 표시용)
✅ prompt 명확하고 구체적
✅ 독립 작업 → 병렬 실행 (단일 메시지)
✅ 의존 작업 → 순차 실행 (결과 대기)

❌ 단순 파일 읽기에 Task 사용 (Read 직접)
❌ 특정 클래스 검색에 Task 사용 (Glob 직접)
❌ 의존 작업을 병렬로 실행
❌ placeholder 값 전달 (결과 대기 후 전달)
```

</validation>
