---
name: ralph
description: 작업 완료까지 자기참조 루프. 아키텍트 검증 기반 완료 판단. 복잡한 작업의 완전한 구현과 검증이 필요한 경우 사용.
user-invocable: true
---

# Ralph Skill

[RALPH + ULTRAWORK - ITERATION {{ITERATION}}/{{MAX}}]

작업 미완료 시 자동으로 재실행되는 반복 루프. 이전 시도에서 완료 약속(`<promise>`)을 출력하지 않았으므로 작업을 계속 진행하세요.

---

<when_to_use>

## 사용 시점

| 상황 | 설명 |
|------|------|
| **복잡한 구현** | 여러 단계의 작업이 필요한 기능 구현 |
| **완전성 필요** | 부분 구현이 아닌 100% 완성이 필요한 작업 |
| **검증 필수** | 테스트, 빌드, 린트 검증이 반드시 필요한 경우 |
| **멀티 에이전트** | 여러 전문 에이전트의 협업이 필요한 작업 |
| **병렬 실행** | 독립적인 작업을 동시에 처리해야 하는 경우 |

</when_to_use>

---

<completion_protocol>

## 완료 프로토콜 (절대 규칙)

**`<promise>{{PROMISE}}</promise>`를 출력하는 유일한 조건:**

| # | 단계 | 검증 방법 | 통과 기준 |
|---|------|----------|----------|
| 1 | 작업 완료 확인 | 원본 요구사항 체크리스트 | 100% 충족 |
| 2 | 코드 검증 | `/pre-deploy` 스킬 실행 | typecheck/lint/build 모두 통과 |
| 3 | TODO 확인 | TaskList 조회 | pending/in_progress = 0 |
| 4 | 아키텍트 검증 | Architect agent 호출 + 승인 대기 | "승인" 응답 |

**모든 4단계 통과 후에만 `<promise>` 출력. 하나라도 실패 시 작업 계속.**

</completion_protocol>

---

<forbidden>

## 금지 사항 (조기 탈출 방지)

| 조기 탈출 패턴 | 설명 | 대신 할 것 |
|---------------|------|-----------|
| ❌ **추측 기반 완료** | "아마 완료된 것 같다" | `/pre-deploy` 실행 |
| ❌ **부분 검증** | `/pre-deploy` 스킵 | 4단계 모두 실행 |
| ❌ **아키텍트 스킵** | 검증 없이 `<promise>` 출력 | Architect 호출 필수 |
| ❌ **만족감 표현** | "잘 작동하네요" | 증거 기반 검증 |
| ❌ **범위 축소** | "이 정도면 충분" | 원본 요구사항 100% |
| ❌ **테스트 삭제/수정** | 실패 테스트 제거 | 코드 수정으로 통과 |
| ❌ **에이전트 미활용** | 모든 작업 혼자 수행 | 적극적으로 에이전트 위임 |

**STOP 조건:** 다음 표현 사용 시 즉시 중단하고 검증 실행

```text
❌ "~해야 한다" "probably" "should" "seems to"
❌ "아마도" "~것 같다" "대부분" "거의"
❌ "이 정도면" "충분히" "~만 하면 됨"
```

**대신 사용:**

```text
✅ "Skill('pre-deploy') 실행"
✅ "/pre-deploy 결과 확인"
✅ "Architect 검증 요청"
✅ "Task(subagent_type='executor', ...) 실행"
✅ "여러 에이전트 병렬 호출"
```

</forbidden>

---

<required>

## 필수 검증 단계

### 1. 작업 완료 확인

원본 작업의 모든 요구사항을 체크리스트로 작성하고 하나씩 확인:

```markdown
- [ ] 요구사항 1: [구체적 설명]
- [ ] 요구사항 2: [구체적 설명]
- [ ] 요구사항 3: [구체적 설명]
```

**모든 항목 체크 완료 후 다음 단계 진행.**

### 2. 코드 검증

`/pre-deploy` 스킬을 사용하여 전체 검증 실행:

```typescript
Skill("pre-deploy")
```

**`/pre-deploy` 스킬은 다음을 자동으로 수행:**
- typecheck (tsc --noEmit 또는 해당 언어 타입 체크)
- lint (eslint, prettier 등)
- build (프로젝트 빌드)
- 모든 단계에서 에러 발견 시 자동 수정 시도

### 3. 검증 결과 확인

`/pre-deploy` 실행 결과를 읽고 기록:

```text
✅ Typecheck: 통과
✅ Lint: 에러 0개
✅ Build: 성공
```

**추측 금지. `/pre-deploy` 실제 출력만 기록. 모든 단계가 통과해야 다음 진행.**

