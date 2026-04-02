---
name: toprig-handoff-state
description: Persistent session handoff with Bead integration for work continuity across Claude sessions
---

# TOPRIG Handoff State Management

## Overview

Enables pausing and resuming work across Claude sessions with automatic Bead synchronization.

## Commands

### /toprig:pause

**When to use:** Before ending session with work in progress.

**Behavior:**
1. Capture current state (files modified, tests status, next steps)
2. Create handoff document in `.toprig/session-state/`
3. **Auto-update Bead** (if active bead exists):
   ```bash
   bd update $BEAD_ID --append-notes "PAUSED: Session handoff. See: .toprig/session-state/[timestamp].md"
   # bd sync  # No longer needed - Dolt auto-persists
   ```
   **Note:** Bead status remains `in_progress` (standard Beads workflow). "PAUSED" marker in notes indicates temporary session pause.
4. Output handoff summary for user

**Handoff Document Format:**
```markdown
# Session Handoff: [Feature/Task Name]
**Created:** [ISO timestamp]
**Bead:** [BEAD-ID or "none"]
**Status:** paused

## Progress Summary
[What was accomplished]

## Current State
- Files modified: [list]
- Tests: [pass/fail/pending]
- Blockers: [if any]

## Next Steps
1. [Specific next action]
2. [Following action]

## Context for Resume
[Critical context that shouldn't be lost]
```

### /toprig:resume

**When to use:** Starting session to continue previous work.

**Behavior:**
1. List available handoffs: `ls .toprig/session-state/`
2. User selects handoff to resume
3. Load handoff document
4. **Auto-update Bead** (if bead linked):
   ```bash
   bd update $BEAD_ID --status in_progress --append-notes "Session resumed"
   # bd sync  # No longer needed - Dolt auto-persists
   ```
5. Present context summary and next steps

## Hybrid Bead Auto-Update

**When Bead exists:** Automatic status sync (paused/in_progress)
**When no Bead:** Handoff document only (no Bead commands)

This hybrid approach:
- ✅ Preserves continuity for tracked work
- ✅ Works for ad-hoc tasks without Beads
- ✅ Minimal token overhead (1-2 bd commands)

## Claude Main Compliance

When Claude base assistant has work in progress:
- Use `/toprig:pause` before session end
- Use `/toprig:resume` when continuing work
- Always sync Beads if active bead exists

## Token Efficiency

- Handoff documents: Max 100 lines
- Only essential context captured
- No verbose logging
