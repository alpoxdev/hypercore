---
name: bug-fix
description: 버그 원인 분석, 수정 옵션 제시, 사용자 선택 기반 구현과 검증까지 수행하는 스킬입니다.
compatibility: 코드 탐색(Read/Grep/Glob), 수정(Edit), 검증(Bash)이 가능한 환경에서 사용합니다.
---

# Bug Fix Skill

> 버그를 재현/분석하고, 옵션 제시 후 선택된 방식으로 안전하게 수정합니다.

<when_to_use>

| 상황 | 예시 |
|------|------|
| 타입 에러 | `Property 'X' does not exist on type 'Y'` |
| 런타임 에러 | `Cannot read property ... of undefined` |
| 논리 오류 | 중복 렌더링, 잘못된 계산, 상태 누락 |
| API 오류 | 4xx/5xx, 응답 형식 불일치 |
| 간헐적 오류 | 특정 조건에서만 실패 |

</when_to_use>

<argument_validation>

ARGUMENT가 없으면 즉시 질문합니다.

```text
어떤 버그를 수정해야 하나요?
- 에러 메시지/스택 트레이스
- 예상 동작 vs 실제 동작
- 재현 절차
- 관련 파일(알고 있다면)
```

</argument_validation>

<mandatory_reasoning>

## Mandatory Sequential Thinking

- 수정 전에 반드시 `sequential-thinking`을 실행합니다.
- 간단한 버그: 최소 3단계
- 보통 복잡도: 5단계
- 복잡한 버그: 7단계 이상

권장 흐름:

1. 복잡도 판단
2. 재현/증상 정리
3. 원인 가설
4. 수정 옵션 비교
5. 추천안 도출

</mandatory_reasoning>

<workflow>

| 단계 | 작업 | 도구 |
|------|------|------|
| 1 | 입력 확인 및 재현 정보 정리 | - |
| 2 | Sequential Thinking으로 분석 계획 수립 | sequential-thinking |
| 3 | 관련 코드 탐색 및 원인 분석 | Read/Grep/Glob |
| 4 | 수정 옵션 2-3개 제시 | - |
| 5 | 사용자 선택 대기 | - |
| 6 | 선택된 옵션 구현 | Edit |
| 7 | 타입/테스트/빌드 검증 | Bash |
| 8 | 결과 요약 및 변경 파일 보고 | - |

</workflow>

<option_presentation>

옵션은 아래 형식으로 제시합니다.

```markdown
## 버그 분석 결과
원인: ...
영향 범위: ...

### 옵션 1: ... (추천)
- 장점:
- 단점:
- 리스크:
- 수정 파일:

### 옵션 2: ...
- 장점:
- 단점:
- 리스크:
- 수정 파일:

### 옵션 3: ... (임시 대응)
- 장점:
- 단점:
- 리스크:
- 수정 파일:

추천: 옵션 N (근거 ...)
어떤 옵션으로 진행할까요? (1/2/3)
```

</option_presentation>

<implementation_rules>

- 사용자 선택 전에는 코드 수정을 시작하지 않습니다.
- 추측성 수정 대신 재현/원인 근거 기반으로 수정합니다.
- 수정 범위는 요청된 버그 해결에 필요한 범위로 제한합니다.
- 변경 후 반드시 검증 결과를 함께 보고합니다.

</implementation_rules>

<validation>

실행 체크리스트:

- [ ] ARGUMENT 확인 완료
- [ ] sequential-thinking 실행 완료
- [ ] 원인 분석 근거 확보
- [ ] 옵션 2-3개 제시
- [ ] 사용자 선택 확인
- [ ] 수정 후 typecheck/test/build 실행
- [ ] 결과 및 수정 파일 보고

금지:

- [ ] 근거 없는 추측 수정
- [ ] 옵션 제시 없이 바로 수정
- [ ] 선택 확인 없이 구현
- [ ] 검증 생략 후 완료 선언

</validation>
