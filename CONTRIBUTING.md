# Contributing to TopRig

Thank you for your interest in contributing to TopRig.

## How TopRig Works

TopRig is a **downstream-only** governance framework. Changes flow from the TopRig repo to consumer projects via `install.sh` or the `toprig-propagate` skill. Consumer projects never push changes back upstream — they override via their `project-config.yml` and project-specific CLAUDE.md sections.

## Before You Start

- **Open an issue first** for any non-trivial change. Discuss before coding.
- **Breaking changes require an RFC** — open an issue tagged `rfc` with your proposal.
- **Core governance logic changes** (skills that affect workflow, agent definitions, validation scripts) require prior discussion and maintainer approval before any PR.

## Developer Certificate of Origin (DCO)

All contributions must include a `Signed-off-by` line in the commit message, certifying that you have the right to submit the work under this project's Apache 2.0 license.

```
Signed-off-by: Your Name <your.email@example.com>
```

Use `git commit -s` to add this automatically. PRs without DCO sign-off will not be merged.

## Pull Request Guidelines

### Size
- **Maximum 200 lines changed** per PR. Smaller PRs get faster, more thorough reviews.
- If your change is larger, split it into sequential PRs.

### Description
- Explain **WHY** you're making this change, not just what changed.
- Link to the issue this PR addresses.
- Describe how you tested the change.

### Requirements
- All CI checks must pass (security scan, shellcheck, linting)
- No CRITICAL or HIGH patterns from `.toprig-secret-patterns`
- Shell scripts must pass `shellcheck`
- Markdown must be well-formed

### What Gets Accepted
- Bug fixes with clear reproduction steps
- Documentation improvements
- New skills/agents that are **genuinely generic** (not project-specific)
- Governance script improvements with tests

### What Doesn't Get Accepted
- Changes the maintainer can't fully evaluate or understand
- Project-specific customizations (use your project's config layer instead)
- Features without prior issue discussion
- PRs that expand scope beyond the linked issue

## Code Style

- Shell scripts: POSIX-compatible where possible, `shellcheck` clean
- Markdown: ATX headings, fenced code blocks, no trailing whitespace
- YAML: 2-space indent, quoted strings for values with special characters

## Security Considerations

TopRig's primary security concern is **preventing private project data from leaking into public repos**. When contributing:

- Never include project-specific examples (use generic names like `MyApp`, `ItemCard`, `ResourceService`)
- Never hardcode paths, credentials, vault IDs, or email patterns
- Use `${VARIABLE}` placeholders for any value that varies per project
- Run `./scripts/release-gate.sh --dry-run` before submitting your PR
- All CI security checks must pass — the pre-commit hook will catch most issues locally

If you discover a security vulnerability, see [SECURITY.md](SECURITY.md).

## Questions?

Open a Discussion (not an Issue) for questions about usage, architecture, or contribution ideas.

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.
