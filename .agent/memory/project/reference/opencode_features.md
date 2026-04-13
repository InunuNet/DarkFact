# OpenCode (Codex) — Complete Feature Reference (April 2026)

> Source: opencode.ai, github.com/anomalyco/opencode, openai.com, web search synthesis
> Fetched: 2026-04-13

---

## OpenCode CLI

### Installation
```bash
curl -fsSL https://opencode.ai/install | bash   # Shell script
brew install opencode                             # Homebrew
npm install -g opencode                           # npm
bun install -g opencode                           # Bun
```

### Overview
- Open-source, terminal-native (TUI) AI coding agent
- Vendor-agnostic: 75+ LLM providers
- MIT license
- Built for keyboard-driven, Git-integrated workflows

### Memory System (AGENTS.md)
- `/init` generates `AGENTS.md` with project context
- File-based persistent instructions (compatible with Claude Code's AGENTS.md format)
- Project-aware context loading

### Provider Support
- OpenAI (GPT-5.x), Anthropic (Claude), Google (Gemini)
- AWS Bedrock, Azure OpenAI
- Local models via Ollama
- Reuse existing subscriptions: GitHub Copilot, ChatGPT Plus/Pro
- **OpenCode Zen**: Curated model list with pay-as-you-go pricing

### Key Features
| Feature | Description |
|---------|-------------|
| **LSP Integration** | Auto-configures Language Server Protocol for IDE-like intelligence |
| **Session Management** | Multiple parallel sessions, persistent history |
| **Collaboration** | Share sessions via links |
| **MCP Support** | Model Context Protocol for external tools |
| **Non-interactive** | `opencode run "prompt"` for automation |

### Agentic Workflows
- File operations and complex refactoring
- Bash command execution
- Deep search jobs
- Autonomous multi-step task execution

### GitHub Integration
- Issue triage and implementation
- Auto-create branches and submit PRs
- GitHub Actions integration (runs in GitHub runners)
- Trigger via `/opencode` or `/oc` in comments
- PR/issue interaction and code changes

### CLI Modes
| Mode | Command | Purpose |
|------|---------|---------|
| Interactive TUI | `opencode` | Rich terminal interface |
| Non-interactive | `opencode run "prompt"` | Automation, CI/CD |
| GitHub Actions | Event-triggered | Autonomous PR/issue work |

---

## OpenAI Codex CLI

### Overview
- OpenAI's proprietary CLI coding agent
- Integrates with ChatGPT plans (Plus, Pro, Business, Edu, Enterprise)
- Or use API keys directly

### Key Features
- GPT-5.4 and GPT-5.3-Codex-Spark models
- Plugin system
- Security agent (Codex Security)
- Headless execution: `codex exec "prompt"`

### CLI
```bash
# Interactive
codex

# Headless
codex exec "fix the auth bug"
```

---

## Key Differentiators (OpenCode vs Codex)

| Dimension | OpenCode | Codex CLI |
|-----------|----------|-----------|
| **Source** | Open source (MIT) | Proprietary (OpenAI) |
| **Providers** | 75+ (any LLM) | OpenAI models only |
| **LSP** | Native integration | None |
| **GitHub** | Deep CI/CD integration | Basic |
| **Sessions** | Shareable via links | Local only |
| **Subscriptions** | Reuse existing (Copilot, etc.) | ChatGPT plans or API |
| **Cost** | Free + provider costs | ChatGPT subscription |

---

## Platform Comparison: All Three CLIs

| Feature | Claude Code | Gemini CLI | OpenCode |
|---------|-------------|------------|----------|
| **Config file** | CLAUDE.md | GEMINI.md | AGENTS.md |
| **Rules dir** | .claude/rules/ | (in GEMINI.md) | (in AGENTS.md) |
| **Skills** | .claude/skills/ | .gemini/skills/ | N/A |
| **Agents** | .claude/agents/ | .gemini/agents/ | N/A |
| **Hooks** | 25+ events | 4 events | N/A |
| **Settings** | .claude/settings.json | .gemini/settings.json | AGENTS.md |
| **Headless** | `claude -p` | `gemini -p` | `opencode run` |
| **MCP** | ✅ | ✅ | ✅ |
| **Plan mode** | permission-mode plan | /plan | N/A |
| **Sessions** | -c, -r, --fork | --resume | Built-in TUI |
| **Auto-run** | --dangerously-skip | --approval-mode yolo | N/A |
| **Scheduling** | /schedule, /loop | N/A | N/A |
| **Remote** | --teleport, remote-control | N/A | GitHub Actions |
| **Plugins** | Marketplace | Extensions | N/A |
| **Free tier** | No (subscription) | Yes (OAuth) | Free (BYOK) |
