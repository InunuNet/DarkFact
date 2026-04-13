---
description: Load project context at session start
---

# Boot

## Steps

1. **Check last session**:
```bash
python3 execution/brain.py last-session
```

2. **Read project context**:
- `.agent/memory/project/goals.md`
- `.agent/memory/project/learned.md`
- `.agent/memory/project/backlog.md` (if exists)

3. **Check brain for relevant memories**:
```bash
python3 execution/brain.py recall "CURRENT_TASK" --n 3
```

> **Note**: In Claude Code and Gemini CLI, the SessionStart hook runs step 1 automatically. This workflow is for Antigravity and manual use.
