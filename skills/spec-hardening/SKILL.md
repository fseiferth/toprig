---
name: spec-hardening
description: Use when PRD, design spec, architecture doc, or implementation plan needs iterative multi-agent review to eliminate ambiguity, risk, and implementation drift. Triggers on "harden spec", "harden PRD", "harden design", "harden architecture", "harden plan", "spec hardening", "review and harden", or when user wants iterative multi-pass review of any SDLC document before implementation.
---

# Agentic Spec Hardening Skill

## Purpose
Systematically harden any SDLC document using focused multi-agent review passes to eliminate ambiguity, risk, and implementation drift.

Supported document types:
- Product Requirements (PRD)
- Design Specifications
- Architecture Documents
- Implementation Plans
- Governance / Process Improvement Plans

---

## Core Protocol (applies to every pass)

Each agent must:

1. Critique the document using its domain checklist AND the universal checklist
2. Identify gaps, risks, contradictions, and vague language
3. Rewrite the document tighter and more explicit
4. Promote assumptions into concrete requirements
5. Carry all fixes forward into the next version

Rules:
- Always output the improved document
- Never summarize
- Remove ambiguity
- Make requirements testable
- Calibrate depth to document size: under 5 pages enumerate specific gaps; over 5 pages enumerate categories with 2-3 examples each

---

## Step 1: Document Classification

Classify the input document as one of:

PRD | Design | Architecture | Implementation | Governance

Use dominant intent if mixed.

---

## Step 1.5: Execution Model

Each agent pass MUST be dispatched as a **separate subprocess** via the `Task` tool. Claude main orchestrates but NEVER role-plays the agent.

### Agent Type Mapping

| Skill Agent Name | `subagent_type` parameter |
|-----------------|---------------------------|
| Governance | `governance` |
| PM | `product-manager` |
| Architect | `system-architect` |
| Security | `security-analyst` |
| Frontend | `senior-frontend-engineer` |
| Backend | `senior-backend-engineer` |
| QA | `qa-test-automation-engineer` |
| Research | `research` |
| DevOps | `devops-deployment-engineer` |
| Design | `ux-ui-designer` |

### Prohibited `subagent_type` Values

Never use these agent types for hardening passes:
- `general-purpose` — never use for any hardening pass
- `Explore` — read-only agent, cannot produce hardened output
- `Plan` — read-only agent, cannot produce hardened output

If a pass requires a domain not listed in the mapping table above, **ask the user** which agent type to use. Never fall back to `general-purpose`, `Explore`, or `Plan`.

### Dispatch Rules

1. Each pass = **fresh agent** (no accumulated context bias between passes)
2. Pass the **current document version** + that agent's **checklist from Step 3** as the prompt
3. Collect the hardened output **before** proceeding to the quality gate (Step 4)
4. Never run passes in parallel — each pass builds on the previous output

---

## Step 2: Agent Routing

### PRD
PM → Architect → Frontend → Backend → Security → QA → Research → DevOps

### Design
Design → PM → Frontend → Backend → QA → Accessibility → Security

### Architecture
Architect → PM → Security → Frontend → Backend → QA → Research → DevOps

### Implementation Plan
PM → Architect → Frontend → Backend → Security → QA → Research → DevOps

### Governance / Process
Governance → PM → Security → Frontend → Backend → QA → Research → DevOps

---

## Step 3: Agent Checklists

Each agent must explicitly evaluate the universal checks AND their domain checklist.
Every item is a verifiable question with pass/fail criteria — bare topic labels are not acceptable.

### All Agents (Universal Checks)

Every agent in the pass sequence must evaluate these in addition to their domain checklist:

**Assumptions:**
- Assumption surface: What platform/runtime/environment behaviors does this spec assume?
- Failure mode: What happens if those assumptions are wrong?
- Dependencies: Are all assumptions documented as explicit dependencies, not embedded in prose? For governance specs: are cross-document dependency chains mapped?

**Verification & Validation:**
- V&V completeness: Does every deliverable/phase have verification steps?
- V&V concreteness: Are tests specified with inputs, expected outputs, and numeric pass/fail? ("Run tests" or "validate it works" = FAIL. For governance specs: specify exact command/script, passing result, and who executes.)
- V&V independence: Can someone with ZERO implementation knowledge execute the validation and judge pass/fail using ONLY this spec? (The stranger test)
- V&V integrity: Does the spec prohibit the implementer from constructing test prompts that contain hints, known issues, or expected findings?
- V&V enforcement: Is validation a named gate (who runs it, what blocks on it) before "done"? Not optional, not "if time allows."

