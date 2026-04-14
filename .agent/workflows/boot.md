---
description: Load project context at session start
---

# Boot

## Steps

### 0. Verify workspace boundary ⚠️ — DO THIS BEFORE ANYTHING ELSE

Two-layer check. Both must pass:

**Layer 1 — WORKSPACE file** (hard identity marker):
```bash
cat WORKSPACE 2>/dev/null || echo "MISSING"
```
If `WORKSPACE` is missing → this project was not properly scaffolded. Run `bash init.sh` first.
If `WORKSPACE` contains a project name that doesn't match the directory you're in → **STOP immediately.**

**Layer 2 — profile.json** (config cross-check):
```bash
pwd && cat .agent/profile.json | python3 -c "import sys,json; p=json.load(sys.stdin); print('Project:', p.get('project_name','UNKNOWN'))"
```

**If either check fails — STOP. Do not proceed.**
Tell the user: "I'm the [WORKSPACE project] coordinator. You've opened [other directory] in the same window.
Please open [other directory] in its **own separate IDE window**."

> ⛔ This is not optional. Cross-project edits are the #1 source of data loss in this fleet.
> Each DarkFact project must run in its own IDE window/session. No exceptions.

---

1. **Check last session**:
```bash
python3 execution/brain.py last-session
```

2. **Check Antigravity KI store** for cross-project patterns relevant to this project:
```bash
python3 execution/ki_recall.py "PROJECT_TYPE_OR_TOPIC" --n 3
```
> Non-blocking — if no KIs found, proceed. KIs surface reusable patterns from past work
> (e.g., "SwiftUI audio pipeline", "FastAPI async", "Ubuntu systemd").
> Skip if `~/.gemini/antigravity/knowledge/` is empty.

3. **Read project context**:
- `.agent/memory/project/goals.md`
- `.agent/memory/project/learned.md`
- `.agent/memory/project/backlog.md` (if exists)

4. **Check brain for relevant memories**:
```bash
python3 execution/brain.py recall "CURRENT_TASK" --n 3
```

4. **Check GitHub for user feedback** (DarkFact sessions only):
```bash
make check-feedback
```

> **Note**: In Claude Code and Gemini CLI, the SessionStart hook runs step 1 automatically. This workflow is for Antigravity and manual use.
