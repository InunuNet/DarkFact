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
- [x] **BUG #6/#7: `.claude/agents/` not populated — agent team not wired** — fixed in v1.2.14: `init.sh` creates dirs, `sync_agents.sh` populates on first boot.
- [x] **ISSUE #7: Complete Claude Code adapter** — fixed in v2.0.0: SessionEnd hook, PreToolUse guards, verify_workspace.sh, 4 new slash commands, init.sh sync_skills().
- [x] **ISSUE #8: Stop hook fires every response** — fixed in v2.0.0: Stop→SessionEnd.
- [x] **ISSUE #10: Enforce memory path redirection** — fixed in v2.0.0: PreToolUse Write/Edit guards block ~/.claude/MEMORY/ paths.
- [x] **ISSUE #13: verify_workspace.sh strips internal spaces** — fixed: tr→sed for trailing-only whitespace strip.
- [x] **BUG #14: overlay_template.sh leaves orphan files** — fixed: cp -r → rsync --delete, .claude/settings.json added to overlay, Makefile+CHANGELOG included. Closes #14.
- [x] **FEATURE: overlay_all.sh batch updater** — created: discovers all fleet projects, ignore list (DarkFact/Workspace Template/PAI), sorts closest-to-current first, runs overlay + sync_agents per project.
- [x] **FEATURE: Recurring issue detector** — v2.0.0: brain.py scan-blockers, --blockers flag, boot step 6 auto-scan, analyst escalation protocol.
- [ ] **TEST: Smoke test all 3 CLIs** — test plan written in workflows/smoke_test.md (T1-T5). Run manually against fresh project. Results table at bottom of smoke_test.md.
- [x] **FEATURE: `darkfact()` shell function — CLI picker** — updated ~/.zshrc: now presents Claude Code | Gemini CLI | Codex | Terminal with binary presence check for each.

## TODO — v2.1.x (Next Up)

### P0 — Claude Code Harness Fixes
- [ ] **BUG: Write/Edit memory guards are no-ops** — `$CLAUDE_TOOL_INPUT` doesn't exist in Claude Code; hooks read stdin as JSON. Rewrite both PreToolUse guards to `input=$(cat); jq -r '.tool_input.file_path'` + case check.
- [ ] **FEATURE: PreCompact hook** — brain.py checkpoint before context compaction; prevents silent session state loss.
- [ ] **FEATURE: SubagentStart/SubagentStop hooks** — inject DarkFact context into spawned agents; capture results for brain.
- [ ] **HARDENING: permissions.deny** — move security denylists from `.claude/rules/security.md` (advisory) to `settings.json` `deny` block (enforced).
- [ ] **HARDENING: verify_workspace.sh JSON safety** — replace grep-based profile.json extraction with `python3 -c "import json,sys; print(json.load(sys.stdin).get('project_name',''))"`.
- [ ] **DOCS: Fix stale Stop hook references** — `wrap-up.md:35`, `smoke_test.md:80` still say "Stop hook". Fix to "SessionEnd".
- [ ] **DOCS: Makefile version + fleet-update target** — version string still `v1.1.0`; add `fleet-update` and `fleet-dry-run` targets wrapping overlay_all.sh.

### P1 — Self-Improvement Loop
- [ ] **FEATURE: Pain Point Monitor (#11)** — scheduled analyst loop per project: scan-blockers → research → dev fix → maintainer commit. No human required.
- [ ] **FEATURE: Version check on boot** — `/boot` queries `gh release view --repo InunuNet/DarkFact` for latest version; prompts `make update-template` if behind.
- [ ] **FEATURE: `make update-template` via gh** — fetch and apply overlay from GitHub release (not local clone). Portable across any machine layout.

### Future
- [ ] **INTEGRATION: Alembic (formerly Token Less)** — wire as web search/research tool. Add usage rules to lead.md, architect.md, analyst.md skill files. Wire into onboard for research/legal soul types.
- [ ] **DOCS: Full documentation suite** — Architecture doc, contributor guide, agent authoring guide, hook reference, provider comparison. Auto-maintained by docs agent in self-improvement loop.
- [ ] **FEATURE: markitdown recommended addon** — PDF→Markdown for research/legal soul types.

## Cross-Platform (Deferred — Low Priority)

- [ ] Audit `init.sh` for macOS/Linux/Windows differences (`sed -i`, `date -u`)
- [ ] `sync_agents.sh` — test on Linux (bash vs zsh)
- [ ] `darkfact()` shell function — zsh only (document bash equivalent)
- [ ] Document Windows support: Git Bash or WSL

## Post-v1.0.0 Polish (Low Priority)

- [x] Live test Claude Code hooks (SessionStart + SessionEnd)
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
