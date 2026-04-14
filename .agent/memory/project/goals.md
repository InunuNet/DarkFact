# Goals

## Mission

Build a provider-agnostic workspace template that makes any AI coding agent
smarter by leveraging native platform features (hooks, agents, skills, memory)
instead of custom scripts. Config over code.

## Active Goals

1. ~~**DarkFact v1.0.0**~~ ✅ 66 files, 7 agents, native hooks
2. ~~**Phase 4: Terminal cleanup**~~ ✅ `darkfact()` launcher with IDE picker
3. ~~**Phase 5: Onboarding questionnaire**~~ ✅ `/onboard` workflow + Vex persona
4. ~~**Rule isolation**~~ ✅ Core rules decoupled from project-specific rules
5. ~~**Upstream feedback**~~ ✅ `/report-bug` workflow + `make update-template`
6. ~~**GitHub release**~~ ✅ InunuNet/DarkFact live, v1.0.0 + v1.1.0 tagged
7. ~~**End-to-end test**~~ ✅ PortPulse test run — 7 bugs logged
8. ~~**Fleet migration**~~ ✅ 16 projects migrated to v1.1.0
9. ~~**v1.2.x hardening**~~ ✅ Workspace isolation, two-repo model, maintainer scope, legacy cleanup — v1.2.0→v1.2.5
10. **Cross-platform compatibility** — audit scripts for Linux/Windows
11. **Onboarding bugs** — `profile.json` not updated, `onboarding_complete` flag stuck
12. **Resilience** — checkpoint pattern for crash recovery, headless fallback docs

## Success Criteria

- ✅ Boot in any tool → agent has full project context
- ✅ Wrap-up persists → next session recalls prior work
- ✅ Zero custom scripts for features that exist natively
- ✅ Onboarding guides non-technical users to correct tech stack
- ✅ Template rules don't conflict with project-specific rules
- ✅ Published on GitHub (InunuNet/DarkFact)
- ✅ 16 legacy projects migrated with crafted context
- ✅ Workspace isolation enforced (WORKSPACE file + two-layer boot check)
- ✅ Two-repo model in every project (origin + darkfact-upstream)
- ✅ Legacy Dark Factory files cleaned from all 16 projects
- [ ] Tested on Linux + Windows (WSL)
- [ ] Onboarding profile.json bug fixed
- [ ] Checkpoint/crash resilience documented
