---
description: Per-provider parallelism — how each CLI handles parallel subagents and agent teams
---

# Per-Provider Parallelism

DarkFact's 7-agent team model assumes parallel execution is available. It is not uniform
across providers. This doc defines what each CLI supports and how to work within limits.

## Capability Matrix

| Feature | Claude Code | Gemini CLI | Codex | Antigravity |
|---------|------------|-----------|-------|-------------|
| Native parallel subagents | ✅ Yes | ✅ Yes | ⚠️ Limited | ❌ No |
| Agent Teams (`@agent`) | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| Concurrent tool calls | ✅ Yes | ✅ Yes | ✅ Yes | ❌ Sequential |
| Background tasks | ✅ Yes | ⚠️ Partial | ❌ No | ❌ No |
| Max parallel agents | ~10 | ~5 | 1 | 1 |

---

## Claude Code

**Richest parallelism support.**

```bash
# Enable agent teams (required for @agent delegation)
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
# Already set in .claude/settings.json env block
```

- Spawn up to ~10 parallel subagents via `Task` tool
- `@lead`, `@dev`, `@analyst` etc. route to named agents in `.claude/agents/`
- Each agent runs in its own context — no shared state unless written to files
- Use for: parallel file analysis, multi-agent implementation, concurrent QA + dev

**Pattern for parallel work:**
```
Lead delegates:
  → dev: implement feature X
  → qa: write tests for Y  
  → docs: update README
All run concurrently, lead reviews outputs
```

---

## Gemini CLI

**Parallel support, smaller pool.**

- Supports parallel tool calls natively
- Agent delegation via `.gemini/agents/` — same YAML frontmatter as Claude
- Context window advantage (1M tokens) compensates for smaller agent pool
- Use for: large-context tasks where one agent needs to hold many files

**Limitation:** No equivalent to Claude's `Task` tool for explicit parallel dispatch.
Gemini parallelises at the tool-call level, not the agent level.

```bash
# Run with specific agent context
gemini -p "@analyst review all files in .agent/memory/project/"
```

---

## Codex

**Single-agent only.**

- No native agent teams
- No parallel subagent dispatch
- Executes sequentially — one tool call at a time
- Best for: focused single-file tasks, script execution, isolated changes

**Workaround for parallelism:** Run multiple Codex headless processes in separate terminals:
```bash
codex "implement feature X in src/feature.ts" &
codex "write tests for Y in tests/y.test.ts" &
wait
```

---

## Antigravity

**Sequential only.**

- No parallel execution at any level
- No agent teams, no concurrent tool calls
- Every operation blocks until complete
- Best for: simple tasks, interactive sessions, quick lookups

**Mitigation:** Use short, atomic tasks. Break complex work into explicit sequential steps.
Don't attempt multi-agent workflows in Antigravity — delegate to Claude/Gemini headless.

---

## DarkFact Agent Team Design Implications

The 7-agent team model is optimised for **Claude Code**. When using other providers:

| Provider | Recommendation |
|----------|---------------|
| Claude Code | Full team — parallel delegation works as designed |
| Gemini CLI | Use lead + 1-2 specialist agents — no parallel dispatch |
| Codex | Single agent only — skip team delegation entirely |
| Antigravity | Single agent, sequential steps — use `/boot` context only |

**Rule:** Never instruct an Antigravity or Codex session to "delegate to @dev" — 
those providers don't resolve agent references. Use direct instructions instead.
