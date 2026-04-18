# Backlog

## Phase 1: Core Harness Hardening
- [ ] Fix PreToolUse guards (In Progress) to correctly parse stdin JSON.
- [ ] Implement PreCompact hook for state persistence.
- [x] Wire SubagentStart/Stop hooks for context injection.
- [ ] Move security denylists to `settings.json` permissions.
- [x] Optimize `make update-template` to pull from GitHub via `gh`.

## Phase 2: Self-Improvement Loop
- [x] Finalize Pain Point Monitor (`scan-blockers` integration).
- [ ] Implement `gh`-based version checking on boot.

## Phase 3: Parity & Documentation
- [ ] Audit Gemini CLI for feature gaps vs Claude Code.
- [ ] Wire OpenCode skills and agents.
- [ ] Complete the full documentation suite (Architecture, Agent Guide).
