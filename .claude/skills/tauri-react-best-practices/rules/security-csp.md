# Content Security Policy 설정

## 왜 중요한가

Content Security Policy(CSP)는 웹 애플리케이션에서 실행 가능한 스크립트의 출처를 제한하여 XSS(Cross-Site Scripting) 공격을 방지합니다. Tauri 애플리케이션은 로컬 파일로 실행되지만, 외부 API 호출이나 사용자 입력을 처리할 때 여전히 XSS 위험이 있습니다. 강력한 CSP는 악의적인 스크립트가 실행되는 것을 원천 차단합니다.

## ❌ 잘못된 패턴

```html
<!-- index.html: CSP 미설정 -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>My App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

```html
<!-- index.html: 너무 관대한 CSP -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="Content-Security-Policy"
          content="default-src *; script-src * 'unsafe-inline' 'unsafe-eval'; style-src * 'unsafe-inline';" />
    <title>My App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

**문제점:**
- CSP 미설정: 모든 출처의 스크립트 실행 가능
- `unsafe-eval`: `eval()`, `Function()` 사용 가능 (동적 코드 실행)
- `unsafe-inline`: 인라인 스크립트/스타일 허용 (XSS 주입 가능)
- `default-src *`: 모든 리소스 출처 허용
- 공격자가 임의의 스크립트를 주입하여 Tauri API 호출 가능

## ✅ 올바른 패턴

```html
<!-- index.html: 기본 Tauri CSP -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="Content-Security-Policy"
          content="default-src 'self' tauri:; script-src 'self' tauri:; style-src 'self' tauri: 'unsafe-inline'; img-src 'self' tauri: data: https:;" />
    <title>My App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

**장점:**
- `default-src 'self' tauri:`: 로컬 리소스와 Tauri 프로토콜만 허용
- `script-src 'self' tauri:`: 외부 스크립트 차단
- `img-src ... https:`: 이미지는 HTTPS 외부 출처 허용
- `style-src ... 'unsafe-inline'`: CSS-in-JS 라이브러리 호환 (필요 시)
- 인라인 스크립트 차단으로 XSS 방어

**추가 예시 (외부 API 사용):**

```html
<!-- index.html: 외부 API와 nonce 사용 -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="Content-Security-Policy"
          content="default-src 'self' tauri:;
                   script-src 'self' tauri: 'nonce-random123';
                   connect-src 'self' https://api.example.com;
                   style-src 'self' tauri: 'unsafe-inline';
                   img-src 'self' tauri: data: https:;" />
    <title>My App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" nonce="random123" src="/src/main.tsx"></script>
  </body>
</html>
```

**추가 예시 (프로덕션 환경):**

```json
// tauri.conf.json
{
  "app": {
    "security": {
      "csp": "default-src 'self' tauri:; script-src 'self' tauri:; style-src 'self' tauri: 'unsafe-inline'; img-src 'self' tauri: data: https:; connect-src 'self' https://api.example.com"
    }
  }
}
```

## 추가 컨텍스트

**CSP 지시자 설명:**

| 지시자 | 설명 | Tauri 권장값 |
|-------|------|-------------|
| `default-src` | 모든 리소스의 기본 정책 | `'self' tauri:` |
| `script-src` | JavaScript 출처 | `'self' tauri:` (nonce 추가 가능) |
| `style-src` | CSS 출처 | `'self' tauri: 'unsafe-inline'` |
| `img-src` | 이미지 출처 | `'self' tauri: data: https:` |
| `font-src` | 폰트 출처 | `'self' tauri: data:` |
| `connect-src` | AJAX, WebSocket 출처 | `'self' https://api.example.com` |
| `media-src` | 오디오/비디오 출처 | `'self' tauri:` |

**특수 키워드:**

| 키워드 | 의미 | 사용 권장 |
|-------|------|----------|
| `'self'` | 현재 도메인 (tauri://localhost) | ✅ 필수 |
| `tauri:` | Tauri 프로토콜 (`asset:`, `ipc:`) | ✅ 필수 |
| `'unsafe-inline'` | 인라인 스크립트/스타일 허용 | ❌ script-src에는 금지 |
| `'unsafe-eval'` | eval() 허용 | ❌ 절대 금지 |
| `'nonce-xxx'` | 특정 nonce를 가진 스크립트만 | ✅ 동적 스크립트 시 권장 |
| `data:` | data: URI 허용 | ⚠️ img-src, font-src만 |
| `https:` | 모든 HTTPS 출처 | ⚠️ img-src만 허용 |

**React 앱 호환성:**

```html
<!-- Vite + React + Tauri -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <!-- Vite는 빌드 시 모듈 스크립트로 변환 -->
    <meta http-equiv="Content-Security-Policy"
          content="default-src 'self' tauri:;
                   script-src 'self' tauri:;
                   style-src 'self' tauri: 'unsafe-inline';
                   img-src 'self' tauri: data: https:;
                   connect-src 'self' https://api.example.com;" />
    <title>My App</title>
  </head>
  <body>
    <div id="root"></div>
    <!-- 모듈 스크립트는 기본적으로 안전 -->
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

**CSP 위반 디버깅:**

```typescript
// src/main.tsx
// CSP 위반 시 콘솔에 에러 출력
window.addEventListener('securitypolicyviolation', (e) => {
  console.error('CSP Violation:', {
    blockedURI: e.blockedURI,
    violatedDirective: e.violatedDirective,
    originalPolicy: e.originalPolicy,
  });
});
```

**점진적 강화 전략:**

1. **개발 단계**: 관대한 CSP로 시작
   ```
   default-src 'self' tauri:;
   script-src 'self' tauri: 'unsafe-inline';
   style-src 'self' tauri: 'unsafe-inline';
   ```

2. **테스트 단계**: `unsafe-inline` 제거, nonce 추가
   ```
   script-src 'self' tauri: 'nonce-${random}';
   ```

3. **프로덕션**: 최소 권한 CSP
   ```
   default-src 'self' tauri:;
   script-src 'self' tauri:;
   connect-src 'self' https://api.example.com;
   ```

**체크리스트:**
- [ ] CSP 헤더가 설정되어 있음
- [ ] `unsafe-eval` 사용 안 함
- [ ] `script-src`에 `unsafe-inline` 사용 안 함 (또는 nonce 사용)
- [ ] `connect-src`로 API 엔드포인트 명시
- [ ] 개발자 도구에서 CSP 위반 확인
- [ ] 프로덕션 빌드에서 CSP 테스트

**참조:**
- [Tauri Security CSP Guide](https://tauri.app/v2/security/#content-security-policy)
- [MDN CSP Reference](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [CSP Evaluator](https://csp-evaluator.withgoogle.com/)
