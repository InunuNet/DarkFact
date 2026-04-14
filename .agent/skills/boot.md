---
description: Boot the project — load all context, verify workspace, recall last session
---

# /boot

Run the full DarkFact boot sequence. Use this at session start or any time you need to force a full context reload.

## Steps

### 1. Verify workspace boundary

```bash
cat WORKSPACE 2>/dev/null || echo "MISSING"
pwd && cat .agent/profile.json | python3 -c "import sys,json; p=json.load(sys.stdin); print('Project:', p.get('project_name','UNKNOWN'), '| Onboarded:', p.get('onboarding_complete', False))"
```

If `WORKSPACE` is missing or names don't match the directory → **STOP**. Tell the user to open this project in its own IDE window.

### 2. Last session recall

```bash
python3 execution/brain.py last-session --quiet
```

### 3. KI recall (cross-project patterns)

```bash
python3 execution/ki_recall.py "$(cat .agent/profile.json | python3 -c "import sys,json; p=json.load(sys.stdin); print(p.get('project_type','general'))")" --n 3 2>/dev/null || true
```

Non-blocking — skip if no results.

### 4. Read project context

Read these files:
- `.agent/memory/project/goals.md`
- `.agent/memory/project/learned.md`
- `.agent/memory/project/backlog.md` (if exists)

### 5. Brain recall

```bash
python3 execution/brain.py recall "current work" --n 3
```

### 6. Git remotes check

```bash
git remote -v
```

Every project needs `origin` (your repo) and `darkfact-upstream` (template). Warn if either is missing.

### 7. Report status

Summarise in the standard boot output:
```
✅ WORKSPACE: [name]
✅ Last session: [one line]
📋 Active goals: [count]
🔧 Open backlog items: [count]
➡️ Ready. What are we working on?
```

If `onboarding_complete: false` → prompt user to run `/onboard` first.
