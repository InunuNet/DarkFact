# Session Log

Rolling log of work sessions. Most recent at top. Max 20 entries — drop oldest when full.

---

## 2026-04-14 — v1.2.7–v1.2.9 hardening + session_log pattern

- Created `.agent/skills/boot.md` — /boot now works as slash command on all platforms
- Upgraded Claude Code SessionStart hook to auto-prompt /boot; Gemini echo reminder
- Fixed onboard Step 6 — replaced bash comments with real symlink commands
- Documented checkpoint crash-resilience pattern in `workflows/checkpoint.md`
- Wired checkpoint into onboard.md (step 5 write + step 9 cleanup)
- Added `soul_type` stub to profile.json, wired into onboard + boot identity check
- Added smoke test + darkfact() CLI picker tasks to backlog
- Wired session_log into Stop hook and boot recall
- L18/L19 added to learned.md (hook scoping + Stop fires on every response)
Commits: a34c4d3 feat: soul_type | 521cba5 feat: checkpoint | daddd89 fix: onboard Step 6

<!-- SESSIONS -->
