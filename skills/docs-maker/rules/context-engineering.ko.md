# Docs Maker용 Context Engineering 가이드

**목적**: 문서를 AI 시스템이 안정적으로 파싱, 검색, 실행할 수 있는 고밀도 저노이즈 컨텍스트로 바꿉니다.

## 0. Core Contract

Instruction 성격의 문서는 실행에 영향을 주는 경우 아래 경계를 명시합니다.

| 섹션 | 반드시 적을 것 | 피할 것 |
|---|---|---|
| Intent | 사용자가 성공으로 보는 결과 | persona만 있는 역할놀이 |
| Scope | 읽기/수정/생성 가능한 대상 | "관련된 것 전부" 같은 무제한 범위 |
| Authority | 지시 우선순위와 충돌 처리 | user/project/tool 규칙을 조용히 섞기 |
| Evidence | 신뢰할 evidence channel과 source grade | snippet이나 tool output을 1차 출처처럼 취급 |
| Tools | 도구 사용, 중단, 위임 기준 | 존재하지 않는 도구 상상 또는 runtime profile 없는 하드코딩 |
| Output | 산출물 형태, 경로, 완료 기준 | "정리" 같은 모호한 종료 |
| Verification | 완료를 증명할 test, eval, review, source check | evidence 없는 완료 선언 |

XML tag, Markdown heading, table 모두 가능하지만 필수는 특정 문법이 아니라 경계 분리입니다.

## 0.1 Instruction Layers

규칙마다 하나의 source of truth를 유지합니다.

| Layer | 예시 | 역할 |
|---|---|---|
| Project root | `AGENTS.md`, `CLAUDE.md`, repo-wide instructions | 짧은 불변 규칙과 loading map |
| Instructions base | `instructions/**` | 공통 방법론, sourcing, validation |
| Runtime rules | Cursor rules, Codex config, Claude memory | runtime quirk와 path scope |
| Skill/command | `skills/**/SKILL.md`, slash command | 좁고 실행 가능한 workflow |
| Task prompt | 현재 사용자 요청 | 최신 구체 override |

Root 문서는 짧게 유지하고 깊은 내용은 필요할 때 references에서 로드합니다.

## 1. 핵심 원칙

### 1.1 적절한 고도

원칙 + 패턴 + 예시 구조를 사용합니다. 양 극단을 피합니다.

- 너무 낮음: 메인 문서에 조건 분기와 엣지 케이스를 과도하게 늘어놓음
- 너무 높음: 실행 기준 없는 추상 문장만 남음

권장 구조:

1. 한 줄 규칙
2. 한 줄 이유
3. 복사 가능한 패턴
4. 관측 가능한 검증 항목

### 1.2 Context는 유한 자원

토큰을 제한 자원으로 취급합니다.

- 핵심 파일은 간결하고 실행 중심으로 유지합니다.
- 깊은 상세 내용은 `rules/` 또는 `references/`로 이동합니다.
- 필요한 순간에만 세부 내용을 로드합니다.
- 영구 가이드와 실행 중 상태, 임시 메모를 구분합니다.

### 1.3 Explicit > Implicit

AI 시스템은 지시를 문자 그대로 최소 범위로 수행하는 경향이 있습니다.

- 나쁨: "적절히 개선"
- 좋음: "A, B, C를 적용해 개선하고 X, Y로 검증"

### 1.4 안정적인 코어, 변동적인 주변부

코어 규칙은 vendor 업데이트에도 버틸 수 있도록 안정적으로 유지합니다.

- provider-neutral 원칙은 canonical 문서에 둡니다.
- provider 민감한 동작은 날짜가 붙은 reference 파일에 둡니다.
- 배포 전용 설정은 정말 필수일 때만 core 가이드에 둡니다.

## 2. 프롬프트와 문서 구조 패턴

### 2.1 구조화된 섹션

검색 안정성을 위해 일관된 섹션 구조를 사용합니다.

- `<purpose>`
- `<trigger_conditions>`
- `<workflow>`
- `<required>`
- `<forbidden>`
- `<validation>`

Markdown 헤더와 표도 읽기성과 경계를 더 잘 살려준다면 충분히 유효합니다.

