# Gemini CLI — Complete Feature Reference (April 2026)

> Source: geminicli.com, ai.google.dev, blog.google, web search synthesis
> Fetched: 2026-04-13

---

## Installation
```bash
npm install -g @google/gemini-cli@latest
# or
brew install gemini-cli
```

---

## Memory System

### GEMINI.md (Persistent Context)
- **Workspace**: `.gemini/GEMINI.md` — shared with team via VCS
- **User**: `~/.gemini/GEMINI.md` — personal, all workspaces
- Informs model about project architecture, naming conventions, design patterns
- Loaded at session start, reloadable via `/memory`

### Settings
- **User**: `~/.gemini/settings.json` — global config
- **Workspace**: `.gemini/settings.json` — project-specific

---

## Skills System

### Structure
```
.gemini/skills/<skill-name>/
├── SKILL.md        # Instructions (YAML frontmatter: name, description)
├── scripts/        # Helper scripts
├── resources/      # Reference docs
└── assets/         # Static files
```

### Discovery Tiers (priority order)
1. **Workspace**: `.gemini/skills/` (team-shared)
2. **User**: `~/.gemini/skills/` (personal)
3. **Extensions**: Bundled with installed extensions

### Behavior
- On-demand loading — only activated when task matches description
- YAML frontmatter: `name`, `description`
- Manage via `/skills` command: list, enable, disable, link, reload

---

## Agent System

### Agent Definitions
- Location: `.gemini/agents/<name>.md`
- YAML frontmatter format:
  ```yaml
  ---
  name: dev
  description: Code implementation agent
  model: gemini-3-flash
  tools:
    - read_file
    - write_file
    - edit_file
    - run_shell_command
    - grep_search
  ---
  # Dev Agent
  [system prompt]
  ```
- Manage via `/agents` command

### Agent Modes
- **Standard**: Requires user approval for changes
- **Agent (Auto-run)**: Autonomous execution with guardrails for high-impact actions
- **Plan mode**: `/plan` — read-only exploration, no code changes

### Thinking Modes
- **Standard**: Normal processing
- **Thinking**: Deep reasoning (slower)
- **Deepthink**: Complex technical problems (slowest)

---

## Hooks System

### Configuration (`.gemini/settings.json`)
```json
{
  "hooks": {
    "SessionStart": [{"command": ".agent/hooks/on_session_start.sh"}],
    "PreToolCall": [{"matcher": "*", "command": ".agent/hooks/on_pre_tool.sh"}],
    "PostToolCall": [{"matcher": "*", "command": ".agent/hooks/on_post_tool.sh"}],
    "SessionEnd": [{"command": ".agent/hooks/on_session_end.sh"}]
  }
}
```

### Events
| Event | When |
|-------|------|
| `SessionStart` | Session begins |
| `PreToolCall` | Before tool execution |
| `PostToolCall` | After tool execution |
| `SessionEnd` | Session ends |

### JSON-Based
- Trigger at specific lifecycle events
- Run security scanners, compliance checks, inject custom context
- Hook scripts receive JSON on stdin, output JSON on stdout

---

## MCP (Model Context Protocol)

### Configuration (`~/.gemini/settings.json`)
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-memory"]
    },
    "gemini-docs": {
      "url": "https://gemini-api-docs-mcp.dev"
    }
  }
}
```

- Remote or local MCP servers
- Extends agent with custom tools and resources
- Manage via `/mcp` command

---

## Slash Commands (Interactive)

| Command | Purpose |
|---------|---------|
| `/skills` | List, enable, disable, link, reload skills |
| `/mcp` | Manage MCP connections |
| `/agents` | Manage agent registry, reload configs |
| `/memory` | Reload GEMINI.md and context files |
| `/commands` | Reload custom slash commands |
| `/plan` | Enter plan/read-only mode |
| `/stats` | Session telemetry (tokens, cost) |
| `/stats model` | Per-model token breakdown |
| `/stats tools` | Tool call success rate + timing |
| `/compress` | Compress context (replace history with summary) |
| `/tools` | List available tools (`/tools desc` for descriptions) |
| `/hooks` | Manage lifecycle hooks |
| `/tasks` | Toggle background tasks view |
| `/settings` | View/edit CLI settings |
| `/directory` | Manage workspace directories |

---

## CLI Flags

| Flag | Purpose |
|------|---------|
| `-p "prompt"` | Non-interactive/print/headless mode |
| `--sandbox` / `-s` | Sandboxed execution (~8s startup vs ~25s) |
| `--model <model>` | Select model |
| `--approval-mode yolo` | Auto-approve all actions |
| `--resume latest` | Resume last session |
| `--list-sessions` | List saved sessions |
| `--output-format json` | Structured output (json, stream-json) |

---

## Models (as of April 2026)

| Model | Tier | Best For |
|-------|------|----------|
| Gemini 3.1 Pro | Pro | Deep reasoning, complex SWE |
| Gemini 3 Pro | Pro | General purpose |
| Gemini 2.5 Flash | Flash | Fast, cost-effective |
| Gemini 2.5 Pro Preview | Pro | Advanced reasoning |
| Gemma 4 26B-A4B | Local | Via LM Studio, offline |

---

## Key Differentiators
- **Free tier**: Generous free API access with OAuth login
- **Large context**: Up to 1M+ token windows
- **Google ecosystem**: Deep GCP/Firebase integration
- **Zero API cost**: Personal use with OAuth (no API key needed)
- **Sandbox mode**: `--sandbox` for faster, isolated execution
- **Plan mode**: `/plan` for safe read-only exploration

---

## Headless Mode (Automation)
```bash
# Non-interactive execution
gemini -p "fix the bug in auth.py" --approval-mode yolo --output-format json

# With sandbox (faster)
gemini -p "analyze this code" --sandbox --model gemini-2.5-flash

# Pipe input
cat error.log | gemini -p "explain these errors"
```

---

## Session Management
- `--resume latest` — resume last session
- `--resume <session-id>` — resume specific session
- `--list-sessions` — list all saved sessions
- Sessions persist automatically
