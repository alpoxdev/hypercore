---
name: bug-fix
description: 버그 원인 분석, 수정 옵션 제시, 사용자 선택 기반 구현과 검증까지 수행하는 스킬. 간단한 버그는 바로 수정하고, 복잡한 버그는 .hypercore/bug-fix/ JSON 플로우로 진행 상황을 추적한다.
compatibility: 코드 탐색(Read/Grep/Glob), 수정(Edit), 검증(Bash)이 가능한 환경에서 사용.
---

# Bug Fix Skill

> 구체적인 버그를 진단하고, 가장 안전한 수정 경로를 고른 뒤 구현한다 — 복잡도를 먼저 판단하고, 간단하면 바로 수정하고 복잡하면 단계별로 추적하며 진행한다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 아티팩트, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋/메시지 초안, 검증 메모는 기본적으로 한국어로 작성합니다.

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지합니다.

사용자가 명시적으로 다른 언어를 요청했거나, 기존 대상 산출물의 언어 일관성을 맞춰야 하거나, 기계 판독 계약상 정확한 영어 토큰이 필요한 경우에만 다른 언어를 사용합니다. 사용자-facing 산출물에 쓸 로컬라이즈된 템플릿/참조(`*.ko.md`, `*.ko.json` 등)가 있으면 우선 사용합니다.

</output_language>

<request_routing>

## Positive triggers

- `Cannot read properties of undefined`처럼 재현 경로가 있는 구체적인 런타임 에러
- 특정 기능 안에서 발생하는 중복 렌더링, stale state, 계산 오류 같은 구체적인 논리 버그
- 실패한 요청, 응답 형식 불일치, 단일 통합 경로 파손처럼 범위가 좁은 API 버그

## Out-of-scope

- 저장소 전체의 빌드/CI 복구 작업. 이 경우 `build-fix`로 라우팅
- 보안 감사, 익스플로잇 검토, 신뢰 경계 분석. 이 경우 `security-review`로 라우팅
- 구체적 버그와 무관한 신규 기능 개발, 리팩터링, 추측성 정리 작업

## Boundary cases

- 사용자가 원인 분석만 원하면 diagnosis 모드로 머물고 수정하지 않는다.
- 사용자가 단일 구체적 버그의 직접 수정을 요청하면 이 스킬이 담당한다.
- 시작은 버그였지만 범위가 저장소 전체 빌드 장애로 확대되면 `build-fix`로 넘긴다.

</request_routing>

<argument_validation>

ARGUMENT가 없으면 즉시 질문:

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

## 필수 순차적 사고

수정 전에 반드시 `sequential-thinking`을 실행한다. 깊이는 복잡도에 비례:

- **간단 (3단계)**: 원인 파악 → 수정 결정 → 검증 방법 확인
- **보통 (5단계)**: 분류 → 재현 → 가설 → 옵션 비교 → 추천
- **복잡 (7단계 이상)**: 분류 → 재현 → 다중 원인 가설 → 의존성 탐색 → 옵션 비교 → 교차 영향 평가 → 추천

권장 흐름:

1. 복잡도 판단
2. 재현/증상 정리
3. 원인 가설
4. 수정 옵션 비교
5. 추천안 도출

수정 전에 반드시 root-cause evidence를 확보하고, 실제로 검증 가능한 minimal reproduction 또는 가장 좁은 failing boundary까지 문제를 줄인다.

</mandatory_reasoning>

<complexity_classification>

## 복잡도 분류

sequential-thinking 직후에 즉시 분류:

| 복잡도 | 신호 | 경로 |
|--------|------|------|
| **간단** | 단일 파일, 명확한 에러 메시지, 원인 자명, 수정 경로 1개, 리스크 낮음 | **Fix-now** — 플로우 추적 없이 바로 수정 |
| **복잡** | 교차 영향 버그, 원인 후보 다수, 다중 시스템 조사 필요, 수정에 사이드 이펙트, 유효한 수정 전략 다수 | **추적 모드** — `.hypercore/bug-fix/flow.json` 생성 |

분류 결과 발표:

```
복잡도: [간단/복잡] — [한 줄 근거]
```

판단이 애매하면 복잡으로 분류한다. 추적하는 비용이 조사 진행 상황을 잃는 비용보다 낮다.

</complexity_classification>

<flow_tracking>

## 플로우 추적 (복잡 경로만)

복잡으로 분류되면 플로우를 초기화:

```bash
mkdir -p .hypercore/bug-fix
```

`.hypercore/bug-fix/flow.json`을 작성하고 각 단계 완료 시 업데이트한다. 전체 스키마는 `references/flow-schema.md` 참조.

### 단계 진행

| 단계 | 설명 | 다음 |
|------|------|------|
| `diagnose` | 재현, 원인 분석, 근거 수집 | `options` |
| `options` | 수정 옵션 2-3개 제시 | `confirm` |
| `confirm` | 사용자 선택 대기 및 기록 | `fix` |
| `fix` | 선택된 옵션 구현 | `verify` |
| `verify` | 검증 실행, 결과 보고 | 완료 |

### 재개 지원

`.hypercore/bug-fix/flow.json`이 이미 존재하면 먼저 읽고 마지막 미완료 단계(`in_progress` 또는 `pending`)부터 이어간다. 완료된 단계를 재시작하지 않는다.

