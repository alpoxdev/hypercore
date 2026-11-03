#!/usr/bin/env bash
# check-sources.sh — instructions/ 문서의 출처 무결성 검사
#
# 검사 항목
#   1. link   (네트워크) 인용 URL이 이전(3xx)되지 않았는가. HEAD를 거부하는 서버는 GET으로 재확인한다.
#             예시 URL과 코드 블록 안의 URL은 제외한다
#   2. date   (오프라인) `Checked YYYY-MM-DD` / `확인 YYYY-MM-DD` 표기가 실재하는 ISO 날짜인가
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
    -h|--help)   sed -n '2,21p' "$0"; exit 0 ;;
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
  local out
  # 정규화 값을 받아들이는 date 구현이 있으므로(2026-02-30 -> 2026-03-02)
  # 출력이 입력과 같은지까지 확인한다.
  out=$(date -j -f '%Y-%m-%d' "$1" '+%Y-%m-%d' 2>/dev/null) && [ "$out" = "$1" ] && return 0
  out=$(date -d "$1" '+%Y-%m-%d' 2>/dev/null) && [ "$out" = "$1" ] && return 0
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
# 일부 서버는 HEAD를 아예 거부한다. nvlpubs.nist.gov는 HEAD에 404, GET에 200을
# 돌려준다(2026-11-04 실측). HEAD 결과만 믿으면 살아 있는 링크를 죽었다고 보고하고,
# 그 오탐을 피하려고 인용을 다른 페이지로 바꾸는 일이 생긴다. 그래서 HEAD가
# 400/404/405/501이면 본문을 저장하지 않는 GET(-o /dev/null)으로 한 번 더 확인하고
# GET 결과로 판정한다. 재확인은 URL당 1회다.
#
# return 0 = 이상 없음 / 1 = 문제 발견
# ---------------------------------------------------------------------------

# 한 URL의 상태를 확인하고 결과를 전역 변수에 남긴다.
#   RESOLVED_CODE     상태 코드 (curl과 같은 규칙으로 000은 실패)
#   RESOLVED_METHOD   head | get — 판정에 쓴 요청
#   RESOLVED_REDIRECT GET으로 확인했을 때 3xx의 즉시 목적지(Location)
resolve_url() {
  RESOLVED_METHOD="head"
  RESOLVED_REDIRECT=""
  RESOLVED_CODE=$(curl -sI -o /dev/null -w '%{http_code}' --max-time "$TIMEOUT" "$1" 2>/dev/null)
  case "$RESOLVED_CODE" in
    400|404|405|501)
      RESOLVED_METHOD="get"
      # -L을 주지 않으므로 즉시 응답의 상태 코드와 Location을 함께 받는다.
      read -r RESOLVED_CODE RESOLVED_REDIRECT <<< "$(curl -s -o /dev/null -w '%{http_code} %{redirect_url}' --max-time "$TIMEOUT" "$1" 2>/dev/null)"
      ;;
  esac
}

