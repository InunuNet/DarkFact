---
description: Load project context at session start
---

# Boot

## Steps

### 0. Verify workspace boundary ⚠️

Before doing ANYTHING, confirm you are in the correct project:

```bash
pwd && cat .agent/profile.json | python3 -c "import sys,json; p=json.load(sys.stdin); print('Project:', p.get('project_name','UNKNOWN'))"
```

**If the project name does not match the directory you were opened in — STOP.**
Tell the user: "I'm the [PROJECT] coordinator. You've opened [OTHER PROJECT] in the same window.
Please open [OTHER PROJECT] in its **own separate IDE window** so it gets its own isolated agent."

> Each DarkFact project must run in its own IDE window/session.
> Never act on a directory that isn't your assigned project root.

---

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

4. **Check GitHub for user feedback** (DarkFact sessions only):
```bash
make check-feedback
```

> **Note**: In Claude Code and Gemini CLI, the SessionStart hook runs step 1 automatically. This workflow is for Antigravity and manual use.
