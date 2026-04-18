# Learned

## L29: PreToolUse hooks — pipe stdin directly to python3, never buffer through a shell variable (2026-04-18)

`input=$(cat); echo "$input" | python3` breaks on large inputs: `echo` mangles JSON containing newlines, backslashes, and `-n` at line start. The pattern works in unit tests but silently corrupts large tool payloads (Write with multi-KB content). The fix: don't buffer at all — pipe stdin directly: `fp=$(python3 -c "..." )` where python3 reads `sys.stdin` from the hook's live stdin pipe.

**Rule**: In PreToolUse hook commands, pipe directly: `fp=$(python3 -c "import json,sys; ..." 2>/dev/null)`. Never do `input=$(cat); echo "$input" | python3`.

## L28: subagent_start.sh must build JSON entirely in python3 — no shell string escaping (2026-04-18)

Shell `sed 's/"/\\"/g'` only escapes double quotes. It misses backslashes, tabs, control characters, and multi-byte sequences that appear in markdown agent files and learned.md. Injected context that contains any of these produces malformed JSON, silently dropping subagent context.

**Rule**: For any shell script that must emit JSON containing arbitrary file content, build the entire JSON object in python3 using `json.dumps()`. No shell interpolation into JSON strings.

## L27: Gemini CLI settings.json hook entries require `"type": "command"` (2026-04-18)

Gemini CLI rejects hook entries without an explicit `type` field. The Claude Code format and Gemini CLI format both require `{"type": "command", "command": "..."}` — bare `{"command": "..."}` silently skips the hook on Gemini.

**Rule**: Every hook entry in `.gemini/settings.json` must have `"type": "command"`. Validate with `python3 -m json.tool` and manually confirm hooks fire after any settings change.

## L26: overlay_template.sh must copy .claude/settings.json (2026-04-16)

`cp -r` only merges into the destination — it never deletes files removed upstream. Three fleet projects (Mumbl AI, PortPulse, Mlilo) had the Stop hook bug long after it was fixed in the template because `settings.json` wasn't in the overlay list. Orphan files from restructured dirs (skills, agents, rules) accumulate silently across versions.

**Rule**: Always use `rsync -a --delete` for directory overlays. Always include `.claude/settings.json` in the overlay. If a file exists in the template, it must be in the overlay — no exceptions.

## L27: macOS bash is v3.2 — no mapfile, no sort -V (2026-04-16)

macOS ships bash 3.2. `mapfile` (bash 4+) and `sort -V` (GNU coreutils) are both unavailable. Scripts using these silently produce no output rather than erroring loudly. Use `while IFS= read -r` loops instead of `mapfile`, and `sort -r` for reverse sort when version-natural sort isn't critical.

**Rule**: Write all DarkFact shell scripts targeting bash 3.2 / macOS BSD coreutils. Test with `bash -n` but also do a dry-run to catch silent failures from missing builtins.

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

## L14: Claude Code hook `type: "agent"` is invalid (2026-04-14)

Claude Code only supports two hook types: `"command"` (runs a shell command) and `"prompt"` (sends a prompt to the current model). The `"agent"` type doesn't exist — it causes a `Settings Error: prompt: Expected string, but received undefined` at session start, and **the entire settings.json is skipped** (hooks + permissions both lost).

**Fix**: Replace `type: "agent"` Stop hooks with `type: "prompt"` containing the maintainer instructions inline. Fixed in DarkFact template, Mlilo, and PortPulse (v1.2.6).

**Rule**: Always validate hook types against https://code.claude.com/docs/en/hooks before shipping.

## L22: Claude Code doesn't follow directory symlinks for skills (2026-04-16)

`.claude/skills/` was a symlink to `.agent/skills/`. Claude Code doesn't traverse directory symlinks when scanning for slash commands — `/wrap-up`, `/boot`, etc. all returned "Unknown command." Git also can't operate on files "beyond a symbolic link."

**Fix**: Replace symlinks with real directories. `init.sh` copies `.agent/skills/*.md` into `.claude/skills/` and `.gemini/skills/` via `sync_skills()`. Same pattern as `sync_agents.sh` for agents.

**Rule**: Never use directory symlinks for `.claude/skills/` or `.gemini/skills/`. Use real dirs with copied files. This is the skills equivalent of L21 (agents).

## L23: `|| true` swallows exit codes in PreToolUse hooks (2026-04-16)

PR #9 appended `|| true` to all PreToolUse hook commands as a "safety" fallback. This converts exit code 2 (block tool call) into exit code 0 (allow) — making the guards completely non-functional. The guards look correct but silently do nothing.

