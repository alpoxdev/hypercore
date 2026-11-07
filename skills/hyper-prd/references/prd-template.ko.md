# PRD Template

`prd.md`를 새로 만들거나 구조를 바꿀 때 이 참조를 사용한다. 절 순서, 골격, 예시 하나를 소유한다.

## Contents

- Section order
- Skeleton
- Worked example
- Rules

## Section order

1. 메타: 상태, 플랫폼, 규모, 갱신일
2. 한 줄 정의
3. 문제와 근거
4. 대상 사용자와 명시적 제외 대상
5. 목표와 지표
6. 범위: P1/P2/P3 스토리, 비목표, 바뀌면 안 되는 동작
7. 기능 요구사항
8. 인수 시나리오
9. 플랫폼 요구사항
10. 가정
11. 열린 질문
12. 위험과 의존성
13. 변경 이력
14. 핸드오프 블록

적용되지 않는 절은 지운다. 내용 없이 제목만 두지 않고 `N/A`도 쓰지 않는다.

## Skeleton

```markdown
# <제품 또는 기능 이름> PRD

## Meta

- Status: draft | ready | revised
- Platforms: web | ios | android | desktop (하나 이상)
- Size: S | M | L
- Updated: YYYY-MM-DD

## Definition

<한 문장. 무엇이고, 누구를 위한 것이며, 무엇이 달라지는지.>

## Problem and evidence

- 구체적 사례 하나: <누가, 언제, 무엇이 일어났는지, 실제 값과 함께>
- 지금의 대안: <오늘 대신 사람들이 하는 일>
- 근거 등급: observed | reported | assumed

## Target users and exclusions

- 사용자: <이 문서가 구체적으로 섬기는 사람>
- 제외 대상: <이 문서가 일부러 섬기지 않는 사람>

## Goals and metrics

| 목표 | 지표 | 목표치 | 측정 수단 | 측정 시점 |
|---|---|---|---|---|
| <목표> | <주 지표> | <숫자 + 단위> | <수치가 나오는 곳> | <측정 창> |
| <목표> | <보조 지표> | <숫자 + 단위> | <출처> | <측정 창> |
| <목표> | <대응 지표> | <하한 + 단위> | <출처> | <측정 창> |

## Scope

### P1 - <스토리 이름>

- 우선순위 이유: <왜 지금이고, 밀리면 무엇이 깨지는지>
- 독립 테스트: <뒤 스토리 없이 이 스토리만 어떻게 증명하는지>
- 요구사항: FR-001, FR-002

### P2 - <스토리 이름>

- 우선순위 이유: <...>
- 독립 테스트: <...>
- 요구사항: FR-003

### P3 - <스토리 이름>

- 우선순위 이유: <...>
- 독립 테스트: <...>
- 요구사항: FR-004

### 비목표

- <이 문서가 일부러 하지 않는 일과, 했다면 더해졌을 것>
- <범위의 다른 부분을 자르는 두 번째 항목>

### 바뀌면 안 되는 동작

- FR-010 WHEN <기존 조건>, the system SHALL CONTINUE TO <기존 동작>.

## Functional requirements

| Id | 우선순위 | 요구사항 | 검증 |
|---|---|---|---|
| FR-001 | P0 | <EARS 문장> | <검토자가 무엇을 하고 무엇을 보는지> |
| FR-002 | P1 | <EARS 문장> | <...> |

## Acceptance scenarios

### <스토리 이름>

```text
Scenario: <정상 경로 이름> (FR-001, FR-002)
Given <구체적인 시작 상태>
When <행동 하나>
Then <관측 가능한 결과>

