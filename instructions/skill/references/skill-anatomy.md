# Skill Anatomy

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

규칙:

- `name`은 lowercase kebab-case로 쓴다.
- `name`은 가능하면 폴더명과 일치시킨다.
- `description`은 trigger 문장이다. 기능 목록만 나열하지 않는다.
- `compatibility`는 런타임, 네트워크, 시스템 패키지, tool 요구가 있을 때만 쓴다.
- `allowed-tools` 같은 implementation-specific field는 해당 런타임에서 지원할 때만 사용하고, 공통 규칙으로 강제하지 않는다.

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
