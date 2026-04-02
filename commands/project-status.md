# Project Status

Use AskUserQuestion to ask the user which audit they want:

1. **Codebase health** — What's done, pending, stale in the project (git status, file structure, tests, docs)
2. **Stream dashboard** — Status of all Claude Code streams: phase, progress, beads, what's done/underway/pending

Wait for selection before proceeding.

---

## Option 1: Codebase Health

Produce a comprehensive status table for the current project. Answers three questions: what's done (with purpose), what's underway/pending, and what's stale/untouched.

### Data Collection (do ALL of these)

**Git State:**
- `git log --oneline -20` — recent activity
- `git status --short` — uncommitted changes
- `git branch -vv` — current branch, tracking, ahead/behind remote
- `git stash list` — any stashed work

**Project Structure Discovery (project-agnostic):**
- Read `CLAUDE.md` (project root) for project description, structure, conventions
- Read project memory files if they exist (`.claude/projects/*/memory/MEMORY.md`)
- `ls` top-level directories to understand project layout
- Identify key areas: source code, tests, docs, configs, data, scripts, infrastructure

**Completeness Inventory — for each major area:**
- Does it have content? (files exist, non-empty)
- When was it last touched? (`git log -1 --format="%ar" -- <path>`)
- Are there TODOs, FIXMEs, or incomplete markers?

**Test & CI Status (if applicable):**
- Check for test files and whether they appear maintained
- Check CI config (`.github/workflows/`, `Jenkinsfile`, etc.)

### Output Format

```
Branch: main (tracking origin/main, up to date)
Uncommitted: 2 modified, 1 untracked
Push: 3 commits ahead of origin/main
Stashes: none
```

Status table with columns: **Area**, **Status**, **Detail**
- ✅ Done — complete, stable
- 🟡 Underway/Pending — work started but incomplete
- 🔴 Not started / Stale — no meaningful work, or untouched >30 days

Group rows by what the project contains (CORE, TESTS, DOCS, INFRA, DATA — adapt to project).

Summary bullets: what's healthy, what needs attention, what's stale.

### Rules
1. Read actual files — don't guess from names alone
2. Recency matters — >30 days without commits = potentially stale
3. Uncommitted work and push status always called out
4. Adapt to the project — discover structure dynamically
5. Keep detail column concise

---

## Option 2: Stream Dashboard

Full dashboard of all Claude Code streams for this project — active, completed, dropped, with phase and progress.

### How It Works

The dashboard uses `~/.claude/scripts/stream-dashboard.py` which:
1. Reads `sessions-index.json` for indexed sessions (topic, timestamps, message count, branch — no JSONL parsing needed)
2. Scans for un-indexed JSONL files and extracts basic metadata via head/tail
3. Detects phase via `tool_use` pattern scan on last 50 lines (not keyword matching)
4. Renders a structured dashboard

### Run the Dashboard

Determine the project streams directory from the current working directory. Claude Code encodes the full path by replacing `/` with `-`:

```bash
PROJECT_STREAMS=~/.claude/projects/$(echo "$PWD" | sed 's|/|-|g')
python3 ~/.claude/scripts/stream-dashboard.py --project-dir "$PROJECT_STREAMS" --days 7
```

Display the output directly to the user.

If the user wants a different time range, pass `--days N`. For JSON output, pass `--format json`.

### Enrich with Context (optional, skip silently if unavailable)

After showing the dashboard, optionally enrich with:

**Beads** (only if `bd` exists):
```bash
bd list 2>/dev/null
```
If available, cross-reference open beads with stream topics.

**Git worktrees** (always check):
```bash
git worktree list 2>/dev/null
```
Map worktrees to streams if branch names correlate.

### Phase Detection (tool-based)

The script detects phase by scanning `tool_use` entries in the last 50 lines:
- `Edit`, `Write`, `NotebookEdit` → 🟡 Implementing
- `Bash` with test/jest/pytest → 🟠 Testing
- `Bash` with git commit/push/pr → 🟢 Review
- `AskUserQuestion` as last entry → ⏸️ Waiting
- `Skill` with spec-hardening → 🟣 Hardening
- `Skill` with brainstorming/writing-plans → 🔵 Planning
- `EnterPlanMode` → 🔵 Planning
- Small session + no recent activity → ✅ Complete or 🔴 Dropped

### Display Rules
- Sort active streams by last activity (most recent first)
- Phase icon is the most important visual — make it scannable
- Keep topic to ~50 chars, truncate with ellipsis
- Skip streams <1KB (empty/trivial)
- If >20 recent streams, show top 15 and summarize rest
