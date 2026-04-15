# Backlog

## TODO — v1.2.6+ (Next Patches)

### Bugs
- [x] **BUG: `profile.json` not updated during onboarding** — fixed in v1.2.6: Step 5 now has explicit `python3` atomic update command with FILL_IN placeholders and inline comments for security_rules/style_guide.
- [x] **BUG: `onboarding_complete` flag never set to `true`** — fixed in v1.2.6: new Step 9 sets it as the final named action.
- [x] **BUG: Step 6 (Activate rules) has no executable commands** — fixed: real symlink commands added for security.md and style_guide.md into .claude/rules/.
- [x] **BUG: `/boot` command doesn't work** — fixed in v1.2.7: `.agent/skills/boot.md` created, SessionStart hooks upgraded on Claude Code (auto-prompt) and Gemini CLI (echo reminder).

### Hardening
- [x] **ARCHITECTURE: Checkpoint pattern for crash resilience** — documented in workflows/checkpoint.md, wired into onboard.md (crash recovery check + step 5 checkpoint + step 9 cleanup).
- [x] **DOCS: Headless fallback for long tasks** — documented in workflows/headless.md with provider comparison, session budgets, and checkpoint integration.
- [x] **DOCS: Per-provider parallelism capability** — documented in workflows/parallelism.md with capability matrix and per-provider patterns.

### Features
- [x] **FEATURE: `soul_type` field in profile.json** — added stub to template default, wired into onboard Step 5, surfaced in boot identity check.
- [x] **FEATURE: `session_log.md` pattern** — rolling 20-entry log in memory/project/, wired into Stop hook and boot recall. First entry written.
- [x] **FEATURE: `status: archive` in profile.json** — stub added to template default, boot skill warns if status=archive before proceeding.
- [x] **BUG #4: `brain.py` wrap-up crashes on scratch subdirectory** — fixed: shutil.rmtree() for dirs, shutil import added. Closed #4. — `f.unlink()` fails on dirs. Fix: `shutil.rmtree(f)` if `f.is_dir()`. One line in `execution/brain.py` ~line 210.
- [x] **ISSUE #5: MEMORY/LEARNING paths must be project-local** — Section 8 added to CLAUDE.md, pattern from MumblAI. Closed #5. — Algorithm reflections writing to `~/.claude/MEMORY/LEARNING/` instead of `{PROJECT_ROOT}/MEMORY/LEARNING/`. Fix in CLAUDE.md Section 8 + boot directive. MumblAI already has partial implementation — pull pattern from there. More reports incoming from fleet projects.
- [ ] **FEATURE: `markitdown` recommended addon** — document PDF→Markdown conversion for research/legal soul types.

- [x] **FEATURE: Add `designer` agent to the 8-agent team** — designer.md created, CLAUDE.md + profile.json updated, onboard auto-activates for UI soul types, symlinked to Claude + Gemini.
- [ ] **BUG #6/#7: `.claude/agents/` not populated — agent team not wired** — `sync_agents.sh` targets `.claude/agents/` but dir doesn't exist in downstream projects. Global Claude Code built-ins fill the vacuum instead of DarkFact agents. `model_tier` is paper-only until fixed. Fix: ensure `init.sh` creates `.claude/agents/` + `.gemini/agents/` and `sync_agents.sh` populates them correctly. **Blocks smoke test Phase 1–4.**
- [ ] **TEST: Smoke test all 3 CLIs** — test plan written in workflows/smoke_test.md (T1-T5). Run manually against fresh project. Results table at bottom of smoke_test.md.
- [x] **FEATURE: `darkfact()` shell function — CLI picker** — updated ~/.zshrc: now presents Claude Code | Gemini CLI | Codex | Terminal with binary presence check for each.

## Cross-Platform (Deferred — Low Priority)

- [ ] Audit `init.sh` for macOS/Linux/Windows differences (`sed -i`, `date -u`)
- [ ] `sync_agents.sh` — test on Linux (bash vs zsh)
- [ ] `darkfact()` shell function — zsh only (document bash equivalent)
- [ ] Document Windows support: Git Bash or WSL

## Post-v1.0.0 Polish (Low Priority)

- [ ] Live test Claude Code hooks (SessionStart + Stop)
- [ ] Live test Gemini CLI hooks (SessionStart + SessionEnd)
- [ ] Evaluate PAI packs (Research, Thinking, Security, ContextSearch)
- [ ] Python-based YAML parser for sync_agents.sh (L6 fix)
- [ ] Install `gh` CLI prompt in `darkfact()` if not present

## Investigate

- [ ] **Antigravity capacity limits** — document rate limits, max session duration, error patterns. Can we request higher limits? Should DarkFact recommend session budgets?
- [ ] **Fleet mode** — one workspace coordinating many agents (ai.inunu.net manages 6 bots). PAI research area.

## DONE (v1.2.x)

- [x] WORKSPACE marker file — hard identity in every project (v1.2.2)
- [x] Two-layer boot check — WORKSPACE + profile.json (v1.2.2)
- [x] `make update-template` guard — blocks if run inside DarkFact (v1.2.3)
- [x] Remote URL validation — rejects local paths, requires GitHub (v1.2.3)
- [x] Two-repo Git model — in boot.md + learned.md for all projects (v1.2.4)
- [x] Maintainer hard scope boundary — project-only, never DarkFact (v1.2.5)
- [x] report-bug two-channel routing — template vs project (v1.2.5)
- [x] All 16 projects got WORKSPACE files + darkfact-upstream remote
- [x] All 16 projects got updated maintainer/boot/report-bug
- [x] Legacy Dark Factory files removed from all 16 projects
- [x] Soul type heuristics expanded (8 types in onboard.md) (v1.2.0)
- [x] `project_type` enum expanded (13 types) (v1.2.0)
- [x] `ki_recall.py` wired into boot.md (v1.2.5)
- [x] Security/style rules surfaced in onboard opt-in (v1.2.5)
- [x] Makefile version string fixed (v1.2.1)
- [x] SemVer policy added to learned.md (L13) (v1.2.1)
- [x] Issue #3 fully closed

## DONE (v1.0.0 – v1.1.0)

- [x] DarkFact v1.0.0 — 66 files, 7 agents, native hooks, brain
- [x] Phase 4: Terminal cleanup — `darkfact()` launcher, IDE picker
- [x] Phase 5: `/onboard` workflow + Vex persona + skill file
- [x] Rule isolation — core.md decoupled, soul.md/user.md templates
- [x] Upstream feedback — `/report-bug` + `make update-template`
- [x] Project rules.md cleaned of stale template rules
- [x] AGENTS.md updated with Vex identity and /onboard check