### 3. TODO 확인

```typescript
TaskList() // pending/in_progress 작업 확인
```

**모든 작업이 completed 상태여야 다음 단계 진행.**

### 4. 아키텍트 검증

```typescript
Task(
  subagent_type="oh-my-claudecode:architect",
  model="opus",
  prompt=`다음 구현이 완료되었는지 검증:

원본 작업:
{{PROMPT}}

수행한 작업:
[구체적으로 무엇을 했는지]

검증 결과:
- /pre-deploy: ✅ 통과
- TODO: ✅ 0개
[기타 검증 결과]

완료 여부를 판단해주세요.`
)
```

**Architect의 "승인" 응답을 받은 후에만 `<promise>` 출력.**

### 5. 문서화 (각 단계마다)

각 Phase 완료 시 상태 문서 업데이트:

| Phase | 업데이트 파일 | 업데이트 내용 |
|-------|--------------|--------------|
| 1 | TASKS.md | 체크박스 체크, 완료율 업데이트 |
| 1 | PROCESS.md | Phase 1 완료 항목 기록, Phase 2 시작 표시 |
| 2 | VERIFICATION.md | `/pre-deploy` 결과, TODO 개수 기록 |
| 2 | PROCESS.md | Phase 2 완료, Phase 3 시작 |
| 3 | VERIFICATION.md | Architect 응답 기록 |
| 3 | PROCESS.md | Phase 3 완료, Phase 4 시작 |
| 4 | PROCESS.md | 완료 시각, 총 소요 시간 |

**문서 업데이트 시점:**
- Phase 전환 시 즉시 업데이트
- 주요 의사결정 시 NOTES.md 기록
- 블로커 발견 시 PROCESS.md에 기록

**Context compaction 대비:**
- 최소 10분마다 문서 업데이트
- 복잡한 작업 완료 시 즉시 기록
- 의사결정은 PROCESS.md에 이유와 함께 기록

</required>

---

<ultrawork_mode>

## ULTRAWORK MODE (자동 활성화)

### 병렬 실행 규칙

| 원칙 | 실행 방법 |
|------|----------|
| **PARALLEL** | 독립 작업은 단일 메시지에서 동시 Tool 호출 |
| **BACKGROUND** | 10개 이상 동시 작업 시 `run_in_background=true` |
| **DELEGATE** | 전문 에이전트에게 즉시 위임 |

### Smart Model Routing

| 복잡도 | 모델 | 작업 예시 |
|--------|------|----------|
| LOW | haiku | 함수 찾기, 정의 조회, 파일 읽기 |
| MEDIUM | sonnet | 기능 구현, 버그 수정, 리팩토링 |
| HIGH | opus | 아키텍처 설계, 복잡한 디버깅, 보안 분석 |

**에이전트 호출 시 항상 `model` 파라미터 명시:**

```typescript
Task(subagent_type="oh-my-claudecode:executor", model="sonnet", ...)
Task(subagent_type="oh-my-claudecode:architect", model="opus", ...)
```

### 티어별 에이전트

| 도메인 | LOW (haiku) | MEDIUM (sonnet) | HIGH (opus) |
|--------|-------------|-----------------|-------------|
| 분석 | architect-low | architect-medium | architect |
| 실행 | executor-low | executor | executor-high |
| 검색 | explore | explore-medium | - |
| 프론트엔드 | designer-low | designer | designer-high |
| 테스트 | - | qa-tester | - |
| 보안 | security-reviewer-low | - | security-reviewer |
| 빌드 | build-fixer-low | build-fixer | - |
| 리뷰 | code-reviewer-low | - | code-reviewer |

### 백그라운드 실행

| 작업 유형 | 실행 모드 |
|----------|----------|
| 패키지 설치 (`npm install`, `pip install`) | Background |
| 빌드 (`npm run build`, `tsc`, `make`) | Background |
| 테스트 스위트 (`npm test`, `pytest`) | Background |
| Docker 작업 (`docker build`, `docker pull`) | Background |
| 파일 읽기/쓰기 | Foreground |
| 간단한 명령어 (`git status`, `ls`) | Foreground |

### Agent Delegation (적극 활용)

**에이전트에게 위임하는 조건:**

| 조건 | 예시 | 위임할 에이전트 |
|------|------|----------------|
| 독립적인 작업 | 코드 분석 + 문서 작성 동시 | executor + writer |
| 새 컨텍스트 필요 | 대규모 코드베이스 탐색 | explore |
| 전문 지식 필요 | 보안 취약점 분석 | security-reviewer |
| 장기 실행 작업 | 전체 테스트 스위트 실행 | qa-tester |
| 병렬 처리 가능 | 여러 파일 동시 수정 | executor (여러 개) |

