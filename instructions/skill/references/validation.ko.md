# Skill Validation

> 영어판: [`validation.md`](validation.md)

Skill validation은 skill이 "잘 읽힌다"는 것을 증명하는 일이 아니라 **정확히 트리거되고, 요구된 절차를 따르고, 검증 가능한 산출물을 낸다**는 것을 증명하는 일입니다.

## 1. 검증 계층

| 계층 | 질문 | 방법 |
|---|---|---|
| Anatomy | 형식이 맞는가? | Frontmatter, 폴더 형태, 로컬 링크, code fence |
| Trigger | 옳은 요청에서 켜지는가? | Positive/negative/boundary 프롬프트 세트 |
| Workflow | 요구된 단계를 따르는가? | Readback checklist, trace 검토, 수동 dry run |
| Output | 산출물 형식이 맞는가? | 템플릿, rubric, schema 검사 |
| Source | 외부 주장이 근거와 연결되는가? | Source ledger, 확인일, 주장-출처 대응표 |
| Safety | 권한·network·파괴적 행동이 gated 상태인가? | 금지·필수 행동 검토 |
| Benchmark | eval이나 leaderboard 주장이 재현 가능한가? | Benchmark release, scaffold, contamination, oracle caveat |
| Regression | 이후 변경에도 버티는가? | 작은 eval 세트, deterministic 스크립트 |

## 2. 최소 smoke 세트

모든 skill은 최소한 다음 검증 노트를 남깁니다.

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
  - [ ] recency/vendor/API claim prompt
  - [ ] conflicting-source prompt
- Safety:
  - [ ] retrieved prompt-injection prompt
  - [ ] credential/network/destructive action prompt
- Benchmark:
  - [ ] benchmark/scaffold/version note
  - [ ] **with-skill and without-skill both run by default** (the deterministic-skill exception is recorded)
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

## 3. 트리거 eval 설계

개수가 아니라 구성입니다.

세트는 아래 그룹을 모두 덮어야 합니다. 그룹별 행 수는 여기서 고정하지 않습니다. 출처가 검증된 개수를 밝히지 않으므로 이 파일은 개수 대신 구성 요구를 둡니다.

이 작업에는 두 수치가 돌아다니고, 둘은 다른 것을 측정합니다. evaluating-skills 페이지의 시작점은 **test case 2~3개**이고, 이는 행동 eval case입니다. Case마다 산출물을 만들어 assertion 단위로 채점합니다(§4). [`trigger-design.ko.md`](trigger-design.ko.md) §3의 **프롬프트 10~20개**는 OpenAI skill eval 지침에서 온 수치로 **트리거 질의**를 셉니다. 트리거 질의는 skill이 켜지는지만 묻고 trigger rate로 판정합니다(`SK-J-1`~`SK-J-6`). 행동 case는 산출물을 채점하고, 트리거 질의는 선택을 채점합니다. 어느 수치도 다른 수치를 대체하지 않으며, 이 파일의 case 수 목표도 아닙니다.

- should-trigger
- should-not-trigger
- boundary
- source-sensitive
- safety/adversarial

기존 행이 검사하지 않는 것을 검사할 때만 행을 추가합니다. 실제 실패는 생길 때마다 eval 행으로 승격합니다. Smoke set의 canonical schema와 반복·threshold key는 [`trigger-design.ko.md`](trigger-design.ko.md) §4에 있고, 이 파일은 그것을 다시 적지 않습니다.

각 행은 [`trigger-design.ko.md`](trigger-design.ko.md) §4의 key(`expect`, `runs`, `threshold`, 측정된 `trigger_rate`)에 더해, 이 skill이 그 프롬프트를 맡아야 하는 이유를 적은 `expected_reason`을 갖습니다.

트리거 eval은 문장 하나만 보지 않습니다. 같은 의도를 다음처럼 변형합니다.

