# Hermes curator: skill lifecycle 세부

> 영어판: [`curator-lifecycle.md`](curator-lifecycle.md)
>
> **조사일:** 2026-11-03. Hermes Agent **v0.22.5**(커밋 `bf0203a794a`, 2026-10-22 배포)에 실린 공식 문서를 근거로 삼았다. 아래 **사실**은 그 근거를 추적하고, **권고**는 이 안내서의 운영 정책이다. 이 file은 [SKILLS.ko.md](../SKILLS.ko.md)의 curator 요약 뒤에 있는 운영 세부이며, 버전에 민감하다.

## 출처

| 출처 | 제공하는 내용 | 확인 |
| --- | --- | --- |
| [Curator](https://hermes-agent.nousresearch.com/docs/user-guide/features/curator) | 상태, 기본값, CLI, ledger, backup, adopt, pin과 lock | 확인 2026-11-03 |
| [Skills System](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills) | 어떤 쓰기가 agent-created인지, `skill_manage` action | 확인 2026-11-03 |
| [CLI Commands Reference](https://hermes-agent.nousresearch.com/docs/reference/cli-commands) | `hermes curator` 하위 명령 목록 | 확인 2026-11-03 |

## Curator가 손댈 수 있는 대상

**사실:** 다음 세 조건을 모두 만족해야 대상이 된다. 이름이 `.bundled_manifest`에 없고, `.hub/lock.json`에도 없으며, `.usage.json` entry에 `"created_by": "agent"` 또는 `"agent_created": true`가 있다. 이 표시를 남기는 경로는 `background_review` write origin을 쓰는 background self-improvement review 하나뿐이다.

**사실:** Foreground agent가 `skill_manage(action="create")`로 만든 skill은 `/learn` 결과를 포함해 `created_by: learn`으로 기록되고 curator는 손대지 않는다. 손으로 쓴 skill과 `skills.external_dirs`로 발견한 skill은 표시가 없어 건드리지 않는다.

**사실:** `hermes curator status`는 unmanaged 수를 `pre-dates marker`(field가 생기기 전에 기록되어 작성자를 알 수 없음)와 `foreground-created`로 나눠 보여 준다. `hermes curator adopt <skill>` 또는 `adopt --all-unmanaged`가 이들을 넘겨받고, `list-unmanaged`가 항목을 나열한다.

## 상태와 기본값

```yaml
curator:
  enabled: true
  interval_hours: 168        # run 사이 7일
  min_idle_hours: 2          # 그리고 profile이 이만큼 idle
  stale_after_days: 14
  archive_after_days: 30
  consolidate: false         # LLM umbrella pass, 선택
  prune_builtins: false      # 쓰지 않는 bundled skill 보관까지 선택
  archive_ttl_days: 0        # 0 = archive 영구 보관
```

**사실:** 결정적 pass는 14일 미사용에 `active → stale`, 30일에 archive한다. 한 번도 쓰지 않은 skill(`use_count == 0`)에는 유예 하한이 있어 `stale_after_days`만큼 오래되기 전에는 archive하지 않는다. Pinned skill과 어떤 cron job의 `skills:` 목록이 참조하는 skill은 일시 중지·비활성 job까지 포함해 완전히 건너뛴다.

**사실:** `prune_builtins: true`는 결정적 보관 pass의 범위를 쓰지 않는 bundled skill까지 넓힐 뿐이며, bundled skill은 patch, consolidation, 삭제 대상이 되지 않고 hub 설치 skill은 늘 예외다. 보관은 skill을 `~/.hermes/skills/.archive/`로 옮기고, bundled나 hub skill이 그 이름을 차지하지 않았다면 `hermes curator restore <skill>`로 되돌린다.

**사실:** LLM consolidation pass는 auxiliary model run을 쓰며 sweep당 보통 50~100회 API 호출이 들고 기본은 꺼져 있다. `hermes curator run --consolidate`가 한 번만 강제한다. 후보 목록에는 실제로 읽고 쓸 수 있는 skill만 들어간다.

## Backup, ledger, rollback

**사실:** `hermes curator backup`이 `~/.hermes/skills/` snapshot을 만들고, `hermes curator rollback`이 가장 최근 snapshot을 복원한다(`--list`, `--id <ts>`, `-y`).

**사실:** 모든 mutation, 즉 curator 전환, agent의 `skill_manage` 호출, 사용자의 CLI archive/restore/purge가 `~/.hermes/skills/.curator_ledger.jsonl`에 entry 하나를 덧붙인다. Entry에는 actor(`curator`, `agent`, `user`), action, consolidation이면 `absorbed_into` 같은 근거, file별 `{path, sha256}` before/after manifest가 들어간다. 내용은 `~/.hermes/.curator_backups/blobs/`에 content-addressed로 저장된다. `hermes curator ledger [--skill <name>] [--limit N]`이 이를 읽고, `hermes curator rollback <entry-id>`가 그 mutation 하나만 복원하며, 안전 capture를 쓰지 못하면 아무것도 바꾸지 않고 실패한다. Foreground 삭제도 ledger에 남으므로 단일 entry rollback으로 hard-delete된 skill을 되살릴 수 있다.

**사실:** Ledger는 telemetry이며 gate가 아니다. Entry 기록이 실패해도 mutation은 그대로 진행된다. `skills.ledger: false`로 끄고, `skills.ledger_max_bytes`(기본 5MB)로 상한을 두며, 넘으면 unchanged-file dedup으로 압축한 뒤 가장 오래된 entry를 버리고 최신 entry는 항상 남긴다. `hermes curator ledger --compact`가 같은 일을 손으로 한다.

**사실:** Archive는 기본으로 영구 보관된다. `hermes curator purge [--days N] [--dry-run]`는 명시적으로만 실행되고 자동으로 돌지 않으며, 지우는 skill마다 먼저 ledger에 capture한다.

## Pin, lock, cron 보호

**사실:** `pin`은 `.usage.json`에 `"pinned": true`를 남긴다. Curator는 auto-transition에서 그 skill을 건너뛰고 LLM pass에도 손대지 말라고 지시하며, `skill_manage`는 그 skill의 `delete`를 거부하되 patch와 edit는 허용한다. Agent-created skill만 pin할 수 있다.

**사실:** `lock`은 `"locked": true`를 남긴다. Agent의 모든 쓰기 경로가 거부한다. 단일·묶음 형태의 `skill_manage` patch/edit/write_file/remove_file/delete, skill directory 안 모든 path에 대한 `write_file`과 `patch`, 그리고 그곳에 쓰는 terminal 명령(redirection, `tee`, `cp`/`mv`/`rm`/`touch`/`mkdir`/`chmod`, `sed -i`, `perl -i`, git 변경, archive 추출, inline `python -c`)이다. Skill 읽기와 script 실행은 계속 되고, agent는 스스로 unlock할 수 없으며, 사용자의 편집은 막지 않는다. 이는 정책 검사이지 sandbox가 아니다. `execute_code`와 자기 logic으로 그 skill에 쓰는 script는 검사하지 않는다.

**사실:** 두 flag 모두 profile의 `.usage.json`에 있으므로 profile 단위다.

## CLI 표면

```bash
hermes curator status
hermes curator run [--consolidate] [--background] [--dry-run]
hermes curator pause | resume
hermes curator pin <skill> | unpin <skill>
hermes curator lock <skill> | unlock <skill>
hermes curator adopt <skill> | adopt --all-unmanaged | list-unmanaged
hermes curator restore <skill> | list-archived | archive <skill>
hermes curator prune [--days N]
hermes curator backup | rollback [--list] [--id <ts>] [-y]
hermes curator ledger [--skill <name>] [--limit N] | rollback <entry-id>
hermes curator purge [--days N] [--dry-run]
```

**사실:** 같은 하위 명령이 도는 session 안의 `/curator`로도 있다. Run이 끝나면 요약이 전환마다 한 줄을 남기고, consolidation 뒤에는 `old-name → new-name` rename map을 명시한다.

**권고:** 설치하거나 업그레이드한 뒤 `--dry-run`을 한 번 돌리고, routine이나 cron job이 의존하는 skill은 pin한다. Unattended 배포 중 내용이 흔들리면 안 되는 skill에는 `lock`을 쓴다. 다만 lock은 수정하지 않은 bundled나 hub skill을 `hermes update`가 새로 고치는 것까지 막지 않는다. 그것은 agent 쓰기가 아니라 사용자의 명령이기 때문이다.
