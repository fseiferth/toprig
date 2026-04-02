---
name: prompt-engineering
description: Use when handling complex multi-step tasks requiring structured prompts. Applies CO-STAR, TIDD-EC, or hybrid patterns based on task type. Triggers on 'phase', 'implementation plan', 'comprehensive task', 'multi-agent coordination', or when task has 3+ steps/success criteria.
---

# Prompt Engineering Skill

## Purpose

Transform complex task requests into well-structured prompts using proven frameworks:
- **CO-STAR** for contextual/creative tasks
- **TIDD-EC** for technical/precise tasks
- **Hybrid** for complex multi-step tasks

## When This Skill Triggers

**Auto-invoke when (2+ indicators present):**
- User mentions 'phase', 'implementation plan', 'comprehensive'
- Task spans multiple agents or domains
- Task has research + execution components
- Multiple success criteria mentioned (3+)
- Task requires coordination between roles
- User explicitly requests structured prompt

**Do NOT invoke for:**
- Simple single-step tasks
- Quick questions or lookups
- File reads or searches
- Tasks with clear, simple instructions
- Bug fixes with obvious solutions

## Framework Selection Decision Tree

```
START
  │
  ├─► Is the task creative/content-focused?
  │     (PRDs, docs, communications, user-facing content)
  │     → YES: Use CO-STAR
  │     → NO: Continue
  │
  ├─► Is the task technical with clear constraints?
  │     (Code, analysis, debugging, specific implementation)
  │     → YES: Use TIDD-EC
  │     → NO: Continue
  │
  └─► Is the task complex, multi-step, or cross-agent?
        (Phase execution, multi-agent coordination, research+implementation)
        → YES: Use HYBRID
        → NO: Use simplest applicable framework
```

## Framework Reference

### CO-STAR Framework (Creative/Contextual Tasks)

**Origin:** Winner of Singapore's GPT-4 Prompt Engineering Competition

**Structure:**
- **C**ontext: Background information and situation
- **O**bjective: What you want to achieve
- **S**tyle: Writing style or approach
- **T**one: Emotional quality of response
- **A**udience: Who will consume the output
- **R**esponse: Format of the output

**Best for:** PRDs, documentation, communications, content generation, user-facing outputs

**Template:**
```markdown
# [Task Name]

## Context
**Background:** [Situation and relevant history]
**Current State:** [What exists now]

## Objective
**Goal:** [What to achieve]
**Success Criteria:** [How to measure success]

## Style
**Approach:** [formal/informal/technical/conversational]

## Tone
**Voice:** [professional/friendly/authoritative/empathetic]

## Audience
**Reader:** [Who will consume this]
**Their Needs:** [What they care about]

## Response
**Format:** [markdown/json/code/prose]
**Length:** [short/medium/long]
**Structure:** [sections/bullets/paragraphs]
```

---

### TIDD-EC Framework (Technical/Precise Tasks)

**Origin:** Precision-focused framework for technical tasks

**Structure:**
- **T**ask Type: Category of work
- **I**nstructions: Step-by-step guidance
- **D**o: Required behaviors
- **D**on't: Prohibited behaviors
- **E**xamples: Concrete demonstrations
- **C**ontent: Input material to process

**Best for:** Code implementation, analysis, debugging, technical reviews, specific deliverables

**Template:**
```markdown
# [Task Name]

## Task Type
**Category:** [implementation/analysis/research/review/debugging]
**Complexity:** [simple/moderate/complex]

## Instructions
1. [First step with specific action]
2. [Second step with specific action]
3. [Third step with specific action]

## Do
- [Required behavior 1]
- [Required behavior 2]
- [Required behavior 3]

## Don't
- [Prohibited behavior 1]
- [Prohibited behavior 2]
- [Prohibited behavior 3]

## Examples
**Good:**
```
[Example of correct approach]
```

**Bad:**
```
[Example of incorrect approach]
```

## Content
[Input material to process]
```

---

### Hybrid Framework (Complex Multi-Step Tasks)

**Origin:** Combines CO-STAR context with TIDD-EC precision

**Structure:**
1. CO-STAR sections for context and framing
2. TIDD-EC sections for execution precision
3. Additional sections: Pre-flight checklist, Quality gates, Landing protocol

**Best for:** Phase execution, multi-agent coordination, research + implementation, cross-domain tasks

**Template:**
```markdown
# [Phase/Task Name]

## Executive Context (CO-STAR)
**Background:** [Situation and history]
**Current State:** [What exists]
**Objective:** [Goal to achieve]
**Audience:** [Who consumes output]

## Mission
[Clear statement of what must be accomplished]

## Instructions (TIDD-EC)
**Task Type:** [Category and complexity]

### Steps
1. [Step 1 with specific deliverable]
2. [Step 2 with specific deliverable]
3. [Step 3 with specific deliverable]

### Do
- [Required behavior 1]
- [Required behavior 2]

### Don't
- [Prohibited behavior 1]
- [Prohibited behavior 2]

## Success Criteria
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
- [ ] [Testable criterion 3]

## Pre-Flight Checklist
- [ ] [Prerequisite 1 verified]
- [ ] [Prerequisite 2 verified]

## Quality Gates
- [ ] [Gate 1: What must pass before proceeding]
- [ ] [Gate 2: What must pass before completion]

## Landing the Plane
[How to complete, validate, and hand off]
```

