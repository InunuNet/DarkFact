# Learned

## L1: Don't reinvent the wheel (2026-04-14)

The v1-v5 workspace template wrote custom scripts for everything: boot, dispatch, comms, memory, wrap-up, agent sync. This was wrong. Claude Code, Gemini CLI, and OpenCode already have built-in:

- **Memory**: CLAUDE.md / GEMINI.md / AGENTS.md + auto-memory + rules dirs
- **Hooks**: Claude has 25+ lifecycle events. Gemini has 4. Both run shell scripts.
- **Agents**: Both have `.claude/agents/` and `.gemini/agents/` with YAML frontmatter.
- **Skills**: Both have `.claude/skills/` and `.gemini/skills/` with on-demand loading.
- **Sessions**: Both have resume/continue. Claude has fork. Both persist.
- **Context**: Both have /compact, /clear. Claude has /context.
- **MCP**: Both support Model Context Protocol for external tools.
- **Headless**: `claude -p` and `gemini -p` for automation.
- **Plan mode**: Both support read-only exploration.

**Rule**: Only write custom code when the feature doesn't exist natively. The template is config + conventions, not code.

## L2: Claude First (2026-04-14)

Claude Code is the primary platform. It has the richest hook system (25+ events vs Gemini's 4), the best agent teams support, and is the user's preferred model. Gemini CLI is secondary (free tier, large context). OpenCode is tertiary (open-source, vendor-agnostic).

## L3: Brain (Chroma) works (2026-04-14)

The vector DB brain actually works. Boot recall returned relevant memories. Wrap-up stored context that survived across sessions. Don't replace — enhance minimally.

## L4: Premature execution destroys context (2026-04-14)

A previous session ran cleanup + creation before the plan was approved. This deleted files that were needed (5 Gemini agents from Phase 1) and left the workspace in a half-state. Always plan first, execute after explicit approval.
