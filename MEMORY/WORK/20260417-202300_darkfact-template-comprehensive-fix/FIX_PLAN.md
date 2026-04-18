# DarkFact Comprehensive Fix Plan
**Generated:** 2026-04-17 | **Session:** Architect + 6 parallel research agents
**Scope:** Every confirmed defect. Priority-ordered. Actionable.

---

## Mission (Restated)

DarkFact exists to make AI coding **provider-agnostic**. Switch from Claude Code to Gemini CLI to OpenCode and back without friction. No lock-in. Bold, agentic, owning nothing but the framework.

Every fix below is evaluated through that lens. If it doesn't serve provider-agnosticism, it doesn't belong.

---

## The Damage Report (What's Actually Broken Today)

Before fixes: this is what a team gets when they clone DarkFact and run `init.sh`:

| What they expect | What actually happens |
|------------------|-----------------------|
| `profile.json` written | ❌ NOT CREATED — function ordering bug aborts init |
| `/onboard`, `/boot` as slash commands | ❌ MISSING — .claude/skills/ empty (sync_skills reads unpopulated dir) |
| Hooks fire on session start | ❌ MISSING — .claude/settings.json never copied to new project |
| Agent identity generic | ❌ POISONED — AGENTS.md says "You are Vex, DarkFact coordinator" |
| Rules scoped to project | ❌ WRONG — rules.md says "Documentation First", contradicts core rules |
| `make sync` safe to run | ❌ DESTRUCTIVE — sync_rules.sh deletes .claude/rules/ with no source to restore from |
| Boot shows correct state | ❌ BROKEN — verify_workspace blocks all Bash calls (no profile.json) |

Result: team opens Claude Code, every Bash call is blocked, `/onboard` can't run, the agent is Vex, and `make sync` nukes rules. They spend two days "fixing the template" instead of their project.

---

## PHASE 1 — Stop the Bleeding
### P0 Fixes — Ship Before Next Deploy

These are live breakages. Do not tag a new release without all of these.

---

### P0-1: Fix init.sh function ordering (CRITICAL — 5 min fix)

**File:** `/Users/vetus/ai/DarkFact/init.sh`
**Lines:** 271 (`main "$@"`) and 274 (`write_profile()` definition)

**Confirmed:** bash does NOT hoist functions. `write_profile` is called inside `main()` (line 255) but defined at line 274, AFTER `main "$@"` on line 271. At runtime: `write_profile: command not found`. set -euo pipefail does NOT abort in bash 3.2 when an undefined command runs inside a called function — so init.sh prints "✅ Workspace scaffolded." while having failed silently.

**Fix:** Move `write_profile()` function definition (lines 274–305) to **above the `main()` definition**. Place it at line 137 where the `# ── Profile ──` comment placeholder already sits.

Also: **move `main "$@"` to the very last line of the file**, per O'Reilly Bash Cookbook §19.14. This is the canonical pattern — it prevents ALL forward-reference bugs permanently.

```bash
# Pattern: every function defined ABOVE the main() call
write_profile() { ... }
setup_instructions() { ... }
# ... all other functions ...
main() { ... }   # defined last as the orchestrator
main "$@"        # called at EOF
```

