---
name: bug-fix
description: 버그 원인 분석, 수정 옵션 제시, 사용자 선택 기반 구현과 검증까지 수행하는 스킬입니다.
compatibility: 코드 탐색(Read/Grep/Glob), 수정(Edit), 검증(Bash)이 가능한 환경에서 사용합니다.
---

# Bug Fix Skill

> 구체적인 버그를 진단하고, 가장 안전한 수정 경로를 고른 뒤, 실제로 버그 수정 요청일 때만 구현까지 진행합니다.

<request_routing>

## Positive triggers

- `Cannot read properties of undefined`처럼 재현 경로가 있는 구체적인 런타임 에러
- 특정 기능 안에서 발생하는 중복 렌더링, stale state, 계산 오류 같은 구체적인 논리 버그
- 실패한 요청, 응답 형식 불일치, 단일 통합 경로 파손처럼 범위가 좁은 API 버그

## Out-of-scope

- 저장소 전체의 빌드/CI 복구 작업. 이 경우 `build-fix`로 라우팅합니다.
- 보안 감사, 익스플로잇 검토, 신뢰 경계 분석. 이 경우 `security-review`로 라우팅합니다.
- 구체적 버그와 무관한 신규 기능 개발, 리팩터링, 추측성 정리 작업

## Boundary cases

- 사용자가 원인 분석만 원하면 diagnosis 모드로 머물고 수정하지 않습니다.
- 사용자가 단일 구체적 버그의 직접 수정을 요청하면 이 스킬이 담당합니다.
- 시작은 버그였지만 범위가 저장소 전체 빌드 장애로 확대되면 `build-fix`로 넘깁니다.

</request_routing>

<argument_validation>

ARGUMENT가 없으면 즉시 질문합니다.

```text
어떤 버그를 수정해야 하나요?
- 에러 메시지 / 실패 증상
- 예상 동작 vs 실제 동작
- 재현 절차
- 관련 파일 또는 호출 지점
- 최근 변경, 의심 커밋, 또는 환경 정보
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

수정 전에 반드시 Root-cause evidence를 확보하고, 실제로 검증 가능한 minimal reproduction 또는 가장 좁은 failing boundary까지 문제를 줄입니다.

</mandatory_reasoning>

<execution_modes>

아래 분기 중 하나를 명시적으로 선택합니다.

- Diagnose-only: 재현, 실패 경로 격리, 근거 요약까지만 하고 코드 수정 전에 멈춥니다.
- Option-first: 가장 안전한 수정이 자명하지 않거나 트레이드오프가 크면 옵션 2-3개를 제시하고 대기합니다.
- Fix-now: 사용자가 직접 수정을 명시적으로 요청했고 가장 안전한 경로가 분명하면, 어떤 경로로 진행하는지 먼저 밝히고 추가 확인 라운드 없이 구현합니다.
- Handoff: 저장소 전체 빌드 장애는 `build-fix`, 보안 검토 요청은 `security-review`로 넘깁니다.

</execution_modes>

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

- 명시적인 Fix-now 분기가 아닌 한 사용자 선택 전에는 코드 수정을 시작하지 않습니다.
- 추측성 수정 대신 재현/원인 근거 기반으로 수정합니다.
- 수정 범위는 요청된 버그 해결에 필요한 범위로 제한합니다.
- 변경 경로에 맞는 targeted validation을 실행하고, 일반적인 명령 나열로 대체하지 않습니다.
- 최종 보고에는 commands run, key result lines, touched files를 함께 적습니다.
- 검증을 실행할 수 없으면 이유와 남아 있는 미검증 범위를 명시합니다.

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
