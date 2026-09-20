#!/usr/bin/env bash
# check-sources.sh — instructions/ 문서의 출처 무결성 검사
#
# 검사 항목
#   1. link   (네트워크) 인용 URL이 이전(3xx)되지 않았는가. 예시 URL과 코드 블록 안의 URL은 제외한다
#   2. date   (오프라인) `확인 YYYY-MM-DD` 표기가 실재하는 ISO 날짜인가
#   3. lines  (오프라인) 문서가 300줄 이내인가
#
# 기본 동작
#   오프라인 검사(2,3)는 strict — 실패 시 non-zero 종료.
#   네트워크 검사(1)는 advisory — 보고만 하고 종료코드에 반영하지 않는다.
#   `--strict`를 주면 네트워크 검사도 종료코드에 반영한다.
#
# 사용법
#   bash scripts/check-sources.sh              # 오프라인 strict + 링크 advisory
#   bash scripts/check-sources.sh --strict     # 전부 strict (릴리스 게이트용)
#   bash scripts/check-sources.sh --offline    # 링크 검사 생략
#   bash scripts/check-sources.sh --self-test  # 각 검사가 실제로 실패를 잡는지 증명
#
# 종료코드: 0 통과 / 1 검사 실패 / 2 사용법 오류

set -uo pipefail

# 다국어 문자열을 다루므로 UTF-8 로케일을 고정한다.
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

STRICT=0
OFFLINE=0
SELF_TEST=0
MAX_LINES=300
TIMEOUT=15

for arg in "$@"; do
  case "$arg" in
    --strict)    STRICT=1 ;;
    --offline)   OFFLINE=1 ;;
    --self-test) SELF_TEST=1 ;;
    -h|--help)   sed -n '2,26p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

if [ ! -d instructions ]; then
  echo "instructions/ 디렉터리를 찾을 수 없습니다. 저장소 루트에서 실행하세요." >&2
  exit 2
fi

# 검사 범위. 인자로 덮어쓸 수 있어 self-test가 주입 파일만 겨냥할 수 있다.
LINK_SCOPE="instructions"
DOC_SCOPE="instructions"

# 이 저장소의 인용은 Sources 표나 본문 인라인 링크로 적고, 코드 블록 안에는 예시 명령·설정값을 적는다.
# 따라서 코드 블록을 걷어낸 본문만 인용으로 보고 링크를 검사한다.
# CommonMark의 fenced code block을 따른다: 최대 3칸 들여쓰기, ``` 또는 ~~~ fence.
strip_fences() {
  if [ -d "$1" ]; then
    find "$1" -name '*.md' -type f -exec awk 'FNR==1{f=0; c=""} match($0,/^ {0,3}(```+|~~~+)/){m=substr($0,RSTART,RLENGTH); gsub(/ /,"",m); if(f==0){f=1;c=substr(m,1,1)} else if(substr(m,1,1)==c){f=0;c=""}; next} !f' {} +
  else
    awk 'BEGIN{f=0; c=""} match($0,/^ {0,3}(```+|~~~+)/){m=substr($0,RSTART,RLENGTH); gsub(/ /,"",m); if(f==0){f=1;c=substr(m,1,1)} else if(substr(m,1,1)==c){f=0;c=""}; next} !f' "$1" 2>/dev/null
  fi
}

collect_urls() {
  strip_fences "$1" \
    | grep -hioE 'https?://[^ )>,`"]+' \
    | sed -E 's/[.,:;]+$//' \
    | grep -vE "$PLACEHOLDER_RE" \
    | sort -u
}

# fence를 걷어내지 않고 모은 URL. 인용으로 보지 않는 대상을 드러내는 데 쓴다.
all_urls() {
  grep -rhioE 'https?://[^ )>,`"]+' "$1" 2>/dev/null \
    | sed -E 's/[.,:;]+$//' \
    | grep -vE "$PLACEHOLDER_RE" \
    | sort -u
}

# 검사에서 빠지는 URL = 전체 - 검사 대상. 조용히 사라지지 않도록 보고한다.
fence_skipped_urls() {
  comm -23 <(all_urls "$1") <(collect_urls "$1")
}

# 문서 안의 예시 URL은 인용이 아니므로 링크 검사에서 제외한다.
# RFC 2606이 문서용으로 예약한 example.com/.net/.org, *.example, 그리고 루프백(localhost, 127/8, IPv6 ::1)만 해당한다.
# .invalid는 self-test가 죽은 URL로 쓰므로 제외하지 않는다.
PLACEHOLDER_RE='^https?://(localhost|127\.[0-9]+\.[0-9]+\.[0-9]+|\[::1\]|([a-z0-9-]+\.)*example\.(com|org|net)|([a-z0-9-]+\.)*example)([:/]|$)'

