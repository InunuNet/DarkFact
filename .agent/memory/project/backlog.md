# Backlog

## In Progress

- [ ] **`/resume` workflow** — detect partial onboarding state and pick up where a crashed session left off
- [ ] Create GitHub repo (InunuNet/DarkFact) and push v1.0.0
- [ ] PortPulse end-to-end test case

## Cross-Platform Compatibility

- [ ] Audit `init.sh` for macOS/Linux/Windows differences
  - `sed -i ''` (macOS) vs `sed -i` (Linux) — use Python or portable alternative
  - `date -u` format flags differ between GNU/BSD — test on Linux
- [ ] `sync_agents.sh` — test on Linux (bash vs zsh differences)
- [ ] `brain.py` — already cross-platform (Python)
- [ ] `darkfact()` shell function — zsh only (document bash equivalent)
- [ ] Document Windows support: use Git Bash or WSL

## Post-v1.0.0 Polish

- [ ] Live test Claude Code hooks (SessionStart + Stop)
- [ ] Live test Gemini CLI hooks (SessionStart + SessionEnd)
- [ ] Evaluate PAI packs (Research, Thinking, Security, ContextSearch)
- [ ] Python-based YAML parser for sync_agents.sh (L6 fix)
- [ ] Install `gh` CLI prompt in `darkfact()` if not present

## DONE

- [x] DarkFact v1.0.0 — 66 files, 7 agents, native hooks, brain
- [x] Phase 4: Terminal cleanup — `darkfact()` launcher, IDE picker
- [x] Phase 5: `/onboard` workflow + Vex persona + skill file
- [x] Rule isolation — core.md decoupled, soul.md/user.md templates
- [x] Upstream feedback — `/report-bug` + `make update-template`
- [x] Project rules.md cleaned of stale template rules
- [x] AGENTS.md updated with Vex identity and /onboard check
