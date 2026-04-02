Generate a project situation report: what's done, what's underway, and what's yet to do.

## Data Collection (run ALL in parallel where possible)

### 1. Git History
```bash
git log --oneline -25
git log --oneline --since="4 weeks ago" | wc -l
```
Purpose: Recent commits = completed work. Count = velocity indicator.

### 2. Beads (work tracking)
```bash
bd list -s open 2>/dev/null
bd list -s in_progress 2>/dev/null
bd list -s closed --sort updated -r -n 10 2>/dev/null
bd list -s blocked 2>/dev/null
bd list -s deferred 2>/dev/null
```
Purpose: Active work items. If `bd` is not installed, skip silently.

### 3. Linear Issues
Use MCP tools if available:
- `mcp__linear-server__issue` action=list, status="In Progress", limit=10
- `mcp__linear-server__issue` action=list, status="Todo", limit=10
- `mcp__linear-server__issue` action=list, status="Backlog", limit=50

If Linear MCP is not available, skip silently.

### 4. Dev Diary (recent reports)
Look for dev diary files:
```bash
ls dev-diary/weekly/*.md 2>/dev/null | tail -3
ls dev-diary/daily/*.md 2>/dev/null | tail -3
```
Read the most recent weekly report for context on what was accomplished.
If no diary exists, skip silently.

### 5. Plans
```bash
ls docs/plans/*.md 2>/dev/null
```
Search for status markers (`EXECUTED`, `COMPLETE`, `HISTORICAL`, `SUPERSEDED`) to classify plans.
Plans without these markers = pending/active.

## Output Format

Produce THREE tables, then a one-line summary at the bottom.

### Table 1: Recently Completed

| When | What | Purpose |
|------|------|---------|
Group by time period (week or date range). Derive "Purpose" from commit messages, diary entries, or bead close reasons. Collapse related commits into single rows (e.g., 15 governance commits = 1 row about governance work). Max 8 rows.

### Table 2: In Progress / Underway

| Item | Status | Notes |
|------|--------|-------|
Include: open beads, in-progress Linear issues, active plans (not marked EXECUTED/COMPLETE), any unfinished work from diary. Show actual status (plan written, partially built, blocked, etc.). Max 8 rows. If nothing is in progress, say "Nothing active."

### Table 3: Backlog (yet to do)

| Category | Count | Examples |
|----------|-------|---------|
Group Linear backlog + deferred beads by domain/category. Show count per category and 2-3 example titles. Max 8 rows. If no backlog exists, say "No backlog tracked."

### Summary Line

End with italic arrow pointing to the key insight, e.g.:
`*→ You've been in infrastructure mode for 4 weeks. App features haven't moved since Dec. What do you want to pick up?*`
or
`*→ 3 items actively underway, 24 in backlog. Nearest completion: auth API (80% done).*`

## Rules

- **Adapt to what's available.** Not every project has beads, Linear, diary, or plans. Use whatever sources exist. Minimum viable sitrep = git log only.
- **Collapse, don't enumerate.** 20 governance commits = 1 row. 15 similar backlog items = 1 category row with count.
- **No file creation.** Output is inline only.
- **Be opinionated in the summary.** Call out if the project has been stuck on infrastructure, if there's stale work, or if velocity dropped.
- **Fast.** Collect all data in parallel. Don't read files you don't need. Skip sources that error.
