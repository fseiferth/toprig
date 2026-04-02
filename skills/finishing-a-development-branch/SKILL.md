---
name: finishing-a-development-branch
description: Use when implementation is complete, user says "land the plane", "we're done", or you need to decide how to integrate the work - guides completion including mandatory cross-check, structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Cross-check → Verify tests → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 0: Pre-Landing Cross-Check (MANDATORY)

**Check if cross-check ran recently:**

```bash
if [ -f ~/.claude/state/last-cross-check ]; then
  last_run=$(cat ~/.claude/state/last-cross-check)
  now=$(date -u +%s)
  minutes_ago=$(( (now - last_run) / 60 ))

  if [ $minutes_ago -gt 5 ]; then
    echo "⚠️  Cross-check not run recently ($minutes_ago min ago). Running now..."
  else
    echo "✅ Cross-check verified ($minutes_ago min ago)"
  fi
else
  echo "⚠️  Cross-check never run. Running now..."
fi
```

**If cross-check needs to run (>5 min ago or never):**

Invoke `/cross-check` skill immediately using Skill tool.

**Wait for cross-check results:**

| Result | Action |
|--------|--------|
| ✅ **CLEAN** | Continue to Step 1 |
| ⚠️ **MINOR** | Ask user: "Minor issues found. Fix before landing?" |
| ❌ **BLOCKER** | ABORT landing. Report issues, do NOT proceed. |

**If cross-check BLOCKS:** Stop here. User must fix issues, re-run cross-check, then restart landing.

**If cross-check PASSES:** Continue to Step 0.5.

---

### Step 0.5: Respect-the-Spec Gate (Post Cross-Check)

After cross-check completes, recommend running `respect-the-spec`:

```
*→ Cross-check passed. Recommend running respect-the-spec to validate implementation against specs. Run it?*
```

| User Response | Action |
|--------------|--------|
| **Declines** | Continue landing → Step 1 |
| **Approves** | Invoke `respect-the-spec` agent via Task tool. After it completes, ask: *"respect-the-spec complete. Continue landing the plane?"* |

**After respect-the-spec completes:**
- If user says **yes** → Continue to Step 1
- If user says **no** → Stop landing. User handles manually.

---

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 1.5.

### Step 1.5: Sensitive Term Scan

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
if [ -x "$REPO_ROOT/scripts/scan-sensitive-terms.sh" ]; then
  "$REPO_ROOT/scripts/scan-sensitive-terms.sh"
fi
```

**If scan blocks:** Stop. User must clean flagged terms before proceeding.
**If scan passes or script not found:** Continue to Step 2.

### Step 2: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4: Execute Choice

#### Option 1: Merge Locally

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass
git branch -d <feature-branch>

# Push to remote
git push
```

Then: Cleanup worktree (Step 5)

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

Then: Cleanup worktree (Step 5)

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup worktree (Step 5)

### Step 5: Cleanup Worktree

**For Options 1, 2, 4:**

Check if in worktree:
```bash
git worktree list | grep $(git branch --show-current)
```

If yes:
```bash
git worktree remove <worktree-path>
```

**For Option 3:** Keep worktree.

### Step 5.5: Update Serena Memory (Conditional)

**Only runs if the work changed infrastructure, architecture, or tooling that future sessions need to know about.** Skip for routine bug fixes, minor UI changes, or isolated features.

**Examples of when to update:**
- New scripts, hooks, or validation gates added
- Architecture patterns changed (e.g., new hash verification in gate)
- Governance workflow changes
- New dependencies or tooling introduced

**How:**
1. Identify the relevant Serena memory (use `mcp__serena__list_memories` if unsure)
2. If existing memory covers this area: update it with `mcp__serena__edit_memory`
3. If no memory exists for this area: create one with `mcp__serena__write_memory`
4. Keep entries concise (what changed, when, why — not full implementation details)

**If no memory update needed:** Skip silently. No warning needed.

### Step 5.6: Update Session Memory (claude-memory)

**Always runs** (unless the session was trivial — pure Q&A, no decisions, no state changes).

Use `mcp__claude-memory__add_conversation` to record the session using the **mandatory 6-section format** (see Serena memory `memory-persistence-format`):

```
# [Feature/Task Name] - [YYYY-MM-DD]

## Context
Why this work happened (1-2 sentences).

## Decisions
What was chosen and why. What was rejected and why.

## Key Exchanges
2-3 specific user corrections or pivots that shaped the outcome.

## Process
Numbered steps taken, in execution order.

## Outcome
Files changed, config updated, state transitions.
Include: branch name, merge target, PR URL if applicable.

## Next Session
What to pick up, open questions, blocking issues.
```

**Content rules:**
- Include decisions, rejected alternatives, user corrections (decision archaeology)
- Do NOT duplicate Serena reference data (that goes in Step 5.5)
- Do NOT include raw tool output, verbose logs, or full transcripts
- Keep concise — aim for 20-40 lines total

**Skip when:** Pure bug fix with no decisions, single-line changes, no reusable patterns.

---

### Step 6: Close Execution Bead (Conditional)

**Only runs if EXECUTION_BEAD_ID is set** (meaning this was called from executing-plans or SDD).

**If EXECUTION_BEAD_ID is not set:** Skip this step entirely. No warning needed.

**If EXECUTION_BEAD_ID is set:**

First check if bead is already closed:
```bash
# If bd show reports status: closed, skip closure
bd show $EXECUTION_BEAD_ID
```
If already closed: log "Bead already closed, skipping." and continue.

Otherwise, close based on chosen option:

| Option chosen | Bead action |
|--------------|-------------|
| 1 (Merge) | `bd close $EXECUTION_BEAD_ID --reason "Merged to {base}. {summary}."` |
| 2 (PR) | `bd close $EXECUTION_BEAD_ID --reason "PR created: {url}. {summary}."` |
| 3 (Keep) | Do NOT close bead. Work is not finished. |
| 4 (Discard) | `bd close $EXECUTION_BEAD_ID --reason "Work discarded by user."` |

**If bead closure fails:** Warn user with manual command:
```
WARNING: Could not close bead {id}. Manual cleanup:
bd close {id} --reason "summary"
```

**Do NOT close the parent epic.** Only governance-agent closes epics.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch | Serena Memory | Session Memory |
|--------|-------|------|---------------|----------------|---------------|----------------|
| 1. Merge locally | ✓ | ✓ | - | ✓ | if applicable | ✓ |
| 2. Create PR | - | ✓ | ✓ | - | if applicable | ✓ |
| 3. Keep as-is | - | - | ✓ | - | - | - |
| 4. Discard | - | - | - | ✓ (force) | - | if decisions made |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 4 structured options

**Automatic worktree cleanup**
- **Problem:** Remove worktree when might need it (Option 2, 3)
- **Fix:** Only cleanup for Options 1 and 4

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

## Integration

**Called by:**
- **subagent-driven-development** (Step 7) - After all tasks complete
- **executing-plans** (Step 5) - After all batches complete

**Bead lifecycle:**
- Calling skill (executing-plans/SDD) sets EXECUTION_BEAD_ID in Step 0
- This skill closes it in Step 6 (conditional on EXECUTION_BEAD_ID being set)
- If called standalone (no calling skill): Step 6 is a no-op

**Pairs with:**
- **using-git-worktrees** - Cleans up worktree created by that skill
