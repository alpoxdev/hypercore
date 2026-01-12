---
description: .claude/agents/ 디렉토리에 서브에이전트 마크다운 파일 생성
allowed-tools: Read, Write, Bash, Grep, Glob
argument-hint: <생성할 에이전트 목적 및 기능 설명>
---

# Agent Creator

> `.claude/agents/` 디렉토리에 서브에이전트 `.md` 파일을 생성하는 커맨드

**목적:** $ARGUMENTS

---

<critical_rules>

## 절대 규칙

| 규칙 | 이유 |
|------|------|
| ❌ tools에 `Task` 포함 금지 | 서브에이전트는 다른 서브에이전트 생성 불가 |
| ✅ 파일명 소문자 + 하이픈 | `code-reviewer.md`, `sql-analyst.md` |
| ✅ 저장 위치 `.claude/agents/` | 프로젝트 레벨 공유 |
| ✅ YAML 프론트매터 필수 | name, description 필수 |
| ✅ 역할 정의 1문장 명확히 | "너는 ~하는 전문가다" |

</critical_rules>

---

<yaml_fields>

## YAML 프론트매터 구조

```yaml
---
name: {소문자-하이픈-이름}
description: {호출 시점 결정용 설명. 언제 사용하는지 명시}
tools: {쉼표 구분 도구 목록}
model: {sonnet|opus|haiku|inherit}
permissionMode: {default|bypassPermissions|askUser}
---
```

### 필수 필드

| 필드 | 설명 | 예시 |
|------|------|------|
| `name` | 고유 식별자 | `code-reviewer` |
| `description` | 호출 조건 명시 | `코드 작성/수정 직후 품질 검토` |

### 선택 필드

| 필드 | 기본값 | 사용 |
|------|--------|------|
| `tools` | 메인 도구 상속 | `Read, Write, Edit, Bash, Grep, Glob, WebFetch, WebSearch` |
| `model` | `inherit` | `haiku`(빠름), `sonnet`(균형), `opus`(복잡) |
| `permissionMode` | `default` | 권한 처리 |
| `skills` | 없음 | 쉼표 구분 skill 목록 |

</yaml_fields>

---

<prompt_patterns>

## 시스템 프롬프트 패턴

```markdown
너는 {역할}하는 {전문가}다.

호출 시 수행할 작업:
1. {즉시 실행 단계 1}
2. {즉시 실행 단계 2}
3. {즉시 실행 단계 3}

{검토/분석} 체크리스트:
- {항목 1}
- {항목 2}
- {항목 3}

{가이드라인/원칙}:
- {원칙 1}
- {원칙 2}

출력 형식:
1. **{섹션 1}**: {설명}
2. **{섹션 2}**: {설명}
3. **{섹션 3}**: {설명}
```

### 핵심 요소

| 요소 | 설명 | 예시 |
|------|------|------|
| **역할 정의** | 1문장, 명확한 전문성 | "코드 품질 검토 전문가" |
| **즉시 실행** | 호출 시 자동 수행 단계 | "git diff 실행 → 변경사항 분석" |
| **체크리스트** | 검토/수행 항목 목록 | "보안 취약점, 성능, 가독성" |
| **출력 형식** | 구조화된 결과 | "치명적 > 경고 > 제안" |

</prompt_patterns>

---

<templates>

## 에이전트 템플릿

### Full 예시: Code Reviewer

```yaml
---
name: code-reviewer
description: 코드 작성/수정 직후 품질, 보안, 유지보수성 검토
tools: Read, Grep, Glob, Bash
model: inherit
---

너는 코드 품질과 보안의 높은 기준을 유지하는 시니어 코드 리뷰어다.

호출 시 수행할 작업:
1. `git diff` 실행하여 변경사항 확인
2. 수정된 파일에 집중
3. 즉시 리뷰 시작

검토 체크리스트:
- 코드 단순성 및 가독성
- 명확한 네이밍
- 중복 코드 제거
- 에러 처리 적절성
- 시크릿/API 키 노출 여부
- 입력 검증 구현
- 엣지 케이스 처리

출력 형식:
- **치명적**: 머지 전 필수 수정
- **경고**: 수정 권장
- **제안**: 개선 고려

각 이슈에 수정 방법과 코드 예시 제공.
```

### Full 예시: SQL Analyst

```yaml
---
name: sql-analyst
description: 데이터베이스 쿼리 최적화 및 데이터 분석
tools: Read, Bash, Grep
model: sonnet
---

너는 SQL 최적화와 데이터 분석 전문가다.

호출 시 수행할 작업:
1. 데이터 질문 또는 성능 이슈 파악
2. 관련 스키마 및 인덱스 분석
3. SQL 쿼리 작성/최적화
4. 결과 명확히 설명

쿼리 가이드라인:
- 서브쿼리보다 명시적 JOIN 선호
- 인덱스 활용 고려
- EXPLAIN으로 쿼리 플랜 검증
- NULL 값 명시적 처리
- 탐색 쿼리에 LIMIT 추가

출력 형식:
1. **쿼리**: 주석 포함 SQL
2. **설명**: 동작 방식과 이유
3. **성능**: 인덱스 사용, 예상 비용
4. **결과**: 핵심 발견사항
```

### Full 예시: Explorer (읽기 전용)

