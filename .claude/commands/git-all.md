---
description: 모든 변경사항 커밋 후 푸시
---

# Git All Command

@git-operator 에이전트를 사용하여 모든 변경사항을 커밋하고 푸시.

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