# 3xx를 따라간 최종 주소. 판정에 쓴 메서드를 그대로 쓴다(HEAD를 거부하는 서버는 GET으로 따라간다).
final_url() {
  if [ "$1" = get ]; then
    curl -s -o /dev/null -w '%{url_effective}' -L --max-time "$TIMEOUT" "$2" 2>/dev/null
  else
    curl -sI -o /dev/null -w '%{url_effective}' -L --max-time "$TIMEOUT" "$2" 2>/dev/null
  fi
}

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
    resolve_url "$url"
    code="$RESOLVED_CODE"
    case "$code" in
      200|403|405|429)
        # HEAD를 거부한 서버를 GET으로 통과시킨 사실은 숨기지 않고 한 줄 남긴다.
        if [ "$RESOLVED_METHOD" = get ]; then
          printf '  GETOK    %s  (HEAD는 거부, GET %s)\n' "$url" "$code"
        fi ;;
      3??)
        final=$(final_url "$RESOLVED_METHOD" "$url")
        [ -n "$final" ] || final="$RESOLVED_REDIRECT"
        printf '  MOVED    %s  %s\n           -> %s\n' "$code" "$url" "$final"
        moved=$((moved + 1)) ;;
      000)
        printf '  DEAD     ---  %s  (타임아웃 또는 DNS 실패)\n' "$url"
        moved=$((moved + 1)) ;;
      *)
        if [ "$RESOLVED_METHOD" = get ]; then
          printf '  STATUS   %s  %s  (HEAD는 거부, GET도 같은 상태)\n' "$code" "$url"
        else
          printf '  STATUS   %s  %s\n' "$code" "$url"
        fi
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
# 한 줄에 표기가 둘 이상이면 표기마다 검사한다. 첫 값만 보면 뒤쪽 오류가 숨는다.
# return 0 = 이상 없음 / 1 = 문제 발견
# ---------------------------------------------------------------------------
check_dates() {
  echo "== 검사 2: 확인일 형식 (${DOC_SCOPE}) =="
  local bad=0 found=0 line file marks tokens token_n token bad_form bad_date
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    found=$((found + 1))
    file="${line%%:*}"
    # 표기 뒤 토큰을 통째로 뽑아 끝의 문장부호만 떼어 낸다. 접두사 10자만 보면
    # `2026-11-031`·`2026-11-03abc`·`2026-11-03-`가 전부 통과한다.
    marks=$(printf '%s' "$line" | grep -oiE '(확인|checked)[[:space:]]+[0-9]' | grep -c .)
    tokens=$(printf '%s' "$line" | grep -oiE '(확인|checked)[[:space:]]+[0-9][^[:space:]]*' \
      | sed -E 's/.*[[:space:]]//; s/[.,;)]+$//')
    token_n=$(printf '%s' "$tokens" | grep -c .)
    if [ "$token_n" -lt "$marks" ]; then
      printf '  BADFORM  %s\n           %s\n' "$file" "$(printf '%s' "$line" | cut -c1-110)"
      bad=$((bad + 1))
      continue
    fi
    bad_form=""
    bad_date=""
    while IFS= read -r token; do
      [ -z "$token" ] && continue
      # 날짜 뒤에는 구분자만 올 수 있다. ASCII 문자·숫자·하이픈이 붙으면 형식 오류다
      # (한국어 조사는 붙여 쓰므로 `2026-11-03에`처럼 비ASCII가 붙는 것은 허용한다).
      if ! printf '%s' "$token" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}[^0-9A-Za-z_-]*$'; then
        bad_form="$bad_form $token"
      elif ! is_real_date "${token:0:10}"; then
        bad_date="$bad_date $token"
      fi
    done <<< "$tokens"
    if [ -n "$bad_form$bad_date" ]; then
      bad=$((bad + 1))
    fi
    [ -n "$bad_form" ] && printf '  BADFORM  %s  ->%s\n' "$file" "$bad_form"
    [ -n "$bad_date" ] && printf '  BADDATE  %s  ->%s\n' "$file" "$bad_date"
  done < <(grep -rniE '(확인|checked)[[:space:]]+[0-9]' "$DOC_SCOPE" 2>/dev/null)

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

  # (4c) 대문자 표기 — 문서는 `Checked`로 적으므로 검사가 대소문자를 구분하면 안 된다
  printf '# selftest\n\n출처 (Checked 2026-13-45)\n' > "$probe"
  DOC_SCOPE="$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  FAIL  대문자 표기 확인일의 잘못된 날짜를 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  대문자 표기 확인일의 잘못된 날짜를 검출했습니다"
  fi
  # 대문자 정상 날짜도 오탐 없이 통과해야 한다
  printf '# selftest\n\n출처 (Checked 2026-07-29)\n' > "$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  PASS  대문자 표기 확인일의 정상 날짜를 오탐하지 않았습니다"
  else
    echo "  FAIL  대문자 표기 확인일의 정상 날짜를 오탐했습니다"; failures=$((failures + 1))
  fi
  DOC_SCOPE="instructions"
  rm -f "$probe"

  # (4d) 엄격 형식 — 한 자리 월·일(`2026-1-2`)은 ISO 8601 YYYY-MM-DD가 아니므로 검출해야 한다
  printf '# selftest\n\n출처 (Checked 2026-1-2)\n' > "$probe"
  DOC_SCOPE="$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  FAIL  확인일 검사가 비ISO 날짜(2026-1-2)를 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  확인일 검사가 비ISO 날짜를 검출했습니다"
  fi
  DOC_SCOPE="instructions"
  rm -f "$probe"

  # (4e) 줄당 표기 여럿 — 첫 표기가 유효해도 뒤쪽 표기의 오류를 검출해야 한다
  printf '# selftest\n\n출처 (Checked 2026-11-03; 확인 2026-13-45)\n' > "$probe"
  DOC_SCOPE="$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  FAIL  같은 줄의 두 번째 확인일 오류를 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  같은 줄의 두 번째 확인일 오류를 검출했습니다"
  fi
  # 두 표기가 모두 유효하면 오탐이 없어야 한다
  printf '# selftest\n\n출처 (Checked 2026-11-03; 확인 2026-11-03)\n' > "$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  PASS  유효한 확인일 두 개를 오탐하지 않았습니다"
  else
    echo "  FAIL  유효한 확인일 두 개를 오탐했습니다"; failures=$((failures + 1))
  fi
  DOC_SCOPE="instructions"
  rm -f "$probe"

  # (4f) 달력에 없는 날짜 — 형식은 맞아도 실재하지 않으므로 검출해야 한다
  printf '# selftest\n\n출처 (확인 2026-02-30)\n' > "$probe"
  DOC_SCOPE="$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  FAIL  달력에 없는 날짜(2026-02-30)를 놓쳤습니다"; failures=$((failures + 1))
  else
    echo "  PASS  달력에 없는 날짜를 검출했습니다"
  fi
  DOC_SCOPE="instructions"
  rm -f "$probe"

  # (4g) 날짜 뒤에 문자가 붙은 표기 — 접두사 10자만 맞으면 통과시키면 안 된다
  for bad_mark in 'Checked 2026-11-031' '확인 2026-11-03abc' 'Checked 2026-11-03-'; do
    printf '# selftest\n\n출처 (%s)\n' "$bad_mark" > "$probe"
    DOC_SCOPE="$probe"
    if check_dates >/dev/null 2>&1; then
      echo "  FAIL  날짜 뒤 문자가 붙은 표기($bad_mark)를 놓쳤습니다"; failures=$((failures + 1))
    else
      echo "  PASS  날짜 뒤 문자가 붙은 표기($bad_mark)를 검출했습니다"
    fi
  done
  # 문장부호가 붙은 정상 표기는 계속 통과해야 한다
  printf '# selftest\n\n출처 (Checked 2026-11-03).\n' > "$probe"
  if check_dates >/dev/null 2>&1; then
    echo "  PASS  문장부호가 붙은 정상 표기를 오탐하지 않았습니다"
  else
    echo "  FAIL  문장부호가 붙은 정상 표기를 오탐했습니다"; failures=$((failures + 1))
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

  # (9) HEAD 거부 서버 fallback — 네트워크 없이 curl을 스텁으로 바꿔 증명한다.
  # 이 서버는 HEAD에 404, GET에 200을 돌려준다(nvlpubs.nist.gov와 같은 동작).
  # GET 재확인이 없으면 살아 있는 링크를 죽었다고 보고한다.
  curl() {
    local arg url head=0
    for arg in "$@"; do
      case "$arg" in
        -I|-sI) head=1 ;;
      esac
    done
    url="${!#}"
    if [ "$head" -eq 1 ]; then
      printf '404'
    else
      case "$url" in
        */dead-head*) printf '404 ' ;;
        *) printf '200 ' ;;
      esac
    fi
  }
  printf '# selftest\n\nhttps://head-refused.test/nist-publication\n' > "$probe"
  LINK_SCOPE="$probe"
  out=$(check_links 2>&1 || true)
  if check_links >/dev/null 2>&1; then
    echo "  PASS  HEAD 404 + GET 200 링크를 GET 재확인으로 통과시켰습니다"
  else
    echo "  FAIL  HEAD 404 + GET 200 링크를 죽은 링크로 오탐했습니다"; failures=$((failures + 1))
  fi
  if printf '%s' "$out" | grep -q '^  GETOK' && printf '%s' "$out" | grep -q 'nist-publication'; then
    echo "  PASS  HEAD 거부 링크를 GET으로 재확인했음을 보고했습니다"
  else
    echo "  FAIL  GET 재확인 경로가 실행되지 않았습니다"; failures=$((failures + 1))
  fi

  # (10) 재확인은 봐주기가 아니다 — HEAD와 GET이 모두 404면 계속 실패여야 한다
  printf '# selftest\n\nhttps://head-refused.test/dead-head\n' > "$probe"
  if check_links >/dev/null 2>&1; then
    echo "  FAIL  GET으로도 404인 링크를 통과시켰습니다"; failures=$((failures + 1))
  else
    echo "  PASS  GET 재확인 결과가 여전히 404면 실패로 판정했습니다"
  fi
  unset -f curl
  LINK_SCOPE="instructions"
  rm -f "$probe"

  echo
  if [ "$failures" -eq 0 ]; then
    echo "self-test 통과 - 모든 케이스가 기대대로 동작합니다."
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
