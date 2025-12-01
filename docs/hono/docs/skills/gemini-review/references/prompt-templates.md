# Gemini 리뷰 프롬프트 템플릿

## 명령어 패턴

모든 명령어는 고정 모델 `gemini-2.5-pro`와 JSON 출력 사용.

### 기본 패턴
```bash
gemini -m gemini-2.5-pro -p "{prompt}" --output-format json
```

### 파일 파이핑 패턴
```bash
cat {file_path} | gemini -m gemini-2.5-pro -p "{instructions}" --output-format json
```

### 멀티라인 Heredoc 패턴
```bash
gemini -m gemini-2.5-pro --output-format json -p "$(cat << 'EOF'
{multi_line_prompt}
EOF
)"
```

### 응답 파싱
```bash
result=$(gemini -m gemini-2.5-pro -p "..." --output-format json)
review_content=$(echo "$result" | jq -r '.response')
echo "$review_content"
```

---

## 계획 리뷰 템플릿

```bash
gemini -m gemini-2.5-pro --output-format json -p "$(cat << 'EOF'
[계획 리뷰 요청]

## 컨텍스트
프로젝트: {project_name}
기술 스택: {tech_stack}
현재 상태: {current_state_description}

## 구현 계획
{plan_content}

## 리뷰 체크리스트
{checklist_items}

## 리뷰 지침
이 구현 계획을 분석하여 다음에 대한 피드백을 제공해주세요:

1. **완전성**
   - 모든 요구사항이 다뤄졌는가?
   - 누락된 단계나 고려사항이 있는가?

2. **로직 및 실현 가능성**
   - 이 접근방식이 의도대로 작동할 것인가?
   - 논리적 결함이나 모순이 있는가?

3. **엣지 케이스**
   - 놓칠 수 있는 엣지 케이스는?
   - 어떻게 처리해야 하는가?

4. **위험 및 이슈**
   - 구현 중 발생할 수 있는 문제는?
   - 의존성이나 블로커가 있는가?

5. **대안**
   - 더 나은 접근방식이 있는가?
   - 고려해야 할 트레이드오프는?

응답 형식:
- ✅ 계획의 강점
- ⚠️ 발견된 우려사항 또는 이슈
- 💡 개선 제안
- 🔄 대안적 접근방식 (있다면)
EOF
)"
```

---

## 코드 리뷰 템플릿

### 옵션 A: 인라인 코드
```bash
gemini -m gemini-2.5-pro --output-format json -p "$(cat << 'EOF'
[코드 리뷰 요청]

## 컨텍스트
파일: {file_path}
언어: {language}
기술 스택: {tech_stack}
목적: {purpose_description}

## 리뷰할 코드
```{language}
{code_content}
```

## 리뷰 체크리스트
{checklist_items}

## 리뷰 지침
다음에 초점을 맞춰 철저한 코드 리뷰를 수행해주세요:

1. **버그 및 로직 오류**
   - 잘못된 로직 또는 알고리즘
   - Off-by-one 에러
   - Null/undefined 처리
   - 타입 불일치

2. **보안 취약점**
   - 인젝션 위험 (SQL, XSS 등)
   - 인증/인가 갭
   - 데이터 노출 위험
   - 입력 유효성 검사 이슈

3. **성능 이슈**
   - 비효율적인 알고리즘 (문제 시 Big-O 명시)
   - N+1 쿼리
   - 메모리 누수
   - 불필요한 연산

4. **베스트 프랙티스**
   - 코드 구성
   - 명명 규칙
   - 에러 처리 패턴
   - 테스트 고려사항

5. **유지보수성**
   - 코드 명확성
   - 문서화 필요성
   - 결합도와 응집도
   - 향후 확장성

발견된 각 이슈에 대해 다음을 제공:
- 🔴 심각 / 🟡 중요 / 🟢 경미
- 위치 (라인 번호 또는 함수명)
- 이슈 설명
- 코드 예시와 함께 수정 제안
EOF
)"
```

### 옵션 B: 파일 내용 파이핑
```bash
cat {file_path} | gemini -m gemini-2.5-pro --output-format json -p "이 {language} 코드 ({tech_stack} 프로젝트)를 다음 관점에서 리뷰해주세요:
1. 버그 및 로직 오류
2. 보안 취약점
3. 성능 이슈
4. 베스트 프랙티스 위반
5. 유지보수성 우려

각 이슈에 대해: 심각도 (🔴 심각/🟡 중요/🟢 경미), 위치, 설명, 코드와 함께 수정 제안을 명시해주세요."
```

---

## 아키텍처 리뷰 템플릿

