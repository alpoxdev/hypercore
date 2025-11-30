# sgrep - 의미론적 코드 검색

> 자연어로 코드베이스를 검색하는 로컬 시맨틱 검색 엔진

---

## 🚨 필수 사용 규칙

```
✅ 코드베이스 검색 시 기본 grep 대신 sgrep 사용
✅ 자연어 쿼리로 코드 위치 파악
✅ JSON 출력으로 결과 파싱
❌ grep, rg 등 기존 검색 도구 사용 금지
```

---

## 🚀 Quick Reference

### 기본 검색

```bash
# 자연어로 코드 검색
sgrep search "where do we handle authentication?"

# 결과 수 제한
sgrep search "user validation logic" -n 5

# JSON 형식 출력
sgrep search "database connection setup" --json

# 전체 코드 청크 포함
sgrep search "error handling patterns" -c
```

### 인덱싱

```bash
# 인덱스 강제 재구성
sgrep index --force

# 파일시스템 감시 (실시간 업데이트)
sgrep watch . --debounce-ms 200
```

### 설정

```bash
# 기본 설정 초기화
sgrep config --init
```

---

## 주요 기능

### 벡터 + 그래프 검색

```
장점:
- 밀집 벡터 임베딩으로 의미 기반 검색
- 구조적 코드 그래프 분석
- 자연어 쿼리 지원
- 정확한 코드 위치 파악
```

### 로컬 처리

```
특징:
- 모든 처리가 로컬에서 수행
- 프라이버시 보장
- 외부 API 호출 없음
- 오프라인 사용 가능
```

### 에이전트 친화적

```
통합:
- 안정적인 CLI 인터페이스
- JSON 출력 지원
- Claude Code 플러그인 호환
- 자동화 스크립트 연동
```

---

## 사용 예시

### 예시 1: 인증 로직 찾기

```bash
sgrep search "authentication middleware implementation"

# 결과:
# src/middleware/auth.ts:15 - authMiddleware function
# src/functions/auth.ts:8 - session validation
```

### 예시 2: 에러 핸들링 패턴

```bash
sgrep search "how are API errors handled" --json

# JSON 결과로 파싱하여 분석
```

### 예시 3: 데이터베이스 쿼리

```bash
sgrep search "user data fetching with prisma" -c

# 전체 코드 블록 포함하여 컨텍스트 파악
```

---

## 옵션 요약

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `-n, --limit` | 반환 결과 수 | 10 |
| `-c, --context` | 전체 청크 내용 포함 | false |
| `--json` | JSON 형식 출력 | false |
| `--force` | 인덱스 강제 재구성 | false |

---

## Sequential Thinking과 함께 사용

```
복잡한 코드 분석 시:

1. sgrep로 관련 코드 위치 파악
   ↓
2. Sequential Thinking으로 코드 흐름 분석
   ↓
3. Context7로 라이브러리 API 확인
   ↓
4. 수정 구현
```

---

## 설치

```bash
# 간편 설치
curl -fsSL https://raw.githubusercontent.com/rika-labs/sgrep/main/scripts/install.sh | sh

# Cargo로 설치
cargo install --path .
```

---

## 참고

- [sgrep GitHub](https://github.com/Rika-Labs/sgrep)
- 로컬 처리로 프라이버시 보장
- 자연어 쿼리로 직관적 검색