**Also fix in write_profile:**
- Change `profile['platform'] = '$PLATFORM'` → `profile['primary_platform'] = '$PLATFORM'` (wrong key, doesn't match schema)
- Read template version from `$(dirname "$0")/.agent/version`, not from `.agent/version` in CWD

**Add preflight check** (near top of script, after PLATFORM detection):
```bash
for cmd in python3 git; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "❌ '$cmd' not found"; exit 1; }
done
TEMPLATE_DIR="$(dirname "$0")/template"
[ -f "$TEMPLATE_DIR/.agent/profile.json" ] || { echo "❌ template/.agent/profile.json missing"; exit 1; }
```

**Also fix:** `--name "value"` (space form) is not parsed. Change arg parsing:
```bash
while [ $# -gt 0 ]; do
    case "$1" in
        --name=*) PROJECT_NAME="${1#*=}"; shift ;;
        --name)   PROJECT_NAME="$2"; shift 2 ;;
        *)        shift ;;
    esac
done
```

**Also fix:** Version banner reads from CWD instead of template dir:
```bash
echo "🏭 DarkFact v$(cat "$(dirname "$0")/.agent/version" 2>/dev/null || echo '?') — Project Bootstrap"
```

---

### P0-2: Fix template/.agent/profile.json schema (CRITICAL — 10 min)

**File:** `/Users/vetus/ai/DarkFact/template/.agent/profile.json`

**Confirmed:** Current template has 6 fields, 3 of which are wrong (`user_handle`, `agent_handle`, `persona`). Missing 14+ fields including `features{}`, `agents[]`, `memory{}`, `project_type`, `soul_type`, `tech_stack`, `status`. The onboard workflow crashes immediately on `p['features']['security_rules']` because `features` doesn't exist.

**Fix:** Replace entire content with full-schema stub:

```json
{
  "project_name": "",
  "project_type": "",
  "soul_type": "",
  "status": "active",
  "onboarding_complete": false,
  "primary_platform": "",
  "tech_stack": [],
  "features": {
    "brain": true,
    "hooks": true,
    "agent_teams": true,
    "skills": true,
    "telos_lite": false,
    "security_rules": false,
    "style_guide": false,
    "llm_apis": false
  },
  "agents": ["lead", "dev", "designer", "analyst", "architect", "qa", "docs", "maintainer"],
  "memory": {
    "brain_backend": "chromadb",
    "brain_path": ".agent/memory/brain",
    "tiers": ["scratch", "project", "brain", "global"]
  }
}
```

Note: `project_name` is empty string (not "New Project") — `write_profile()` sets it dynamically.

---

### P0-3: Fix template/.agent/memory/project/rules.md (CRITICAL — 5 min)

**File:** `/Users/vetus/ai/DarkFact/template/.agent/memory/project/rules.md`

**Confirmed:** Current content is generic ChatGPT boilerplate ("Clarity Over Brevity", "Documentation First"). Rule #5 ("Documentation First") directly contradicts DarkFact's core rule ("No Placeholders"). This overrides core rules on boot for every new project.

**Fix:** Replace with a minimal scope/invitation stub:

```markdown
# Project-Specific Rules

_These override core rules when they conflict. Populate during /onboard._

## Scope

- Only read/write files inside this project directory.
- Never touch sibling project directories without explicit instruction.

## Add project-specific overrides below
```

This is intentionally minimal. Teams fill it in during onboarding.

---

### P0-4: Guard sync_rules.sh against destruction (CRITICAL — 10 min)

**File:** `/Users/vetus/ai/DarkFact/execution/sync_rules.sh`

**Confirmed:** Lines 20-21 run `find .claude/rules -delete` BEFORE checking if source dirs exist. Since `.agent/rules/_core/` etc. don't exist, every `make sync` invocation silently deletes all 4 `.claude/rules/*.md` files and exits 0 with "✅ Rule sync complete."

**Immediate fix (two-line guard at top of script):**
```bash
if [ ! -d "$CORE_RULES_DIR" ] && [ ! -d "$CLAUDE_RULES_DIR" ] && [ ! -d "$GEMINI_RULES_DIR" ]; then
    echo "❌ sync_rules: source dirs missing under .agent/rules/ — aborting to prevent rule destruction"
    echo "   Run: make migrate-rules  (one-time migration step)"
    exit 1
fi
```

This stops the bleeding immediately. The structural fix (P1-5) completes the job.

---

### P0-5: Fix init.sh — copy settings.json, rules, agents, skills to new projects (CRITICAL — 20 min)

**File:** `/Users/vetus/ai/DarkFact/init.sh`

**Confirmed:** `scaffold_core()` creates empty `.claude/agents/`, `.claude/rules/`, `.claude/skills/`, `.gemini/agents/`, `.gemini/skills/` — but never populates them. A new project has NO hooks (`.claude/settings.json` missing), NO rules, NO agents, NO skills.

**Fix:** Add these copy steps inside `scaffold_core()` after the mkdir block:

```bash
# Copy hooks config (enables SessionStart, PreToolUse, etc.)
cp "$(dirname "$0")/.claude/settings.json" .claude/settings.json
cp "$(dirname "$0")/.gemini/settings.json" .gemini/settings.json

# Copy canonical rules
for f in "$(dirname "$0")"/.claude/rules/*.md; do
    [ -f "$f" ] && cp "$f" .claude/rules/
done

# Copy canonical agents and skills from DarkFact template
for f in "$(dirname "$0")"/.agent/agents/*.md; do
    [ -f "$f" ] && cp "$f" .agent/agents/
done
for f in "$(dirname "$0")"/.agent/skills/*.md; do
    [ -f "$f" ] && cp "$f" .agent/skills/
done
for f in "$(dirname "$0")"/.agent/workflows/*.md; do
    [ -f "$f" ] && cp "$f" .agent/workflows/
done
```

Then the existing `sync_agents()` and `sync_skills()` calls in `main()` will populate `.claude/agents/` and `.claude/skills/` correctly from the now-populated `.agent/` dirs.

**Note:** This is the interim fix. The clean-room architecture (P2-1) does this better.

---

### P0-6: Fix AGENTS.md poisoning — create template/AGENTS.md (CRITICAL — 20 min)

**File to create:** `/Users/vetus/ai/DarkFact/template/AGENTS.md`

**Confirmed:** `init.sh:146` copies DarkFact's own `AGENTS.md` into every new project verbatim. This contains: "You are Vex — DarkFact project coordinator", "Never push to darkfact-upstream", DarkFact-specific PAI rules, DarkFact version number, DarkFact-specific `/report-bug` routing.

**Fix:** Create `template/AGENTS.md` — generic, provider-agnostic instructions. Key changes:
- Remove "You are Vex" → say "Your identity is in `.agent/identity/soul.md`"
- Remove DarkFact-specific memory paths section
- Remove "Never push to darkfact-upstream" (relevant to DarkFact's own repo, not downstream projects — it's in learned.md where it belongs)
- Make `/report-bug` generic ("report bugs in your project repo")
- Keep the 8-agent table, provider notes, and workflow table — these are genuinely generic

Update `init.sh:146` to: `cp "$(dirname "$0")/template/AGENTS.md" AGENTS.md`

Also: create `template/.agent/identity/soul.md` (generic persona template):
```markdown
# Soul: [Your Agent Name Here]

**Name**: [Set during /onboard]
**Role**: Primary project coordinator

Your full persona is defined during /onboard.
```

---

## PHASE 2 — Close All Holes
### P1 Fixes — Ship This Week

---

### P1-1: Create .agent/rules/ canonical structure and complete the migration

**Files to create:**
- `/Users/vetus/ai/DarkFact/.agent/rules/_core/scope.md`
- `/Users/vetus/ai/DarkFact/.agent/rules/_core/security.md`
- `/Users/vetus/ai/DarkFact/.agent/rules/claude/hooks.md`
- `/Users/vetus/ai/DarkFact/.agent/rules/claude/memory.md`
- `/Users/vetus/ai/DarkFact/.agent/rules/gemini/` (empty dir + .keep for now)

**Steps:**
```bash
mkdir -p .agent/rules/_core .agent/rules/claude .agent/rules/gemini
git mv .claude/rules/scope.md    .agent/rules/_core/scope.md
git mv .claude/rules/security.md .agent/rules/_core/security.md  # use .claude version (more complete)
git mv .claude/rules/hooks.md    .agent/rules/claude/hooks.md
git mv .claude/rules/memory.md   .agent/rules/claude/memory.md
git rm .agent/rules/security.md  # delete drifted duplicate
touch .agent/rules/gemini/.keep
```

Then update `sync_rules.sh` to use `rsync -a --delete` per hooks.md rule:
```bash
#!/usr/bin/env bash
set -euo pipefail
CORE_RULES_DIR=".agent/rules/_core"
CLAUDE_RULES_DIR=".agent/rules/claude"
GEMINI_RULES_DIR=".agent/rules/gemini"
CLAUDE_DEST_DIR=".claude/rules"
GEMINI_DEST_DIR=".gemini/rules"

# Safety: refuse if no source dirs exist
if [ ! -d "$CORE_RULES_DIR" ] && [ ! -d "$CLAUDE_RULES_DIR" ]; then
    echo "❌ sync_rules: canonical source missing under .agent/rules/ — aborting"
    exit 1
fi

mkdir -p "$CLAUDE_DEST_DIR" "$GEMINI_DEST_DIR"

[ -d "$CORE_RULES_DIR" ]  && rsync -a --delete "$CORE_RULES_DIR/"  "$CLAUDE_DEST_DIR/" && \
                              rsync -a           "$CORE_RULES_DIR/"  "$GEMINI_DEST_DIR/"
[ -d "$CLAUDE_RULES_DIR" ] && rsync -a          "$CLAUDE_RULES_DIR/" "$CLAUDE_DEST_DIR/"
[ -d "$GEMINI_RULES_DIR" ] && rsync -a          "$GEMINI_RULES_DIR/" "$GEMINI_DEST_DIR/"

echo "✅ Rule sync complete."
```

Add `sync_rules.sh` to `update-template` in Makefile after the existing syncs.

---

### P1-2: Fix SessionStart — remove || true, fix lying prompt hook

**File:** `/Users/vetus/ai/DarkFact/.claude/settings.json`
**Line:** SessionStart command hook

**Confirmed:** `|| true` + `2>/dev/null` means any full_boot.sh failure is invisible. The following `prompt` hook then tells the model "Full boot context was just injected above" which is a lie when nothing was injected.

**Fix:**
```json
"command": "bash execution/hooks/full_boot.sh"
```

Remove `2>/dev/null || true` entirely. `full_boot.sh` already handles each step gracefully with its own `|| echo "(no data)"` fallbacks. The outer suppression is defense against defense and actively harmful.

---

### P1-3: Fix PreToolUse guards — completeness and fail-close

**File:** `/Users/vetus/ai/DarkFact/.claude/settings.json` (Write/Edit matcher hooks)

**Confirmed:** Guard misses `~/.claude/PAI/`, `~/.claude/settings.json`, `~/.claude/CLAUDE.md`. Also: if python3 parse fails, `fp` is empty → exit 0 → fail-open.

**Fix the pattern in both Write and Edit hooks:**
```bash
input=$(cat)
fp=$(echo "$input" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get('tool_input',{}).get('file_path',''))
except:
    sys.exit(2)
" 2>/dev/null)
# Fail closed: if parse failed (exit 2) or fp empty, block
[ $? -ne 0 ] && echo "⛔ PreToolUse: parse failed, blocking as precaution" >&2 && exit 2
[ -z "$fp" ] && exit 0  # No file_path field = not a file operation, allow
case "$fp" in
    */.claude/MEMORY/*|*/MEMORY/LEARNING/*|\
    */.claude/PAI/*|\
    "$HOME/.claude/settings.json"|\
    "$HOME/.claude/CLAUDE.md") exit 2 ;;
esac
```

**Also fix performance:** Replace python3 startup with shell-native extraction where possible (per hooks.md rule). The python3 call is currently 50-80ms on every Write/Edit.

---

### P1-4: Fix subagent_start.sh JSON escaping

**File:** `/Users/vetus/ai/DarkFact/execution/hooks/subagent_start.sh`

**Confirmed:** Uses `sed 's/"/\\"/g'` but doesn't escape backslashes, tabs, carriage returns. Any agent file or learned.md entry with a backslash produces invalid JSON. Claude Code silently drops the hook output — the subagent gets no context injection.

**Fix:** Replace the string concatenation with python3 JSON builder:
```bash
#!/usr/bin/env bash
input=$(cat)
agent_type=$(echo "$input" | python3 -c "
import sys,json
try: print(json.load(sys.stdin).get('agent_type','unknown'))
except: print('unknown')
" 2>/dev/null || echo "unknown")

python3 << EOF
import json, os

def safe_read(path, lines=None):
    try:
        with open(path) as f:
            content = f.readlines()
        return ''.join(content[:lines] if lines else content)
    except FileNotFoundError:
        return ''

agent_type = "$agent_type"
ctx = (safe_read(f'.agent/agents/{agent_type}.md', 30)
       + '\nPROJECT RULES:\n' + safe_read('.agent/memory/project/rules.md')
       + '\nRECENT LEARNINGS:\n'
       + ''.join(open('.agent/memory/project/learned.md').readlines()[-40:]))

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SubagentStart",
        "additionalContext": ctx
    }
}))
EOF
```

---

### P1-5: Fix onboard skill — make it a pointer to workflow

**File:** `/Users/vetus/ai/DarkFact/.agent/skills/onboard.md`

**Confirmed:** skills/onboard.md diverges from workflows/onboard.md. Missing checkpoint recovery, missing explicit `onboarding_complete=true` step (a previously-fixed bug that regressed), missing rule activation step.

**Fix:** Make the skill a thin pointer:
```markdown
# /onboard

Read and follow `.agent/workflows/onboard.md` exactly. Do not skip steps.

The full workflow handles: project goal clarification, tech stack selection,
profile.json update, identity configuration, rule activation, and
onboarding_complete flag. All 9 steps are required.
```

Also: make `workflows/onboard.md` Step 5's profile update defensive:
```python
p.setdefault('features', {})['security_rules'] = False
p.setdefault('features', {})['style_guide'] = False
```

---

### P1-6: Fix Gemini settings.json hook schema

**File:** `/Users/vetus/ai/DarkFact/.gemini/settings.json`

**Confirmed:** Missing `hooks` array and `type` field structure. Schema should match Claude Code's pattern.

**Fix:**
```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "python3 execution/brain.py last-session --quiet 2>/dev/null; printf '\\n▶ Run /boot to load full context\\n'"
      }]
    }],
    "SessionEnd": [{
      "hooks": [{
        "type": "command",
        "command": "CHANGED=$(git diff --stat HEAD 2>/dev/null | wc -l | tr -d ' '); if [ \"$CHANGED\" -gt 0 ]; then echo 'Session had uncommitted changes — run /wrap-up at start of next session.'; fi"
      }]
    }]
  }
}
```

---

### P1-7: Fix workspace verifier — allow .claude/worktrees/ paths

**File:** `/Users/vetus/ai/DarkFact/execution/hooks/verify_workspace.sh`

**Confirmed:** The verifier blocks ALL bash calls when the working directory is a Claude Code worktree (e.g. `.claude/worktrees/agent-xxx/`). This breaks every parallel agent invocation. Also blocks voice notification curl calls to localhost:8888.

**Fix:** Add an early exit for worktree paths:
```bash
# Allow operations inside this project's own worktrees
case "$PWD" in
    */.claude/worktrees/*) exit 0 ;;  # legitimate parallel agent work
esac
```

Also whitelist `curl localhost:*` in the Bash hook pattern. Voice notifications are not cross-project writes.

---

### P1-8: Fix hooks.md — correct hook type list

**File:** `/Users/vetus/ai/DarkFact/.claude/rules/hooks.md` (and .agent/rules/claude/hooks.md after migration)

**Confirmed:** Claims Claude Code supports 4 hook types: `command`, `prompt`, `http`, `agent`. Only `command` and `prompt` are valid. `agent` type was explicitly a past bug (L14 in learned.md) that broke ALL hooks.

**Fix:** Line 4 should read:
```
Claude Code supports exactly two hook types: `command` and `prompt`.
Any other type silently breaks ALL hooks in the file — not just the bad entry.
```

---

### P1-9: Fix brain.py scan-blockers exit code

**File:** `/Users/vetus/ai/DarkFact/execution/brain.py:519`

**Confirmed:** `sys.exit(1 if found else 0)` — exits 1 when blockers ARE found. `full_boot.sh:87` has `|| echo "(none)"` which fires when blockers ARE found, printing "(none)" to describe a state where blockers exist. This is inverted.

**Fix in full_boot.sh:87:**
```bash
# scan-blockers exits 1 when blockers are found (1 = found, 0 = none)
# Don't use || here — the non-zero exit is signal, not error
python3 execution/brain.py scan-blockers 2>/dev/null
```

Or fix brain.py:519 to exit 0 in all success cases and use stdout only.

---

### P1-10: Remove noisy boot recall

**File:** `/Users/vetus/ai/DarkFact/execution/hooks/full_boot.sh:82`

**Confirmed:** `recall "current work session goals" --n 3` returns stale results at distance 0.64 (low relevance). Injects ~240 tokens of 2-day-old noise into every boot. `last-session` already covers current context better.

**Fix:** Remove lines 81-84 (the BRAIN RECALL section) entirely, or replace with:
```bash
echo "--- BRAIN RECALL ---"
python3 execution/brain.py recall "$(cat .agent/memory/project/goals.md | head -5)" --n 2 2>/dev/null || true
```

---

## PHASE 3 — Harden and Automate
### P2 Fixes — Next Sprint

---

### P2-1: Clean Room Architecture — complete the template/ directory

**Context:** The `template/` directory was the right call. It's barely started. The complete vision:

```
template/
├── .agent/
│   ├── profile.json          # full schema stub (done in P0-2)
│   ├── identity/
│   │   ├── soul.md           # generic: "Name set during /onboard"
│   │   └── user.md           # generic: "[Set during /onboard]"
│   ├── memory/
│   │   └── project/
│   │       ├── goals.md      # generic stub ("run /onboard")
│   │       ├── learned.md    # L1 two-repo model only
│   │       ├── backlog.md    # empty header
│   │       ├── rules.md      # scope stub (done in P0-3)
│   │       └── session_log.md # empty header
│   ├── agents/               # copies of 8 canonical agents
│   ├── skills/               # copies of 8 canonical skills
│   └── workflows/            # copies of canonical workflows
├── .claude/
│   └── settings.json         # full hooks wiring
├── .gemini/
│   └── settings.json
├── AGENTS.md                 # generic (done in P0-6)
└── .gitignore                # generic
```

**Key rule:** `init.sh` becomes `rsync -a template/ ./` + dynamic patches (project name, platform, timestamps). All inline heredocs in `scaffold_core()` are deleted — they're duplicates of what's in `template/`. A single source of truth.

**Add `make sync-template`** that keeps `template/` in sync with canonical .agent/ content (agents, skills, workflows, settings).

---

### P2-2: Provider Registry — .agent/providers/

**Context:** Architect's recommendation. Sync pipeline currently has O(N×M×K) maintenance burden (N providers × M asset types × K transformations scattered across 3 scripts). A registry makes it O(N+M+K).

**Create:**
```
.agent/providers/
├── claude-code.json
├── gemini-cli.json
└── opencode.json
```

Each descriptor:
```json
{
  "name": "claude-code",
  "config_dir": ".claude",
  "agents_dir": ".claude/agents",
  "skills_dir": ".claude/skills",
  "rules_dir": ".claude/rules",
  "model_map": {"pro": "claude-opus-4-7", "flash": "claude-sonnet-4-6", "local": "claude-haiku-4-5"},
  "tool_map": {"read": "Read", "write": "Write", "edit": "Edit", "shell": "Bash"},
  "supports_hooks": true,
  "supports_rules": true,
  "supports_dir_symlinks": false
}
```

**New `sync.sh`** that iterates all providers from the registry and applies each transformation. `sync_agents.sh`, `sync_skills.sh`, `sync_rules.sh` stay as compatibility shims or are folded in.

**Impact:** Adding Cursor, Codex, GitHub Copilot = add one JSON file. Zero script changes.

---

### P2-3: Self-updating Makefile

**Context:** "Makefile was not auto-updated (self-overwrite risk)" is architectural surrender. Teams on old Makefiles can't pull future `make` targets.

**Fix:** Make reads the entire Makefile into memory before executing. Overwriting it mid-run is safe for the current invocation. Pattern:

```makefile
update-template:
    # ... existing tarball download ...
    # Self-update Makefile from downloaded tarball
    @if ! diff -q "$$TMPDIR/src/Makefile" "./Makefile" >/dev/null 2>&1; then \
        cp "$$TMPDIR/src/Makefile" "./Makefile.new" && \
        echo "⚡ Makefile updated — new targets available after this run." && \
        echo "   Review: diff Makefile Makefile.new" && \
        mv Makefile.new Makefile; \
    fi
```

The `mv` is atomic (POSIX rename). The next `make` invocation picks up the new file.

---

### P2-4: update-template — add sync_rules.sh call

**File:** `/Users/vetus/ai/DarkFact/Makefile`

After applying template updates, currently syncs agents + skills but not rules. Add:
```makefile
@bash execution/sync_rules.sh
```

After Issues P1-1 (canonical dirs exist) and P0-4 (guard in place), this is safe.

---

### P2-5: Extend make audit with hook validation

**File:** `/Users/vetus/ai/DarkFact/Makefile` (audit target)

Add:
```makefile
audit:
    @python3 -m json.tool .claude/settings.json >/dev/null && echo "✅ .claude/settings.json valid JSON"
    @python3 -m json.tool .gemini/settings.json >/dev/null && echo "✅ .gemini/settings.json valid JSON"
    # Check for || true in PreToolUse hooks (swallows exit 2 guard)
    @python3 -c "
import json
s = json.load(open('.claude/settings.json'))
for hook_list in s.get('hooks', {}).values():
    for entry in hook_list:
        for h in entry.get('hooks', []):
            cmd = h.get('command', '')
            if '|| true' in cmd and 'PreToolUse' in str(hook_list):
                print(f'⚠️ PreToolUse hook has || true: {cmd[:60]}')
print('✅ No dangerous || true in PreToolUse hooks')
"
    @test -L CLAUDE.md && echo "✅ CLAUDE.md symlink" || echo "❌ CLAUDE.md not a symlink"
    @test -L GEMINI.md && echo "✅ GEMINI.md symlink" || echo "❌ GEMINI.md not a symlink"
    @python3 execution/brain.py stats
```

---

### P2-6: Add make test-init smoke test

**File:** `/Users/vetus/ai/DarkFact/Makefile`

```makefile
test-init:
    @echo "Running init.sh smoke test in temp dir..."
    @TMPDIR=$$(mktemp -d); \
    cd "$$TMPDIR" && bash $(PWD)/init.sh --name=smoketest 2>&1; \
    echo "Checking artifacts..."; \
    [ -f WORKSPACE ] && echo "✅ WORKSPACE" || echo "❌ WORKSPACE missing"; \
    [ -f .agent/profile.json ] && echo "✅ profile.json" || echo "❌ profile.json missing"; \
    [ -f .claude/settings.json ] && echo "✅ .claude/settings.json" || echo "❌ hooks missing"; \
    [ -f AGENTS.md ] && echo "✅ AGENTS.md" || echo "❌ AGENTS.md missing"; \
    ls .claude/skills/*.md 2>/dev/null && echo "✅ skills present" || echo "❌ .claude/skills empty"; \
    ls .claude/agents/*.md 2>/dev/null && echo "✅ agents present" || echo "❌ .claude/agents empty"; \
    python3 -c "import json; p=json.load(open('.agent/profile.json')); assert 'features' in p, 'features missing'; assert p['onboarding_complete']==False" && echo "✅ profile schema" || echo "❌ profile schema wrong"; \
    rm -rf "$$TMPDIR"; \
    echo "Smoke test complete."
```

This test should be a release blocker. No tag without it passing.

---

### P2-7: merge_profile.py — fix hardcoded version

**File:** `/Users/vetus/ai/DarkFact/execution/merge_profile.py:27`

```python
# BEFORE:
"template_version": "1.1.0",

# AFTER:
import os
_version_file = os.path.join(os.path.dirname(__file__), '..', '.agent', 'version')
_template_version = open(_version_file).read().strip() if os.path.exists(_version_file) else "unknown"
# ...
"template_version": _template_version,
```

---

### P2-8: Fix onboard workflow — defensive profile updates

**File:** `/Users/vetus/ai/DarkFact/.agent/workflows/onboard.md`

Any Python block that writes to `profile.json` should use `.setdefault()`:
```python
p.setdefault('features', {})['security_rules'] = False
p.setdefault('features', {})['style_guide'] = False
p.setdefault('features', {})['llm_apis'] = False
```

Also: add a verification step at the end that reads profile.json back and confirms `onboarding_complete == True`.

---

### P2-9: Fix missing workflow files (dangling pointers in skills)

**Context:** `/report-bug`, `/audit`, `/test`, `/resume` skills say "Follow .agent/workflows/X.md exactly" but the workflow files don't exist.

**Options (pick one):**
- A: Create the workflow files (more work, more complete)
- B: Make the skills self-contained (remove the pointer, put the content inline)
- **Recommended: B for short skills (report-bug, audit, test, resume), A only for workflows that need checkpointing (onboard)**

---

## PHASE 4 — Future Architecture
### P3 Deferred Items

These won't break teams today but will bite you in 6 months.

---

### P3-1: Versioned fleet updates (Copier pattern)

**Current:** `make update-template` always pulls `main` — no version pinning, no answers file.

**Future:** 
1. Write `.agent/template_version` to downstream projects at scaffold time
2. Tag every release: `git tag v2.1.4 && git push origin v2.1.4`
3. `make update-template` reads `.agent/template_version`, fetches that release tag, diffs, prompts
4. Migrate with `.agent/migrations/v2_to_v3.py` scripts for breaking schema changes

This is the pattern Copier uses and is exactly right for fleet management.

---

### P3-2: ShellCheck in CI

Add to `make test`:
```makefile
@if command -v shellcheck >/dev/null 2>&1; then \
    shellcheck init.sh execution/sync_agents.sh execution/sync_skills.sh execution/sync_rules.sh; \
    echo "✅ ShellCheck passed"; \
else \
    echo "⚠️ shellcheck not installed — run: brew install shellcheck"; \
fi
```

ShellCheck catches the function-ordering class of bugs at write time, not at runtime.

---

### P3-3: schema_version + profile.json migrations

**Context:** No way to know if a downstream project's profile.json is current schema. When you add fields, old projects get outdated profiles.

**Pattern:**
```json
{ "schema_version": 3, ... }
```

`make update-template` runs `execution/migrations/profile_v2_to_v3.py` if needed. Safe, idempotent.

---

### P3-4: GitHub CLI Agent Skills integration

Research agent found: GitHub shipped portable "Agent Skills" via `gh` CLI in April 2026. The spec works across Claude Code, Cursor, Codex, Copilot, Gemini. Evaluate as the future distribution channel for DarkFact's skills — potentially replaces per-provider copy via `sync_skills.sh`.

This directly serves the mission: truly provider-agnostic skills that work with any future tool.

---

## Implementation Order (Sequenced for Zero Regression)

```
Day 1 (< 2 hours):
  P0-4  sync_rules guard (prevents active destruction)
  P0-1  init.sh function order + preflight + flag parsing
  P0-2  template/profile.json full schema
  P0-3  template/rules.md content
  P0-6  template/AGENTS.md generic version

Day 2 (< 3 hours):
  P0-5  init.sh copies settings.json + rules + agents + skills
  P1-1  .agent/rules/_core/ migration + rsync-based sync_rules.sh
  P1-2  SessionStart || true removal
  P1-5  onboard skill → thin pointer
  P2-6  make test-init smoke test (VERIFY EVERYTHING)

Day 3 (< 3 hours):
  P1-3  PreToolUse guard completeness + fail-close
  P1-4  subagent_start.sh JSON escaping
  P1-6  Gemini settings.json schema
  P1-7  workspace verifier worktree allowlist
  P1-8  hooks.md type list fix
  P1-9  brain.py scan-blockers exit code
  P1-10 remove noisy boot recall

Day 4-5:
  P2-1  Complete template/ clean room
  P2-2  Provider registry .agent/providers/
  P2-3  Makefile self-update
  P2-4  update-template + sync_rules
  P2-5  make audit hook validation
  P2-7  merge_profile.py version fix
  P2-8  onboard workflow defensive updates
  P2-9  missing workflow files / self-contained skills

Next sprint:
  P3-1  Versioned fleet updates
  P3-2  ShellCheck CI
  P3-3  schema_version + migrations
  P3-4  GitHub CLI Agent Skills evaluation

Fleet deploy: ONLY after make test-init passes in a clean temp dir.
```

---

## Release Gate

Before tagging ANY release and running `overlay_all.sh` (fleet deploy):

1. `make test-init` passes in a clean temp dir
2. End-to-end lifecycle in test dir: `init.sh` → open Claude Code → `/boot` shows correct state → `/onboard` completes → `/wrap-up` stores summary
3. `make sync` runs twice, `.claude/rules/` unchanged on second run
4. Manually verify a new project does NOT contain "Vex" or "DarkFact" in AGENTS.md
5. Diff `.agent/profile.json` in test project — confirm all fields present, `onboarding_complete: false`

---

## Files Changed by Phase

| Phase | File | Change Type |
|-------|------|-------------|
| P0 | `init.sh` | Move write_profile above main; add preflight; fix flag parsing; add copy steps |
| P0 | `template/.agent/profile.json` | Replace with full schema |
| P0 | `template/.agent/memory/project/rules.md` | Replace with scope stub |
| P0 | `execution/sync_rules.sh` | Add guard at top |
| P0 | `template/AGENTS.md` | Create new generic file |
| P0 | `template/.agent/identity/soul.md` | Create generic template |
| P1 | `.agent/rules/_core/scope.md` | Create (moved from .claude/rules/) |
| P1 | `.agent/rules/_core/security.md` | Create (moved from .claude/rules/) |
| P1 | `.agent/rules/claude/hooks.md` | Create (moved from .claude/rules/) |
| P1 | `.agent/rules/claude/memory.md` | Create (moved from .claude/rules/) |
| P1 | `execution/sync_rules.sh` | Rewrite with rsync pattern |
| P1 | `.claude/settings.json` | Remove || true from SessionStart; fix PreToolUse guard |
| P1 | `execution/hooks/subagent_start.sh` | Rewrite with python3 JSON builder |
| P1 | `.agent/skills/onboard.md` | Make thin pointer to workflow |
| P1 | `.agent/workflows/onboard.md` | Fix defensive setdefault |
| P1 | `.gemini/settings.json` | Fix hook schema |
| P1 | `execution/hooks/verify_workspace.sh` | Add worktree allowlist |
| P1 | `.claude/rules/hooks.md` | Fix: 2 hook types, not 4 |
| P1 | `execution/brain.py` | Fix scan-blockers exit code |
| P1 | `execution/hooks/full_boot.sh` | Remove noisy recall |
| P2 | `template/` | Complete skeleton |
| P2 | `.agent/providers/` | Create registry |
| P2 | `Makefile` | Self-update, audit, test-init, sync-rules |
| P2 | `execution/merge_profile.py` | Read version from file |
