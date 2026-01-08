---
description: PRD(Product Requirements Document) 생성
allowed-tools: Read, Write, Glob, Grep, Task, mcp__sequential-thinking__sequentialthinking
argument-hint: <기능/제품 설명>
---

@../instructions/sequential-thinking-guide.md

# PRD Command

기능/제품의 요구사항 문서(PRD)를 작성.

<requirements>

| 분류 | 필수 | 금지 |
|------|------|------|
| **Input** | 기능/제품 설명 명시 | 빈 인수로 실행 |
| **Thinking** | Sequential 3-5단계 (@sequential-thinking-guide.md) | - |

</requirements>

<workflow>

1. **입력 확인**
   - ARGUMENT 없음 → 질문

2. **Sequential Thinking** (3-5단계)
   - 제품/기능 이해
   - 사용자 시나리오 도출
   - 기술적 요구사항 정리

3. **코드베이스 확인** (필요시)
   - Task (Explore): 관련 코드 확인

4. **PRD 작성**

5. **저장**
   - .claude/plans/ 또는 docs/prd/

</workflow>

<template>

```markdown
# [기능/제품명] PRD

## 개요
**목적**: 무엇을 해결하는가
**사용자**: 누가 사용하는가
**우선순위**: High | Medium | Low

## 사용자 스토리
- As a [역할], I want to [행동] so that [목적]
- ...

## 기능 요구사항
1. **[기능 1]**
   - 설명
   - 인수 조건

2. **[기능 2]**
   - ...

## 비기능 요구사항
- 성능: ...
- 보안: ...
- 접근성: ...

## 기술 스택
- 프론트엔드: ...
- 백엔드: ...
- 데이터베이스: ...

## 제약사항
- 제약 1
- 제약 2

## 성공 지표
- 지표 1
- 지표 2

## 타임라인 (선택)
- 1단계: ...
- 2단계: ...
```

</template>

<example>

```bash
/prd 사용자 프로필 편집 기능

→ Sequential 5단계
→ PRD 작성
→ .claude/plans/profile-edit-prd.md 저장
```

</example>
