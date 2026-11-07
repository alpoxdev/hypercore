# Progressive Disclosure

> 영어판: [`progressive-disclosure.md`](progressive-disclosure.md)

Progressive disclosure는 skill의 핵심 설계 원리입니다. Agent가 모든 skill의 모든 내용을 처음부터 읽는다고 가정하면 컨텍스트가 낭비되고 지시 충돌이 늘어납니다. 필요한 깊이만, 필요한 순간에 읽도록 설계합니다.

## 1. 3단계 모델

| 단계 | 로드되는 것 | 설계 목표 |
|---|---|---|
| Discovery | `name`, `description`, 경로 | 정확한 skill 선택 |
| Activation | `SKILL.md` 전체 | 핵심 workflow와 계약 실행 |
| Execution | `references/`, `scripts/`, `assets/` | 상세 지식과 도구를 필요할 때 사용 |

Anthropic 플랫폼 문서는 단계별 비용을 숫자로 밝힙니다. Metadata는 skill마다 약 **100토큰**으로 항상 로드되고, 본문은 트리거 시 로드되며 **5k 토큰 미만**을 유지해야 하고, 묶인 리소스는 읽기 전까지 비용이 없습니다. 스크립트는 예외를 증명하는 사례입니다. 스크립트 코드는 컨텍스트에 들어가지 않고 출력만 들어갑니다(<https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview>, 확인 2026-11-03).

## 2. `SKILL.md`에 남길 것

- 트리거와 범위
- 권한과 근거 기준
- 주요 workflow 단계
- loop 유형, feedback 출처, stop condition 요약
- 실행자가 반드시 알아야 할 gotcha
- 지원 파일을 언제 읽을지 알려주는 안내
- 검증과 정지 조건

