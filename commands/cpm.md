Execute three steps in sequence: Commit, Push, Memory.

## Step 0: Sensitive Term Scan
```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
if [ -x "$REPO_ROOT/scripts/scan-sensitive-terms.sh" ]; then
  "$REPO_ROOT/scripts/scan-sensitive-terms.sh"
fi
```
If scan blocks: STOP. Report findings. Do not proceed to commit.
If scan passes or script not found: continue.

## Step 1: Commit
Follow the standard git commit protocol:
1. Run `git status` and `git diff` (staged + unstaged) and `git log --oneline -5` in parallel
2. Analyze all changes, draft a concise commit message (focus on "why" not "what")
3. Stage relevant files (specific files, not `git add -A`), create the commit with Co-Authored-By trailer
4. If pre-commit hook fails: fix the issue and create a NEW commit (never amend)

## Step 2: Push
After successful commit:
1. Push to remote: `git push`
2. If no upstream, use `git push -u origin <branch>`
3. Confirm push succeeded

## Step 3: Memory
After successful push, review what was done in this session and update memory if warranted:
1. Check if any session learnings qualify for memory (user preferences, project decisions, patient milestones, feedback)
2. If yes: update or create the appropriate memory file(s) in the project memory directory
3. If no new memory-worthy information: skip silently

Do NOT ask for confirmation between steps — execute all three sequentially. If any step fails, stop and report.
