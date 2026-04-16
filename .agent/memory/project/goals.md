# Goals

## Mission

Build an **agent-agnostic workspace** that helps both the DarkFact template
and every project using it **self-improve** — detecting its own gaps, fixing
its own bugs, and getting smarter across sessions without human intervention.

Provider-agnostic means: works equally well on Claude Code, Gemini CLI,
OpenCode, or any future AI coding agent. No single-provider lock-in.

Self-improving means: the workspace learns from each session, detects
recurring failures, escalates blockers, and feeds those learnings back into
the template so every downstream project benefits automatically.

## Active Goals

### Template Health
1. **Claude Code harness correctness** — fix critical bug: Write/Edit memory guards use `$CLAUDE_TOOL_INPUT` (doesn't exist) — guards are no-ops
2. **PreCompact hook** — prevent silent context loss during compaction via brain.py checkpoint
3. **SubagentStart/SubagentStop hooks** — give the 8-agent team hook-level orchestration
4. **permissions.deny** — move security denylists from advisory .md to enforced settings
5. **verify_workspace.sh JSON safety** — profile.json grep → python3 parse (Layer 3 reliability)

### Self-Improvement Loop
6. **Pain Point Monitor (#11)** — recurring analyst loop: scan-blockers → research → propose fix → maintainer applies it
7. **Auto-overlay on version bump** — when DarkFact version advances, fleet gets updated automatically (overlay_all.sh wired into CI or a scheduled trigger)
8. **Feedback loop from downstream** — `/report-bug` telemetry aggregated back into DarkFact backlog automatically

### Agent-Agnostic Completeness
9. **Gemini CLI parity** — audit Gemini adapter against Claude Code adapter; close gaps
10. **OpenCode adapter** — AGENTS.md is read natively; wire skills + agents for OpenCode
11. **Cross-platform scripts** — audit init.sh, sync_agents.sh, overlay_all.sh for Linux/Windows (WSL)

### Quality
12. **Smoke test all 3 CLIs** — T1–T5 against a fresh project (test plan exists at workflows/smoke_test.md)
13. **Stale docs cleanup** — wrap-up.md + smoke_test.md still reference `Stop` hook; Makefile shows v1.1.0

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
- [ ] Self-improvement loop closes without human intervention
- [ ] All 3 CLI providers at feature parity
- [ ] Tested on Linux + Windows (WSL)
