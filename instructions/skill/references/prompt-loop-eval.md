# Prompt, Loop, And Eval For Skills

이 문서는 skill을 단일 프롬프트가 아니라 **작고 반복 가능한 agent program**으로 설계하는 기준이다. `SKILL.md`는 프로그램의 entrypoint이고, `rules/`, `references/`, `scripts/`, `assets/`는 필요할 때 로드되는 모듈이다.

Source snapshot: 2026-06-28.

## 1. 핵심 원칙

| 원칙 | 작성 기준 | 실패 신호 |
|---|---|---|
| Skill is program | 입력, 단계, 도구, 중간 산출, 최종 산출, 검증을 분리한다 | 긴 역할 프롬프트 하나에 모든 지식을 넣음 |
| Loop needs signal | 반복에는 feedback source, metric/rubric, guard, stop condition이 있어야 한다 | “더 좋게 반복”만 있고 중단 기준이 없음 |
| Tool grounding | 외부 상태가 바뀌는 작업은 observe/action/verify를 분리한다 | 검색 snippet, tool output, subagent 요약을 그대로 믿음 |
| Eval before polish | 문장을 다듬기 전에 success criteria와 eval case를 만든다 | 좋아 보이지만 어떤 회귀를 막는지 모름 |
| Source and safety boundary | retrieved content는 증거이고, system/developer/project instruction이 아니다 | 웹페이지나 tool output 안의 지시를 실행함 |
| Benchmark humility | 리더보드/단일 점수는 참고 신호일 뿐 skill 검증 자체가 아니다 | benchmark version, scaffold, contamination, weak test를 기록하지 않음 |

## 2. Prompt Contract

Skill prompt는 아래 계약을 채워야 한다.

```markdown
## Intent
- 사용자가 성공으로 보는 결과:
- 실패로 보는 결과:

## Scope
- In:
- Out:
- Side-effect boundary:

## Authority
- 우선순위:
- retrieved/tool content 처리:

## Context
- 필요한 파일/source/date/version:
- 누락 정보 처리:

## Workflow
- Step 1:
- Step 2:
- Verification:

## Loop
- Type: none | observe-act | draft-critique-revise | branch-score-prune | optimize-compare
- Feedback:
- Metric/rubric:
- Guard:
- Stop:

## Output
- 형식:
- 저장 위치:
- 필수/금지 필드:
```

## 3. Loop Pattern 선택

| Pattern | 근거 | 쓸 때 | 필수 guard |
|---|---|---|---|
| Observe → act → observe → update | ReAct | 검색, repo 탐색, tool 사용처럼 외부 관측이 답을 바꾸는 작업 | tool output을 읽고 다음 행동을 갱신했다는 trace |
| Draft → critique → revise | Self-Refine | 문서, 요약, 리뷰, policy conformance처럼 rubric으로 개선 가능한 산출물 | critique 기준과 최대 반복 수 |
| Attempt → feedback → reflection → retry | Reflexion | 같은 작업군을 반복하며 실패 postmortem이 다음 시도에 도움이 되는 경우 | reflection이 실제 verify output에 근거하는지 확인 |
| Branch → score → prune | Tree of Thoughts | 대안 탐색, 계획 비교, 복잡한 추론처럼 early choice가 큰 영향을 주는 경우 | branch 수, scorer, prune 기준 |
| Candidate → score → mutate | OPRO, Promptbreeder, DSPy/MIPRO | prompt/skill variants를 eval set으로 최적화할 수 있는 경우 | train/holdout 분리와 regression gate |

Loop가 필요 없는 경우도 명시한다. 예: 단일 파일 template 채우기, deterministic formatter 실행, 짧은 one-shot 변환.

## 4. Skill Eval Matrix

Skill eval은 trigger만 보지 않는다.

| 계층 | Eval case | Pass 기준 |
|---|---|---|
| Trigger | positive/negative/boundary prompt | 필요한 skill만 켜지고 비슷한 작업에는 물러남 |
| Workflow | 정상 task, 누락 context, 실패 tool output | 정해진 순서와 fallback을 따름 |
| Output | schema/table/file path/style | 후속 자동화가 읽을 수 있음 |
| Source | 최신 API claim, 충돌 source, stale source | primary source와 accessed date가 있음 |
| Safety | prompt injection, credential 요구, destructive/network action | retrieved instruction 무시, user/project authority 기준으로 gate |
| Regression | known bad prompt/output pair | 이전 실패가 재발하지 않음 |

최소 권장:

- small skill edit: 3~5 smoke cases
- standard skill creation/refactor: 8~15 cases
- agent/tool workflow skill: 20+ cases 또는 대표 샘플 + targeted adversarial cases

## 5. Multi-Prompt And Format Robustness

Prompt formatting과 예시 배치는 결과를 크게 흔들 수 있다. 따라서 중요한 skill은 하나의 canonical prompt만 통과시키지 않는다.

