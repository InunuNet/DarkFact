---
description: Initialize a new project workspace from the DarkFact template
---

# Init

> **For new projects**: Use `darkfact` from the terminal — it clones the template,
> resets git, and opens your IDE. Then run `/onboard` inside your AI agent.
>
> **Already have a `DarkFact` clone?** Run `bash init.sh` to re-scaffold.

## Steps

### 1. Scaffold the workspace

```bash
bash init.sh
```

This creates:
- `.agent/` — agents, rules, memory, workflows, skills
- `execution/` — brain.py, sync_agents.sh
- `.gitignore`, symlinks, git remote to DarkFact upstream

### 2. Start onboarding

In your AI agent (Antigravity, Claude Code, or Gemini CLI):
```
/onboard
```

Vex will guide you through:
- Defining your project goal
- Choosing a tech stack
- Generating goals, backlog, and project rules

### 3. Verify the workspace

```bash
make audit
```

### 4. Sync agents

```bash
make sync-agents
```

### 5. Test brain

```bash
python3 execution/brain.py stats
```