**에이전트 위임 원칙:**

```text
✅ 독립적인 작업 → 즉시 위임 (병렬 실행)
✅ 컨텍스트 분리 필요 → 위임
✅ 전문성 필요 → 해당 도메인 에이전트
✅ 10분 이상 예상 → 백그라운드 + 에이전트

❌ 간단한 파일 읽기 → 직접 실행
❌ 순차 의존성 → 직접 실행 후 다음 에이전트
```

### Phase별 에이전트 활용

| Phase | 작업 | 에이전트 | 모델 | 병렬 실행 |
|-------|------|---------|------|----------|
| **1** | 코드베이스 탐색 | explore | haiku | ✅ (여러 영역) |
| **1** | 기능 구현 | executor | sonnet | ✅ (독립 기능) |
| **1** | UI 구현 | designer | sonnet/opus | ✅ (여러 컴포넌트) |
| **1** | 문서 작성 | writer | haiku | ✅ (여러 문서) |
| **2** | 빌드 수정 | build-fixer | sonnet | ❌ (순차) |
| **2** | 테스트 실행 | qa-tester | sonnet | 백그라운드 |
| **3** | 아키텍처 검증 | architect | opus | ❌ (필수) |
| **3** | 코드 리뷰 | code-reviewer | opus | ✅ (파일별) |

### 병렬 에이전트 실행 패턴

**패턴 1: 독립 작업 동시 처리**

```typescript
// ❌ 순차 실행 (느림)
Task(subagent_type="executor", model="sonnet", prompt="기능 A 구현")
// 대기...
Task(subagent_type="executor", model="sonnet", prompt="기능 B 구현")

// ✅ 병렬 실행 (빠름)
// 단일 메시지에서 두 Task 호출
Task(subagent_type="executor", model="sonnet", prompt="기능 A 구현")
Task(subagent_type="executor", model="sonnet", prompt="기능 B 구현")
```

**패턴 2: 도메인별 전문가 활용**

```typescript
// 동시에 실행
Task(subagent_type="oh-my-claudecode:executor", model="sonnet",
     prompt="API 엔드포인트 구현")
Task(subagent_type="oh-my-claudecode:designer", model="sonnet",
     prompt="UI 컴포넌트 구현")
Task(subagent_type="oh-my-claudecode:writer", model="haiku",
     prompt="API 문서 작성")
```

**패턴 3: 탐색 + 구현 분리**

```typescript
// Phase 1 시작 시
Task(subagent_type="oh-my-claudecode:explore", model="haiku",
     prompt="프로젝트 구조 및 기존 패턴 분석")

// 탐색 결과 기반으로 구현
Task(subagent_type="oh-my-claudecode:executor", model="sonnet",
     prompt="분석된 패턴에 따라 [기능] 구현")
```

### 에이전트 호출 체크리스트

작업 시작 전 확인:

- [ ] 이 작업은 독립적인가? → 병렬 에이전트 고려
- [ ] 새 컨텍스트가 필요한가? → 에이전트 위임
- [ ] 전문 지식이 필요한가? → 도메인 에이전트 선택
- [ ] 10분 이상 소요될까? → 백그라운드 + 에이전트
- [ ] 여러 파일/영역 동시 작업? → 여러 executor 병렬 실행

**적극적으로 에이전트 활용. 혼자 하지 말 것.**

</ultrawork_mode>

---

<state_management>

## 상태 관리 (Context Compaction 대비)

### 문서화 폴더 구조

세션 시작 시 `.claude/ralph/{timestamp}/` 폴더 생성:

```
.claude/ralph/2026-01-23_14-30/
├── TASKS.md          # 작업 체크리스트
├── PROCESS.md        # 진행 단계 및 의사결정
├── VERIFICATION.md   # 검증 결과 기록
└── NOTES.md          # 추가 메모
```

**폴더명 형식:** `YYYY-MM-DD_HH-MM`

### 문서 역할

| 파일 | 내용 | 업데이트 시점 |
|------|------|--------------|
| **TASKS.md** | 요구사항 체크리스트, 진행 상태 | 요구사항 추가/완료 시 |
| **PROCESS.md** | 현재 Phase, 다음 단계, 의사결정 기록 | Phase 전환 시 |
| **VERIFICATION.md** | `/pre-deploy` 결과, Architect 응답 | 검증 실행 시 |
| **NOTES.md** | 기술적 결정, 블로커, 해결책 | 필요 시 |

### 문서 작성/수정 스킬

