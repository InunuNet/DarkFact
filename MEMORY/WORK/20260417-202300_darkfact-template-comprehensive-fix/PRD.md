---
task: comprehensive audit and fix of darkfact template
slug: 20260417-202300_darkfact-template-comprehensive-fix
effort: comprehensive
phase: complete
progress: 80/80
mode: interactive
started: 2026-04-17T20:23:00Z
updated: 2026-04-17T20:30:00Z
---

## Context

DarkFact is a provider-agnostic AI workspace template deployed to 17+ downstream projects. It keeps breaking on deploy — teams get stuck fixing template bugs instead of doing their own work. This session performs a comprehensive audit (architect + 6 parallel researchers) and produces an actionable fix plan covering every root cause.

### Known Critical Bugs Entering This Session

**A: write_profile() defined AFTER main() in init.sh** — function called before it exists; likely causes `command not found` on all new project inits.

**B: template/ directory is wrong and incomplete** — `template/.agent/profile.json` has "New Project" + missing all feature fields. `template/.agent/memory/project/rules.md` contains ChatGPT-generic placeholder rules, not DarkFact scope/security rules. This content gets injected into every new project via boot.

**C: sync_rules.sh destroys rules on run** — Runs `find .claude/rules -delete` before copying from dirs that don't exist yet (`.agent/rules/_core/`, `_claude/`, `_gemini/`). Running `make sync` will DELETE all hooks.md/scope.md/memory.md/security.md in .claude/rules/ and replace with nothing.

**D: template/.agent/profile.json is structurally wrong** — Missing soul_type, tech_stack, features{}, agents[], memory{} — new project profiles will be incomplete until onboard fills them.

**E: Bug #17 (Poisoned Template)** — new projects receiving DarkFact's own project-specific state instead of clean generic skeleton. The Clean Room template/ strategy was architected last session but barely started.

**F: merge_profile.py hardcodes template_version: "1.1.0"** — stale; always wrong on deploy.

**G: .agent/rules/ is almost empty** — only security.md stub; hooks.md, memory.md, scope.md live only in .claude/rules/. sync_rules.sh has no canonical source to pull from.

### Risks

- sync_rules.sh is a live landmine: running `make sync` destroys all Claude rules
- init.sh write_profile failure means NO new project can be created correctly
- Generic rules.md in template/ = every new project gets wrong scope boundaries on day 1
- 17 fleet projects may need remediation after fixes land

## Criteria

