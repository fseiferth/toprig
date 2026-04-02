# Skill Catalog

TopRig ships 20+ workflow skills organized by category. Each skill is a directory under `skills/` containing a `SKILL.md` file.

## Development Workflow

| Skill | Purpose | Auto-invoked? |
|-------|---------|---------------|
| `test-driven-development` | RED-GREEN-REFACTOR cycle | Yes — when implementing features |
| `systematic-debugging` | 4-phase debugging framework | Yes — when bugs/errors mentioned |
| `defense-in-depth` | Multi-layer validation | When invalid data causes deep failures |
| `root-cause-tracing` | Trace bugs backward through call stack | When errors occur deep in execution |
| `condition-based-waiting` | Replace timeouts with condition polling | When tests have race conditions |

## Planning & Design

| Skill | Purpose | Auto-invoked? |
|-------|---------|---------------|
| `brainstorming` | Socratic method design refinement | Ask first |
| `writing-plans` | Detailed implementation plans | When design is complete |
| `executing-plans` | Execute plans with review checkpoints | When plan is ready |
| `prompt-engineering` | Structured prompts (CO-STAR, TIDD-EC) | For multi-step tasks |

## Quality & Review

| Skill | Purpose | Auto-invoked? |
|-------|---------|---------------|
| `cross-check` | Pre-merge validation sweep | Yes — before landing |
| `verification-before-completion` | Final checks before "done" | Yes — before commit/PR |
| `finishing-a-development-branch` | Branch completion workflow | Yes — "land the plane" |
| `spec-hardening` | Multi-agent review of specs/plans | On "harden spec" |

## Governance

| Skill | Purpose | Auto-invoked? |
|-------|---------|---------------|
| `governance-cascade` | Eliminate redundant governance | Ask first |
| `governance-rollback` | Revert governance changes | When rollback needed |
| `simplification-cascade` | Find insights that eliminate complexity | Ask first |
| `claude-md-steward` | Safe CLAUDE.md editing | Yes — when CLAUDE.md modified |

## Meta & Tooling

| Skill | Purpose | Auto-invoked? |
|-------|---------|---------------|
| `when-stuck` | Dispatch to right problem-solving technique | Yes — when stuck |
| `dispatching-parallel-agents` | Run 3+ independent investigations | For parallel failures |
| `writing-skills` | Create/edit skills with TDD | When creating skills |
| `toprig-handoff-state` | Session continuity across conversations | For session handoffs |
| `toprig-release-gate` | 4-layer security gate before publishing | Before any push |

## Adding Your Own Skills

Create a new directory under `skills/` with a `SKILL.md` file following the standard format. See `writing-skills` skill for the creation workflow.
