# Session Log

Rolling log of work sessions. Most recent at top. Max 20 entries — drop oldest when full.

---

## 2026-04-16 — Diagnostic only, gh CLI status check

- Verified gh CLI auth (BDauth, keyring, all scopes present)
- No code changes, no commits
Commits: 2607f67 fix: gemma-3 + designer | ef393ac fix: agent dirs | 19581ca chore: backlog

## 2026-04-15 — Agent model tiers confirmed, no changes

- Displayed final model assignments across Claude + Gemini for all 8 agents
- User reviewing tier assignments — no changes made this block
- No commits this block
Commits: 2607f67 fix: gemma-3 + designer | ef393ac fix: agent dirs | 19581ca chore: backlog

## 2026-04-15 — Gemini model update, symlink bug fixed

- sync_agents.sh: gemma-4 → gemma-3 for local tier
- designer.md symlink write-through bug found and fixed — now real files
- All 8 agents re-synced with correct Gemini 2.5 models
- L20 added: symlinks in .claude/agents/ cause write-through corruption
Commits: 2607f67 fix: gemma-3 + designer | ef393ac fix: agent dirs | 19581ca chore: backlog

## 2026-04-15 — Model tier review, no changes

- Reviewed current model_tier assignments across all 8 agents
- Flagged analyst/designer on pro as potentially over-specced
- Awaiting user decision before adjusting
- No commits this block
Commits: ef393ac fix: init.sh agent dirs | 19581ca chore: backlog | f8a4311 fix: Section 8

## 2026-04-15 — Agent team wiring fixed, v1.2.14 (closes #6/#7)

- init.sh now creates .claude/agents/, .gemini/agents/ before sync_agents runs
- All 8 agents synced with correct model_tier mappings on first init
- L20 added to learned.md — agent team was broken until dirs existed
- Pushed + tagged v1.2.14
Commits: ef393ac fix: init.sh agent dirs | 19581ca chore: backlog | f8a4311 fix: Section 8

## 2026-04-15 — Smoke test 9-phase plan drafted, awaiting approval

- Full 8-agent stack plan created for smoke test execution
- Phase 5 identified as manual (user runs T1/T2/T3 in CLI)
- No commits this block
Commits: 19581ca chore: backlog | f8a4311 fix: Section 8 | 8a9ace6 fix: brain.py #4

## 2026-04-15 — Bugs #4 and #5 fixed, pushed to GitHub

- #4: brain.py shutil fix — wrap-up no longer crashes on scratch subdirs
- #5: CLAUDE.md Section 8 added — PAI MEMORY/ writes redirected to DarkFact tiers
- Both issues closed on GitHub, pushed to origin
Commits: 19581ca chore: backlog | f8a4311 fix: Section 8 | 8a9ace6 fix: brain.py #4

## 2026-04-15 — Backlog review, no changes

- Reviewed and presented full backlog to user
- No commits, no file changes this block
Commits: d513210 docs: CLAUDE.md + memory updates | 924de0c feat: /wrap-up skill | 7fb1582 feat: designer agent

## 2026-04-15 — Bug triage, awaiting fix approval

- #4 and #5 added to backlog, prioritised above smoke test
- MumblAI partial impl of #5 noted as reference pattern
- No commits this block
Commits: d513210 docs: CLAUDE.md + memory updates | 924de0c feat: /wrap-up skill | 7fb1582 feat: designer agent

## 2026-04-15 — GitHub issues reviewed, two bugs found

- Issue #4: brain.py crash when scratch/ has subdirectory — fix ready to apply
- Issue #5: MEMORY/LEARNING paths should be project-local not ~/.claude — bigger scope
- No commits this block
Commits: d513210 docs: CLAUDE.md + memory updates | 924de0c feat: /wrap-up skill | 7fb1582 feat: designer agent

## 2026-04-15 — /wrap-up skill created (v1.2.13)

- .agent/skills/wrap-up.md created — /wrap-up now works as slash command
- Auto-symlinked into .claude/skills/ and .gemini/skills/
Commits: 924de0c feat: /wrap-up skill | 7fb1582 feat: designer agent | 0141b71 feat: status:archive

## 2026-04-15 — Session wrap, moving locations

- Reviewed full backlog, presented human-readable plan
- No commits this block
Commits: 7fb1582 feat: designer agent | 0141b71 feat: status:archive + docs | e418a96 feat: session_log

## 2026-04-15 — Plan review, no changes

- Reviewed open backlog, presented prioritised plan to user
- No commits, no file changes this block
Commits: 7fb1582 feat: designer agent | 0141b71 feat: status:archive + docs | e418a96 feat: session_log

## 2026-04-15 — Smoke test T4+T5 pass, T1-T3 pending manual run

- T4 (archive warning): PASS — boot correctly warns on status=archive
- T5 (crash recovery): PASS — checkpoint detection fires, outputs correct message
- T1/T2/T3 pending manual run by user in fresh SmokeTest project
- Designer agent committed and pushed (v1.2.12)
Commits: 7fb1582 feat: designer agent | 0141b71 feat: status:archive + docs | e418a96 feat: session_log

## 2026-04-15 — Designer agent added as 8th team member (v1.2.12)

- .agent/agents/designer.md — UI/UX specialist, a11y rules, design defaults
- CLAUDE.md agent table updated 7→8, profile.json agents list updated
- onboard.md — designer auto-activates for webapp/mobile/macos soul types
- Symlinked into .claude/agents/ and .gemini/agents/
Commits: 7fb1582 feat: designer agent | 0141b71 feat: status:archive + docs | e418a96 feat: session_log

## 2026-04-15 — Morning backlog review, no code changes

- Reviewed open backlog, prioritised smoke test + markitdown + gh prompt + bash docs
- No commits this session
Commits: 0141b71 feat: status:archive + docs | e418a96 feat: session_log | a34c4d3 feat: soul_type

## 2026-04-14 — v1.2.10–v1.2.11 docs, archive status, CLI picker, smoke test

- session_log.md created and wired into Stop hook + boot recall
- status:archive field added to profile.json, boot step 0 warns if set
- workflows/headless.md — claude/gemini/codex headless patterns + session budgets
- workflows/parallelism.md — per-provider capability matrix + agent team implications
- workflows/smoke_test.md — T1–T5 manual test plan across all 3 CLIs
- darkfact() shell function updated — Claude Code | Gemini CLI | Codex | Terminal picker
- L18/L19 added to learned.md (hook scoping, Stop fires per response)
Commits: 0141b71 feat: status:archive + docs | e418a96 feat: session_log | a34c4d3 feat: soul_type

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
