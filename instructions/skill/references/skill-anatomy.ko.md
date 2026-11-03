# Skill Anatomy

> 영어판: [`skill-anatomy.md`](skill-anatomy.md)

Skill anatomy는 skill에 어떤 파일이 반드시 있어야 하는지보다, 각 파일이 어떤 책임을 지는지를 정의합니다.

## 1. 필수와 선택

| 요소 | 요구 | 책임 |
|---|---|---|
| `SKILL.md` | 필수 | Metadata, trigger, 핵심 실행 계약, workflow, validation |
| `SKILL.ko.md` | 권장 | 사용자에게 보이는 한국어 mirror |
| `rules/` | 조건부 | 반복 정책, 판단 규칙, checklist |
| `references/` | 조건부 | 공식 문서 요약, 상세 지식, edge case, 긴 예시 |
| `scripts/` | 조건부 | deterministic helper, validator, formatter, data transform |
| `assets/` | 조건부 | 템플릿, schema, 예시 산출물, static resource |
| `agents/` | 조건부 | 런타임 metadata. 예: Codex `agents/openai.yaml`(UI 문구, 호출 정책, 도구 의존성) |

## 2. Frontmatter

기본 frontmatter입니다.

```yaml
---
name: skill-name
description: Use this skill when the user asks to ...
compatibility: Optional runtime/dependency requirements.
---
```

### Spec 필드와 제약

