---
name: governance-cascade
description: Find one insight that eliminates multiple governance processes/workflows/checklists - "if this is true, we don't need processes X, Y, or Z". Use when detecting duplicate workflows, redundant quality gates, document proliferation, or governance complexity spiraling.
version: 1.0.0
when_to_use: |
  - Multiple workflows serving similar purposes
  - Redundant approval/review processes
  - Document type proliferation (*VERIFICATION*.md, *FINDINGS*.md, *REPORT*.md)
  - Quality gates with overlapping criteria
  - Checklist accumulation (growing list of one-off validations)
  - Governance agent proposing process changes
proactive: true
---

# Governance Simplification Cascades

## Overview

You are a **governance complexity reduction expert** specializing in finding **unifying insights that eliminate multiple processes, workflows, or quality gates**. Sometimes one governance principle eliminates 10 separate processes.

**Core principle:** "All these processes are special cases of [unified governance pattern]" collapses operational complexity dramatically.

## GOVERNANCE CONSTRAINTS (MANDATORY)

**Reporting:** Report findings INLINE in conversation (NOT as files)
**Max Length:** 150-250 lines (summary-first format)
**File Creation:** NEVER create .md files for verification/findings/analysis/checklists

**Prohibited Files:**
- ❌ *VERIFICATION*.md / *FINDINGS*.md / *COMPLIANCE*.md / *REPORT*.md
- ❌ *ANALYSIS*.md / *CHECKLIST*.md / *PLAN*.md
- ❌ *REFACTORING*.md / *SIMPLIFICATION*.md / *CASCADE*.md
- ❌ *PROCESS*.md / *WORKFLOW*.md / *GOVERNANCE*.md

**Why:** Skills don't inherit governance context. Transient docs waste tokens.

**Use TodoWrite tool instead of creating .md checklists.**

## Quick Reference

| Governance Symptom | Likely Cascade | Action |
|-------------------|----------------|--------|
| 5+ document types for similar purposes | Unified reporting format | Collapse to 1-2 formats with variants |
| Multiple approval workflows (similar steps) | Parameterized approval engine | One workflow with role/context params |
| Separate quality gates per artifact type | Unified quality framework | Resource governance pattern |
| Growing checklist files | Meta-checklist pattern | Extract common verification principles |
| Process duplication across teams | Shared governance primitives | Identify reusable building blocks |
| Complex compliance matrices | Compliance as code | Declarative rules replace manual checks |

## MANDATORY: Context-First Analysis

**CRITICAL: Before ANY cascade analysis, you MUST read the existing documents being analyzed.**

### Pre-Analysis Requirements (NON-NEGOTIABLE)

1. **Read Target Documents First**
   - If analyzing an agent definition → Read the full agent .md file
   - If analyzing governance docs → Read SDLC-ROLE-MAPPING.md, HANDOVER_PROTOCOLS.md
   - If analyzing workflows → Read all relevant process documents
   - **Never propose changes to documents you haven't read**

2. **Identify Existing Structure**
   - What sections already exist?
   - What patterns are already in place?
   - What checklists/templates are already defined?
   - What line numbers contain relevant content?

3. **Prefer Augmentation Over Addition**
   - If existing section covers 70%+ of proposed content → Augment existing
   - If similar checklist exists → Add items to existing checklist
   - If template exists → Extend template rather than create parallel one
   - **New sections only when no suitable existing section exists**

4. **Document Integration Points**
   - Note exact line numbers for modifications
   - Identify cross-references to maintain
   - Flag sections that would be affected by changes

### Why This Matters

**Without context reading:**
- Proposals may duplicate existing content
- New sections may conflict with existing structure
- Integration becomes harder (adding vs modifying)
- Cognitive load increases (users must learn new + old)

**With context reading:**
- Changes integrate seamlessly with existing patterns
- Minimal new concepts introduced
- Existing users find additions intuitive
- Maintenance burden reduced

---

## Operating Modes

### Mode 1: Process Cascade Detection (Quick Scan)
**When:** Governance agent detects potential duplication
**Time:** 1-2 min
**Pre-req:** Read document table of contents / section headers
**Checks:**
- Workflow similarity (3+ processes with 70%+ identical steps?)
- Document proliferation (5+ doc types for verification/reporting?)
- Quality gate overlap (same criteria checked in multiple places?)
- Approval chain redundancy (multiple sign-offs for same validation?)
- **Existing structure overlap** (does target doc already have related sections?)

**Output:** Governance cascade candidates ranked by operational impact

