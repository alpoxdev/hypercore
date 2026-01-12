---
description: Git 상태 확인 및 커밋 작업
argument-hint: [push|pull|커밋 지시사항...]
---

# Git Command

> @git-operator 에이전트를 사용하여 Git 작업 수행.

---

<critical_requirements>

## ⚠️ CRITICAL: 작업 시작 전 필수 확인

**이 커맨드는 반드시 @git-operator 에이전트를 사용해야 합니다.**

### MANDATORY: Task 도구로 @git-operator 호출

```typescript
Task({
  subagent_type: 'git-operator',
  description: 'Git 커밋 작업',
  prompt: `
    $ARGUMENTS 처리:
    [사용자 인수 또는 기본 동작 설명]
  `
})
```

**❌ 절대 금지:**
- Bash 도구로 git 명령 직접 실행
- @git-operator 없이 커밋/푸시 수행
- 커맨드 내에서 직접 파일 분석

**✅ 필수:**
- Task 도구로 @git-operator 에이전트 호출
- 모든 git 작업을 에이전트에 위임

---

**진행 전 자가 점검:**
```text
□ Task 도구 사용 준비?
□ @git-operator 에이전트로 작업 위임?
□ Bash로 git 직접 실행 안 함?
```

**⚠️ 위 체크리스트를 통과하지 않으면 작업을 시작하지 마세요.**

</critical_requirements>

---

<mode>

**기본 모드**: 선택적 커밋

- 일부 변경사항만 커밋 가능
- 푸시는 선택적 (명시 시에만)

</mode>

---

<arguments>

**$ARGUMENTS 있음**: 해당 지시사항 우선 수행

| 예시 | 동작 |
|------|------|
| `push` | 커밋 후 푸시 |
| `pull` | git pull 먼저 실행 |
| `로그인 기능만` | 해당 파일만 커밋 |

**$ARGUMENTS 없음**: 기본 동작

1. git status, git diff 분석
2. 논리적 단위로 그룹핑
3. 선택적 커밋

</arguments>
