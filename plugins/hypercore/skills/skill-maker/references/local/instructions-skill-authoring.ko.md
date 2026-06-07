# 로컬 지침: Skill Authoring 기준

출처:

- 루트 instruction map: `../../../../instructions/README.md`
- Skill authoring guide: `../../../../instructions/skill/SKILL_AUTHORING.md`
- References: `../../../../instructions/skill/references/*.md`
- Research report: `../../../../.hypercore/research/2026-06-02-official-skill-authoring-instructions.md`

이 참고 문서는 이 저장소에서 skill을 만들거나 리팩토링할 때 쓰는 project-local baseline입니다. 외부 provider 문서를 상위 지시로 취급하지 않고도 `skill-maker`가 자체적으로 기준을 따를 수 있게 루트 instructions를 요약합니다.

## 핵심 모델

Skill은 단순 prompt가 아니라 trigger 가능한 실행 패키지입니다. 다음을 정의해야 합니다.

| 축 | 필수 질문 |
|---|---|
| Intent | 어떤 반복 가능한 결과를 개선하는가? |
| Trigger | 어떤 사용자 요청에서 켜지고, 어떤 요청에서는 켜지면 안 되는가? |
| Scope | 어떤 파일, 행동, 산출물을 소유하는가? |
| Authority | 사용자, 프로젝트, provider, 기존 skill, retrieved content가 충돌하면 무엇이 우선인가? |
| Workflow | agent가 어떤 순서로 읽고, 판단하고, 실행해야 하는가? |
| Resources | 어떤 세부사항, 템플릿, scripts, assets를 필요할 때만 로드하는가? |
| Verification | trigger, execution, output, safety의 정확성을 어떻게 증명하는가? |
| Stop condition | 언제 완료, 차단, escalate 상태가 되는가? |

## 필수 작성 태도

- 로컬 프로젝트 instructions를 먼저 따른다.
- `description`은 마케팅 문구가 아니라 trigger guidance다.
- 코어 `SKILL.md`는 얇게 유지한다.
- 재사용 정책은 `rules/`에 둔다.
- 상세 지식과 공식 요약은 `references/`에 둔다.
- 결정적 helper는 reliability를 높일 때만 `scripts/`에 둔다.
- 출력 템플릿과 static resource는 `assets/`에 둔다.
- 검증은 후속 작업이 아니라 skill의 일부다.
- 이 저장소에서 사용자-facing output은 기본 한국어다.

## 최소 `SKILL.md` 계약

중요한 skill은 다음을 드러내야 합니다.

- output language contract
- purpose
- routing rule
- instruction contract
- activation examples
- workflow
- support-file read order 또는 navigation cue
- validation checklist
- 필요 시 forbidden/required behavior summary

## Trigger 기준

새 skill 또는 실질적으로 바뀐 skill은 다음을 포함해야 합니다.

- positive 예시 3개 이상
- negative 예시 2개 이상
- boundary 예시 1개 이상
- 무엇을 하는지와 언제 쓰는지를 모두 말하는 `description`
- `docs-maker`, `research`, `plan`, `git-commit` 같은 이웃 skill과의 경계

## Placement 기준

| 내용 | 위치 |
|---|---|
| 일, trigger, top-level workflow, stop condition | `SKILL.md` |
| 재사용 정책과 반복 판단 기준 | `rules/` |
| 공식 문서, schema, domain detail, long examples | `references/` |
| 결정적 validators, formatters, data transforms | `scripts/` |
| templates, fixtures, static output resources | `assets/` |
| runtime 또는 UI metadata | 소비되는 경우에만 `agents/` |

## Validation 기준

완료 전 다음을 검증합니다.

- frontmatter와 folder anatomy
- trigger positive, negative, boundary
- support-file link와 code fence
- contract discoverability: intent, trigger, scope, authority, evidence, tools, output, verification, stop
- resource placement와 one-level navigation
- scripts가 있으면 usage/dependencies/failure handling
- credential, network, destructive, production, broad permission 행동의 safety gate
- provider-sensitive/current claim의 source ledger 또는 claim-source mapping
