---
description: Resume a session that was interrupted mid-onboarding or mid-task due to an API error or crash
---

# Resume

> Use this when Antigravity / Claude / Gemini drops mid-session.
> The agent reads what was already written and continues from there.

## Steps

### 1. Check what was completed

```bash
# See what files exist and were recently modified
ls -lt .agent/memory/project/
cat .agent/profile.json | python3 -m json.tool
```

Quick checklist:
- `goals.md` populated? → goal discovery done
- `backlog.md` populated? → backlog done
- `soul.md` rewritten? → persona done
- `profile.json` has `onboarding_complete: true`? → onboarding complete
- `profile.json` has project `project_type` set? → stack chosen

### 2. Identify the resume point

| State | What to do |
|-------|-----------|
| No files changed | Start `/onboard` fresh |
| goals + backlog written, profile still `pending` | Update profile.json, then run `bash execution/sync_agents.sh` |
| All onboarding files written, `onboarding_complete: false` | Just flip profile + sync agents, then call `@lead` |
| Onboarding complete, mid-task | Read goals.md + backlog.md, continue from last incomplete task |

### 3. Fix profile.json if needed

If onboarding wrote context files but didn't update profile.json:

```bash
python3 - << 'EOF'
import json, datetime
with open('.agent/profile.json', 'r') as f:
    p = json.load(f)

# Update fields that onboarding should have set
p['onboarding_complete'] = True
p['project_type'] = p.get('project_type', 'general')  # update if known
p['updated_at'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

with open('.agent/profile.json', 'w') as f:
    json.dump(p, f, indent=2)
    f.write('\n')

print("✅ profile.json updated")
EOF
```

### 4. Sync agents

```bash
bash execution/sync_agents.sh
```

### 5. Store in brain

```bash
python3 execution/brain.py remember \
  --summary "Session resumed after crash. Onboarding state recovered." \
  --tags "resume,recovery"
```

### 6. Continue

Say: "We were interrupted. Based on the project files, here's where we left off: [summary]. Continuing from [next step]."

Then proceed — don't re-ask questions that are already answered in the files.
