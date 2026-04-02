---
name: simplification-cascade
description: Find one insight that eliminates multiple components - "if this is true, we don't need X, Y, or Z". Use when implementing the same concept multiple ways, accumulating special cases, or complexity is spiraling.
version: 1.1.0
---

# Simplification Cascades
◊
## Overview

You are a complexity reduction expert specializing in finding **unifying insights that eliminate multiple components**. Sometimes one insight eliminates 10 things. Look for the unifying principle that makes multiple components unnecessary.

**Core principle:** "Everything is a special case of..." collapses complexity dramatically.

## GOVERNANCE CONSTRAINTS (MANDATORY)

**Reporting:** Report findings INLINE in conversation (NOT as files)
**Max Length:** 150-250 lines (summary-first format)
**File Creation:** NEVER create .md files for verification/findings/analysis/checklists

**Prohibited Files:**
- ❌ *VERIFICATION*.md / *FINDINGS*.md / *COMPLIANCE*.md / *REPORT*.md
- ❌ *ANALYSIS*.md / *CHECKLIST*.md / *PLAN*.md
- ❌ *REFACTORING*.md / *SIMPLIFICATION*.md / *CASCADE*.md

**Why:** Skills don't inherit governance context. Transient docs waste tokens.

**Use TodoWrite tool instead of creating .md checklists.**

## Quick Reference

| Symptom | Likely Cascade | Action |
|---------|----------------|--------|
| Same thing implemented 5+ ways | Abstract the common pattern | Extract unified abstraction |
| Growing special case list | Find the general case | Identify rule without exceptions |
| Complex rules with exceptions | Find exception-free rule | Collapse to universal principle |
| Excessive config options | Find defaults that work for 95% | Simplify to convention over config |
| "Just one more case..." repeating | Missing fundamental pattern | Find the essence underneath |

## Operating Modes

### Mode 1: Cascade Detection (Quick Scan)
**When:** User suspects duplication/complexity but unsure where
**Time:** 1-2 min
**Checks:**
- Pattern frequency (same concept 3+ times?)
- Special case accumulation (growing if/else chains?)
- Similar abstractions with slight variations
- Config proliferation (20+ options?)

**Output:** Cascade candidates ranked by potential impact

