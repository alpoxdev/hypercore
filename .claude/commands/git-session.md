---
description: 현재 세션에서 수정한 파일만 커밋 후 푸시
---

@../instructions/multi-agent/coordination-guide.md
@../instructions/multi-agent/execution-patterns.md

# Git Session Command

> @git-operator 에이전트를 사용하여 현재 세션 파일만 선택적으로 커밋하고 푸시.

---

<critical_requirements>

## ⚠️ CRITICAL: 작업 시작 전 필수 확인

**이 커맨드는 반드시 @git-operator 에이전트를 사용해야 합니다.**

### MANDATORY: Task 도구로 @git-operator 호출

```typescript
Task({
  subagent_type: 'git-operator',
  description: '세션 파일만 커밋 후 푸시',
  prompt: `
    세션 커밋 모드:
    - 현재 세션 관련 파일만 선택적 커밋
    - 반드시 푸시 (git push)
    - 이전 세션의 미완성 작업은 제외
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
- 현재 세션 파일만 선택

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

**세션 커밋 모드**

- **현재 세션 관련 파일만** 선택적 커밋
- **반드시 푸시** (git push)

</mode>

---

<selection_criteria>

| 포함 | 제외 |
|------|------|
| 현재 세션 관련 파일 | 이전 세션의 미완성 작업 |
| 방금 전 작업한 파일 | 자동 생성 파일 (lock, cache) |
| 관련 기능의 파일들 | 무관한 변경사항 |

</selection_criteria>

---

<workflow>

1. 모든 변경사항 분석
2. **현재 세션 관련 파일만 선택**
3. 논리적 단위로 그룹핑
4. 각 그룹별 커밋
5. git push 실행

</workflow>

---

<example>

```bash
# 상황: 로그인 기능 작업 중, 이전 프로필 기능은 미완성

git status
# modified: src/auth/login.ts (현재 세션)
# modified: src/auth/logout.ts (현재 세션)
# modified: src/profile/edit.ts (이전 세션)

# ✅ 로그인 관련만 커밋
git add src/auth/login.ts src/auth/logout.ts && git commit -m "feat: 로그인/로그아웃 기능 추가"
git push
```

</example>

