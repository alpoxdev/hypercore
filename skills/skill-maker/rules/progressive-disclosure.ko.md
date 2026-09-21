# 점진적 공개

**Purpose**: 스킬을 간결하게 유지하면서 깊은 내용을 필요한 순간에 찾을 수 있게 만듭니다.

## 1. 세 단계 로딩 모델

모든 스킬을 에이전트가 단계적으로 로드한다고 가정하고 설계합니다.

| 단계 | 로드되는 내용 | 설계 목표 |
|---|---|---|
| 발견 | `name`, `description`, 경로 | 올바른 스킬 선택 |
| 활성화 | `SKILL.md` 전체 | 핵심 워크플로와 실행 계약 |
| 실행 | `rules/`, `references/`, `scripts/`, `assets/` | 필요할 때만 읽는 세부, 결정적 도우미, 출력 자원 |

계층이 깊을수록 내용은 더 구체적이고 더 선택적이어야 합니다.

## 2. 컨텍스트 예산

아래 두 수치는 **서로 다른 것**이며 그 차이가 중요합니다.

| 수치 | 지위 | 대상 |
|---|---|---|
| 500 lines | `PRIMARY` - 명세가 말합니다 | `SKILL.md` 본문 |
| 5,000 tokens | `PRIMARY` - 명세가 말합니다 | `SKILL.md` 본문 |
| 300 | **이 저장소가 고른 게이트** | `instructions/` 아래 파일만 |

300줄 값은 출처가 말한 수치가 아닙니다. 이 저장소가 고른 기본값이며 `scripts/check-sources.sh`가
`MAX_LINES=300`으로 강제하고, 그 스크립트는 `DOC_SCOPE="instructions"`를 설정하므로
`instructions/**`를 검사하고 **현재 이 스킬은 덮지 않습니다**. 300을 명세 요구처럼 제시하지 말고,
다른 검사가 우연히 다른 범위를 본다는 이유로 이 스킬이 500줄 예산에서 면제된다고도 보지 않습니다.

그 밖의 예산 규칙:

- 각 `references/` 파일은 한 주제에 집중합니다.
- 깊은 참조 사슬을 만들지 않습니다.
- 지원 파일을 만들었으면 `SKILL.md`에서 직접 참조합니다.
- 지원 파일이 필요하지 않았던 설명은 만들지 않습니다.
- 평가 픽스처와 프롬프트 템플릿은 실제로 실행하거나 복사할 때 산문 참조가 아니라 `assets/`에 둡니다.

## 3. 핵심을 간결하게 유지

핵심 스킬은 다음을 담습니다.

- 직업, 트리거, 경계
- 권위, 안전, 출력, 검증, 정지 조건 요약
- 상위 수준 워크플로
- 읽는 조건이 붙은 더 깊은 파일 안내

밖으로 옮길 것:

- 긴 예시
- 공식 출처 요약
- 스키마와 제공자별 세부
- 변형별 워크플로
- 결정적 명령 로직
- 출력 템플릿

## 4. 안내 문구

`see references/`처럼 모호하게 쓰지 않습니다.

약한 예:

```markdown
For more information, see references/.
```

나은 예:

```markdown
Read `references/official/openai.md` only when Codex-specific skill behavior changes the rule.
Read `rules/validation-and-iteration.md` before declaring the skill complete.
Run the target package's documented validator when present.
A repository-maintenance gate stays in the repository's policy documents, not in the skill artifact (`rules/self-containment.md`, SK-S-1).
```

## 5. 한 단계 깊이

지원 파일은 `SKILL.md`에서 직접 연결하는 것을 우선합니다. 참조는 핵심에서 **한 단계 깊이**로
유지합니다.

이유는 정돈이 아닙니다. 에이전트는 다른 참조에서 참조된 파일을 부분적으로 읽고 `head -100` 같은
명령으로 미리보기한 뒤 불완전한 그림으로 행동할 수 있습니다. `SKILL.md`가 직접 연결한 파일은 전체가
읽힙니다. 규칙이 다른 규칙을 요구하고 그 규칙이 또 다른 참조를 요구하는 사슬은 명시적으로 정당화하지
않는 한 피합니다.

## 6. 참조 파일 구조

**100줄을 넘는 참조 파일에는 맨 위에 table of contents를 넣습니다.** 깊은 사슬을 위험하게 만드는 같은
부분 읽기 동작 때문에 독자가 여는 몇 줄만 볼 수도 있으며, 목차는 그때도 파일의 전체 범위를 보이게
합니다.

## 7. 필요에 따라 나누기

내용을 옮길 자리:

- 반복되는 정책은 `rules/`
- 상세 지식은 `references/`
- 결정적 실행은 `scripts/`
- 출력 자원은 `assets/`
- 소비되는 런타임·UI 메타데이터는 `agents/`

## 8. 낭독 점검

나눈 뒤 확인합니다.

- 핵심만으로도 여전히 말이 되는가
- 지원 파일을 핵심에서 찾을 수 있는가
- 핵심 지침이 계층 사이에 중복되지 않았는가
- 모든 지원 파일이 존재할 이유가 있는가

### 제거 시험

위 질문들은 내용이 *쓸모 있는지*를 묻습니다. 다음은 그것이 *설 자리를 얻는지*를 정합니다.

- SK-D-1: 각 지침에 대해 **"이것이 없으면 에이전트가 틀릴까?"** 를 묻습니다. 답이 아니오면 삭제합니다. 확신이 없으면 미심쩍다는 이유로 남기지 말고 시험합니다.
- SK-D-2: 스킬 없이도 작업이 성공한다면 그 스킬은 가치를 더하지 않을 수 있습니다. 에이전트가 이미 안정적으로 하는 일을 다시 적는 스킬은 이익 없는 비용입니다.

낭독 질문 **과** 제거 시험을 함께 유지합니다. 둘은 다른 것을 묻습니다. 앞은 독자가 찾을 수 있는지를,
뒤는 그 내용이 애초에 있어야 하는지를 묻습니다.

## Sources

> 링크 확인 2026-09-20.

| 주장 | 출처 |
|---|---|
| 500줄·5,000토큰 점진적 공개 예산, `SK-D-1`과 `SK-D-2`의 근거인 제거 시험 | <https://agentskills.io/skill-creation/best-practices> |
| 세 단계 모델(메타데이터, 전체 지침, 참조 파일) | <https://agentskills.io/specification> |
| 한 단계 깊이 참조 규칙과 그 이유인 부분 읽기 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> |
| 100줄을 넘는 참조 파일의 목차 규칙 | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> |
| 300줄 저장소 게이트와 그 범위 | `scripts/check-sources.sh` (`MAX_LINES=300`, `DOC_SCOPE="instructions"`) |

### 증거 등급

이 파일은 공개 예산의 **정본** 진술입니다. `rules/skill-anatomy.md`는 예산을 다시 적지 않고 이 파일을
가리킵니다. 500줄과 5,000토큰은 `PRIMARY`이며 명세가 말합니다. 300줄 값은 저장소 게이트이며 그렇게
표시하고 출처가 말한 값처럼 제시하지 않습니다.
