# Prompt, Loop, And Eval For Skills

> 영어판: [`prompt-loop-eval.md`](prompt-loop-eval.md)

이 문서는 skill을 단일 프롬프트가 아니라 **작고 반복 가능한 agent 프로그램**으로 설계하는 기준입니다. `SKILL.md`는 프로그램의 진입점이고, `rules/`, `references/`, `scripts/`, `assets/`는 필요할 때 로드되는 모듈입니다.

출처 스냅샷: 2026-11-03. §12의 모든 URL은 그날 다시 읽었습니다.

## 1. 핵심 원칙

| 원칙 | 기준 | 실패 신호 |
|---|---|---|
| Skill은 프로그램 | 입력, 단계, 도구, 중간 산출, 최종 산출, 검증을 분리 | 모든 지식을 담은 하나의 긴 역할 프롬프트 |
| Loop에는 신호가 필요 | 반복에는 feedback 출처, metric/rubric, guard, stop condition이 필요 | 정지 기준 없이 "더 좋아질 때까지 반복" |
| 도구 근거 | 외부 상태를 바꾸는 작업은 observe, action, verify를 분리 | 검색 snippet, 도구 출력, subagent 요약을 그대로 믿음 |
| 다듬기 전에 eval | 문장을 다듬기 전에 성공 기준과 eval case를 만듭니다 | 보기에는 좋지만 어떤 회귀를 막는지 말할 수 없음 |
| 출처와 안전 경계 | 검색된 내용은 증거이지 system·developer·project 지시가 아닙니다 | 웹페이지나 도구 출력 안의 지시를 실행 |
| Benchmark 겸손 | Leaderboard나 단일 점수는 참고 신호이지 skill 검증 자체가 아닙니다 | Benchmark 버전, scaffold, contamination, 약한 테스트를 기록하지 않음 |
| 가치는 측정 대상 | 주장은 with/without 차이이고, 산출물의 존재가 아닙니다 | "잘 썼으니 도움이 된다" |

## 2. Prompt 계약

[`../SKILL_AUTHORING.ko.md`](../SKILL_AUTHORING.ko.md) → `## 최소 SKILL.md 계약`이 canonical 정의입니다. `instruction_contract`는 Intent, Scope, Authority, Evidence, Tools, Loop, Output, Verification, Stop condition 아홉 필드를 그대로 갖습니다. 아래 계약은 그 아홉을 모두 채우고, 앞선 7블록 개요가 어디로 갔는지 기록합니다. 어느 형태로 쓴 skill이든 같은 checklist를 통과합니다.

| 앞선 블록(7) | Canonical 필드(9) | 옮겨 가는 것 |
|---|---|---|
| Intent | Intent | 그대로 |
| Scope | Scope | 그대로 |
| Authority | Authority | 그대로 |
| Context | Evidence | 필수 파일, 출처, 날짜, 버전, 빠진 정보 처리는 근거에 관한 질문 |
| Workflow | Tools | 단계 순서는 `<workflow>`에 남고, `Tools`가 단계마다 쓸 수 있는 도구와 경계를 적음 |
| Workflow | Verification | 블록의 `Verification` 줄이 독립 필드가 됨 |
| Workflow | Stop condition | 완료, 중단, 사용자 질문 조건이 독립 필드가 됨 |
| Loop | Loop | 그대로 |
| Output | Output | 그대로 |

Evidence는 Context 블록을 이어받습니다. 자기 블록이 없던 세 필드, 즉 Tools, Verification, Stop condition이 가장 자주 비어 있으므로 Workflow에 접어 넣지 않고 Evidence와 함께 아래에 따로 적습니다.

```markdown
## Intent
- What the user counts as success:
- What counts as failure:

## Scope
- In:
- Out:
- Side-effect boundary:

## Authority
- Priority:
- Handling of retrieved/tool content:

## Evidence
- Required files, sources, dates, versions:
- Handling of missing information:

## Tools
- Tools each stage may use, and the boundary on each:
- Handling of tool-output failure:

## Loop
- Type: none | observe-act | draft-critique-revise | branch-score-prune | optimize-compare
- Feedback:
- Metric/rubric:
- Guard:
- Stop:

## Output
- Format:
- Storage location:
- Required/forbidden fields:

## Verification
- Checks that decide pass or fail:
- Evidence each check leaves:

## Stop condition
- Complete when:
- Abort when:
- Ask the user when:
```