```bash
gemini -m gemini-2.5-pro --output-format json -p "$(cat << 'EOF'
[아키텍처 리뷰 요청]

## 시스템 개요
이름: {system_name}
목적: {system_purpose}
기술 스택: {tech_stack}
규모: {expected_scale}

## 현재/제안 아키텍처
{architecture_description}

## 컴포넌트
{components_list}

## 데이터 흐름
{data_flow_description}

## 구체적인 질문
{specific_questions}

## 리뷰 지침
다음을 고려하여 이 아키텍처를 평가해주세요:

1. **확장성**
   - 예상 로드를 처리할 수 있는가?
   - 수평 vs 수직 스케일링 옵션은?
   - 확인된 병목 지점은?

2. **신뢰성**
   - 단일 장애 지점이 있는가?
   - 내결함성 메커니즘은?
   - 복구 전략은?

3. **유지보수성**
   - 컴포넌트 결합도는?
   - 배포 복잡성은?
   - 운영 오버헤드는?

4. **보안**
   - 공격 표면은?
   - 데이터 보호는?
   - 접근 제어 경계는?

5. **비용 효율성**
   - 리소스 활용도는?
   - 스케일링 비용은?
   - 운영 비용은?

6. **트레이드오프**
   - 무엇을 희생하고 있는가?
   - 대안적 아키텍처는?
   - 마이그레이션 경로 고려사항은?

응답 형식:
- 📊 전체 평가
- ✅ 아키텍처 강점
- ⚠️ 우려사항 및 위험
- 💡 권장사항
- 🔄 고려할 가치가 있는 대안적 접근방식
EOF
)"
```

---

## Hono 특화 추가사항

tech_stack이 `hono`일 때 관련 템플릿에 추가:

```
## Hono 특화 리뷰 포인트
- 미들웨어 체인 정확성 및 순서
- zValidator 사용 및 Zod 스키마 설계
- 에러 처리에 HTTPException 사용
- Context (c) 사용 패턴
- 타입 안전 바인딩 및 변수
- RPC 클라이언트 타입 내보내기
- 빌트인 미들웨어 설정
```

---

## Cloudflare Workers 특화 추가사항

tech_stack이 `cloudflare`일 때 관련 템플릿에 추가:

```
## Cloudflare Workers 특화 리뷰 포인트
- 엣지 런타임 호환성 (Node.js API 금지)
- KV, D1, R2 바인딩 사용
- wrangler.toml 설정
- c.env를 통한 환경 변수 처리
- 요청/응답 크기 제한
- CPU 및 메모리 제약
- 서브리퀘스트 한도 (<50)
- 해당 시 Durable Objects
```

---

## 빠른 리뷰 템플릿

### 보안 빠른 체크
```bash
cat {file_path} | gemini -m gemini-2.5-pro -p "이 Hono 코드를 보안 감사해주세요. 찾을 것: 인젝션 취약점, 인증 이슈, 데이터 노출 위험, 입력 유효성 검사 갭. 각각 심각도와 수정안과 함께 나열해주세요." --output-format json
```

### 성능 빠른 체크
```bash
cat {file_path} | gemini -m gemini-2.5-pro -p "이 Hono 코드를 성능 리뷰해주세요. 찾을 것: 비효율적인 알고리즘 (Big-O 명시), N+1 쿼리, 메모리 이슈, 불필요한 연산. 최적화를 제안해주세요." --output-format json
```

### 버그 헌팅
```bash
cat {file_path} | gemini -m gemini-2.5-pro -p "이 코드에서 버그를 찾아주세요: 로직 오류, 엣지 케이스, null 처리, 레이스 컨디션, 타입 이슈. 각 버그에 대해 수정안을 보여주세요." --output-format json
```

### 미들웨어 리뷰
```bash
cat {file_path} | gemini -m gemini-2.5-pro -p "이 Hono 미들웨어를 리뷰해주세요: 적절한 next() 처리, 에러 전파, 타입 안전성, 재사용성, 부작용. 개선안을 제안해주세요." --output-format json
```

### 유효성 검사 리뷰
```bash
cat {file_path} | gemini -m gemini-2.5-pro -p "Zod 스키마와 zValidator 사용을 리뷰해주세요: 스키마 완전성, 에러 메시지, 타입 추론, 재사용성. Zod v4 문법을 사용해주세요." --output-format json
```

---

## 템플릿 사용 가이드

1. 적절한 기본 템플릿 선택 (plan/code/architecture)
2. 모든 `{placeholder}` 필드를 실제 내용으로 채움
3. 기술 스택에 따라 `checklists.md`에서 관련 체크리스트 로드
4. 해당 시 기술 스택 특화 추가사항 첨부
5. Gemini CLI로 실행
6. JSON 응답을 파싱하여 `.response` 필드 추출
7. Gemini 원본 응답과 Claude 분석 모두 제시
