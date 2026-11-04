---
name: readme-maker
description: "[Hyper] 사용자가 코드베이스를 근거로 프로젝트 README.md나 모노레포 패키지 README를 새로 쓰거나, 리팩터하거나, 일부 섹션을 갱신해 달라고 요청할 때 사용한다. 프로젝트 형태(CLI, 라이브러리, 웹 앱, 모노레포, 플러그인, 프레임워크, 문서 사이트, 서비스), 진입점, 스크립트, 설정, 라이선스, 기존 문서를 확인한 뒤, 사용자가 다른 언어를 요청했거나 기존 README의 언어를 유지해야 하는 경우가 아니면 한국어 README를 쓴다. CHANGELOG, CONTRIBUTING, LICENSE, 일반 문서, 릴리스 노트, 소스 코드 작업에는 사용하지 않는다."
compatibility: 프로젝트 구조 스캔, 매니페스트 분석, 소스 검증을 위해 read/edit/write와 셸 검색 도구가 가장 잘 동작한다.
---

@rules/project-discovery.md
@rules/section-design.md
@rules/validation.md
@references/readme-templates.md

# README Maker

> 프로젝트를 꼼꼼히 읽고, 그 프로젝트가 진짜 받아야 할 README를 쓴다.

<output_language>

사용자에게 보이는 모든 산출물, 저장 파일, 리포트, 계획서, 생성 문서, 요약, 인수인계 메모, 커밋 메시지 초안, 검증 메모는 기본적으로 한국어로 작성한다. 이 정본 파일이 영어로 쓰여 있어도 같다.

사용자가 다른 언어를 명시적으로 요청했거나, 기존 대상 산출물의 언어 일관성을 유지해야 하거나, 기계 판독 계약이 정확한 영어 토큰을 요구할 때만 다른 언어를 쓴다.

</output_language>

<purpose>

- 보일러플레이트가 아니라 실제 코드베이스에 근거한 `README.md`를 생성한다.
- 오래되거나 일반적인 README를 리팩터해 설치, 사용법, 구조, 예시가 현재 코드와 일치하도록 만든다.
- 프로젝트 형태(CLI, 라이브러리, 웹 앱, 모노레포, 플러그인, 프레임워크, 문서 사이트, 서비스)에 맞춰 섹션 선택과 깊이를 조정한다.
- 증거 보존: 모든 설치 명령, 스크립트, 배지, 예시는 저장소의 실제 파일로 추적 가능해야 한다.

</purpose>

<routing_rule>

주요 산출물이 프로젝트, 라이브러리, CLI, 플러그인, 워크스페이스, 프레임워크, 문서 사이트, 서비스에 대한 (루트 또는 하위 패키지) `README.md`일 때 `readme-maker`를 사용한다.

인접 작업은 산출물 형태로 경계를 나눈다:

- 일반 문서, 런북, 인스트럭션 베이스, 하니스 룰 팩은 README가 아니라 문서 산출물이다.
- 제품 기획 패키지(PRD, 다이어그램, 기능 명세, 사용자 플로우, 와이어프레임)는 기획 산출물이다.
- SEO/AEO/GEO 감사 또는 마케팅 페이지 최적화는 검색 최적화 산출물이다.
- README 산출물 없는 순수 사실 조사는 조사 작업이다.
- 버전 업이나 릴리스 노트 묶음은 릴리스 산출물이다.
- 마무리된 README를 커밋하는 일은 README 작성이 아니라 버전 관리 작업이다.

다음의 경우에는 `readme-maker`를 사용하지 않는다:

- 사용자가 `CHANGELOG.md`, `CONTRIBUTING.md`, `LICENSE` 등 README가 아닌 파일만 원할 때
- 사용자가 소스 코드 수정, 리팩터, 기능 구현을 원하고 README는 부수적으로 언급될 때
- 사용자가 README 산출물 없이 실시간 외부 조사만 원할 때
- 사용자가 AI가 읽기 좋은 인스트럭션 문서나 하니스 룰 팩을 원할 때 (문서 산출물이므로 범위 밖)