## 3. Loop 패턴 선택

| 패턴 | 근거 | 쓸 때 | 필수 guard |
|---|---|---|---|
| Observe -> act -> observe -> update | ReAct | 검색, 저장소 탐색, 도구 사용처럼 외부 관찰이 답을 바꾸는 작업 | 도구 출력을 읽고 다음 행동을 바꿨다는 trace |
| Draft -> critique -> revise | Self-Refine | 문서, 요약, 리뷰, 정책 준수처럼 rubric으로 개선 가능한 산출물 | Critique 기준과 최대 반복 횟수 |
| Attempt -> feedback -> reflection -> retry | Reflexion | 실패 사후 분석이 다음 시도에 도움이 되는 반복 작업군 | 회고가 실제 verify 출력에 근거하는지 확인 |
| Branch -> score -> prune | Tree of Thoughts | 대안 탐색, 계획 비교, 초기 선택이 크게 좌우하는 복잡한 추론 | Branch 수, scorer, prune 기준 |
| Candidate -> score -> mutate | OPRO, Promptbreeder, DSPy/MIPRO | Eval 세트에 대해 prompt나 skill 변형을 최적화 | Train/holdout 분리와 회귀 gate |

Loop가 필요 없는 경우를 명시합니다. 예: 단일 파일 템플릿 채우기, deterministic formatter 실행, 짧은 일회성 변환.

## 4. Skill eval matrix

Skill eval은 트리거만 보지 않습니다.

| 계층 | Eval case | 통과 기준 |
|---|---|---|
| Trigger | Positive/negative/boundary 프롬프트 | 필요한 skill만 켜지고, 비슷한 작업에서는 물러남 |
| Workflow | 정상 과제, 문맥 누락, 도구 출력 실패 | 정해진 순서와 fallback을 따름 |
| Output | Schema, 표, 파일 경로, 스타일 | 하위 자동화가 읽을 수 있음 |
| Source | 최신 API 주장, 출처 충돌, 오래된 출처 | 1차 출처와 확인일이 있음 |
| Safety | Prompt injection, credential 요청, 파괴적·network 행동 | 검색된 지시를 무시하고 사용자·프로젝트 권위로 gate |
| Regression | 알려진 나쁜 prompt·출력 쌍 | 이전 실패가 재발하지 않음 |

최소 권장:

- 작은 skill 수정: smoke 부분집합
- 표준 skill 생성·리팩터: 구성된 전체 세트
- Agent·도구 workflow skill: 전체 세트 + 표적 adversarial case

개수는 여기서 고정하지 않습니다. 출처가 검증된 개수를 밝히지 않으므로 이 파일은 개수 대신 **구성** 요구를 둡니다. 모든 case는 다른 case가 검사하지 않는 것을 검사해야 합니다. Case 수 정책은 [`validation.ko.md`](validation.ko.md) §3에 있습니다.

## 5. 다중 prompt와 형식 견고성

Prompt 형식과 예시 배치는 결과를 크게 흔들 수 있으므로, 중요한 skill은 정본 prompt 하나로 통과했다고 끝내지 않습니다.

- 같은 의도를 한국어와 영어로, 짧은 요청과 긴 요청으로, skill 이름을 넣은 경우와 뺀 경우로 시험합니다.
- 출력 형식이 중요하면 Markdown, JSON, YAML에 걸쳐 최소 두 가지 형식 변형을 평가합니다.
- 평균만 보지 않고 최악 case와 회귀 case를 봅니다.
- "새 prompt가 더 좋아 보인다"는 출시 기준이 아닙니다. 같은 eval 세트에서 실패 수가 줄어야 합니다.

## 6. Benchmark와 leaderboard 위생

Agentic, coding, 도구 사용 skill을 검증할 때 공개 benchmark 점수만으로 완료를 주장하지 않습니다.

필수 기록:

