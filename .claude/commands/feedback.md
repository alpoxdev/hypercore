---
description: 피드백 기반 코드 위치 탐색 및 수정
allowed-tools: Read, Edit, Glob, Grep, Bash, Task, mcp__sequential-thinking__sequentialthinking
argument-hint: <피드백 내용>
---

@../instructions/git-rules.md
@../instructions/sequential-thinking-guide.md
@../instructions/common-patterns.md

# Feedback Command

피드백을 분석하여 관련 코드를 찾고 수정하는 커맨드.

**지시사항**: $ARGUMENTS

<requirements>

| 분류 | 필수 | 금지 |
|------|------|------|
| **Input** | 피드백 내용 명시 | 빈 인수로 실행 |
| **Thinking** | Sequential 5-10단계 (@sequential-thinking-guide.md) | 5단계 미만 |
| **Exploration** | Task (Explore) 코드 탐색 (@common-patterns.md) | 추측으로 수정 |
| **Confirmation** | 수정 전 사용자 확인 | 무단 수정 |
| **Commit** | 완료 후 커밋 (@git-rules.md) | - |

</requirements>

<workflow>

1. **입력 확인**
   - ARGUMENT 없음 → "어떤 피드백을 수정해야 하나요?" 질문

2. **피드백 분석** (Sequential 5-10단계)
   - 피드백 의도 파악
   - 키워드 추출 (기능명, 변수명, 컴포넌트명)
   - 피드백 유형 분류 (버그, UI, 로직, 성능)
   - 예상 파일 위치 추론
   - 검색 전략 수립

3. **코드 탐색**
   - Task (Explore): 관련 파일 탐색
   - 병렬 탐색 가능

4. **후보 제시**
   - 확실 (1개) → 수정 계획 제시
   - 불확실 (2-3개) → 선택 요청

5. **사용자 확인**
   - Y/숫자 → 수정 진행
   - N → 추가 탐색

6. **수정 및 커밋**

</workflow>

<candidate_presentation>

**확실한 경우 (1개):**
```
수정 대상: src/components/Button.tsx:42

수정 계획:
- onClick 핸들러 null 체크 추가
- 에러 바운더리 적용

이대로 수정할까요? (Y/N)
```

**불확실한 경우 (2-3개):**
```
후보 위치:

1. src/components/Button.tsx:42 - onClick 핸들러
2. src/hooks/useSubmit.ts:28 - submit 에러 처리
3. src/api/client.ts:15 - API 에러 핸들링

어느 위치를 수정할까요? (1/2/3/N)
N → 다른 위치 탐색
```

</candidate_presentation>

<examples>

**간단한 버그:**
```bash
/feedback 로그인 버튼 클릭 시 아무 반응 없음

→ Sequential 5단계
→ Task (Explore): LoginButton 탐색
→ 후보: src/components/LoginButton.tsx
→ 확인: Y
→ 수정: onClick 핸들러 연결
→ git commit -m "fix: 로그인 버튼 onClick 핸들러 연결"
```

**복잡한 이슈:**
```bash
/feedback 결제 완료 후 페이지 리다이렉션 안됨

→ Sequential 10단계
→ Task 병렬:
   - 결제 플로우 탐색
   - 리다이렉션 로직 탐색
   - 상태 관리 확인
→ 후보 3개 제시
→ 선택: 2
→ 수정 진행
→ git commit -m "fix: 결제 완료 후 리다이렉션 로직 수정"
```

</examples>
