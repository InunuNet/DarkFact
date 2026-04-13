# Claude Code — Complete Feature Reference (April 2026)

> Source: docs.anthropic.com, code.claude.com, web search synthesis
> Fetched: 2026-04-13

---

## Installation
```bash
curl -fsSL https://claude.ai/install.sh | bash     # Native (recommended)
brew install --cask claude-code                       # Homebrew
winget install Anthropic.ClaudeCode                   # Windows
```

---

## Memory System

### CLAUDE.md (Persistent Instructions)
- **Layered loading**: Managed (`/Library/Application Support/ClaudeCode/CLAUDE.md`) → Global (`~/.claude/CLAUDE.md`) → Project (`./CLAUDE.md` or `.claude/CLAUDE.md`) → Subdirectory → CLAUDE.local.md
- **CLAUDE.local.md**: Per-developer overrides, add to `.gitignore`
- **@imports**: `@path/to/file` in CLAUDE.md injects file content into context
- **AGENTS.md**: Cross-tool compatible — Claude reads `## Claude Code` sections
- **Write effective**: Use imperative ("Use 2-space indentation" not "Format code properly")
- **Keep concise**: <200–800 words recommended
- **`/init`**: Auto-generates CLAUDE.md from project analysis
- **`/memory`**: View and edit auto-memory

### Auto Memory
- Agent writes its own notes from corrections/preferences
- Storage: `~/.claude/projects/<project>/memory/`
- Toggle: `autoMemoryEnabled` in settings or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`
- Custom dir: `autoMemoryDirectory` setting

### .claude/rules/ (Scoped Rules)
- Markdown files in `.claude/rules/` auto-loaded
- Support `paths:` YAML frontmatter for file-scoped rules:
  ```yaml
  ---
  paths:
    - "src/api/**/*.ts"
  ---
  # API Development Rules
  - All endpoints must include input validation
  ```
- User-level rules: `~/.claude/rules/`
- Symlink sharing: `ln -s ~/shared-rules .claude/rules/shared`

### Context Management
- **`/compact`**: Compress conversation context
- **`/clear`**: Clear conversation entirely  
- **`/context`**: View context window usage
- **`--add-dir`**: Include additional directories

---

## Hooks System

### Hook Events (Full Lifecycle)
| Event | When | Decision Control |
|-------|------|-----------------|
| `SessionStart` | Session begins | Env vars, context |
| `InstructionsLoaded` | After CLAUDE.md/rules loaded | Inject instructions |
| `UserPromptSubmit` | Before processing user input | Transform/block |
| `PreToolUse` | Before tool call | Allow/deny/defer |
| `PermissionRequest` | Permission needed | Auto-approve/deny |
| `PostToolUse` | After tool success | Audit, learn |
| `PostToolUseFailure` | After tool failure | Retry logic |
| `PermissionDenied` | Permission rejected | Retry with changes |
| `SubagentStart` | Sub-agent spawned | Configure |
| `SubagentStop` | Sub-agent finished | Process results |
| `TaskCreated` | Background task created | Validate |
| `TaskCompleted` | Background task done | Process results |
| `Stop` | Session ending | Cleanup, learn |
| `StopFailure` | Stop failed | Error handling |
| `TeammateIdle` | Agent team member idle | Reassign |
| `PreCompact` | Before context compression | Save critical info |
| `PostCompact` | After context compression | Restore info |
| `Notification` | Desktop notification | Custom alerts |
| `FileChanged` | File modified externally | React to changes |
| `CwdChanged` | Directory changed | Update context |
| `WorktreeCreate/Remove` | Git worktree lifecycle | Isolation |
| `SessionEnd` | Session terminated | Final cleanup |
| `Elicitation` | Agent asks user question | Custom UI |
| `ConfigChange` | Settings modified | React |

### Hook Types
- **command**: Shell script (`"type": "command", "command": "script.sh"`)
- **HTTP**: Webhook (`"type": "http", "url": "...", "method": "POST"`)
- **prompt**: LLM-evaluated (`"type": "prompt", "prompt": "..."`)
- **agent**: Sub-agent evaluated (`"type": "agent", "agent": "reviewer"`)

### Hook Configuration (`.claude/settings.json`)
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "if": "Bash(rm *)",
        "command": ".claude/hooks/block-rm.sh"
      }]
    }],
    "SessionStart": [{
      "hooks": [{"type": "command", "command": ".agent/hooks/on_session_start.sh"}]
    }]
  }
}
```

