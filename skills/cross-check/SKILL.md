# Cross-Check

Pre-landing verification: catch oversights before claiming "done".

**Announce:** "Running cross-check before landing the plane."

---

## When to Use

**MANDATORY before:** closing epics, marking "complete", handing off, creating PRs.

**Triggered by:** "done", "complete", "ready to close", "land the plane", pre-governance epic closure.

---

## The Check (7 Steps)

### Step 1: Identify Scope

Run `git status` and `git diff`. Create scope list: "Changed X files, updated Y protocol, modified Z script."

Categories: code, protocols (CLAUDE.md, agents), scripts, documentation.

---

### Step 2: Open Beads Check

```bash
bd list --status open
```

Any beads that should be closed before landing? Flag as BLOCKER if orphaned beads exist for completed work.

---

### Step 3: Stub Detection (changed files only)

Grep changed files for shipped placeholders:

```bash
git diff --name-only HEAD~1 | xargs grep -n "TODO\|FIXME\|NotImplementedError\|throw.*not implemented\|pass  #"
```

Any hits in production code = BLOCKER (test files = WARNING).

---

### Step 4: Search for Obsolete References

Based on what changed, grep for old patterns across the codebase:
- Old protocol terms in agents/scripts/docs
- Deprecated function/class names
- Outdated config values, URLs, endpoints

Search both project (`./`) and global (`~/.claude/`) paths.

---

### Step 5: Cross-Reference Validation

| Layer | Files | Verify |
|-------|-------|--------|
| Project config | CLAUDE.md, SDLC-ROLE-MAPPING.md | Matches agent definitions |
| Global config | ~/.claude/CLAUDE.md | Aligns with project config |
| Agent definitions | ~/.claude/agents/*.md | Updated consistently |
| Scripts | scripts/*.sh | No obsolete validations |
| Documentation | docs/ | References current protocol |

Checklist:
- [ ] Project CLAUDE.md ↔ Global CLAUDE.md
- [ ] CLAUDE.md ↔ Agent definitions
- [ ] Agent definitions ↔ Scripts
- [ ] Documentation ↔ Implementation

---

### Step 6: Feature ID & UI Gates (conditional)

**If feature work:** Run `./scripts/validate-feature-id-system.sh` — verify `// FEAT-XXX` in code and commits.

**If `.tsx` files changed:** Verify `ui-guidelines-check` was run (check conversation history or state). Don't re-run — just confirm it happened. Flag WARNING if skipped.

---

### Step 7: Contradiction Detection & Report

**Scan for conflicting guidance:**
- Document A says X, Document B says not-X
- Agent definition requires Y, script blocks Y
- "Mandatory" in one doc, "optional" in another

**Report format:**

```
## CROSS-CHECK RESULTS

### Scope
Changed: [list]

### Issues Found
- [Category]: [file:line] description → fix

### Verdict
✅ CLEAN - Cleared to land
⚠️  MINOR - N non-blocking issues
❌ BLOCKER - Fix before landing

### Actions
1. [Fix]
```

---

### Step 8: Recommend Respect-the-Spec

After reporting results, recommend running the `respect-the-spec` agent for spec compliance validation:

```
*→ Recommend running respect-the-spec agent to validate implementation against specifications. Run it?*
```

Ask the user to approve or decline. If approved, invoke the `respect-the-spec` agent via Task tool.

**If declined:** No action. Continue to state tracking.

**If approved:** Run respect-the-spec, report results inline, then continue to state tracking.

**Note:** When invoked from `finishing-a-development-branch`, the landing skill handles this flow differently — see that skill for details.

---

## State Tracking

After completion: `echo "$(date -u +%s)" > ~/.claude/state/last-cross-check`

`finishing-a-development-branch` checks this timestamp to avoid duplicate runs.

---

## Rules

- If issues found: fix, re-run until clean.
- Always update state file after completion.

**Related:** `finishing-a-development-branch`, `governance-check`, `verification-before-completion`.
