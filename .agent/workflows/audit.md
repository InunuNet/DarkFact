---
description: Run a workspace health check
---

# Audit

## Steps

1. **Check file structure**:
```bash
ls .agent/agents/ .agent/rules/ .agent/memory/project/
ls .claude/settings.json .gemini/settings.json
```

2. **Validate JSON configs**:
```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('Claude: OK')"
python3 -c "import json; json.load(open('.gemini/settings.json')); print('Gemini: OK')"
```

3. **Check symlinks**:
```bash
test -L CLAUDE.md && echo "CLAUDE.md → AGENTS.md OK" || echo "CLAUDE.md BROKEN"
test -L GEMINI.md && echo "GEMINI.md → AGENTS.md OK" || echo "GEMINI.md BROKEN"
test -d .claude/skills && echo ".claude/skills OK" || echo ".claude/skills MISSING"
test -d .gemini/skills && echo ".gemini/skills OK" || echo ".gemini/skills MISSING"
```

4. **Check brain**:
```bash
python3 execution/brain.py stats
```

5. **Check agents synced**:
```bash
diff <(ls .agent/agents/ | sort) <(ls .claude/agents/ | sort) && echo "Claude agents synced" || echo "Claude agents OUT OF SYNC"
diff <(ls .agent/agents/ | sort) <(ls .gemini/agents/ | sort) && echo "Gemini agents synced" || echo "Gemini agents OUT OF SYNC"
```