**Tooling:**
- Tooling specified: Does each work phase name the skills/scripts/agents it uses?
- Tooling exists: Do all referenced skills/scripts actually exist? (Search all standard locations: project scripts, global skills, agent definitions, docs.)
- Tooling gaps: Are there existing project skills relevant to this work not referenced?

### PM Agent
- Goal specificity: Does every stated goal include a measurable outcome (numeric target or binary condition)? Goals without measurable outcomes = FAIL.
- Goal traceability: Can every feature/requirement be traced back to exactly one stated goal?
- Metric completeness: Does each success metric specify baseline, target, measurement method, and timeframe? ("User satisfaction improves" = FAIL)
- Scope boundaries: Are explicit "out of scope" items listed? Is there a cut-line between MVP and post-MVP?
- Scope-effort alignment: Is the scope sized to stated resource constraints (team, timeline, budget)?
- Dependency risk: Are external dependencies identified with fallback plans if unavailable?
- Priority justification: Does every prioritized item link priority to user impact AND business value?
- User value: Are target users defined with specific behaviors and pain points? Is each feature's value hypothesis testable?

### Design Agent
- Complete user flows: Are all user journeys mapped end-to-end including entry, happy path, error, and exit?
- States and edge cases: Are all component states enumerated (empty, loading, error, partial, full)?
- Accessibility and usability: Are WCAG compliance levels stated? Are keyboard navigation and screen reader behaviors specified?
- Responsiveness: Are breakpoints defined with layout behavior at each?
- Handoff readiness: Are all design tokens, spacing values, and interaction specifications implementation-ready?

### Architect Agent
- System boundaries: Are all service/module boundaries explicitly defined with justification (data ownership, scaling unit, deployment unit)? Are cross-boundary interactions enumerated with protocol, auth, and failure handling?
- Service ownership: Does each component have a named owner? Are operational responsibilities (monitoring, on-call) assigned?
- APIs and contracts: Are all API contracts defined with request/response schemas, status codes, error formats, and auth? Is versioning strategy specified? Are backward compatibility rules stated?
- Data flows: Are all data paths between components mapped? Are PII flows identified with encryption and access controls?
- Scalability: Are target load numbers specified? Are scaling strategies defined per component? Are bottlenecks identified with mitigation?
- Failure isolation: Is each component's blast radius defined? Are circuit breaker/retry patterns specified? Is graceful degradation documented?
- Security architecture: Are trust boundaries drawn between components? Is auth architecture specified (not just "use JWT")? Are secrets management patterns defined?
- Rollback boundaries: Are changes structured so intermediate states are valid?
- Dependency ordering: If step B depends on step A, can A be reverted without breaking B's artifacts?

### Security Agent
- Authentication: Does the spec define auth mechanism (JWT, OAuth2, session), token lifecycle (issuance, expiration, refresh, revocation), and credential storage? Are service-to-service auth patterns specified?
- Authorization: Is the access control model defined (RBAC, ABAC, RLS)? Are permission boundaries explicit per endpoint/action? Is horizontal privilege escalation addressed?
- Data protection: Are sensitive data types classified with protection levels? Are encryption-at-rest and in-transit standards stated (AES-256, TLS 1.2+)? Are retention and deletion policies defined?
- Trust boundaries: Are all trust boundaries diagrammed or listed? Is input validated at every boundary crossing with specific rules? Are external integrations treated as untrusted?
- Input security: Does the spec address injection prevention (SQL, XSS, CSRF, SSRF)? Are parameterized queries mandated? Are file upload restrictions defined?
- Abuse prevention: Are rate limits defined per endpoint/user? Are brute-force protections specified? Are resource-intensive operations bounded?
- Compliance: Which frameworks apply (GDPR, PCI-DSS, SOC2)? Are relevant controls addressed?
- Secure defaults: Do all configurable security settings default to restrictive? Do error responses avoid leaking internal state? Is secret management approach specified (no hardcoded credentials)?

### Frontend Agent
- API usability: Are API contracts clear enough to build UI without guessing? Are loading/error states defined per endpoint?
- Performance impact: Are bundle size, render time, and network request budgets stated?
- Error handling: Are error states defined for every user action? Are retry and fallback behaviors specified?
- State management: Is client-side state architecture defined? Are cache invalidation rules stated?
- UX feasibility: Can every designed interaction be implemented with the specified technology stack?

