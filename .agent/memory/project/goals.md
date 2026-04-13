# Goals

## Mission

Build a provider-agnostic workspace template that makes any AI coding agent smarter by leveraging native platform features (hooks, agents, skills, memory) instead of custom scripts. Config over code.

## Active Goals

1. **DarkFact v1.0.0** — Complete rewrite. Native-first architecture. Claude Code primary, Gemini CLI secondary, OpenCode tertiary.
2. **Persistent memory** — Brain (Chroma) for semantic recall. TELOS-lite (goals.md + learned.md) for project context. Session wrap-up that actually works.
3. **Cross-platform agent sync** — Single canonical agent definition → generate platform-specific configs.
4. **Security hooks** — Leverage Claude's PreToolUse + Gemini's PreToolCall for command validation.

## Success Criteria

- Boot in any tool (Claude/Gemini/OpenCode) → agent has full project context
- Wrap-up persists → next session recalls prior work
- Zero custom scripts for features that exist natively
- Template installs in < 60 seconds on a new project
