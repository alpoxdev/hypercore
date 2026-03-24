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

Use the smallest command set that proves the claim:

```bash
rg -n "process\\.env|import\\.meta\\.env|createServerFn|createServerOnlyFn|createClientOnlyFn" src app
rg -n "beforeLoad|validateSearch|params\\.parse|getSession|ensureSession|trustedOrigins|tanstackStartCookies|disableCSRFCheck|Set-Cookie" src app
rg -n "createServerRoute|webhook|signature|Cache-Control|Content-Security-Policy|Access-Control-Allow|rateLimit|rate-limit" src app
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

## Exit Criteria

- At least one explicit security surface was identified and hardened
- The changed behavior is backed by repository verification evidence
- Remaining risks are stated in stack-specific terms, not generic fear
- If SSR is in play, no sensitive loader/context data is serialized into hydration output
