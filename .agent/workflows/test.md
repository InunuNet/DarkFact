---
description: Run tests and validation on the workspace
---

# Test

## Steps

1. **Validate all JSON configs**:
```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('✅ .claude/settings.json')"
python3 -c "import json; json.load(open('.gemini/settings.json')); print('✅ .gemini/settings.json')"
python3 -c "import json; json.load(open('.agent/profile.json')); print('✅ .agent/profile.json')"
```

2. **Test brain operations**:
```bash
python3 execution/brain.py stats
python3 execution/brain.py last-session
```

3. **Verify agent sync**:
```bash
bash execution/sync_agents.sh
ls .claude/agents/ .gemini/agents/
```

4. **Check symlinks**:
```bash
test -L CLAUDE.md && test -L GEMINI.md && echo "✅ AGENTS.md symlinks"
test -d .claude/skills && test -d .gemini/skills && echo "✅ Skills dirs"
```
