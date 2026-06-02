# 스킬 구조

**목적**: 고품질 스킬이 가져야 할 최소 구조와 책임 분리를 정의합니다.

## 1. 최소 구조

스킬은 `SKILL.md`에서 시작하고, support file은 triggerability, reliability, reuse, validation을 높일 때만 추가합니다.

권장 구조:

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

| 요소 | 필요성 | 책임 |
|---|---|---|
| `SKILL.md` | 필수 | metadata, trigger, core execution contract, workflow, validation |
| `SKILL.ko.md` | repo 관례 | local/user-facing 사용을 위한 한국어 mirror |
| `rules/` | 조건부 | 재사용 정책, 판단 기준, validation checklist, anti-pattern |
| `references/` | 조건부 | 공식 요약, 상세 지식, schema, edge case, long example |
| `scripts/` | 조건부 | 결정적 helper, validator, formatter, data transform |
| `assets/` | 조건부 | template, fixture, schema, static output resource |
| `agents/` | 조건부 | runtime/UI가 소비할 때만 metadata |

## 2. Frontmatter

명확한 discovery metadata를 사용합니다.

```yaml
---
name: skill-name
description: Use this skill when the user asks to ... Do not use for ...
compatibility: Optional runtime/dependency requirements.
---
```

규칙:

- `name`은 lowercase kebab-case이며 가능하면 폴더명과 일치합니다.
- `description`은 마케팅 문구가 아니라 trigger guidance입니다.
- `description`은 무엇을 하는지와 언제 쓰는지를 모두 말해야 합니다.
- `compatibility`는 실제 runtime, network, package, tool, permission 제약이 있을 때만 씁니다.
- tool allowlist 같은 implementation-specific field는 선택 사항이며 core instruction을 대체하면 안 됩니다.

## 3. 최소 Core Contract

중요한 `SKILL.md`는 다음을 드러내야 합니다.

- output language contract
- purpose
- routing rule
- instruction contract
- activation examples
- trigger conditions 또는 supported targets
- skill architecture 또는 resource model
- workflow
- support-file read order 또는 navigation cue
- required/forbidden behavior
- validation checklist

instruction contract에는 intent, trigger, scope, authority, evidence, tools, output, verification, stop condition이 드러나야 합니다.

## 4. `SKILL.md`에 둘 것

코어 스킬에는 다음을 둡니다.

- 스킬이 하는 일
- 언제 쓰고 언제 쓰지 않는지
- 어떤 output 또는 transformation을 만들어야 하는지
- high-level workflow
- 필수 authority, safety, stop-condition boundary
- 더 깊은 rules 또는 references로 가는 pointer

코어 스킬을 전체 knowledge base로 만들지 않습니다.

## 5. 언어와 Mirror Pairing

canonical skill markdown은 기본적으로 영어로 쓰되, 생성되는 user-facing artifact는 기본 한국어가 되게 합니다.

스킬 폴더 안에서 markdown 파일을 만들거나 실질적으로 수정할 때는 한국어 sibling translation을 유지합니다.

- `SKILL.md`는 `SKILL.ko.md`와 짝을 이룹니다.
- `rules/name.md`는 `rules/name.ko.md`와 짝을 이룹니다.
- `references/path/name.md`는 `references/path/name.ko.md`와 짝을 이룹니다.

현지화에 따른 작은 표현 조정을 제외하고 heading, section order, link, example을 구조적으로 정렬합니다.

## 6. Quality Gate

- [ ] `SKILL.md`만 읽어도 모든 support file을 보지 않고 스킬을 이해할 수 있음.
- [ ] Frontmatter가 discovery와 trigger selection을 지원함.
- [ ] Contract fields가 드러남: intent, trigger, scope, authority, evidence, tools, output, verification, stop.
- [ ] Rules는 policy를 담고 reference detail을 비대하게 복제하지 않음.
- [ ] References는 detail을 담고 core trigger logic을 담지 않음.
- [ ] Scripts/assets는 정당화되고 문서화된 경우에만 존재함.
- [ ] Optional metadata는 의도적으로 있거나 의도적으로 생략됨.
