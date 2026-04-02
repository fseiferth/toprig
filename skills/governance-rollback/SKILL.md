# Governance Rollback Skill

## Overview

Rollback governance consolidation changes if they cause major regression.

## When to Use

**Triggers:** Discovery time >10%, agent confusion, quality degradation

**Criteria for rollback:**
- ❌ Discovery time increases >10%
- ❌ Agent confusion incidents increase
- ❌ Quality metrics degraded (spec compliance <95%, rework >5%)
- ❌ Major process breakdowns
- ❌ User feedback negative

**Do NOT rollback if:**
- ✅ Metrics improved or stable
- ✅ Minor regressions (<10%) with clear fix path
- ⚠️ Issues fixable without reverting structure

## Rollback Procedure

### Phase 1: Assess Impact
- Review health check report (which metrics regressed?)
- Determine root cause (structural issue vs implementation bug)
- Impact assessment (all agents vs specific roles)

### Phase 2: User Decision Point
Present options:
1. **Rollback** - Restore previous structure (safe, immediate)
2. **Fix Forward** - Adjust implementation (riskier, takes time)
3. **Monitor** - Give it another week (delay decision)

### Phase 3: Execute Rollback (If Approved)

```bash
# 3A. Backup Current State
git checkout -b governance-consolidated-backup-$(date +%Y-%m-%d)
git add .
git commit -m "Backup: Preserve consolidated governance before rollback"
git push -u origin governance-consolidated-backup-$(date +%Y-%m-%d)
git checkout main

# 3B. Restore Previous Structure
# Find backup file or commit
cp ~/.claude/agents/governance.md.pre-phase-14-* ~/.claude/agents/governance.md

# OR from git
git log --oneline --all --grep="governance" -n 10
git checkout {commit-hash} -- ~/.claude/agents/governance.md

# 3C. Verify Restoration
wc -l ~/.claude/agents/governance.md  # Should be ~1,958 lines

# 3D. Commit Rollback
git add ~/.claude/agents/governance.md
git commit -m "rollback: Restore governance.md due to regression

Health check detected major regression in [metrics].
Restoring previous structure.

Consolidated version preserved in branch: governance-consolidated-backup-$(date +%Y-%m-%d)

🤖 Generated with Claude Code"

git push origin main
```

### Phase 4: Post-Rollback Analysis
- Document why consolidation failed
- Write rollback analysis report
- Notify team of structure change
- Plan improved consolidation approach

## Rollback Prevention (Future Changes)

**Before implementing any future governance consolidation:**
1. **Pilot Test** - Try with subset first
2. **A/B Test** - Run old and new in parallel for 1 week
3. **Agent Training** - Update prompts BEFORE switching
4. **Navigation Aids** - Add TOC, index, jump links
5. **Incremental Rollout** - Move gradually (not all at once)

## Backup Locations

- **File backup:** `~/.claude/agents/governance.md.pre-phase-14-*`
- **Git branch:** `phase-14-backup-baseline` (if created)
- **Consolidated backup:** `governance-consolidated-backup-YYYY-MM-DD` (created during rollback)
