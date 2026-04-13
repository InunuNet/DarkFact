# PAI Investigation: Personal AI Infrastructure

## danielmiessler/Personal_AI_Infrastructure — What It Brings to the Table

---

## Executive Summary

PAI is a **Claude Code-native personal AI platform** by Daniel Miessler (the Fabric creator). It's the most mature open-source implementation of personalized agentic coding infrastructure — **1,135 files**, 14 agents, 21 hooks, 63 skills, 180 workflows, 12 packs. Built entirely on Claude Code's hook system, it transforms Claude Code from a coding tool into a "Life Operating System."

> [!IMPORTANT]
> **Key Takeaway**: PAI is NOT a competitor to our Dark Factory — it's a **complementary layer** that solves a different problem. Dark Factory handles multi-agent orchestration and dispatch. PAI handles personalization, continuous learning, and goal-oriented AI behavior. The two could be combined.

---

## Architecture Overview

### The 7 Architecture Components

| Component | PAI Implementation | Our Equivalent |
|---|---|---|
| **1. Intelligence** | "The Algorithm" — Observe → Think → Plan → Build → Execute → Verify → Learn | Boot sequence + Lead agent |
| **2. Context** | TELOS (10 goal files) + 3-tier Memory (hot/warm/cold) | Memory tiers (scratch/project/global) |
| **3. Personality** | Quantified traits + ElevenLabs voice + relationship model | None |
| **4. Tools** | 63 Skills + Fabric patterns + Integrations | SKILL.md system |
| **5. Security** | SecurityValidator hook + AllowList + 4-layer defense | security.md rules |
| **6. Orchestration** | Hook system (21 hooks) + Context Priming Pipeline + Agent Teams | Dark Factory dispatch |
| **7. Interface** | Terminal UI + Tab management + Statusline + Voice output | CLI-only |

### TELOS — The Goal System

PAI's killer differentiator. 10 files that capture _who you are_:

| File | Purpose |
|---|---|
| `MISSION.md` | Your life mission |
| `GOALS.md` | Active goals |
| `PROJECTS.md` | Current projects |
| `BELIEFS.md` | Core beliefs |
| `MODELS.md` | Mental models |
| `STRATEGIES.md` | Approaches to life |
| `NARRATIVES.md` | Personal narratives |
| `LEARNED.md` | Lessons learned |
| `CHALLENGES.md` | Current challenges |
| `IDEAS.md` | Ideas backlog |

> [!TIP]
> **Opportunity for us**: Our template has `memory/project/` but nothing like TELOS. A simplified version (GOALS.md, PROJECTS.md, LEARNED.md) could significantly improve how agents understand project context.

---

## Agent System — 14 Specialized Agents

| Agent | Model | Persona | Role |
|---|---|---|---|
| `Algorithm.md` | opus | Vera Sterling (Verification Purist) | ISC creation, algorithm phases |
| `Engineer.md` | — | — | Code implementation |
| `Architect.md` | — | — | System design |
| `QATester.md` | — | — | Testing |
| `Designer.md` | — | — | UI design |
| `Artist.md` | — | — | Visual creation |
| `UIReviewer.md` | — | — | UI review |
| `Pentester.md` | — | — | Security testing |
| `BrowserAgent.md` | — | — | Browser automation |
| `GeminiResearcher.md` | — | Alex Rivera (Multi-perspective) | Gemini-powered research |
| `ClaudeResearcher.md` | — | — | Claude deep research |
| `GrokResearcher.md` | — | — | Grok/X research |
| `CodexResearcher.md` | — | — | Codex research |
| `PerplexityResearcher.md` | — | — | Perplexity research |

### Key Agent Patterns

Each PAI agent has:
1. **YAML frontmatter** with `name`, `description`, `model`, `color`, `voiceId`, `persona` (name, title, background), `permissions`
2. **Mandatory startup sequence** — load context, send voice notification
3. **Mandatory output format** — structured with `📋 SUMMARY`, `🔍 ANALYSIS`, `⚡ ACTIONS`, `✅ RESULTS`, `🎯 COMPLETED`
4. **Voice integration** — curl to local ElevenLabs TTS server

> [!NOTE]
> Their agent definition format is richer than ours or Gemini CLI's native format. The `persona` field (name, title, background story) and `voiceId` are unique to PAI.

