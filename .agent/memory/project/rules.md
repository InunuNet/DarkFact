# Project-Specific Rules

_These override core rules when they conflict._

## Scope Boundary — HARD RULE

**Never read, search, edit, or run commands inside any directory outside `/Users/vetus/ai/DarkFact/` unless Brad explicitly says to.**

- No `find /Users/vetus/ai/` sweeps
- No reading sibling project files for "comparison"
- No patching downstream projects unless instructed
- The only exception: `overlay_all.sh` / `overlay_template.sh` when Brad explicitly asks for a fleet update

Violation = cross-project data loss risk. No exceptions without explicit instruction.

## Template-Only Work

All work happens in the DarkFact template. Downstream projects receive changes via overlay on Brad's command — never by direct edit from this workspace.
