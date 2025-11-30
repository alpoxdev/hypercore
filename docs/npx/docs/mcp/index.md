# MCP 도구 사용 가이드

## ⛔ 프로젝트 시작 전 필수 확인

### 1. Serena - 프로젝트 활성화 확인
```
mcp__serena__get_current_config 호출하여 현재 프로젝트 확인
→ 프로젝트 미활성화 시: mcp__serena__activate_project 실행
```

### 2. Sequential Thinking - 복잡한 문제 분석용
```
복잡한 로직, 아키텍처 설계, 디버깅 시 활용
```

### 3. sgrep - 코드베이스 검색용
```
❌ grep, rg 사용 금지
✅ sgrep 사용 필수
```

---

## 필수 MCP 도구

### sgrep (코드 검색)
```
❌ 금지: grep, rg, find
✅ 필수: sgrep
```

**사용 상황**:
- 함수/클래스 정의 찾기
- 특정 패턴 검색
- 코드베이스 탐색

### Sequential Thinking (복잡한 분석)
**사용 상황**:
- 복잡한 로직 분석
- 아키텍처 설계
- 디버깅 및 문제 해결
- 멀티스텝 작업 계획

### Context7 (라이브러리 문서)
**사용 상황**:
- Commander 사용법 확인
- fs-extra API 확인
- prompts 옵션 확인
- 라이브러리 버전별 차이 확인

---

## 상황별 MCP 사용

| 상황 | 사용 MCP |
|------|----------|
| 코드 검색 | sgrep |
| 복잡한 분석 | Sequential Thinking |
| 라이브러리 문서 | Context7 |
| 프로젝트 컨텍스트 | Serena |
