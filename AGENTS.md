> Single source of truth. CLAUDE.md and GEMINI.md are symlinks to this file.

# DarkFact — Agent Instructions

## 0. Boot (Mandatory)

Before doing anything:

1. Read `python3 execution/brain.py last-session --quiet` — what happened last session
2. Read `.agent/memory/project/goals.md` — what we're trying to achieve
3. Read `.agent/memory/project/learned.md` — what we've learned so far
4. If a backlog exists, read `.agent/memory/project/backlog.md`

> Never skip this. Context is everything.

## 1. Memory System

### Brain (Semantic Vector DB)

```bash
# Remember something
python3 execution/brain.py remember --summary "what happened" --tags "relevant,tags"

# Recall by topic
python3 execution/brain.py recall "search query" --n 5

# Session wrap-up (stores summary + clears scratch)
python3 execution/brain.py wrap-up --summary "session summary" --tags "tags"

# Last session (for boot)
python3 execution/brain.py last-session

# Export/Import (portability)
python3 execution/brain.py export > brain_backup.json
python3 execution/brain.py import brain_backup.json

# Stats
python3 execution/brain.py stats
```

### Memory Tiers

| Tier | Path | Purpose | Lifecycle |
|------|------|---------|-----------|
| **Scratch** | `.agent/memory/scratch/` | Working notes, temp data | Cleared on wrap-up |
| **Project** | `.agent/memory/project/` | Goals, lessons, backlog, rules | Persistent |
| **Brain** | `.agent/memory/brain/` | Semantic recall (Chroma) | Persistent |
| **Global** | Antigravity KI system | Cross-project patterns | Managed by IDE |

## 2. Rules

1. **CLI First** — use `curl`, `python`, `git`, shell. No browser UIs.
2. **Native First** — use platform features (hooks, agents, skills, MCP) before writing custom code.
3. **Least Tokens** — be terse. BLUF. Bullets over prose.
4. **No Placeholders** — write real implementations, not TODOs.
5. **Read Before Write** — check goals.md and learned.md before starting work.
6. **Self-Anneal** — error → fix → update learned.md. Pivot after 3 failed attempts.
7. **Wrap Up** — at session end, store a summary in brain. Claude does this automatically via Stop hook.

## 3. Structured Output (Recommended)

```
📋 TASK: [what you're doing]
🔍 ANALYSIS: [findings, context]
⚡ CHANGES: [files modified]
✅ RESULT: [outcome]
➡️ NEXT: [suggested follow-up]
```

## 4. Agents

7 canonical agents defined in `.agent/agents/`. Use `bash execution/sync_agents.sh` to generate platform-specific configs.

| Agent | Role |
|-------|------|
| **lead** | Plans, delegates, reviews. Never writes code. |
| **dev** | Code implementation. Follows architect's design. |
| **analyst** | Research + analysis. Read-only. |
| **architect** | Structural decisions. Returns decisions, not code. |
| **qa** | Testing + review. Reports pass/fail. |
| **docs** | Documentation. README, CHANGELOG, workflows. |
| **maintainer** | Self-improvement. Updates learned.md, goals.md, backlog. |

## 5. Provider Notes

### Claude Code
- Hooks wired in `.claude/settings.json` — SessionStart (brain recall) and Stop (maintainer agent)
- Agent Teams enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- Skills at `.claude/skills/` (symlinked to `.agent/skills/`)
- Continue: `claude -c` | Resume: `claude -r <id>` | Headless: `claude -p "prompt"`

### Gemini CLI
- Hooks wired in `.gemini/settings.json` — SessionStart (brain recall) and SessionEnd (wrap-up reminder)
- Skills at `.gemini/skills/` (symlinked to `.agent/skills/`)
- Resume: `--resume latest` | Headless: `gemini -p "prompt"` | Sandbox: `--sandbox`

### Antigravity
- No native hooks — use `/boot` and `/wrap-up` workflows manually
- Brain recall: `python3 execution/brain.py last-session`

### OpenCode
- Reads this file as AGENTS.md natively
- Headless: `opencode run "prompt"`