count_placeholders() {
  grep -rhioE 'https?://[^ )>,`"]+' "$1" 2>/dev/null \
    | sed -E 's/[.,:;]+$//' \
    | grep -iE "$PLACEHOLDER_RE" \
    | sort -u \
    | wc -l \
    | tr -d ' '
}

is_real_date() {
  date -j -f '%Y-%m-%d' "$1" '+%Y-%m-%d' >/dev/null 2>&1 && return 0
  date -d "$1" '+%Y-%m-%d' >/dev/null 2>&1 && return 0
  return 1
}

# ---------------------------------------------------------------------------
# 검사 1 — 링크 이전 여부 (네트워크)
#
# 403/429는 dead가 아니다. WAF 봇 차단·레이트리밋이며 페이지는 살아있다.
# 실측 근거: openai.com/index/introducing-swe-bench-verified/ 는 403을 반환하지만
# TLS 지문을 바꿔 접근하면 정상 페이지다. dead로 분류하면 오탐이 된다.
# 405는 HEAD 미지원 서버다.
#
# return 0 = 이상 없음 / 1 = 문제 발견
# ---------------------------------------------------------------------------
check_links() {
  echo "== 검사 1: 링크 이전 여부 (${LINK_SCOPE}) =="
  local moved=0 total=0 url code final placeholders
  placeholders=$(count_placeholders "$LINK_SCOPE")
  if [ "$placeholders" -gt 0 ]; then
    echo "  -- 예시 URL ${placeholders}개 제외 (RFC 2606 문서용 도메인·루프백)"
  fi
  skipped=$(fence_skipped_urls "$LINK_SCOPE")
  skipped_n=$(printf '%s\n' "$skipped" | grep -c . || true)
  if [ "${skipped_n:-0}" -gt 0 ]; then
    echo "  -- 코드 블록 안 URL ${skipped_n}개는 인용으로 보지 않고 건너뜀 (검사 밖):"
    printf '%s\n' "$skipped" | head -3 | sed 's/^/       /'
    if [ "$skipped_n" -gt 3 ]; then
      echo "       ... 나머지 $((skipped_n - 3))개"
    fi
  fi
  while IFS= read -r url; do
    [ -z "$url" ] && continue
    total=$((total + 1))
    code=$(curl -sI -o /dev/null -w '%{http_code}' --max-time "$TIMEOUT" "$url" 2>/dev/null)
    case "$code" in
      200|403|405|429) ;;
      3??)
        final=$(curl -sI -o /dev/null -w '%{url_effective}' -L --max-time "$TIMEOUT" "$url" 2>/dev/null)
        printf '  MOVED    %s  %s\n           -> %s\n' "$code" "$url" "$final"
        moved=$((moved + 1)) ;;
      000)
        printf '  DEAD     ---  %s  (타임아웃 또는 DNS 실패)\n' "$url"
        moved=$((moved + 1)) ;;
      *)
        printf '  STATUS   %s  %s\n' "$code" "$url"
        moved=$((moved + 1)) ;;
    esac
  done < <(collect_urls "$LINK_SCOPE")

  if [ "$moved" -eq 0 ]; then
    echo "  OK - URL ${total}개 전부 정상"
    return 0
  fi
  echo "  ${total}개 중 ${moved}개 문제"
  return 1
}

# ---------------------------------------------------------------------------
# 검사 2 — 확인일 표기 (오프라인)
#
# 단순 존재 검사는 어떤 문자열로도 통과하므로 ISO 형식과 실재 날짜를 검증한다.
# return 0 = 이상 없음 / 1 = 문제 발견
# ---------------------------------------------------------------------------
check_dates() {
  echo "== 검사 2: 확인일 형식 (${DOC_SCOPE}) =="
  local bad=0 found=0 line file date_str
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    found=$((found + 1))
    file="${line%%:*}"
    date_str=$(printf '%s' "$line" | grep -oE '[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}' | head -1)
    if [ -z "$date_str" ]; then
      printf '  BADFORM  %s\n           %s\n' "$file" "$(printf '%s' "$line" | cut -c1-110)"
      bad=$((bad + 1))
      continue
    fi
    if ! is_real_date "$date_str"; then
      printf '  BADDATE  %s  -> %s\n' "$file" "$date_str"
      bad=$((bad + 1))
    fi
  done < <(grep -rnE '(확인|checked) [0-9]' "$DOC_SCOPE" 2>/dev/null)

  if [ "$found" -eq 0 ]; then
    echo "  FAIL - 확인일 표기(확인/checked)가 하나도 없습니다."
    return 1
  fi
  if [ "$bad" -eq 0 ]; then
    echo "  OK - 확인일 ${found}건 전부 유효"
    return 0
  fi
  echo "  ${found}건 중 ${bad}건 오류"
  return 1
}

