# Getting Started with TopRig

## What You Need

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- `git` and `bash` 3.2+ (macOS default works; 4+ recommended)
- ~5 minutes

## Quick Start (3 commands)

```bash
# 1. Clone TopRig
git clone https://github.com/FrankSeiferth-WELL/toprig.git
cd toprig

# 2. Install to your Claude Code environment
./install.sh

# 3. Initialize in your project
cd ~/your-project
toprig init
```

That's it. Claude Code now has 13 agents, 20+ skills, and governance scripts active.

## Verify Installation

```bash
toprig validate
```

This checks: agents have frontmatter, skills have SKILL.md, hooks are installed, CLAUDE.md references valid paths.

## What Just Happened?

`install.sh` copied TopRig's governance framework to `~/.claude/`:

```
~/.claude/
├── agents/         13 SDLC agent definitions
├── skills/         20+ workflow skills (TDD, debugging, code review, etc.)
├── commands/       8 slash commands (/cross-check, /brainstorm, etc.)
└── CLAUDE.md       Global governance rules (merged with existing)
```

`toprig init` created a `project-config.yml` in your project with sensible defaults.

## Configure Your Project

Edit `project-config.yml`:

```yaml
project_name: "my-saas-app"        # REQUIRED
platform_type: "web-app"           # Optional hint

infrastructure:
  work_tracking:
    provider: github-issues        # or: beads, none
  secrets:
    provider: env-file             # or: bitwarden, 1password, none
```

See [configuration.md](configuration.md) for all options.

## Your First Workflow

Once installed, Claude Code automatically uses TopRig agents. Try:

```
> Implement a user authentication endpoint

Claude will:
1. Use the system-architect agent to design the API
2. Use the senior-backend-engineer to implement
3. Use TDD skill (write tests first)
4. Use QA agent to verify
5. Use cross-check before committing
```

## Available Slash Commands

| Command | What It Does |
|---------|-------------|
| `/cross-check` | Pre-merge validation sweep |
| `/brainstorm` | Interactive design refinement |
| `/write-plan` | Generate implementation plan |
| `/execute-plan` | Execute plan with checkpoints |
| `/sitrep` | Project status report |

## Troubleshooting

### "Skills not loading"
Run `toprig validate` — check that `~/.claude/skills/` has SKILL.md files in each directory.

### "Agents not available"
Verify `~/.claude/agents/*.md` files exist and start with `---` frontmatter.

### "Hooks not running"
Run `hooks/install.sh` from the TopRig repo to reinstall hooks.

## Next Steps

- [Agent Roster](agent-roster.md) — what each agent does
- [Skill Catalog](skill-catalog.md) — available workflow skills
- [Governance Model](governance-model.md) — how the SDLC workflow works
- [Security Model](security-model.md) — the 4-layer release gate
- [Configuration](configuration.md) — all config options
