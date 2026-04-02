# TopRig Configuration Guide

## Overview

TopRig uses a `project-config.yml` file to customize the governance framework for your project. This file lives in your project root (not in the TopRig repo).

## Quick Start

```bash
# Copy the template to your project
cp toprig/templates/project-config.yml ./project-config.yml

# Edit with your project values
$EDITOR project-config.yml

# Initialize TopRig with your config
toprig init
```

## Configuration Reference

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `project_name` | string | Your project name (alphanumeric + hyphens). Used in templates, test emails, file paths. |

### Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `platform_type` | string | `""` | Project type hint (mobile-native, web-app, api-service, monorepo) |
| `test_email_pattern` | string | `${project_name}${counter}${agent}@mailinator.com` | Test email pattern for QA/engineering agents |
| `feature_id.format` | string | `FEAT-XXX` | Feature ID format for traceability |
| `feature_id.registry` | string | `product-docs/FEATURE-REGISTRY.md` | Path to feature registry |

### Infrastructure Providers

TopRig is infrastructure-agnostic. Configure which tools your project uses:

#### Work Tracking
```yaml
infrastructure:
  work_tracking:
    provider: beads    # beads | github-issues | none
```

- **beads**: Uses the `bd` CLI for git-backed issue tracking
- **github-issues**: Uses `gh issue` commands
- **none**: No automated work tracking (manual)

#### Secrets Management
```yaml
infrastructure:
  secrets:
    provider: bitwarden    # bitwarden | 1password | env-file | none
    vault_id: "your-vault-id"
    server: "vault.bitwarden.eu"
```

- **bitwarden**: Uses Bitwarden MCP server
- **1password**: Uses 1Password CLI/MCP
- **env-file**: Uses `.env` files (ensure `.env` is in `.gitignore`)
- **none**: Manual credential management

#### Project Tracker
```yaml
infrastructure:
  project_tracker:
    provider: linear    # linear | jira | github | none
```

#### Code Intelligence
```yaml
infrastructure:
  code_intelligence:
    provider: serena    # serena | none
```

## Template Variables

When `toprig init` renders the CLAUDE.md template, these variables are resolved from your config:

| Variable | Source | Example |
|----------|--------|---------|
| `${PROJECT_NAME}` | `project_name` | `MyApp` |
| `${PLATFORM_TYPE}` | `platform_type` | `mobile-native` |
| `${TEST_EMAIL_PATTERN}` | `test_email_pattern` | `myapp${counter}${agent}@mailinator.com` |
| `${FEATURE_ID_FORMAT}` | `feature_id.format` | `FEAT-XXX` |
| `${FEATURE_REGISTRY_PATH}` | `feature_id.registry` | `product-docs/FEATURE-REGISTRY.md` |
| `${VAULT_ID}` | `infrastructure.secrets.vault_id` | `abc123-def456` |

Unresolved variables are left as `${VARIABLE_NAME}` in the output with a warning to stderr.

## Validation

```bash
# Validate your config
toprig validate

# Check for required fields and valid enum values
toprig init --validate-only
```

### Validation Rules

- `project_name`: Required, alphanumeric + hyphens only, no shell metacharacters
- `infrastructure.*.provider`: Must be one of the documented enum values
- `infrastructure.secrets.vault_id`: Required if secrets provider is not `none`
