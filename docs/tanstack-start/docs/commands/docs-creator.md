---
description: Claude Code 문서 작성 가이드. CLAUDE.md, SKILL.md 등 효과적인 문서 작성 시 사용.
---

# Docs Creator

Claude Code 문서 작성 베스트 프랙티스 가이드.

## 핵심 원칙

| 원칙 | 설명 |
|------|------|
| **간결함** | 컨텍스트 윈도우는 공공재. 모든 토큰이 비용 |
| **점진적 공개** | 핵심만 메인 파일에, 상세는 참조 파일로 분리 |
| **보편적 적용** | 모든 세션에 필요한 정보만 포함 |

## 문서 유형별 가이드

| 문서 | 권장 길이 | 용도 |
|------|----------|------|
| CLAUDE.md | 60-200줄 | 프로젝트 전역 설정, 컨벤션 |
| SKILL.md | 500줄 이하 | 특화 워크플로우, 도구 사용법 |
| references/ | 무제한 | 상세 API 문서, 스키마 등 |

**지침 개수 한계**: 150-200개 (Claude Code 자체 ~50개 사용)

## 구조 템플릿

### CLAUDE.md

```markdown
# 프로젝트명

## 개요
프로젝트 목적 (1-2문장)

## 기술 스택
- 프레임워크: X
- 언어: Y
- DB: Z

## 명령어
| 명령 | 설명 |
|------|------|
| `yarn dev` | 개발 서버 |
| `yarn test` | 테스트 실행 |

## 컨벤션
- 파일명: kebab-case
- 함수: const 화살표 함수
- 타입: interface (객체), type (유니온)

## 워크플로우
기능 추가 → 테스트 → 린트 → 커밋
```

### SKILL.md

```markdown
---
name: skill-name
description: 무엇을 하는지 + 언제 사용하는지. (scope)
---

# Skill Name

스킬 목적 (2-3문장)

## 사용 시점
- 조건 1
- 조건 2

## 사용 방법

### 기본 워크플로우
1. 단계 1
2. 단계 2

### 참조
- 상세 API: [references/api.md](references/api.md)
- 스키마: [references/schema.md](references/schema.md)
```

## Progressive Disclosure

```
project/
├── CLAUDE.md           # 핵심만 (60-200줄)
├── docs/
│   ├── api.md          # API 상세
│   └── architecture.md # 아키텍처
└── .claude/skills/
    └── my-skill/
        ├── SKILL.md        # 개요 (<500줄)
        └── references/     # 상세 정보
```

**토큰 로드 단계:**

| 단계 | 내용 | 크기 |
|------|------|------|
| 1. 메타데이터 | name + description | 30-50 토큰 |
| 2. 활성화 | SKILL.md 본문 | <5k 단어 |
| 3. 참조 | 번들 리소스 | 필요 시만 |

## 작성 규칙

### DO

- 불릿 포인트 + 짧은 문장
- 코드 예시 중심
- 표로 정보 구조화
- 강조: `IMPORTANT:`, `YOU MUST:`
- 1단계 깊이 참조 (A→B ✅, A→B→C ❌)

### DON'T

- 긴 서술형 문단
- Claude가 아는 것 설명
- 린터 역할 강요 (도구 사용)
- 시간 의존적 정보
- /init 자동 생성 의존

## Description 작성

SKILL.md의 description은 스킬 발견에 핵심.

```yaml
# Good - 구체적 + 트리거 포함
description: PDF에서 텍스트/표 추출, 폼 작성. PDF 작업 시 사용.

# Bad - 모호함
description: 문서 처리
```

**규칙:**
- 3인칭 작성 (시스템 프롬프트에 주입됨)
- 무엇을 하는지 + 언제 사용하는지
- 구체적 키워드 포함

## Context 관리

| 명령어 | 용도 | 시점 |
|--------|------|------|
| `/compact` | 컨텍스트 요약 | 70% 도달 |
| `/clear` | 세션 초기화 | 새 기능 시작 |
| `/resume` | 세션 복원 | 작업 재개 |

**주의:** 마지막 20%는 복잡한 작업 피할 것

## Subagent 활용

문서 작성 시 subagent를 적극 활용하여 메인 컨텍스트 보호.

### Subagent 종류

| 타입 | 용도 | 문서 작성 활용 |
|------|------|---------------|
| `Explore` | 코드베이스 탐색 | 프로젝트 구조 파악, 패턴 분석 |
| `Plan` | 구현 계획 수립 | 문서 구조 설계, 섹션 계획 |
| `general-purpose` | 범용 조사 | 베스트 프랙티스 조사, 예시 수집 |

### 활용 시점

**CLAUDE.md 작성 시:**
```
1. Explore agent → 프로젝트 구조/기술 스택 파악
2. Explore agent → 기존 컨벤션/패턴 분석
3. 메인 에이전트 → 요약 기반 문서 작성
```

**SKILL.md 작성 시:**
```
1. Explore agent → 관련 코드/워크플로우 분석
2. Plan agent → 스킬 구조 설계
3. 메인 에이전트 → 설계 기반 작성
```

### 효과

| 방식 | 컨텍스트 사용 |
|------|--------------|
| 직접 탐색 | 전체 파일 내용 로드 |
| Subagent | 요약만 반환 → 90%+ 절약 |

### 프롬프트 예시

```
Explore agent에게:
"프로젝트 구조와 기술 스택을 분석하고,
CLAUDE.md에 포함할 핵심 정보만 요약해줘.
- 디렉토리 구조
- 주요 의존성
- 빌드/테스트 명령어
- 코드 컨벤션"
```

```
Plan agent에게:
"이 스킬의 SKILL.md 구조를 설계해줘.
- 스킬 목적
- 주요 섹션
- 참조 파일 분리 계획
- 워크플로우 단계"
```

## 체크리스트

### CLAUDE.md

- [ ] 60-200줄 이내
- [ ] 기술 스택 명시
- [ ] 주요 명령어 포함
- [ ] 컨벤션 정리
- [ ] 민감 정보 제외

### SKILL.md

- [ ] 500줄 이하
- [ ] description 구체적 (무엇 + 언제)
- [ ] 3인칭 작성
- [ ] 참조 1단계 깊이
- [ ] 100줄+ 파일은 목차 포함
- [ ] 워크플로우에 체크리스트

### 공통

- [ ] 간결한 작성
- [ ] 코드 예시 포함
- [ ] 표로 구조화
- [ ] 시간 의존 정보 없음
- [ ] Subagent로 사전 조사 완료
- [ ] 테스트 완료

## 참조

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Using CLAUDE.MD files](https://claude.com/blog/using-claude-md-files)
- [Skill Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
