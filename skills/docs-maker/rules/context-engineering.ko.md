# Docs Maker용 Context Engineering 가이드

**목적**: 문서를 AI가 빠르게 파싱하고 안정적으로 회수/실행할 수 있는 고밀도 컨텍스트로 변환합니다.

## 1. 핵심 원칙

### 1.1 Right Altitude

원칙 + 패턴 + 예시 조합을 사용합니다. 양극단을 피합니다.

- Too Low: 조건문/엣지케이스를 과도하게 나열
- Too High: 실행 기준 없는 추상 문장

권장 구조:

1. 한 줄 규칙
2. 한 줄 이유
3. 복사 가능한 패턴

### 1.2 Context는 유한 자원

토큰을 제한 자원으로 취급합니다.

- 메인 문서는 간결하고 실행 중심으로 유지
- 상세 내용은 `rules/`, `references/`로 분리
- 필요한 시점에만 로드(Just-in-Time)

### 1.3 Explicit > Implicit

AI 모델은 지시를 더 문자 그대로, 최소 범위로 수행하는 경향이 있습니다.

- 나쁨: "적절히 개선"
- 좋음: "A/B/C를 적용해 개선하고 X/Y로 검증"

## 2. 프롬프트/문서 구조 패턴

## 2.1 XML 구획 구조

검색 안정성을 위해 섹션 키를 고정합니다.

- `<purpose>`
- `<trigger_conditions>`
- `<workflow>`
- `<forbidden>`
- `<required>`
- `<validation>`

## 2.2 행동 제어 블록

필요한 경우에만 명시적으로 사용합니다.

```xml
<default_to_action>바로 구현</default_to_action>
<do_not_act_before_instructions>승인 전 제안만</do_not_act_before_instructions>
<use_parallel_tool_calls>true</use_parallel_tool_calls>
<avoid_minimal_implementation>완결형 구현</avoid_minimal_implementation>
<verify_implementation>요구사항/테스트/타입/품질 게이트 검증</verify_implementation>
```

## 2.3 긍정형 지시

금지문 나열보다 `Do X` 형태의 실행 지시를 우선합니다.

- 나쁨: "A 하지마, B 하지마..."
- 좋음: "Y 패턴으로 X 수행, Z로 검증"

## 3. 추론 전략 선택

| 복잡도 | 추론 모드 | 기준 |
|------|------|------|
| 낮음 | 직접 실행 | 별도 추론 블록 생략 |
| 중간 | 구조화 CoT | 짧은 단계형 사고 |
| 높음 | 확장 추론 | 다중 옵션 비교 후 결정 |

docs-maker 적용:

- create/refactor 주요 작업 전 `sequential-thinking` 필수
- 가정 변경 시 revision/branching 사용

## 4. 압축/회수 전략

## 4.1 압축 규칙

- 장문 설명을 표로 변환
- 추상 설명을 실행 예시로 변환
- 반복 규칙은 단일 기준 섹션으로 통합
- 같은 개념은 용어 하나로 고정(검색 분산 방지)

## 4.2 Progressive Disclosure

3계층 로딩 모델:

1. Metadata: 트리거 요약
2. SKILL 본문: 워크플로우/제약
3. Rules/References: 필요 시 상세 로드

## 4.3 Minimal-Start 반복

최소 유효 지시로 시작하고, 품질이 부족하면 다음 순서로 확장합니다.

1. 구체 예시 1개 추가
2. 제약 1개 추가
3. 검증 게이트 1개 추가

## 5. AI 작성 규칙

- 문자 그대로 해석됨을 전제로 작성
- 완결 조건을 명시적으로 작성
- 행동 자세(즉시 실행/제안 우선)를 명시
- 독립 작업은 병렬 의도를 명시

완결 기준 문구 패턴:

"필수 상태, 에러 처리, 엣지 케이스, 검증 결과를 모두 포함한다."

## 6. 실전 템플릿

## 6.1 규칙 진술 템플릿

```markdown
Rule: [실행 가능한 단일 지시]
Why: [한 줄 이유]
Pattern:
[복사 가능한 스니펫]
Validation:
- [관측 가능한 점검 항목]
```

## 6.2 워크플로우 단계 템플릿

```markdown
Phase N
- Goal:
- Inputs:
- Actions:
- Output:
- Exit criteria:
```

## 7. 제거해야 할 안티패턴

- 기준 없는 모호어("적절히", "필요시")
- 메인 문서의 과도한 조건 분기
- 섹션 간 중복 지시
- 검증 누락/후순위 처리
- 객관적 체크 없이 완료 선언

## 8. 문서 품질 게이트

아래 항목이 모두 통과될 때만 완료 처리합니다.

- 스캔 가능한 섹션 구조
- 명시적이고 테스트 가능한 지시
- 재사용 가능한 예시
- 관측 가능한 검증 기준
- 중복/모호성 제거