Scenario: <실패 또는 경계 이름> (FR-002)
Given <구체적인 시작 상태>
When <행동 하나>
Then <관측 가능한 결과>
```

## Platform requirements

### web

<결정된 플랫폼과, 그 체크리스트가 정해야 할 의무. 체크리스트가 있으면 그 파일이 이 블록을 채운다.>

## Assumptions

- A-001: <진술>
  - 근거 등급: repo fact | convention default | guess
  - 근거: <경로, 인용, 또는 의지한 관례>
  - 틀렸을 때: <무엇이 바뀌는지>

## Open questions

- Q-001: <질문>
  - 답할 사람: <역할>
  - 막힘: yes | no
  - 이력: Q: <질문> → A: <답 또는 unanswered>

## Risks and dependencies

- 위험: <무엇이 실패할 수 있고, 이른 신호는 무엇인지>
- 의존성: <이 문서 밖에서 필요한 것>

## Change history

| 날짜 | 모드 | 바뀐 내용 |
|---|---|---|
| YYYY-MM-DD | create | 최초 문서 |

## Handoff

- 플랫폼: <결정된 플랫폼>
- 규모: <S | M | L>
- P1 범위: <먼저 출시하는 스토리와 요구사항>
- 남은 막힘 질문: <Q ID, 또는 "none">
- 다음 단계 입력: <다음 단계가 이 문서에서 읽는 것>
```

## Worked example

```markdown
# 집중 타이머 PRD

## Meta

- Status: draft
- Platforms: ios, android
- Size: S
- Updated: 2026-11-07

## Definition

고정된 세션을 시작하고 세션 중 설정 변경을 막는 단일 목적 집중 타이머다. 타이머 설정이 너무 많아 흐름을 놓치는 사람을 위한 것이다.

## Problem and evidence

- 구체적 사례 하나: 2026-10-28 지원 스레드에서 한 사용자가 25분 세션을 네 번 다시 시작했다. 설정 화면이 세션 중에 여섯 가지 길이 프리셋을 제공했기 때문이다.
- 지금의 대안: 일반 타이머 앱에 의도한 길이를 종이에 적어 두는 것.
- 근거 등급: reported

## Target users and exclusions

- 사용자: 하루에 짧은 집중 블록을 여러 번 도는 개인 지식 노동자
- 제외 대상: 공유 세션 대시보드가 필요한 팀, 간격 반복이나 뽀모도로 연쇄가 필요한 사람

## Goals and metrics

| 목표 | 지표 | 목표치 | 측정 수단 | 측정 시점 |
|---|---|---|---|---|
| 세션이 끝까지 진행된다 | 완료 세션 비율 | 시작한 세션의 70% 이상 | 세션 시작·종료 이벤트 | 출시 후 첫 14일 |
| 세션이 빠르게 시작된다 | 앱 열기부터 세션 시작까지의 중앙값 | 5초 이하 | 시작 시각 이벤트 쌍 | 출시 후 첫 14일 |
| 이 블록이 나머지 앱을 해치지 않는다 | 크래시 없는 세션 비율 | 99.5% 이상(대응 지표 하한) | 세션당 크래시 보고 | 출시 후 첫 30일 |

## Scope

### P1 - 세션 하나를 시작하고 끝낸다

- 우선순위 이유: 끝까지 가는 경로가 없으면 제품이 없고, 다른 무엇도 측정할 수 없다.
- 독립 테스트: 25분 세션을 시작하고 앱을 백그라운드로 보낸 뒤 25분 후 돌아와 완료 상태를 본다.
- 요구사항: FR-001, FR-002

### P2 - 중단 뒤 이어서 한다

- 우선순위 이유: 프로세스가 종료되는 것이 세션이 죽는 가장 흔한 경로다. 이어하기를 출시하면 쓸모 있는 세션이 두 배가 된다.
- 독립 테스트: 세션 중 강제 종료하고 다시 실행해 남은 시간이 복원되는지 본다.
- 요구사항: FR-003

### 비목표

- 프리셋 라이브러리와 길이 직접 작성: 같은 25분에 설정 표면과 두 번째 사고 모델을 더한다.
- 기기 간 세션 동기화: 단일 기기 사례에 필요 없는 계정과 서버 의존성을 더한다.

### 바뀌면 안 되는 동작

- FR-010 WHEN 세션 중 앱이 백그라운드에서 돌아오면, 시스템 SHALL CONTINUE TO 세션을 다시 시작하지 않고 남은 시간을 보여 준다.

## Functional requirements

| Id | 우선순위 | 요구사항 | 검증 |
|---|---|---|---|
| FR-001 | P0 | WHEN 사용자가 세션을 시작하면, 타이머 SHALL 고정 길이에서 카운트다운을 시작하고 남은 시간을 보여 준다. | 세션을 시작한다. 남은 시간이 1초마다 줄어든다. |
| FR-002 | P0 | IF 세션이 0에 닿으면, THEN 타이머 SHALL 완료 상태를 보여 주고 카운트를 멈춘다. | 1분짜리 시험 세션을 0까지 돌린다. 완료 상태가 나오고 카운트가 멈춘다. |
| FR-003 | P1 | WHEN 세션 중 프로세스가 종료되고 24시간 안에 다시 실행되면, 타이머 SHALL 남은 시간을 복원한다. [가정: 사용자는 하루 안에 돌아온다] | 남은 10분 시점에 프로세스를 종료하고 다시 실행해 10분이 보이는지 본다. |
| FR-004 | P1 | WHERE 기기가 무음 모드이면, 완료 상태 SHALL 소리 없이 나타나되 눈에 보이는 배너는 보여 준다. [확인 필요: 디자인 검토가 햅틱을 요구하는가?] | 무음 모드를 켜고 0까지 돌린다. 배너가 보이고 소리는 나지 않는다. |

## Acceptance scenarios

### 세션 하나를 시작하고 끝낸다

```text
Scenario: 세션이 끝까지 진행된다 (FR-001, FR-002)
Given 세션이 없는 새 설치 상태
When 사용자가 시작을 누르고 25분을 기다린다
Then 완료 상태가 보이고 남은 카운트다운이 없다

