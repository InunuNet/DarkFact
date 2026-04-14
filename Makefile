# DarkFact v1.2.1 Makefile

.PHONY: help sync-agents brain-export brain-import brain-stats commit audit test update-template onboard check-feedback

help:
	@echo "🏭 DarkFact v1.2.1"
	@echo ""
	@echo "  Project Setup"
	@echo "  make onboard           Start AI-guided project onboarding"
	@echo ""
	@echo "  Agents"
	@echo "  make sync-agents       Sync canonical agents → Claude + Gemini"
	@echo ""
	@echo "  Memory / Brain"
	@echo "  make brain-export      Export brain memories to JSON"
	@echo "  make brain-import      Import brain memories (FILE=path.json)"
	@echo "  make brain-stats       Show brain statistics"
	@echo ""
	@echo "  Workflow"
	@echo "  make commit            Semantic commit (TYPE=feat MSG='...')"
	@echo "  make audit             Run workspace health check"
	@echo "  make test              Run validation suite"
	@echo ""
	@echo "  Template"
	@echo "  make update-template   Pull latest DarkFact template updates"
	@echo "  make check-feedback    Check GitHub for new issues + PRs"

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

update-template:
	@echo "🔄 Fetching latest DarkFact template..."
	@git fetch darkfact-upstream --quiet 2>/dev/null && \
		echo "✅ Fetched. Review changes: git log darkfact-upstream/main --oneline -10" || \
		echo "⚠️  Could not reach upstream. Check network or: git remote -v"

onboard:
	@echo "🏭 Starting onboarding..."
	@echo "Open your AI agent and run: /onboard"
	@echo "Or use the workflow at: .agent/workflows/onboard.md"

check-feedback:
	@echo "📬 DarkFact GitHub Feedback"
	@echo ""
	@/opt/homebrew/bin/gh issue list --repo InunuNet/DarkFact --state open --limit 10 2>/dev/null || \
		gh issue list --repo InunuNet/DarkFact --state open --limit 10 2>/dev/null || \
		echo "⚠️  gh CLI not found or not authenticated. Run: brew install gh && gh auth login"
	@echo ""
	@echo "💬 Discussions:"
	@echo "   https://github.com/InunuNet/DarkFact/discussions"
