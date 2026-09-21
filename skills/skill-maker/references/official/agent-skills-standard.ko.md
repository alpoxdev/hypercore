# Skill-Maker를 위한 Agent Skills 표준 참조

## Contents

- 갱신 정책
- Agent Skills 명세
- 스킬 제작자를 위한 모범 사례
- 스킬 출력 품질 평가
- 스킬 설명 최적화
- 스킬에서 스크립트 사용
- Sources

검토한 모든 런타임이 그 위에 세워진 공개 표준입니다. 이 스냅샷은 frontmatter 제약과 점진적 공개
예산에 대한 `PRIMARY` 출처입니다. 각 벤더가 그 위에 무엇을 더하는지는 옆의 제공자 스냅샷에 적습니다.

## 갱신 정책

- last_verified_at: 2026-09-20
- refresh_when:
  - 명세가 frontmatter 제약(name, description, compatibility, allowed-tools)을 바꿀 때
  - 점진적 공개 예산(목록 단계, 지침 단계, 줄 수 한도)이 바뀔 때
  - 참조 검증기(`skills-ref`)가 검사 항목을 바꿀 때
  - 스크립트 작성 문서가 실질적으로 바뀔 때
- supports_rules:
  - `rules/skill-anatomy.md`
  - `rules/trigger-design.md`
  - `rules/progressive-disclosure.md`
  - `rules/resource-placement.md`
  - `rules/validation-and-iteration.md`

## Agent Skills 명세

- source_url: https://agentskills.io/specification
- last_verified_at: 2026-09-20
- applies_to: frontmatter 필드와 그 제약, 디렉터리 관례, 점진적 공개, 파일 참조 깊이, 참조 검증기
- summary: 스킬은 최소한 `SKILL.md`를 담은 디렉터리이며, YAML frontmatter 뒤에 Markdown 본문이
  옵니다. `name`과 `description`은 필수이고 `license`, `compatibility`, `metadata`,
  `allowed-tools`는 선택입니다. 본문에는 형식 제한이 없습니다. `scripts/`, `references/`,
  `assets/`는 필수가 아니라 선택 관례입니다.
- implication_for_skill_maker: 아래 제약 집합을 명세가 말한 그대로 강제하고, 선택 디렉터리는
  명세의 요구가 아니라 이 저장소가 고른 관례로 다룹니다.

### 출처가 말하는 frontmatter 제약

| 필드 | 필수 | 제약 |
|---|---|---|
| `name` | 예 | 1-64자. 소문자, 숫자, 하이픈만. 하이픈으로 시작하거나 끝날 수 없습니다. 연속 하이픈을 담을 수 없습니다. **부모 디렉터리 이름과 일치해야 합니다** |
| `description` | 예 | 1-1024자. 비어 있을 수 없습니다. 스킬이 무엇을 하는지와 언제 쓰는지를 모두 적고, 에이전트가 대조할 핵심어를 담아야 합니다 |
| `license` | 아니오 | 라이선스 이름 또는 함께 넣은 라이선스 파일 참조. 짧게 유지합니다 |
| `compatibility` | 아니오 | **제공한다면 1-500자.** 의도한 제품, 시스템 패키지, 네트워크 접근 같은 환경 요구가 있을 때만 씁니다 |
| `metadata` | 아니오 | 문자열 키에서 문자열 값으로 가는 맵. 충돌을 피하려면 키를 고유하게 유지합니다 |
| `allowed-tools` | 아니오 | 사전 승인된 도구의 공백 구분 문자열. **실험적**이며 구현마다 지원이 다릅니다 |

- implication_for_skill_maker: `name`이 부모 디렉터리와 일치하는 것은 문체 선호가 아니라 명세
  요구이므로, 규칙 문구는 **must**로 쓰고 검증기는 이를 강제해야 합니다.

### 점진적 공개와 파일 참조

- 세 단계입니다. 메타데이터(`name` + `description`, 모든 스킬에 대해 시작 시 로드, 약 100토큰),
  스킬이 활성화될 때 로드되는 `SKILL.md` 본문(5,000토큰 미만 권장), 필요할 때 읽는 `scripts/`,
  `references/`, `assets/`입니다.
- 본문 `SKILL.md`는 500줄 미만으로 유지하고 세부 내용은 별도 파일로 옮깁니다.
- 다른 파일은 스킬 루트 기준 상대 경로로 참조하고, 참조는 `SKILL.md`에서 **한 단계 깊이**로
  유지합니다. 깊게 중첩된 참조 사슬은 피합니다.
- implication_for_skill_maker: 500줄과 5,000토큰은 출처가 말한 값입니다. 이 저장소는 추가로
  `scripts/check-sources.sh`에서 300줄 게이트를 걸며, 그 검사는 `instructions`만 대상으로 합니다.
  300을 출처가 말한 값처럼 제시하지 말고 두 값을 구분해 유지합니다.

### 검증

- 출처는 참조 구현 `skills-ref validate ./my-skill`을 제시하며, 이는 `SKILL.md` frontmatter가
  유효하고 작명 관례를 따르는지 검사합니다.
- implication_for_skill_maker: 이 저장소는 `scripts/validate-skills.sh`에서 `uvx`로 그것을
  실행합니다. 이 경로는 네트워크가 필요하고 `bun run --cwd scripts verify`에 포함되지 않으므로,
  오프라인 게이트에 조용히 끼워 넣지 않습니다.

## 스킬 제작자를 위한 모범 사례

