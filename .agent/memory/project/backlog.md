# Backlog

## In Progress

- [ ] **`/resume` workflow** — detect partial onboarding state and pick up where a crashed session left off
- [ ] PortPulse end-to-end test case (paused — collecting observations)

## Test Run Observations (PortPulse — 2026-04-14)

> Observations from the PortPulse test case. These are bugs/gaps to fix in DarkFact,
> NOT fixed live during the test run. The test run is for data collection.

- [ ] **BUG: `profile.json` not updated during onboarding** — onboarding wrote goals/backlog/soul/rules correctly but left `profile.json` with the DarkFact template profile (name, type, version all wrong). Onboarding skill must update profile.json atomically.
- [ ] **BUG: `onboarding_complete` flag not set** — even if files are written, the flag stays `false`. Means boot check always triggers re-onboarding.
- [ ] **OBSERVATION: Antigravity crashes mid-long-session** — "high traffic" API errors terminate the agent. Template needs crash-resilient design: each onboarding step writes its output immediately before moving to the next step (checkpoint pattern), not at the end.
- [ ] **PROCESS: Test runs must OBSERVE not FIX** — when something fails during a DarkFact test, log it here, don't fix it live. The DarkFact coordinator session won't always be running. Feedback loop: test → observe → log → fix in next DarkFact session.
- [ ] **ARCHITECTURE: Native-first is fragile under API rate limits** — the old Dark Factory CLI daemon queued and retried tasks even when the UI hit quotas/errors. Native hooks (Claude Stop, Gemini SessionEnd) die with the UI session. DarkFact v1.1.0 has no retry layer. Consider: headless `claude -p` / `gemini -p` for long-running tasks as a resilience pattern, or a lightweight local task queue (a simple JSON file + cron) that survives UI crashes. This is the one real loss from going native-first.
- [ ] **BUG: `darkfact()` scaffold sets wrong remote name** — PortPulse ends up with `origin` pointing at `InunuNet/DarkFact` instead of the user's own repo. The scaffold should name the template remote `darkfact-upstream` and leave `origin` empty (to be set by user). Bug in `darkfact()` shell function in `~/.zshrc`.
- [ ] **CONFIRMED: `profile.json` bug is template-level** — affects every project scaffolded from DarkFact v1.1.0. The `/onboard` skill writes goals/backlog/soul/user/rules but never updates `profile.json`. PortPulse can (and should) file this via `/report-bug` against `InunuNet/DarkFact` — this is exactly the feedback loop the template is designed for.

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
