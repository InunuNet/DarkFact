# Session Log

Rolling log of work sessions. Most recent at top. Max 20 entries — drop oldest when full.

---

## 2026-04-16 — Fleet-wide v2.0.0 rollout + overlay hardening

- Merged PR #12 → v2.0.0 on main, closed #8 and #10 manually
- Fixed #14: overlay_template.sh cp -r → rsync --delete, dynamic TEMPLATE/version, added Makefile+CHANGELOG
- Fixed Stop hook in PortPulse + Mlilo (same bug as Mumbl AI — settings.json not in overlay)
- Added .claude/settings.json to overlay so hook drift can't recur across fleet
- Created overlay_all.sh — batch updater with ignore list, sorts closest-to-current first
- Ran fleet-wide overlay: 17/17 projects updated to v2.0.0, 0 failures
- Fleet status: all green, Codi RnI intentionally not onboarded (research project, user will onboard on next use)
- Workspace Template added to overlay ignore list (legacy original, different versioning)
Commits: 29cadf2 feat: overlay_all.sh | cb33f4e fix: overlay copies settings.json | c00ce32 fix: rsync --delete

## 2026-04-16 — DarkFact v2.0.0: Claude Code adapter + recurring issue detector

- Fixed #7 (complete Claude adapter), #8 (Stop→SessionEnd), #10 (memory path guards), #13 (spaces in project names)
- Built recurring issue detector: brain.py scan-blockers with escalation ladder (2x→research, 3x→pivot)
- Replaced .claude/skills/ symlink with real dir — Claude Code doesn't follow dir symlinks (L22)
- /simplify caught critical bugs twice: || true swallowing exit 2, unconditional empty blocker storage
- Closed PR #9 (superseded), opened PR #12 with 6 commits
- Added 4 lessons (L22–L25), updated backlog with 6 closed items
Commits: c586993 fix: skills dir symlinks | da2b330 fix: spaces in project names | b731a32 feat: recurring issue detector

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
