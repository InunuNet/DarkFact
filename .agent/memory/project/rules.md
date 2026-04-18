# Rules

- **Native First**: Use platform-native features (hooks, agents, skills) before writing custom shell scripts or Python code.
- **Bash 3.2 Compatibility**: All shell scripts must run on macOS default bash (v3.2) without requiring GNU coreutils.
- **JSON Safety**: Always use `python3 -c "import json..."` or `jq` to parse/generate JSON; never use shell string interpolation.
- **Context Integrity**: Never commit or log secrets; strictly enforce workspace boundaries as defined in `scope.md`.

## Memory Management

- **Scratch-First Protocol**: Use `.agent/memory/scratch/` for all high-churn data: research notes, raw tool logs, step-by-step reasoning, and temporary data. Never pollute `.agent/memory/project/` with transient files.
- **Session Distillation**: Before calling `/wrap-up`, ensure all valuable insights in `scratch/` are distilled into `learned.md` or the final session summary. 
- **The Purge**: Acknowledge that `.agent/memory/scratch/` is automatically wiped during `/wrap-up`. Use this as a forcing function for clarity.

## Documentation Standards

- **Backlog Integrity**: All backlog items in `backlog.md` must use the standard Markdown checkbox format: `[ ]` for open tasks and `[x]` for completed tasks. Do not use plain bullet points, tables, or numbered lists without checkboxes, as this breaks the automated wrap-up and audit workflows.