# ---------------------------------------------------------------------------
# 검사 3 — 문서 줄 수 (오프라인)
# instructions/README.md 원칙 6: 상위 문서는 200-300줄 이내
# return 0 = 이상 없음 / 1 = 문제 발견
# ---------------------------------------------------------------------------
check_lines() {
  echo "== 검사 3: 문서 줄 수 (<= ${MAX_LINES}) =="
  local over=0 n f
  while IFS= read -r f; do
    n=$(wc -l < "$f" | tr -d ' ')
    if [ "$n" -gt "$MAX_LINES" ]; then
      printf '  TOOLONG  %s  %s줄\n' "$f" "$n"
      over=$((over + 1))
    fi
  done < <(find "$DOC_SCOPE" -name '*.md' -type f 2>/dev/null | sort)

  if [ "$over" -eq 0 ]; then
    echo "  OK - 모든 문서가 ${MAX_LINES}줄 이내"
    return 0
  fi
  echo "  ${over}개 문서가 한계 초과"
  return 1
}

# ---------------------------------------------------------------------------
# Self-test — 각 검사가 실제로 실패를 잡는지 증명한다.
#
# 통과만 하고 아무것도 잡지 못하는 검사는 없는 것보다 나쁘다.
# 검사마다 negative case를 1개씩 주입하고 return code로 판정한다.
# (출력 문자열 grep은 로케일에 취약하므로 쓰지 않는다.)
# ---------------------------------------------------------------------------
run_self_test() {
  local failures=0 probe="instructions/__selftest__.md"
  # shellcheck disable=SC2064
  trap "rm -f '$probe'" EXIT

  echo "== self-test: 각 검사의 실효성 검증 =="
  echo

  # (1) 링크 검사 — 존재하지 않는 호스트
  printf '# selftest\n\nhttps://example.invalid/definitely-not-real\n' > "$probe"
  LINK_SCOPE="$probe"
  if check_links >/dev/null 2>&1; then
    echo "  FAIL  링크 검사가 죽은 URL을 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  링크 검사가 죽은 URL을 검출했습니다"
  fi
  LINK_SCOPE="instructions"
  rm -f "$probe"

  # (2) 확인일 검사 — 존재하지 않는 날짜(13월 45일)
  printf '# selftest\n\n출처 (확인 2026-13-45)\n' > "$probe"
  DOC_SCOPE="$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  FAIL  확인일 검사가 잘못된 날짜를 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  확인일 검사가 잘못된 날짜를 검출했습니다"
  fi
  rm -f "$probe"

  # (3) 줄 수 검사 — 한계 초과 파일
  seq 1 $((MAX_LINES + 10)) > "$probe"
  if check_lines >/dev/null 2>&1; then
    echo "  FAIL  줄 수 검사가 초과 문서를 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  줄 수 검사가 초과 문서를 검출했습니다"
  fi
  DOC_SCOPE="instructions"
  rm -f "$probe"

  # (4) 역방향 확인 — 정상 입력에서 오탐이 없어야 한다
  printf '# selftest\n\n출처 (확인 2026-07-29)\n' > "$probe"
  DOC_SCOPE="$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  PASS  확인일 검사가 정상 날짜를 오탐하지 않았습니다"
  else
    echo "  FAIL  확인일 검사가 정상 날짜를 오탐했습니다"; failures=$((failures + 1))
  fi
  DOC_SCOPE="instructions"
  rm -f "$probe"

  # (4b) 영어 표기 확인일 — 잘못된 영어 날짜도 검출해야 한다
  printf '# selftest\n\n출처 (checked 2026-13-45)\n' > "$probe"
  DOC_SCOPE="$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  FAIL  영어 표기 확인일의 잘못된 날짜를 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  영어 표기 확인일의 잘못된 날짜를 검출했습니다"
  fi
  DOC_SCOPE="instructions"
  rm -f "$probe"

  echo

  # (5) 예시 URL 제외 — 예시만 있으면 실패하지 않아야 한다
  printf '# selftest\n\nhttps://example.com/SKILL.md\nhttp://127.0.0.1:8080\n' > "$probe"
  LINK_SCOPE="$probe"
  if check_links >/dev/null 2>&1; then
    echo "  PASS  예시 URL을 링크 검사에서 제외했습니다"
  else
    echo "  FAIL  예시 URL을 죽은 링크로 오탐했습니다"; failures=$((failures + 1))
  fi
  LINK_SCOPE="instructions"
  rm -f "$probe"

  echo

  # (6) 디렉터리 범위 — 코드 블록 처리가 디렉터리 수집을 깨뜨리지 않아야 한다
  local probe_dir="instructions/__selftest_dir__"
  mkdir -p "$probe_dir"
  # shellcheck disable=SC2016  # Markdown fence를 리터럴로 넣는다(확장 의도 없음)
  printf '# selftest\n\n```bash\nhttps://example.com/example-only\n```\n\nhttps://example.invalid/in-a-directory\n' > "$probe_dir/probe.md"
  LINK_SCOPE="$probe_dir"
  if check_links >/dev/null 2>&1; then
    echo "  FAIL  디렉터리 범위에서 죽은 URL을 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  디렉터리 범위에서도 죽은 URL을 검출했습니다"
  fi
  rm -rf "$probe_dir"
  LINK_SCOPE="instructions"

  echo

  # (7) fence 형태 — ~~~와 들여쓴 ``` 안의 URL도 제외해야 한다
  # shellcheck disable=SC2016  # Markdown fence를 리터럴로 넣는다(확장 의도 없음)
  printf '# selftest\n\n~~~bash\nhttps://example.invalid/tilde-fence\n~~~\n\n   ```bash\n   https://example.invalid/indented-fence\n   ```\n\nhttps://example.invalid/outside-fence\n' > "$probe"
  LINK_SCOPE="$probe"
  out=$(check_links 2>&1 || true)
  # 검사 결과 줄(DEAD/MOVED/STATUS)만 본다. advisory 목록은 제외 대상이므로 판정에서 뺀다.
  verdicts=$(printf '%s\n' "$out" | grep -E '^  (DEAD|MOVED|STATUS|BADDATE)' || true)
  if printf '%s' "$verdicts" | grep -q 'outside-fence' && ! printf '%s' "$verdicts" | grep -q 'tilde-fence' && ! printf '%s' "$verdicts" | grep -q 'indented-fence'; then
    echo "  PASS  ~~~와 들여쓴 fence를 인식했습니다"
  else
    echo "  FAIL  fence 형태를 잘못 인식했습니다"; failures=$((failures + 1))
  fi
  # 건너뛴 URL은 advisory로 보고되어야 한다(조용한 제외 금지)
  if printf '%s' "$out" | grep -q '건너뜀' && printf '%s' "$out" | grep -q 'tilde-fence'; then
    echo "  PASS  건너뛴 URL을 advisory로 보고했습니다"
  else
    echo "  FAIL  건너뛴 URL이 조용히 사라졌습니다"; failures=$((failures + 1))
  fi
  LINK_SCOPE="instructions"
  rm -f "$probe"

  echo

  # (8) 대문자 URL 스킴도 수집해야 한다
  printf '# selftest\n\n출처: HTTPS://example.invalid/uppercase-scheme\n' > "$probe"
  LINK_SCOPE="$probe"
  if check_links >/dev/null 2>&1; then
    echo "  FAIL  대문자 URL 스킴을 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  대문자 URL 스킴도 검출했습니다"
  fi
  LINK_SCOPE="instructions"
  rm -f "$probe"

  echo
  if [ "$failures" -eq 0 ]; then
    echo "self-test 통과 - 10개 케이스 모두 기대대로 동작합니다."
    return 0
  fi
  echo "self-test 실패 - ${failures}개 케이스가 기대와 다릅니다."
  return 1
}

main() {
  if [ "$SELF_TEST" -eq 1 ]; then
    run_self_test
    exit $?
  fi

  local fail_offline=0 fail_link=0

  check_dates || fail_offline=1
  echo
  check_lines || fail_offline=1
  echo

  if [ "$OFFLINE" -eq 1 ]; then
    echo "== 검사 1: 링크 - 생략됨 (--offline) =="
  else
    check_links || fail_link=1
  fi
  echo

  echo "== 요약 =="
  if [ "$fail_offline" -ne 0 ]; then
    echo "오프라인 검사 실패 (strict)"
    exit 1
  fi
  if [ "$fail_link" -ne 0 ]; then
    if [ "$STRICT" -eq 1 ]; then
      echo "링크 검사 실패 (--strict)"
      exit 1
    fi
    echo "링크 검사에 문제가 있으나 advisory 모드입니다. 게이트로 쓰려면 --strict 를 사용하세요."
    exit 0
  fi
  echo "전부 통과"
  exit 0
}

main
