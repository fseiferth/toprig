# Hybrid Framework Template

**Origin:** Combines CO-STAR context with TIDD-EC precision

**Best for:** Phase execution, multi-agent coordination, research + implementation, cross-domain tasks

## Structure

1. CO-STAR sections for context and framing
2. TIDD-EC sections for execution precision
3. Additional sections: Pre-flight checklist, Quality gates, Landing protocol

## Template

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

## Usage

Use this framework when the task is:
- Complex and multi-step
- Involves multiple agents or roles
- Requires both context and precision
- Has multiple success criteria
- Needs coordination and handoff

## Example

**Task:** "Implement user authentication with OAuth and session management"

```markdown
# Phase 8: User Authentication Implementation

## Executive Context (CO-STAR)
**Background:** ${PROJECT_NAME} app currently has no authentication. Users requested account features for saving items across devices.
**Current State:** Anonymous usage only. No user model, no session management.
**Objective:** Implement OAuth (Google/Apple) with JWT session management.
**Audience:** Backend Engineer, Frontend Engineer, QA Engineer

## Mission
Enable users to sign in with Google or Apple, persist sessions securely, and sync their item collections across devices.

## Instructions (TIDD-EC)
**Task Type:** Full-stack implementation (multi-agent, complex)

### Steps
1. **Backend (BE Engineer):** Create User model, OAuth endpoints, JWT middleware
2. **Frontend (FE Engineer):** Create auth screens, token storage, auth context
3. **Integration (Both):** Connect flows, test end-to-end
4. **QA (QA Engineer):** Test all auth scenarios, edge cases

### Do
- Use industry-standard OAuth2 PKCE flow
- Store tokens securely (Keychain/SecureStore)
- Implement refresh token rotation
- Add rate limiting to auth endpoints

### Don't
- Don't store passwords (OAuth only)
- Don't log tokens or sensitive data
- Don't allow token replay attacks
- Don't skip CSRF protection

## Success Criteria
- [ ] Users can sign in with Google
- [ ] Users can sign in with Apple
- [ ] Sessions persist across app restarts
- [ ] Tokens refresh automatically before expiry
- [ ] Sign out clears all session data
- [ ] All auth endpoints have rate limiting
- [ ] E2E tests pass on iOS and Android

## Pre-Flight Checklist
- [ ] Google OAuth credentials configured
- [ ] Apple Sign-In capability enabled
- [ ] Backend environment has Redis for sessions
- [ ] Test accounts created for both providers

## Quality Gates
- [ ] **Gate 1 (Backend):** OAuth flow returns valid tokens
- [ ] **Gate 2 (Frontend):** UI flows complete without errors
- [ ] **Gate 3 (Integration):** Full flow works on real device
- [ ] **Gate 4 (QA):** All test scenarios pass

## Landing the Plane
1. BE closes bead when API tests pass
2. FE closes bead when UI tests pass
3. QA closes bead when E2E tests pass
4. Run `bd sync && git push`
5. Create PR with test evidence
```

## When to Choose Hybrid

| Indicator | Framework |
|-----------|-----------|
| Single agent, creative output | CO-STAR |
| Single agent, technical precision | TIDD-EC |
| Multi-agent coordination | **Hybrid** |
| Research + implementation | **Hybrid** |
| Phase execution | **Hybrid** |
| Complex success criteria (3+) | **Hybrid** |
