# Core Rules

## Philosophy
- **Native First** — use platform features before writing custom code
- **CLI First** — terminal over browser, always
- **Least Tokens** — be terse, use BLUF, bullets over prose
- **No Placeholders** — write real implementations
- **Self-Anneal** — error → fix → update learned.md → continue. Pivot after 3 failures.

## Platform Priority
1. Claude Code (primary)
2. Gemini CLI (secondary)
3. OpenCode (tertiary)

## Workflow
1. Read goals.md and learned.md before starting
2. Do the work
3. Claude: Stop hook handles wrap-up automatically
4. Others: Run `python3 execution/brain.py wrap-up -s "summary" -t "tags"`