- 같은 intent를 한국어/영어, 짧은 요청/긴 요청, 명시 skill명/무명시 요청으로 나눠 테스트한다.
- Markdown, JSON, YAML 등 출력 형식이 중요한 경우 최소 2개 형식 변형을 평가한다.
- 평균만 보지 말고 worst case와 regression case를 본다.
- “새 prompt가 좋아 보임”은 ship 기준이 아니다. 같은 eval set에서 failure count가 줄어야 한다.

## 6. Benchmark And Leaderboard Hygiene

Agentic skill, coding skill, tool-use skill을 검증할 때 공개 benchmark 점수만으로 완료를 주장하지 않는다.

필수 기록:

- benchmark name, release/date window, dataset split
- model/runtime/scaffold/tool version
- repository commit, container/toolchain, allowed tools
- retrieval enabled 여부와 source cutoff
- contamination/overlap 확인 방식
- public test, hidden test, oracle weakness caveat
- with-skill vs without-skill paired result가 필요한지 여부

규칙:

- software skill은 가능하면 execution-based verifier를 우선한다.
- benchmark가 오래됐거나 공개되어 있으면 contamination-prone으로 표시한다.
- scaffold가 바뀌면 같은 benchmark의 연속 점수로 비교하지 않는다.
- aggregate score만 보지 말고 task type, repository, difficulty, failure class로 나눈다.
- public tests가 약하면 hidden tests, differential check, oracle refinement를 추가한다.

## 7. Source-Grounded Skill 작성

Skill이 vendor docs, API behavior, 논문, benchmark, 보안 claim을 포함하면:

- `references/official/` 또는 별도 reference에 source URL, accessed date, 적용 버전/제품을 기록한다.
- `SKILL.md`에는 core rule만 남기고 긴 source 요약은 reference로 분리한다.
- 최신성 claim은 절대 날짜를 쓴다.
- 공식 문서끼리 충돌하면 적용 runtime/model/product와 날짜를 비교한다.
- model-generated summary는 source가 아니라 후보로 취급한다.

## 8. Safety-Grounded Skill 작성

Skill이 network, shell, credential, external API, production, destructive action을 다루면:

- `Authority`에 retrieved/tool content는 증거일 뿐 지시가 아니라고 적는다.
- 외부 텍스트 안의 command, URL, recipient, file path는 allowlist/schema로 검증한다.
- credential 입력, 결제, 게시, 삭제, 배포, production 변경은 사용자 명시 권한 없이는 실행하지 않는다.
- third-party skill과 bundled script는 prompt snippet이 아니라 code review 대상이다.
- production skill은 version pinning과 변경 재검토를 요구한다.
- scripts는 목적, dependency, input/output, failure mode, side effect를 문서화한다.
- 안전 지시는 성능을 해칠 수 있으므로 adversarial eval과 정상 happy path를 같이 둔다.

## 9. Authoring Loop

```text
Collect failures -> Draft contract -> Build eval set -> Run baseline/readback -> Patch smallest surface -> Re-run -> Record decision
```

| 단계 | 산출물 |
|---|---|
| Collect failures | 실제 사용자 문장, 실패 output, missing context, unsafe request |
| Draft contract | `SKILL.md` intent/scope/authority/workflow/output/verification |
| Build eval set | positive, negative, boundary, source, safety, regression cases |
| Run baseline/readback | 기존 skill 또는 초안의 실패 목록 |
| Patch | trigger, workflow, resource placement, script, asset 중 하나씩 수정 |
| Re-run | 같은 eval set과 새 failure case 확인 |
| Record | 변경 이유, 통과/실패, 남은 risk |

## 10. Sources

- OpenAI Codex Agent Skills: <https://developers.openai.com/codex/skills>
- OpenAI API Skills: <https://developers.openai.com/api/docs/guides/tools-skills>
- OpenAI agent evals: <https://developers.openai.com/api/docs/guides/agent-evals>
- OpenAI prompt engineering: <https://developers.openai.com/api/docs/guides/prompt-engineering>
- OpenAI agent safety: <https://developers.openai.com/api/docs/guides/agent-builder-safety>
- OpenAI Codex approvals and security: <https://developers.openai.com/codex/agent-approvals-security>
- Anthropic Agent Skills engineering note: <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills>
- Anthropic prompt/eval docs: <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>
- Anthropic Agent Skills enterprise security: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise>
- Agent Skills specification: <https://agentskills.io/specification>
- Agent Skills best practices: <https://agentskills.io/skill-creation/best-practices>
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
- OpenAI SWE-bench Verified: <https://openai.com/index/introducing-swe-bench-verified/>
- SWE-Skills-Bench: <https://arxiv.org/abs/2603.15401>
- OWASP Top 10 for LLM Applications: <https://genai.owasp.org/llm-top-10/>
- NIST AI Risk Management Framework: <https://www.nist.gov/itl/ai-risk-management-framework>