**Rule**: Never use `|| true` on PreToolUse hooks that use exit 2 to block. If you need a fallback for missing dependencies, handle it in the script itself, not with a shell-level catch-all.

## L24: Use bash `case` over python3 for PreToolUse path checks (2026-04-16)

Python3 startup is ~50-80ms per invocation. PreToolUse hooks fire on every tool call. For simple string-contains checks on paths, bash `case "$VAR" in *pattern*) exit 2 ;; esac` is instant and has no dependency on python3.

**Rule**: Default to bash for PreToolUse hooks. Only use python3 when parsing JSON or doing logic bash can't handle.

## L25: Store metadata conditionally in Chroma (2026-04-16)

Storing empty strings (`"blockers": ""`) in Chroma metadata on every memory bloats the database and prevents efficient `where` filtering. Chroma's `$ne` filter can only exclude non-empty values if the field doesn't exist on empty records.

**Rule**: Only add optional metadata fields when they have a value: `if blockers: metadata["blockers"] = blockers`.

## L20: Agent team dispatch is broken until .claude/agents/ is populated (2026-04-15)

DarkFact agents (`.agent/agents/*.md`) are symlinked into `.claude/agents/` and `.gemini/agents/` — but only in the DarkFact template itself. Downstream projects created via `darkfact()` + `init.sh` don't get those dirs created or populated. `sync_agents.sh` targets `.claude/agents/` but fails silently if the dir is missing. Result: `@lead`, `@dev`, `@designer` dispatch to global Claude Code built-ins, not DarkFact agents. `model_tier: flash/pro` is ignored.

**Rule**: `init.sh` must create `.claude/agents/` and `.gemini/agents/` and run `sync_agents.sh` as part of scaffolding. Don't assume the dirs exist.

## L18: DarkFact hooks are already project-scoped — global settings are clean (2026-04-14)

The Stop/SessionStart hooks in `.claude/settings.json` inside the DarkFact project dir are project-level. Claude Code merges global + project settings at runtime. Global `~/.claude/settings.json` contains only PAI hooks — no DarkFact bleed. No config change needed; the setup was already correct.

**Rule**: Before moving hooks between global and project settings, read both files and verify the actual merge behavior. Don't assume global = everywhere until confirmed.

## L19: Stop hook fires on every response stop, not just true session end (2026-04-14)

Claude Code's `Stop` hook fires whenever the model stops generating — which includes mid-conversation pauses, not only when the user closes the session. This means the maintainer wrap-up prompt fires repeatedly. Wrap-up must be run on every firing, not deferred to "real" session end.

**Rule**: Treat every Stop hook as a potential session end. Run wrap-up immediately when the hook fires — don't queue it.

## L17: Checkpoint pattern belongs in workflows/, not skills/ (2026-04-14)

Crash resilience via scratch-file checkpoints is a workflow concern, not a skill. The canonical doc lives in `workflows/checkpoint.md`. Workflows that are long, multi-step, or write files (onboard, update-template) get wired in. Read-only or atomic workflows (boot, wrap-up, report-bug) don't need it.

**Rule**: Before adding checkpoints to a workflow, check the table in `checkpoint.md` — if it's not listed as needing them, don't add them.

## L15: /boot was a workflow, not a skill — slash commands need .agent/skills/ (2026-04-14)

`/boot` was listed in CLAUDE.md section 6 as a workflow but lived only in `workflows/boot.md`. Slash commands (`/cmd`) only resolve from `.agent/skills/` (or the platform-specific symlink). The fix: create `.agent/skills/boot.md` as the canonical skill file. The `workflows/` version becomes documentation/fallback for Antigravity.

**Rule**: Any `/command` listed in CLAUDE.md must have a corresponding file in `.agent/skills/`. Workflows are for multi-step orchestration docs, not slash-command dispatch.

## L16: Claude Code SessionStart hook supports `type: "prompt"` — use it for auto-boot (2026-04-14)

Claude Code's `SessionStart` hook accepts both `type: "command"` (shell) and `type: "prompt"` (sends a prompt to the model). This means boot can be fully automated on session start without user intervention. Gemini CLI only supports `command` type — use a shell echo as a reminder instead.

**Rule**: For cross-platform auto-boot, use `prompt` hook on Claude Code, `command` echo reminder on Gemini, manual `/boot` on Codex/Antigravity.

## L13: Follow SemVer strictly — patch, minor, major (2026-04-14)

DarkFact must use `major.minor.patch` versioning:
- **Patch** (`x.x.N`): Bug fixes, typo corrections, broken wiring, version string drift. No new features.
- **Minor** (`x.N.0`): New backwards-compatible features (new soul types, new workflow steps, new agent capabilities).
- **Major** (`N.0.0`): Breaking changes (restructured `.agent/` layout, renamed core files, changed brain schema).

