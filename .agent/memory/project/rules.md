
## Version Bump Rule (2026-04-12)
Every change to the workspace template MUST include a version bump in `.agent/version`.
Use semantic-ish versioning: major.minor (e.g. 3.4 → 3.5).
This ensures downstream projects detect stale factory versions at boot.

## Non-Blocking Dispatch Rule (2026-04-12)
NEVER use `--watch` or blocking polls in interactive sessions.
Pattern: dispatch (fire-and-forget) → stay responsive → quick `--result` check later.
The daemon posts to comms.db on completion — check `inbox` instead of blocking.