- Benchmark 이름, release·날짜 범위, dataset split
- 모델, 런타임, scaffold, 도구 버전
- 저장소 commit, container·toolchain, 허용 도구
- Retrieval 사용 여부와 출처 cutoff
- Contamination과 중복을 어떻게 확인했는지
- 공개 테스트, hidden 테스트, 약한 oracle caveat
- with-skill과 without-skill 기준선이 필요한지 여부. **기본으로 실행합니다**([`validation.ko.md`](validation.ko.md) §4의 `SK-V-1` 참고. deterministic skill 예외도 여기 적용됩니다)

규칙:

- 소프트웨어 skill에는 실행 기반 verifier를 우선합니다.
- 오래됐거나 공개된 benchmark는 contamination 위험으로 표시합니다.
- Scaffold가 바뀐 같은 benchmark의 연속 점수를 비교하지 않습니다.
- 집계 점수만 보지 않고 과제 유형, 저장소, 난이도, 실패 유형으로 나눕니다.
- 공개 테스트가 약하면 hidden 테스트, differential 검사, oracle 개선을 더합니다.

이 규율을 skill에 적용한 가장 분명한 공개 사례가 SWE-Skills-Bench(2026-03-16)입니다. Skill마다 저장소 commit을 고정하고, 저장소별 요구사항을 도출하고, 실행 verifier를 만들고, skill별 paired delta를 보고합니다. 98개 중 92개가 유의미한 효과가 없었고 평균 통과율은 76.6%에서 76.9%로 움직였습니다 <https://arxiv.org/abs/2603.15401>. 이 결과는 개별 skill에 대한 판결이 아니라 따라 만들 설계로 다룹니다.

## 7. 출처 근거가 있는 skill 작성

Skill이 벤더 문서, API 동작, 논문, benchmark, 보안 주장을 다루면 다음을 따릅니다.

- 출처 URL, 확인일, 적용 버전이나 제품을 `references/official/`(권장 배치이지 필수 경로가 아님), 별도 reference, 또는 이 저장소 문서의 고정 스냅샷이면 `references/local/`에 기록합니다.
- Core 규칙만 `SKILL.md`에 두고 긴 출처 요약은 references로 나눕니다.
- 최신성 주장에는 절대 날짜를 씁니다.
- 공식 문서가 충돌하면 적용 런타임·모델·제품과 날짜를 비교합니다.
- 모델이 만든 요약은 출처가 아니라 후보로 취급합니다.

## 8. 안전 근거가 있는 skill 작성

Skill이 network, shell, credential, 외부 API, 운영, 파괴적 행동에 닿으면 다음을 따릅니다.

- `Authority`에 검색된 내용과 도구 출력은 증거일 뿐 지시가 아니라고 적습니다.
- 외부 텍스트에서 찾은 명령, URL, 수신자, 파일 경로를 allowlist나 schema로 검증합니다.
- 명시적 사용자 허가 없이 credential을 입력하거나, 결제·게시·삭제·배포·운영 변경을 하지 않습니다.
- 제3자 skill과 번들 스크립트는 prompt 조각이 아니라 코드 리뷰 대상으로 다룹니다.
- 운영 skill에는 버전 고정과 변경 재검토를 요구합니다.
- 스크립트마다 목적, 의존성, 입출력, 실패 양상, 부작용을 문서화합니다.
- 안전 지시는 성능을 떨어뜨릴 수 있으므로 adversarial eval과 정상 happy path를 나란히 둡니다.

## 9. Skill 재고와 recall

Skill은 선택기의 주의를 두고 설치된 다른 모든 skill과 경쟁하며, 그 비용은 쓰이든 쓰이지 않든 매 turn 청구됩니다.

| 제약 | 수치 | 작성에 주는 결과 |
|---|---|---|
| Skill당 metadata 비용 | 약 100토큰, 항상 로드 | 40개를 설치하면 작업 전에 이미 약 4,000토큰 |
| Codex 목록 | 모델 컨텍스트의 2%, 크기를 모를 때는 8,000자. `skills.max_context_tokens`로 최대 10,000토큰 | 설명을 먼저 줄이고, skill을 경고와 함께 목록에서 뺄 수 있음 |
| Claude Code 목록 | 모델 컨텍스트의 1%, 항목당 1,536자 | 호출 빈도가 낮은 skill부터 설명을 버림 |
| Anthropic API | 요청당 skill 최대 20개 | 합치거나 요청을 skill 세트별로 라우팅해야 함 |