### 2.2 행동 제어 블록

실행 자세를 실제로 바꿀 때만 행동 블록을 씁니다.

```xml
<default_to_action>다음 단계가 명확하고 되돌릴 수 있으면 바로 실행한다.</default_to_action>
<do_not_act_before_instructions>사용자 의도가 모호하면 먼저 조사하고 제안한다.</do_not_act_before_instructions>
<use_parallel_tool_calls>true</use_parallel_tool_calls>
<verify_outputs>규칙, 예시, references, validation gate를 점검한 뒤 완료 처리한다.</verify_outputs>
```

### 2.3 긍정형 지시

가능하면 금지문을 연속으로 적기보다 "Do X" 형태의 실행 지시를 우선합니다.

- 나쁨: "A 하지 마라, B 하지 마라..."
- 더 좋음: "Y 패턴으로 X를 수행하고 Z로 검증한다."

### 2.4 고정 모델명 대신 성능 프로필

canonical 문서에서는 다음 방식을 선호합니다.

- `frontier reasoning model`
- `fast general model`
- `snapshot-pinned production model`

고정된 모델명은 날짜가 붙은 provider reference나 배포 예시에만 둡니다.

## 3. 압축과 검색 전략

### 3.1 압축 규칙

- 반복적인 장문은 표로 바꿉니다.
- 추상 설명은 실행 패턴으로 바꿉니다.
- 반복 규칙은 하나의 canonical 섹션으로 합칩니다.
- 같은 개념은 하나의 용어로 고정해 검색이 분산되지 않게 합니다.

### 3.2 점진적 공개

3단계 로딩 모델:

1. 메타데이터: 트리거 수준 요약
2. Skill 본문: 워크플로우와 제약
3. Rules/References: 필요할 때만 불러오는 상세 내용

### 3.3 최소 시작 반복

최소 유효 지시로 시작하고, 품질이 부족하면 다음 순서로 확장합니다.

1. 구체적인 예시 1개
2. 명시적인 제약 1개
3. 검증 게이트 1개
4. reference 기반 예외 1개

## 4. 상태와 컨텍스트 경계

- canonical 규칙과 task state, 진행 메모, 임시 스크래치 컨텍스트를 구분합니다.
- 장기 실행 하네스를 문서화할 때는 무엇이 유지되고, 무엇이 압축되며, 무엇을 버려도 되는지 명시합니다.
- 긴 컨텍스트 시스템에서는 고정 지시, 참고 자료, 변수 입력의 배치 순서를 적어둡니다.

## 5. 드리프트 방지 유지보수

- provider 민감한 reference 항목에는 검증 날짜를 넣습니다.
- migration 가이드, tool 동작 노트, model profile 정책이 바뀌면 reference를 갱신합니다.
- 여러 core 파일을 조용히 패치하기보다 reference 항목 하나를 먼저 갱신하는 편을 우선합니다.

## 6. 실전 템플릿

### 6.1 규칙 진술 템플릿

```markdown
Rule: [실행 가능한 단일 지시]
Why: [한 줄 이유]
Pattern:
[복사 가능한 스니펫]
Validation:
- [관측 가능한 검증 항목]
```

### 6.2 워크플로우 단계 템플릿

```markdown
Phase N
- Goal:
- Inputs:
- Actions:
- Output:
- Exit criteria:
```

### 6.3 참조 항목 템플릿

```markdown
## [출처 또는 주제]
- source_url:
- last_verified_at:
- applies_to:
- summary:
- implication_for_docs_maker:
```

## 7. 제거해야 할 안티패턴

- 기준 없는 모호 표현
- 메인 문서의 과도한 조건 분기
- 섹션 간 중복 지시
- 검증 생략 또는 후순위 처리
- canonical core 규칙 안의 고정 모델명
- 날짜가 없는 provider 민감한 주장

## 8. 문서 품질 게이트

아래 조건이 모두 통과될 때만 완료 처리합니다.

- 스캔 가능한 섹션 구조
- 명시적이고 테스트 가능한 지시
- 재사용 가능한 예시
- 관측 가능한 검증 기준
- 중복과 모호성 제거
- provider 민감한 지시의 출처 분리 및 근거 확보
