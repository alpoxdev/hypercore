---
description: tsc/eslint 오류 검사 및 하나씩 수정
allowed-tools: Bash, Read, Edit, mcp__sequential-thinking__sequentialthinking
argument-hint: [파일/디렉토리 경로...]
---

@../instructions/sequential-thinking-guide.md
@../instructions/common-patterns.md

# Lint Fix Command

tsc/eslint 오류를 하나씩 꼼꼼히 수정.

<requirements>

| 분류 | 필수 | 금지 |
|------|------|------|
| **Thinking** | Sequential 3-5단계 (각 오류마다) (@sequential-thinking-guide.md) | 분석 없이 수정 |
| **Tracking** | TodoWrite 오류 목록 (@common-patterns.md) | 진행 상황 미추적 |
| **Strategy** | 하나씩 수정 + 재검사 | 여러 오류 동시 수정 |

</requirements>

<workflow>

1. **오류 검사**
   - `tsc --noEmit` (타입 오류)
   - `eslint` (린트 오류)

2. **TodoWrite 생성**
   - 오류 목록 추적

3. **각 오류 수정** (순차)
   - Sequential Thinking (3-5단계)
     * 오류 메시지 분석
     * 코드 컨텍스트 파악
     * 근본 원인 식별
     * 수정 방안 검토
     * 최적 방안 선택
   - 수정 적용
   - TodoWrite 업데이트 (completed)
   - 재검사

4. **전체 재검사**

</workflow>

<check_commands>

```bash
# TypeScript
tsc --noEmit
npx tsc --noEmit

# ESLint
npx eslint .
npx eslint src/
```

</check_commands>

<example>

```bash
# 타입 오류: Property 'foo' does not exist on type 'Bar'

→ Sequential 5단계:
  1. 'foo' 프로퍼티 누락
  2. Bar 타입 정의 확인
  3. foo 필요 여부 판단
  4. 옵션: Bar에 foo 추가 vs 다른 타입 사용
  5. Bar 인터페이스에 foo 추가
→ 수정 적용
→ 재검사
```

</example>