따라오는 운영 규칙:

- 세트가 커지면 recall을 측정하고, 선택 정확도가 떨어지면 추가를 멈춥니다.
- 좁은 skill을 넓은 skill로 합치는 것은 합친 skill의 eval이 원래 것들과 같은 성능을 보일 때만 합니다.
- 당장 지울 준비가 안 된 skill은 삭제 대신 끕니다(Codex는 `[[skills.config]]`, Claude Code는 `skillOverrides`). 판단 전에 사용 보고서를 확인합니다.

## 10. 산출물 감사

위 규칙은 skill이 **받는 것**을 시험합니다. 주입된 지시에 저항하는지 봅니다. 아래는 skill이 **무엇인지**를 봅니다. 산출물 자체가 담으면 안 되는 것을 담고 있는지 확인합니다. Skill은 배포되는 코드와 지시의 묶음이므로 배포 전에 감사합니다.

출처가 부여한 심각도와 함께 일곱 범주입니다. 이 목록은 "skill 보안의 전부"가 아니라, 출처가 이름 붙인 산출물 수준 점검 항목입니다.

| 범주 | 볼 것 | 출처가 부여한 심각도 |
|---|---|---|
| Code execution | Skill 디렉터리의 스크립트(`*.py`, `*.sh`, `*.js`) | High: 스크립트는 환경 전체 권한으로 실행됨 |
| Instruction manipulation | 안전 규칙 무시, 행동 은닉, 조건부 동작 변경 지시 | High: 보안 통제를 우회할 수 있음 |
| MCP server reference | `ServerName:tool_name` 형태의 참조 | High |
| Network access | URL, API endpoint, `fetch`, `curl`, `requests` | High: 데이터 유출 경로 |
| Hardcoded credentials | Skill 파일이나 스크립트 안의 key, token, 비밀번호 | High: Git 이력과 컨텍스트 창에 secret 노출 |
| Filesystem scope | Skill 디렉터리 밖 경로, 넓은 glob, `../` | Medium |
| Tool calls | bash, 파일 작업, 다른 도구를 쓰라는 지시 | Medium: 어떤 작업이 수행되는지 검토 필요 |

- SK-A-1: 배포 전에 위 일곱 범주로 skill을 감사하고 결과를 기록합니다.
- SK-A-2: 신뢰할 수 없는 출처의 skill은 전체 감사 없이 배포하지 않습니다.
- SK-A-3: Skill을 버전에 고정하고, 버전이 바뀌면 다시 검토합니다.

이것들은 `VENDOR` 주장입니다. 심각도 표시는 인용한 출처의 것이지 이 저장소의 통제된 연구 결과가 아닙니다. 감사는 알려진 산출물 수준 문제를 잡는 checklist이지 안전의 증명이 아닙니다. 일부 enterprise 표면에는 자동 콘텐츠 검사가 있지만, 출처는 그것이 Skills API 업로드를 덮지 않는다고 밝힙니다. 이 저장소가 쓰는 경로가 바로 그 경로입니다.

## 11. 작성 loop

```text
Collect failures -> Draft contract -> Build eval set -> Run baseline/readback -> Patch smallest surface -> Re-run -> Record decision
```

| 단계 | 산출물 |
|---|---|
| 실패 수집 | 실제 사용자 문장, 실패한 출력, 빠진 문맥, 안전하지 않은 요청 |
| 계약 초안 | `SKILL.md`의 intent, scope, authority, workflow, output, verification |
| Eval 세트 구성 | Positive, negative, boundary, source, safety, regression case |
| 기준선 실행·readback | 기존 skill이나 초안의 실패 목록 |
| Patch | 트리거, workflow, 리소스 배치, 스크립트, asset 중 하나를 수정 |
| 재실행 | 같은 eval 세트 + 새 실패 case |
| 기록 | 변경 이유, 통과/실패, 남은 위험 |

이 작성 loop는 사람이 감독하는 turn 기반 loop입니다. 예약 실행, 목표 조건, 별도 검증자처럼 사람 없이 돌아가는 loop로 만들 때는 [`../../loop-engineering/LOOP_ENGINEERING.ko.md`](../../loop-engineering/LOOP_ENGINEERING.ko.md)를 따릅니다.

