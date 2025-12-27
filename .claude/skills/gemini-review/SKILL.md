---
name: gemini-review
description: Google Gemini CLI를 활용한 코드 리뷰 및 계획 검증 스킬. 구현 계획 검토, 코드 리뷰, 아키텍처 논의 시 Gemini를 세컨드 오피니언으로 활용. gemini-2.5-pro 모델 사용 (무료: 60req/min, 1000req/day).
license: Complete terms in LICENSE.txt
---

# Gemini 리뷰 스킬

Claude가 컨텍스트를 준비하고 Gemini가 독립적인 검증을 제공하는 듀얼 AI 리뷰 워크플로우.

**모델**: `gemini-2.5-pro` (고정) | **비용**: 무료 (60 req/min, 1000 req/day)

## 사용 시점

- 코딩 전 구현 계획 검증
- 완성된 코드의 버그, 보안, 베스트 프랙티스 리뷰
- 아키텍처 결정에 대한 세컨드 AI 의견

## 워크플로우 타입

| 타입 | 목적 | 사용 시점 |
|------|------|-----------|
| **plan** | 구현 계획 검증 | 개발 시작 전 |
| **code** | 완성 코드 리뷰 | 기능 구현 후 |
| **architecture** | 시스템 설계 논의 | 설계 단계 또는 리팩토링 시 |

## 실행 프로세스

### Step 1: 사용자 컨텍스트 수집

1. **리뷰 타입**: `plan`, `code`, `architecture`
2. **리뷰 대상**: 실제 계획, 코드, 아키텍처 설명
3. **기술 스택** (선택): 프로젝트의 기술 스택 (자유 입력)

### Step 2: 체크리스트 로드

`references/checklists.md`에서 리뷰 대상에 맞는 체크리스트 로드 (범용, 프론트엔드, 백엔드).

### Step 3: Gemini 실행

`references/prompt-templates.md`에서 적절한 템플릿 선택 후 실행.

**기본 패턴:**
```bash
gemini -m gemini-2.5-pro -p "{prompt}" --output-format json
```

**파일 리뷰:**
```bash
cat {file_path} | gemini -m gemini-2.5-pro -p "{instructions}" --output-format json
```

**응답 파싱:**
```bash
result=$(gemini -m gemini-2.5-pro -p "..." --output-format json)
echo "$result" | jq -r '.response'
```

### Step 4: 결과를 두 섹션으로 제시

**항상 두 개의 명확히 구분된 섹션으로 결과 제시:**

#### A. Gemini 응답 (원본)
Gemini의 완전한 응답을 수정 없이 제시.

#### B. Claude 분석 및 액션 플랜

1. **요약** (2-3문장): 핵심 발견 사항, 전체 평가

2. **액션 아이템** (우선순위 목록)
   - 🔴 심각: 진행 전 반드시 수정
   - 🟡 중요: 조속히 해결 필요
   - 🟢 경미: 개선하면 좋음

3. **바로 적용 가능한 코드** (해당 시)

**출력 형식:**
```markdown
## 📋 Gemini 리뷰 결과

### A. Gemini 응답 (원본)
{gemini_response_verbatim}

---

### B. Claude 분석

#### 요약
{2-3문장 개요}

#### 액션 아이템
🔴 **심각**: {이슈} → {수정}
🟡 **중요**: {이슈} → {수정}
🟢 **경미**: {이슈} → {수정}

#### 바로 적용 가능한 코드
{fixed_code}
```

## 에러 처리

Gemini 에러 발생 시:
1. 사용자에게 에러 메시지 표시
2. 일반적인 문제 확인: 할당량 초과, 네트워크 연결, 프롬프트 형식
3. 재시도 또는 대안 제안

## 할당량 관리

무료 티어 한도: 분당 60 요청, 일당 1000 요청

절약 팁:
- 관련 리뷰를 단일 프롬프트로 결합
- 구체적이고 집중된 리뷰 요청 사용

## 참조

- [체크리스트](references/checklists.md): 범용/프론트엔드/백엔드 리뷰 체크리스트
- [프롬프트 템플릿](references/prompt-templates.md): 리뷰 타입별 프롬프트 템플릿
