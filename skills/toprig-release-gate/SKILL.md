# TopRig Release Gate

> **Type:** Security gate skill
> **Trigger:** Before any `git push`, `gh pr merge`, `gh release create`, or propagation to TopRig
> **NEVER skippable.** No `--force`, `--skip-gate`, or `--no-verify` flags exist.

## Purpose

Enforce the 4-layer security model before any TopRig content becomes publicly visible. This skill orchestrates the automated script (`scripts/release-gate.sh`) and the manual semantic review (Layer 3).

## Layers

| Layer | Tool | What It Catches | Pass Criteria |
|-------|------|-----------------|---------------|
| 0 | SHA256 checksum | Tampered pattern file | Checksum matches (SP1) |
| 1 | `.toprig-secret-patterns` scan | Known secrets, PII, paths, domain terms | 0 CRITICAL/HIGH |
| 2 | TruffleHog | High-entropy strings (API keys, tokens) | 0 findings |
| 2.5 | Base64/hex decode + re-scan | Obfuscated secrets, encoded paths | 0 CRITICAL decoded matches |
| 3 | Security analyst agent | Contextual leakage (domain hints, architecture clues) | S1-S8 all PASS |
| 4 | Interactive prompt | Final human judgment on full diff | User types exact phrase |

## How to Run

### Dry run (check without approving)
```bash
./scripts/release-gate.sh --dry-run
```

### Full gate (automated layers + human approval)
```bash
./scripts/release-gate.sh
```

### With semantic review (Layer 3) — invoke as skill
When invoked as a Claude skill, this additionally dispatches the security analyst agent for semantic review using the S1-S8 checklist before presenting the approval prompt.

## Layer 3 — Semantic Review Checklist (S1-S8)

The security analyst agent verifies:

| # | Check | PASS Condition |
|---|-------|----------------|
| S1 | No product domain terms | Zero matches for app-specific nouns |
| S2 | No tech stack fingerprints | Zero references to specific backend/DB/infra choices |
| S3 | No user PII or paths | Zero absolute paths, usernames, email addresses, IPs |
| S4 | No project-specific IDs | Zero bead IDs, Linear IDs, vault IDs from private projects |
| S5 | No encoded/obfuscated secrets | Zero base64/hex strings decoding to sensitive content |
| S6 | Examples are generic | All examples use placeholder names (MyApp, ItemCard, ResourceService) |
| S7 | No binary files with private metadata | Zero EXIF author/GPS/creator/comment fields |
| S8 | No git metadata leakage | Zero git notes, reflog, stash references to private projects |

## Failure Handling

- **Any layer fails → gate blocks.** Fix the issue and re-run from Layer 0.
- **Agent unavailable → gate blocks** (fail-closed). No `--skip-semantic` flag.
- **Wrong approval phrase → rejected.** Must type exact phrase with correct SHA.

## Approval Logging

All approvals are logged to `~/.toprig/approval-log.yml` with:
- Timestamp, SHA, branch
- Each layer's verdict
- Approver identity

The approved SHA is added to `.toprig-approved-shas` (gitignored, local-only), which the pre-push hook checks.

## Workflow

```
Claude invokes release-gate skill
  → Run scripts/release-gate.sh --dry-run (Layers 0, 1, 2, 2.5)
  → If all pass: dispatch security-analyst agent (Layer 3, S1-S8)
  → If all pass: present results + approval prompt to user (Layer 4)
  → User types: APPROVE TOPRIG RELEASE <sha>
  → SHA added to .toprig-approved-shas
  → git push now succeeds (pre-push hook checks approved SHAs)
```
