# DarkFact Changelog

## [2.0.0] — 2026-04-16

### Complete Claude Code Adapter + Fleet Hardening

**Breaking**: SessionEnd hook replaces Stop hook name in all docs and rules.

### Added
- 8th canonical agent: `designer` (UI/UX design, component specs, accessibility. Never implements.)
- `scan-blockers` command in `brain.py` — detects recurring issues across sessions
- `overlay_all.sh` — batch updater to apply template changes across downstream fleet
- `overlay_template.sh` hardened: rsync `--delete` flag, `settings.json` now included in overlay
- PreToolUse guards in Claude Code hooks: workspace verify before destructive tool calls
- `verify_workspace.sh` — standalone workspace identity check used by PreToolUse hook
- Parallel-by-default added as core rule #1 in CLAUDE.md

### Changed
- SessionEnd hook (Claude Code): previously documented as auto-firing maintainer agent — corrected to `git diff --stat HEAD` + manual wrap-up reminder
- `.claude/skills/` and `.gemini/skills/` are now real directories (not symlinks) — Claude Code does not follow directory symlinks
- All version strings bumped from v1.1.0 → v2.0.0

### Fixed
- `brain.py` wrap-up crash on scratch subdirectory (closes #4)
- Memory paths: PAI writes redirected to DarkFact tiers, never `~/.claude/MEMORY/` (closes #5)
- `init.sh` now creates platform agent dirs before `sync_agents.sh` runs (closes #6, #7)
- `sync_agents.sh` correctly wires full 8-agent team including designer

---

## [1.0.0] — 2026-04-14

### Clean Slate — Native-First Architecture

**Philosophy**: Leverage native platform features (hooks, agents, skills, memory) instead of custom scripts. Config over code.

### Added
- 7 canonical agents: lead, dev, analyst, architect, qa, docs, maintainer
- Claude Code hooks: SessionStart (brain recall), Stop (maintainer auto-wrap-up)
- Gemini CLI hooks: SessionStart (brain recall), SessionEnd (wrap-up reminder)
- `sync_agents.sh` — generates platform-specific agent configs from canonical defs
- `brain.py` — new commands: last-session, export, import, compact
- TELOS-lite: goals.md + learned.md for persistent project context
- Self-improving maintainer agent via Stop hook
- Docs agent for automated documentation

### Removed
- `boot.sh` (262 lines) — replaced by native SessionStart hooks
- `secrets_check.py` — replaced by native permission ask lists
- `antigravity.md`, `context_prep.md`, `manage_memory.md` rules — stale factory references
- Factory dispatch system (dispatch_async.py, factory_daemon.py, etc.)
- LM Studio integration
- update_template.py, memory_manager.py, memory_consolidate.py

### Changed
- `AGENTS.md` — complete rewrite, native-first instructions
- `profile.json` — clean DarkFact identity
- All workflows (boot, wrap-up, init, audit, test) — simplified for native-first
- `.gitignore` — added Claude/Gemini local config patterns
