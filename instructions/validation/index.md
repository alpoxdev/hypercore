# Validation

검증 및 품질 기준

## 파일 목록

| 파일 | 설명 |
|------|------|
| [forbidden-patterns.md](./forbidden-patterns.md) | 금지 패턴 - 반복되는 실수 방지 |
| [required-behaviors.md](./required-behaviors.md) | 필수 행동 - 반드시 따를 규칙 |
| [verification-checklist.md](./verification-checklist.md) | 검증 체크리스트 - 표준 검증 절차 |

## 사용법

```markdown
@.claude/instructions/validation/forbidden-patterns.md
@.claude/instructions/validation/required-behaviors.md
```

## 빠른 참조

### 금지 패턴 (Forbidden)
- 수동 검증/인증 체크 (handler 내부)
- 임의 DB 변경 (schema.prisma 직접 수정)
- AI 표시 커밋 메시지
- 클라이언트에서 Server Function 직접 호출

### 필수 행동 (Required)
- POST/PUT/PATCH: inputValidator + middleware
- DB 스키마 변경: 파일 분리 (Prisma Multi-File)
- 라이브러리 API 조회: 먼저 문서 읽기
- 3개+ 파일 수정: Gemini Review 실행