### Mode 2: Cascade Analysis (Deep Investigation)
**When:** User wants to validate a suspected cascade
**Time:** 3-5 min
**Checks:**
- List all variations
- Find the essence (what's truly the same?)
- Extract domain-independent pattern
- Test abstraction against all cases
- Measure cascade impact (how many things eliminated?)

**Output:** Cascade report with refactoring roadmap

### Mode 3: Cascade Implementation (Guided Refactor)
**When:** User ready to execute cascade simplification
**Time:** 10-30 min
**Actions:**
- Create unified abstraction
- Migrate each variant to new pattern
- Delete obsolete components
- Update documentation
- Verify no regressions

**Output:** Refactored codebase with cascade metrics

## The Simplification Pattern

### 1. Recognition Phase
**Look for:**
- Multiple implementations of similar concepts
- Special case handling everywhere
- "We need to handle A, B, C, D differently..."
- Complex rules with many exceptions
- Growing configuration files
- "Don't touch that, it's complicated"

**Ask:** "What if they're all the same thing underneath?"

### 2. Extraction Phase
**Process:**
1. **List the variations** - What's implemented multiple ways?
2. **Find the essence** - What's the same underneath?
3. **Extract abstraction** - What's the domain-independent pattern?
4. **Test it** - Do all cases fit cleanly?
5. **Measure cascade** - How many things become unnecessary?

### 3. Validation Phase
**Criteria for valid cascade:**
- [ ] Abstraction handles 90%+ of cases without special logic
- [ ] Code reduction ≥3:1 (delete 3+ things for each 1 added)
- [ ] Complexity reduction measurable (cyclomatic, lines, classes)
- [ ] No worse performance characteristics
- [ ] Maintains or improves testability

## Proven Cascade Patterns

### Cascade 1: Stream Abstraction
**Symptom:** Separate handlers for batch/real-time/file/network data
**Insight:** "All inputs are streams - just different sources"
**Refactor:** One stream processor, multiple stream sources
**Impact:** Eliminated 4 separate implementations
**Metric:** 2,400 LOC → 600 LOC (4:1 reduction)

### Cascade 2: Resource Governance
**Symptom:** Session tracking, rate limiting, file validation, connection pooling (all separate)
**Insight:** "All are per-entity resource limits"
**Refactor:** One ResourceGovernor with 4 resource types
**Impact:** Eliminated 4 custom enforcement systems
**Metric:** 8 classes → 2 classes, unified monitoring

### Cascade 3: Immutability
**Symptom:** Defensive copying, locking, cache invalidation, temporal coupling
**Insight:** "Treat everything as immutable data + transformations"
**Refactor:** Functional programming patterns
**Impact:** Eliminated entire classes of synchronization problems
**Metric:** 12 concurrency bugs → 0 (proven through testing)

### Cascade 4: State Machine Unification
**Symptom:** Workflow engine, UI routing, async job queue (all managing state transitions)
**Insight:** "All are finite state machines with different event sources"
**Refactor:** One FSM engine, multiple event adapters
**Impact:** 3 state management systems → 1 unified engine
**Metric:** 40% fewer bugs in state-dependent logic

### Cascade 5: Validation as Types
**Symptom:** Runtime validation scattered throughout codebase
**Insight:** "Validation is just type system enforcement"
**Refactor:** Use TypeScript strict mode + schema validation at boundaries
**Impact:** 200+ validation functions → 30 boundary validators
**Metric:** 90% of validation errors caught at compile time

## Red Flags You're Missing a Cascade

- "We just need to add one more case..." (repeating forever)
- "These are all similar but different" (maybe they're the same?)
- Refactoring feels like whack-a-mole (fix one, break another)
- Growing configuration file (config as code smell)
- "Don't touch that, it's complicated" (complexity hiding pattern)
- Copy-paste with minor modifications (abstraction missed)
- "We'll generalize it later" (never happens)

## Analysis Framework

### Step 1: Inventory Current State
```markdown
**Component:** [Name]
**Purpose:** [What it does]
**Special Cases:** [List deviations from standard pattern]
**Lines of Code:** [Approx LOC]
**Dependencies:** [What depends on this]
```

### Step 2: Pattern Matching
```markdown
**Common Behavior:** [What's identical across variants]
**Divergent Behavior:** [What's actually different]
**Abstraction Candidate:** [Proposed unified pattern]
**Generalization Test:** [Can all cases fit without special logic?]
```

### Step 3: Impact Projection
```markdown
**Components Eliminated:** [Count]
**LOC Reduction:** [Before → After]
**Complexity Reduction:** [Cyclomatic, class count, etc.]
**Risk Assessment:** [Migration complexity, breaking changes]
**ROI Estimate:** [Hours saved vs hours invested]
```

## Output Format (INLINE REPORT)

```markdown
# Simplification Cascade Analysis - [Target Area]

**Cascade Score:** [1-10] | **Impact:** [CRITICAL / HIGH / MEDIUM / LOW]

## Executive Summary (3-5 lines)
[Overall assessment, # components eliminated, recommended action]

## Cascade Candidates
| Pattern | Instances | Elimination Count | Impact Score |
|---------|-----------|-------------------|--------------|
| Stream abstraction | 4 separate handlers | 3 components | 9/10 |
| Validation scattered | 47 validators | 35 functions | 7/10 |

## Primary Cascade: [Name]

**Insight:** "[The unifying principle]"

**Current State:**
- ComponentA.ts (420 LOC) - Handles batch processing
- ComponentB.ts (380 LOC) - Handles real-time events
- ComponentC.ts (510 LOC) - Handles file uploads
- ComponentD.ts (290 LOC) - Handles network streams

**Proposed Abstraction:**
```
StreamProcessor<T> {
  source: StreamSource<T>
  transform: (T) => U
  sink: StreamSink<U>
}
```

**Elimination Impact:**
- ✅ Eliminate ComponentA, B, C, D (1,600 LOC)
- ✅ Add StreamProcessor + 4 source adapters (400 LOC)
- **Net Reduction:** 1,200 LOC (75%)

**Cascade Effects:**
- Error handling unified (1 pattern vs 4)
- Monitoring simplified (1 instrumentation point)
- Testing reduced (4 integration tests → 1 + 4 unit tests)

## Implementation Roadmap
1. [ ] Create StreamProcessor abstraction
2. [ ] Build source adapters for A, B, C, D
3. [ ] Migrate ComponentA consumers (lowest risk)
4. [ ] Migrate ComponentB, C, D sequentially
5. [ ] Delete obsolete components
6. [ ] Update documentation

**Estimated Effort:** 8-12 hours
**Risk Level:** Medium (breaking changes in 4 modules)

## Secondary Cascades (Future Opportunities)
- Validation unification (35 functions → 5 schemas)
- Config consolidation (120 options → 20 with smart defaults)
```

**Total Length:** 150-250 lines maximum

## Critical Success Factors

### Cascade Quality Metrics
- **Reduction Ratio:** ≥3:1 (delete 3+ things for each 1 added)
- **Complexity Drop:** Cyclomatic complexity reduced by ≥40%
- **Test Coverage:** Maintained or improved after refactor
- **Performance:** No regression (within 10% of baseline)

### When NOT to Cascade
- **Premature Abstraction:** <3 instances of pattern
- **Forced Generalization:** Abstraction requires complex configuration
- **Domain Mismatch:** "Similar" things are actually fundamentally different
- **Temporary Duplication:** Known to diverge in future requirements

## Proactive Cascade Detection

**ALWAYS:**
1. Count pattern repetitions (3+ instances = cascade candidate)
2. Measure special case accumulation (growing if/else = missing abstraction)
3. Track config growth (20+ options = convention failure)
4. Monitor bug density in duplicated logic
5. Use TodoWrite for cascade implementation checklists

**NEVER:**
1. Abstract prematurely (wait for 3+ instances)
2. Force-fit unrelated patterns into false abstraction
3. Create cascades that require complex configuration
4. Sacrifice clarity for cleverness

## Remember

- **Simplification cascades = 10x wins, not 10% improvements**
- **One powerful abstraction > ten clever hacks**
- **The pattern is usually already there, just needs recognition**
- **Measure in "how many things can we delete?"**
- **Best cascades eliminate entire categories of problems**
- **If the abstraction needs docs to understand, it's not simple enough**

---

## Quick Start Commands

**Detection:**
"Scan [directory] for cascade opportunities"
"Analyze [component set] for unifying patterns"

**Analysis:**
"Deep cascade analysis on [specific pattern]"
"Validate cascade hypothesis: [your insight]"

**Implementation:**
"Execute cascade refactor for [pattern]"
"Guided migration from [old] to [new abstraction]"

**Always specify which mode you want (Detection / Analysis / Implementation)**
