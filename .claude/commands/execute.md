---
description: 계획 실행 또는 간단한 작업 수행
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, Task, TodoWrite, mcp__sequential-thinking__sequentialthinking
argument-hint: <실행할 작업 또는 계획 파일명>
---

@../instructions/git-rules.md
@../instructions/sequential-thinking-guide.md
@../instructions/common-patterns.md

# Execute Command

계획 문서를 기반으로 실행하거나, 간단한 작업을 바로 수행하는 커맨드.

**지시사항**: $ARGUMENTS

<requirements>

| 분류 | 필수 | 금지 |
|------|------|------|
| **Input** | 작업 내용 명시 | 빈 인수로 실행 |
| **Thinking** | Sequential 2-5단계 (@sequential-thinking-guide.md) | 분석 없이 코드 수정 |
| **Progress** | TodoWrite 추적 (@common-patterns.md) | 상태 업데이트 누락 |
| **Commit** | 완료 후 커밋 (@git-rules.md) | 테스트 실패 상태로 커밋 |

</requirements>

<workflow>

1. **입력 확인**
   - ARGUMENT 없음 → "무엇을 실행할까요?" 질문
   - .claude/plans/*.md 존재 → 계획 기반 실행
   - 작업 설명 제공 → 직접 실행
   - 모호함 → 되물음

2. **복잡도 판단**
   - Sequential Thinking (2-5단계)
   - 복잡 시 → "/plan 먼저 세우시겠습니까?"

3. **코드 탐색** (필요시)
   - Task (Explore) 사용

4. **실행**
   - TodoWrite 생성
   - 단계별 진행 (in_progress → completed)
   - 테스트 확인

5. **커밋**
   - @git-rules.md 참고

</workflow>

<examples>

**계획 기반:**
```bash
/execute session-auth

→ .claude/plans/session-auth.md 읽기
→ TodoWrite: [세션 스토어, 미들웨어, API, 테스트]
→ 단계별 실행 및 완료 표시
→ git commit -m "feat: 세션 기반 인증 구현"
```

**직접 실행 (간단):**
```bash
/execute 로그인 버튼 색상을 파란색으로 변경

→ Sequential 2단계
→ TodoWrite: [LoginButton 수정, 확인]
→ Edit 수정
→ git commit -m "style: 로그인 버튼 색상 변경"
```

**직접 실행 (복잡):**
```bash
/execute 사용자 프로필 편집 기능 추가

→ Sequential 5단계
→ Task (Explore): 프로필 관련 코드
→ TodoWrite: [컴포넌트, API, 폼, 테스트]
→ git commit -m "feat: 사용자 프로필 편집 기능 추가"
```

</examples>
