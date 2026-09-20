# Skill Anatomy

> 영어판: [`skill-anatomy.md`](skill-anatomy.md)

Skill anatomy는 skill이 어떤 파일을 가져야 하는지보다, 각 파일이 어떤 책임을 가져야 하는지를 정의한다.

## 1. 필수와 선택

| 요소 | 필수성 | 책임 |
|---|---|---|
| `SKILL.md` | 필수 | metadata, trigger, 핵심 실행 계약, workflow, validation |
| `SKILL.ko.md` | 권장 | 한국어 사용자-facing mirror |
| `rules/` | 조건부 | 반복 정책, decision rule, checklist |
| `references/` | 조건부 | 공식 문서 요약, 상세 지식, edge case, 긴 예시 |
| `scripts/` | 조건부 | deterministic helper, validator, formatter, data transform |
| `assets/` | 조건부 | 템플릿, 스키마, 예시 산출물, static resources |
| `agents/` | 조건부 | OpenAI 또는 특정 UI/runtime metadata |

## 2. Frontmatter

기본 frontmatter:

```yaml
---
name: skill-name
description: Use this skill when the user asks to ...
compatibility: Optional runtime/dependency requirements.
---
```

### Spec 필드와 제약

Agent Skills specification(<https://agentskills.io/specification>, 확인 2026-09-19) 기준이다.

| 필드 | 필수 | 제약 |
|---|---|---|
| `name` | 필수 | 1-64자. 소문자 `a-z`·숫자·하이픈만. 하이픈으로 시작·종료 불가, 연속 하이픈(`--`) 불가. **부모 디렉터리명과 일치해야 한다** |
| `description` | 필수 | 1-1024자. 무엇을 하는지와 언제 쓰는지를 모두 포함 |
| `license` | 선택 | 라이선스명 또는 번들 라이선스 파일 참조. 짧게 유지 |
| `compatibility` | 선택 | 1-500자. 대상 제품, 시스템 패키지, 네트워크 요구 등 환경 요구가 있을 때만 |
| `metadata` | 선택 | 문자열 key-value 맵. spec 미정의 속성 보관용. 충돌을 피하도록 key를 고유하게 |
| `allowed-tools` | 선택 | 공백 구분 문자열. 사전 승인 도구 목록. **Experimental — 구현체별 지원이 다르다** |

### Progressive disclosure 예산

| 단계 | 로드 시점 | 권장 예산 |
|---|---|---|
| Metadata | 시작 시 전체 skill에 대해 | `name` + `description` 약 100 토큰 |
| Instructions | skill 활성화 시 | `SKILL.md` 본문 **5,000 토큰 미만**, **500줄 미만** |
| Resources | 필요할 때만 | `scripts/`·`references/`·`assets/` 개별 로드 |

Codex 런타임은 목록 단계 예산을 컨텍스트의 2% 또는 8,000자로 제한한다(<https://learn.chatgpt.com/docs/build-skills>). 즉 `description`은 잘릴 수 있다고 가정하고 핵심 트리거를 앞에 둔다.

### 규칙

- `name`은 lowercase kebab-case로 쓰고 **폴더명과 일치시킨다**(spec 요구사항이며 권장이 아니다).
- `description`은 trigger 문장이다. 기능 목록만 나열하지 않는다.
- `compatibility`는 런타임, 네트워크, 시스템 패키지, tool 요구가 있을 때만 쓴다. 대부분의 skill에는 필요 없다.
- `allowed-tools`는 spec상 Experimental이므로 해당 런타임에서 지원을 확인했을 때만 사용하고, 공통 규칙으로 강제하지 않는다.
- 파일 참조는 skill 루트 기준 상대경로로 쓰고 **한 단계 깊이**로 유지한다. 깊게 중첩된 참조 사슬을 만들지 않는다.

### 검증 도구

공식 reference 구현으로 frontmatter와 명명 규칙을 기계 검증할 수 있다.

```bash
skills-ref validate ./my-skill
```

이 저장소는 [`scripts/validate-skills.sh`](../../../scripts/validate-skills.sh)에서 `uvx`로 `skills-ref validate`를 `skills/**/SKILL.md` 전체에 실행한다.

## 3. Core body 책임

`SKILL.md`에는 다음만 둔다.

1. output language / localization contract
2. purpose
3. routing rule
4. instruction contract
5. activation examples
6. high-level workflow
7. support-file read order
8. validation checklist
9. forbidden/required behavior 요약

긴 API 세부, 많은 예시, 공식 문서 요약, 환경별 옵션은 core body에서 빼야 한다.

## 4. Rule files 책임

`rules/`는 “항상 적용되는 절차적 정책”을 담는다.

좋은 예:

- trigger 설계 기준
- resource placement 기준
- validation checklist
- anti-patterns
- provider-sensitive guidance를 언제 읽을지 결정하는 규칙

나쁜 예:

- 공식 문서 원문 복사
- core workflow와 같은 문장 반복
- 특정 한 task에만 필요한 긴 예시

## 5. References 책임

`references/`는 필요할 때 읽는 상세 지식이다.

좋은 예:

- OpenAI/Anthropic 공식 문서 요약
- API schema
- framework별 edge case
- long examples
- domain glossary

규칙:

- 각 reference는 한 주제에 집중한다.
- `SKILL.md`에서 “언제 읽을지”와 함께 링크한다.
- reference가 다시 다른 reference를 읽게 하는 깊은 체인은 피한다.

## 6. Scripts 책임

`scripts/`는 prose보다 코드가 더 안정적인 경우에만 둔다.

추가 기준:

- 같은 변환/검증을 반복한다.
- 명령 순서가 취약하다.
- structured output이 필요하다.
- 실패 메시지를 통해 agent가 self-correct할 수 있다.

필수 설명:

- 실행 방법
- dependency
- input/output
- failure mode
- version pinning 또는 환경 요구

## 7. Assets 책임

`assets/`는 산출물 생성에 필요한 복사/채움 대상이다.

예:

- report template
- schema JSON
- style guide sample
- prompt template
- fixture data

assets는 reasoning을 대체하지 않는다. 사용 조건과 채움 규칙을 `SKILL.md` 또는 `rules/`에 둔다.

## 8. Quality gate

- [ ] `SKILL.md`만 읽어도 목적·트리거·완료 조건을 이해할 수 있다.
- [ ] 상세 자료는 필요 시 로드하도록 분리되어 있다.
- [ ] support files는 직접 상대경로로 참조된다.
- [ ] scripts/assets는 존재 이유가 명확하다.
- [ ] 한국어 mirror가 필요한 파일은 구조적으로 동기화되어 있다.