### Decision Control (JSON Output)
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked"
  }
}
```

### Matcher Patterns
- `"*"` — match all tools
- `"Bash"` — exact tool name
- `"Edit|Write"` — multiple tools (regex OR)
- `"mcp__memory__.*"` — regex pattern
- `"if": "Bash(rm *)"` — conditional within matched tool

### Async Hooks
- `"async": true` — runs in background, doesn't block
- Good for: tests after edits, notifications, logging

---

## Skills System
- Location: `.claude/skills/` (auto-discovered)
- Markdown files with instructions for specific workflows
- Custom slash commands: `/review-pr`, `/deploy-staging`
- Loaded on-demand when task matches skill description

---

## Sub-agents
- Defined in `.claude/agents/` as markdown files
- Or via `--agents` CLI JSON flag
- YAML frontmatter: `name`, `description`, `model`, `prompt`, `allowedTools`
- Each gets clean context window (prevents context bloat)
- **Agent teams**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- Parallel sub-agents coordinated by lead
- Adversarial patterns (write + review)
- `--agent <name>` to select specific agent profile

---

## CLI Reference

### Commands
| Command | Purpose |
|---------|---------|
| `claude` | Interactive session |
| `claude "query"` | Start with initial prompt |
| `claude -p "query"` | Print/headless mode (non-interactive) |
| `cat file \| claude -p "query"` | Pipe input |
| `claude -c` | Continue last session |
| `claude -r <session> "query"` | Resume named session |
| `claude update` | Self-update |
| `claude auth login` | Authenticate |
| `claude agents` | List sub-agents |
| `claude mcp` | Manage MCP servers |
| `claude plugin install <name>` | Install plugin |
| `claude remote-control` | Start remote session |
| `claude setup-token` | Generate long-lived token |

### Key Flags
| Flag | Purpose |
|------|---------|
| `-p` / `--print` | Headless/print mode |
| `-c` / `--continue` | Continue last session |
| `-r <id>` / `--resume` | Resume specific session |
| `--bare` | Skip auto-discovery (fast startup, CI) |
| `--agent <name>` | Use specific agent profile |
| `--agents <json>` | Inline agent definitions |
| `--model <model>` | Select model (sonnet, opus) |
| `--fallback-model` | Fallback if primary unavailable |
| `--effort <level>` | low/medium/high/max |
| `--max-turns <n>` | Limit agent loops |
| `--max-budget-usd <n>` | Spending cap |
| `--add-dir <path>` | Include additional directories |
| `--output-format` | text/json/stream-json |
| `--input-format` | text/stream-json |
| `--json-schema` | Structured output schema |
| `--mcp-config <file>` | Load MCP server config |
| `--allowedTools` | Whitelist tools |
| `--disallowedTools` | Blacklist tools |
| `--debug <categories>` | Debug logging (api,hooks,mcp) |
| `--dangerously-skip-permissions` | Skip all permission checks |
| `--permission-mode <mode>` | plan/auto/bypassPermissions |
| `--fork-session` | Branch from existing session |
| `--from-pr <n>` | Start from PR context |
| `--init` / `--init-only` | Initialize CLAUDE.md |
| `--append-system-prompt` | Add to system prompt |
| `--chrome` | Chrome browser integration |

### Interactive Commands
| Command | Purpose |
|---------|---------|
| `/compact` | Compress context |
| `/clear` | Clear conversation |
| `/cost` | Show token usage + cost |
| `/model` | Switch model mid-session |
| `/memory` | View/edit auto-memory |
| `/init` | Generate CLAUDE.md |
| `/schedule` | Create recurring task |
| `/loop` | Repeat prompt (polling) |
| `/desktop` | Hand off to desktop app |
| `/debug` | Start debug logging |
| `/hooks` | Manage hooks |
| `/agents` | Manage sub-agents |

---

## Advanced Features

### Scheduling
- `/schedule` — recurring tasks (cloud or desktop)
- Cloud: runs on Anthropic infrastructure (survives machine off)
- Desktop: runs locally with file/tool access
- `/loop` — repeat prompt within session

### Remote Control
- `claude remote-control --name "Project"` — start remote session
- `claude --teleport` — pull web/mobile session into terminal
- Dispatch from phone → opens desktop session

### Checkpointing
- Git-based state snapshots for recovery
- Automatic checkpoints before risky operations

### Plugins
- `claude plugin install <name>@<marketplace>`
- Marketplace ecosystem for extensions

### Channels
- External notification/messaging integrations
- `--channels plugin:<name>@<marketplace>`

### MCP (Model Context Protocol)
- Connect to external tools, APIs, databases
- Configure in `.claude/settings.json` or `--mcp-config`

### Permission Modes
- **plan**: Read-only exploration
- **auto**: Auto-approve safe operations
- **bypassPermissions**: Skip all checks (dangerous)

### Structured Outputs
- `--json-schema` for programmatic consumption
- Enforce response format

### Budget Control
- `--max-budget-usd 5.00` — spending cap
- `--max-turns 3` — iteration limit

---

## Settings Files
- **Project**: `.claude/settings.json` (shared)
- **Local**: `.claude/settings.local.json` (gitignored)
- **User**: `~/.claude/settings.json` (global)
- **Managed**: `/Library/Application Support/ClaudeCode/settings.json` (org-wide)

### Key Settings
```json
{
  "permissions": {
    "allow": ["Bash", "Read", "Write", "Edit", "Glob", "Grep"],
    "ask": ["Bash(rm -rf *)"]
  },
  "hooks": { "..." },
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "BASH_DEFAULT_TIMEOUT_MS": "600000"
  },
  "autoMemoryEnabled": true,
  "claudeMdExcludes": ["**/vendor/**"]
}
```
