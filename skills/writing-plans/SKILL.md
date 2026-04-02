---
name: writing-plans
description: Use when design is complete and you need detailed implementation tasks for engineers with zero codebase context - creates comprehensive implementation plans with exact file paths, complete code examples, and verification steps assuming engineer has minimal domain knowledge
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Atomic Task Sizing

### The 15-60 Minute Rule
Each **task** should be completable in 15-60 minutes.

**Reconciliation with existing guidance:** The `writing-plans` skill already has "Bite-Sized Task Granularity" (2-5 minutes per **step**). These are different levels:
- **Tasks** (15-60 min) are composed of multiple **steps** (2-5 min each)
- Example: Task "Implement login endpoint" (30 min) contains steps: "Write route handler" (3 min), "Add validation" (4 min), "Write tests" (8 min), etc.

This new guidance applies to TASK sizing, not step sizing.

**Signs task is too large:**
- More than 5 files to modify
- More than 100 lines of new code
- Multiple unrelated concerns
- "And also..." in description
- Requires context from multiple domains

### Split Strategy
1. **Identify independent units** - Can this be committed alone?
2. **Vertical over horizontal** - Complete feature slices, not layers
3. **Test boundaries** - Each task should have clear test criteria

### Task Description Template
```
## Task: [Verb] [Specific Thing]
**Estimate:** [15-60 min]
**Files:** [List specific files, max 5]
**Deliverable:** [What exists when done]
**Test:** [How to verify completion]
```

### Claude Main Compliance
When Claude base assistant creates implementation tasks:
- Apply 15-60 minute rule
- Include all template fields
- Split tasks exceeding guidelines

## Plan Document Header

**Every plan MUST start with this header (fill EXECUTION after user chooses in Execution Handoff):**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use [EXECUTION_SKILL] to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits

## Entry Point Propagation (governance-affecting plans)

If ANY task in the plan introduces or modifies a governance rule:

1. **Add a propagation task** after the implementation task:
   ```
   ### Task N+1: Propagate [rule] to all applicable entry points
   **Files:** [list each file that needs the rule]
   **Checklist:**
   - [ ] Agent definitions (Type 2)
   - [ ] SDD dispatch template (if applies to subagents)
   - [ ] Claude main direct work constraints (if universal)
   - [ ] Governance wrapper template (if Type 3)
   - [ ] writing-skills template (if future skills need it)
   - [ ] Exemptions documented with rationale
   ```

2. **Add a symmetry verification task** as the FINAL task in the plan:
   ```
   ### Task FINAL: Verify enforcement symmetry for [rule]
   **Test:** For each non-exempt entry point, grep for rule presence
   **Pass criteria:** Rule found in all applicable entry points or exemption documented
   ```

If the plan does NOT affect governance rules, skip this section.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - Fresh subagent per task, code review between tasks, stays in this session

**2. Parallel Session** - Batch execution with human review checkpoints, opens new session in worktree

**Which approach?"**

**After user chooses, stamp the plan header** — replace `[EXECUTION_SKILL]` with the chosen skill:

**If Subagent-Driven chosen:**
- Stamp header: `superpowers:subagent-driven-development`
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Stay in this session

**If Parallel Session chosen:**
- Stamp header: `superpowers:executing-plans`
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses superpowers:executing-plans
