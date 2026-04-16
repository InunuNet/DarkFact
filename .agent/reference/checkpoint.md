---
description: Checkpoint pattern — crash-resilient workflow steps using scratch state files
---

# Checkpoint Pattern

Long-running workflows die mid-execution when agents hit token limits, API rate limits,
or UI crashes. Without checkpoints, the next session starts from zero. This pattern
writes state after each step so a crashed workflow resumes from the last completed step.

## Core Principle

> **Write before proceeding.** Each step records its output to a scratch file
> before moving to the next step. On resume, read the scratch file to skip completed steps.

---

## Implementation

### Scratch file location

All checkpoint files live in `.agent/memory/scratch/`. They are cleared on wrap-up.

```
.agent/memory/scratch/
  checkpoint_<workflow>_<step>.json   # step output
  checkpoint_<workflow>_state.json    # overall workflow state
```

### Step template

Every checkpointed step follows this pattern:

```bash
SCRATCH=".agent/memory/scratch"
WORKFLOW="onboard"  # change per workflow

# 1. Check if step already completed
if [ -f "$SCRATCH/checkpoint_${WORKFLOW}_step3.json" ]; then
  echo "↩️  Step 3 already complete — skipping"
  cat "$SCRATCH/checkpoint_${WORKFLOW}_step3.json"
else
  # 2. Do the work
  # ... actual step logic here ...

  # 3. Write checkpoint
  echo '{"step": 3, "status": "complete", "output": "summary of what happened"}' \
    > "$SCRATCH/checkpoint_${WORKFLOW}_step3.json"
  echo "✅ Step 3 complete"
fi
```

### State file

Track overall workflow progress in a single state file:

```json
{
  "workflow": "onboard",
  "started": "2026-04-14T18:00:00Z",
  "last_step": 5,
  "status": "in_progress",
  "steps_complete": [1, 2, 3, 4, 5],
  "steps_remaining": [6, 7, 8, 9]
}
```

Write state after each step:

```python
import json, datetime
state_file = ".agent/memory/scratch/checkpoint_onboard_state.json"
try:
    with open(state_file) as f:
        state = json.load(f)
except FileNotFoundError:
    state = {"workflow": "onboard", "started": datetime.datetime.utcnow().isoformat(), "steps_complete": []}

state["last_step"] = 5
state["steps_complete"].append(5)
state["status"] = "in_progress"

with open(state_file, "w") as f:
    json.dump(state, f, indent=2)
```

---

## Resume Pattern

When a workflow is invoked, check for an existing state file first:

```bash
SCRATCH=".agent/memory/scratch"
STATE="$SCRATCH/checkpoint_onboard_state.json"

if [ -f "$STATE" ]; then
  LAST=$(python3 -c "import json; print(json.load(open('$STATE'))['last_step'])")
  echo "⚠️  Incomplete onboard session found — last completed step: $LAST"
  echo "Resume from step $((LAST + 1))? [yes/no]"
else
  echo "Starting fresh onboard session"
fi
```

---

## Cleanup

On successful workflow completion, clear checkpoints:

```bash
rm -f .agent/memory/scratch/checkpoint_onboard_*.json
echo "🧹 Checkpoints cleared"
```

The brain wrap-up hook also clears scratch on session end:
```bash
python3 execution/brain.py wrap-up --summary "..." --tags "..."
# wrap-up does NOT auto-clear scratch — do it explicitly on workflow success
```

---

## Which Workflows Need Checkpoints

| Workflow | Needs checkpoints? | Reason |
|----------|--------------------|--------|
| `onboard.md` | ✅ Yes | 9 steps, writes multiple files, high token cost |
| `boot.md` | ❌ No | Read-only, fast, safe to re-run |
| `wrap-up` | ❌ No | Single command, atomic |
| `report-bug` | ❌ No | Single gh CLI call |
| `update-template` | ✅ Yes | Git operations — partial apply is dangerous |

---

## Agent Instructions

When running a checkpointed workflow:

1. Check for existing state file before starting
2. If found — report last step to user, ask to resume or restart
3. On restart — delete state file, begin from step 1
4. On resume — skip completed steps, start from `last_step + 1`
5. After each step — write checkpoint before proceeding
6. On completion — delete all checkpoint files for this workflow
