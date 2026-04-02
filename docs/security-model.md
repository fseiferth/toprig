# Security Model

TopRig's primary security concern is preventing private project data from leaking into public repositories.

## 4-Layer Release Gate

Every push to the TopRig public repo must pass all 4 layers:

### Layer 0 — Pattern File Integrity
SHA256 checksum of `.toprig-secret-patterns.example` verified before any scan. Prevents tampered pattern files from weakening the gate.

### Layer 1 — Automated Pattern Scan
Regex patterns from `.toprig-secret-patterns` scan all tracked files for:
- Personal identifiable information (paths, names)
- Credentials and secrets (API keys, tokens, connection strings)
- Private project references (project names, bead IDs)
- Product domain terms (app-specific nouns)
- Infrastructure identifiers (URLs, IPs)

### Layer 2 — Entropy Detection
TruffleHog scans for high-entropy strings that look like API keys or tokens, even if they don't match known patterns.

### Layer 2.5 — Encoded Content Scan
Base64 and hex-encoded strings are decoded and re-scanned against CRITICAL patterns. Catches obfuscated secrets.

### Layer 3 — Semantic Review
Security analyst agent performs contextual review using the S1-S8 checklist:
- S1: No product domain terms
- S2: No tech stack fingerprints
- S3: No user PII or paths
- S4: No project-specific IDs
- S5: No encoded secrets
- S6: Examples are generic
- S7: No binary metadata leakage
- S8: No git metadata leakage

### Layer 4 — Human Approval
User must type exact phrase: `APPROVE TOPRIG RELEASE <commit-sha>`. No shortcuts.

## Secret Patterns Architecture

```
.toprig-secret-patterns.example    ← Committed (generic rules)
.toprig-secret-patterns            ← Gitignored (consumer adds private terms)
```

Consumers customize by adding Category 3 (client names, business terms) to the real file. Private terms never flow upstream.

## Pre-Commit Hook

Scans staged diff-only (new/changed lines). Context-aware:
- **In TopRig**: All categories enforced
- **In consumer repos**: Categories 1-2 skipped (project name/paths are expected)

## CI Pipeline

GitHub Actions run on every PR:
- Pattern integrity verification
- TruffleHog entropy scan
- Custom pattern scan
- Encoded content scan
- Submodule/symlink/binary checks

## Trust Boundary

TopRig is canonical for generic governance content. Consumer `~/.claude/` is the installed (derived) copy. Propagation flows one-way: TopRig repo → `~/.claude/`. Never the reverse.
