---
description: Initialize a new project workspace from the DarkFact template
---

# Init

## Steps

1. **Run the scaffolding script**:
```bash
bash init.sh
```

2. **Verify the workspace**:
```bash
ls .agent/agents/ .agent/rules/ .agent/memory/project/
python3 -c "import json; json.load(open('.claude/settings.json'))"
python3 -c "import json; json.load(open('.gemini/settings.json'))"
test -L CLAUDE.md && test -L GEMINI.md && echo "Symlinks OK"
```

3. **Sync agents to platforms**:
```bash
bash execution/sync_agents.sh
```

4. **Test brain**:
```bash
python3 execution/brain.py stats
```