| 작업 | 스킬 | 사용 시점 |
|------|------|----------|
| 새 문서 작성 | `Skill("docs-creator")` | 초기 TASKS.md, PROCESS.md 생성 |
| 문서 개선/수정 | `Skill("docs-refactor")` | 문서 업데이트, 구조 개선 |

**활용 예시:**
- Phase 1 시작 시: `Skill("docs-creator")` → TASKS.md, PROCESS.md 생성
- 문서 업데이트 시: `Skill("docs-refactor")` → 기존 문서 수정
- 복잡한 문서 작성: `/docs-creator`, `/docs-refactor` 호출

### 문서 템플릿

#### TASKS.md

```markdown
# Tasks - {{PROMPT}}

생성: {{TIMESTAMP}}
상태: Phase {{CURRENT_PHASE}}/4

## 요구사항 체크리스트

- [ ] 요구사항 1: [설명]
- [ ] 요구사항 2: [설명]
- [ ] 요구사항 3: [설명]

## 완료 상태

- 완료: 0 / 총 3
- 진행률: 0%
```

#### PROCESS.md

```markdown
# Process Log

## 현재 상태

- Phase: 1 (작업 실행)
- 진행 중: [현재 작업]
- 다음: [다음 작업]

## Phase 1: 작업 실행

**시작:** {{TIMESTAMP}}

### 완료 항목
- 항목 1

### 진행 중
- 항목 2

### 의사결정
- 결정 1: [이유]

## Phase 2: 검증

**대기 중**

## Phase 3: Architect 검증

**대기 중**

## Phase 4: 완료

**대기 중**
```

#### VERIFICATION.md

```markdown
# Verification Results

## /pre-deploy 검증

**실행 시각:** 미실행

**결과:**
- Typecheck: 대기
- Lint: 대기
- Build: 대기

## TODO 확인

**실행 시각:** 미실행

**결과:** pending/in_progress = ?

## Architect 검증

**실행 시각:** 미실행

**응답:** 대기 중
```

### Context Recovery Protocol

Context compaction 후 세션 재개 시:

```text
1. pwd 실행 → 작업 디렉토리 확인
2. ls .claude/ralph/ → 최신 세션 폴더 식별
3. TASKS.md 읽기 → 요구사항 및 진행 상태 파악
4. PROCESS.md 읽기 → 현재 Phase 및 다음 단계 확인
5. VERIFICATION.md 읽기 → 검증 결과 확인
6. git log --oneline -10 → 최근 커밋 확인
7. 중단된 지점부터 작업 재개
```

</state_management>

---

<verification_workflow>

## 검증 워크플로우 (단계별 체크포인트)

### Phase 1: 작업 실행

```text
1. 원본 작업 요구사항 분석
2. .claude/ralph/{timestamp}/ 폴더 생성
3. TASKS.md 작성 (체크리스트)
4. PROCESS.md 작성 (Phase 1 시작 기록)
5. 구현 실행 (병렬/백그라운드 활용)
6. 각 요구사항 완료 시 TASKS.md 업데이트
7. 주요 의사결정 시 PROCESS.md 기록
```

**Phase 1 완료 조건:** 모든 체크리스트 항목 완료 + 문서 업데이트

### Phase 2: 자동 검증

```text
1. PROCESS.md 업데이트 (Phase 2 시작)
2. Skill("pre-deploy") 실행 → typecheck/lint/build 검증
3. VERIFICATION.md 업데이트 (/pre-deploy 결과)
4. TaskList 조회 → pending/in_progress 확인
5. VERIFICATION.md 업데이트 (TODO 개수)
6. PROCESS.md 업데이트 (Phase 2 완료)
```

**Phase 2 완료 조건:** `/pre-deploy` 전체 통과 + TODO 0개 + 문서 업데이트

### Phase 3: 아키텍트 검증

```text
1. PROCESS.md 업데이트 (Phase 3 시작)
2. Architect agent 생성 (model="opus")
3. 검증 요청 전송 (작업 내용 + 검증 결과 포함)
4. Architect 응답 대기
5. VERIFICATION.md 업데이트 (Architect 응답)
6. 승인/거절 확인
7. PROCESS.md 업데이트 (Phase 3 완료 또는 재작업)
```

**Phase 3 완료 조건:** Architect "승인" 응답 + 문서 업데이트

### Phase 4: 완료 출력

```text
1. PROCESS.md 업데이트 (완료 시각, 총 소요 시간)
2. TASKS.md 최종 확인 (모든 체크박스 체크)
3. <promise>{{PROMISE}}</promise> 출력
```

