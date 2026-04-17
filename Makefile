# DarkFact v2.0.0 Makefile

.PHONY: help sync sync-agents sync-skills brain-export brain-import brain-stats commit audit test update-template onboard check-feedback

help:
	@echo "🏭 DarkFact v2.0.0"
	@echo ""
	@echo "  Project Setup"
	@echo "  make onboard           Start AI-guided project onboarding"
	@echo ""
	@echo "  Agents + Skills"
	@echo "  make sync              Sync agents + skills → Claude + Gemini"
	@echo "  make sync-agents       Sync canonical agents → Claude + Gemini"
	@echo "  make sync-skills       Sync canonical skills → Claude + Gemini"
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

sync:
	@bash execution/sync_agents.sh
	@bash execution/sync_skills.sh

sync-agents:
	@bash execution/sync_agents.sh

sync-skills:
	@bash execution/sync_skills.sh

brain-export:
	@python3 execution/brain.py export

brain-import:
	@python3 execution/brain.py import $(FILE)

brain-stats:
	@python3 execution/brain.py stats

commit:
	@python3 execution/commit_helper.py $(TYPE) "$(MSG)"

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
	@# GUARD: downstream projects only — never run inside the DarkFact template repo itself
	@if [ -f ".agent/profile.json" ] && python3 -c "import json,sys; p=json.load(open('.agent/profile.json')); sys.exit(0 if p.get('project_name')=='DarkFact' else 1)" 2>/dev/null; then \
		echo "❌ ABORT: You are inside the DarkFact template repo."; \
		echo "   This command is for downstream projects only."; \
		echo "   To update DarkFact itself: git add . && git commit && git push"; \
		exit 1; \
	fi
	@which gh >/dev/null 2>&1 || { echo "❌ gh CLI not found. Run: brew install gh && gh auth login"; exit 1; }
	@gh auth status >/dev/null 2>&1 || { echo "❌ gh not authenticated. Run: gh auth login"; exit 1; }
	@echo "🔄 Downloading DarkFact template from GitHub..."
	@TMPDIR=$$(mktemp -d); \
	gh api repos/InunuNet/DarkFact/tarball/main > "$$TMPDIR/darkfact.tar.gz" 2>/dev/null || \
		{ echo "❌ Download failed. Check gh auth and network."; rm -rf "$$TMPDIR"; exit 1; }; \
	mkdir -p "$$TMPDIR/src"; \
	tar -xz --strip-components=1 -C "$$TMPDIR/src" -f "$$TMPDIR/darkfact.tar.gz"; \
	echo ""; \
	echo "📋 Infrastructure files that will change:"; \
	for f in .agent/workflows .agent/agents .agent/rules .agent/skills .agent/reference execution/hooks .claude/settings.json .claude/skills .gemini/skills AGENTS.md; do \
		diff -rq "$$TMPDIR/src/$$f" "./$$f" 2>/dev/null | sed 's/^/  • /' || true; \
	done; \
	echo ""; \
	echo "⚡ Applying infrastructure updates..."; \
	rsync -a --delete "$$TMPDIR/src/.agent/workflows/"  .agent/workflows/; \
	rsync -a --delete "$$TMPDIR/src/.agent/agents/"     .agent/agents/; \
	rsync -a --delete "$$TMPDIR/src/.agent/rules/"      .agent/rules/; \
	rsync -a --delete "$$TMPDIR/src/.agent/skills/"     .agent/skills/; \
	rsync -a --delete "$$TMPDIR/src/.agent/reference/"  .agent/reference/ 2>/dev/null || true; \
	rsync -a --delete "$$TMPDIR/src/execution/hooks/"   execution/hooks/; \
	rsync -a --delete "$$TMPDIR/src/.claude/skills/"    .claude/skills/ 2>/dev/null || true; \
	rsync -a --delete "$$TMPDIR/src/.gemini/skills/"    .gemini/skills/ 2>/dev/null || true; \
	cp "$$TMPDIR/src/.claude/settings.json"             .claude/settings.json 2>/dev/null || true; \
	cp "$$TMPDIR/src/AGENTS.md"                         AGENTS.md 2>/dev/null || true; \
	cp "$$TMPDIR/src/execution/brain.py"                execution/brain.py 2>/dev/null || true; \
	cp "$$TMPDIR/src/execution/sync_agents.sh"          execution/sync_agents.sh 2>/dev/null || true; \
	cp "$$TMPDIR/src/execution/sync_skills.sh"          execution/sync_skills.sh 2>/dev/null || true; \
	cp "$$TMPDIR/src/execution/overlay_template.sh"     execution/overlay_template.sh 2>/dev/null || true; \
	cp "$$TMPDIR/src/.agent/version"                    .agent/version 2>/dev/null || true; \
	cp "$$TMPDIR/src/.agent/CHANGELOG.md"               .agent/CHANGELOG.md 2>/dev/null || true; \
	rm -rf "$$TMPDIR"
	@echo "🔄 Syncing agents + skills..."
	@bash execution/sync_agents.sh
	@bash execution/sync_skills.sh
	@NEW_VER=$$(cat .agent/version 2>/dev/null || echo "?"); \
	echo ""; \
	echo "✅ Updated to DarkFact v$$NEW_VER"; \
	echo "   Review changes: git diff"; \
	echo "   Commit when ready: git add -A && git commit -m 'chore: update to DarkFact v$$NEW_VER'"; \
	echo ""; \
	echo "   Note: Makefile was not auto-updated (self-overwrite risk)."; \
	echo "   Check latest: gh api repos/InunuNet/DarkFact/contents/Makefile --jq '.content' | base64 -d"


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