### A: init.sh Correctness
- [ ] ISC-1: write_profile() defined BEFORE main() call in init.sh
- [ ] ISC-2: write_profile() succeeds when template/.agent/profile.json exists
- [ ] ISC-3: write_profile() fails gracefully with clear error when template profile missing
- [ ] ISC-4: scaffold_core() creates all required dirs (verified list)
- [ ] ISC-5: init.sh runs without errors on macOS bash 3.2
- [ ] ISC-6: init.sh runs without errors on Linux bash 5+
- [ ] ISC-7: init.sh exits non-zero and prints clear message on missing dependencies
- [ ] ISC-8: WORKSPACE file written with correct project name after init
- [ ] ISC-9: .agent/profile.json has all required fields after init
- [ ] ISC-10: onboarding_complete is false in profile after init
- [ ] ISC-11: goals.md contains fresh placeholder content (not DarkFact's own goals)
- [ ] ISC-12: backlog.md contains fresh placeholder (not DarkFact's backlog)
- [ ] ISC-13: session_log.md is empty/fresh after init
- [ ] ISC-14: learned.md contains two-repo Git model info only (not DarkFact's learnings)

### B: template/ Clean Room
- [ ] ISC-15: template/.agent/profile.json has all fields matching master profile schema
- [ ] ISC-16: template/.agent/profile.json project_name is "New Project" (placeholder)
- [ ] ISC-17: template/.agent/profile.json onboarding_complete is false
- [ ] ISC-18: template/.agent/memory/project/rules.md contains DarkFact scope/security rules
- [ ] ISC-19: template/.agent/memory/project/rules.md does NOT contain generic AI rules
- [ ] ISC-20: template/ contains no DarkFact-specific state (no goals.md, backlog.md content)
- [ ] ISC-21: template/ is documented — README or comment explains what it's for

### C: sync_rules.sh Safety
- [ ] ISC-22: sync_rules.sh does NOT delete rules when source dirs don't exist
- [ ] ISC-23: sync_rules.sh exits with error and message when source dirs are missing
- [ ] ISC-24: .agent/rules/_core/ directory exists with scope.md and security.md
- [ ] ISC-25: .agent/rules/claude/ directory exists with hooks.md and memory.md
- [ ] ISC-26: sync_rules.sh correctly populates .claude/rules/ from .agent/rules/
- [ ] ISC-27: sync_rules.sh correctly populates .gemini/rules/ from .agent/rules/
- [ ] ISC-28: make sync runs all three syncs (agents, skills, rules) without error
- [ ] ISC-29: make sync is idempotent — running twice produces same result

### D: Profile Schema Integrity
- [ ] ISC-30: template profile has soul_type stub field
- [ ] ISC-31: template profile has tech_stack array stub
- [ ] ISC-32: template profile has features{} block with all feature flags
- [ ] ISC-33: template profile has agents[] array
- [ ] ISC-34: template profile has memory{} block
- [ ] ISC-35: template profile has status field with "active" default
- [ ] ISC-36: merge_profile.py reads template_version from .agent/version (not hardcoded)
- [ ] ISC-37: write_profile() in init.sh sets template_version from .agent/version file

### E: Multi-Provider Agent/Skill/Rules Architecture
- [ ] ISC-38: .agent/agents/ is canonical source for all agents
- [ ] ISC-39: .claude/agents/ populated by sync_agents.sh (no manual edits required)
- [ ] ISC-40: .gemini/agents/ populated by sync_agents.sh
- [ ] ISC-41: .agent/skills/ is canonical source for all skills
- [ ] ISC-42: .claude/skills/ populated by sync_skills.sh
- [ ] ISC-43: .gemini/skills/ populated by sync_skills.sh
- [ ] ISC-44: .agent/rules/ is canonical source for all rules
- [ ] ISC-45: .claude/rules/ populated by sync_rules.sh
- [ ] ISC-46: Rules architecture documented: which rules are _core vs provider-specific

### F: Hook System Integrity
- [ ] ISC-47: SessionStart hook fires and injects boot context
- [ ] ISC-48: SessionStart prompt hook shows correct workspace identity
- [ ] ISC-49: PreToolUse Bash hook (verify_workspace.sh) fires on bash commands
- [ ] ISC-50: PreToolUse Write guard blocks ~/.claude/MEMORY/ path writes
- [ ] ISC-51: PreToolUse Edit guard blocks ~/.claude/MEMORY/ path edits
- [ ] ISC-52: PreCompact hook fires and saves brain checkpoint
- [ ] ISC-53: SubagentStart hook fires and injects agent context
- [ ] ISC-54: SessionEnd hook fires and warns on uncommitted changes
- [ ] ISC-55: No hook uses "|| true" on PreToolUse (swallows exit 2 guard)
- [ ] ISC-56: All hook types are valid (command or prompt only, no "agent")

### G: update-template Reliability
- [ ] ISC-57: make update-template fetches from GitHub (not local path)
- [ ] ISC-58: make update-template applies rules files via rsync (currently missing from update list)
- [ ] ISC-59: Makefile itself is updated by update-template (self-update note addressed)
- [ ] ISC-60: update-template guard prevents running inside DarkFact repo itself

### H: Brain/Memory System Reliability
- [ ] ISC-61: brain.py fails gracefully when chromadb not installed (clear install message)
- [ ] ISC-62: boot continues when brain.py is unavailable (non-fatal)
- [ ] ISC-63: brain.py last-session returns clean output when no data exists
- [ ] ISC-64: wrap-up doesn't fail on scratch dir with subdirectories (shutil fix)

### I: Anti-criteria (Must NOT happen)
- [ ] ISC-A1: New project must NOT inherit DarkFact's goals/backlog/session content
- [ ] ISC-A2: make sync must NOT destroy .claude/rules/ when source dirs missing
- [ ] ISC-A3: init.sh must NOT silently succeed while write_profile fails
- [ ] ISC-A4: No hook type "agent" in settings.json (breaks all hooks)
- [ ] ISC-A5: template/.agent/profile.json must NOT have DarkFact as project_name
- [ ] ISC-A6: No path outside project dir written during normal operation

### J: Validation / Smoke Test
- [ ] ISC-65: A fresh project created via init.sh passes verify_workspace.sh check
- [ ] ISC-66: All 5 smoke test scenarios (T1-T5) have expected outputs documented
- [ ] ISC-67: Smoke test can be run automatically (not just manually)
- [ ] ISC-68: Plan documents what to test before any fleet-wide deploy

## Decisions

(populated during Build/Execute)

## Verification

(populated during Verify)
