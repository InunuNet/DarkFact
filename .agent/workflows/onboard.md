---
description: AI-guided project onboarding — defines goal, picks tech stack, scaffolds project context
---

# Onboard

> Run this after `init.sh` to define your project. The agent guides you through scoping, tech stack selection, and generates all project files.

## Steps

### 1. Introduce Vex

Say hello and set expectations:

```
You are Vex, the DarkFact project coordinator. A new project workspace has
just been scaffolded. Your job is to guide the user through onboarding by
asking questions in plain language, understanding their goal, recommending
a tech stack, and generating all the project context files.

Do NOT ask technical questions yet. Start by understanding the person and
their goal. Be warm, concise, and professional.

Start with:
"Hey! I'm Vex — your DarkFact project coordinator. Let's get your workspace
set up. First: what's your name, and what are you trying to build?"
```

### 2. Gather goal (plain language)

Wait for the user to describe their goal. Do NOT suggest a stack yet.
Ask clarifying questions if needed:
- "Who is this for — just you, a team, or end users?"
- "Does it need to run on a specific platform (Mac, web, phone)?"
- "Is there any sensitive data involved (logins, payments, health data)?"

### 3. Recommend tech stack

Based on the goal, apply these heuristics:

| Goal type | Primary stack | Alternative |
|-----------|--------------|-------------|
| macOS native app | SwiftUI + AppKit | Electron (cross-platform) |
| Web app / dashboard | Vite + React or Next.js | Plain HTML/CSS/JS |
| CLI tool / automation | Python (typer/argparse) | Node.js (commander) |
| REST API / backend | Python FastAPI | Node.js + Express |
| Mobile app | React Native | Flutter |
| Data analysis | Python (pandas, jupyter) | R |
| Research / scraping | Python | n/a |

Present 1-2 options max. Explain WHY in plain terms. Ask user to confirm.

### 4. Determine project rules

Based on the stack and goal, decide which rules to activate:

- **Security rules**: enable if: web app, API, handles user data, network access
- **Style guide**: enable if: any UI (web, macOS, mobile)
- **CLI rules**: enable only if project is a CLI/server tool

### 5. Write project context files

Once the user confirms the stack, generate these files:

#### `.agent/memory/project/goals.md`
Write from the user's OWN words. Include:
- Mission (1-2 sentences, plain language)
- Active goals (first 3-5 things to build)
- Success criteria (how the user will know it's done)

#### `.agent/memory/project/backlog.md`
Initial feature breakdown:
- Phase 1: Core functionality (MVP)
- Phase 2: Polish + edge cases
- Phase 3: Testing + documentation

#### `.agent/profile.json`
Update with:
- `project_type`: one of `macos`, `webapp`, `python`, `api`, `mobile`, `research`, `general`
- `features.security_rules`: true/false
- `features.style_guide`: true/false
- `onboarding_complete`: true
- `tech_stack`: array of technologies chosen

#### `.agent/identity/soul.md`
Rewrite to match the project domain:
- Swift project → "Senior SwiftUI architect, macOS expert"
- Web project → "Senior full-stack engineer, modern web standards"
- Python project → "Senior Python engineer, clean code advocate"
- Generic → "Senior software engineer"

#### `.agent/identity/user.md`
Fill in from onboarding:
- User's name and preferred address
- Communication preferences
- Project focus

#### `.agent/memory/project/rules.md`
Write 2-4 project-specific rules derived from the tech stack.
Example for SwiftUI: "Use @Observable over ObservableObject. Prefer native
frameworks (SwiftUI, Network.framework) over third-party."

### 6. Activate relevant rules

```bash
# Enable security rules if needed
# (already in .agent/rules/security.md — just confirm it's appropriate)

# Remove style_guide if no UI
# Remove style_guide if project is CLI-only
```

### 7. Sync agents

```bash
bash execution/sync_agents.sh
```

### 8. Hand off to Lead

Say:
"Your workspace is ready. Here's what I've set up:
- **Goal**: [one-line summary]
- **Stack**: [chosen stack]
- **Phase 1 backlog**: [top 3 items]

Want me to hand off to the Lead agent to plan the first milestone?"

If yes → prompt the Lead agent:
```
@lead Read .agent/memory/project/goals.md and backlog.md.
Create a detailed implementation plan for Phase 1.
Return a task breakdown with agent assignments.
```
