# 스킬 구조

**Purpose**: 높은 품질의 스킬에 필요한 최소 형태와 책임 분담을 정의합니다.

## 1. 최소 구조

스킬은 `SKILL.md`로 시작하고, 발동성·신뢰성·재사용·검증을 개선할 때만 지원 파일을 더합니다.

권장 형태:

```text
skill-name/
├── SKILL.md
├── SKILL.ko.md
├── rules/
├── references/
├── scripts/
├── assets/
└── agents/
```

| 요소 | 요건 | 책임 |
|---|---|---|
| `SKILL.md` | 필수 | 메타데이터, 트리거, 핵심 실행 계약, 워크플로, 검증 |
| `SKILL.ko.md` | 저장소 관례 | 로컬·사용자 대면용 한국어 미러 |
| `rules/` | 조건부 | 재사용 정책, 판단 기준, 검증 체크리스트, 안티패턴 |
| `references/` | 조건부 | 공식 요약, 상세 지식, 스키마, 경계 사례, 긴 예시 |
| `scripts/` | 조건부 | 결정적 도우미, 검증기, 포매터, 데이터 변환 |
| `assets/` | 조건부 | 템플릿, 픽스처, 스키마, 정적 출력 자원 |
| `agents/` | 조건부 | 런타임이 소비할 때만 쓰는 런타임·UI 메타데이터 |

## 2. Frontmatter

```yaml
---
name: skill-name
description: Use this skill when the user asks to ... Do not use for ...
compatibility: Optional runtime/dependency requirements.
---
```

규칙:

- `name`은 소문자 케밥 표기이며 **부모 디렉터리 이름과 일치해야 합니다**.
- `description`은 마케팅 문구가 아니라 트리거 안내이며, 스킬이 무엇을 하는지와 언제 쓰는지를 모두 적습니다.
- `compatibility`는 선택이며 실제 런타임, 네트워크, 패키지, 도구, 권한 제약을 적습니다.
- 도구 허용 목록 같은 구현별 필드는 선택이며 핵심 지침을 대체할 수 없습니다.

## 3. Frontmatter 제약

아래 모든 제약은 명세에서 오며, 게이트가 있는 곳에서는 강제됩니다.

| 필드 | 필수 | 제약 |
|---|---|---|
| `name` | 예 | 1-64자. 소문자, 숫자, 하이픈만. 하이픈으로 시작하거나 끝날 수 없습니다. 연속 하이픈을 담을 수 없습니다. **부모 디렉터리 이름과 일치해야 합니다** |
| `description` | 예 | 1-1024자, 비어 있을 수 없습니다. 스킬이 무엇을 하는지와 언제 쓰는지를 적습니다 |
| `license` | 아니오 | 라이선스 이름 또는 함께 넣은 라이선스 파일 참조 |
| `compatibility` | 아니오 | **제공한다면 1-500자.** 환경 요구가 있을 때만 씁니다 |
| `metadata` | 아니오 | 명세가 정의하지 않은 속성을 위한 문자열 키-값 맵 |
| `allowed-tools` | 아니오 | 사전 승인된 도구의 공백 구분 문자열. **실험적** |

틀리기 쉬운 두 가지:

- `compatibility`의 하한 1은 명세가 **실제로** 말합니다. "Must be 1-500 characters if provided"입니다.
  이 필드는 양끝이 모두 제한된다고 봅니다.
- `name`이 부모 디렉터리와 일치하는 것은 **명세 요구**이지 문체 선호가 아닙니다. "가능하면 폴더와
  맞추는 것이 좋다"고 적은 규칙은 스스로 구현한다고 주장하는 표준보다 약합니다.

## 4. Claude 고유 제약

Claude는 명세 위에 제약을 더합니다. 이것을 어긴 스킬은 Claude로 이식되지 않습니다.

- `name`은 XML tags를 담을 수 없고 예약어 **"anthropic"**과 **"claude"**를 담을 수 없습니다.
- `description`은 XML tags를 담을 수 없습니다.
- 설명은 **third person**으로 씁니다. 이 필드는 시스템 프롬프트에 주입되므로 인칭이 흔들리는 설명은
  발견에 문제를 만듭니다.