## 12. Sources

> 링크는 다시 읽고 확인 2026-11-03. OpenAI Codex 문서는 `learn.chatgpt.com/docs/*`에 있고, Anthropic 엔지니어링 노트는 이제 `/research/`로 redirect되므로 아래 canonical URL은 redirect 대상입니다.

| 주장 | 출처 |
|---|---|
| with/without 기준선을 핵심 패턴으로 두는 것(evaluating-skills 페이지가 선택이 아니라 핵심 패턴이라고 부름) | <https://agentskills.io/skill-creation/evaluating-skills> |
| Case 세트 구성과 검증된 case 수가 없다는 점 | <https://agentskills.io/skill-creation/optimizing-descriptions> |
| 일곱 산출물 감사 범주와 심각도 표시 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> |
| 제3자 skill을 코드 리뷰 대상으로 보는 것, 버전 고정과 재검토, 검사 범위의 빈틈 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise> |
| Skill당 metadata 약 100토큰, API 요청당 20개 제한 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| Codex 목록 예산, `skills.max_context_tokens`, `[[skills.config]]` | <https://learn.chatgpt.com/docs/build-skills> |
| Claude Code 목록 예산, 항목당 1,536자 제한, 호출 빈도 낮은 순서로 버리는 동작, `skillOverrides` | <https://code.claude.com/docs/en/skills> |
| Skill별 paired delta 설계와 98개 중 92개 결과 | <https://arxiv.org/abs/2603.15401> |

### 인용 URL

- OpenAI Codex Agent Skills: <https://learn.chatgpt.com/docs/build-skills>
- OpenAI API Skills: <https://developers.openai.com/api/docs/guides/tools-skills>
- OpenAI agent evals: <https://developers.openai.com/api/docs/guides/agent-evals>
- OpenAI skill eval 지침: <https://developers.openai.com/blog/eval-skills>
- Anthropic Agent Skills 엔지니어링 노트: <https://www.anthropic.com/research/equipping-agents-for-the-real-world-with-agent-skills>
- Anthropic Agent Skills overview: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview>
- Anthropic skill 작성 best practices: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>
- Anthropic Agent Skills enterprise 보안: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise>
- Claude Code skills: <https://code.claude.com/docs/en/skills>
- Anthropic prompt·eval 문서: <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>
- Agent Skills specification: <https://agentskills.io/specification>
- Agent Skills best practices: <https://agentskills.io/skill-creation/best-practices>
- Agent Skills 출력 품질 평가: <https://agentskills.io/skill-creation/evaluating-skills>
- Vercel `skills` CLI: <https://github.com/vercel-labs/skills>
- ReAct: <https://arxiv.org/abs/2210.03629>
- Reflexion: <https://arxiv.org/abs/2303.11366>
- Self-Refine: <https://arxiv.org/abs/2303.17651>
- Tree of Thoughts: <https://arxiv.org/abs/2305.10601>
- OPRO: <https://arxiv.org/abs/2309.03409>
- Promptbreeder: <https://arxiv.org/abs/2309.16797>
- DSPy: <https://arxiv.org/abs/2310.03714>
- MIPRO: <https://arxiv.org/abs/2406.11695>
- AI Agents That Matter: <https://arxiv.org/abs/2407.01502>
- LiveCodeBench: <https://arxiv.org/abs/2403.07974>
- LiveBench: <https://arxiv.org/abs/2406.19314>
- SWE-bench Verified: <https://openai.com/index/introducing-swe-bench-verified/>
- SWE-Skills-Bench: <https://arxiv.org/abs/2603.15401>
- OWASP Top 10 for LLM Applications: <https://genai.owasp.org/llm-top-10/>
- NIST AI Risk Management Framework: <https://www.nist.gov/itl/ai-risk-management-framework>

### 근거 등급

20개 API 제한과 목록 예산은 특정 제품과 날짜에 묶인 `VENDOR` 수치입니다. 감사 심각도는 출처가 붙인 표시입니다. 98개 중 92개 결과는 자체 통계 검정을 갖춘 2026년 벤치마크 하나의 결과입니다.
