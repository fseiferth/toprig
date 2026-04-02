# Governance Model

TopRig enforces a structured SDLC workflow where each phase has clear responsibilities, handover protocols, and quality gates.

## Workflow Sequence

```
PM → Designer → Architect → Engineers (BE+FE) → QA + Security → DevOps → Respect-the-Spec
```

Each transition requires handover validation via `verify-handover-ready.sh`.

## Key Principles

### 1. User Approval Required
Nothing runs autonomously without user approval. Claude analyzes, presents a plan, gets approval, then executes.

### 2. Plan-First
Claude always presents a plan before making changes. No surprise modifications.

### 3. Agent Self-Sufficiency
Bugs or deficiencies found by one agent are sent back to the accountable agent — not self-fixed by the reviewer.

### 4. TDD for Engineers
All engineering work follows RED-GREEN-REFACTOR. Tests before implementation.

### 5. Feature ID Traceability
Feature IDs flow across all phases: PRD → Design → Architecture → Code → Tests.

## Enforcement Hierarchy

**Type 1 (scripts)** > **Type 2 (agent definitions)** > **Type 3 (CLAUDE.md rules)**

- **Type 1**: Shell scripts that block commits/merges. Cannot be bypassed without `--no-verify`.
- **Type 2**: Agent frontmatter that defines behavior. Enforced by Claude Code agent system.
- **Type 3**: CLAUDE.md behavioral rules. Enforced by Claude's instruction following.

## Quality Gates

| Gate | Enforcement | Blocks |
|------|-------------|--------|
| Pre-commit hook | Type 1 (script) | Sensitive terms, prohibited files, workflow validation |
| Handover validation | Type 1 (script) | Missing docs, incomplete specs |
| Cross-check | Type 2 (skill) | Pre-merge sweep |
| Security gate | Type 1 + 2 | 4-layer scan before publication |
| Governance coverage | Type 1 (script) | Missing governance in CLAUDE.md |

## Scripts

| Script | Purpose |
|--------|---------|
| `verify-handover-ready.sh` | Validates phase transitions |
| `audit-workflow-compliance.sh` | Checks SDLC workflow adherence |
| `validate-governance-coverage.sh` | Ensures governance sections present |
| `validate-governance-symmetry.sh` | Checks consistency across docs |
| `gate-claude-md.sh` | Pre-commit CLAUDE.md validation |
| `quality-gate-functions.sh` | Shared quality gate utilities |

## Decision Tree: When to Involve Which Agent

| Change Type | Agents Needed |
|------------|---------------|
| Bug fix | Engineer → QA |
| Small feature (<100 lines) | Engineer → QA |
| Large feature (>100 lines) | PM → Designer → Architect → Engineer → QA |
| Security-sensitive | + Security Analyst |
| Infrastructure change | + DevOps |
| Breaking change | PM (RFC) → full pipeline |
