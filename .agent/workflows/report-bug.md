---
description: Report a bug or improvement in the DarkFact template to the upstream maintainer
---

# Report Bug

> Reports a bug or improvement in the DarkFact template itself (not your project).
> Uses `gh` CLI to create a GitHub Issue directly. Falls back to a formatted
> report you can paste manually.

## Steps

### 1. Describe the bug

Ask the user:
- "What went wrong?" (concise description)
- "Which file or workflow is affected?"
- "Steps to reproduce?"
- "What did you expect vs what happened?"

### 2. Capture context automatically

```bash
# Gather template version + platform info
TEMPLATE_VERSION=$(cat .agent/version 2>/dev/null || echo "unknown")
PROJECT_TYPE=$(python3 -c "import json; p=json.load(open('.agent/profile.json')); print(p.get('project_type','unknown'))" 2>/dev/null || echo "unknown")
PLATFORM=$(uname -s 2>/dev/null || echo "unknown")
echo "Template: $TEMPLATE_VERSION | Project type: $PROJECT_TYPE | Platform: $PLATFORM"
```

### 3. Submit via gh CLI (preferred)

```bash
# Check if gh is available and authenticated
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    gh issue create \
        --repo InunuNet/DarkFact \
        --title "Bug: [TITLE]" \
        --body "## Description
[DESCRIPTION]

## Affected file/workflow
[FILE_OR_WORKFLOW]

## Steps to reproduce
1. [STEP 1]
2. [STEP 2]

## Expected vs actual
- Expected: [EXPECTED]
- Actual: [ACTUAL]

## Context
- Template version: [TEMPLATE_VERSION]
- Project type: [PROJECT_TYPE]
- Platform: [PLATFORM]" \
        --label "bug"
    echo "✅ Issue created at https://github.com/InunuNet/DarkFact/issues"
else
    echo "⚠️  gh CLI not available or not authenticated."
    echo "   Install: brew install gh && gh auth login"
    echo ""
    echo "   📋 Paste this at: https://github.com/InunuNet/DarkFact/issues/new"
fi
```

### 4. Fallback: save report locally

If `gh` is unavailable, write the report to scratch so the user can paste it:

```bash
cat > .agent/memory/scratch/bug_report.md << EOF
# DarkFact Bug Report

**Title**: [TITLE]
**Template version**: $(cat .agent/version 2>/dev/null || echo "unknown")
**Platform**: $(uname -s 2>/dev/null || echo "unknown")
**Date**: $(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date)

## Description
[DESCRIPTION]

## Steps to reproduce
1. [STEP]

## Expected vs actual
- Expected: [EXPECTED]
- Actual: [ACTUAL]

## Submit at
https://github.com/InunuNet/DarkFact/issues/new
EOF
echo "📄 Report saved to .agent/memory/scratch/bug_report.md"
```

### 5. Check for template updates

Offer to check if a newer template version is available:

```bash
# Fetch remote without merging
git fetch darkfact-upstream --quiet 2>/dev/null && \
    echo "✅ Upstream fetched. Run 'make update-template' to see changes." || \
    echo "⚠️  Could not reach upstream (no network or remote not set)."
```
