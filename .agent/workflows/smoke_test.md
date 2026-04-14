---
description: Smoke test — verify DarkFact boot, /boot, /onboard, and wrap-up on all 3 CLIs
---

# Smoke Test

Manual test plan to verify DarkFact works end-to-end on Claude Code, Gemini CLI, and Codex.
Run after any significant template change or before a version release.

## Setup

Create a fresh test project from the template:

```bash
# Use darkfact() to scaffold
darkfact
# Name: SmokeTest
# Provider: Terminal only (we'll open each CLI manually)
```

---

## Test Suite

### T1 — Boot (all providers)

**Steps:**
1. Open the project in the CLI
2. Observe SessionStart hook output (Claude/Gemini only)
3. Run `/boot` manually

**Pass criteria:**
- [ ] WORKSPACE file read correctly
- [ ] profile.json identity check passes
- [ ] brain last-session runs (returns "no sessions yet" on fresh project — acceptable)
- [ ] goals.md, learned.md, backlog.md read without error
- [ ] git remotes check shows `darkfact-upstream`
- [ ] Status report printed with correct project name

**Per provider:**
| Provider | SessionStart auto-boot? | /boot manual? |
|----------|------------------------|---------------|
| Claude Code | ✅ Should auto-prompt /boot | ✅ |
| Gemini CLI | ✅ Should echo reminder | ✅ |
| Codex | ❌ No hooks — manual only | ✅ |

---

### T2 — Onboard (Claude Code only)

**Steps:**
1. Run `/onboard`
2. Answer questions as a test user: name=Tester, goal="Build a Python CLI tool"
3. Confirm stack: Python + typer

**Pass criteria:**
- [ ] Vex introduces herself correctly
- [ ] Clarifying questions asked (1-3 max)
- [ ] Stack recommendation: Python + typer
- [ ] goals.md written with mission + goals
- [ ] backlog.md written with Phase 1 items
- [ ] profile.json updated: project_name, project_type, soul_type, tech_stack, onboarding_complete=true
- [ ] soul.md rewritten for Python domain
- [ ] user.md written with Tester's details
- [ ] rules.md written with Python-specific rules
- [ ] Step 6 symlinks created: `.claude/rules/` updated
- [ ] sync_agents.sh runs without error
- [ ] Checkpoint scratch file cleared after Step 9
- [ ] Brain remember called with onboarding summary

---

### T3 — Wrap-up (Claude Code + Gemini)

**Steps:**
1. Make a small change (add a line to backlog.md)
2. End the session (Claude Code: `/exit` or close; Gemini: `exit`)

**Pass criteria:**
- [ ] Stop hook fires (Claude Code)
- [ ] session_log.md gets new entry appended
- [ ] brain wrap-up runs and confirms storage
- [ ] SessionEnd hook fires (Gemini) — shows wrap-up reminder

---

### T4 — Archive warning

**Steps:**
1. Set `"status": "archive"` in profile.json
2. Run `/boot`

**Pass criteria:**
- [ ] Boot prints `⚠️ WARNING: This workspace is ARCHIVED`
- [ ] Boot continues (does not stop)
- [ ] Reset to `"status": "active"` after test

---

### T5 — Crash recovery (onboard checkpoint)

**Steps:**
1. Manually create a fake checkpoint:
```bash
mkdir -p .agent/memory/scratch
echo '{"workflow":"onboard","last_step":5,"steps_complete":[1,2,3,4,5],"status":"in_progress","started":"2026-01-01T00:00:00"}' \
  > .agent/memory/scratch/checkpoint_onboard_state.json
```
2. Run `/onboard`

**Pass criteria:**
- [ ] Onboard detects existing checkpoint
- [ ] Reports "Incomplete onboard found — last step: 5"
- [ ] Asks: resume or restart?
- [ ] Resume → skips steps 1-5
- [ ] Restart → deletes checkpoint, starts fresh

---

## Results Log

| Date | Provider | T1 | T2 | T3 | T4 | T5 | Notes |
|------|----------|----|----|----|----|----|----|
| — | Claude Code | — | — | — | — | — | Not yet run |
| — | Gemini CLI | — | — | — | — | — | Not yet run |
| — | Codex | — | — | — | — | — | Not yet run |
