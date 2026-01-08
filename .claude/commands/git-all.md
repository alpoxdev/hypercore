---
description: 모든 변경사항 커밋 후 푸시
allowed-tools: Bash
---

@../instructions/git-rules.md

# Git All Command

모든 변경사항을 논리적 단위로 분리하여 전부 커밋 후 푸시.

<workflow>

1. **초기 분석** (병렬 실행 필수)
   ```bash
   git status
   git diff
   ```

2. **논리적 단위로 분리하여 커밋** (반복)
   - 하나의 커밋 = 하나의 논리적 변경

3. **완료 확인** (필수)
   ```bash
   git status  # clean working directory 확인
   ```
   - 남은 변경사항 없어야 함

4. **푸시**
   ```bash
   git push
   ```

</workflow>

<commit_principles>

| 분리 필요 | 묶어도 됨 |
|----------|----------|
| 서로 다른 기능 | 동일 기능의 관련 파일들 |
| 버그 수정 + 새 기능 | 동일 기능의 타입 + 구현 |
| 코드 + 문서 | |

</commit_principles>

<references>

커밋 형식과 prefix는 @git-rules.md 참조

</references>
