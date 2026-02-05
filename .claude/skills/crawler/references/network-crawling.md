# Network 분석

> Playwriter로 인증 정보 추출 → NETWORK.md 문서화

---

<workflow>

```text
1. Playwriter로 페이지 탐방
2. API 인터셉트 → 엔드포인트/헤더/쿠키/토큰 추출
3. NETWORK.md에 문서화
4. 크롤러 코드 작성 시 활용
```

</workflow>

---

<cookie>

## 쿠키 추출

```bash
# 모든 쿠키
playwriter -s 1 -e "console.log(JSON.stringify(await context.cookies(), null, 2))"

# 인증 쿠키만
playwriter -s 1 -e $'
const cookies = await context.cookies();
console.log(cookies.filter(c =>
  ["session","token","auth","sid"].some(n => c.name.toLowerCase().includes(n))
));
'
```

</cookie>

---

<token>

## 토큰 추출

```bash
# localStorage
playwriter -s 1 -e "console.log(await state.page.evaluate(() => localStorage.getItem('token')))"

# sessionStorage
playwriter -s 1 -e "console.log(await state.page.evaluate(() => sessionStorage.getItem('accessToken')))"

# Authorization 헤더
playwriter -s 1 -e $'
state.page.on("request", req => {
  const auth = req.headers()["authorization"];
  if (auth) console.log("Auth:", auth);
});
'
```

</token>

---

<headers>

## 헤더 캡처

```bash
playwriter -s 1 -e $'
state.page.on("request", req => {
  if (req.url().includes("/api/"))
    console.log(JSON.stringify(req.headers(), null, 2));
});
'
```

</headers>

---

<bot_check>

## 봇 탐지 확인

```bash
playwriter -s 1 -e "console.log(await state.page.content().then(c => c.includes('cf-')))"

playwriter -s 1 -e $'
state.page.on("response", res => {
  if ([403, 429].includes(res.status()))
    console.log("차단:", res.status(), res.url());
});
'
```

</bot_check>

---

<template>

## NETWORK.md 템플릿

```markdown
# [사이트명] Network

## 인증

| 항목 | 값 | 만료 |
|------|-----|------|
| Cookie | `session=...` | 24h |
| Token | `Bearer ...` | 1h |

## 필수 헤더

\`\`\`json
{
  "Cookie": "...",
  "Authorization": "Bearer ...",
  "User-Agent": "Mozilla/5.0 ..."
}
\`\`\`

## Rate Limit

- 제한: 60 req/min
- 딜레이: 1000ms

## 봇 탐지

- [ ] Cloudflare
- [ ] reCAPTCHA

## 참고

- 봇 탐지 강함 → Nstbrowser
- 쿠키 만료 짧음 → 갱신 로직
```

</template>
