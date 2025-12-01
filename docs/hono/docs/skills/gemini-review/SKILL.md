---
name: gemini-review
description: Google Gemini CLI를 활용한 코드 리뷰 및 계획 검증 스킬. 구현 계획 검토, 코드 리뷰, 아키텍처 논의 시 Gemini를 세컨드 오피니언으로 활용. Hono, Cloudflare Workers 등 특화 체크리스트 지원. gemini-2.5-pro 모델 사용 (무료: 60req/min, 1000req/day).
---

# Gemini 리뷰 스킬

## 개요

Claude가 컨텍스트를 준비하고 Gemini가 독립적인 검증을 제공하는 듀얼 AI 리뷰 워크플로우. 결과는 항상 Gemini 원본 응답과 Claude의 종합 액션 플랜 두 섹션으로 제공.

**모델**: `gemini-2.5-pro` (고정)
**비용**: 무료 티어 (60 req/min, 1000 req/day)

## 사용 시점

- 코딩 전 구현 계획 검증
- 완성된 코드의 버그, 보안, 베스트 프랙티스 리뷰
- 아키텍처 결정에 대한 세컨드 AI 의견
- Hono, Cloudflare Workers 프로젝트 특화 피드백

## 워크플로우 타입

| 타입 | 목적 | 사용 시점 |
|------|------|-----------|
| **plan** | 구현 계획 검증 | 개발 시작 전 |
| **code** | 완성 코드 리뷰 | 기능 구현 후 |
| **architecture** | 시스템 설계 논의 | 설계 단계 또는 리팩토링 시 |

## 실행 프로세스

### Step 1: 사용자 컨텍스트 수집

실행 전 수집할 정보:
1. **리뷰 타입**: `plan`, `code`, `architecture`
2. **기술 스택** (선택): `hono`, `cloudflare`, `general`
3. **리뷰 대상**: 실제 계획, 코드, 아키텍처 설명

### Step 2: 체크리스트 로드

기술 스택에 따라 `references/checklists.md`에서 해당 체크리스트 로드:
- **Hono**: API 설계, 미들웨어 패턴, 유효성 검사, 에러 처리
- **Cloudflare**: Workers, KV, D1, R2, 엣지 런타임 고려사항
- **General**: 범용 베스트 프랙티스

### Step 3: Gemini 명령어 구성 및 실행

`references/prompt-templates.md`에서 적절한 프롬프트 템플릿 로드 후 실행:

**인라인 프롬프트:**
```bash
gemini -m gemini-2.5-pro -p "{constructed_prompt}" --output-format json
```

**파일 내용 리뷰:**
```bash
cat {file_path} | gemini -m gemini-2.5-pro -p "{review_instructions}" --output-format json
```

**멀티라인 프롬프트 (heredoc):**
```bash
gemini -m gemini-2.5-pro --output-format json -p "$(cat << 'EOF'
{constructed_prompt}
EOF
)"
```

### Step 4: JSON 응답 파싱

Gemini 응답 구조:
```json
{
  "response": "실제 리뷰 내용",
  "stats": {
    "models": { ... },
    "tools": { ... }
  }
}
```

`response` 필드에서 리뷰 내용 추출. `jq` 사용:
```bash
result=$(gemini -m gemini-2.5-pro -p "..." --output-format json)
echo "$result" | jq -r '.response'
```

### Step 5: 결과를 두 섹션으로 제시

**중요**: 항상 두 개의 명확히 구분된 섹션으로 결과 제시:

#### 섹션 A: Gemini 원본 응답
Gemini의 완전한 응답을 수정 없이 제시. 사용자에게 Gemini가 발견한 내용을 그대로 보여줌.

#### 섹션 B: Claude 분석 및 액션 플랜
Gemini 피드백을 기반으로 Claude가 제공:

1. **요약** (2-3문장)
   - 핵심 발견 사항
   - 전체 평가

2. **액션 아이템** (우선순위 목록)
   - 🔴 심각: 진행 전 반드시 수정
   - 🟡 중요: 조속히 해결 필요
   - 🟢 경미: 개선하면 좋음

3. **바로 적용 가능한 코드** (해당 시)
   - 각 이슈에 대한 실제 코드 수정안
   - 필요 시 before/after 비교 포함

## 출력 형식 템플릿

```markdown
---
## 📋 Gemini 리뷰 결과

### A. Gemini 응답 (원본)

{gemini_response_verbatim}

---

### B. Claude 분석

#### 요약
{2-3문장 개요}

#### 액션 아이템

🔴 **심각**
- 이슈: {설명}
- 수정: {해결책}

🟡 **중요**
- 이슈: {설명}
- 수정: {해결책}

🟢 **경미**
- 이슈: {설명}
- 수정: {해결책}

#### 바로 적용 가능한 코드

**{이슈명}**
```{language}
{fixed_code}
```

---
```

## 명령어 예시

### 계획 리뷰
```bash
gemini -m gemini-2.5-pro --output-format json -p "$(cat << 'EOF'
[계획 리뷰 요청]
이 구현 계획의 완전성과 잠재적 문제를 검토해주세요:

{plan_content}

확인 사항: 로직 오류, 누락된 엣지 케이스, 아키텍처 결함, 보안 우려.
구체적이고 실행 가능한 피드백을 제공해주세요.
EOF
)"
```

### 코드 리뷰 (파일 파이핑)
```bash
cat src/routes/auth.ts | gemini -m gemini-2.5-pro -p "이 Hono 인증 코드를 보안 이슈, 버그, 베스트 프랙티스 관점에서 리뷰해주세요. 구체적인 라인별 피드백을 제공해주세요." --output-format json
```

### 아키텍처 리뷰
```bash
gemini -m gemini-2.5-pro --output-format json -p "$(cat << 'EOF'
[아키텍처 리뷰]
시스템: {system_name}
기술 스택: Hono + Cloudflare Workers + D1

{architecture_description}

평가 항목: 확장성, 신뢰성, 유지보수성, 보안, 비용 효율성.
트레이드오프 분석과 함께 개선안을 제시해주세요.
EOF
)"
```

## 환경 호환성

| 환경 | 실행 방법 |
|------|-----------|
| Claude Code | 직접 bash 실행 |
| Claude (Web/Desktop) | `bash_tool` 사용 |

명령어 문법은 모든 환경에서 동일.

## 에러 처리

Gemini 에러 발생 시:
1. 사용자에게 에러 메시지 표시
2. 일반적인 문제 확인:
   - 할당량 초과 (60/min 또는 1000/day 한도)
   - 네트워크 연결
   - 잘못된 프롬프트 형식
3. 재시도 또는 대안 제안

## 할당량 관리

무료 티어 한도:
- 분당 60 요청
- 일당 1000 요청

할당량 절약:
- 관련 리뷰를 단일 프롬프트로 결합
- 구체적이고 집중된 리뷰 요청 사용
- 중복 리뷰 회피

## 참조 파일

- `references/checklists.md`: 기술 스택별 리뷰 체크리스트
- `references/prompt-templates.md`: 리뷰 타입별 프롬프트 템플릿
