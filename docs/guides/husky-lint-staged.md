# Husky + lint-staged

> Git 커밋 시 자동 코드 검사 및 포맷팅

---

## 🚀 Quick Reference

### 설치 (복사용)

```bash
# 패키지 설치
yarn add -D husky lint-staged

# Husky 초기화
npx husky init

# pre-commit 훅 설정
echo "npx lint-staged" > .husky/pre-commit
```

---

## 설치 단계별 가이드

### 1. 패키지 설치

```bash
yarn add -D husky lint-staged
```

### 2. Husky 초기화

```bash
npx husky init
```

이 명령어는:
- `.husky/` 디렉토리 생성
- `package.json`에 `prepare` 스크립트 추가
- 기본 `pre-commit` 훅 생성

### 3. pre-commit 훅 설정

```bash
echo "npx lint-staged" > .husky/pre-commit
```

---

## 설정 파일

### package.json

```json
{
  "scripts": {
    "prepare": "husky"
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "prettier --write"
    ],
    "*.{json,yml,yaml}": [
      "prettier --write"
    ],
    "*.{css,scss}": [
      "prettier --write"
    ]
  }
}
```

### 또는 .lintstagedrc.json (별도 파일)

```json
{
  "*.{js,jsx,ts,tsx}": [
    "prettier --write"
  ],
  "*.{json,yml,yaml}": [
    "prettier --write"
  ],
  "*.{css,scss}": [
    "prettier --write"
  ]
}
```

**주의**: `*.md` 파일은 lint-staged에서 제외 (Prettier가 테이블 등을 이상하게 변형함)

---

## 고급 설정

### TypeScript 타입 체크 포함

```json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "prettier --write",
      "bash -c 'tsc --noEmit'"
    ],
    "*.{js,jsx}": [
      "prettier --write"
    ]
  }
}
```

### ESLint 포함 (선택)

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}
```

### 테스트 포함 (선택)

```json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "prettier --write",
      "vitest related --run"
    ]
  }
}
```

---

## 디렉토리 구조

```
project/
├── .husky/
│   ├── _/
│   │   └── husky.sh
│   └── pre-commit        # 커밋 전 실행
├── package.json          # lint-staged 설정
└── .prettierrc           # Prettier 설정
```

---

## .husky/pre-commit 예시

### 기본 (lint-staged만)

```bash
npx lint-staged
```

### 추가 검사 포함

```bash
#!/bin/sh

# lint-staged 실행
npx lint-staged

# 타입 체크 (전체)
echo "Running type check..."
npx tsc --noEmit
```

---

## 작동 흐름

```
git commit -m "feat: 새 기능"
       ↓
.husky/pre-commit 실행
       ↓
lint-staged 실행
       ↓
스테이징된 파일만 처리:
  - *.ts, *.tsx → prettier --write
  - *.json, *.md → prettier --write
       ↓
변경된 파일 자동 스테이징
       ↓
커밋 완료
```

---

## 문제 해결

### 훅이 실행되지 않을 때

```bash
# Husky 재설치
rm -rf .husky
npx husky init
echo "npx lint-staged" > .husky/pre-commit
```

### 권한 문제

```bash
chmod +x .husky/pre-commit
```

### lint-staged 캐시 문제

```bash
# 캐시 삭제
rm -rf node_modules/.cache/lint-staged
```

### 훅 우회 (긴급 시에만)

```bash
git commit -m "fix: 긴급 수정" --no-verify
```

**주의**: `--no-verify`는 정말 긴급한 상황에서만 사용

---

## 팀 설정

### 새 팀원 온보딩

```bash
# 클론 후 실행
yarn install  # prepare 스크립트가 자동으로 husky 설정
```

### CI/CD에서 Husky 비활성화

```bash
# CI 환경에서
HUSKY=0 yarn install
```

또는 package.json:

```json
{
  "scripts": {
    "prepare": "husky || true"
  }
}
```

---

## 권장 설정 조합

### 최소 설정

```json
{
  "lint-staged": {
    "*": ["prettier --write --ignore-unknown"]
  }
}
```

### 표준 설정 (권장)

```json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": ["prettier --write"],
    "*.{json,yml,yaml,css,scss}": ["prettier --write"]
  }
}
```

### 엄격한 설정

```json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "prettier --write",
      "bash -c 'tsc --noEmit'"
    ],
    "*.{js,jsx}": ["prettier --write"],
    "*.{json,yml,yaml,css,scss}": ["prettier --write"]
  }
}
```

---

## 참고

- [Husky 공식 문서](https://typicode.github.io/husky/)
- [lint-staged 공식 문서](https://github.com/lint-staged/lint-staged)
- [Prettier 설정](./prettier.md)
