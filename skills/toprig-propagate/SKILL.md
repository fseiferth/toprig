# TopRig Propagate

> **Type:** Maintenance skill
> **Trigger:** When updated skills/agents/scripts need to flow from private project to TopRig
> **Direction:** One-way. Private → TopRig. Never reverse.

## Purpose

Propagate updated governance content from the TopRig repo working directory to the public repo, with security scanning at every step.

## Usage

```
/toprig:propagate skill systematic-debugging
/toprig:propagate agent senior-backend-engineer
/toprig:propagate script validate-governance-coverage.sh
```

## Workflow

1. **Verify source identity** — source must be the TopRig repo working directory (from `~/.toprig/config.yml` allowlist), NOT `~/.claude/` (installed copy may have user modifications)
2. **Copy file(s)** from source to staging area
3. **Remove backup files** (`.pre-*`, `.bak`, `.backup`)
4. **Run pattern scan** — `.toprig-secret-patterns` (SP1) against copied content
5. **Run encoded content scan** (SP5) — decode base64/hex, re-scan
6. **Verify text MIME type** — reject binary files or files >100KB (SP15)
7. **If clean:** create branch `propagate/<name>`, commit with `Propagated-from:` trailer
8. **Open PR** via `gh pr create` — CI runs automatically
9. **Before merge:** run `toprig-release-gate` (4-layer gate)

## Source Resolution

The propagation source is determined from `~/.toprig/config.yml`:

```yaml
# ~/.toprig/config.yml
source_repos:
  - /path/to/toprig    # Local TopRig repo working directory
```

The skill:
- Reads `source_repos` allowlist
- Verifies the source path is a git repo
- Verifies the source is NOT `~/.claude/` (installed location)
- If source not in allowlist: EXIT 1

## Commit Trailer

Each propagated commit includes a hashed project identifier:

```
Propagated-from: sha256:a1b2c3d4...
```

The hash prevents leaking the private project name while maintaining traceability.

## Pre-Propagation Checklist

Before propagating, verify the feature is ready:

- [ ] Feature is complete and tested in the source project
- [ ] All project-specific references removed (domain terms, paths, credentials)
- [ ] Examples use generic placeholder names
- [ ] Feature works standalone (no private dependencies)
- [ ] CHANGELOG.md updated with the change
- [ ] Version bumped if this is a release

## What Gets Rejected

- Files containing CRITICAL/HIGH patterns
- Binary files or files >100KB
- Files from `~/.claude/` (must be from repo working directory)
- Source repo not in allowlist
- Encoded content that decodes to sensitive data

## Post-Propagation

After the PR is merged:
1. Update CHANGELOG.md
2. Consider bumping version
3. Update docs if the propagated content changes behavior
4. Run `toprig validate` to verify integrity
