# Git 커밋 규칙

## 커밋 메시지 형식

```
<prefix>: <설명>
```

**한 줄만 작성, 본문 없음**

---

## Prefix 목록

| Prefix | 설명 | 예시 |
|--------|------|------|
| `feat` | 새 기능 추가 | `feat: 템플릿 복사 기능 추가` |
| `fix` | 버그 수정 | `fix: 경로 처리 오류 수정` |
| `refactor` | 리팩토링 | `refactor: copy 유틸 분리` |
| `style` | 코드 스타일 | `style: prettier 적용` |
| `docs` | 문서 수정 | `docs: README 업데이트` |
| `test` | 테스트 | `test: copy 유틸 테스트 추가` |
| `chore` | 기타 작업 | `chore: 버전 업데이트` |
| `perf` | 성능 개선 | `perf: 파일 복사 최적화` |
| `ci` | CI/CD | `ci: GitHub Actions 추가` |

---

## 금지 사항

```
❌ "Generated with Claude Code" 포함 금지
❌ "🤖" 또는 AI 관련 이모지 포함 금지
❌ "Co-Authored-By:" 헤더 포함 금지
❌ AI/봇이 작성했다는 어떤 표시도 금지
❌ 커밋 메시지 여러 줄 작성 금지
❌ 커밋 메시지에 이모지 사용 금지
```

---

## 예시

```bash
# ✅ 올바른 예시
git commit -m "feat: CLI 옵션 추가"
git commit -m "fix: 템플릿 경로 오류 수정"
git commit -m "docs: 사용법 문서 추가"

# ❌ 잘못된 예시
git commit -m "feat: CLI 옵션 추가 🚀"           # 이모지 금지
git commit -m "feat: CLI 옵션 추가

상세 설명..."                                    # 여러 줄 금지
```