**Phase 4 조건:** Phase 1, 2, 3 순차적 완료 + 최종 문서 업데이트

### 실패 시 처리

| 실패 Phase | 조치 |
|-----------|------|
| Phase 1 | 미완료 항목 계속 구현 |
| Phase 2 | 에러 수정 후 재검증 |
| Phase 3 | Architect 피드백 반영 후 Phase 2부터 재실행 |

**절대 건너뛰지 말 것. 실패 시 수정 → 재검증 반복.**

</verification_workflow>

---

<architect_verification>

## 아키텍트 검증 (우회 불가)

### 호출 시점

Phase 1, 2 완료 후에만 호출:

```text
✅ 모든 요구사항 체크
✅ /pre-deploy 통과 (typecheck/lint/build)
✅ TODO 리스트 0개
→ 이제 Architect 호출
```

### 호출 방법

```typescript
Task(
  subagent_type="oh-my-claudecode:architect",
  model="opus",
  prompt=`구현 완료 검증 요청

【원본 작업】
{{PROMPT}}

【수행 내용】
- 요구사항 1: 완료 (구체적 설명)
- 요구사항 2: 완료 (구체적 설명)
- ...

【검증 결과】
- /pre-deploy: ✅ 통과 (typecheck/lint/build)
- TODO: ✅ 0개

완료 여부를 판단하고, 미흡한 점이 있다면 구체적으로 지적해주세요.`
)
```

### 응답 처리

| Architect 응답 | 조치 |
|---------------|------|
| "승인", "완료", "문제없음" | `<promise>` 출력 |
| "수정 필요", "미흡", "추가 작업" | 피드백 반영 → Phase 2부터 재실행 |

**Architect 검증 없이 `<promise>` 출력 시 즉시 작업 실패 처리.**

</architect_verification>

---

<instructions>

## 작업 지침

### 시작 시

**첫 실행:**
1. 원본 작업(`{{PROMPT}}`) 읽기
2. `.claude/ralph/{YYYY-MM-DD_HH-MM}/` 폴더 생성
3. TASKS.md, PROCESS.md, VERIFICATION.md 초기화
4. 요구사항 분석 후 TASKS.md에 체크리스트 작성

**Context Compaction 후 재개:**
1. `pwd` → 작업 디렉토리 확인
2. `ls .claude/ralph/` → 최신 세션 폴더 찾기
3. TASKS.md 읽기 → 요구사항 및 완료 상태
4. PROCESS.md 읽기 → 현재 Phase 및 다음 단계
5. VERIFICATION.md 읽기 → 검증 결과
6. `git log --oneline -10` → 최근 작업 확인
7. 중단 지점부터 계속

### 실행 중

**작업 실행:**
1. 병렬 실행 최대 활용 (독립 작업 동시 처리)
2. 백그라운드 실행 적극 사용 (빌드/테스트)
3. **에이전트 적극 위임 (혼자 하지 말 것)**
   - 독립 작업 → 즉시 에이전트 위임
   - 전문 지식 필요 → 도메인 에이전트 활용
   - 여러 작업 동시 → 병렬 에이전트 실행
   - 복잡도에 맞는 모델 선택 (haiku/sonnet/opus)

**문서화 (필수):**
1. 요구사항 완료 시 → TASKS.md 체크박스 업데이트
2. Phase 전환 시 → PROCESS.md 업데이트
3. 검증 실행 시 → VERIFICATION.md 업데이트
4. 주요 의사결정 시 → PROCESS.md 또는 NOTES.md 기록
5. 블로커 발견 시 → NOTES.md에 상황 및 해결책 기록

**문서 작성/수정 스킬:**
- 새 문서 작성: `Skill("docs-creator")`
- 기존 문서 개선: `Skill("docs-refactor")`

### 완료 판단

1. **Phase 1:** 모든 요구사항 완료 확인 + TASKS.md/PROCESS.md 업데이트
2. **Phase 2:** `/pre-deploy` 검증 + TODO 확인 + VERIFICATION.md 업데이트
3. **Phase 3:** Architect 검증 + VERIFICATION.md 업데이트
4. **Phase 4:** 최종 문서 업데이트 + `<promise>{{PROMISE}}</promise>` 출력

**4단계 순차 진행. 건너뛰기 절대 금지.**

### 실패 시

1. 검증 실패 → NOTES.md에 원인 기록
2. 수정 작업 → PROCESS.md에 수정 내용 기록
3. 재검증 → VERIFICATION.md 업데이트
4. 작업이 진정으로 완료될 때까지 중단하지 말 것

</instructions>

---

**원본 작업:**
{{PROMPT}}