Scenario: 세션이 백그라운드 복귀를 견딘다 (FR-001, FR-010)
Given 10분 전에 시작한 세션
When 사용자가 앱을 2분 동안 백그라운드로 보냈다가 돌아온다
Then 남은 시간이 약 13분으로 보이고 세션은 계속 실행 중이다
```

### 중단 뒤 이어서 한다

```text
Scenario: 강제 종료 뒤 남은 시간이 복원된다 (FR-003)
Given 남은 시간 10분인 세션이 시작된 상태
When 사용자가 앱을 강제 종료하고 24시간 안에 다시 실행한다
Then 타이머가 복원된 남은 시간을 보이고 계속 센다

Scenario: 이어하기 창을 넘겨 실행하면 새 세션이 된다 (FR-003)
Given 25시간 전에 종료된 세션
When 사용자가 앱을 다시 실행한다
Then 복원되는 세션이 없고 시작 상태가 보인다
```

## Platform requirements

### ios

결정된 플랫폼이다. iOS 체크리스트는 빌드 단계 전에 앱 안 계정 처리, 프라이버시 신고, 심사용 데모 경로를 정해야 한다. 그 체크리스트가 생기기 전까지 이 항목은 열린 상태로 두고 여기서 지어내지 않는다.

### android

결정된 플랫폼이다. 안드로이드 체크리스트는 빌드 단계 전에 target API 수준 마감과 데이터 안전 신고를 정해야 한다. 그 체크리스트가 생기기 전까지 이 항목은 열린 상태로 둔다.

## Assumptions

- A-001: 사용자는 세션 중 설정 없이 고정 25분 길이를 받아들인다
  - 근거 등급: convention default
  - 근거: 인용한 지원 스레드가 프리셋 과다에 관한 것이다
  - 틀렸을 때: P1에 길이 선택이 더해지고 설정 비목표가 빠진다

## Open questions

- Q-001: 완료 시 디자인 검토가 햅틱을 요구하는가?
  - 답할 사람: design
  - 막힘: no
  - 이력: Q: 햅틱이 필요한가? → A: unanswered

## Risks and dependencies

- 위험: 백그라운드 실행 제한이 카운트다운을 멈출 수 있다. 이른 신호는 복귀 시 세션이 건너뛰는 현상이다.
- 의존성: 스토어 등록에는 제출 전 최종 길이 문구가 필요하다.

## Change history

| 날짜 | 모드 | 바뀐 내용 |
|---|---|---|
| 2026-11-07 | create | 최초 문서 |

## Handoff

- 플랫폼: ios, android
- 규모: S
- P1 범위: 시작하고 끝내는 스토리와 FR-001, FR-002
- 남은 막힘 질문: none
- 다음 단계 입력: 고정 길이, 완료 상태, 이어하기 창, 그리고 위의 플랫폼 의무 두 개
```