---

## Output Format

When this skill is invoked, produce:

1. **Framework Selection** (1-2 sentences explaining choice)
2. **Structured Prompt** (using selected template)
3. **Validation Checklist** (verify completeness)

### Example Output

```
**Framework Selected:** Hybrid (complex multi-step task with cross-agent coordination)

**Structured Prompt:**

# Phase 17: User Notification Implementation

## Executive Context
**Background:** ${PROJECT_NAME} app needs push notifications for item updates
**Current State:** No notification system exists
**Objective:** Implement end-to-end notification system
**Audience:** Backend + Frontend engineers, QA

## Mission
Create a complete push notification system allowing users to receive item updates.

## Instructions
**Task Type:** Implementation (multi-agent, complex)

### Steps
1. Define notification data model and API contracts
2. Implement backend notification service with FCM integration
3. Create frontend notification components and permission flow
4. Test end-to-end with real device notifications

### Do
- Use Firebase Cloud Messaging
- Follow existing authentication patterns
- Create comprehensive tests for each component

### Don't
- Don't store notification content unencrypted
- Don't send notifications without explicit user consent

## Success Criteria
- [ ] Users can enable/disable notifications in settings
- [ ] Notifications delivered within 5 seconds of trigger
- [ ] All notification types documented with examples
- [ ] E2E tests pass on iOS and Android

## Pre-Flight Checklist
- [ ] Firebase project configured with FCM
- [ ] Push certificates generated for iOS
- [ ] Backend environment ready with Redis

## Landing the Plane
Close bead with evidence of tests passing. Run `bd sync && git push`.

---

**Validation Checklist:**
- [x] Context complete (background, current state, objective)
- [x] Objective specific and measurable
- [x] Success criteria testable
- [x] Constraints clear (do/don't)
- [x] Pre-flight checklist included
- [x] Landing protocol defined
```

---

## Quality Checklist

Before finalizing any structured prompt, verify:

- [ ] Context is complete (no missing background)
- [ ] Objective is specific and measurable
- [ ] Success criteria are testable (not vague)
- [ ] Constraints are clear (do/don't)
- [ ] Examples provided (if complex task)
- [ ] Output format specified
- [ ] Pre-flight checklist included (if multi-step)
- [ ] Landing protocol defined (if handoff required)
- [ ] No ambiguous requirements
- [ ] **Governance validation passed** (see below)

---

## Governance Validation (MANDATORY)

**Before finalizing any prompt, scan for governance violations:**

### Epic Closure Check

**Search for:** `bd close` followed by epic reference (not bead)

**Patterns to catch and fix:**
```bash
# ❌ WRONG - bypasses child validation
bd close ${PROJECT_NAME}-xxx --reason "..."
bd close $EPIC_ID --reason "..."
"Close epic when approved"

# ✅ CORRECT - validates all children first
bd epic close-eligible --dry-run
bd epic close-eligible
```

**If prompt contains direct epic closure:**
1. Replace `bd close <epic-id>` with `bd epic close-eligible`
2. Add `--dry-run` preview step before actual closure
3. Ensure only governance agent (via Task tool) executes epic closure

### Authority Check

**These authorities cannot be delegated via prompt:**

| Authority | Owner | Prompt Should Say |
|-----------|-------|-------------------|
| Epic closure | governance-agent | "Invoke governance agent to close epic" |
| Feature ID assignment | product-manager | "PM assigns Feature ID" |

**Rationale:** Prompts execute verbatim. Embedding wrong commands causes governance violations.

---

## Framework Comparison Matrix

| Aspect | CO-STAR | TIDD-EC | Hybrid |
|--------|---------|---------|--------|
| **Best for** | Creative, content | Technical, precise | Complex, multi-step |
| **Structure** | Contextual framing | Execution precision | Both |
| **Constraints** | Light | Heavy | Variable |
| **Examples** | Optional | Required | Required |
| **Enforcement** | Low | High | High |
| **Typical length** | 100-300 words | 200-500 words | 500-1500 words |
| **Use cases** | PRDs, docs, comms | Code, analysis, debug | Phases, coordination |

---

## Integration Notes

**This skill integrates with:**
- `writing-plans` - Use prompt-engineering first, then writing-plans for implementation details
- `executing-plans` - Structured prompts feed directly into plan execution
- `brainstorming` - Use brainstorming first for idea refinement, then structure with this skill

**Workflow:**
```
Vague idea → brainstorming → prompt-engineering → writing-plans → executing-plans
```

---

## Maintenance

**Skill Location:** `~/.claude/skills/prompt-engineering/`
**Version:** 1.0.0
**Last Updated:** 2026-02-02
**Owner:** ${PROJECT_NAME} Team