</routing_rule>

<instruction_contract>

| 필드 | 계약 |
|---|---|
| Intent | 대상 프로젝트의 실제 형태, 설치, 사용법, 제약을 반영한 `README.md`를 생성하거나 개선한다. |
| Scope | 대상 `README.md`(루트 또는 패키지)와 짧은 요약만 소유한다. 사용자가 요청하지 않는 한 소스 코드, 설정, 라이선스, 무관한 문서는 수정하지 않는다. |
| Authority | 사용자 지시와 프로젝트 로컬 문서(`AGENTS.md`, `CLAUDE.md`, 루트 README, 패키지 매니페스트)가 일반 README 관습이나 외부 템플릿보다 우선한다. |
| Evidence | 모든 설치 명령, 스크립트 호출, 파일 경로, 배지, 기능 주장은 프로젝트의 실제 파일에 근거해야 한다. 명령이나 API를 지어내지 않는다. |
| Tools | 프로젝트 내부에서만 read/edit/write와 셸 검색(`find`, `grep`, `ls`)을 사용한다. 작성 과정에서 install, build, deploy, release 명령을 실행하지 않는다. |
| Loop | 없음. 요청 하나당 한 번만 수행한다. 프로젝트 발견, 섹션 설계, 초안 작성, 검증, 보고 후 종료하며, 다른 README나 후속 섹션 갱신을 사용자가 요청할 때만 다시 호출한다. |
| Output | 작성 또는 갱신된 단일 `README.md`와, 어떤 파일을 살폈고 어떤 섹션이 바뀌었는지 적은 짧은 요약. |
| Verification | 완료 전에 `rules/validation.md`의 프로젝트 디스커버리·형태·언어·증거 검사를 실행한다. |
| Stop condition | 검사가 통과하고 불확실한 주장에 `<!-- TODO -->`가 표시되었을 때 종료한다. 프로젝트 형태가 모호하거나 라이선스가 불명확하거나 명령을 저장소에서 검증할 수 없으면 에스컬레이션한다. |

</instruction_contract>

<activation_examples>

Positive examples (긍정 예시):

- "이 프로젝트를 꼼꼼히 읽고 README.md를 만들어줘."
- "현재 CLI 명령에 맞게 README를 리팩터해줘."
- "이 모노레포의 `packages/color` 워크스페이스용 README를 만들어줘."
- "새 진입점에 맞춰 README의 install/usage 섹션만 갱신해줘."
- "프로젝트 README.md 만들어줘."
- "이 저장소를 꼼꼼히 읽고 README를 다시 써줘."

Negative examples (부정 예시):

- "커밋 로그로 CHANGELOG 만들어줘." → 산출물은 릴리스 문서이며 README가 아님.
- "이 라이브러리의 API 문서를 작성해줘." → 산출물은 문서이며 README가 아님.
- "이 프로젝트의 다음 릴리스를 기획해줘." → 산출물은 기획 문서이며 README가 아님.
- "이 코드베이스에 새 기능을 추가해줘." → README 작업이 아님.

Boundary examples (경계 예시):

- "이 프로젝트를 문서화해줘."
  산출물이 `README.md`일 때만 `readme-maker`를 사용한다. 가이드, 런북, 인스트럭션 베이스는 문서 산출물이므로 범위 밖이다.
- "README를 리팩터하고 커밋해줘."
  README 자체는 `readme-maker`로 작업하고, 뒤따르는 커밋은 README 작성이 아니라 버전 관리 작업으로 처리한다.
- "이 README 리팩터하고 커밋도 같이 해줘." (한국어 경계 예시. README 작성은 `readme-maker`로 먼저, 커밋은 별도의 버전 관리 작업으로.)

</activation_examples>

<trigger_conditions>

| 상황 | 모드 |
|------|------|
| 프로젝트에 `README.md`가 없음 | create |
| `README.md`가 있지만 오래되거나 일반적이거나 현재 코드와 모순됨 | refactor |
| 기능, 이름 변경, 이동 후 특정 섹션을 갱신해야 함 | update |
| 모노레포 안의 하위 패키지/워크스페이스가 자체 README를 필요로 함 | create |
| README가 한국어 기본 언어 정책과 어긋나거나, 명시 요청/기존 문서 언어 보존이 필요함 | refactor |