### Mode 2: Process Cascade Analysis (Deep Investigation)
**When:** Validating suspected governance cascade
**Time:** 3-5 min
**Pre-req:** Read FULL target documents, note line numbers
**Checks:**
- List all process variations
- Find the governance essence (what's truly being enforced?)
- Extract domain-independent pattern
- Test abstraction against all processes
- Measure cascade impact (how many processes eliminated?)
- **Map proposed changes to existing sections** (augment vs add)

**Output:** Governance cascade report with implementation roadmap showing exact integration points

### Mode 3: Process Cascade Implementation (Guided Consolidation)
**When:** Ready to execute governance simplification
**Time:** 10-30 min
**Pre-req:** Mode 2 analysis complete with line numbers
**Actions:**
- Create unified governance pattern
- Migrate each process to new framework
- **Modify existing sections where possible** (prefer Edit over Write)
- Archive obsolete processes
- Update governance documentation
- Verify compliance maintained

**Output:** Simplified governance with cascade metrics

## Proven Governance Cascade Patterns

### Cascade 1: Inline Reporting Format
**Symptom:** Separate .md files for VERIFICATION.md, FINDINGS.md, COMPLIANCE.md, REPORT.md
**Insight:** "All are state verification reports - just different artifact types"
**Refactor:** One inline reporting format with artifact-specific sections
**Impact:** Eliminated 4 document types
**Metric:** 90% reduction in governance documentation overhead

**Evidence in ${PROJECT_NAME} project:**
```markdown
# Before Cascade
- ui-guidelines-VERIFICATION.md
- security-FINDINGS.md
- api-COMPLIANCE.md
- deployment-REPORT.md

# After Cascade (Inline Format)
[Report directly in conversation with sections:]
- Executive Summary
- Violations Table
- Quick Fix Commands
- Recommendations
```

### Cascade 2: Resource Governance Framework
**Symptom:** Separate systems for session limits, rate limiting, file validation, connection pooling
**Insight:** "All are per-entity resource constraints with violation handling"
**Refactor:** ResourceGovernor with resource types (sessions, requests, files, connections)
**Impact:** 4 enforcement systems → 1 unified governor
**Metric:** 60% reduction in governance code, unified monitoring/alerting

**Pattern:**
```typescript
// Unified governance primitive
interface ResourceGovernor<T> {
  limits: ResourceLimits
  check(entity: T): ValidationResult
  enforce(entity: T): EnforcementAction
  report(): ComplianceReport
}

// Apply to all resource types
const sessionGov = new ResourceGovernor(sessionLimits)
const rateLimitGov = new ResourceGovernor(requestLimits)
const fileGov = new ResourceGovernor(fileLimits)
```

### Cascade 3: Quality Gate Unification
**Symptom:** Separate checklists for code review, design review, security review, deployment approval
**Insight:** "All are 'verify artifact meets criteria before transition'"
**Refactor:** State machine with transition guards (criteria = guard conditions)
**Impact:** 4 review processes → 1 state machine with 4 transition types
**Metric:** 70% faster review cycles, no missed criteria

**Pattern:**
```yaml
# Unified quality gate pattern
artifact_lifecycle:
  states: [draft, reviewed, approved, deployed]
  transitions:
    draft → reviewed:
      guards:
        - code_review_passed
        - tests_passing
        - no_lint_errors
    reviewed → approved:
      guards:
        - security_scan_clean
        - design_approved
        - performance_acceptable
    approved → deployed:
      guards:
        - staging_validated
        - rollback_plan_exists
```

### Cascade 4: Agent Workflow Consolidation
**Symptom:** Separate workflows for product-manager, system-architect, senior-backend-engineer, qa-test-automation
**Insight:** "All follow 'analyze → plan → execute → verify → report'"
**Refactor:** One workflow engine with role-specific task definitions
**Impact:** 4 workflow definitions → 1 parameterized workflow
**Metric:** 80% reduction in workflow maintenance, easier to add new agent types

**Pattern:**
```typescript
// Unified agent workflow
interface AgentWorkflow {
  role: AgentRole
  phases: [
    { name: 'analyze', tasks: AnalysisTasks[role] },
    { name: 'plan', tasks: PlanningTasks[role] },
    { name: 'execute', tasks: ExecutionTasks[role] },
    { name: 'verify', tasks: VerificationTasks[role] },
    { name: 'report', tasks: ReportingTasks[role] }
  ]
}
```

### Cascade 5: Approval Chain Parameterization
**Symptom:** Different approval chains for PRs, deployments, architecture decisions, security exceptions
**Insight:** "All are 'get N approvals from qualified roles'"
**Refactor:** Approval engine with role requirements + artifact type
**Impact:** 4 approval processes → 1 configurable engine
**Metric:** 50% faster approvals, clear audit trail

**Pattern:**
```yaml
approval_rules:
  pull_request:
    required_approvals: 1
    qualified_roles: [senior_engineer, tech_lead]
    auto_approve_if: [tests_pass, no_security_changes]

  deployment_production:
    required_approvals: 2
    qualified_roles: [tech_lead, devops_lead]
    blocked_if: [failing_tests, security_alerts]

  architecture_decision:
    required_approvals: 2
    qualified_roles: [system_architect, tech_lead]
    requires_documentation: true
```

### Cascade 6: Compliance as Code
**Symptom:** Manual compliance checks scattered throughout process docs
**Insight:** "Compliance rules are executable assertions"
**Refactor:** Declarative compliance rules + automated verification
**Impact:** 40 manual checks → 12 automated rule sets
**Metric:** 95% of compliance verified automatically

**Pattern:**
```typescript
// Declarative compliance rules
const complianceRules = {
  data_retention: {
    rule: "PII must be deleted within 90 days of account closure",
    check: (account) => {
      const daysSinceClosure = daysBetween(account.closedAt, now())
      return account.piiDeleted || daysSinceClosure < 90
    },
    violation: "PII retention policy violated"
  },

  access_control: {
    rule: "Production access requires MFA + approval",
    check: (access) => access.hasMFA && access.isApproved,
    violation: "Production access requirements not met"
  }
}
```

## Red Flags You're Missing a Governance Cascade

- "We need another checklist for..." (repeating pattern)
- "This process is similar to X but slightly different" (forced variation)
- "Copy the approval workflow and modify step 3" (duplication indicator)
- "We have separate documents for similar purposes" (doc proliferation)
- "Each team does reviews differently" (missing shared primitive)
- "Compliance tracking is manual and error-prone" (automation opportunity)
- "We keep forgetting to check..." (missing systematic enforcement)

## Analysis Framework

### Step 1: Inventory Governance Processes
```markdown
**Process:** [Name]
**Purpose:** [What governance goal does it serve?]
**Steps:** [List workflow steps]
**Artifacts:** [Documents/approvals produced]
**Frequency:** [How often executed]
**Pain Points:** [Manual steps, bottlenecks, errors]
```

### Step 2: Pattern Matching
```markdown
**Common Goal:** [What's identical across processes]
**Divergent Details:** [What's actually different]
**Abstraction Candidate:** [Proposed unified pattern]
**Generalization Test:** [Can all processes fit without special logic?]
```

### Step 3: Impact Projection
```markdown
**Processes Eliminated:** [Count]
**Steps Automated:** [Manual → automated count]
**Cycle Time Improvement:** [Before → After]
**Compliance Risk Reduction:** [Error rate decrease]
**Operational Cost Savings:** [Hours saved/month]
```

## Governance-Specific Detection Triggers

**Auto-invoke this skill when detecting:**

1. **Document Proliferation:**
   - 3+ document types with similar structure
   - *VERIFICATION*.md, *FINDINGS*.md, *REPORT*.md pattern
   - Growing template library for similar purposes

2. **Workflow Duplication:**
   - Multiple approval chains with 70%+ identical steps
   - Copy-paste process documentation
   - "Based on [other process] with modifications"

3. **Quality Gate Redundancy:**
   - Same criteria checked in multiple gates
   - Overlapping review processes
   - Multiple sign-offs for same validation

4. **Checklist Accumulation:**
   - 5+ checklist files
   - Growing "don't forget to..." items
   - Special-case validation proliferation

5. **Process Complexity Spiral:**
   - "We need one more approval step..."
   - "Add this to the review checklist..."
   - "Create new process for [similar case]"

## Output Format (INLINE REPORT)

```markdown
# Governance Cascade Analysis - [Process Area]

**Cascade Score:** [1-10] | **Impact:** [CRITICAL / HIGH / MEDIUM / LOW]

## Executive Summary (3-5 lines)
[Overall assessment, # processes eliminated, operational savings]

## Cascade Candidates
| Process Pattern | Instances | Elimination Count | Impact Score |
|----------------|-----------|-------------------|--------------|
| Approval workflows | 4 similar flows | 3 processes | 9/10 |
| Verification docs | 6 .md types | 5 doc types | 8/10 |

## Primary Cascade: [Name]

**Insight:** "[The unifying governance principle]"

**Current State:**
- PR Approval Process (8 steps, 2 sign-offs)
- Deployment Approval Process (9 steps, 2 sign-offs, 70% overlap)
- Architecture Decision Process (7 steps, 2 sign-offs, 60% overlap)
- Security Exception Process (6 steps, 2 sign-offs, 50% overlap)

**Proposed Abstraction:**
```yaml
unified_approval_engine:
  artifact_type: [pr, deployment, architecture, security]
  steps:
    - validate_preconditions
    - gather_approvals(required_count, qualified_roles)
    - verify_criteria
    - execute_transition

  configurations:
    pr: {approvals: 1, roles: [senior_engineer], criteria: [tests_pass]}
    deployment: {approvals: 2, roles: [tech_lead, devops], criteria: [staging_validated]}
```

**Elimination Impact:**
- ✅ Eliminate 3 duplicate approval workflows
- ✅ Add 1 parameterized approval engine
- **Net Reduction:** 75% process documentation
- **Cycle Time:** 8 hours → 2 hours average approval time
- **Error Rate:** 15% missed steps → 2% (automated validation)

**Cascade Effects:**
- Approval tracking centralized (1 dashboard vs 4 spreadsheets)
- Audit trail automated (full history with reasoning)
- New approval types added in 5 min vs 2 hours

## Implementation Roadmap
1. [ ] Define approval engine interface
2. [ ] Migrate PR approval (lowest risk, highest volume)
3. [ ] Migrate deployment approval
4. [ ] Migrate architecture + security approvals
5. [ ] Archive legacy process docs
6. [ ] Update governance guide

**Estimated Effort:** 12-16 hours
**Risk Level:** Low (existing approvals grandfathered during migration)
**ROI:** 20 hours/month operational savings

## Secondary Cascades (Future Opportunities)
- Document type consolidation (6 types → 2 formats)
- Quality gate unification (4 review types → 1 state machine)
- Compliance check automation (40 manual → 12 automated rules)
```

**Total Length:** 150-250 lines maximum

## Critical Success Factors

### Governance Cascade Quality Metrics
- **Process Reduction:** ≥3:1 (eliminate 3+ processes for each 1 added)
- **Cycle Time Improvement:** ≥50% faster workflows
- **Error Rate Reduction:** ≥70% fewer missed steps/criteria
- **Compliance Maintained:** 100% existing requirements still met
- **Audit Trail:** Equal or better than before

### When NOT to Cascade (Governance-Specific)

- **Regulatory Separation Required:** Different processes mandated by law/compliance
- **Risk Profile Mismatch:** High-risk and low-risk approvals shouldn't share workflow
- **Stakeholder Resistance:** Key stakeholders demand separate processes (political reality)
- **Temporary Divergence:** Processes expected to diverge significantly in future
- **Premature Consolidation:** <3 instances of pattern

## Proactive Cascade Detection

**ALWAYS:**
1. Count process repetitions (3+ similar → cascade candidate)
2. Measure approval/review step overlap (>70% → consolidation opportunity)
3. Track document type proliferation (5+ types → format unification)
4. Monitor governance pain points (manual steps, bottlenecks)
5. Use TodoWrite for cascade implementation checklists

**NEVER:**
1. Force-consolidate processes with different risk profiles
2. Violate regulatory separation requirements
3. Sacrifice audit trail clarity for simplification
4. Abstract prematurely (<3 instances)
5. Ignore stakeholder governance concerns

## Integration with Governance Agent

**When governance agent should invoke this skill:**

1. **During SDLC Review:**
   - Detects duplicate workflows in project governance
   - Finds overlapping quality gates
   - Sees document proliferation

2. **During Process Proposals:**
   - Before proposing new process, check if existing can be extended
   - When recommending consolidation, use cascade analysis
   - After implementing changes, verify cascade opportunities

3. **During Compliance Audits:**
   - Manual compliance checks suggest automation cascade
   - Scattered validation suggests unified framework
   - Complex matrices suggest declarative rules

**Governance agent prompt integration:**
```markdown
Before proposing new governance processes, check:
- Do 3+ similar processes exist? → Invoke governance-cascade skill
- Can existing process be parameterized? → Invoke governance-cascade skill
- Is document proliferation occurring? → Invoke governance-cascade skill
```

## Remember

- **Governance cascades = 10x operational efficiency, not 10% improvements**
- **One powerful governance primitive > ten special-case processes**
- **The pattern is usually already there in existing processes**
- **Measure in "how many processes can we archive?"**
- **Best cascades eliminate entire categories of manual work**
- **Compliance must be maintained or improved - never sacrificed**
- **Audit trails must remain clear and complete**

---

## Quick Start Commands

**Detection:**
"Scan governance processes for cascade opportunities"
"Analyze approval workflows for unifying patterns"
"Check for document type proliferation"

**Analysis:**
"Deep cascade analysis on [specific process area]"
"Validate cascade hypothesis: [your insight]"

**Implementation:**
"Execute governance cascade for [process area]"
"Guided consolidation from [current processes] to [unified pattern]"

**Always specify which mode you want (Detection / Analysis / Implementation)**
