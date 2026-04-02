# TopRig

![Version](https://img.shields.io/badge/version-v0.1.0--dev-orange)
![License](https://img.shields.io/badge/license-Apache%202.0-blue)

**A governance engine for AI-assisted software development.**

TopRig is a process framework and agent orchestration engine that brings structured governance to AI-powered SDLC workflows. It provides skills, agents, commands, scripts, and configuration templates that work with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) to enforce quality gates, handover protocols, and development best practices.

## Status

Early development. Not yet ready for external use. Published to establish prior art and IP.

## What TopRig Is

- A **governance framework** — skills, agents, and scripts that enforce SDLC quality
- A **process engine** — structured workflows for PM → Design → Architecture → Engineering → QA → Security → DevOps
- A **Claude Code extension** — skills and agents that plug into Claude Code's agent system
- **Infrastructure-agnostic** — works with any database, auth provider, project tracker, or secrets manager

## What TopRig Is NOT

- Not a mobile app or web application
- Not a database, authentication system, or deployment tool
- Not tied to any specific tech stack (React Native, Supabase, etc.)
- Not a replacement for Claude Code — it extends it

## Components

| Category | Description |
|----------|-------------|
| **Skills** | Workflow skills for TDD, debugging, code review, governance, spec hardening, and more |
| **Agents** | SDLC agent definitions (PM, Architect, Engineers, QA, Security, Governance, etc.) |
| **Commands** | Claude Code slash commands for common workflows |
| **Scripts** | Governance validation, handover verification, quality gates |
| **Templates** | CLAUDE.md framework, project config schema, document structure templates |

## License

Apache License 2.0 — see [LICENSE](LICENSE) for details.

## Author

Frank Seiferth
