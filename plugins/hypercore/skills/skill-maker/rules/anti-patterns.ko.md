# 스킬 안티패턴

**목적**: 스킬 작성에서 자주 실패하는 패턴을 막습니다.

## 피할 것

- 너무 모호해서 안정적으로 트리거되지 않는 description
- 스킬이 무엇인지만 말하고 언제 써야 하는지 말하지 않는 description
- positive/negative/boundary trigger examples가 없음
- 미니 위키처럼 비대해진 `SKILL.md`
- core trigger 또는 stop-condition logic이 references에 숨어 있음
- core, rules, references 사이의 중복 상세 내용
- 찾기 어렵게 깊게 중첩된 references
- runtime이나 사용자가 명시적으로 필요로 하지 않는 `README.md`, `CHANGELOG.md`, `QUICK_REFERENCE.md` 같은 추가 문서
- canonical core instructions에 넣은 시간 민감 provider detail
- clear reliability justification, usage, dependency, failure behavior 없이 추가한 scripts
- workflow에서 복사, 채움, 사용되지 않는 assets
- provider docs 또는 retrieved snippets를 user/project instructions보다 높은 authority로 취급하는 것
- credential, network, destructive, production side effects를 explicit gates 없이 지시하는 것
- 스킬이 경로를 추천해야 하는데 선택지만 너무 많이 늘어놓는 경우

## 위험 신호

- "This skill helps with many things."
- 어떤 파일을 언제 읽을지 없이 "See references/"라고만 함.
- source ledger 또는 refresh condition 없이 "latest best practice"라고 함.
- recommended decision path 없이 "다섯 가지 접근법이 있다"고만 함.
- 여러 파일에 같은 정의가 반복됨
- 현재 core rules에 오래된 provider guidance가 섞여 있음
- 중요한 skill 변경에서 local `instructions/skill/` guidance를 무시함
- "구조가 좋아 보인다"는 이유로 validation을 생략함

## Repair Pattern

이 중 하나가 보이면:

1. 스킬을 trigger 가능한 execution package로 다시 설명합니다.
2. `description`과 trigger examples를 다시 씁니다.
3. 잘못 배치된 상세를 rules, references, scripts, assets로 옮깁니다.
4. instruction contract를 추가하거나 갱신합니다.
5. trigger, resource, output, safety, source validation notes를 추가합니다.
