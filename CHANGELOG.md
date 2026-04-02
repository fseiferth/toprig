# Changelog

All notable changes to TopRig will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Apache 2.0 license, NOTICE, README
- `.toprig-secret-patterns.example` with `.example` + gitignore architecture
- Pre-commit hook: diff-only scanning, context-aware (TopRig vs consumer)
- Pre-push hook: blocks push without release gate approval
- Hook installer (`hooks/install.sh`): idempotent, auto-creates patterns file
- GitHub Actions CI: security-scan.yml + validate.yml
- CODEOWNERS for security-sensitive paths
- Release gate skill: 4-layer security model (pattern scan, trufflehog, semantic review, human approval)
- Community health files: CONTRIBUTING.md, SECURITY.md, CODE_OF_CONDUCT.md
- Issue templates (bug, feature request) and PR template with security checklist
- This CHANGELOG

### Deferred
- License header check promoted from advisory to blocking (planned for v1.0)
- Provider resolution system (Phase 8 — future plan)

### Notes
- `v0.x` releases may include breaking changes. Upgrade carefully.
- `v1.0` will mark the first stable release with backwards compatibility guarantees.
