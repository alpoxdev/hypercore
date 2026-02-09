---
title: Audit Dependencies for Security Vulnerabilities
impact: MEDIUM
impactDescription: Prevent known CVE exploitation
tags: deps, security, audit, vulnerability, cve
languages: all
related: [deps-version-pin]
---

## 보안 취약점 스캔 및 업데이트

알려진 보안 취약점이 있는 의존성을 감지하고 업데이트합니다.

**스캔 도구:**

| 언어 | 도구 | 명령어 |
|------|------|--------|
| **JS/TS** | npm audit | `npm audit` / `npm audit fix` |
| **JS/TS** | yarn audit | `yarn npm audit` |
| **Python** | pip-audit | `pip-audit` |
| **Python** | safety | `safety check` |
| **Go** | govulncheck | `govulncheck ./...` |
| **Rust** | cargo-audit | `cargo audit` |
| **범용** | trivy | `trivy fs .` |
| **범용** | Snyk | `snyk test` |

**CI 통합:**

```yaml
# GitHub Actions
- name: Security audit
  run: npm audit --audit-level=high

# Dependabot (자동 PR)
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

**원칙:** CI에서 high/critical 취약점 발견 시 빌드 실패 설정.
