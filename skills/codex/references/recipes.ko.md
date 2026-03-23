# 명령 레시피

이 예시는 라우팅 결정이 끝난 뒤에만 사용한다.

## 읽기 전용 검토

```bash
codex exec --skip-git-repo-check \
  -m gpt-5.3-codex \
  --config model_reasoning_effort="high" \
  --sandbox read-only \
  "이 저장소의 최신 diff를 검토해줘" 2>/dev/null
```

## 로컬 편집

사용자가 Codex에게 파일 편집을 명시적으로 요청했을 때만 사용한다.

```bash
codex exec --skip-git-repo-check \
  -m gpt-5.3-codex \
  --config model_reasoning_effort="high" \
  --sandbox workspace-write \
  "src/app.ts를 수정해서 failing build를 고쳐줘" 2>/dev/null
```

`--full-auto`는 먼저 확인받는다.

## 네트워크 조사 또는 패치

네트워크 접근이나 광범위한 시스템 접근이 꼭 필요할 때만 사용한다.

```bash
codex exec --skip-git-repo-check \
  -m gpt-5.3-codex \
  --config model_reasoning_effort="high" \
  --sandbox danger-full-access \
  "최신 Next.js 문서를 확인하고 필요하면 코드를 패치해줘" 2>/dev/null
```

`--full-auto`는 먼저 확인받는다.
`--sandbox danger-full-access`도 먼저 확인받는다.

## 재개

```bash
echo "이전 작업을 계속해줘" | codex exec --skip-git-repo-check resume --last 2>/dev/null
```

플래그는 `exec`와 `resume` 사이에 둔다.