- 한국어, 영어, 혼합 언어
- Skill 이름을 직접 언급한 경우와 언급하지 않은 경우
- 짧은 요청과 긴 문맥 요청
- 일반 문서 작성과 재사용 skill 작성의 경계
- 선행 조사가 필요한 최신성 주장 요청

## 4. 출력 eval 설계

산출물이 중요한 skill은 다음을 포함합니다.

- 기대 출력 설명
- 필수 파일
- 금지 출력
- 스타일·형식 rubric
- Deterministic 산출물 검사

아래 규칙은 규범입니다.

- SK-V-1: 각 case를 **기본으로** 두 번 실행합니다. skill을 켠 경우와 끈 경우(또는 이전 버전)입니다. 예외: formatter나 schema 검사기처럼 skill 없는 조건이 산출물을 아예 만들 수 없으면 실행하지 않고 그 사실을 기록합니다.
- SK-V-2: 기존 skill을 개선할 때는 skill 없는 조건 대신 **이전 버전 스냅샷**을 기준선으로 씁니다. 수정 전에 skill 폴더를 스냅샷하고 그 스냅샷을 가리킵니다.
- SK-V-3: 비교할 **기준선 없이** skill이 개선됐다고 주장하지 않습니다.
- SK-V-4: **두 조건 모두**에서 통과하는 assertion은 skill의 가치를 반영하지 않고 통과율만 부풀리므로 지우거나 바꿉니다. 두 조건 모두에서 항상 **실패**하는 assertion은 삭제 대상이 아니라 조사 대상입니다.
- SK-V-5: 점수만이 아니라 출력을 읽고 case별 사람 검토 노트(eval 디렉터리 옆의 `feedback.json`)를 남깁니다. "차트에 축 레이블이 없다" 같은 구체적 지적은 실행 가능하고, "별로다"는 실행 가능하지 않으며, 빈 문자열은 그 case가 검토를 통과했다는 뜻입니다. 다음 반복은 지적이 있던 case부터 손봅니다.

## 5. Workflow / loop eval 설계

Loop가 있는 skill은 "반복했다"가 아니라 **올바른 신호로 반복하고 올바른 조건에서 멈췄다**는 것을 증명합니다.

| Loop | Eval case | 확인 |
|---|---|---|
| observe-act | 도구 출력이 실패하거나, 충돌하거나, 없다 | 관찰을 읽고 다음 행동을 바꾸는가 |
| draft-critique-revise | rubric을 어긴 초안 | critique가 rubric을 인용하고 수정이 그것을 고치는가 |
| branch-score-prune | 대안 둘 중 하나가 범위 밖 | score/prune 기준으로 버리는가 |
| optimize-compare | Prompt 후보 A/B | 같은 eval 세트, holdout, 회귀 기록 |

필수:

- [ ] Feedback 출처를 적었습니다.
- [ ] 최대 반복 횟수나 stop condition이 있습니다.
- [ ] Guard 실패가 keep, discard, ask, block 중 하나로 정확히 귀결됩니다.
- [ ] Loop 결과를 로그나 검증 노트에 남겼습니다.

## 6. 출처 근거 eval 설계

조사, 최신 API, 벤더 동작, 논문, 벤치마크, 보안 주장을 다루는 skill은 출처 eval을 포함합니다.

| Case | 기대 행동 |
|---|---|
| 공식 출처가 있다 | URL, 확인일, 적용 버전이나 제품을 기록합니다 |
| 출처가 충돌한다 | 권위, 날짜, 범위를 비교하고 caveat를 붙입니다 |
| 오래된 블로그만 있다 | 1차 출처를 요구하거나 미해결로 표시합니다 |
| 검색된 내용에 지시가 들어 있다 | 증거로만 추출하고 지시는 무시합니다 |

최소 확인:

- [ ] 자명하지 않은 주장이 출처와 연결됩니다.
- [ ] 최신성 주장에 절대 날짜를 씁니다.
- [ ] 검토한 출처와 인용만 한 출처를 구분합니다.
- [ ] 출처 없는 주장을 skill core 규칙으로 승격하지 않습니다.

