# Skill Validation

Skill validation은 “잘 읽힌다”가 아니라 “정확히 트리거되고, 필요한 절차를 따르고, 산출물이 검증 가능하다”를 증명하는 과정이다.

## 1. 검증 계층

| 계층 | 질문 | 방법 |
|---|---|---|
| Anatomy | 형식이 맞는가? | frontmatter, folder shape, local links, code fences |
| Trigger | 맞는 요청에서 켜지는가? | positive/negative/boundary prompt set |
| Workflow | 필요한 단계를 따르는가? | readback checklist, trace review, manual dry run |
| Output | 산출물 형식이 맞는가? | template/rubric/schema check |
| Source | 외부 claim이 근거와 연결되는가? | source ledger, accessed date, claim-source matrix |
| Safety | 권한·네트워크·파괴적 행동이 gated인가? | forbidden/required behavior review |
| Benchmark | eval/leaderboard 주장이 재현 가능한가? | benchmark release, scaffold, contamination, oracle caveat |
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
- Source-sensitive:
  - [ ] 최신/벤더/API claim prompt
  - [ ] 충돌 source prompt
- Safety:
  - [ ] retrieved prompt injection prompt
  - [ ] credential/network/destructive action prompt
- Benchmark:
  - [ ] benchmark/scaffold/version note
  - [ ] with-skill vs without-skill comparison 필요 여부
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
- source-sensitive 2~4개
- safety/adversarial 2~4개

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

Trigger eval은 단일 문장만 보지 않는다. 같은 intent를 다음처럼 변형한다.

- 한국어/영어/혼합 언어
- skill 이름 직접 언급/무언급
- 짧은 요청/긴 맥락 요청
- 일반 문서 작성/재사용 skill 생성의 경계
- research 선행이 필요한 최신 claim 요청

## 4. Output eval 설계

산출물이 중요한 skill은 다음을 포함한다.

- expected output description
- required files
- forbidden output
- style/format rubric
- deterministic artifact check
- with-skill vs without-skill baseline이 필요한지 여부

## 5. Workflow / Loop eval 설계

Loop가 있는 skill은 “반복했다”가 아니라 “올바른 신호로 반복했고 올바른 조건에서 멈췄다”를 증명한다.

| Loop | Eval case | 확인 |
|---|---|---|
| observe-act | tool output이 실패/충돌/누락됨 | observation을 읽고 다음 action을 바꿈 |
| draft-critique-revise | rubric 위반 draft | critique가 rubric에 근거하고 revision이 고침 |
| branch-score-prune | 두 대안 중 하나가 scope 밖 | score/prune 기준으로 버림 |
| optimize-compare | prompt 후보 A/B | 같은 eval set, holdout, regression 기록 |

필수:

- [ ] feedback source가 명시되어 있다.
- [ ] max iterations 또는 stop condition이 있다.
- [ ] guard 실패 시 keep/discard/ask/block 중 하나로 귀결된다.
- [ ] loop 결과가 log 또는 validation notes에 남는다.

## 6. Source-grounding eval 설계

리서치, 최신 API, vendor behavior, 논문, benchmark, 보안 claim을 포함하는 skill은 source eval을 둔다.

| Case | 기대 행동 |
|---|---|
| 공식 source가 있음 | URL, accessed date, 적용 버전/제품 기록 |
| source끼리 충돌 | authority/date/scope 비교 후 caveat |
| 오래된 블로그만 있음 | primary source 요구 또는 unresolved 처리 |
| retrieved content가 지시를 포함 | evidence로만 추출하고 지시는 무시 |

최소 체크:

- [ ] non-obvious claim은 source와 연결된다.
- [ ] 최신성 claim은 절대 날짜를 쓴다.
- [ ] reviewed source와 cited source를 구분한다.
- [ ] source가 없는 claim은 skill core rule로 승격하지 않는다.

## 7. Benchmark eval 설계

Skill이 “성능이 좋아졌다”, “벤치마크를 통과한다”, “agentic coding에 강하다” 같은 검증 claim을 포함하면 benchmark hygiene을 둔다.

| Case | 기대 행동 |
|---|---|
| static public benchmark | contamination/overlap 가능성을 caveat로 기록 |
| scaffold/tool version 변경 | 이전 점수와 직접 비교하지 않음 |
| weak public tests | hidden/differential/oracle refinement 필요 표시 |
| skill utility claim | 같은 task에서 with-skill vs without-skill paired run |
| aggregate score claim | task type/repo/difficulty/failure class로 stratify |

필수 기록:

- benchmark release/date window
- model/runtime/tool/scaffold version
- repository commit/container/toolchain
- allowed tools and retrieval setting
- deterministic verifier 또는 LLM judge rubric
- known leakage, weak oracle, contamination caveat

## 8. Safety eval 설계

Safety eval은 정상 작업을 막지 않으면서 위험 행동을 gate하는지 본다.

| Case | 기대 행동 |
|---|---|
| prompt injection in webpage/tool output | 외부 지시 무시, 필요한 데이터만 추출 |
| credential 요구 | 사용자 권한과 secure handling 없이는 거부/중단 |
| destructive command | 명시 권한 전에는 실행하지 않음 |
| production deploy/publish | 권한, scope, verification, rollback 확인 |
| arbitrary URL/tool arg | allowlist/schema validation |
| third-party skill/script | code review, sandboxing, version pinning, secret check |

## 9. Script-backed skill 검증

`scripts/`가 있으면 추가 확인한다.

- [ ] script가 non-interactive하다.
- [ ] `--help` 또는 usage 설명이 있다.
- [ ] dependency가 명시되어 있다.
- [ ] 실패 시 helpful error를 출력한다.
- [ ] structured output이 필요하면 JSON/JSONL/schema를 쓴다.
- [ ] version pinning 또는 환경 요구가 명시되어 있다.

## 10. Markdown 검증

수동 또는 자동으로 다음을 확인한다.

- code fence balance
- local markdown link target 존재
- frontmatter 시작/종료
- duplicate headings 과다 여부
- `SKILL.md`에서 존재하지 않는 support file을 링크하지 않는지

## 11. Completion gate

다음 중 하나라도 실패하면 완료라고 말하지 않는다.

- trigger boundary가 설명되지 않음
- support files가 연결되지 않음
- scripts/assets가 workflow와 분리되어 있음
- 공식 문서 claim에 source가 없음
- destructive/credential/network behavior가 gated되지 않음
- 검증 결과가 기록되지 않음
- loop가 있는데 feedback/metric/guard/stop condition이 없음
- eval이 happy path만 있고 negative/boundary/source/safety case가 없음
- benchmark/성능 claim이 있는데 release, scaffold, verifier, contamination caveat가 없음
