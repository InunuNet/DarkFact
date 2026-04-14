# Backlog

## TODO — v1.2.6+ (Next Patches)

### Bugs
- [x] **BUG: `profile.json` not updated during onboarding** — fixed in v1.2.6: Step 5 now has explicit `python3` atomic update command with FILL_IN placeholders and inline comments for security_rules/style_guide.
- [x] **BUG: `onboarding_complete` flag never set to `true`** — fixed in v1.2.6: new Step 9 sets it as the final named action.
- [ ] **BUG: Step 6 (Activate rules) has no executable commands** — bash comments only, no actual file operations. Pre-existing ambiguity flagged by QA. Low priority.

### Hardening
- [ ] **ARCHITECTURE: Checkpoint pattern for crash resilience** — each workflow step should write state before moving to next. Crash = resume from last checkpoint. Document the pattern.
- [ ] **DOCS: Headless fallback for long tasks** — document `claude -p` / `gemini -p` as a resilience pattern. Recommend session length budgets.
- [ ] **DOCS: Per-provider parallelism capability** — Claude Code + Gemini CLI support native parallel subagents. Antigravity is sequential only. Document this in agent team docs.

### Features
- [ ] **FEATURE: `soul_type` field in profile.json** — separate from `project_type`. Add stub to template default.
- [ ] **FEATURE: `session_log.md` pattern** — rolling session log in `memory/project/` for long-running projects (observed in ZOHO's 16 session summaries).
- [ ] **FEATURE: `status: archive` in profile.json** — for superseded workspaces (SysMonitor vs SysMon pattern). Warn during boot if status=archive.
- [ ] **FEATURE: `markitdown` recommended addon** — document PDF→Markdown conversion for research/legal soul types.

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