**v1.1.1 was skipped** — bug fixes landed in v1.2.0 without a patch tag. Don't repeat. Tag every release immediately after pushing. Use `git tag vX.Y.Z && git push origin vX.Y.Z`.
{"timestamp":"2026-04-17T23:15:00+00:00","effort_level":"comprehensive","task_description":"comprehensive audit and fix plan for darkfact template","criteria_count":80,"criteria_passed":80,"criteria_failed":0,"prd_id":"20260417-202300_darkfact-template-comprehensive-fix","implied_sentiment":7,"reflection_q1":"Running 7 parallel agents on non-overlapping scopes gave complete coverage with zero redundancy — this is the right pattern for comprehensive audits","reflection_q2":"A smarter algorithm would have run make test-init first as a canary — the smoke test failure would have immediately surfaced the function-order bug without needing deep analysis","reflection_q3":"Thinking/FirstPrinciples skill would have helped frame the provider-agnosticism mission earlier; Research skill was partially used via analyst subagents","within_budget":true}

## L30: Scratch-First Memory Tiering (2026-04-18)

Agents were polluting persistent project memory with high-churn research and logs. The fix was adding a mandatory rule to all agent souls to use `.agent/memory/scratch/` for transient work.

**Rule**: All agents must use `scratch/` for high-churn data, which is automatically purged during wrap-up.

## L31: Gemini CLI Policy-Based Autonomy (2026-04-18)

Interactive Gemini CLI sessions were stalling on file edits due to default permission guards. Setting `approval-mode yolo` is a partial fix, but defining a workspace-local `.gemini/policies/autonomy.toml` is the robust solution for long-term autonomy.

**Rule**: Always define a workspace-local autonomy policy in `.gemini/policies/autonomy.toml` to trust core engineering tools.

## L32: Gemini CLI policy priority must be <= 999 (2026-04-18)

Gemini CLI policy engine uses priority tiers. Setting a priority of 1000 or higher causes a schema validation error ("priority must be <= 999 to prevent tier overflow"). This prevents the policy file from loading, defaulting the agent to interactive mode (blocking autonomy).

**Rule**: All policy rules in `.gemini/policies/*.toml` must have a priority between 0 and 999. Use 999 for the highest priority (e.g. deny-all overrides).

## L33: Gemini CLI tool name for web search is `google_web_search` (2026-04-18)

The Gemini CLI provider uses `google_web_search` for its integrated search capability. Using `google_search` or other variants in agent `tools:` definitions causes a "Validation failed: Agent Definition: tools.N: Invalid tool name" error at load time.

**Rule**: Always map canonical `search` tool to `google_web_search` for Gemini CLI. Ensure `sync_agents.sh` maintains this mapping.

## L34: GitHub-first Template Updates (2026-04-18)

DarkFact projects update via `make update-template`. This uses the `gh` CLI to download the latest infrastructure from GitHub directly. No `darkfact-upstream` git remote is required. This replaces the old two-repo Git model which was complex and error-prone for users.

**Rule**: Use `make update-template` for all upstream synchronization. Do not manually pull from or add a `darkfact-upstream` remote.

## L35: Sub-agent delegation requires explicit autonomy policies (2026-04-18)

When delegating to sub-agents (@dev, @architect, etc.), the Gemini CLI provider treats these as tool calls. If they are not explicitly listed in `.gemini/policies/autonomy.toml`, the user is bombarded with permission prompts for every delegation.

**Rule**: All 8 canonical sub-agent tools must be in the `allow` list of the project's autonomy policy.

## L36: SubagentStart/Stop hooks for context injection (2026-04-18)

DarkFact v2.2.1 implements `SubagentStart` and `SubagentStop` hooks. These allow the template to inject project-specific context (rules, recent learnings) into sub-agent prompts and record sub-agent outcomes back to the brain.

**Rule**: Ensure `SubagentStart` and `SubagentStop` are registered in `.gemini/settings.json` and `.claude/settings.json` for all projects.

## L37: onboarding_complete stub prevents infrastructure loss (2026-04-18)

Early versions of `init.sh` did not include project-specific fields in the template `profile.json`. When agents updated these during `/onboard`, they often overwrote the entire file, deleting critical infrastructure config (memory paths, agent lists).

**Rule**: Always include stubs for `project_name`, `project_type`, `soul_type`, `tech_stack`, and `onboarding_complete` (set to `false`) in the template `profile.json`. Agents must update only these stubs.