---

## Hook System — 21 Production Hooks

### Event Coverage

| Event | Hooks |
|---|---|
| **PreToolUse** | `SecurityValidator` (Bash, Edit, Write, Read), `SetQuestionTab` (AskUserQuestion), `AgentExecutionGuard` (Task), `SkillGuard` (Skill) |
| **PostToolUse** | `QuestionAnswered`, `DocIntegrity` (Write), `IntegrityCheck` (Edit), `UpdateCounts` |
| **SessionStart** | `LoadContext`, `KittyEnvPersist`, `SessionAutoName` |
| **Stop** | `RatingCapture`, `WorkCompletionLearning`, `RelationshipMemory`, `VoiceCompletion`, `PRDSync`, `ResponseTabReset`, `UpdateTabTitle`, `LastResponseCache`, `SessionCleanup` |

### Hook Architecture

```
settings.json → hooks config
  └── hooks/*.hook.ts (Bun/TypeScript)
       └── hooks/lib/ (shared utilities)
            ├── identity.ts
            ├── time.ts
            ├── paths.ts
            └── notifications.ts
```

> [!IMPORTANT]
> **Direct Port Opportunity**: Their `SecurityValidator`, `LoadContext`, and `WorkCompletionLearning` hooks solve the exact same problems we identified in our research. We could adapt these for Gemini CLI's hook system.

---

## Skill System — 63 Skills in 11 Categories

| Category | Skills |
|---|---|
| **Research** | Quick, Standard, Extensive, Deep, Interview, Claude, Web Scraping, YouTube, Knowledge Extraction |
| **Thinking** | Council (debate), RedTeam, FirstPrinciples, Science, IterativeDepth, BeCreative, WorldThreatModel |
| **Security** | Recon, Web App Testing, Prompt Injection Testing, Security News |
| **ContentAnalysis** | Video, Podcast, Article, YouTube extraction |
| **Investigation** | OSINT, Company Intel, People Search, Domain Lookup |
| **Media** | Image Generation, Diagrams, Infographics, Remotion Video |
| **Telos** | Goals, Beliefs, Wisdom, Project Dashboards, McKinsey Reports |
| **Utilities** | CLI Generation, Skill Scaffolding, Fabric Patterns, Cloudflare, Browser, Documents, Evals |
| **Scraping** | Bright Data proxy, Apify social media |
| **USMetrics** | 68 US economic indicators (FRED, EIA, Treasury, BLS, Census) |
| **Agents** | Custom agent composition from traits/voices/personalities |

### Skill Structure
```
skills/[Category]/[SkillName]/
  ├── SKILL.md          # Core instructions
  ├── Workflows/        # Step-by-step execution guides
  ├── Tools/            # Helper scripts
  ├── Templates/        # Output templates
  └── Assets/           # Static resources
```

---

## Memory System — 3-Tier Architecture

| Tier | Purpose | Retention |
|---|---|---|
| **Hot (Session)** | Current session context | Session lifetime |
| **Warm (Work)** | Recent decisions, learnings | Days-weeks |
| **Cold (Learning)** | Permanent lessons, patterns | Permanent |

### Learning Signal Capture
- **Explicit ratings** — User rates output quality
- **Implicit signals** — Task completion time, retry count, approval rate
- **Sentiment analysis** — Tone of user responses
- **Verification outcomes** — Did the solution actually work?

---

## Settings & Configuration

### Key config patterns from `settings.json`:
```json
{
  "env": {
    "PAI_DIR": "${HOME}/.claude",
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "80000",
    "BASH_DEFAULT_TIMEOUT_MS": "600000"
  },
  "permissions": {
    "allow": ["Bash", "Read", "Write", "Edit", "MultiEdit", "Glob", "Grep",
              "LS", "WebFetch", "WebSearch", "TodoWrite", "Task", "Skill", "mcp__*"],
    "ask": [
      "Bash(rm -rf /)", "Bash(dd if=/dev/zero:*)",
      "Bash(gh repo delete:*)", "Bash(git push --force:*)",
      "Read(~/.ssh/*)", "Write(~/.claude/settings.json)"
    ]
  }
}
```

