# Evaluation Patterns

> 영어판: [`evaluation-patterns.md`](evaluation-patterns.md)

## Deterministic Assertions

출력을 정확히 검사할 수 있을 때 쓴다.

```yaml
assert:
  - type: is-json
  - type: contains
    value: "status"
  - type: javascript
    value: output.changed_files.length > 0
```

## Rubric Judge

품질 판단이 필요할 때 쓴다.

```markdown
Score 0-3:
3 = 완전히 답하고, 출처를 인용하며, caveat를 명시함
2 = 대체로 답했으나 사소한 caveat 누락
1 = 부분적 답변이거나 근거가 약함
0 = 근거가 없거나 틀림
```

## Trace Assertions

에이전트 검증에 쓴다.

```yaml
must_call:
  - repo_search_before_edit
  - test_after_edit
must_not_call:
  - external_post_without_permission
  - destructive_shell_without_approval
```

## Source-Grounded Answer Eval

```yaml
metrics:
  context_recall: "답변이 필요한 출처 사실을 모두 사용했는가?"
  context_precision: "인용한 출처가 실제로 관련 있는가?"
  citation_accuracy: "출처가 그 주장을 지지하는가?"
  stale_source_rate: "현재 시점 주장이 현재 시점 출처로 뒷받침되는가?"
```

## Regression Checklist

- [ ] baseline과 동일한 입력 세트를 사용했다
- [ ] 모델·런타임 버전이 같거나 기록되어 있다
- [ ] 도구 가용성이 같거나 차이가 명시적으로 문서화되어 있다
- [ ] 실패를 root cause별로 분류했다
- [ ] 새 실패를 영구 eval case로 승격했다

## Negative Fixtures (부정 픽스처)

형식은 받아들이는 입력이 아니라 **거부해야 하는 입력**으로 증명된다. 잘못된 케이스마다 검증기 옆에
최소 파일을 두고, 각 파일이 특정 거부를 단언한다.

지시·매니페스트 형식의 최소 집합:

- [ ] 필수 헤더나 frontmatter 블록이 통째로 없음
- [ ] 디렉터리명과 맞지 않는 이름
- [ ] 형식이 금지하는 문자
- [ ] 길이 한계를 넘은 값
- [ ] 알 수 없는 필드
- [ ] **로드되어서는 안 되는 루트** — 기대 결과가 "절대 로드되지 않는다"인 픽스처

마지막이 보안 케이스다. 주어진 것을 다 받아들이는 로더는 모든 양성 테스트를 통과하므로,
"절대 로드되지 않는다" 픽스처가 거부 경로를 관찰 가능하게 만든다.

코퍼스 계약 테스트가 픽스처를 보완한다. 한 파일이 아니라 지시 집합 전체의 속성을 고정한다.
항목 수, 필수 항목, 금지 항목(은퇴한 항목이 광고되어서는 안 된다), 링크 해석이다.

이 저장소의 실행 지점:

```bash
bun run --cwd scripts verify
node skills/skill-tester/scripts/validate-skills-corpus.mjs --root skills --json
```

첫 번째는 저장소 자체 검사를 돌리고, 두 번째는 스킬 코퍼스를 검증해 JSON을 낸다. 형식·검증기·코퍼스
멤버십이 바뀌면 둘 다 돌린다.