- gerund 형태 이름(동사 + `-ing`)이 권장 관례입니다. 명사구와 동작 지향 이름도 허용되며 `helper`,
  `utils`, `tools` 같은 모호한 이름은 그렇지 않습니다.

함께 기억할 것: claude.ai 업로드, Skills API, `package_skill.py` 경로에서는 표준 여섯 필드만 허용되고
추가 필드는 조용히 무시되지 않고 **하드 오류**입니다. 그러므로 Claude Code 확장 필드를 쓰는 스킬은
이식 가능한 스킬이 아니라 Claude Code 스킬입니다.

## 5. `allowed-tools`가 실제로 하는 일

양방향 모두 틀리기 쉬우므로 정확히 적습니다.

- **허용적 부여**입니다. Claude Code는 이것을 **스킬을 호출한 턴 동안 승인 없이 쓸 수 있는** 도구라고
  문서화하며, 다음 메시지에서 권한이 해제됩니다. 즉 실제 효과가 있습니다.
- **제한적 경계가 아닙니다.** 에이전트가 다른 도구를 쓰는 것을 막지 않고, 독립적인 권한·안전 게이트를
  대체하지 않습니다. 명세는 이 필드를 실험적으로 표시하며, 다른 런타임은 파싱은 하지만 강제하지
  않는다고 기록합니다.

따라서 정확한 결론은 "효과가 없다"도 "보안 통제다"도 아닙니다. 편의를 위한 부여이며, 부작용 게이팅은
스킬 자체의 계약에 적어야 합니다.

## 6. 첫 줄 규칙, 목록 예산, 발견

**여는 `---`가 파일의 첫 줄일 때만 frontmatter를 읽습니다.** 그렇지 않으면 `---` 표시를 포함한 파일
전체가 스킬 내용으로 취급되며, 스킬은 발견 메타데이터를 조용히 잃고 이름으로는 여전히 로드될 수
있습니다.

이 규칙은 이미 두 저장소 게이트가 강제하므로 새 도구가 아니라 서술이 필요합니다.

- `validate-skill-maker.mjs`는 파일 시작에 `---`를 요구하는 앵커로 frontmatter를 찾으므로, 앞에 빈 줄이
  있으면 블록을 찾지 못하고 `FRONTMATTER_NAME`, `FRONTMATTER_DESCRIPTION`, `FRONTMATTER_TRIGGER`를
  보고합니다.
- `validate-skills-corpus.mjs`는 `FRONTMATTER_MISSING`을 보고합니다.

목록 예산:

| 런타임 | 예산 | 넘칠 때 |
|---|---|---|
| Codex | 컨텍스트 창의 **2%**, 창을 알 수 없으면 **8,000**자 | 먼저 설명을 줄이고, 이후 일부 스킬을 최초 목록에서 빼며 경고를 냅니다 |
| Claude Code | 컨텍스트 창의 1%, 항목당 텍스트는 1,536자 한도 | 가장 적게 호출한 스킬이 설명을 먼저 잃습니다 |

**이 저장소는 이미 Codex 예산을 넘겼습니다.** 2026-09-20 측정: 스킬 38개의 설명 합계가 **14,641**자
이며, 그 세션에서 Codex가 축약 경고를 냈습니다. 설명을 키우려면 이유가 필요하고, 핵심 트리거는 첫
문장에 있어야 합니다.

## 7. 최소 핵심 계약

비사소한 `SKILL.md`는 다음을 드러내야 합니다.

- 출력 언어 계약
- 목적
- 라우팅 규칙
- 지침 계약
- 활성화 예시
- 트리거 조건 또는 지원 대상
- 스킬 구조 또는 자원 모델
- 워크플로
- 지원 파일 읽기 순서 또는 안내 문구
- 필수·금지 동작
- 검증 체크리스트

지침 계약은 intent, trigger, scope, authority, evidence, tools, output, verification, stop 조건을
찾을 수 있게 해야 합니다.

## 8. `SKILL.md`에 들어갈 것

핵심 스킬에 남길 것:

- 스킬이 무엇을 하는지
- 언제 쓰고 언제 쓰지 않는지
- 어떤 출력이나 변환을 만들어야 하는지
- 상위 수준 워크플로
- 필수적인 권위·안전·정지 조건 경계
- 더 깊은 규칙이나 참조 안내

