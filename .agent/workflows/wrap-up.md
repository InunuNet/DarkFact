---
description: End-of-session wrap-up — persist context to brain
---

# Wrap-Up

## Steps

1. **Summarize** the session in 2-3 sentences — key decisions, outcomes, unresolved items.

2. **Store in brain**:
```bash
python3 execution/brain.py wrap-up --summary "SESSION_SUMMARY" --tags "relevant,tags"
```

3. **Update project memory** (if significant changes):
- Add lessons to `.agent/memory/project/learned.md`
- Update goals in `.agent/memory/project/goals.md`
- Add TODOs to `.agent/memory/project/backlog.md`

4. **Verify storage**:
```bash
python3 execution/brain.py last-session
```

> **Note**: In Claude Code, the `Stop` hook fires the maintainer agent which handles all of this automatically. This workflow is for Gemini CLI, Antigravity, and manual use.