### Backend Agent
- Data models: Are all entities defined with field types, constraints, and relationships? Are migration scripts specified?
- Transactions: Are transaction boundaries defined? Is rollback behavior specified for partial failures?
- Consistency: Is the consistency model stated per data domain (strong, eventual)? Is the source of truth identified per entity?
- Idempotency: Are all mutating operations idempotent or explicitly marked as non-idempotent with justification?
- Scaling logic: Are database query patterns analyzed for N+1, missing indexes, and lock contention?

### QA Agent
- Testability: Can every requirement be verified by a test with defined input, action, and expected output? ("Should work correctly" without specifics = FAIL)
- Edge cases: Are boundary values, null/empty inputs, concurrent access, timeout, and max-length scenarios enumerated? ("Handle edge cases" without specifics = FAIL)
- Acceptance criteria: Are criteria in Given/When/Then or input-output format with numeric thresholds? Are negative criteria ("must NOT") included?
- Automation readiness: Can tests be automated without human judgment? Are API contracts stable? Are UI selectors specified?
- Failure modes: Are system failures (crash, timeout, network) and business failures (invalid state, rejected) distinguished with expected behavior for each?
- Error contracts: Are error responses specified with status codes, body format, and triggering conditions?
- Test data: Does the spec define required test data, creation method, cleanup procedure, and test credentials?
- Environment: Does the spec include reproducible environment setup steps and health check verification?
- Regression scope: Does the spec identify existing features affected by changes that require regression testing?
- Performance criteria: Are non-functional requirements (response time, throughput, memory) specified with numeric thresholds? (N/A for pure UI specs)

### Research Agent
- Assumptions validation: Are all stated assumptions backed by evidence (data, prior art, user research)?
- Evidence backing: Are claims about user behavior, market, or technology supported by citations or experiments?
- User behavior realism: Are usage patterns based on observed data or validated hypotheses (not wishful thinking)?
- Load expectations: Are traffic, data volume, and growth rate projections based on evidence?

### DevOps Agent
- Deployment strategy: Is the deployment method specified (blue-green, canary, rolling)? Is zero-downtime requirement stated?
- Observability: Are logging standards, key metrics, and alerting thresholds defined per component?
- Rollback granularity: Can each phase/batch be rolled back independently?
- Rollback verification: Does each rollback step have a verification command?
- Partial failure: If phase 3 of 5 fails, what's the state? Is it recoverable?
- Rollback cost: Is rollback a 1-command revert or a multi-step manual process?
- Scaling infra: Are auto-scaling triggers and resource limits defined?
- Cost risks: Are cost projections stated for infrastructure at target scale?

### Governance Agent
- Ownership clarity: Is each deliverable/phase assigned to a specific named role? Is the accountability chain clear (who is responsible if late, wrong, or incomplete)?
- Decision rights: Are approval gates assigned to named roles? Is user approval required for scope changes? Are escalation paths defined?
- Enforcement mechanisms: Does the spec distinguish blocking (script/CI) vs advisory (documentation) enforcement? Are blocking requirements backed by executable validation? What happens when enforcement degrades?
- Compliance mapping: Does the spec maintain Feature ID traceability across deliverables? Are quality gate checkpoints mapped to SDLC phases? Does each deliverable reference its upstream input?
- Adoption friction: How many new tools/processes does this spec introduce? Can existing agents follow this spec without definition changes? Is there a migration path from current to proposed state?
- Entry point symmetry: For EACH governance rule the document introduces or modifies, does it explicitly address which entry point categories apply (A: planned SDLC pipeline, B: Claude main shortcuts, C: skill-triggered code changes, D: indirect governance changes, E: future skills, F: Claude main as orchestrator)? For each applicable category, is enforcement type stated (Type 1 script / Type 2 definition / Type 3 doc / exempt with rationale)? Watchmen check: if rule is "universal", does it apply to the governance agent itself? Shortcut path check: does it apply when Claude main implements directly? Future-proof check: will new skills inheriting the default template get this rule? Are exemptions explicit with rationale (not implicit by omission)?

---

## Step 4: Quality Gate (mandatory)

After each agent pass, score:

- Clarity (1-10) — 9 = an implementer unfamiliar with the project could work from this spec without asking questions
- Implementability (1-10) — 9 = every requirement can be directly translated to code/config/process without interpretation
- Risk exposure (1-10) — 9 = all identified risks have documented mitigations; no unacknowledged risks
- Validation Integrity (1-10) — 9 = validation is concrete, unbiasable, and gate-enforced; N/A if spec has no V&V sections

If any score <9:
Fix issues before proceeding to the next agent.

---

## Step 5: Final Output

Return:

- The fully hardened document
- With all improvements integrated
- With explicit, testable requirements
- With risks eliminated or controlled

Do not include commentary.

Only output the final hardened version.