핵심 스킬을 전체 지식 기반으로 만들지 않습니다. 예산은 그 정본인 `rules/progressive-disclosure.md`에
있으며, 이 파일은 그것을 다시 적지 않습니다.

## 9. 언어와 미러 짝

정본 스킬 마크다운은 기본적으로 영어로 쓰되, 생성되는 사용자 대면 산출물은 기본을 한국어로 둡니다.

스킬 폴더 안에 마크다운 파일을 만들거나 실질적으로 수정할 때마다 한국어 형제 번역을 유지합니다.

- `SKILL.md`는 `SKILL.ko.md`와 짝입니다
- `rules/name.md`는 `rules/name.ko.md`와 짝입니다
- `references/path/name.md`는 `references/path/name.ko.md`와 짝입니다

국지화가 사소한 표현 변경을 요구하지 않는 한 제목, 절 순서, 링크, 예시를 짝 사이에서 구조적으로
맞춥니다. `## Sources` 제목은 두 파일 모두 영어로 유지합니다. 패리티 게이트가 그 제목을 그대로
대조하기 때문입니다. `###` 소제목과 필드 값은 자유롭게 번역합니다.

## 10. 품질 게이트

- [ ] `SKILL.md`가 모든 지원 파일을 읽지 않고도 스킬을 설명합니다.
- [ ] frontmatter가 발견과 트리거 선택을 뒷받침합니다.
- [ ] `name`이 부모 디렉터리 이름과 정확히 일치합니다.
- [ ] 계약 필드를 찾을 수 있습니다. intent, trigger, scope, authority, evidence, tools, output, verification, stop.
- [ ] 규칙이 정책을 담고 부풀린 참조 세부를 담지 않습니다.
- [ ] 참조가 세부를 담고 핵심 트리거 로직을 담지 않습니다.
- [ ] 스크립트·자산이 정당화되고 문서화된 경우에만 존재합니다.
- [ ] 선택 메타데이터가 의도적으로 있거나 의도적으로 없습니다.
- [ ] `allowed-tools`를 쓸 때 안전 경계로 제시하지 않습니다.

## Sources

> 링크 확인 2026-09-20.

| 주장 | 출처 |
|---|---|
| frontmatter 필드 표와 그 모든 제약, 필수·선택 구분, 세 단계 공개 모델 | <https://agentskills.io/specification> |
| `name`의 XML 태그·예약어 제약, `description`의 XML 태그 제약, 3인칭 설명, 동명사 작명 관례 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> |
| 표준 frontmatter 여섯 필드, claude.ai·API 경로에서 비표준 필드의 하드 오류, 첫 줄 규칙, 1%·1,536자 목록 예산 | <https://code.claude.com/docs/en/skills> |
| Codex의 2%·8,000자 목록 예산, 먼저 줄이고 이후 생략, 생략 경고 | <https://learn.chatgpt.com/docs/build-skills> |
| 제한적 경계가 아니라 호출 턴에 대한 허용적 부여로서의 `allowed-tools` | <https://code.claude.com/docs/en/skills> |
| 파싱은 되지만 강제 가능한 권한 경계로 확립되지 않은 `allowed-tools` | `instructions/cli/jcode/README.md` |
| 첫 줄 규칙을 이미 강제하는 게이트 | `skills/skill-maker/scripts/validate-skill-maker.mjs` |
| 38개 스킬·14,641자 측정 | 이 저장소, 2026-09-20 측정 |

### 증거 등급

frontmatter 제약은 `PRIMARY`이며 명세가 말합니다. Claude 추가 사항과 목록 예산은 `VENDOR`이며 각
벤더가 자기 제품에 대해 한 서술입니다. 38개 스킬·14,641자 수치는 이 저장소의 측정이며 외부 주장이
아닙니다.

**기반 문서에 대한 정정 기록:** `instructions/skill/references/skill-anatomy.md` §2는 `compatibility`의
하한 1이 "확인한 어떤 출처에도 명시되지 않는다"고 적습니다. 명세는 그것을 명시합니다. 그 기반 문서의
서술은 낡았으며, 범위 밖인 `instructions/**`를 고치는 대신 여기에 기록합니다.
