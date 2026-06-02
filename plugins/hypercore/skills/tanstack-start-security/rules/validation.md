# Validation

> Review and verification gates for TanStack Start security work

## Security Review Order

1. Project actually uses TanStack Start
2. Auth/session surface
3. Secret/env and runtime boundary surface
4. Server route / header / webhook surface
5. App verification commands

## Must-Pass Questions

- Can any secret or privileged helper be imported from client-reachable code?
- Can a protected mutation be executed with forged client identity?
- Can a browser request mutate state without auth/origin/CSRF protection?
- Can a webhook or external callback be abused before signature validation?
- Did the hardening change break normal app behavior?

If any answer is uncertain, keep verifying.

## Suggested Commands

Use the smallest command set that proves the claim. The first command verifies that no `process.env` (or `import.meta.env`) access leaks into client-reachable code, and that privileged work uses `createServerFn` / `createServerOnlyFn` instead of escaping through `createClientOnlyFn`. Patterns are escaped (`process\.env`) for ripgrep.

```bash
rg -n "process\\.env|import\\.meta\\.env|createServerFn|createServerOnlyFn|createClientOnlyFn" src app
rg -n "beforeLoad|validateSearch|params\\.parse|getSession|ensureSession|trustedOrigins|tanstackStartCookies|disableCSRFCheck|Set-Cookie" src app
rg -n "createServerRoute|webhook|signature|Cache-Control|Content-Security-Policy|Strict-Transport-Security|X-Frame-Options|Access-Control-Allow|rateLimit|rate-limit" src app
test -f src/start.ts && sed -n '1,220p' src/start.ts
```

Then run the project checks appropriate to the repo:

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

Run only the commands that exist in the repository, but do not skip available verification just because the change seems small.

## Readback Checks

- The core `SKILL.md` stays readable without opening every support file
- Rules are discoverable from the core
- No rule duplicates the reference file verbatim
- Trigger examples are specific enough to avoid generic security-review overlap
- `src/start.ts` is reviewed when global request middleware or headers are relevant

## Logging Hygiene

- Do not log session tokens, API keys, raw cookies, password hashes, or other auth-bearing values. Redact before write.
- Do not log full PII (personally identifiable information) such as full email, phone, address, or government IDs unless the log sink is access-controlled and required by a documented audit policy. Prefer hashed or partial identifiers (`user_id`, last four digits) for diagnostics.
- Treat error messages echoed to the browser as another logging surface — do not include stack traces, SQL fragments, or internal IDs in production responses.

## Exit Criteria

- At least one explicit security surface was identified and hardened
- The changed behavior is backed by repository verification evidence
- Remaining risks are stated in stack-specific terms, not generic fear
- If SSR is in play, no sensitive loader/context data is serialized into hydration output
