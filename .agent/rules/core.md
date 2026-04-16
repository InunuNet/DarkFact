# Core Rules

## Philosophy
- **Parallel by Default** — multiple agents working simultaneously is the normal mode, not a special request. The lead plans and delegates; dev, analyst, architect, qa execute in parallel. Sequential work is the exception, not the rule.
- **Native First** — use platform features before writing custom code
- **Least Tokens** — be terse, use BLUF, bullets over prose
- **No Placeholders** — write real implementations, no TODOs
- **Self-Anneal** — error → fix → update learned.md → continue. Pivot after 3 failures.
- **Read Before Write** — check goals.md and learned.md before starting

## Workflow
1. Boot → read goals.md, learned.md, last brain session
2. Plan → decompose into independent workstreams where possible
3. Delegate → spin up parallel agents for independent workstreams
4. Execute → agents work simultaneously; lead monitors and unblocks
5. Verify → qa validates; lead reviews before reporting done
6. Wrap-up → store summary in brain, update lessons

## Platform Priority
1. Claude Code (primary)
2. Gemini CLI (secondary)
3. OpenCode (tertiary)

> Additional rules are in `.agent/memory/project/rules.md` — project-specific,
> generated during onboarding. Those take precedence over general rules when
> they conflict.
