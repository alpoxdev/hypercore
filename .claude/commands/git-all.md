---
description: 모든 변경사항 커밋 후 푸시
---

@../instructions/multi-agent/coordination-guide.md
@../instructions/multi-agent/execution-patterns.md

# Git All Command

> @git-operator 에이전트를 사용하여 모든 변경사항을 커밋하고 푸시.

---

<critical_requirements>

## ⚠️ CRITICAL: 작업 시작 전 필수 확인

**이 커맨드는 반드시 @git-operator 에이전트를 사용해야 합니다.**

### MANDATORY: Task 도구로 @git-operator 호출

```typescript
Task({
  subagent_type: 'git-operator',
  description: '모든 변경사항 커밋 후 푸시',
  prompt: `
    전체 커밋 모드:
    - 모든 변경사항을 논리적 단위로 분리하여 전부 커밋
    - 반드시 푸시 (git push)
    - clean working directory 확인 필수
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
- 완료 후 clean working directory 확인

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

**전체 커밋 모드**

- **모든 변경사항**을 논리적 단위로 분리하여 **전부 커밋**
- **반드시 푸시** (git push)
- **남은 변경사항 없음** (clean working directory) 확인 필수

</mode>

---

<workflow>

1. 모든 변경사항 분석
2. 논리적 단위로 그룹핑
3. 각 그룹별 커밋 (반복)
4. clean working directory 확인
5. git push 실행

</workflow>