## Rules

- 골격의 절 이름을 그대로 복사한다. 검토자가 확인하는 이름이다.
- 사실, 가정, 표시로 채울 수 없는 자리표시자는 지운다. 빈 절은 템플릿 흔적이 아니라 결함이다.
- 범위를 바꾸는 `[가정: …]`은 `A-###` 항목으로 다시 나타난다. 범위를 막는 `[확인 필요: …]`은 `Blocking: yes`인 `Q-###`이 된다.
- 스토리마다 정상 경로 하나와 실패·경계 하나를 인수 시나리오에 쓴다. 스토리 둘이면 시나리오 네 개다.
- 문서 전체에서 `[확인 필요: …]`는 최대 3개다.
- 다음 단계 입력은 핸드오프 블록에서만 설명한다. 이 문서에는 태스크 목록, 설계, 흐름이 들어가지 않는다.

## Sources

> 확인 2026-11-07.

| Claim | Source |
|---|---|
| 정본 산출물 하나와 짧은 질문 예산 | [snarktank/ai-dev-tasks create-prd](https://raw.githubusercontent.com/snarktank/ai-dev-tasks/main/create-prd.md) - "Limit questions to 3-5 critical gaps in understanding." |
| N/A 대신 적용되지 않는 절을 지움 | [spec-kit specify](https://raw.githubusercontent.com/github/spec-kit/main/templates/commands/specify.md) - "When a section doesn't apply, remove it entirely (don't leave as 'N/A')." |
| 독립 테스트 가능한 스토리와 번호 요구사항 | [spec-kit spec-template](https://raw.githubusercontent.com/github/spec-kit/main/templates/spec-template.md) - "Each user story/journey must be INDEPENDENTLY TESTABLE" |
| WHEN/SHALL 요구사항 문장 | [Kiro feature specs](https://kiro.dev/docs/specs/feature-specs.md) - "WHEN [condition/event] THE SYSTEM SHALL [expected behavior]" |
| 상태형과 원치 않는 사건형 요구사항 | [EARS](https://alistairmavin.com/ears/) |
| 바뀌지 않는 동작의 `SHALL CONTINUE TO` | [Kiro bugfix specs](https://kiro.dev/docs/specs/bugfix-specs.md) - "WHEN [condition] THEN the system SHALL CONTINUE TO [existing behavior]" |
| 공백 지점의 문장 안 표시 | [deanpeters prd-development](https://github.com/deanpeters/Product-Manager-Skills) - "Tag inline where the gap appears, not just at the end." |
| 가정과 열린 질문을 본문 사실과 분리 | [phuryn create-prd](https://github.com/phuryn/pm-skills) - "Don't invent. What you don't know goes to 7.4 Assumptions and open questions, clearly marked, not into the body as fact." |
| 지표 집합의 대응 지표 | [TerminalSkills prd-writing](https://github.com/TerminalSkills/skills) - "Counter-metrics: [Metrics we don't want to hurt]" |
| 문서 끝의 핸드오프 블록 | [Citadel prd](https://github.com/SethGammon/Citadel) |
| 내부 구현 메커니즘을 이름으로 쓰지 않음 | [ai-conductor prd](https://github.com/jstoup111/ai-conductor) - "It MUST NOT name the new internal mechanism by which this feature is built." |

### 근거 등급

`LOCAL` - 절 순서와 예시는 이 패키지의 설계다. 문장 형식은 EARS와 Kiro 문서에서 인용했고, 표시와 가정 규칙은 인용한 지침을 각색했다.
