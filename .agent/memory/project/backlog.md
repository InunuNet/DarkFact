# Backlog

## In Progress

- [ ] **`/resume` workflow** — detect partial onboarding state and pick up where a crashed session left off ✅ shipped
- [ ] **`/migrate` — Legacy Workspace → DarkFact v1.1.0** — one-time migration tool for 16 existing projects (v3.0–v4.8). See [migration_plan.md](file:///Users/vetus/.gemini/antigravity/brain/3837d78f-d855-4c4e-bf3c-fa9ad4c0a09c/migration_plan.md)
  - [ ] Phase 1: Write `execution/migrate.sh` + `execution/merge_profile.py`
  - [ ] Phase 2: Test on HomeClaw (Tier 1, no brain)
  - [ ] Phase 3: Test on LanScout (Tier 2, has brain)
  - [ ] Phase 4: Migrate all 16 projects (Tier 1 → Tier 2 → PAI last)
  - [ ] Phase 5: Cleanup — delete backups, archive old Workspace Template
- [ ] PortPulse end-to-end test case (in progress — observing)

## Test Run Observations (PortPulse — 2026-04-14)

> Observations from the PortPulse test case. These are bugs/gaps to fix in DarkFact,
> NOT fixed live during the test run. The test run is for data collection.

- [ ] **BUG: `profile.json` not updated during onboarding** — onboarding wrote goals/backlog/soul/rules correctly but left `profile.json` with the DarkFact template profile (name, type, version all wrong). Onboarding skill must update profile.json atomically.
- [ ] **BUG: `onboarding_complete` flag not set** — even if files are written, the flag stays `false`. Means boot check always triggers re-onboarding.
- [ ] **OBSERVATION: Antigravity crashes mid-long-session** — "high traffic" API errors terminate the agent. 3 crashes observed in this test session (onboarding at 58s, phase execution at 33s, wrap-up at 45s). **Root cause: Antigravity platform capacity limits, NOT a template bug.** Template mitigation: checkpoint pattern (each workflow step writes state before moving to next). But the real fix is upstream in Antigravity.
- [ ] **INVESTIGATE: Antigravity capacity limits** — document the platform's rate limits, max session duration, and error patterns. Determine: (1) Is there a way to request higher limits? (2) Can we break long tasks into smaller sub-agent calls to stay under limits? (3) Should DarkFact recommend session length budgets in its docs? (4) File upstream feedback with the Antigravity team if there's a channel for it.
- [ ] **PROCESS: Test runs must OBSERVE not FIX** — when something fails during a DarkFact test, log it here, don't fix it live. The DarkFact coordinator session won't always be running. Feedback loop: test → observe → log → fix in next DarkFact session.
- [ ] **ARCHITECTURE: Native-first is fragile under API rate limits** — the old Dark Factory CLI daemon queued and retried tasks even when the UI hit quotas/errors. Native hooks (Claude Stop, Gemini SessionEnd) die with the UI session. DarkFact v1.1.0 has no retry layer. Consider: headless `claude -p` / `gemini -p` for long-running tasks as a resilience pattern, or a lightweight local task queue (a simple JSON file + cron) that survives UI crashes. This is the one real loss from going native-first.
- [ ] **🔴 CRITICAL: `darkfact()` scaffold breaks workspace isolation** — PortPulse's `origin` points at `InunuNet/DarkFact`. When agent runs `git log`, it sees DarkFact commits and wraps up BOTH projects as if they're the same workspace. Agent cannot distinguish PortPulse from DarkFact. Fix: `darkfact()` must NOT set `origin` at all — only set `darkfact-upstream`. User sets `origin` to their own repo. Additionally, `init.sh` should write a `WORKSPACE` marker file with the project name so agents can self-verify which project they're in.
- [ ] **🔴 CRITICAL: Agent has no workspace boundary — coordinator bleeds into child projects** — The DarkFact coordinator (Vex) has no CWD check and will happily act on any directory the user opens in the same tool. When the user opened PortPulse, the DarkFact coordinator jumped in and started acting as PortPulse Lead. This blocks all teams using DarkFact — every project needs an isolated agent session. Fix: (1) `boot.md` must verify `pwd` against the expected workspace root and refuse to proceed if mismatched. (2) AGENTS.md must include: "If the current directory is not your project root, stop and tell the user to open this project in its own IDE window." (3) Each project must be opened in a **separate** IDE window/session — document this explicitly in onboarding.
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

## Insights from Migration (v3.x → v1.1.0 Fleet)

> Patterns observed across 16 real projects. Feed these into template improvements.

- [ ] **FEATURE: Expand soul type heuristics in `/onboard`** — current onboard.md only covers 5 types. Fleet revealed 8 distinct souls needed: `devops` (HomeClaw, wh3), `financial` (ZOHO), `legal` (GJ Dauth Estate), `security` (Phising Attack Back), `fleet-manager` (ai.inunu.net), `av-consultant` (NWU Tender), `research` (PAI). Add these to the stack heuristics table.
- [ ] **FEATURE: Expand `project_type` enum** — add: `devops`, `financial`, `legal`, `security`, `research`, `fleet`. The `general` fallback is too broad.
- [ ] **FEATURE: `soul_type` field in profile.json** — separate from `project_type`. Lets the agent know the persona domain even when the tech stack changes.
- [ ] **INSIGHT: ZOHO multi-session-summary pattern** — ZOHO had 16 session summaries (v1–v16) in memory/project/. This is a useful pattern for long-running projects — a rolling session log in addition to brain wrap-up. Consider adding a `session_log.md` to the memory structure.
- [ ] **INSIGHT: SysMonitor vs SysMon** — two projects for one product = workspace sprawl. DarkFact should warn or recommend archiving superseded workspaces. Add `status: archive` to profile.json spec and document the convention.
- [ ] **INSIGHT: ai.inunu.net fleet management** — managing 6 bots (Dadb0t, Momb0t, etc.) from one workspace. Fleet management is a real DarkFact use case. PAI research should explore a `fleet` mode where one workspace coordinates many agents.
- [ ] **INSIGHT: NWU Tender used markitdown** — document conversion (PDF → Markdown) is a recurring need across research projects. Add `markitdown` as a recommended addon in the docs/research soul type.
- [ ] **INSIGHT: Parallelism is Antigravity-specific** — Antigravity agents cannot spawn parallel child agents (sequential orchestration only). Claude Code and Gemini CLI both support native parallel subagents. Document per-provider parallelism capability in the agent team docs so teams know what's available in their tool.

## GitHub Issues (Pending)
- [ ] **ISSUE #3: `ki_recall.py` not wired** — Either wire it into the boot sequence or remove it entirely if superseded.
- [ ] **ISSUE #3: `security_rules` & `style_guide` undiscoverable** — Provide opt-in prompts during the `/onboard` workflow.
- [x] **ISSUE #3: Version string drift** — Fixed: Makefile updated to `v1.1.0`. Issue #3 closed.

## DONE

- [x] DarkFact v1.0.0 — 66 files, 7 agents, native hooks, brain
- [x] Phase 4: Terminal cleanup — `darkfact()` launcher, IDE picker
- [x] Phase 5: `/onboard` workflow + Vex persona + skill file
- [x] Rule isolation — core.md decoupled, soul.md/user.md templates
- [x] Upstream feedback — `/report-bug` + `make update-template`
- [x] Project rules.md cleaned of stale template rules
- [x] AGENTS.md updated with Vex identity and /onboard check
