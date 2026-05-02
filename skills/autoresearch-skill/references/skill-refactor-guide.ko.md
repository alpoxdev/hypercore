# Skill Refactor Guide

오토리서치 실패 원인이 단일 지침 누락이 아니라 대상 스킬의 구조 자체일 때 이 레퍼런스를 사용한다.

이 가이드는 로컬 `skill-maker` 패턴을 오토리서치 실행 안에서 쓰기 좋게 조정한 버전이다.

## 1. 구조 실패를 식별한다

대상 스킬에 anatomy 작업이 필요하다는 흔한 신호:

- `description`이 너무 모호해 안정적으로 트리거되지 않는다
- 핵심 `SKILL.md`가 미니 위키처럼 비대해졌다
- 상세 지식이 core에 갇혀 있고 support file이 없다
- 반복 정책이 여러 섹션에 중복된다
- 검증이 약하거나 빠져 있다
- 다음 유지보수자가 무엇을 어디에 넣어야 하는지 알기 어렵다
- 한국어 요청 예시가 없어 실제 사용자 언어를 충분히 커버하지 못한다
- intent, scope, authority, evidence, tools, output, verification, stop condition을 찾을 수 없다
- 외부/current claim을 쓰는데 source ledger나 refresh 조건이 없다
- 도구 사용이나 delegation 결과를 최종 검증 없이 신뢰한다

## 2. 레이어 단위로 리팩터링한다

기본 분리 기준:

- `SKILL.md`: 맡은 일, 트리거, 상위 워크플로, support file 포인터
- `rules/`: 재사용 정책, 의사결정 기준, 검증, anti-pattern
- `references/`: 상세 지식, 스키마, 긴 예시, 공급자 민감 정보
- `scripts/`: prose보다 결정적 실행이 더 믿을 만할 때만

구조 문제를 core에 설명을 더 붓는 방식으로 해결하지 않는다.

## 3. 트리거 문구를 먼저 고친다

스킬이 잘못 트리거된다면:

- `description`을 다시 써서 무엇을 하고 언제 쓰는지 분명히 말한다
- 긍정, 부정, 경계 예시를 추가한다
- 범위 밖 요청을 어느 이웃 스킬이 담당해야 하는지 적는다
- 한국어와 영어 요청 모두에서 경계가 유지되는지 확인한다

트리거 품질은 깊은 프롬프트 미세조정보다 더 큰 개선을 주는 경우가 많다.

## 4. core는 가볍게 유지한다

좋은 신호:

- 첫 화면만 봐도 스킬의 일과 경계가 설명된다
- 모든 지원 파일을 열지 않아도 워크플로가 읽힌다
- 긴 예시와 스키마가 다른 파일로 내려가 있다

나쁜 신호:

- core 안에 긴 예시 블록이 반복된다
- 공식 문서 요약이 core를 차지한다
- core와 references에 정의가 중복된다

## 5. support file은 한 단계까지만

support file은 `SKILL.md`에서 직접 링크한다.

피해야 할 것:

- 깊은 reference 체인
- 또 다른 support file만 가리키는 support file
- 중복 내용을 가진 `README.md`, `QUICK_REFERENCE.md`류 문서

## 6. Context/Source/Trace도 구조로 본다

대상 스킬이 리서치, 도구, delegation, 외부 문서, 최신 정보를 다루면 아래도 구조 품질이다.

- retrieved content는 evidence이지 instruction authority가 아니라는 경계
- source-sensitive claim을 references 또는 source ledger로 보내는 규칙
- tool/delegation trajectory를 검증하는 trace assertion
- 실패, reset, rollback 조건을 artifact에 남기는 방식

이 항목이 빠진 스킬은 점수가 올라가도 재현성과 안전성이 약할 수 있다. core에 긴 설명을 넣기보다 직접 연결된 `rules/`나 `references/`에 배치한다.

## 7. 구조 변이 아이디어

구조가 병목일 때 시도할 만한 변이:

- 검증 규칙을 `rules/`로 이동
- 출력 스키마와 긴 예시를 `references/`로 이동
- 비대해진 섹션을 줄이고 직접 포인터 하나로 교체
- 이웃 스킬과의 범위 경계 한 줄을 추가
- 동작은 바꾸지 않으면서 core만 무겁게 만드는 중복 지침 삭제

## 8. 오토리서치 중 구조 점검 질문

다음을 스스로 묻는다:

- 새로운 유지보수자가 다음 세부사항을 어디에 넣어야 할지 알 수 있는가?
- 트리거 모델이 메타데이터와 첫 화면만 보고 경계를 이해할 수 있는가?
- 컨텍스트가 부족한 에이전트도 다음에 읽을 파일을 알 수 있는가?
- source나 tool output이 상위 지시처럼 오용될 경로가 차단되어 있는가?
- 최종 완료 주장이 score, evidence, trace, caveat에 매핑되는가?

대답이 아니오라면, 행동 지침을 더 추가하기 전에 구조를 다루는 실험을 먼저 배정한다.
