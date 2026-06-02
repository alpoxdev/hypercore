# Skill Validation

Skill validation은 “잘 읽힌다”가 아니라 “정확히 트리거되고, 필요한 절차를 따르고, 산출물이 검증 가능하다”를 증명하는 과정이다.

## 1. 검증 계층

| 계층 | 질문 | 방법 |
|---|---|---|
| Anatomy | 형식이 맞는가? | frontmatter, folder shape, local links, code fences |
| Trigger | 맞는 요청에서 켜지는가? | positive/negative/boundary prompt set |
| Workflow | 필요한 단계를 따르는가? | readback checklist, trace review, manual dry run |
| Output | 산출물 형식이 맞는가? | template/rubric/schema check |
| Safety | 권한·네트워크·파괴적 행동이 gated인가? | forbidden/required behavior review |
| Regression | 나중에 바꿔도 유지되는가? | small eval set, deterministic scripts |

## 2. 최소 smoke set

모든 skill은 최소 다음 검증 노트를 남긴다.

```markdown
## Validation notes

- Trigger positives:
  - [ ] prompt 1
  - [ ] prompt 2
  - [ ] prompt 3
- Trigger negatives:
  - [ ] prompt 1
  - [ ] prompt 2
- Boundary:
  - [ ] prompt 1
- Anatomy:
  - [ ] frontmatter present
  - [ ] support files linked
  - [ ] no broken local links
  - [ ] code fences balanced
- Workflow:
  - [ ] purpose/scope/authority/output/verification discoverable
- Risks:
  - ...
```

## 3. Trigger eval 설계

권장 세트:

- should-trigger 8~10개
- should-not-trigger 8~10개
- boundary 2~4개

초기에는 6개 smoke set으로 시작해도 된다. 실제 실패가 생길 때마다 eval row로 승격한다.

각 row에는 다음을 둔다.

```json
{
  "id": "skill-trigger-001",
  "prompt": "실제 사용자가 입력할 문장",
  "should_trigger": true,
  "expected_reason": "왜 이 skill이어야 하는지"
}
```

## 4. Output eval 설계

산출물이 중요한 skill은 다음을 포함한다.

- expected output description
- required files
- forbidden output
- style/format rubric
- deterministic artifact check
- with-skill vs without-skill baseline이 필요한지 여부

## 5. Script-backed skill 검증

`scripts/`가 있으면 추가 확인한다.

- [ ] script가 non-interactive하다.
- [ ] `--help` 또는 usage 설명이 있다.
- [ ] dependency가 명시되어 있다.
- [ ] 실패 시 helpful error를 출력한다.
- [ ] structured output이 필요하면 JSON/JSONL/schema를 쓴다.
- [ ] version pinning 또는 환경 요구가 명시되어 있다.

## 6. Markdown 검증

수동 또는 자동으로 다음을 확인한다.

- code fence balance
- local markdown link target 존재
- frontmatter 시작/종료
- duplicate headings 과다 여부
- `SKILL.md`에서 존재하지 않는 support file을 링크하지 않는지

## 7. Completion gate

다음 중 하나라도 실패하면 완료라고 말하지 않는다.

- trigger boundary가 설명되지 않음
- support files가 연결되지 않음
- scripts/assets가 workflow와 분리되어 있음
- 공식 문서 claim에 source가 없음
- destructive/credential/network behavior가 gated되지 않음
- 검증 결과가 기록되지 않음
