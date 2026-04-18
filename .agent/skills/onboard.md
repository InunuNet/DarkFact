---
description: Guide the user through project onboarding — goal discovery, tech stack recommendation, project file generation
---

# /onboard — Project Onboarding

Read and follow `.agent/workflows/onboard.md` exactly. Do not skip steps.

The workflow covers: project name, goal clarification, tech stack selection, profile.json update, identity configuration, rule activation, and setting `onboarding_complete: true`. All steps are required.

## Quick reference

### Flow
0. **Lock the project name first** — warn: renaming later is painful
1. Ask for user's name + project goal
2. Clarify with 1-3 follow-up questions
3. Recommend tech stack with reasoning
4. Confirm choice
5. Generate all context files (goals.md, profile.json, soul.md, user.md, backlog.md, rules.md)
6. Set `onboarding_complete: true` in profile.json
7. Run `bash execution/sync_agents.sh`
8. Store brain memory: `python3 execution/brain.py remember --summary "Onboarded: [goal]" --tags "onboarding,setup"`
9. Hand off to Lead: `@lead Goals and backlog are ready. Plan Phase 1.`

### Tech Stack Heuristics

| Goal | Recommend |
|------|-----------|
| macOS app | SwiftUI |
| Web dashboard | Vite + React |
| Simple web | Vanilla HTML/CSS/JS |
| Python CLI | typer + rich |
| REST API | FastAPI |
| Mobile | React Native |

### Files to Generate

**`.agent/memory/project/goals.md`** — user's own words, mission + milestones + success criteria

**`.agent/profile.json`** — update these fields:
```python
p.setdefault('features', {})
p['project_name']      = PROJECT_NAME
p['project_type']      = TYPE
p['soul_type']         = SOUL
p['tech_stack']        = [...]
p['primary_platform']  = PLATFORM
p['features']['security_rules'] = bool
p['features']['style_guide']    = bool
p['features']['llm_apis']       = bool
p['onboarding_complete'] = True
```

**`.agent/identity/soul.md`** — agent persona matched to domain (e.g. "Senior SwiftUI architect")

**`.agent/identity/user.md`** — user name, communication style, experience level

**`.agent/memory/project/backlog.md`** — Phase 1 MVP items

**`.agent/memory/project/rules.md`** — 2-4 project-specific overrides
