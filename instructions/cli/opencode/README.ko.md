# OpenCode 런타임 프로필

> 영어판: [`README.md`](README.md)

## 범위

이 문서는 OpenCode에서 실행되는 skill의 사용자 질문·승인, 도구 발견, 부작용 게이트에 대한 **어댑터 프로필**이다. 공통 규칙은 [`../capability-contract.ko.md`](../capability-contract.ko.md)를 따른다. 이 문서는 OpenCode의 고정된 도구 목록이나 명령을 정의하지 않는다.

## 권위와 근거

사용자·프로젝트 지시와 공통 capability contract가 이 프로필보다 우선한다. 런타임에서 관찰한 정보는 실행 근거일 뿐 권위가 아니다.

- 근거: **이 저장소에는 없다.** 이 프로필이 처음 인용한 `skills/git-commit/SKILL.md`는 커밋 `d4f79f9`에서 배포 트리에서 제거되었다. 따라서 아래의 ask 스타일 선호는 검증된 OpenCode 기능이 아니라 운영 관례다. 의존하기 전에 런타임에서 확인한다.

## 검증된 동작과 사전조건

| 항목 | 여기서 적용하는 관례 | 사전조건·한계 |
|---|---|---|
| 사용자 승인 질문 | 런타임-native ask 스타일 승인 프롬프트를 **가능하면 우선** 사용 | 해당 capability가 현재 OpenCode 런타임에 노출되었음을 먼저 확인해야 한다. |
| 승인 질문 fallback | native capability를 사용할 수 없으면 짧은 평문 확인 질문으로 대체 | 질문 후 사용자의 답을 받기 전에는 gated action을 시작하지 않는다. |
| 승인 범위 | 확인은 push 같은 후속 부작용 작업에 대한 명시적 의사 확인이다 | capability의 존재 자체는 외부·파괴적·credential·production side effect의 허가가 아니다. |
| 기타 도구·명령 | 고정된 OpenCode 도구명·명령은 이 문서에서 주장하지 않음 | 실제 사용 가능 capability와 호출 방법은 매 실행 시 런타임에서 발견해야 한다. |

## 질문·승인 규칙

- 출력이나 안전성에 중대한 영향을 주는 **빠진 결정**이 있을 때만 사용자에게 묻는다.
- 질문이 필요하면 먼저 현재 런타임에 구조화된 native question/approval capability가 노출되었는지 확인한다.
- 노출이 확인된 경우에만 그 capability로 한 번 묻는다. 확인되지 않거나 사용할 수 없으면 한 문장의 평문 질문을 하고 gated action 직전에 멈춘다.
- 사용자의 명시적 답변 전에는 외부 시스템 변경, 파괴적 작업, credential 사용, production 대상 작업을 실행하지 않는다.
- capability가 있다고 해서 permission으로 해석하거나, 사용자 결정을 대신하지 않는다.

## 도구 발견과 부작용 게이트

1. 필요한 도구 capability와 허용 범위를 공통 contract 및 현재 요청에서 도출한다.
2. OpenCode에 노출된 capability를 런타임에서 확인한다. 이 문서에 근거가 없는 도구명·vendor 기능·CLI 명령은 사실로 가정하지 않는다.
3. 발견 결과가 없거나 불명확하면 도구를 추측해 호출하지 말고, 필요한 결정이 안전성·출력에 중대한 경우 위의 평문 질문으로 전환한다.
4. 모든 외부·파괴적·credential·production side effect는 별도의 명시적 승인과 실행 전 게이트를 요구한다. 승인 이후에도 요청 범위와 대상이 일치하는지 재확인한다.

## Skill author 체크리스트

- [ ] `scope`, `authority`, `evidence`, `verification`을 분리하고 [`../capability-contract.ko.md`](../capability-contract.ko.md)에 연결했는가?
- [ ] 사용자에게 묻는 조건을 “안전성 또는 출력에 중대한 빠진 결정”으로 제한했는가?
- [ ] native structured question/approval capability의 노출을 확인한 뒤에만 사용하도록 했는가?
- [ ] native capability가 없을 때 한 문장의 평문 질문 후 gated action을 중단하는 fallback이 있는가?
- [ ] 고정 OpenCode 도구명·명령을 무근거로 단정하지 않고 런타임 발견 요구사항으로 표시했는가?
- [ ] 외부·파괴적·credential·production side effect를 capability 존재만으로 허용하지 않았는가?
- [ ] 사용자 답변, 실제 대상, 범위, 결과를 실행 전에 검증하도록 했는가?