Agent Skills specification 기준입니다(<https://agentskills.io/specification>, 확인 2026-11-03).

| 필드 | 필수 | 제약 |
|---|---|---|
| `name` | 필수 | 1~64자. 소문자 `a-z`, 숫자, 하이픈만. 앞뒤에 하이픈을 둘 수 없고 연속 하이픈(`--`)도 안 됩니다. **상위 디렉터리 이름과 일치해야 합니다** |
| `description` | 필수 | 1~1024자. 무엇을 하는지와 언제 쓰는지를 함께 담습니다 |
| `license` | 선택 | 라이선스 이름 또는 번들 라이선스 파일 참조. 짧게 유지합니다 |
| `compatibility` | 선택 | 값이 있을 때 1~500자. 대상 제품, 시스템 패키지, network 접근 같은 환경 요구가 있을 때만 씁니다 |
| `metadata` | 선택 | spec이 정의하지 않은 속성을 담는 문자열 key-value map. 충돌을 피하려면 key를 고유하게 유지합니다 |
| `allowed-tools` | 선택 | 미리 승인된 도구를 공백으로 이은 문자열. **Experimental이라 구현마다 지원이 다릅니다** |

목록은 이게 전부입니다. 필드 여섯 개 중 필수는 두 개입니다. Anthropic 플랫폼 문서는 spec 표에 명시되지 않은 제약을 두 가지 더 둡니다. `name`에는 XML 태그와 예약어 `anthropic`, `claude`를 쓸 수 없고, `description`에는 XML 태그를 쓸 수 없습니다(<https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview>, 확인 2026-11-03).

### 런타임 확장 필드

런타임은 spec보다 많은 필드를 받습니다. 아래 필드는 특정 제품에 대한 `VENDOR` 사실이므로, 그 필드가 없어도 skill이 동작해야 합니다([`../SKILL_AUTHORING.ko.md`](../SKILL_AUTHORING.ko.md)의 `SK-P-3` 참고).

| 런타임 | 필드 | 효과 |
|---|---|---|
| Claude Code | `when_to_use` | 목록에서 `description` 뒤에 붙고, 항목당 1,536자 제한에 포함됩니다 |
| Claude Code | `argument-hint`, `arguments` | 자동완성 힌트와 이름 있는 위치 인자 `$name` 치환 |
| Claude Code | `disable-model-invocation`, `user-invocable` | 자동 호출과 수동 호출을 각각 끕니다 |
| Claude Code | `allowed-tools`, `disallowed-tools` | skill이 활성인 동안 도구를 더하거나 뺍니다 |
| Claude Code | `model`, `effort`, `context`, `agent`, `background` | 해당 turn의 모델·effort를 덮어쓰고, `context: fork`는 subagent에서 실행합니다 |
| Claude Code | `hooks` | skill 호출 시 세션 종료까지 유지되는 hook을 등록합니다 |
| Claude Code | `paths`, `shell`, `metadata`, `license`, `compatibility` | 경로 glob 활성화 제한, inline shell 선택, 그리고 spec이 이미 정의한 필드 |
| Codex | `agents/openai.yaml`(frontmatter가 아닌 파일) | `interface` 문구와 아이콘, `policy.allow_implicit_invocation`, `dependencies.tools` |

이식 비용은 실제입니다. claude.ai 업로드와 Skills API는 spec의 여섯 필드 밖 필드를 **hard error로 거부**하므로, 런타임 확장을 담은 skill은 그대로 올릴 수 없습니다(<https://code.claude.com/docs/en/skills>, 확인 2026-11-03).

### Progressive disclosure 예산

단계별 예산은 [`progressive-disclosure.ko.md`](progressive-disclosure.ko.md) §1, `SKILL.md` 줄 수 한도와 저장소 gate는 §5, 런타임별 목록 예산은 §7에 있습니다. 이 절은 frontmatter와 파일 배치에 필요한 부분만 다시 적습니다.

- **Codex**는 초기 목록을 모델 컨텍스트의 2%, 컨텍스트 크기를 모를 때는 8,000자로 제한하고, `skills.max_context_tokens`로 최대 10,000토큰까지 올릴 수 있습니다. skill이 많으면 설명을 먼저 줄이고, **일부 skill을 초기 목록에서 통째로 생략하며 경고를 띄울 수 있습니다**(<https://learn.chatgpt.com/docs/build-skills>, 확인 2026-11-03). 핵심 트리거를 앞에 둡니다.
- **Claude Code**는 목록을 모델 컨텍스트의 1%로 잡고, 항목마다 `description`과 `when_to_use`를 합친 길이를 1,536자로 제한하며, 목록이 넘치면 호출 빈도가 낮은 skill부터 설명을 버립니다. `skillListingBudgetFraction`, `SLASH_COMMAND_TOOL_CHAR_BUDGET`, `skillListingMaxDescChars`가 이 예산을 바꿉니다(<https://code.claude.com/docs/en/skills>, 확인 2026-11-03).

두 런타임 모두 설명이 잘린 사실을 오류로 알리지 않습니다. 그래서 목록에는 있지만 키워드를 잃은 skill은 아예 매칭되지 않은 skill과 구별되지 않습니다.

**Codex 런타임 탐색 (2026-11-03 보고, `VENDOR`).** Codex는 현재 작업 디렉터리에서 저장소 루트까지의 모든 디렉터리에 있는 `.agents/skills`와 `$HOME/.agents/skills`(user), `/etc/codex/skills`(admin), 번들 system skill을 읽습니다. 같은 `name`의 skill 두 개는 **병합하지 않고** 둘 다 선택기에 나타날 수 있습니다. symlink skill 폴더는 대상까지 따라갑니다. `agents/openai.yaml`의 `policy.allow_implicit_invocation`을 `false`로 두면 암시 호출이 꺼져 `$skill` 명시 호출만 동작하고, `~/.codex/config.toml`의 `[[skills.config]]`는 절대 `path` 또는 `name`으로 skill을 끕니다. 이것들은 Codex의 동작이지 보편 규칙이 아닙니다.

### 규칙

- `name`은 소문자 kebab-case로 쓰고 **폴더 이름과 일치**시킵니다(권장이 아니라 spec 요구입니다).
- `description`은 트리거 문장입니다. 기능을 나열하는 것으로 끝내지 않습니다.
- `compatibility`는 런타임, network, 시스템 패키지, 도구 요구가 있을 때만 씁니다. 대부분의 skill에는 필요하지 않습니다.
- `allowed-tools`는 spec상 Experimental이므로 해당 런타임에서 지원을 확인한 뒤에만 쓰고, 공통 규칙으로 강제하지 않습니다. Claude Code의 승인은 다음 메시지를 보내면 풀립니다.
- 파일 참조는 skill root 기준 상대 경로로 쓰고 **한 단계 깊이**를 유지합니다. 깊게 중첩된 참조 사슬을 만들지 않습니다.
- 런타임 전용 필드는 이식 가능한 핵심에서 빼고, 쓰는 필드마다 어느 런타임의 것인지 밝힙니다.

### 검증 도구

공식 참조 구현이 frontmatter와 이름 규칙을 기계적으로 검증합니다.

```bash
skills-ref validate ./my-skill
```

이 저장소는 [`scripts/validate-skills.sh`](../../../scripts/validate-skills.sh)에서 `skills/**/SKILL.md` 전체에 `uvx`로 `skills-ref validate`를 실행합니다. Claude Code는 자기 트리 용도로 `claude plugin validate .claude/skills`를 따로 제공하며, frontmatter가 파싱되지 않는 `SKILL.md`를 보고합니다.

## 3. Core body의 책임

`SKILL.md`에는 다음만 둡니다.

1. 출력 언어·현지화 계약
2. 목적
3. 라우팅 규칙
4. 지시 계약
5. 활성화 예시
6. 상위 수준 workflow
7. 지원 파일 읽기 순서
8. 검증 checklist
9. 금지·필수 행동 요약

긴 API 설명, 많은 예시, 공식 문서 요약, 환경별 선택지는 core body에서 빼야 합니다. 본문은 한 번 로드되면 공짜가 아닙니다. Claude Code는 호출된 skill의 내용을 이후 turn에도 컨텍스트에 유지하고 파일을 다시 읽지 않으므로, 모든 줄이 반복 비용이고 가장 중요한 지시는 앞부분에 두어야 합니다(<https://code.claude.com/docs/en/skills>, 확인 2026-11-03).

## 4. Rule 파일의 책임

`rules/`는 "항상 적용되는 절차적 정책"을 담습니다.

좋은 예:

- 트리거 설계 기준
- 리소스 배치 기준
- 검증 checklist
- 안티패턴
- provider 민감 지침을 언제 읽을지 정하는 규칙

나쁜 예:

- 공식 문서의 그대로 붙여넣기
- core workflow와 같은 문장의 반복
- 특정 작업 하나에서만 쓰는 긴 예시

## 5. References의 책임

`references/`는 필요할 때 읽는 상세 지식을 담습니다.

좋은 예:

- OpenAI와 Anthropic 공식 문서 요약
- API schema
- 프레임워크별 edge case
- 긴 예시
- 도메인 용어집

규칙:

- 참조 파일 하나는 주제 하나에 집중합니다.
- `SKILL.md`에서 "언제 읽는지"와 함께 링크합니다.
- 참조 파일이 또 다른 참조로 이어지는 깊은 사슬을 피합니다.

## 6. Scripts의 책임

코드가 산문보다 신뢰할 만할 때만 `scripts/`를 둡니다.

추가 기준:

- 같은 변환이나 검증이 반복됩니다.
- 명령 순서가 깨지기 쉽습니다.
- 구조화된 출력이 필요합니다.
- 실패 메시지가 agent의 자기 수정에 도움이 됩니다.

필수 문서화:

- 실행 방법
- 의존성
- 입력과 출력
- 실패 양상
- 버전 고정 또는 환경 요구

## 7. Assets의 책임

`assets/`는 산출물을 만들 때 복사하거나 채우는 대상을 담습니다.

예:

- 보고서 템플릿
- Schema JSON
- 스타일 가이드 샘플
- 프롬프트 템플릿
- Fixture 데이터

Asset은 추론을 대신하지 않습니다. 사용 조건과 채우는 규칙은 `SKILL.md` 또는 `rules/`에 둡니다.

## 8. 품질 gate

- [ ] `SKILL.md`만 읽어도 목적, 트리거, 완료 조건을 알 수 있습니다.
- [ ] 상세 자료는 필요할 때 로드되도록 분리했습니다.
- [ ] 지원 파일을 상대 경로로 직접 참조합니다.
- [ ] 스크립트와 asset이 존재하는 이유가 분명합니다.
- [ ] 런타임 전용 필드마다 런타임을 밝혔고, 그 필드가 없어도 읽힙니다.
- [ ] 한국어 mirror가 필요한 파일의 구조가 동기화됐습니다.

## Sources

> 링크는 다시 읽고 확인 2026-11-03.

| 주장 | 출처 |
|---|---|
| Frontmatter 필드 표와 제약(`compatibility` 1~500자 범위 포함), 3단계 disclosure 모델 | <https://agentskills.io/specification> |
| 5,000토큰·500줄 지시 예산 | <https://agentskills.io/skill-creation/best-practices> |
| `name`·`description`의 예약어와 XML 태그 제한, metadata 약 100토큰, sandbox 제약 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| 컨텍스트 2%/8,000자 목록 예산, `skills.max_context_tokens`, `.agents/skills` 탐색, user/admin/system 범위, 같은 `name` 비병합, symlink 추적, `[[skills.config]]`, `agents/openai.yaml` | <https://learn.chatgpt.com/docs/build-skills> |
| 컨텍스트 1% 목록 예산, 항목당 1,536자 제한, frontmatter 확장 전체 목록, 비-spec 필드의 hard error, 컨텍스트 내 lifecycle, `claude plugin validate` | <https://code.claude.com/docs/en/skills> |

### 근거 등급

Frontmatter 제약은 specification이 직접 밝히므로 `PRIMARY`입니다. `compatibility`의 1~500자 범위는 이제 specification이 직접 밝히므로("Must be 1-500 characters if provided"), 하한이 출처에 없다는 이전 주석은 폐기했습니다. 런타임 확장 표와 탐색 동작은 제품별 `VENDOR` 주장이므로 그렇게 적었습니다.
