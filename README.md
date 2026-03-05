# Hypercore Agent Skills

This repository is structured to be compatible with:
- [`vercel-labs/agent-skills`](https://github.com/vercel-labs/agent-skills) style skill packages
- Agent Skills format and script guidance from [`agentskills.io`](https://agentskills.io/skill-creation/using-scripts)

## Repository layout

```text
skills/
  <skill-name>/
    SKILL.md
    scripts/      # optional
    references/   # optional
    assets/       # optional
scripts/
  new-skill.sh
  validate-skills.sh
```

## Quick start

1. Create a new local skill:

```bash
./scripts/new-skill.sh my-skill
```

2. Validate all local skills against the Agent Skills reference validator:

```bash
./scripts/validate-skills.sh
```

3. (Optional) Install Vercel's public skills to your local agent environment:

```bash
npx -y skills add vercel-labs/agent-skills
```

## Included example skill

- `skills/repo-snapshot`
- Demonstrates the `scripts/` pattern with a non-interactive Python script that returns structured JSON to stdout.
