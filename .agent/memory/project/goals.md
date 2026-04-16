# Goals

## Mission

Build an **agent-agnostic workspace** that helps both the DarkFact template
and every project using it **self-improve** — detecting its own gaps, fixing
its own bugs, and getting smarter across sessions without human intervention.

**Agent-agnostic:** works equally well on Claude Code, Gemini CLI, OpenCode,
or any future AI coding agent. No single-provider lock-in.

**Self-improving (downstream projects):** each project running DarkFact scans
its own blockers, the analyst researches, the dev fixes, the maintainer pushes
— without a human noticing or intervening. The loop closes itself.

**Self-improving (template):** DarkFact's own harness checks GitHub for newer
versions on boot and on `make update-template`. When a version bump lands on
GitHub, projects pull it via `gh` — not a direct local push from Vex.

---

## Active Goals

### P0 — Claude Code Harness (Critical Bugs)
1. **Fix broken memory guards** — Write/Edit PreToolUse hooks use `$CLAUDE_TOOL_INPUT` (doesn't exist). Guards are no-ops. Rewrite to read stdin JSON + jq.
2. **PreCompact hook** — brain.py checkpoint before context compaction so state isn't silently lost.
3. **SubagentStart/SubagentStop hooks** — inject DarkFact context into spawned agents; capture results.
4. **permissions.deny** — move security denylists from advisory `.md` text to enforced `settings.json` deny rules.
5. **verify_workspace.sh JSON safety** — replace grep-based profile.json parse with python3 for Layer 3 reliability.

### P1 — Self-Improvement Loop (Downstream Projects)
6. **Pain Point Monitor (#11)** — analyst runs `scan-blockers` on schedule inside each project. On hit: research → dev proposes fix → maintainer commits → done. No human in the loop.
7. **Version check on boot** — `/boot` queries GitHub (`gh release view --repo InunuNet/DarkFact`) for latest version. If project is behind: prompt user to run `make update-template`.
8. **`make update-template` pulls via gh** — fetches overlay from GitHub (not local DarkFact clone). Uses `gh` to download and apply latest template. Correct for any machine, any layout.

### P2 — Agent-Agnostic Completeness
9. **Gemini CLI parity audit** — compare Gemini adapter against Claude Code adapter; close gaps.
10. **OpenCode adapter** — AGENTS.md is read natively; wire skills + agents properly.
11. **Cross-platform scripts** — audit init.sh, sync_agents.sh, overlay_all.sh for Linux/WSL.

### P3 — Quality
12. **Smoke test all 3 CLIs** — T1–T5 from workflows/smoke_test.md on a fresh project.
13. **Stale docs cleanup** — wrap-up.md + smoke_test.md reference `Stop` hook; Makefile shows v1.1.0; no `fleet-update` target.

### Future (Planned, Not Started)
- **Alembic integration** — formerly Token Less. Wire as a tool with usage rules for lead, architect, and analyst agents (web search / research capability). Add to agent skill files and onboard.
- **Full documentation suite** — not just README. Architecture doc, contributor guide, agent authoring guide, hook reference. Build doc generation into the self-improvement loop so docs stay current automatically.

---

## Success Criteria

### Already Met
- ✅ Boot in any tool → agent has full project context
- ✅ Wrap-up persists → next session recalls prior work
- ✅ Zero custom scripts for features that exist natively
- ✅ Onboarding guides non-technical users to correct tech stack
- ✅ Template rules don't conflict with project-specific rules
- ✅ Published on GitHub (InunuNet/DarkFact)
- ✅ 17 fleet projects on v2.0.0
- ✅ Workspace isolation enforced (WORKSPACE + two-layer boot check)
- ✅ Recurring issue detector (scan-blockers + escalation ladder)
- ✅ Batch fleet updater (overlay_all.sh)

### In Progress
- [ ] Claude Code harness guards actually enforce (not no-ops)
- [ ] Context compaction doesn't silently discard session state
- [ ] Projects self-improve without human intervention
- [ ] Version check on boot via gh (not local path)
- [ ] All 3 CLI providers at feature parity
- [ ] Tested on Linux + Windows (WSL)
- [ ] Alembic wired as agent research tool
- [ ] Full documentation suite live and auto-maintained
