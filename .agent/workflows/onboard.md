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
| DevOps / infra | Bash/Python + YAML | Ansible, Terraform |
| Financial / accounting | Python + CSV/API | n/a |
| Legal / documents | Python + markitdown | n/a |
| Security / audit | Python + CLI tools | n/a |
| Fleet / multi-agent | DarkFact native | n/a |

Also determine the **soul type** — the agent's persona domain, independent of tech stack:

| Soul type | Use when |
|-----------|----------|
| `engineer` | Building software (default) |
| `devops` | Infrastructure, deployments, CI/CD |
| `financial` | Accounting, reconciliation, invoicing |
| `legal` | Contracts, compliance, estates |
| `security` | Pentesting, auditing, threat modelling |
| `av-consultant` | AV/IT installation projects |
| `fleet-manager` | Managing multiple bots or workspaces |
| `researcher` | Research, analysis, literature review |

Present 1-2 stack options max. Explain WHY in plain terms. Ask user to confirm.

### 4. Determine and confirm project rules

Based on the stack and goal, decide which rules to activate — then **present them to the user and ask for confirmation**. Do not silently enable rules.

**Decision logic:**
- **Security rules** → enable if: web app, API, user data, network access, or any auth
- **Style guide** → enable if: any UI (web, macOS, mobile, desktop)

**For each rule you plan to enable, tell the user what it does:**

> If enabling security rules, say:
> "🔒 **Security rules**: I'll add guardrails that require confirmation before dangerous commands
> (`rm -rf`, `git push --force`, curl-pipe installs), block reading SSH/credential files,
> and enforce secrets management (no `.env` commits, use sops+age encryption).
> Enable this? [yes/no]"

> If enabling style guide, say:
> "🎨 **Style guide**: I'll add UI/design rules — Google Fonts, HSL color system (no plain
> red/blue/green), dark-mode-first layouts, hover animations, glassmorphism cards,
> and CSS Grid/Flexbox conventions.
> Enable this? [yes/no]"

Set `features.security_rules` and `features.style_guide` in `profile.json` based on the user's answers.

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
> ⚠️ Update ONLY the stub fields that already exist — do NOT rewrite the file.
> Preserve all infrastructure fields (`agents`, `memory`, `platforms`, `features.brain`, etc.)

Fill in the `FILL_IN` values from the onboarding conversation, then run this command:

```python
python3 -c "
import json, sys
with open('.agent/profile.json', 'r') as f:
    p = json.load(f)
p['project_name'] = 'FILL_IN'
p['project_type'] = 'FILL_IN'  # one of: macos, webapp, python, api, mobile, research, devops, financial, legal, security, fleet, general
p['tech_stack'] = ['FILL_IN']
p['onboarding_complete'] = False
p['features']['security_rules'] = False  # replace with True if enabled in Step 4
p['features']['style_guide'] = False     # replace with True if enabled in Step 4
with open('.agent/profile.json', 'w') as f:
    json.dump(p, f, indent=2)
"
```

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

### 9. Mark onboarding complete

Run this as the LAST action. This confirms onboarding succeeded and prevents re-onboarding on next boot.

```bash
python3 -c "
import json
with open('.agent/profile.json', 'r') as f:
    p = json.load(f)
p['onboarding_complete'] = True
with open('.agent/profile.json', 'w') as f:
    json.dump(p, f, indent=2)
print('✅ Onboarding complete. profile.json updated.')
"
```
