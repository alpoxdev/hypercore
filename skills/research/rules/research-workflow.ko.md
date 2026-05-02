# Research Workflow

실제로 조사 작업을 수행할 때 이 규칙 파일을 사용합니다.

## 1. 요청 확정

- 사용자가 주제를 주지 않았다면 즉시 질문합니다.
- `--quick` 또는 `--deep`이 명시된 경우에만 그 깊이를 사용하고, 아니면 기본적으로 standard 모드를 사용합니다.
- `latest`, `current`, `today`, `this year`, `recent`, `최신` 같은 표현이 있으면 최신성 민감 요청으로 표시합니다.

## 2. 과한 계획 대신 적정 계획

다음 중 하나라도 참이면 sequential thinking을 사용합니다.

- 요청이 넓거나 모호함
- 요청이 고위험임
- 사용자가 `--deep`을 요구함
- 단순 사실 나열이 아니라 권고안까지 필요함

빠르고 좁은 요청은 짧은 계획이면 충분합니다.

- 주제
- 범위
- 예상 채널
- 종료 조건

## 3. 채널 우선순위 선택

1차 근거가 가장 있을 법한 채널부터 시작합니다.

- 내부 프로젝트 질문 -> 로컬 저장소 검색 우선
- 라이브러리/패키지 질문 -> 공식 문서 우선, 필요하면 GitHub나 웹 소스 추가
- 저장소/제품/릴리스 이력 질문 -> GitHub 근거 우선
- 시장/트렌드/뉴스 질문 -> 라이브 웹 소스 우선
- 학술/개념 질문 -> 원문 논문이나 공식 레퍼런스 우선

어떤 채널이 없으면, 없는 역할이나 도구를 꾸며내지 말고 가능한 다음 경로로 짧게 폴백합니다.

## 4. 계획 후에만 병렬화

기본, deep, broad, comparative, 또는 명시적 parallel research에서는 query plan이 생긴 뒤 `rules/parallel-research.ko.md`를 읽습니다.

- `--quick` 또는 좁은 one-channel research는 병렬화하지 않습니다.
- 독립 question, option, source channel 기준으로 lane을 나눕니다.
- 각 lane에 source floor, query angle, output schema, stop condition을 배정합니다.
- synthesis, conflict resolution, final recommendation은 lead agent가 소유합니다.

## 5. 근거 수집

- 모든 검색 쿼리는 서로 다른 각도로 유지합니다.
- 중복 방지, source-quality, 종료 조건은 이 스킬의 workflow, parallel-research, validation 파일에 있는 로컬 규칙을 따릅니다.
- 해설성 글보다 1차/공식 출처를 먼저 봅니다.
- 최신성 민감 주장은 정확한 발행일 또는 갱신일을 기록합니다.
- 출처가 서로 충돌하면 그 충돌을 명시하고 가능하면 해소합니다.

## 6. 리포트 저장

다음 위치에 저장합니다.

`.hypercore/research/[NN].slug.md`

파일명 규칙:

- `NN`은 `.hypercore/research/`의 다음 0채움 순번
- `slug`는 주제를 짧게 요약한 ASCII 문자열
- 읽기 쉽고 안정적인 이름 유지

## 7. 사용자 마감 응답

최종 메시지에는 다음을 포함합니다.

- 핵심 결론
- 저장한 리포트 경로
- 확신이 낮을 때는 근거 품질 또는 주요 한계