> [!NOTE]
> PAI enables `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — confirming this is the flag for multi-agent coordination in Claude Code.

---

## What PAI Brings to Our Table

### 🟢 Direct Adoption Opportunities

| Feature | PAI Source | Our Benefit |
|---|---|---|
| **TELOS (simplified)** | `Packs/Telos/` | Goal-aware agents → better task prioritization |
| **SecurityValidator hook** | `hooks/SecurityValidator.hook.ts` | Port to Gemini CLI hooks for security layer |
| **WorkCompletionLearning** | `hooks/WorkCompletionLearning.hook.ts` | Self-improving agent behavior |
| **LoadContext hook** | `hooks/LoadContext.hook.ts` | Replace manual boot.sh context loading |
| **Skill structure** | SKILL.md + Workflows/ + Tools/ | Enhance our flat SKILL.md with workflow sub-dirs |
| **Research Pack** | `Packs/Research/` | Multi-agent research with Quick/Standard/Deep modes |
| **Thinking Pack** | `Packs/Thinking/` | Council debates, RedTeam, FirstPrinciples |

### 🟡 Patterns to Study

| Pattern | What We Learn |
|---|---|
| **Agent Personas** | Name + background story + voice = more focused agent behavior |
| **OUTPUT FORMAT** | Structured output (📋/🔍/⚡/✅/🎯) ensures consistency |
| **User/System Separation** | `USER/` dir for customizations survives upgrades |
| **Pack System** | Standalone installable capabilities → our addon model is similar |
| **Continuous Learning** | Rating capture + sentiment → self-improving system |

### 🔴 Not Applicable / Different Problem Space

| Feature | Why Not |
|---|---|
| **Voice System** | Nice-to-have, not critical for our factory |
| **Terminal UI** | Tab titles, statusline — cosmetic for our use case |
| **Claude Code-only** | We're multi-platform (Gemini + Claude + Codex) |
| **TELOS (full)** | 10 life-goal files is overkill for project templates |

---

## PAI vs Dark Factory — Key Differences

| Dimension | PAI | Dark Factory |
|---|---|---|
| **Philosophy** | Human-centric life OS | Task-centric multi-agent dispatch |
| **Platform** | Claude Code only | Gemini CLI + Claude Code + Codex |
| **Focus** | Personalization + Learning | Orchestration + Delegation |
| **Architecture** | Monolithic (`~/.claude/`) | Addon overlay (install.sh/uninstall.sh) |
| **Scale** | 1,135 files, massive skill library | Lean (< 50 files), focused |
| **Agent Count** | 14 (with personas + voices) | 5 (functional roles) |
| **Hooks** | 21 production hooks | 0 (identified as gap) |
| **Memory** | 3-tier with learning signals | 3-tier (scratch/project/global) |
| **Inter-Agent** | Claude Code Agent Teams (experimental) | factory_comms.py message bus |
| **Target User** | Everyone (non-technical included) | Developers building software |

---

## Recommended Actions

### Phase 1: Cherry-Pick (Low Effort, High Value)
1. **Add `GOALS.md` and `LEARNED.md`** to `.agent/memory/project/` — minimal TELOS
2. **Study their SecurityValidator hook** — adapt for Gemini CLI hooks
3. **Adopt structured output format** for agent responses
4. **Add Workflows/ subdirs** to skill definitions

### Phase 2: Deeper Integration
5. **Port Learning hooks** — `WorkCompletionLearning`, `RatingCapture`
6. **Adopt Pack model** for standalone skill distribution
7. **Research Pack workflows** — Quick/Standard/Deep research modes

### Phase 3: Strategic
8. **Evaluate full TELOS** for user-facing PAI projects
9. **Consider agent personas** for specialized Dark Factory agents
10. **Track PAI releases** for upstream patterns to adopt

---

## Online Resources

- **GitHub**: [danielmiessler/Personal_AI_Infrastructure](https://github.com/danielmiessler/Personal_AI_Infrastructure)
- **Blog**: [danielmiessler.com/blog/personal-ai-infrastructure](https://danielmiessler.com/blog/personal-ai-infrastructure)
- **Video**: [PAI Full Walkthrough](https://youtu.be/Le0DLrn7ta0)
- **Discord**: [danielmiessler.com/upgrade](https://danielmiessler.com/upgrade)
- **Also**: Built by the creator of [Fabric](https://github.com/danielmiessler/fabric) (AI prompt patterns)