</flow_tracking>

<execution_modes>

아래 분기 중 하나를 명시적으로 선택:

- **Diagnose-only**: 재현, 실패 경로 격리, 근거 요약까지만 하고 코드 수정 전에 멈춘다.
- **Fix-now** (간단 경로): 사용자가 직접 수정을 명시적으로 요청했고 가장 안전한 경로가 분명하면, 어떤 경로로 진행하는지 먼저 밝히고 추가 확인 없이 구현한다. 플로우 추적 없음.
- **Option-first** (복잡 경로): 플로우 추적과 함께 옵션 2-3개를 제시하고 사용자 선택을 기다린다.
- **Handoff**: 저장소 전체 빌드 장애는 `build-fix`, 보안 검토 요청은 `security-review`로 넘긴다.

</execution_modes>

<workflow>

## 간단 경로 (Fix-now)

| 단계 | 작업 | 도구 |
|------|------|------|
| 1 | 입력 확인, sequential-thinking (3단계) | sequential-thinking |
| 2 | 간단으로 분류 | - |
| 3 | 관련 코드 탐색, 원인 파악 | Read/Grep/Glob |
| 4 | 수정 경로 발표 후 구현 | Edit |
| 5 | 검증 (타입체크/테스트/빌드) | Bash |
| 6 | 결과 보고 | - |

## 복잡 경로 (Option-first)

| 단계 | 작업 | 도구 |
|------|------|------|
| 1 | 입력 확인, sequential-thinking (7단계 이상) | sequential-thinking |
| 2 | 복잡으로 분류, `.hypercore/bug-fix/flow.json` 생성 | Write |
| 3 | 심층 조사 → 플로우 `diagnose: completed` 업데이트 | Read/Grep/Glob + Edit |
| 4 | 수정 옵션 2-3개 제시 → 플로우 `options: completed` 업데이트 | Edit |
| 5 | 사용자 선택 대기 → 플로우 `confirm: completed` 업데이트 | Edit |
| 6 | 선택된 옵션 구현 → 플로우 `fix: completed` 업데이트 | Edit/Write |
| 7 | 검증 실행 → 플로우 `verify: completed` 업데이트 | Bash + Edit |
| 8 | 결과 보고, 플로우 status를 `completed`로 설정 | Edit |

</workflow>

<option_presentation>

옵션은 아래 형식으로 제시 (복잡 경로):

```markdown
## 버그 분석 결과
**원인**: ...
**영향 범위**: ...
**복잡도**: 복잡

### 옵션 1: ... (추천)
- **장점**:
- **단점**:
- **리스크**:
- **수정 파일**:

### 옵션 2: ...
- **장점**:
- **단점**:
- **리스크**:
- **수정 파일**:

### 옵션 3: ... (임시 대응)
- **장점**:
- **단점**:
- **리스크**:
- **수정 파일**:

추천: 옵션 N (근거 ...)
어떤 옵션으로 진행할까요? (1/2/3)
```

</option_presentation>

<implementation_rules>

- 명시적인 Fix-now 분기가 아닌 한 사용자 선택 전에는 코드 수정을 시작하지 않는다.
- 추측성 수정 대신 재현/원인 근거 기반으로 수정한다.
- 수정 범위는 요청된 버그 해결에 필요한 범위로 제한한다.
- 변경 경로에 맞는 targeted validation을 실행하고, 일반적인 명령 나열로 대체하지 않는다.
- 최종 보고에는 commands run, key result lines, touched files를 함께 적는다.
- 검증을 실행할 수 없으면 이유와 남아 있는 미검증 범위를 명시한다.

## 보고

실행 후 보고:

```markdown
## 완료

**버그**: [원본 증상]
**원인**: [무엇이 잘못되었는지]
**적용한 수정**: [어떤 옵션/접근법]
**변경사항**: [변경된 파일 목록]
**검증**: [검증한 내용과 결과]
```

복잡 경로: `.hypercore/bug-fix/flow.json`의 status도 `completed`로 업데이트한다.

</implementation_rules>

<validation>

실행 체크리스트:

- [ ] ARGUMENT 확인 완료
- [ ] sequential-thinking 실행 완료 (복잡도에 비례한 깊이)
- [ ] 복잡도 분류 완료 (간단/복잡)
- [ ] 플로우 JSON 생성 및 유지 (복잡 경로만)
- [ ] 원인 분석 근거 확보
- [ ] 옵션 2-3개 제시 (복잡 경로) 또는 수정 경로 발표 (간단 경로)
- [ ] 사용자 선택 확인 (복잡 경로)
- [ ] 수정 후 typecheck/test/build 실행
- [ ] 결과 및 수정 파일 보고
- [ ] 플로우 JSON `completed` 상태로 마무리 (복잡 경로만)

금지:

- [ ] 근거 없는 추측 수정
- [ ] 옵션 제시 없이 바로 수정 (복잡 경로)
- [ ] 선택 확인 없이 구현 (복잡 경로)
- [ ] 검증 생략 후 완료 선언
- [ ] 복잡 경로에서 플로우 JSON 업데이트 누락

</validation>
