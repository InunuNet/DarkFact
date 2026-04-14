# DarkFact Changelog

## [1.2.0] — 2026-04-14

### Boot & Isolation
- `boot.md`: Added Step 0 — workspace boundary verification (pwd + profile.json check). Agents halt if project name mismatches the open directory.
- `boot.md`: Wired `ki_recall.py` into Step 2 for cross-project pattern recall. Non-blocking.
- `boot.md`: Fixed duplicate step 4 numbering.
- `AGENTS.md`: Added workspace isolation mandate — one IDE window per project.

### Onboarding
- `onboard.md`: Expanded stack heuristics from 5 to 13 types (added devops, financial, legal, security, fleet, and more).
- `onboard.md`: Added `soul_type` determination step with 8-row heuristic table.
- `onboard.md`: Profile update instruction hardened — "update ONLY stub fields, do NOT rewrite".
- `profile.json`: Added `soul_type` stub field (persona domain, independent of tech stack).
- `profile.json`: Added `_comment_project_type` with full enum (12 types).

### Maintainer Agent
- `maintainer.md`: Added Mid-Session Trigger pattern — dev/qa agents call maintainer after each Phase 1 task.
- `maintainer.md`: Added backlog tick-off rule — "always tick off completed items, a stale backlog misleads the team".

### Version
- `profile.json` + `.agent/version`: Bumped to `1.2.0`.

## [1.1.0] — 2026-04-14

### Onboarding + Isolation
- `/onboard` workflow: AI-guided questionnaire, tech stack heuristics, Vex persona
- `/resume` workflow: recovery from mid-onboarding crashes
- Rule isolation: `security.md`, `style_guide.md` opt-in via onboarding
- `AGENTS.md`: Vex identity, `/onboard` check on boot

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
