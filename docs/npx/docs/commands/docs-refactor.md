---
description: Claude Code 문서 리팩토링 가이드. 기존 CLAUDE.md, SKILL.md 개선 시 사용.
---

# Docs Refactor

기존 Claude Code 문서를 베스트 프랙티스에 맞게 개선하는 가이드.

## 리팩토링 필요 신호

| 신호 | 문제 | 우선순위 |
|------|------|---------|
| 200줄+ CLAUDE.md | 컨텍스트 과부하 | 높음 |
| 500줄+ SKILL.md | 로딩 지연, 품질 저하 | 높음 |
| Claude가 지침 무시 | 과도한 지침 (150+개) | 높음 |
| 중첩 참조 (A→B→C) | 불완전한 파일 읽기 | 중간 |
| 코드 스타일 지침 | 린터 역할 강요 | 중간 |
| 시간 의존 정보 | 오래된 지침 | 낮음 |

## 분석 워크플로우

### 1단계: Subagent로 현황 분석

```
Explore agent에게:
"현재 CLAUDE.md/SKILL.md를 분석하고 보고해줘:
- 총 줄 수
- 섹션별 줄 수
- 지침 개수 (명령형 문장)
- 중첩 참조 깊이
- 린터 역할 지침 여부
- 시간 의존 정보 여부"
```

### 2단계: 개선 계획 수립

```
Plan agent에게:
"분석 결과를 바탕으로 리팩토링 계획 수립:
- 삭제할 내용
- 분리할 내용 (references/)
- 병합할 섹션
- 추가할 내용"
```

### 3단계: 리팩토링 실행

메인 에이전트가 계획 기반으로 문서 수정.

## 안티패턴 → 개선 패턴

### 길이 문제

| Before | After |
|--------|-------|
| 300줄 CLAUDE.md | 60-200줄 + docs/ 분리 |
| 800줄 SKILL.md | 500줄 이하 + references/ 분리 |

**분리 기준:**
- 모든 세션에 필요 → 메인 파일
- 특정 작업에만 필요 → 참조 파일

### 구조 문제

| Before | After |
|--------|-------|
| 긴 서술형 문단 | 불릿 포인트 + 짧은 문장 |
| 중첩 참조 (A→B→C) | 1단계 깊이 (A→B) |
| 목차 없는 100줄+ 파일 | 상단에 목차 추가 |

### 내용 문제

| Before | After |
|--------|-------|
| 코드 스타일 가이드 | 삭제 (Biome/ESLint 사용) |
| Claude가 아는 설명 | 삭제 |
| 시간 의존 정보 | "old patterns" 섹션으로 이동 |
| 너무 많은 옵션 | 기본값 + 대안 1개 |

**삭제 예시:**
```markdown
# Before - 불필요한 설명
PDF (Portable Document Format)는 Adobe에서 개발한
문서 형식으로, 텍스트와 이미지를 포함할 수 있습니다...

# After - 핵심만
PDF 텍스트 추출: `pdfplumber.open("file.pdf")`
```

### Description 문제

| Before | After |
|--------|-------|
| `description: 문서 처리` | `description: PDF 텍스트/표 추출. PDF 작업 시 사용.` |
| 1인칭/2인칭 | 3인칭 작성 |
| 트리거 없음 | 구체적 트리거 포함 |

## 분리 전략

### 참조 파일로 분리할 내용

| 내용 | 분리 위치 |
|------|----------|
| API 상세 문서 | `references/api.md` |
| 스키마 정의 | `references/schema.md` |
| 예시 모음 | `references/examples.md` |
| 도메인별 가이드 | `references/{domain}.md` |

### 분리 후 메인 파일 참조

```markdown
## API 사용

기본 호출: `api.call(params)`

**상세 API 문서**: [references/api.md](references/api.md)
```

## Subagent 활용

| 단계 | Agent | 작업 |
|------|-------|------|
| 분석 | Explore | 현황 파악, 문제점 식별 |
| 계획 | Plan | 리팩토링 전략 수립 |
| 검증 | Explore | 개선 결과 확인 |

### 검증 프롬프트

```
Explore agent에게:
"리팩토링된 문서 검증:
- 줄 수 목표 달성?
- 지침 개수 150개 이하?
- 중첩 참조 1단계?
- 필수 정보 누락 없음?"
```

## 체크리스트

### 분석 단계

- [ ] Subagent로 현황 분석 완료
- [ ] 문제점 목록 작성
- [ ] 개선 우선순위 결정

### 리팩토링 단계

- [ ] 불필요한 설명 삭제
- [ ] 코드 스타일 지침 삭제
- [ ] 긴 내용 참조 파일로 분리
- [ ] 중첩 참조 1단계로 평탄화
- [ ] 100줄+ 파일에 목차 추가
- [ ] Description 개선 (3인칭, 트리거)

### 검증 단계

- [ ] CLAUDE.md 60-200줄
- [ ] SKILL.md 500줄 이하
- [ ] 지침 개수 150개 이하
- [ ] 참조 1단계 깊이
- [ ] 필수 정보 유지 확인
- [ ] 테스트 완료

## 참조

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Using CLAUDE.MD files](https://claude.com/blog/using-claude-md-files)
- [Skill Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
