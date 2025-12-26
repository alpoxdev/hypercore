---
name: skill-creator
description: 스킬 생성 가이드. 새로운 스킬을 만들거나 기존 스킬을 수정할 때 사용. (project)
license: Complete terms in LICENSE.txt
---

# Skill Creator

Claude 기능 확장을 위한 스킬 생성 가이드.

## 스킬 개요

스킬은 특화된 지식, 워크플로우, 도구를 제공하는 모듈. Claude를 범용 에이전트에서 전문 에이전트로 변환.

### 스킬 제공 요소

| 요소 | 설명 |
|------|------|
| 워크플로우 | 특정 도메인의 다단계 절차 |
| 도구 통합 | 파일 형식, API 작업 지침 |
| 도메인 전문성 | 회사별 지식, 스키마, 비즈니스 로직 |
| 번들 리소스 | 스크립트, 참조 문서, 에셋 |

### 스킬 구조

```
skill-name/
├── SKILL.md (필수)
│   ├── YAML frontmatter (name, description 필수)
│   └── Markdown 지침
└── 번들 리소스 (선택)
    ├── scripts/     - 실행 가능 코드
    ├── references/  - 참조 문서
    └── assets/      - 출력용 파일 (템플릿, 이미지 등)
```

### 번들 리소스

| 디렉토리 | 용도 | 예시 |
|----------|------|------|
| `scripts/` | 반복 작업용 결정론적 코드 | `rotate_pdf.py` |
| `references/` | 컨텍스트에 로드될 문서 | `schema.md`, `api_docs.md` |
| `assets/` | 출력에 사용될 파일 | `logo.png`, `template.pptx` |

**references 원칙**: SKILL.md는 간결하게, 상세 정보는 references로 분리. 대용량 파일(>10k 단어)은 grep 패턴 포함.

### 점진적 로딩

| 레벨 | 내용 | 크기 |
|------|------|------|
| 메타데이터 | name + description | ~100 단어 |
| SKILL.md 본문 | 스킬 트리거 시 | <5k 단어 |
| 번들 리소스 | 필요 시 로드 | 무제한 |

### Description 작성

description은 스킬 발견의 핵심. 100+ 스킬 중에서 선택됨.

```yaml
# Good - 구체적 + 트리거 포함
description: PDF 텍스트/표 추출, 폼 작성. PDF 작업 시 사용. (project)

# Bad - 모호함
description: 문서 처리
```

**규칙:**
- 3인칭 작성 (시스템 프롬프트에 주입됨)
- 무엇을 하는지 + 언제 사용하는지
- 구체적 키워드 포함
- scope 명시: `(project)`, `(user)`, `(managed)`

## 생성 프로세스

### 1단계: 사용 사례 파악

스킬 사용 패턴 이해. 질문 예시:
- "어떤 기능을 지원해야 하나?"
- "사용 예시를 보여줄 수 있나?"
- "스킬을 트리거할 사용자 요청은?"

### 2단계: 재사용 콘텐츠 계획

각 사용 사례 분석:
1. 처음부터 실행하는 방법 고려
2. 반복 실행 시 유용한 스크립트/참조/에셋 식별

**예시**:
- `pdf-editor`: PDF 회전 코드 반복 → `scripts/rotate_pdf.py`
- `frontend-builder`: 보일러플레이트 반복 → `assets/hello-world/`
- `big-query`: 스키마 재탐색 반복 → `references/schema.md`

### 3단계: 스킬 초기화

새 스킬 생성 시 init 스크립트 실행:

```bash
scripts/init_skill.py <skill-name> --path <output-directory>
```

생성 내용: SKILL.md 템플릿, scripts/, references/, assets/ 예제

### 4단계: 스킬 편집

**작성 스타일**: 명령형/부정형 사용 ("X를 수행" ← "X를 수행해야 합니다" ❌)

편집 순서:
1. `scripts/`, `references/`, `assets/` 구현 (사용자 입력 필요 시 요청)
2. 불필요한 예제 파일 삭제
3. SKILL.md 완성:
   - 스킬 목적 (2-3문장)
   - 사용 시점
   - 사용 방법 (모든 번들 리소스 참조)

### 5단계: 패키징

```bash
scripts/package_skill.py <path/to/skill-folder> [output-directory]
```

자동 검증 후 zip 생성. 오류 시 수정 후 재실행.

### 6단계: 반복

사용 → 문제 발견 → 수정 → 재테스트

## Subagent 활용

스킬 생성 시 subagent를 활용하여 메인 컨텍스트 보호.

### 활용 시점

```
1. Explore agent → 기존 스킬 패턴 분석
2. Explore agent → 관련 코드/워크플로우 파악
3. Plan agent → 스킬 구조 설계
4. 메인 에이전트 → 설계 기반 작성
```

### 프롬프트 예시

```
Explore agent에게:
"프로젝트의 스킬 구조와 패턴을 분석하고 보고해줘:
- 기존 스킬 목록 및 용도
- 공통 구조 (섹션, 참조 방식)
- 번들 리소스 활용 패턴"
```

```
Plan agent에게:
"새 스킬 구조 설계:
- 목적 및 사용 시나리오
- SKILL.md 섹션 구성
- 참조 파일 분리 계획
- 번들 리소스 (scripts/references/assets)"
```

## 체크리스트

### 계획 단계

- [ ] 사용 사례 파악
- [ ] 재사용 콘텐츠 식별
- [ ] 번들 리소스 계획

### 작성 단계

- [ ] description 구체적 작성 (3인칭, 트리거)
- [ ] SKILL.md 500줄 이하
- [ ] 명령형 작성
- [ ] 참조 1단계 깊이
- [ ] 100줄+ 파일 목차 포함

### 검증 단계

- [ ] 스킬 트리거 테스트
- [ ] 번들 리소스 접근 확인
- [ ] 다양한 시나리오 테스트

## 참조

- [Skill Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