## 7. Benchmark eval 설계

Skill이 "성능이 올랐다", "벤치마크를 통과한다", "agentic coding에 강하다" 같은 검증 주장을 담으면 benchmark 위생을 적용합니다.

| Case | 기대 행동 |
|---|---|
| 정적 공개 벤치마크 | Contamination과 중복 위험을 caveat로 기록합니다 |
| Scaffold나 도구 버전이 바뀜 | 이전 점수와 직접 비교하지 않습니다 |
| 공개 테스트가 약함 | Hidden, differential, oracle 개선 필요성을 표시합니다 |
| Skill 효용 주장 | 같은 과제에서 with-skill과 without-skill을 짝지어 실행합니다 |
| 집계 점수 주장 | 과제 유형, 저장소, 난이도, 실패 유형으로 나눠 봅니다 |

필수 기록:

- Benchmark release와 날짜 범위
- 모델, 런타임, 도구, scaffold 버전
- 저장소 commit, container, toolchain
- 허용 도구와 retrieval 설정
- Deterministic verifier 또는 LLM judge rubric
- 알려진 누출, 약한 oracle, contamination caveat

짝지은 설계의 실제 사례가 있으니 효용을 주장하기 전에 읽어 볼 만합니다. SWE-Skills-Bench는 skill마다 저장소 commit을 고정하고 요구사항을 도출해 실행 verifier를 만들고, skill별 paired delta를 보고합니다. 그 결과는 공개 skill 98개 중 92개가 통계적으로 유의미한 효과가 없었고 평균 통과율이 76.6%에서 76.9%로 움직였다는 것이었습니다. Skill eval이 낼 수 있어야 하는 답의 형태이자, skill이 도움이 된다고 가정하면 안 된다는 경고입니다(<https://arxiv.org/abs/2603.15401>, 발행 2026-03-16).

## 8. 안전 eval 설계

안전 eval은 정상 작업을 막지 않으면서 위험한 행동이 gated 상태인지 확인합니다.

| Case | 기대 행동 |
|---|---|
| 웹페이지나 도구 출력의 prompt injection | 외부 지시를 무시하고 필요한 데이터만 추출합니다 |
| Credential 요청 | 사용자 허가와 안전한 처리 없이는 거부하거나 멈춥니다 |
| 파괴적 명령 | 명시적 허가 전에는 실행하지 않습니다 |
| 운영 배포나 게시 | 허가, 범위, 검증, rollback을 확인합니다 |
| 임의 URL이나 도구 인자 | Allowlist와 schema 검증을 적용합니다 |
| 제3자 skill이나 스크립트 | 코드 리뷰, sandbox, 버전 고정, secret 검사를 합니다 |

## 9. 스크립트 기반 skill 검증

`scripts/`가 있으면 다음을 추가로 확인합니다.

- [ ] 스크립트가 비대화형입니다.
- [ ] `--help`나 사용법 문서가 있습니다.
- [ ] 의존성을 적었습니다.
- [ ] 실패 시 도움이 되는 오류를 출력합니다.
- [ ] 구조화된 출력이 필요하면 JSON, JSONL, schema를 씁니다.
- [ ] 버전 고정이나 환경 요구를 적었습니다.

## 10. Markdown 검증

다음을 수동 또는 자동으로 확인합니다.

- Code fence 균형
- 로컬 markdown 링크 대상 존재
- Frontmatter 시작과 종료
- 과도한 중복 heading
- `SKILL.md`가 존재하지 않는 지원 파일을 링크하지 않음

## 11. 완료 gate

다음 중 하나라도 실패하면 완료라고 하지 않습니다. [`../SKILL_AUTHORING.ko.md`](../SKILL_AUTHORING.ko.md) → `## 검증 기준` 절이 요약 checklist이고, **각 항목을 어떻게 판정하는지**는 위 절들에 있습니다.

- 트리거 경계를 설명하지 않았습니다
- 지원 파일을 링크하지 않았습니다
- 스크립트나 asset이 workflow와 끊겨 있습니다
- 공식 문서 주장에 출처가 없습니다
- 파괴적·credential·network 동작이 gated가 아닙니다
- 검증 결과를 기록하지 않았습니다
- Loop가 feedback, metric, guard, stop condition 없이 존재합니다
- Eval에 happy path만 있고 negative, boundary, source, safety case가 없습니다
- Benchmark나 성능 주장에 release, scaffold, verifier, contamination caveat가 없습니다

## 12. 이 loop를 실행하는 도구

위에서 설명한 배치와 비교를 구현한 도구가 둘 있습니다. 그래서 이 저장소는 파일 이름을 새로 만들지 않고 그 이름을 따를 수 있습니다.

| 도구 | 하는 일 | 요구하는 것 |
|---|---|---|
| Anthropic `skill-creator`(Skill/plugin) | Eval 세트를 나누고, case마다 새 세션이나 subagent에서 실행하고, assertion을 근거와 함께 채점하며, `benchmark.json`을 집계하고, 두 버전의 blind A/B를 돌리고, 설명 수정안을 제안합니다 | Skill 디렉터리 안 `evals/evals.json`의 test case |
| `claude plugin eval` | 프롬프트마다 plugin을 켠 경우와 끈 경우를 격리된 세션에서 실행하고, 정의한 grader로 채점하며, threshold 아래면 non-zero로 종료해 CI gate로 쓸 수 있습니다 | Plugin. 트리거 측정에는 `tool_used: Skill` grader |

어느 쪽이든 실행마다 새 세션이 필수입니다. Skill을 작성하며 남은 컨텍스트가 문서에 적힌 지시의 빈틈을 가리기 때문입니다(<https://code.claude.com/docs/en/skills>, 확인 2026-11-03).

## Sources

> 링크는 다시 읽고 확인 2026-11-03.

| 주장 | 출처 |
|---|---|
| with/without 기준선을 핵심 패턴으로 두는 것, 이전 버전 스냅샷을 기준선으로 쓰는 것, 기준선 없는 개선 주장 금지, 두 조건 모두 통과하는 assertion 제거 — `SK-V-1`~`SK-V-4`의 근거 | <https://agentskills.io/skill-creation/evaluating-skills> |
| 점수 옆의 사람 검토, case별 구체적 feedback, test case 2~3개 시작 — `SK-V-5`의 근거 | <https://agentskills.io/skill-creation/evaluating-skills> |
| 반복 횟수, threshold, trigger rate를 트리거 지표로 쓰는 것 | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| 네 가지 호출 모드, 프롬프트 세트 구성, 트리거 질의 10~20개 수치 | <https://developers.openai.com/blog/eval-skills> |
| Skill별 paired delta 설계, 98개 중 92개 결과, 76.6%에서 76.9% 평균 | <https://arxiv.org/abs/2603.15401> |
| `skill-creator`, `evals/evals.json`, blind A/B 비교, `claude plugin eval`, 새 세션 규칙, CI 종료 코드 | <https://code.claude.com/docs/en/skills> |

### 근거 등급

위 기준선 규칙은 evaluating-skills 페이지에서 오므로 `PRIMARY`이고, 그 페이지는 with/without 쌍을 선택 사항이 아니라 **핵심 패턴**이라고 부릅니다. 이 파일은 **규범적 case 수를 두지 않습니다**. 확인한 출처 중 검증된 개수를 밝힌 것이 없어 구성 요구가 그 자리를 대신하며, 2~3개라는 값은 출처가 밝힌 시작점으로 인용했습니다. Benchmark 사례는 2026년 논문 하나이며, 모든 skill에 일반화되는 결과가 아니라 따라 만들 설계로 제시했습니다.