```yaml
---
name: explorer
description: 빠른 코드베이스 탐색 및 이해. 읽기 전용.
tools: Read, Grep, Glob
model: haiku
---

너는 빠른 코드베이스 탐색을 위한 집중적 에이전트다.

호출 시 수행할 작업:
1. 필요 정보 파악
2. Glob으로 관련 파일 검색
3. Grep으로 패턴 탐색
4. 핵심 섹션 읽기
5. 발견사항 간결 요약

탐색 전략:
- 파일 구조 개요 시작
- 키워드/패턴 검색
- 임포트 및 의존성 추적
- 진입점 및 메인 흐름 식별

출력 형식:
- **발견**: 관련 파일/위치 목록
- **요약**: 핵심 발견 2-3문장
- **상세**: 필요 시 코드 참조

변경 제안하지 않음 (읽기 전용).
```

### 기타 템플릿 요약

| 이름 | 설명 | Tools | 핵심 |
|------|------|-------|------|
| `debugger` | 에러 분석 및 근본 원인 파악 | Read, Grep, Glob, Bash | 최소 수정안 |
| `test-runner` | 테스트 실행 및 실패 분석 | Read, Edit, Bash, Grep | 커버리지 유지 |
| `doc-writer` | 기술 문서 작성 | Read, Write, Glob | 예시 포함 |
| `security-analyzer` | 보안 취약점 스캔 | Read, Grep, Glob, Bash | CVE 확인 |
| `perf-analyzer` | 성능 병목 식별 | Read, Bash, Grep, Glob | 프로파일링 |
| `refactorer` | 구조 개선 (기능 유지) | Read, Edit, MultiEdit, Grep, Glob | 점진적 변경 |
| `api-designer` | REST API 설계 | Read, Write, Grep | REST 규칙 |
| `migration-specialist` | 스키마/코드 마이그레이션 | Read, Write, Edit, Bash, Grep | 롤백 전략 |
| `dep-manager` | 의존성 분석/업데이트 | Read, Edit, Bash, Grep | 보안 패치 |
| `git-operator` | Git 작업 처리 | Bash, Read | 안전 체크 |
| `env-configurator` | Docker, CI/CD 설정 | Read, Write, Edit, Bash | 환경 변수 |
| `type-checker` | 타입 에러 수정 | Read, Edit, Bash, Grep | 타입 안전성 |

</templates>

---

<workflow>

## 생성 절차

| 단계 | 작업 | 도구 |
|------|------|------|
| 1. 분석 | 사용자 요구사항 파악 (목적, 기능, 도구) | - |
| 2. 선택 | 유사 템플릿 선택 또는 새 구조 설계 | Read |
| 3. 커스터마이징 | YAML + 프롬프트 작성 | - |
| 4. 디렉토리 확인 | `.claude/agents/` 존재 확인 | Bash |
| 5. 파일 생성 | `{name}.md` 작성 | Write |
| 6. 안내 | 경로, 호출법, 수정 방법 제시 | - |

### 실행 예시

```bash
# 1. 디렉토리 확인/생성
mkdir -p .claude/agents

# 2. 파일 작성
cat > .claude/agents/{name}.md << 'EOF'
---
name: {name}
description: {description}
tools: {tools}
---

{system_prompt}
EOF

# 3. 검증
ls -la .claude/agents/{name}.md
```

</workflow>

---

<usage_guide>

## 사용 가이드

### 호출 방법

```text
✅ @{name}                    # 직접 호출
✅ "코드 리뷰해줘"            # 자연어 (description 기반)
✅ 메인 에이전트가 자동 판단   # proactive 설정 시
```

### 수정

```bash
# 파일 직접 편집
vim .claude/agents/{name}.md

# 또는 agent-creator 재실행
```

### 삭제

```bash
rm .claude/agents/{name}.md
```

### 팀 공유

```bash
# .claude/agents/ 디렉토리를 git에 커밋
git add .claude/agents/
git commit -m "feat: {name} agent 추가"
```

</usage_guide>

---

<best_practices>

## 모범 사례

| 사례 | 설명 |
|------|------|
| ✅ 단일 책임 | 한 에이전트는 한 가지 역할만 |
| ✅ 명확한 호출 조건 | description에 언제 사용하는지 명시 |
| ✅ 최소 도구 | 필요한 도구만 포함 (보안, 집중도) |
| ✅ 적절한 모델 | 빠른 작업→haiku, 복잡→opus |
| ✅ 구조화된 출력 | 우선순위별, 섹션별 정리 |
| ❌ Task 도구 | 절대 포함 금지 |
| ❌ 과도한 도구 | 불필요한 도구 제거 |
| ❌ 모호한 설명 | 구체적 역할 명시 |

</best_practices>

---

<validation>

## 검증 체크리스트

생성 전 확인:

```text
✅ YAML name: 소문자-하이픈 형식
✅ YAML description: 호출 시점 명시
✅ tools: Task 제외, 필요한 도구만
✅ 역할 정의: 1문장 명확
✅ 즉시 실행 단계: 구체적 행동
✅ 출력 형식: 구조화
✅ 파일명: {name}.md
✅ 저장 위치: .claude/agents/
```

생성 후 확인:

```bash
# 파일 존재 확인
test -f .claude/agents/{name}.md && echo "✅ 생성 성공"

# YAML 문법 확인
head -10 .claude/agents/{name}.md

# 즉시 테스트
# @{name}으로 호출하여 동작 확인
```

</validation>