Gotcha가 여기 들어오는 이유는 분명합니다. Gotcha는 합리적 가정을 뒤집는 환경 사실이고, 별도 참조 파일은 agent가 그 상황을 알아보고 읽어야만 도움이 됩니다. 알아볼 계기가 없다면 그 수정은 `SKILL.md`에 있어야 합니다(<https://agentskills.io/skill-creation/best-practices>, 확인 2026-11-03).

## 3. 아래로 내릴 것

| 내용 | 위치 |
|---|---|
| 긴 공식 문서 요약 | `references/official/*.md` |
| 반복되는 정책 | `rules/*.md` |
| Prompt scaffold와 재사용 prompt 템플릿 | `assets/prompts/` 또는 `references/examples.md` |
| 상세 loop 규칙과 실패 복구 순서 | `rules/loop.md` |
| Eval case, fixture, 기대 출력 | `assets/evals/` 또는 `references/eval-cases.md` |
| Source ledger와 벤더 변동 기록 | `references/official/` 또는 `references/sources.md` |
| 이 저장소 문서의 고정 스냅샷 | `references/local/*.md` |
| Prompt injection·부작용 안전 노트 | `rules/safety.md` 또는 `references/safety.md` |
| Schema와 API 상세 | `references/*.md` |
| Deterministic 검증 | `scripts/*.sh` |
| 템플릿 | `assets/*` |
| 긴 예시 모음 | `references/examples.md` 또는 `assets/examples/*` |

`references/official/`는 긴 공식 문서 요약과 provider 변동 기록을 두는 관례적 위치입니다(예: `skills/hyper-skill/references/official/`, `skills/hyper-docs/references/official/`). 다만 폴더 이름은 권장이지 필수 경로가 아닙니다. 규칙이 요구하는 것은 provider 상세를 core 밖으로 두는 일입니다. 이 저장소 안에 있는 문서의 고정 스냅샷이면 `references/local/*.md`를 씁니다. `skills/hyper-skill`가 skill 작성 문서 요약을 그 폴더에 둡니다.

## 4. 안내 문장

"references/를 보세요"로 끝내지 않습니다. 언제 읽는지 밝힙니다.

약한 예:

```markdown
For more information, see references/.
```

강한 예:

```markdown
Read `references/official/openai.md` only when provider-specific Codex skill behavior changes the core rule.
Read `references/prompt-loop-eval.md` before adding an iterative loop, prompt optimizer, or eval fixture.
Read `rules/safety.md` before enabling network, credential, destructive, or production side effects.
Run `scripts/validate-skill.sh` when the skill includes scripts, generated assets, or eval fixtures.
```

출처도 같은 규칙을 디렉터리가 아니라 조건의 형태로 적습니다. "API가 200이 아닌 상태를 반환하면 `references/api-errors.md`를 읽는다"가 "자세한 내용은 `references/`를 본다"보다 유용합니다.

## 5. 컨텍스트 예산 규칙

- Core `SKILL.md`는 500줄 이내로 유지합니다. 이 한도는 이 저장소가 아니라 agentskills.io best-practices 지침에서 온 값입니다. 이 저장소는 **추가로** `instructions/` 아래 문서에만 300줄 gate를 둡니다(`scripts/check-sources.sh`, `MAX_LINES=300`, `DOC_SCOPE="instructions"`). 이 gate는 `skills/`의 `SKILL.md`를 검사하지 않으므로, `SKILL.md`에는 500줄 지침이 그대로 적용됩니다. 300은 **이 저장소가 고른 기본값**이지 출처가 밝힌 수치가 아닙니다. 500은 best-practices 페이지가 밝힌 값이고 300은 이 저장소가 검사하는 값입니다.
- `references/` 파일은 하나가 주제 하나에 집중하게 합니다.
- 깊은 참조 사슬을 만들지 않습니다.
- 지원 파일을 만들었으면 `SKILL.md`에서 직접 참조합니다.
- 지원 파일이 필요 없었던 설명을 만들지 않습니다.
- Eval fixture와 prompt 템플릿은 산문 참조가 아니라 실제로 실행하거나 복사할 때 `assets/`에 둡니다.

## 6. Readback 점검

분리한 뒤 다음에 답합니다.

- `SKILL.md`만으로 무엇을 언제 해야 하는지 알 수 있는가?
- 지원 파일마다 읽는 조건이 분명한가?
- Core와 참조 사이에 정의가 중복됐는가?
- 모든 참조가 실제로 유용한가?
- 스크립트와 asset을 추론용 파일로 오용하고 있지 않은가?

### 삭제 판단

위 질문은 내용이 *유용한지*를 묻습니다. 아래는 그 내용이 *제자리를 얻을 자격이 있는지*를 정합니다.

- SK-D-1: 지시마다 **"이것이 없으면 agent가 틀릴까?"**를 묻습니다. 답이 아니면 삭제합니다. 확신이 없으면 의심으로 남기지 말고 시험합니다.
- SK-D-2: skill 없이도 과제가 성공한다면 그 skill은 가치를 더하지 않을 수 있습니다. Agent가 이미 안정적으로 하는 일을 다시 적는 skill은 이익 없는 비용입니다.
- SK-D-3: 잘 쓰였다는 이유만으로 skill을 유지할 근거가 되지 않습니다. 2026년 SWE-Skills-Bench 측정에서는 공개 skill 98개 중 92개가 통계적으로 유의미한 효과를 내지 못했고, 해로운 skill은 agent를 자기 템플릿에 고정시켜 과제의 명시 지시를 덮어쓰는 방식으로 작동했습니다. "내 skill을 항상 따른다"는 가치의 증거가 아닙니다.

## 7. 런타임별 목록 예산

목록이 희소 자원입니다. 설치된 모든 skill의 metadata는 쓰이든 쓰이지 않든 매 turn 청구됩니다.

| 런타임 | 목록 예산 | 넘칠 때 |
|---|---|---|
| Agent Skills spec | 규정 없음. client가 결정 | 동작이 정의되지 않음 |
| Codex | 모델 컨텍스트의 2%, 크기를 모를 때는 8,000자. `skills.max_context_tokens`로 최대 10,000토큰까지 상향 | 설명을 먼저 줄이고, 일부 skill을 경고와 함께 목록에서 뺄 수 있음 |
| Claude Code | 모델 컨텍스트의 1%. 항목당 `description`과 `when_to_use`를 합쳐 1,536자 | 호출 빈도가 낮은 skill부터 설명을 버림 |
| Anthropic API | 요청당 skill 최대 20개 | 요청이 거부됨. skill을 합치거나 세트를 나눠 라우팅해야 함 |

작성에 주는 결론은 세 가지입니다. 트리거를 첫 문장에 두고, 뒷부분은 영영 보이지 않을 수 있다고 가정하며, 설치 개수를 공짜 자원이 아니라 예산으로 봅니다. Claude Code의 `/skill-doctor`와 `/doctor`는 skill마다 드는 비용과 한 번도 호출되지 않은 skill을 보고하고(<https://code.claude.com/docs/en/skills>, 확인 2026-11-03), Codex의 `[[skills.config]]`는 skill을 삭제하지 않고 끕니다.

## Sources

> 링크는 다시 읽고 확인 2026-11-03.

| 주장 | 출처 |
|---|---|
| 500줄·5,000토큰 disclosure 예산, `SK-D-1`·`SK-D-2`의 삭제 판단 질문, gotcha 배치 규칙 | <https://agentskills.io/skill-creation/best-practices> |
| 3단계 모델(metadata → 전체 지시 → 참조 파일), 참조 한 단계 깊이 규칙 | <https://agentskills.io/specification> |
| Skill당 metadata 약 100토큰, 5k 토큰 미만 본문, 스크립트 출력만 컨텍스트에 들어가는 점 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview> |
| API 요청당 20개 제한 | <https://platform.claude.com/docs/en/build-with-claude/skills-guide> |
| 98개 중 92개 무효과 결과와 `SK-D-3`의 템플릿 고정 실패 양상 | <https://arxiv.org/abs/2603.15401> |
| Codex 컨텍스트 2%/8,000자 목록 예산, `skills.max_context_tokens`, `[[skills.config]]` | <https://learn.chatgpt.com/docs/build-skills> |
| Claude Code 컨텍스트 1% 목록 예산, 항목당 1,536자 제한, 호출 빈도 낮은 순서로 버리는 동작, `/skill-doctor` | <https://code.claude.com/docs/en/skills> |

### 근거 등급

이 파일은 disclosure 예산의 **canonical** 서술입니다. [`skill-anatomy.ko.md`](skill-anatomy.ko.md)는 단계별 예산과 500줄 한도는 이 파일을 가리키고, frontmatter와 파일 배치에 필요한 목록 수치만 다시 적습니다. 500줄·5,000토큰 값은 agentskills.io best-practices 페이지가 밝히므로 `PRIMARY`입니다. 300줄은 `instructions/`에 걸린 이 저장소의 gate이며 그렇게 표시했습니다. `SK-D-3`은 자체 통계 검정을 갖춘 2026년 벤치마크 하나의 결과에 근거하며, 법칙이 아니라 한 번의 측정으로 적었습니다.
