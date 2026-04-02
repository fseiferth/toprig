---
name: executing-plans
description: Use when partner provides a complete implementation plan to execute in controlled batches with review checkpoints - loads plan, reviews critically, executes tasks in batches, reports for review between batches
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 0: Execution Bead (Pre-flight)

Track this plan execution in Beads for visibility and recovery.

1. **Pre-flight validation** (if script exists):
   ```bash
   # Run if available; skip with warning if not
   ./scripts/validate-work-readiness.sh
   ```
   If script missing: log "Note: validate-work-readiness.sh not found, skipping pre-flight." Continue.
   If script fails (exit 1): warn user of the issue but continue (advisory).

2. **Create execution bead:**

   Determine bead title from plan context:
   - With Feature ID: `"[FEAT-XXX] Execute: {plan-filename}"`
   - Without Feature ID: `"Execute: {plan-filename}"`

   If EXECUTION_BEAD_ID is already set and bead is still `in_progress`:
   close it first: `bd close $EXECUTION_BEAD_ID --reason "Superseded by new plan execution"`

   Create bead:
   ```bash
   bd create "$BEAD_TITLE" --parent <epic-id> --assignee claude-main -p 2
   ```

   **If bead creation fails or times out:** Display actionable warning:
   ```
   WARNING: Could not create execution bead ({actual error}).
   Work will proceed without bead tracking.
   To create manually: bd create "{title}" --parent <epic> --assignee claude-main
   ```
   Set EXECUTION_BEAD_ID to empty. Continue to Step 1. Do NOT block.

3. **Mark in progress and create Claude Tasks:**
   ```bash
   bd update $EXECUTION_BEAD_ID --status in_progress
   ```
   Create Claude Tasks (TaskCreate) mirroring the plan's task list for session visibility.

**Ownership rule:** Claude-main owns this bead. Subagents dispatched by this skill do NOT create beads.

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Batch
**Default: First 3 tasks**

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified (REAL systems, not simulation - see ~/.claude/CLAUDE.md "Universal Testing Principle")
4. Mark as completed

### Step 3: Report
When batch complete:
- Show what was implemented
- Show verification output
- Say: "Ready for feedback."

### Step 4: Continue
Based on feedback:
- Apply changes if needed
- Execute next batch
- Repeat until complete

### Step 5: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

### Step 6: Close Execution Bead

After Step 5 (finishing-a-development-branch) completes:

**If EXECUTION_BEAD_ID is not set:** Skip. No warning needed.

**If EXECUTION_BEAD_ID is set:** The finishing-a-development-branch skill handles bead closure (see its Step 6). If for any reason it did not close the bead, close it here:
```bash
bd close $EXECUTION_BEAD_ID --reason "Plan execution complete. <brief summary>."
```

**Do NOT close the parent epic.** Only governance-agent closes epics.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
- Create execution bead before starting (Step 0)
- Close execution bead after finishing (Step 6)
