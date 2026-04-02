
---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Stub Detection Framework

### Stub Indicators (Must Check Before Claiming Complete)

**Code Patterns:**
```
// TODO, # TODO, // FIXME, # FIXME
return null, return {}, return []
console.log-only handlers
pass (Python)
throw new Error("Not implemented")
NotImplementedError
Functions defined but never called
Empty catch blocks
Hardcoded test values in production code
```

### Three-Level Verification

| Level | Check | Evidence Required |
|-------|-------|-------------------|
| **1. Exists** | File/function present | `ls`, `grep` output |
| **2. Substantive** | Real implementation (>15 lines, no stubs) | Code review showing logic |
| **3. Wired** | Connected and used | Call site evidence, test coverage |

### Verification Sequence
1. **Exists** - Does the file/function exist?
2. **Substantive** - Is there real logic (not stubs)?
3. **Wired** - Is it actually called/used?

All three levels MUST pass before claiming "complete."

### Claude Main Compliance
When Claude base assistant implements features:
- Run stub detection before claiming done
- Verify all three levels
- Provide evidence for each level in completion claim

## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## Goal-Backward Verification

### The Outcome Question
Before claiming complete, ask: "Does this achieve the GOAL, not just finish the TASK?"

**Task completion ≠ Goal achievement**

| Task | Goal | Verification |
|------|------|--------------|
| "Write login endpoint" | "Users can authenticate" | Test actual login flow |
| "Add validation" | "Invalid data rejected gracefully" | Test edge cases |
| "Implement caching" | "Response time improved" | Measure before/after |

### Verification Sequence

1. **Re-read original requirement** (PRD, ticket, user request)
2. **Identify the goal** (what outcome was desired?)
3. **Test the outcome** (not just task completion)
4. **Document evidence** (actual results, not assumptions)

### Anti-Patterns

❌ "I implemented the function" → Did you test it works?
❌ "Tests pass" → Do they test the actual requirement?
❌ "Code looks correct" → Did you run it?

### Claude Main Compliance

When Claude base assistant completes work:
- Ask "Does this achieve the goal?"
- Test outcomes, not just tasks
- Provide goal-achievement evidence

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