</trigger_conditions>

<skill_architecture>

| 구성 | 역할 |
|---|---|
| `SKILL.md` | trigger, 계약, workflow, gate |
| `rules/project-discovery.md` | 프로젝트 형태, 진입점, 매니페스트, 스크립트, 기존 문서 |
| `rules/section-design.md` | 프로젝트 유형별 섹션 정책, 순서, 문체, 배지, 축약 기준 |
| `rules/validation.md` | 근거, 형태, 언어, 완성도 검사 |
| `references/readme-templates.md` | 유형별 README 골격. 붙여 넣는 문장이 아니라 적응할 틀이다 |
| `assets/evals/readme-maker-cases.jsonl` | trigger, routing, 근거, 안전 case |

</skill_architecture>

<loop_policy>

loop은 없다. 요청 하나에 프로젝트 확인, 섹션 계획, 초안, 검증, 보고를 각각 한 번씩 한다. 검사가 실패하면 지목된 섹션을 고치고 그 검사만 다시 실행하며, 이 재실행은 두 번을 넘기지 않는다. 그 뒤에도 남은 문제는 계속 반복하지 않고 그대로 보고한다. 자체 검토만으로는 검증이 되지 않는다.

</loop_policy>

<language_and_translation_default>

소스 코드 식별자, CLI 명령, 파일 경로, 스키마 키, JSON/YAML 필드명, API 이름, 패키지명, 고유명사, 인용한 원문 발췌는 필요한 언어 또는 원문 그대로 유지한다. 사용자에게 보이는 산출물에는 현지화된 템플릿이나 참조(`*.ko.md`, `*.ko.json`)가 있으면 그것을 먼저 쓴다.

이 package의 Markdown은 영어/한국어 쌍으로 관리한다. 한 번의 작업에서는 한 언어판만 읽고, 한쪽을 고치면 다른 쪽도 같게 맞춘다.

</language_and_translation_default>

<reference_routing>

- 프로젝트 유형이나 근거 출처가 불분명하면 섹션을 고르기 전에 `rules/project-discovery.md`를 읽는다.
- 섹션 순서, 깊이, 문체, 배지 정책을 정할 때 `rules/section-design.md`를 읽는다.
- 초안을 쓰는 동안 해당 프로젝트 유형의 `references/readme-templates.md`를 읽는다. 템플릿은 시작 골격일 뿐 명령의 출처가 아니다.
- 완료 전에 `rules/validation.md`를 읽고 그 검사를 실행한다.
- 이 package의 trigger, workflow, 산출물이 바뀌면 `assets/evals/readme-maker-cases.jsonl`을 읽고 관찰한 실패를 regression으로 추가한다.

</reference_routing>

<support_file_read_order>

한 번의 작업에서는 한 언어판만 읽는다. 한국어 package는 맞는 `*.ko.md` 파일을 쓰며, 읽는 조건은 `reference_routing`에 있다.

1. `rules/project-discovery.md`
2. `rules/section-design.md`
3. `references/readme-templates.md`
4. `rules/validation.md`
5. `assets/evals/readme-maker-cases.jsonl`

</support_file_read_order>

<workflow>

| 단계 | 작업 | 산출물 |
|------|------|------|
| 0 | 산출물이 `README.md`인지 확인하고 `create`/`refactor`/`update`를 선택 | 모드 결정 |
| 1 | 프로젝트 구조를 스캔하고 형태를 감지(`rules/project-discovery.md`) | 프로젝트 프로필 |
| 2 | 기존 README, `AGENTS.md`, `CLAUDE.md`, 라이선스, 매니페스트, 진입점 읽기 | 증거 베이스 |
| 3 | 섹션, 순서, 깊이, 한국어 기본 언어 처리 결정(`rules/section-design.md`) | 섹션 플랜 |
| 4 | 근거 있는 예시와 `references/readme-templates.md` / `.ko.md`의 한국어 기본 템플릿으로 `README.md` 작성/리팩터 | 갱신된 README |
| 5 | 검증 검사(`rules/validation.md`) 실행 후 완료 요약 작성 | 최종 README + 요약 |

