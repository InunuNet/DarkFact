---
task: Re-analyze backlog and plan next work
slug: 20260414-175300_backlog-analysis-and-plan
effort: extended
phase: execute
progress: 0/18
mode: interactive
started: 2026-04-14T17:53:00Z
updated: 2026-04-14T17:54:00Z
---

## Context

Full re-analysis of the DarkFact backlog following v1.2.6 (onboarding bug fixes). Goal is a sequenced, tiered plan — not a list dump. User (Codi as lead) wants prioritized work with agent assignments and minimal interruptions.

Current state: v1.2.6 partial (onboarding bugs fixed, onboard.md committed). Remaining open items span bugs, hardening, features, cross-platform, polish, and investigation.

Key inconsistency discovered during session: `soul_type` appears in onboard.md heuristics table but has no stub in `profile.json` — agents reading Step 3 will reference a field that doesn't exist in the file they're told to update.

### Risks
- Cross-platform items cannot be verified without Linux/Windows hardware — keep deferred
- Checkpoint pattern is architectural — implementing without design risks wrong abstraction
- Fleet mode is a research area — no concrete requirements yet, keep as investigate

## Criteria

- [ ] ISC-1: All backlog items categorized (bug / hardening / feature / deferred / investigate)
- [ ] ISC-2: Each open item has priority tier (v1.2.6 / v1.3.0 / v1.4.0 / deferred)
- [ ] ISC-3: Each open item has effort estimate (S / M / L)
- [ ] ISC-4: Each open item has agent assignment (dev / docs / architect / analyst)
- [ ] ISC-5: v1.2.6 scope defined with specific items listed
- [ ] ISC-6: v1.3.0 scope defined with specific items listed
- [ ] ISC-7: v1.4.0 scope defined with specific items listed
- [ ] ISC-8: Deferred items explicitly listed with reasoning
- [ ] ISC-9: soul_type inconsistency flagged — in onboard.md but missing from profile.json stub
- [ ] ISC-10: status:archive scoped to specific two-file change (profile.json + boot.md)
- [ ] ISC-11: Step 6 fix approach identified — what commands to add and where
- [ ] ISC-12: Checkpoint pattern flagged as architect-first (design before dev)
- [ ] ISC-13: Sequence rationale documented — why this order
- [ ] ISC-14: Backlog.md updated with version groupings and new ordering
- [ ] ISC-15: Goals.md updated — v1.2.6 fix noted, new active goals set
- [ ] ISC-16: Plan presented to user in structured format
- [ ] ISC-17: soul_type addition scoped — profile.json stub AND onboard.md Step 5 python command both updated
- [ ] ISC-18: Step 6 fix scoped after reading current rules dir structure (no blind assumption)

## Decisions

## Verification
