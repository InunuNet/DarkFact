---
description: End-of-session wrap-up — persist context to brain
---

# Wrap-Up

## Steps

1. **Summarize** the session in 2-3 sentences — key decisions, outcomes, unresolved items.

2. **Tag blockers (if any)**:

   If the session hit any recurring issues, blockers, or unsolved problems — note them as blocker tags for the `--blockers` flag in the next step. Use short, kebab-case identifiers (e.g., `tauri-popup`, `webview-rendering`, `api-rate-limit`).

   If no blockers this session, skip this step.

3. **Store in brain**:
```bash
python3 execution/brain.py wrap-up --summary "SESSION_SUMMARY" --tags "relevant,tags" --blockers "blocker1,blocker2"
```

   Omit `--blockers` if no blockers this session.

4. **Update project memory** (if significant changes):
- Add lessons to `.agent/memory/project/learned.md`
- Update goals in `.agent/memory/project/goals.md` — mark done with `~~goal~~ ✅`
- **Tick off completed items** in `.agent/memory/project/backlog.md` (`- [ ]` → `- [x]`)
- Add new TODOs to backlog for anything discovered but not yet done

5. **Verify storage**:
```bash
python3 execution/brain.py last-session
```

> **Note**: In Claude Code, the `Stop` hook fires the maintainer agent which handles all of this automatically. This workflow is for Gemini CLI, Antigravity, and manual use.