### 4단계 작성 규칙

- 먼저 읽고, 그다음 쓴다. 설치 명령, 스크립트, 환경 변수, API를 지어내지 않는다.
- README 산문은 기본적으로 한국어로 씁니다. 사용자가 다른 언어를 요청했거나 기존 대상 README의 현재 문서 언어를 보존해야 할 때만 다른 언어를 사용합니다.
- 추측 예시 세 개보다 정확한 예시 한 개를 선호한다.
- README는 스캔 가능해야 한다: 제목, 설명, 설치, 퀵스타트는 첫 화면 안에 둔다.
- 깊이 들어가는 내용은 README 밖으로 빼고 링크한다. README는 안내하는 곳이지 모든 것을 담는 곳이 아니다.
- 검증할 수 없는 배지(CI 상태, 커버리지, npm 버전)는 프로젝트가 이미 발행하고 있지 않으면 추가하지 않는다.

</workflow>

<required>

| 카테고리 | 필수 |
|------|------|
| Evidence | README의 모든 install/usage 라인이 매니페스트, 스크립트, 소스 파일 또는 기존 문서에 매핑된다 |
| Shape match | 섹션 선택이 감지된 프로젝트 형태와 일치한다 |
| Language match | README 산문이 기본적으로 한국어이거나, 보존이 필요한 경우 사용자 요청/기존 대상 언어와 일치한다 |
| Discoverability | 제목, 한 줄 설명, install, quickstart가 첫 화면 안에 있다 |
| Scope | update 모드에서는 사용자가 지목한 섹션이나 diff가 가리키는 섹션만 고치고, README에 변경 이력 섹션이 이미 있을 때만 항목을 추가한다 |
| Verification | 완료 선언 전에 검증 체크리스트가 끝난다 |

</required>

<forbidden>

| 카테고리 | 금지 |
|------|------|
| Fabrication | 저장소에 없는 설치 명령, 스크립트, 환경 변수, API |
| Drift | 오래된 스크린샷, 죽은 링크, 폐기된 명령을 그대로 둠 |
| Overload | 전체 API 레퍼런스, 긴 튜토리얼, 설계 문서를 README에 끼워 넣음 |
| Tone | 마케팅 부풀림, 모호한 최상급 표현, 코드가 뒷받침하지 않는 과장 |
| Side effects | README 작성 중에 소스 코드, 설정, 라이선스를 수정 |
| Extra files | 사용자가 요청하지 않은 `CHANGELOG.md`, `CONTRIBUTING.md` 등 추가 파일 생성 |

</forbidden>

<validation>

| 검사 | 규칙 |
|------|------|
| Evidence | README의 모든 명령과 경로가 저장소에 존재 |
| Shape | 선택한 템플릿이 실제 프로젝트 형태와 일치 |
| Language | README는 기본적으로 한국어이며, 비한국어 출력은 명시 요청 또는 기존 대상 언어 보존 시에만 사용 |
| Above the fold | 제목, 설명, install, quickstart가 첫 화면 안에 위치 |
| No fabrication | 지어낸 API, 스크립트, env var, 외부 배지 없음 |
| Lean body | 긴 내용은 인라인이 아니라 링크로 처리 |
| Translation pair | 스킬 자체나 다른 마크다운을 수정했다면 영문/한글 파일이 정렬되어 있음 |

필수 통과 임계값:
- [ ] 프로젝트 형태가 감지되어 완료 요약에 기록됨
- [ ] 검증된 install 명령 1개와 검증된 usage 예시 1개 이상
- [ ] (refactor/update 모드) 정확한 기존 README 섹션은 보존됨
- [ ] 모르는 부분은 지어내지 않고 `<!-- TODO -->`로 표시됨
- [ ] 새 초안에 죽은 링크나 사라진 스크립트가 남아 있지 않음

</validation>
