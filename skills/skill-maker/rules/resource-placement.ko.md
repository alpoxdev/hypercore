# 자원 배치

**목적**: 스킬 내용의 각 조각을 책임에 맞는 파일 유형에 배치합니다.

## 1. Placement Matrix

| 내용 | 위치 | 이유 |
|---|---|---|
| 언제 skill을 쓰는지 | `description`, routing rule | Discovery와 trigger signal |
| 일, boundary, top-level workflow, stop condition | `SKILL.md` | Activation 후 항상 필요 |
| 재사용 정책과 반복 판단 | `rules/` | 모든 run에 적용 |
| 공식 문서, schema, domain detail, long examples | `references/` | 필요할 때만 로드 |
| 결정적 validation 또는 transformation | `scripts/` | prose보다 더 reliable |
| templates, fixtures, static output resources | `assets/` | output에 복사, 채움, 삽입 |
| UI/runtime metadata | `agents/` | runtime이 소비할 때만 |

## 2. 판단 순서

다음 질문을 순서대로 봅니다.

1. 이것이 core identity, trigger, boundary, stop condition인가?
2. 이것이 재사용 정책 또는 반복 판단 가이드인가?
3. 필요할 때만 로드하는 상세 지식인가?
4. 결정적 실행이 더 나은가?
5. reasoning context보다 output resource에 가까운가?
6. runtime 또는 UI가 소비하는 platform metadata인가?

## 3. Rules vs References

`rules/`는 판단 기준에 사용합니다.

- scripts를 언제 추가할지
- trigger examples를 어떻게 검증할지
- source-sensitive claims를 어떻게 처리할지
- core와 references를 어떻게 나눌지

`references/`는 지식에 사용합니다.

- 공식 문서 요약
- API schemas
- long examples
- provider-specific edge cases
- domain glossary

## 4. Scripts

다음 중 하나 이상일 때만 scripts를 추가합니다.

- 같은 check 또는 transform을 자주 반복함
- command sequence가 fragile함
- machine-readable output이 필요함
- failure message가 agent self-correction에 도움됨
- version pinning 또는 parameter normalization이 reliability를 높임

모든 script에는 purpose, usage, dependencies, expected output, failure behavior를 문서화합니다.

## 5. Assets

Assets는 output generation을 지원하는 파일에 사용합니다.

- report templates
- prompt templates
- JSON schemas
- fixtures
- 복사하거나 채우는 examples

reasoning-only documentation에는 assets를 쓰지 않습니다.

## 6. Quality Gate

- [ ] 모든 support file에 placement reason이 있음.
- [ ] 모든 support file이 `SKILL.md` 또는 직접 연결된 rule에서 discoverable함.
- [ ] Scripts/assets에 usage와 validation note가 있음.
- [ ] Provider-sensitive content가 references로 격리됨.
- [ ] Core trigger logic이 references 안에 숨지 않음.
