# Verification Rules

7단계(Independent Verify). 샘플 수가 허용하는 깊이로 적용하는 3개 레이어와, 8단계의 Deliver 규칙.

## Layer 1: Profile lint — 항상 실행

스펙 문서 자체의 기계적 검사:

- [ ] meta 필드 7개가 모두 채워져 있다(profile_mode, source_scope, sample_count, observed_contexts, valid_at, unsupported_contexts, 규칙 충돌 우선순위).
- [ ] Meta 밖의 모든 규칙이 강도를 정확히 하나씩 갖는다(MUST / PREFER / AVOID).
- [ ] 수치는 band로 쓰였고 지어낸 백분율이 아니다.
- [ ] Known Limits 섹션이 존재하고 비어 있지 않다.
- [ ] observed_contexts가 2개 이상이면 맥락 변주 섹션이 있거나, 일반화 공백이 Known Limits에 기록돼 있다.
- [ ] 소비자 writer 기본값을 재진술하는 규칙이 없다(`rules/spec-schema.md`의 divergence-only 판정).

lint 실패는 Draft으로 돌아간다. 이 레이어는 형식만 채운 스펙을 통과시키지 않는다 — 구조가 완전한 스펙을 통과시킨다.

## Layer 2: Holdout feature check — holdout이 있을 때 실행

Intake에서 분리한 holdout이 필요하다(`rules/sample-quality.md`). holdout은 분석과 Draft에서 읽지 않았어야 한다.

1. 스펙이 주장하는 것과 같은 feature를 holdout 샘플에서 측정한다: 종결 분포, 기호 패턴, 문장 길이, 어휘 항목, 구조 습관.
2. 각 측정을 스펙의 주장과 강도와 대조한다.
3. holdout이 MUST를 반박하거나, "주력"이라는 주장 패턴의 부재를 보이면 그 주장은 실패다.

1차 판정은 결정론적 feature delta다 — 계수한 종결과 기호를 주장한 band와 비교한다. 실패한 곳은 스펙을 고치고 재검사한다. holdout을 버텨내려고 주장을 넓히지 않는다; 좁히거나 맥락별로 분리한다.

## Layer 3: Consumer reproducibility — 검증이 가능할 때 실행

스펙 하나로 말투가 재현되는지 확인한다:

1. 소비자 패스가 스펙만 따라(컨텍스트에 샘플 없이) 중립 내용의 짧은 문단을 생성한다.
2. 평가자가 생성 문단을 holdout의 feature target과 비교한다. 평가자는 스펙과 샘플을 보지 않는다.
3. 1차 판정은 다시 결정론적 feature delta다: 생성 문단이 스펙의 종결·기호·구조 주장에 맞는가.

LLM judge는 secondary blind 검사로 쓸 수 있다(어떤 규칙을 따랐는지 모르는 채 그 말투 "같은지" 판정). 하지만 same-model 자유 자기평가 — 스펙을 만든 모델이 자기 출력을 분위기로 채점하는 것 — 는 금지다. 하네스가 모델 하나와 blind 채널 없이 제공하면, reproducibility가 독립적으로 검증 불가능했음을 기록하고 Known Limits에 넣는다.

## Degradation policy

검증 깊이는 야망이 아니라 증거의 함수다:

| 상황 | 실행 레이어 | 필수 기록 |
|---|---|---|
| extracted/hybrid, sample_count >= 3, holdout 존재 | 1 + 2 + 3(소비자/blind 채널이 있으면) | 전체 결과; layer-3 공백은 메모. |
| extracted/hybrid, sample_count >= 3, holdout 없음(분리하지 않았음) | 1만, 그리고 intake 규율 수정 | Known Limits: "holdout verification unavailable". |
| 저표본 extracted(1~2개) | 1만 | Known Limits: "holdout verification unavailable"; 스펙과 요약 어디에도 fidelity·reproducibility 주장 금지. |
| preset_approximation(샘플 없음) | 1만 — 프리셋 인스턴스의 schema adherence | holdout fidelity 검증을 아예 수행하지 않는다; "preset fidelity 검증됨" 표현 금지. 프리셋이 근사치라고 명시한다. |
| hybrid | 1 + 2를 샘플 기반 주장에 적용; 프리셋 기반 주장은 approximation 라벨 유지 | 프리셋 부분은 절대 fidelity를 주장하지 않는다. |

레이어 없는 fidelity 주장이 바로 이 파일이 막으려는 순환 그 자체다.

## Deliver 규칙 (8단계)

- 분석 스캐폴딩을 제거한다: 증거 인용, 축별 작업 노트, 신뢰도 코멘터리, 이 패키지의 rule ID. 스펙은 규칙을 진술하지 탐정 과정을 보여주지 않는다.
- Provenance meta 블록은 온전히 유지한다 — 그것은 스캐폴딩이 아니라 스펙의 정직함이다.
- Self-contained 확인: 이 스킬 패키지, 이 저장소, 외부 파일에 접근 없이 문서를 읽고 쓸 수 있어야 한다. 소비자 AI에게 필요한 것은 스펙 하나뿐이다.
- `tone-profile-<name>.md`로 저장하고, 사용자 환경이 기대하는 위치에 저장했으면 요약에 그 위치를 명시한다.
- 사용자에게 남기는 요약: 무엇을 담았는지, profile_mode, 어떤 검증이 실행됐는지, Known Limits가 무엇을 말하는지 — 과정 덤프가 아니라 2~4줄로.

## Sources

> 외부 출처를 사용하지 않았다. 내용 확인 2026-09-21.

이 규칙 파일은 이 패키지 자체의 규칙을 진술하며 외부 주장을 하지 않으므로, 외부 출처를 인용하지 않는다.
