# Backlog

## DONE
- [x] Dark Factory split — addon model with install/uninstall (v3.1)
- [x] Boot sequence — execution/boot.sh, single command
- [x] Gemini CLI integration — AI Ultra, zero API cost
- [x] KI created for cross-project boot enforcement
- [x] All agents validated (analyst, architect, dev, qa, lead)
- [x] Factory field-tested on SysMon + LanScout
- [x] Projects moved GDrive → ~/ai/ local
- [x] gemini_query.py hardened — 300s timeout, retries, quota surfacing
- [x] Gemini CLI upgraded 0.32.1 → 0.36.0
- [x] Agent models: Pro Preview (architect/analyst), Flash Preview (dev/qa), Flash Lite (devops)
- [x] Async dispatch system — dispatch_async.py + factory_daemon.py (v3.2)
- [x] Daemon lifecycle — boot starts, wrap-up stops, launchd installer
- [x] Tool workarounds baked into rules (write_to_file + run_command hangs)
- [x] Feedback.md cleaned and restructured
- [x] Template bumped to v3.2
- [x] Async dispatch tested end-to-end (daemon → queue → result in 38.8s)
- [x] dispatch.py DEFAULT_TIMEOUT: 60s → 300s (CLI cold start + tool overhead)
- [x] gemini_query.py: added --sandbox flag (8s vs 25s per call)
- [x] **Eliminate CLI cold start** — sticking with 8s `--sandbox` dispatch delay (v5.x)
- [x] Architect SKILL.md: "return decisions, not code" rule (v5.0)
- [x] profile.json: hardware_profile field for agent prompt injection (v5.0)
- [x] init.sh: blank backlog bug fixed (v5.0)
- [x] Template README.md updated for v5.0
- [x] install.sh manifest bug — factory_comms.py verified in manifest (v5.0)
- [x] **P0: Local model provider** — Gemma 4 26B-A4B via LM Studio (v5.1)
- [x] /boot + /init workflow files created (v5.2)
- [x] **P0: Fallback provider bug fixed** — SystemExit now caught in dispatch.py (v5.3)
- [x] boot.sh: KI relevance check — execution/ki_recall.py, word-overlap scoring, step 3.5 (v5.5)

## TODO
- [ ] P1: Typed event bus (architect spec exists)
- [ ] P3: Task DAG pipeline (JSON with dependency resolution)
- [ ] **P1: Lead dispatch — Gemini CLI blocks run_shell_command** — Root cause confirmed by security audit test. The Gemini CLI sandbox denies `run_shell_command` calls regardless of agent config or `--sandbox` flag. Lead can plan and reason but cannot execute `dispatch_async.py` itself. Fix options:
  - **(Recommended) Structured output dispatch**: Lead outputs a JSON dispatch plan (array of `{agent, prompt}` objects) — daemon parses and queues them. Avoids shell dependency entirely.
  - Alternative: Lead writes dispatch commands to a `.factory/dispatch_requests/` file; daemon polls and executes. Similar pattern to current queue.
  - Alternative: Use a separate non-CLI model (lmstudio) for lead exclusively — local Gemma 4 can write files and the daemon reads dispatch instructions from output.

