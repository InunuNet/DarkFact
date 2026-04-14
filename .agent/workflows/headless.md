---
description: Headless fallback — run long tasks via CLI when UI crashes or hits token limits
---

# Headless Fallback

When a UI session (Claude Code desktop, Gemini CLI interactive) crashes mid-task or hits
a token/rate limit, switch to headless mode. The CLI runs independently of the UI — no
rate limit sharing, no context UI overhead, survives terminal disconnects.

## When to Use

- Task is longer than ~30 min of agent work
- You've hit a token limit in the UI and context is gone
- You need to run overnight or unattended
- The UI crashed mid-workflow and you need to resume

## Claude Code Headless

```bash
# Single prompt, non-interactive
claude -p "Run /boot then continue: [task description]"

# With a specific model
claude -p "Run /boot then: [task]" --model claude-opus-4-6

# Continue last session headlessly
claude -c -p "[follow-up task]"

# Pipe output to file for review
claude -p "Run /boot then audit all open backlog items" > session_output.txt
```

**Session budget guidance:**
- Simple tasks (1-3 file changes): fine in UI
- Medium tasks (multi-file, 10-20 steps): use UI with /compact if needed
- Long tasks (full feature, audit, migration): headless preferred
- Overnight jobs: always headless

## Gemini CLI Headless

```bash
# Single prompt
gemini -p "Run /boot then: [task description]"

# With sandbox (safer for destructive ops)
gemini -p "[task]" --sandbox

# Pipe output
gemini -p "Audit goals.md and backlog.md, report status" > gemini_output.txt
```

**Gemini advantage:** Large context window (1M tokens) — better for tasks that need
to hold many files in context simultaneously. Use Gemini headless for:
- Full codebase audits
- Large file analysis
- Cross-file refactors where context size matters

## Codex Headless

```bash
# Single prompt
codex "Run /boot then: [task description]"

# With approval mode (prompts before each action)
codex --approval-mode suggest "Run /boot then: [task]"

# Full auto (no prompts — use carefully)
codex --approval-mode full-auto "Run /boot then: [task]"
```

## Combining with Checkpoints

For tasks using the checkpoint pattern (`workflows/checkpoint.md`), headless resume is seamless:

```bash
# First run crashed at step 5
# Resume headlessly — checkpoint detection happens automatically
claude -p "Run /onboard — there may be an existing checkpoint, resume from it"
```

## Provider Selection Guide

| Scenario | Recommended | Why |
|----------|-------------|-----|
| Code changes, multi-file edits | Claude Code headless | Best tool use, richest hooks |
| Large context analysis | Gemini headless | 1M token window |
| Unattended overnight job | Claude Code headless | Best session resumption |
| Sensitive/sandboxed work | Gemini `--sandbox` | Isolated execution |
| Open-source, no API key | Codex | Self-hosted option |

## Session Length Budgets

Rough guidelines based on observed behavior:

| Task type | UI session | Headless |
|-----------|-----------|---------|
| Single bug fix | ✅ fine | overkill |
| Feature implementation (5-10 files) | ✅ fine | optional |
| Full onboarding flow | ⚠️ use /compact | ✅ preferred |
| Codebase audit | ❌ likely OOM | ✅ required |
| Fleet migration (16 projects) | ❌ | ✅ required |
