# Learned

## L1: Don't reinvent the wheel (2026-04-14)

The v1-v5 workspace template wrote custom scripts for everything: boot, dispatch, comms, memory, wrap-up, agent sync. This was wrong. Claude Code, Gemini CLI, and OpenCode already have built-in:

- **Memory**: CLAUDE.md / GEMINI.md / AGENTS.md + auto-memory + rules dirs
- **Hooks**: Claude has 25+ lifecycle events. Gemini has 4. Both run shell scripts.
- **Agents**: Both have `.claude/agents/` and `.gemini/agents/` with YAML frontmatter.
- **Skills**: Both have `.claude/skills/` and `.gemini/skills/` with on-demand loading.
- **Sessions**: Both have resume/continue. Claude has fork. Both persist.
- **Context**: Both have /compact, /clear. Claude has /context.
- **MCP**: Both support Model Context Protocol for external tools.
- **Headless**: `claude -p` and `gemini -p` for automation.
- **Plan mode**: Both support read-only exploration.

**Rule**: Only write custom code when the feature doesn't exist natively. The template is config + conventions, not code.

## L2: Claude First (2026-04-14)

Claude Code is the primary platform. It has the richest hook system (25+ events vs Gemini's 4), the best agent teams support, and is the user's preferred model. Gemini CLI is secondary (free tier, large context). OpenCode is tertiary (open-source, vendor-agnostic).

## L3: Brain (Chroma) works (2026-04-14)

The vector DB brain actually works. Boot recall returned relevant memories. Wrap-up stored context that survived across sessions. Don't replace — enhance minimally.

## L4: Premature execution destroys context (2026-04-14)

A previous session ran cleanup + creation before the plan was approved. This deleted files that were needed and left the workspace in a half-state. Always plan first, execute after explicit approval.

## L5: Bash associative arrays break on macOS zsh (2026-04-14)

`declare -A` in bash works, but when scripts run via `bash script.sh` on macOS the default `set -u` catches empty arrays as unbound. Use `case` statements instead for cross-shell compatibility. Also use `|| true` on grep calls that might return empty.

## L6: sync_agents.sh is fragile with YAML parsing (2026-04-14)

Parsing YAML frontmatter with sed/grep works for simple cases but breaks on multiline descriptions. Future: consider a Python-based parser or yq if YAML gets complex.

## L7: Rule isolation is critical for template adoption (2026-04-14)

When users initialise a project from DarkFact, the template's own rules (CLI First, backend/CLI god persona) bleed into the project context and cause contradictions — e.g. a SwiftUI project told to avoid browser UIs. Fix: `core.md` must be domain-agnostic. `soul.md` and `user.md` must be templates rewritten during `/onboard`. Project-specific rules live in `memory/project/rules.md` and always take precedence.

## L8: Onboarding is UX, not infra (2026-04-14)

The original `init.sh` asked technical Bash questions ("Do you use external LLM APIs?"). Users are not sysadmins. Split onboarding: `init.sh` = pure scaffolding (dirs, git, symlinks), `/onboard` = AI conversation that asks for the goal in plain language and recommends a stack. The LLM IS the UX.

## L9: Upstream feedback needs zero friction (2026-04-14)

Template users won't report bugs if it requires navigating GitHub manually. The `/report-bug` workflow uses `gh` CLI to create issues in one step, with context auto-captured (template version, platform, project type). Falls back to a formatted local file if `gh` isn't available.

## L10: darkfact() shell function is the entry point (2026-04-14)

The `anti()` function pointed to a dead path (`/ai/Workspace Template/execution/new_project.py`). The new `darkfact()` function copies the template, resets git, adds the upstream remote, and presents an IDE picker (Antigravity/Claude/Terminal). This is how non-technical users start projects.

## L11: Native-first is UI-fragile — daemon pattern has real merit (2026-04-14)

Going native-first (hooks, skills, workflows) is the right call for simplicity and portability. But the old Dark Factory CLI daemon had one genuine advantage: it queued and retried tasks independently of the UI. When Antigravity/Claude/Gemini hit API rate limits or crash, native hooks die with them — there is no retry layer. DarkFact v1.1.0 has this gap. Mitigation options (in order of complexity):
1. **Checkpoint pattern** — each workflow step writes output before moving to the next. Crash = resume from last checkpoint, not from zero.
2. **Headless fallback** — for long tasks, use `claude -p` / `gemini -p` from terminal. Survives UI crashes.
3. **Lightweight local queue** — JSON task file + cron/launchd. Only if 1+2 are insufficient.

Rule: native-first for sessions, checkpoints for resilience.

## L12: profile.json conflates template metadata with project config (2026-04-14)

The default `profile.json` contained only template infrastructure fields (`name`, `description`, `version`, `platforms`, `agents`, `memory`). The `/onboard` workflow then instructed agents to update it with project fields (`onboarding_complete`, `project_type`, `tech_stack`, etc.) — but since no stubs existed, agents fully overwrote the file, discarding all infrastructure config.

**Fix applied**: Added onboarding stub fields (`onboarding_complete: false`, `project_name: ""`, `project_type: ""`, `tech_stack: []`) directly to the template default. Agents now update only the stubs during onboarding; infrastructure fields survive intact.

**Rule**: Any field the `/onboard` workflow writes must be stubbed in the template default. Onboarding = fill in stubs, not rewrite file.