- source_url: https://agentskills.io/skill-creation/best-practices
- last_verified_at: 2026-09-20
- applies_to: 스킬 내용의 출처, 실제 실행을 통한 개선, 컨텍스트 사용, 설명 최적화, 훈련·검증 분할
- summary: 스킬은 일반 지식에서 생성하기보다 실제 전문성에 근거해야 합니다. 직접 수행한 작업에서
  추출하거나, 기존 프로젝트 산출물(내부 문서, 런북, API 명세, 코드 리뷰 코멘트, 버전 관리 이력,
  실제 실패 사례)에서 합성합니다. 실제 작업에 스킬을 돌리고 최종 출력만이 아니라 실행 추적을 읽어
  개선합니다. 500줄·5,000토큰 예산과 함께, 트리거 질의 약 20개를 훈련·검증으로 대략 60/40으로
  나누라고 말합니다.
- implication_for_skill_maker: 스킬 초안을 쓰기 전에 도메인 전문성의 출처를 밝히게 하고, 개선
  단계에서는 출력이 아니라 추적을 읽게 합니다.

## 스킬 출력 품질 평가

- source_url: https://agentskills.io/skill-creation/evaluating-skills
- last_verified_at: 2026-09-20
- applies_to: 테스트 케이스 설계, 스킬 있음·없음 쌍, 실행별 시간·채점 기록, 단언
- summary: 테스트 케이스는 프롬프트, 사람이 읽는 기대 출력, 선택적 입력 파일로 이루어집니다. 핵심
  패턴은 각 케이스를 두 번, 즉 스킬과 함께 한 번 그리고 없이(또는 이전 버전과) 한 번 실행해 비교
  기준을 갖는 것입니다. 채점은 PASS 또는 FAIL을 **출력을 인용하거나 참조하는 증거와 함께**
  기록합니다. 기계적 검사(유효한 JSON, 행 수, 파일 존재)는 스크립트에 맡기고, 스크립트가 판단할 수
  없는 것에만 판단을 씁니다. 2-3개 케이스로 시작해 확장합니다.
- implication_for_skill_maker: 짝지은 실행과 증거 문자열이 핵심입니다. 증거 문자열 없는
  `passed: true`는 기록이 아닙니다.

## 스킬 설명 최적화

- source_url: https://agentskills.io/skill-creation/optimizing-descriptions
- last_verified_at: 2026-09-20
- applies_to: 지표로서의 트리거 비율, 케이스별 실행 횟수와 임계값, 훈련·검증 선택, 설명 길이 한도
- summary: 트리거 동작은 확률적이므로 케이스마다 자기 실행 횟수와 임계값을 갖고, 실행은 그 결과
  비율을 기록합니다. 질의 집합을 훈련과 검증으로 나누고 검증 성능으로 선택하며, 가장 좋은 반복이
  마지막 반복이 아닐 수 있음을 기억합니다. 설명은 최적화하는 동안 길어지므로 편집할 때마다 길이
  한도를 다시 확인하고, 조정이 더는 도움이 되지 않으면 형용사를 더하지 말고 구조를 바꿉니다.
- implication_for_skill_maker: 최종 점수만 보고하는 실행은 개선의 증거가 아닙니다. 반복마다 훈련과
  검증 수치를 함께 보고합니다.

## 스킬에서 스크립트 사용

- source_url: https://agentskills.io/skill-creation/using-scripts
- last_verified_at: 2026-09-20
- applies_to: 스킬이 산문 대신 실행 코드를 넣어야 하는 시점과 그 코드의 문서화 방식
- summary: 실행 코드는 결정적 동작, 정밀한 처리, 또는 산문으로 보장할 수 없는 외부 도구 연동을
  제공할 때 스킬에 들어갑니다. 스크립트는 자립적이거나 의존성을 문서화해야 하고, 도움이 되는
  오류를 내며, 경계 조건을 처리해야 합니다. 스크립트 코드는 컨텍스트 창에 들어가지 않고 출력만
  들어갑니다.
- implication_for_skill_maker: 스크립트는 편의가 아니라 결정성이나 외부 연동으로 정당화되며,
  검토자가 읽는 것은 그 출력입니다.

## Sources

> 링크 확인 2026-09-20. 다음 재검증: 2026-10-29, `instructions/README.md`의 주기와 맞춥니다.

| 주장 | 출처 |
|---|---|
| frontmatter 필드 표와 그 모든 제약, 필수·선택 구분, 디렉터리 관례, 세 단계 공개 모델, 500줄 지침, 한 단계 깊이 파일 참조 규칙 | <https://agentskills.io/specification> |
| 실제 전문성에 근거한 스킬 작성, 실제 실행과 추적을 통한 개선, 5,000토큰 예산, 약 20개 질의의 훈련·검증 분할 | <https://agentskills.io/skill-creation/best-practices> |
| 테스트 케이스 형태, 스킬 있음·없음 쌍, 증거 문자열이 있는 채점, 기계적 검사는 스크립트로 | <https://agentskills.io/skill-creation/evaluating-skills> |
| 트리거 비율, 케이스별 실행 횟수와 임계값, 훈련·검증 선택, 설명 길이 재확인 | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| 실행 코드를 넣을 시점과 그 문서가 밝혀야 할 것 | <https://agentskills.io/skill-creation/using-scripts> |
| 위 다섯 문서를 찾는 데 쓴 문서 목록 | <https://agentskills.io/llms.txt> |

### 증거 등급

`PRIMARY`입니다. 명세 문서가 frontmatter 제약과 공개 예산을 직접 말합니다. **기반 문서에 대한 정정
기록:** `instructions/skill/references/skill-anatomy.md` §2는 `compatibility`의 하한 1이 "확인한
어떤 출처에도 명시되지 않는다"고 적습니다. 2026-09-20에 확인한 명세 문서는 "Must be 1-500
characters if provided"라고 적습니다. 그 기반 문서의 서술은 이제 낡았습니다. 이 계획이
`instructions/**`를 범위 밖으로 두므로 정정은 여기에 기록하고 기반 문서는 고치지 않습니다.
