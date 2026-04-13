# DarkFact v1.0.0 Makefile

.PHONY: help sync-agents brain-export brain-import brain-stats commit audit test

help:
	@echo "🏭 DarkFact v1.0.0"
	@echo ""
	@echo "  make sync-agents    Sync canonical agents → Claude + Gemini"
	@echo "  make brain-export   Export brain memories to JSON"
	@echo "  make brain-import   Import brain memories (FILE=path.json)"
	@echo "  make brain-stats    Show brain statistics"
	@echo "  make commit         Semantic commit (TYPE=feat MSG='...')"
	@echo "  make audit          Run workspace health check"
	@echo "  make test           Run validation suite"

sync-agents:
	@bash execution/sync_agents.sh

brain-export:
	@python3 execution/brain.py export

brain-import:
	@python3 execution/brain.py import $(FILE)

brain-stats:
	@python3 execution/brain.py stats

commit:
	@python3 execution/commit_helper.py $(TYPE) $(MSG)

audit:
	@echo "Running audit..."
	@python3 -c "import json; json.load(open('.claude/settings.json')); print('✅ .claude/settings.json')"
	@python3 -c "import json; json.load(open('.gemini/settings.json')); print('✅ .gemini/settings.json')"
	@test -L CLAUDE.md && echo "✅ CLAUDE.md symlink" || echo "❌ CLAUDE.md"
	@test -L GEMINI.md && echo "✅ GEMINI.md symlink" || echo "❌ GEMINI.md"
	@python3 execution/brain.py stats

test:
	@bash execution/sync_agents.sh
	@python3 execution/brain.py last-session --quiet
	@echo "✅ All tests passed"
